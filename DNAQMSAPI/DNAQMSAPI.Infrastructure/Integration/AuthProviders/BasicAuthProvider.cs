using System.Net.Http.Headers;
using System.Text;
using DNAQMSAPI.Domain.Integration;

namespace DNAQMSAPI.Infrastructure.Integration.AuthProviders;

public class BasicAuthProvider : IAuthProvider
{
    public Task ApplyAuthenticationAsync(HttpRequestMessage request, ThirdPartyApiConfig config)
    {
        if (!string.IsNullOrEmpty(config.Username) && !string.IsNullOrEmpty(config.Password))
        {
            var authString = Convert.ToBase64String(Encoding.UTF8.GetBytes($"{config.Username}:{config.Password}"));
            request.Headers.Authorization = new AuthenticationHeaderValue("Basic", authString);
        }
        return Task.CompletedTask;
    }
}
