using DNAQMSAPI.Domain.Entities;

namespace DNAQMSAPI.Application.Interfaces;

public interface IApiKeyAuthenticator
{
    Task<ApiKey?> ValidateApiKeyAsync(string apiKeyRaw);
}
