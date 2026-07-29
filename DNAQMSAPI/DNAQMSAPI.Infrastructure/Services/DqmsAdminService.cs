using System.Data;
using AntiGravity.Enterprise.Shared.Core.Enums;
using AntiGravity.Enterprise.Shared.Core.Models;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Infrastructure.Models;

namespace DNAQMSAPI.Infrastructure.Services
{
    public interface IDqmsAdminService
    {
        Task<ApiResponse<IEnumerable<AreaModel>>> GetAreasAsync(int? id, int? organizationId, int? locationId, e_ActiveSearchStatus isActive);
        Task<ApiResponse<object>> SaveAreaAsync(AreaModel model, int userId);
        Task<ApiResponse<IEnumerable<ProcessModel>>> GetProcessesAsync(int? id, int? organizationId, e_ActiveSearchStatus isActive);
        Task<ApiResponse<object>> SaveProcessAsync(ProcessModel model, int userId);
    }

    public class DqmsAdminService : IDqmsAdminService
    {
        private readonly DNAQMSAPI.Application.Interfaces.IDapperDBFactory _dbFactory;

        public DqmsAdminService(DNAQMSAPI.Application.Interfaces.IDapperDBFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<ApiResponse<IEnumerable<AreaModel>>> GetAreasAsync(int? id, int? organizationId, int? locationId, e_ActiveSearchStatus isActive)
        {
            try
            {
                var parameters = new
                {
                    p_Id = id ?? -1,
                    p_OrganizationId = organizationId ?? -1,
                    p_LocationId = locationId ?? -1,
                    p_IsActive = (int)isActive
                };

                var areas = await _dbFactory.QueryAsync<AreaModel>(
                    "PR_S_Area",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                return ApiResponse<IEnumerable<AreaModel>>.Ok(areas.Where(a => a != null).Select(a => a!).ToList());
            }
            catch (Exception ex)
            {
                // Return empty list safely on database or execution error
                return ApiResponse<IEnumerable<AreaModel>>.Ok(Enumerable.Empty<AreaModel>(), $"Note: Database query notice ({ex.Message})");
            }
        }

        public async Task<ApiResponse<object>> SaveAreaAsync(AreaModel model, int userId)
        {
            try
            {
                var parameters = new
                {
                    p_Id = model.Id,
                    p_AreaCode = model.AreaCode,
                    p_OrganizationId = model.OrganizationId,
                    p_LocationId = model.LocationId,
                    p_AreaName = model.AreaName,
                    p_Description = model.Description,
                    p_IsActive = model.IsActive ? 1 : 0,
                    p_UID = userId
                };

                var result = await _dbFactory.QuerySingleAsync<SPResult>(
                    "PR_IU_Area",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                if (result != null && result.ErrNo == 0)
                {
                    return ApiResponse<object>.Ok(new { areaId = result.ID }, "Area saved successfully");
                }

                return ApiResponse<object>.Fail(result?.ErrMsg ?? "Failed to save Area.");
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.Fail($"Database error: {ex.Message}");
            }
        }

        public async Task<ApiResponse<IEnumerable<ProcessModel>>> GetProcessesAsync(int? id, int? organizationId, e_ActiveSearchStatus isActive)
        {
            try
            {
                var parameters = new
                {
                    p_Id = id ?? -1,
                    p_OrganizationId = organizationId ?? -1,
                    p_IsActive = (int)isActive
                };

                var processes = await _dbFactory.QueryAsync<ProcessModel>(
                    "PR_S_Process",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                return ApiResponse<IEnumerable<ProcessModel>>.Ok(processes.Where(p => p != null).Select(p => p!).ToList());
            }
            catch (Exception ex)
            {
                return ApiResponse<IEnumerable<ProcessModel>>.Ok(Enumerable.Empty<ProcessModel>(), $"Note: Database query notice ({ex.Message})");
            }
        }

        public async Task<ApiResponse<object>> SaveProcessAsync(ProcessModel model, int userId)
        {
            try
            {
                var parameters = new
                {
                    p_Id = model.Id,
                    p_ProcessCode = model.ProcessCode,
                    p_OrganizationId = model.OrganizationId,
                    p_ProcessName = model.ProcessName,
                    p_Prefix = model.Prefix,
                    p_TargetTATMinutes = model.TargetTATMinutes,
                    p_AllowSubTokens = model.AllowSubTokens ? 1 : 0,
                    p_IsActive = model.IsActive ? 1 : 0,
                    p_UID = userId
                };

                var result = await _dbFactory.QuerySingleAsync<SPResult>(
                    "PR_IU_Process",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                if (result != null && result.ErrNo == 0)
                {
                    return ApiResponse<object>.Ok(new { processId = result.ID }, "Process saved successfully");
                }

                return ApiResponse<object>.Fail(result?.ErrMsg ?? "Failed to save Process.");
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.Fail($"Database error: {ex.Message}");
            }
        }
    }
}
