using DNAQMSAPI.Domain.Integration;

namespace DNAQMSAPI.Infrastructure.Integration.AuthProviders;

public class ApiKeyAuthProvider : IAuthProvider
{
    public Task ApplyAuthenticationAsync(HttpRequestMessage request, ThirdPartyApiConfig config)
    {
        if (!string.IsNullOrEmpty(config.ApiKey))
        {
            // Assuming API key goes in the header, could be customized per provider requirements
            request.Headers.Add("x-api-key", config.ApiKey);
        }
        return Task.CompletedTask;
    }
}
