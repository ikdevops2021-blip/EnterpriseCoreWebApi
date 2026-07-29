using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Integration;
using DNAQMSAPI.Application.Integration.Interfaces;

namespace DNAQMSAPI.Infrastructure.Integration;

public class ConfigurationResolver : IConfigurationResolver
{
    private readonly IDapperDBFactory _dbFactory;

    public ConfigurationResolver(IDapperDBFactory dbFactory)
    {
        _dbFactory = dbFactory;
    }

    public async Task<ThirdPartyApiConfig?> ResolveConfigAsync(string configName, int? tenantId)
    {
        return await _dbFactory.QuerySingleAsync<ThirdPartyApiConfig>(
            "pr_GetThirdPartyApiConfig", 
            new { Name = configName, TenantId = tenantId },
            commandType: System.Data.CommandType.StoredProcedure);
    }
}
