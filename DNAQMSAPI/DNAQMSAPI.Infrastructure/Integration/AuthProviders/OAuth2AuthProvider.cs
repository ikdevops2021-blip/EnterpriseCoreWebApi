using System.Net.Http.Headers;
using DNAQMSAPI.Domain.Integration;

namespace DNAQMSAPI.Infrastructure.Integration.AuthProviders;

public class OAuth2AuthProvider : IAuthProvider
{
    private readonly TokenManager _tokenManager;

    public OAuth2AuthProvider(TokenManager tokenManager)
    {
        _tokenManager = tokenManager;
    }

    public async Task ApplyAuthenticationAsync(HttpRequestMessage request, ThirdPartyApiConfig config)
    {
        // Get valid token, refreshing if necessary
        var validToken = await _tokenManager.GetValidAccessTokenAsync(config);

        if (!string.IsNullOrEmpty(validToken))
        {
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", validToken);
        }
    }
}
