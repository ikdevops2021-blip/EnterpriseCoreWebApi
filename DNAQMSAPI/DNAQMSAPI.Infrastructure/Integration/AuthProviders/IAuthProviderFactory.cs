using DNAQMSAPI.Domain.Integration;

namespace DNAQMSAPI.Infrastructure.Integration.AuthProviders;

public interface IAuthProviderFactory
{
    IAuthProvider CreateProvider(AuthType authType);
}
