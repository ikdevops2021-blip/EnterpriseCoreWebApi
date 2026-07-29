using System.Net.Http.Headers;
using DNAQMSAPI.Domain.Integration;

namespace DNAQMSAPI.Infrastructure.Integration.AuthProviders;

public class JwtAuthProvider : IAuthProvider
{
    public Task ApplyAuthenticationAsync(HttpRequestMessage request, ThirdPartyApiConfig config)
    {
        if (!string.IsNullOrEmpty(config.AccessToken))
        {
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", config.AccessToken);
        }
        return Task.CompletedTask;
    }
}
