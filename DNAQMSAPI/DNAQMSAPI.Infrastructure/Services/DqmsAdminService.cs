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
        Task<ApiResponse<IEnumerable<CounterModel>>> GetCountersAsync(int? id, int? organizationId, int? locationId, int? areaId, e_ActiveSearchStatus isActive);
        Task<ApiResponse<object>> SaveCounterAsync(CounterModel model, int userId);
        Task<ApiResponse<IEnumerable<DisplayTemplateModel>>> GetDisplayTemplatesAsync(int? id, int? organizationId, e_ActiveSearchStatus isActive);
        Task<ApiResponse<object>> SaveDisplayTemplateAsync(DisplayTemplateModel model, int userId);
        Task<ApiResponse<IEnumerable<ConfigCategoryDto>>> GetConfigCategoriesAsync(int? id, e_ActiveSearchStatus isActive);
        Task<ApiResponse<IEnumerable<ConfigParameterDto>>> GetConfigParametersAsync(int? categoryId, int? id, e_ActiveSearchStatus isActive);
        Task<ApiResponse<object>> SaveConfigCategoryAsync(ConfigCategoryDto model, int userId);
        Task<ApiResponse<object>> SaveConfigParameterAsync(ConfigParameterDto model, int userId);
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

        public async Task<ApiResponse<IEnumerable<CounterModel>>> GetCountersAsync(int? id, int? organizationId, int? locationId, int? areaId, e_ActiveSearchStatus isActive)
        {
            try
            {
                var parameters = new
                {
                    p_Id = id ?? -1,
                    p_OrganizationId = organizationId ?? -1,
                    p_LocationId = locationId ?? -1,
                    p_AreaId = areaId ?? -1,
                    p_IsActive = (int)isActive
                };

                var counters = await _dbFactory.QueryAsync<CounterModel>(
                    "PR_S_Counter",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                return ApiResponse<IEnumerable<CounterModel>>.Ok(counters.Where(c => c != null).Select(c => c!).ToList());
            }
            catch (Exception ex)
            {
                return ApiResponse<IEnumerable<CounterModel>>.Ok(Enumerable.Empty<CounterModel>(), $"Note: Database query notice ({ex.Message})");
            }
        }

        public async Task<ApiResponse<object>> SaveCounterAsync(CounterModel model, int userId)
        {
            try
            {
                var parameters = new
                {
                    p_Id = model.Id,
                    p_CounterCode = model.CounterCode,
                    p_OrganizationId = model.OrganizationId,
                    p_LocationId = model.LocationId,
                    p_AreaId = model.AreaId,
                    p_CounterNumber = model.CounterNumber,
                    p_CounterName = model.CounterName,
                    p_CurrentStatus = model.CurrentStatus,
                    p_IsActive = model.IsActive ? 1 : 0,
                    p_UID = userId
                };

                var result = await _dbFactory.QuerySingleAsync<SPResult>(
                    "PR_IU_Counter",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                if (result != null && result.ErrNo == 0)
                {
                    return ApiResponse<object>.Ok(new { counterId = result.ID }, "Counter saved successfully");
                }

                return ApiResponse<object>.Fail(result?.ErrMsg ?? "Failed to save Counter.");
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.Fail($"Database error: {ex.Message}");
            }
        }

        public async Task<ApiResponse<IEnumerable<DisplayTemplateModel>>> GetDisplayTemplatesAsync(int? id, int? organizationId, e_ActiveSearchStatus isActive)
        {
            try
            {
                var parameters = new
                {
                    p_Id = id ?? -1,
                    p_OrganizationId = organizationId ?? -1,
                    p_IsActive = (int)isActive
                };

                var templates = await _dbFactory.QueryAsync<DisplayTemplateModel>(
                    "PR_S_DisplayTemplate",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                return ApiResponse<IEnumerable<DisplayTemplateModel>>.Ok(templates.Where(t => t != null).Select(t => t!).ToList());
            }
            catch (Exception ex)
            {
                return ApiResponse<IEnumerable<DisplayTemplateModel>>.Ok(Enumerable.Empty<DisplayTemplateModel>(), $"Note: Database query notice ({ex.Message})");
            }
        }

        public async Task<ApiResponse<object>> SaveDisplayTemplateAsync(DisplayTemplateModel model, int userId)
        {
            try
            {
                var parameters = new
                {
                    p_Id = model.Id,
                    p_OrganizationId = model.OrganizationId,
                    p_TemplateName = model.TemplateName,
                    p_TemplateType = model.TemplateType,
                    p_LayoutConfigJson = model.LayoutConfigJson,
                    p_IsDefault = model.IsDefault ? 1 : 0,
                    p_IsActive = model.IsActive ? 1 : 0,
                    p_UID = userId
                };

                var result = await _dbFactory.QuerySingleAsync<SPResult>(
                    "PR_IU_DisplayTemplate",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                if (result != null && result.ErrNo == 0)
                {
                    return ApiResponse<object>.Ok(new { templateId = result.ID }, "Display Template saved successfully");
                }

                return ApiResponse<object>.Fail(result?.ErrMsg ?? "Failed to save Display Template.");
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.Fail($"Database error: {ex.Message}");
            }
        }

        public async Task<ApiResponse<IEnumerable<ConfigCategoryDto>>> GetConfigCategoriesAsync(int? id, e_ActiveSearchStatus isActive)
        {
            try
            {
                var parameters = new
                {
                    p_Id = id ?? -1,
                    p_IsActive = (int)isActive
                };

                var categories = await _dbFactory.QueryAsync<ConfigCategoryDto>(
                    "PR_S_ConfigCategory",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                var list = categories.Where(c => c != null).Select(c => c!).ToList();
                return ApiResponse<IEnumerable<ConfigCategoryDto>>.Ok(list);
            }
            catch (Exception ex)
            {
                return ApiResponse<IEnumerable<ConfigCategoryDto>>.Ok(Enumerable.Empty<ConfigCategoryDto>(), $"Note: Database query notice ({ex.Message})");
            }
        }

        public async Task<ApiResponse<IEnumerable<ConfigParameterDto>>> GetConfigParametersAsync(int? categoryId, int? id, e_ActiveSearchStatus isActive)
        {
            try
            {
                var parameters = new
                {
                    p_CategoryId = categoryId ?? -1,
                    p_Id = id ?? -1,
                    p_IsActive = (int)isActive
                };

                var paramsList = await _dbFactory.QueryAsync<ConfigParameterDto>(
                    "PR_S_ConfigParameter",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                var list = paramsList.Where(p => p != null).Select(p => p!).ToList();
                return ApiResponse<IEnumerable<ConfigParameterDto>>.Ok(list);
            }
            catch (Exception ex)
            {
                return ApiResponse<IEnumerable<ConfigParameterDto>>.Ok(Enumerable.Empty<ConfigParameterDto>(), $"Note: Database query notice ({ex.Message})");
            }
        }

        public async Task<ApiResponse<object>> SaveConfigCategoryAsync(ConfigCategoryDto model, int userId)
        {
            try
            {
                var parameters = new
                {
                    p_CategoryId = model.CategoryId,
                    p_CategoryCode = model.CategoryCode,
                    p_CategoryName = model.CategoryName,
                    p_Description = model.Description,
                    p_Priority = model.Priority,
                    p_Active = model.Active ? 1 : 0,
                    p_AllowModify = model.AllowModify ? 1 : 0,
                    p_CategoryExternalId = model.CategoryExternalId,
                    p_CategoryExternalCode = model.CategoryExternalCode,
                    p_CategoryColor = model.CategoryColor,
                    p_CategoryIcon = model.CategoryIcon,
                    p_CategoryImage = model.CategoryImage,
                    p_UID = userId
                };

                var result = await _dbFactory.QuerySingleAsync<SPResult>(
                    "PR_IU_ConfigCategory",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                if (result != null && result.ErrNo == 0)
                {
                    return ApiResponse<object>.Ok(new { categoryId = result.ID }, "ConfigCategory saved successfully");
                }

                return ApiResponse<object>.Fail(result?.ErrMsg ?? "Failed to save ConfigCategory.");
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.Fail($"Database error: {ex.Message}");
            }
        }

        public async Task<ApiResponse<object>> SaveConfigParameterAsync(ConfigParameterDto model, int userId)
        {
            try
            {
                var parameters = new
                {
                    p_ParameterId = model.ParameterId,
                    p_CategoryId = model.CategoryId,
                    p_ParamCode = model.ParamCode,
                    p_ParamName = model.ParamName,
                    p_IsDefault = model.IsDefault ? 1 : 0,
                    p_Priority = model.Priority,
                    p_IsActive = model.IsActive ? 1 : 0,
                    p_Description = model.Description,
                    p_ParameterExternalId = model.ParameterExternalId,
                    p_ParameterExternalCode = model.ParameterExternalCode,
                    p_ParameterColor = model.ParameterColor,
                    p_ParameterIcon = model.ParameterIcon,
                    p_ParameterImage = model.ParameterImage,
                    p_UID = userId
                };

                var result = await _dbFactory.QuerySingleAsync<SPResult>(
                    "PR_IU_ConfigParameter",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                if (result != null && result.ErrNo == 0)
                {
                    return ApiResponse<object>.Ok(new { parameterId = result.ID }, "ConfigParameter saved successfully");
                }

                return ApiResponse<object>.Fail(result?.ErrMsg ?? "Failed to save ConfigParameter.");
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.Fail($"Database error: {ex.Message}");
            }
        }
    }
}
