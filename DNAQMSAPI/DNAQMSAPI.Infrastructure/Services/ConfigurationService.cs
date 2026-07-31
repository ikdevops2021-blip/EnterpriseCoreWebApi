using System.Data;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Entities;
using DNAQMSAPI.Infrastructure.Models;

namespace DNAQMSAPI.Infrastructure.Services;

public class ConfigurationService : IConfigurationService
{
    private readonly IDapperDBFactory _dbFactory;

    public ConfigurationService(IDapperDBFactory dbFactory)
    {
        _dbFactory = dbFactory;
    }

    public async Task<IEnumerable<ConfigCategory>> GetConfigCategoriesAsync()
    {
        var categories = await _dbFactory.QueryAsync<ConfigCategory>(
            "PR_S_ConfigCategory",
            new { p_CategoryID = -1, p_CategoryCode = "", p_CategoryName = "", p_Active = -1 },
            commandType: CommandType.StoredProcedure);
        return categories.Where(c => c != null).Select(c => c!).ToList();
    }

    public async Task<ConfigCategory?> GetConfigCategoryByIdAsync(int categoryId)
    {
        var categories = await _dbFactory.QueryAsync<ConfigCategory>(
            "PR_S_ConfigCategory",
            new { p_CategoryID = categoryId, p_CategoryCode = "", p_CategoryName = "", p_Active = -1 },
            commandType: CommandType.StoredProcedure);
        return categories.FirstOrDefault();
    }

    public async Task<ConfigCategory> CreateConfigCategoryAsync(ConfigCategory category)
    {
        var parameters = new
        {
            p_CategoryID = 0,
            p_CategoryCode = category.CategoryCode,
            p_CategoryName = category.CategoryName,
            p_Description = category.Description,
            p_Priority = category.Priority,
            p_Active = category.Active,
            p_AllowModify = category.AllowModify,
            p_ParentCategoryID = category.ParentCategoryID,
            p_CategoryExternalID = category.CategoryExternalID,
            p_CategoryExternalName = category.CategoryExternalName,
            p_CategoryExternalCode = category.CategoryExternalCode,
            p_CategoryColor = category.CategoryColor,
            p_CategoryIcon = category.CategoryIcon,
            p_CategoryImage = category.CategoryImage,
            p_Attribute1 = category.Attribute1,
            p_Attribute2 = category.Attribute2,
            p_Attribute3 = category.Attribute3,
            p_UID = category.CreatedBy
        };

        var result = await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_ConfigCategory",
            parameters,
            commandType: CommandType.StoredProcedure);

        var createdId = Convert.ToInt32(result?.ID ?? 0);
        if (createdId > 0)
        {
            return (await GetConfigCategoryByIdAsync(createdId))!;
        }

        throw new InvalidOperationException(result?.ErrMsg ?? "Failed to create ConfigCategory.");
    }

    public async Task<bool> UpdateConfigCategoryAsync(ConfigCategory category)
    {
        var parameters = new
        {
            p_CategoryID = category.CategoryID,
            p_CategoryCode = category.CategoryCode,
            p_CategoryName = category.CategoryName,
            p_Description = category.Description,
            p_Priority = category.Priority,
            p_Active = category.Active,
            p_AllowModify = category.AllowModify,
            p_ParentCategoryID = category.ParentCategoryID,
            p_CategoryExternalID = category.CategoryExternalID,
            p_CategoryExternalName = category.CategoryExternalName,
            p_CategoryExternalCode = category.CategoryExternalCode,
            p_CategoryColor = category.CategoryColor,
            p_CategoryIcon = category.CategoryIcon,
            p_CategoryImage = category.CategoryImage,
            p_Attribute1 = category.Attribute1,
            p_Attribute2 = category.Attribute2,
            p_Attribute3 = category.Attribute3,
            p_UID = category.ModifiedBy
        };

        var result = await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_ConfigCategory",
            parameters,
            commandType: CommandType.StoredProcedure);

        return result != null && result.ErrNo == 0 && result.RowsCount > 0;
    }

    public async Task<bool> DeleteConfigCategoryAsync(int categoryId, int deletedBy)
    {
        var category = await GetConfigCategoryByIdAsync(categoryId);
        if (category == null) return false;

        category.Active = false;
        category.ModifiedBy = deletedBy;

        return await UpdateConfigCategoryAsync(category);
    }

    public async Task<IEnumerable<ConfigParameter>> GetConfigParametersByCategoryAsync(int categoryId)
    {
        var parameters = await _dbFactory.QueryAsync<ConfigParameter>(
            "PR_S_ConfigParameters",
            new { p_ParameterID = -1, p_CategoryID = categoryId, p_CategoryCode = "", p_ParameterCode = "", p_ParameterName = "", p_IsActive = -1 },
            commandType: CommandType.StoredProcedure);

        return parameters.Where(p => p != null).Select(p => p!).ToList();
    }

    public async Task<IEnumerable<ConfigParameter>> GetConfigParametersByCategoryCodeAsync(string categoryCode)
    {
        var parameters = await _dbFactory.QueryAsync<ConfigParameter>(
            "PR_S_ConfigParameters",
            new { p_ParameterID = -1, p_CategoryID = -1, p_CategoryCode = categoryCode, p_ParameterCode = "", p_ParameterName = "", p_IsActive = -1 },
            commandType: CommandType.StoredProcedure);

        return parameters.Where(p => p != null).Select(p => p!).ToList();
    }

    public async Task<ConfigParameter?> GetConfigParameterByIdAsync(int parameterId)
    {
        var parameters = await _dbFactory.QueryAsync<ConfigParameter>(
            "PR_S_ConfigParameters",
            new { p_ParameterID = parameterId, p_CategoryID = -1, p_CategoryCode = "", p_ParameterCode = "", p_ParameterName = "", p_IsActive = -1 },
            commandType: CommandType.StoredProcedure);

        return parameters.FirstOrDefault();
    }

    public async Task<ConfigParameter> CreateConfigParameterAsync(ConfigParameter parameter)
    {
        var parameters = new
        {
            p_ParameterID = 0,
            p_CategoryID = parameter.CategoryID,
            p_ParameterCode = parameter.ParameterCode,
            p_ParameterName = parameter.ParameterName,
            p_Priority = parameter.Priority,
            p_IsDefault = parameter.IsDefault,
            p_IsActive = parameter.IsActive,
            p_ParameterExternalID = parameter.ParameterExternalID,
            p_ParameterExternalName = parameter.ParameterExternalName,
            p_ParameterExternalCode = parameter.ParameterExternalCode,
            p_ParameterColor = parameter.ParameterColor,
            p_ParameterIcon = parameter.ParameterIcon,
            p_ParameterImage = parameter.ParameterImage,
            p_Attribute1 = parameter.Attribute1,
            p_Attribute2 = parameter.Attribute2,
            p_Attribute3 = parameter.Attribute3,
            p_UID = parameter.CreatedBy
        };

        var result = await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_ConfigParameters",
            parameters,
            commandType: CommandType.StoredProcedure);

        var createdId = Convert.ToInt32(result?.ID ?? 0);
        if (createdId > 0)
        {
            return (await GetConfigParameterByIdAsync(createdId))!;
        }

        throw new InvalidOperationException(result?.ErrMsg ?? "Failed to create ConfigParameter.");
    }

    public async Task<bool> UpdateConfigParameterAsync(ConfigParameter parameter)
    {
        var parameters = new
        {
            p_ParameterID = parameter.ParameterID,
            p_CategoryID = parameter.CategoryID,
            p_ParameterCode = parameter.ParameterCode,
            p_ParameterName = parameter.ParameterName,
            p_Priority = parameter.Priority,
            p_IsDefault = parameter.IsDefault,
            p_IsActive = parameter.IsActive,
            p_ParameterExternalID = parameter.ParameterExternalID,
            p_ParameterExternalName = parameter.ParameterExternalName,
            p_ParameterExternalCode = parameter.ParameterExternalCode,
            p_ParameterColor = parameter.ParameterColor,
            p_ParameterIcon = parameter.ParameterIcon,
            p_ParameterImage = parameter.ParameterImage,
            p_Attribute1 = parameter.Attribute1,
            p_Attribute2 = parameter.Attribute2,
            p_Attribute3 = parameter.Attribute3,
            p_UID = parameter.ModifiedBy
        };

        var result = await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_ConfigParameters",
            parameters,
            commandType: CommandType.StoredProcedure);

        return result != null && result.ErrNo == 0 && result.RowsCount > 0;
    }

    public async Task<bool> DeleteConfigParameterAsync(int parameterId, int deletedBy)
    {
        var parameter = await GetConfigParameterByIdAsync(parameterId);
        if (parameter == null) return false;

        parameter.IsActive = false;
        parameter.ModifiedBy = deletedBy;

        return await UpdateConfigParameterAsync(parameter);
    }

    public async Task<IEnumerable<SystemConfigurationKey>> GetSystemConfigurationsAsync()
    {
        var configurations = await _dbFactory.QueryAsync<SystemConfigurationKey>(
            "sp_GetSystemConfigurations",
            commandType: CommandType.StoredProcedure);

        return configurations.Where(c => c != null).Select(c => c!).ToList();
    }

    public async Task<SystemConfigurationKey?> GetSystemConfigurationByKeyAsync(string key)
    {
        var configurations = await _dbFactory.QueryAsync<SystemConfigurationKey>(
            "sp_GetSystemConfigurationByKey",
            new { Key = key },
            commandType: CommandType.StoredProcedure);

        return configurations.FirstOrDefault(c => c != null);
    }

    public async Task<bool> UpdateSystemConfigurationAsync(string key, string value, int modifiedBy)
    {
        var rowsAffected = await _dbFactory.ExecuteAsync(
            "sp_UpdateSystemConfiguration",
            new { Key = key, Value = value, ModUID = modifiedBy },
            commandType: CommandType.StoredProcedure);

        return rowsAffected > 0;
    }
}
