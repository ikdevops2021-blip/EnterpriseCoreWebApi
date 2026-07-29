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
        Task<ApiResponse<IEnumerable<TokenTransactionModel>>> GetTokenQueueAsync(int organizationId, int locationId, int processId, int counterId);
    }

    public class DqmsStaffService : IDqmsStaffService
    {
        private readonly DNAQMSAPI.Application.Interfaces.IDapperDBFactory _dbFactory;

        public DqmsStaffService(DNAQMSAPI.Application.Interfaces.IDapperDBFactory dbFactory)
        {
            _dbFactory = dbFactory;
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
                    return ApiResponse<object>.Ok(new { tokenId = result.ID }, "Token status updated successfully");
                }

                return ApiResponse<object>.Fail(result?.ErrMsg ?? "Failed to update token status.");
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.Fail($"Database notice: {ex.Message}");
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

                var tokens = await _dbFactory.QueryAsync<TokenTransactionModel>(
                    "PR_S_TokenQueue",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                return ApiResponse<IEnumerable<TokenTransactionModel>>.Ok(tokens.Where(t => t != null).Select(t => t!).ToList());
            }
            catch (Exception ex)
            {
                return ApiResponse<IEnumerable<TokenTransactionModel>>.Ok(Enumerable.Empty<TokenTransactionModel>(), $"Note: Queue notice ({ex.Message})");
            }
        }
    }
}
