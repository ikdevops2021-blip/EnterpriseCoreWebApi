using DNAQMSAPI.Domain.Entities;

namespace DNAQMSAPI.Application.Interfaces;

public interface IConfigurationService
{
    Task<IEnumerable<ConfigCategory>> GetConfigCategoriesAsync();
    Task<ConfigCategory?> GetConfigCategoryByIdAsync(int categoryId);
    Task<ConfigCategory> CreateConfigCategoryAsync(ConfigCategory category);
    Task<bool> UpdateConfigCategoryAsync(ConfigCategory category);
    Task<bool> DeleteConfigCategoryAsync(int categoryId, int deletedBy);

    Task<IEnumerable<ConfigParameter>> GetConfigParametersByCategoryAsync(int categoryId);
    Task<IEnumerable<ConfigParameter>> GetConfigParametersByCategoryCodeAsync(string categoryCode);
    Task<ConfigParameter?> GetConfigParameterByIdAsync(int parameterId);
    Task<ConfigParameter> CreateConfigParameterAsync(ConfigParameter parameter);
    Task<bool> UpdateConfigParameterAsync(ConfigParameter parameter);
    Task<bool> DeleteConfigParameterAsync(int parameterId, int deletedBy);

    Task<IEnumerable<SystemConfigurationKey>> GetSystemConfigurationsAsync();
    Task<SystemConfigurationKey?> GetSystemConfigurationByKeyAsync(string key);
    Task<bool> UpdateSystemConfigurationAsync(string key, string value, int modifiedBy);
}
