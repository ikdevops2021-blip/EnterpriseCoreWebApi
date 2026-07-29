using DNAQMSAPI.Domain.Integration;

namespace DNAQMSAPI.Infrastructure.Integration.AuthProviders;

public interface IAuthProvider
{
    Task ApplyAuthenticationAsync(HttpRequestMessage request, ThirdPartyApiConfig config);
}
