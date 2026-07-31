using System.Data;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Entities;
using DNAQMSAPI.Infrastructure.Models;
using Microsoft.Extensions.Caching.Memory;

namespace DNAQMSAPI.Infrastructure.Services;

public class ConfigurationService : IConfigurationService
{
    private readonly IDapperDBFactory _dbFactory;
    private readonly IMemoryCache _cache;
    private static readonly TimeSpan CacheDuration = TimeSpan.FromMinutes(10);

    private const string CategoriesCacheKey = "config_categories_all";
    private const string SystemConfigsCacheKey = "system_config_keys_all";

    public ConfigurationService(IDapperDBFactory dbFactory, IMemoryCache cache)
    {
        _dbFactory = dbFactory;
        _cache = cache;
    }

    public async Task<IEnumerable<ConfigCategory>> GetConfigCategoriesAsync()
    {
        if (_cache.TryGetValue(CategoriesCacheKey, out IEnumerable<ConfigCategory>? cached) && cached != null)
        {
            return cached;
        }

        var categories = await _dbFactory.QueryAsync<ConfigCategory>(
            "PR_S_ConfigCategory",
            new { p_CategoryID = -1, p_CategoryCode = "", p_CategoryName = "", p_Active = -1 },
            commandType: CommandType.StoredProcedure);

        var result = categories.Where(c => c != null).Select(c => c!).ToList();
        _cache.Set(CategoriesCacheKey, result, CacheDuration);
        return result;
    }

    public async Task<ConfigCategory?> GetConfigCategoryByIdAsync(int categoryId)
    {
        string cacheKey = $"config_category_{categoryId}";
        if (_cache.TryGetValue(cacheKey, out ConfigCategory? cached))
        {
            return cached;
        }

        var categories = await _dbFactory.QueryAsync<ConfigCategory>(
            "PR_S_ConfigCategory",
            new { p_CategoryID = categoryId, p_CategoryCode = "", p_CategoryName = "", p_Active = -1 },
            commandType: CommandType.StoredProcedure);

        var category = categories.FirstOrDefault();
        if (category != null)
        {
            _cache.Set(cacheKey, category, CacheDuration);
        }
        return category;
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
            InvalidateCategoryCache();
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

        bool success = result != null && result.ErrNo == 0 && result.RowsCount > 0;
        if (success)
        {
            InvalidateCategoryCache(category.CategoryID);
        }
        return success;
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
        string cacheKey = $"config_parameters_cat_{categoryId}";
        if (_cache.TryGetValue(cacheKey, out IEnumerable<ConfigParameter>? cached) && cached != null)
        {
            return cached;
        }

        var parameters = await _dbFactory.QueryAsync<ConfigParameter>(
            "PR_S_ConfigParameters",
            new { p_ParameterID = -1, p_CategoryID = categoryId, p_CategoryCode = "", p_ParameterCode = "", p_ParameterName = "", p_IsActive = -1 },
            commandType: CommandType.StoredProcedure);

        var result = parameters.Where(p => p != null).Select(p => p!).ToList();
        _cache.Set(cacheKey, result, CacheDuration);
        return result;
    }

    public async Task<IEnumerable<ConfigParameter>> GetConfigParametersByCategoryCodeAsync(string categoryCode)
    {
        string cacheKey = $"config_parameters_code_{categoryCode}";
        if (_cache.TryGetValue(cacheKey, out IEnumerable<ConfigParameter>? cached) && cached != null)
        {
            return cached;
        }

        var parameters = await _dbFactory.QueryAsync<ConfigParameter>(
            "PR_S_ConfigParameters",
            new { p_ParameterID = -1, p_CategoryID = -1, p_CategoryCode = categoryCode, p_ParameterCode = "", p_ParameterName = "", p_IsActive = -1 },
            commandType: CommandType.StoredProcedure);

        var result = parameters.Where(p => p != null).Select(p => p!).ToList();
        _cache.Set(cacheKey, result, CacheDuration);
        return result;
    }

    public async Task<ConfigParameter?> GetConfigParameterByIdAsync(int parameterId)
    {
        string cacheKey = $"config_parameter_{parameterId}";
        if (_cache.TryGetValue(cacheKey, out ConfigParameter? cached))
        {
            return cached;
        }

        var parameters = await _dbFactory.QueryAsync<ConfigParameter>(
            "PR_S_ConfigParameters",
            new { p_ParameterID = parameterId, p_CategoryID = -1, p_CategoryCode = "", p_ParameterCode = "", p_ParameterName = "", p_IsActive = -1 },
            commandType: CommandType.StoredProcedure);

        var parameter = parameters.FirstOrDefault();
        if (parameter != null)
        {
            _cache.Set(cacheKey, parameter, CacheDuration);
        }
        return parameter;
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
            InvalidateParameterCache(parameter.CategoryID);
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

        bool success = result != null && result.ErrNo == 0 && result.RowsCount > 0;
        if (success)
        {
            InvalidateParameterCache(parameter.CategoryID, parameter.ParameterID);
        }
        return success;
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
        if (_cache.TryGetValue(SystemConfigsCacheKey, out IEnumerable<SystemConfigurationKey>? cached) && cached != null)
        {
            return cached;
        }

        var configurations = await _dbFactory.QueryAsync<SystemConfigurationKey>(
            "sp_GetSystemConfigurations",
            commandType: CommandType.StoredProcedure);

        var result = configurations.Where(c => c != null).Select(c => c!).ToList();
        _cache.Set(SystemConfigsCacheKey, result, CacheDuration);
        return result;
    }

    public async Task<SystemConfigurationKey?> GetSystemConfigurationByKeyAsync(string key)
    {
        string cacheKey = $"system_config_key_{key}";
        if (_cache.TryGetValue(cacheKey, out SystemConfigurationKey? cached))
        {
            return cached;
        }

        var configurations = await _dbFactory.QueryAsync<SystemConfigurationKey>(
            "sp_GetSystemConfigurationByKey",
            new { Key = key },
            commandType: CommandType.StoredProcedure);

        var config = configurations.FirstOrDefault(c => c != null);
        if (config != null)
        {
            _cache.Set(cacheKey, config, CacheDuration);
        }
        return config;
    }

    public async Task<bool> UpdateSystemConfigurationAsync(string key, string value, int modifiedBy)
    {
        var rowsAffected = await _dbFactory.ExecuteAsync(
            "sp_UpdateSystemConfiguration",
            new { Key = key, Value = value, ModUID = modifiedBy },
            commandType: CommandType.StoredProcedure);

        bool success = rowsAffected > 0;
        if (success)
        {
            _cache.Remove(SystemConfigsCacheKey);
            _cache.Remove($"system_config_key_{key}");
        }
        return success;
    }

    private void InvalidateCategoryCache(int? categoryId = null)
    {
        _cache.Remove(CategoriesCacheKey);
        if (categoryId.HasValue)
        {
            _cache.Remove($"config_category_{categoryId.Value}");
            _cache.Remove($"config_parameters_cat_{categoryId.Value}");
        }
    }

    private void InvalidateParameterCache(int categoryId, int? parameterId = null)
    {
        _cache.Remove($"config_parameters_cat_{categoryId}");
        if (parameterId.HasValue)
        {
            _cache.Remove($"config_parameter_{parameterId.Value}");
        }
    }
}
