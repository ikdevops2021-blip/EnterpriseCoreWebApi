using DNAQMSAPI.Domain.Integration;
using DNAQMSAPI.Infrastructure.Integration.AuthProviders;
using Microsoft.Extensions.DependencyInjection;

namespace DNAQMSAPI.Infrastructure.Integration;

public class AuthProviderFactory : IAuthProviderFactory
{
    private readonly IServiceProvider _serviceProvider;

    public AuthProviderFactory(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public IAuthProvider CreateProvider(AuthType authType)
    {
        return authType switch
        {
            AuthType.ApiKey => _serviceProvider.GetRequiredService<ApiKeyAuthProvider>(),
            AuthType.Basic => _serviceProvider.GetRequiredService<BasicAuthProvider>(),
            AuthType.JwtBearer => _serviceProvider.GetRequiredService<JwtAuthProvider>(),
            AuthType.OAuth2 => _serviceProvider.GetRequiredService<OAuth2AuthProvider>(),
            _ => throw new NotSupportedException($"Auth type {authType} is not supported.")
        };
    }
}
