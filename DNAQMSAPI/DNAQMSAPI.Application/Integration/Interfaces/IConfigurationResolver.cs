using DNAQMSAPI.Domain.Integration;

namespace DNAQMSAPI.Application.Integration.Interfaces;

public interface IConfigurationResolver
{
    Task<ThirdPartyApiConfig?> ResolveConfigAsync(string configName, int? tenantId);
}
