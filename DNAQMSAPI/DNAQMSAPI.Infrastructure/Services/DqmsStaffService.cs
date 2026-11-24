using System.Data;
using AntiGravity.Enterprise.Shared.Core.Enums;
using AntiGravity.Enterprise.Shared.Core.Models;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Infrastructure.Models;

namespace DNAQMSAPI.Infrastructure.Services
{
    public interface IDqmsStaffService
    {
        Task<ApiResponse<object>> IssueTokenAsync(IssueTokenRequestDto dto, int userId);
        Task<ApiResponse<object>> CallNextTokenAsync(CallNextTokenRequestDto dto, int userId);
        Task<ApiResponse<object>> UpdateTokenStatusAsync(UpdateTokenStatusRequestDto dto, int userId);
        Task<ApiResponse<object>> ForwardTokenAsync(ForwardTokenRequestDto dto, int userId);
        Task<ApiResponse<TokenWorkflowHistoryDto>> GetTokenWorkflowHistoryAsync(int tokenId, string? tokenNumber);
        Task<ApiResponse<IEnumerable<ProcessStepDto>>> GetProcessStepsAsync(int? processId);
        Task<ApiResponse<IEnumerable<TokenTransactionModel>>> GetTokenQueueAsync(int organizationId, int locationId, int processId, int counterId);
    }

    public class DqmsStaffService : IDqmsStaffService
    {
        private readonly DNAQMSAPI.Application.Interfaces.IDapperDBFactory _dbFactory;
        private readonly IWebhookDispatcher? _webhookDispatcher;

        public DqmsStaffService(
            DNAQMSAPI.Application.Interfaces.IDapperDBFactory dbFactory,
            IWebhookDispatcher? webhookDispatcher = null)
        {
            _dbFactory = dbFactory;
            _webhookDispatcher = webhookDispatcher;
        }

        public async Task<ApiResponse<object>> IssueTokenAsync(IssueTokenRequestDto dto, int userId)
        {
            try
            {
                var parameters = new
                {
                    p_OrganizationId = dto.OrganizationId,
                    p_LocationId = dto.LocationId,
                    p_AreaId = dto.AreaId,
                    p_ProcessId = dto.ProcessId,
                    p_PriorityTier = dto.PriorityTier,
                    p_CustomerName = dto.CustomerName,
                    p_CustomerPhone = dto.CustomerPhone,
                    p_UID = userId
                };

                var result = await _dbFactory.QuerySingleAsync<SPResult>(
                    "PR_IU_IssueToken",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                if (result != null && result.ErrNo == 0)
                {
                    _ = _webhookDispatcher?.EnqueueEventAsync("token.issued", dto.OrganizationId, dto.LocationId, new
                    {
                        tokenId = result.ID,
                        processId = dto.ProcessId,
                        areaId = dto.AreaId,
                        priorityTier = dto.PriorityTier,
                        customerName = dto.CustomerName,
                        customerPhone = dto.CustomerPhone
                    });

                    return ApiResponse<object>.Ok(new { tokenId = result.ID }, "Token issued successfully");
                }

                return ApiResponse<object>.Fail(result?.ErrMsg ?? "Failed to issue token.");
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.Fail($"Database notice: {ex.Message}");
            }
        }

        public async Task<ApiResponse<object>> CallNextTokenAsync(CallNextTokenRequestDto dto, int userId)
        {
            try
            {
                var parameters = new
                {
                    p_OrganizationId = dto.OrganizationId,
                    p_LocationId = dto.LocationId,
                    p_CounterId = dto.CounterId,
                    p_ProcessId = dto.ProcessId,
                    p_UserId = userId
                };

                var result = await _dbFactory.QuerySingleAsync<SPResult>(
                    "PR_IU_CallNextToken",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                if (result != null && result.ErrNo == 0)
                {
                    _ = _webhookDispatcher?.EnqueueEventAsync("token.called", dto.OrganizationId, dto.LocationId, new
                    {
                        tokenId = result.ID,
                        counterId = dto.CounterId,
                        processId = dto.ProcessId,
                        callerUserId = userId
                    });

                    return ApiResponse<object>.Ok(new { tokenId = result.ID }, "Next token called successfully");
                }

                return ApiResponse<object>.Fail(result?.ErrMsg ?? "No tokens in queue.");
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.Fail($"Database notice: {ex.Message}");
            }
        }

        public async Task<ApiResponse<object>> UpdateTokenStatusAsync(UpdateTokenStatusRequestDto dto, int userId)
        {
            try
            {
                var parameters = new
                {
                    p_TokenId = dto.TokenId,
                    p_NewStatus = dto.NewStatus,
                    p_Reason = dto.Reason,
                    p_UserId = userId
                };

                var result = await _dbFactory.QuerySingleAsync<SPResult>(
                    "PR_IU_UpdateTokenStatus",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                if (result != null && result.ErrNo == 0)
                {
                    string eventCode = dto.NewStatus switch
                    {
                        18004 => "token.serving",
                        18005 => "token.hold",
                        18006 => "token.canceled",
                        18007 => "token.completed",
                        _ => "token.updated"
                    };

                    _ = _webhookDispatcher?.EnqueueEventAsync(eventCode, 1, null, new
                    {
                        tokenId = dto.TokenId,
                        newStatus = dto.NewStatus,
                        reason = dto.Reason,
                        userId = userId
                    });

                    return ApiResponse<object>.Ok(new { tokenId = result.ID }, "Token status updated successfully");
                }

                return ApiResponse<object>.Fail(result?.ErrMsg ?? "Failed to update token status.");
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.Fail($"Database notice: {ex.Message}");
            }
        }

        public async Task<ApiResponse<object>> ForwardTokenAsync(ForwardTokenRequestDto dto, int userId)
        {
            try
            {
                var effectiveUserId = dto.StaffUserId > 0 ? dto.StaffUserId : (userId > 0 ? userId : 1);
                var parameters = new
                {
                    p_TokenId = dto.TokenId,
                    p_TargetProcessId = dto.TargetProcessId,
                    p_TargetCounterId = dto.TargetCounterId,
                    p_IsSubToken = dto.IsSubToken ? (byte)1 : (byte)0,
                    p_Reason = dto.Reason,
                    p_UserId = effectiveUserId
                };

                var result = await _dbFactory.QuerySingleAsync<dynamic>(
                    "PR_IU_ForwardToken",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                if (result != null && (int)result.ErrNo == 0)
                {
                    _ = _webhookDispatcher?.EnqueueEventAsync("token.forwarded", 1, null, new
                    {
                        tokenId = (int)result.ID,
                        tokenNumber = (string)result.TokenNumber,
                        targetProcessId = dto.TargetProcessId,
                        stepOrder = (int)result.StepOrder,
                        stepName = (string)result.StepName,
                        isSubToken = dto.IsSubToken
                    });

                    return ApiResponse<object>.Ok(new
                    {
                        tokenId = (int)result.ID,
                        tokenNumber = (string)result.TokenNumber,
                        processId = (int)result.ProcessId,
                        stepOrder = (int)result.StepOrder,
                        stepName = (string)result.StepName,
                        isSubToken = dto.IsSubToken
                    }, (string)result.ErrMsg);
                }

                return ApiResponse<object>.Fail((string)result?.ErrMsg ?? "Failed to forward token.");
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.Fail($"Database notice: {ex.Message}");
            }
        }

        public async Task<ApiResponse<TokenWorkflowHistoryDto>> GetTokenWorkflowHistoryAsync(int tokenId, string? tokenNumber)
        {
            try
            {
                var parameters = new
                {
                    p_TokenId = tokenId,
                    p_TokenNumber = tokenNumber ?? string.Empty
                };

                using var grid = await _dbFactory.QueryMultipleAsync("PR_S_TokenWorkflowHistory", parameters);
                var header = await grid.ReadFirstOrDefaultAsync<TokenWorkflowHistoryDto>();
                if (header == null)
                {
                    return ApiResponse<TokenWorkflowHistoryDto>.Fail("Token workflow journey not found.");
                }

                var steps = (await grid.ReadAsync<TokenWorkflowStepDto>()) ?? Enumerable.Empty<TokenWorkflowStepDto>();
                var subTokens = (await grid.ReadAsync<SubTokenDto>()) ?? Enumerable.Empty<SubTokenDto>();

                header.Steps = steps.ToList();
                header.SubTokens = subTokens.ToList();

                return ApiResponse<TokenWorkflowHistoryDto>.Ok(header);
            }
            catch (Exception ex)
            {
                return ApiResponse<TokenWorkflowHistoryDto>.Fail($"Failed to load workflow history: {ex.Message}");
            }
        }

        public async Task<ApiResponse<IEnumerable<ProcessStepDto>>> GetProcessStepsAsync(int? processId)
        {
            try
            {
                var parameters = new
                {
                    p_ProcessId = processId ?? 0
                };

                var steps = await _dbFactory.QueryAsync<ProcessStepDto>(
                    "PR_S_ProcessSteps",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                return ApiResponse<IEnumerable<ProcessStepDto>>.Ok(steps ?? Enumerable.Empty<ProcessStepDto>());
            }
            catch (Exception ex)
            {
                return ApiResponse<IEnumerable<ProcessStepDto>>.Ok(Enumerable.Empty<ProcessStepDto>(), $"Steps notice: {ex.Message}");
            }
        }

        public async Task<ApiResponse<IEnumerable<TokenTransactionModel>>> GetTokenQueueAsync(int organizationId, int locationId, int processId, int counterId)
        {
            try
            {
                var parameters = new
                {
                    p_OrganizationId = organizationId,
                    p_LocationId = locationId,
                    p_ProcessId = processId,
                    p_CounterId = counterId
                };

                using var grid = await _dbFactory.QueryMultipleAsync("PR_S_TokenQueue", parameters);
                var activeTokens = (await grid.ReadAsync<TokenTransactionModel>()) ?? Enumerable.Empty<TokenTransactionModel>();
                var waitingTokens = (await grid.ReadAsync<TokenTransactionModel>()) ?? Enumerable.Empty<TokenTransactionModel>();

                var allTokens = activeTokens.Concat(waitingTokens).Where(t => t != null).ToList();

                return ApiResponse<IEnumerable<TokenTransactionModel>>.Ok(allTokens);
            }
            catch (Exception ex)
            {
                return ApiResponse<IEnumerable<TokenTransactionModel>>.Ok(Enumerable.Empty<TokenTransactionModel>(), $"Note: Queue notice ({ex.Message})");
            }
        }
    }
}
