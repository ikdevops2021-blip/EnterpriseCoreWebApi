using Microsoft.AspNetCore.Authentication;

namespace DNAQMSAPI.Security.Authentication;

public class ApiKeyAuthenticationOptions : AuthenticationSchemeOptions
{
    public const string DefaultScheme = "ApiKey";
    public string HeaderName { get; set; } = "x-api-key";
}
