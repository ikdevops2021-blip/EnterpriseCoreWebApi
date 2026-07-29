using DNAQMSAPI.Application.Interfaces;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Security.Claims;
using System.Text.Encodings.Web;

namespace DNAQMSAPI.Security.Authentication;

public class ApiKeyAuthenticationHandler : AuthenticationHandler<ApiKeyAuthenticationOptions>
{
    private readonly IApiKeyAuthenticator _apiKeyAuthenticator;
    private readonly ILogger<ApiKeyAuthenticationHandler> _logger;

    public ApiKeyAuthenticationHandler(
        IOptionsMonitor<ApiKeyAuthenticationOptions> options,
        ILoggerFactory logger,
        UrlEncoder encoder,
        ISystemClock clock,
        IApiKeyAuthenticator apiKeyAuthenticator)
        : base(options, logger, encoder, clock)
    {
        _apiKeyAuthenticator = apiKeyAuthenticator;
        _logger = logger.CreateLogger<ApiKeyAuthenticationHandler>();
    }

    protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        string? apiKey = null;
        if (Request.Headers.TryGetValue(Options.HeaderName, out var extractedApiKey) ||
            Request.Headers.TryGetValue("x-api-key", out extractedApiKey) ||
            Request.Headers.TryGetValue("ApiKey", out extractedApiKey))
        {
            apiKey = extractedApiKey.FirstOrDefault();
            if (!string.IsNullOrWhiteSpace(apiKey))
            {
                apiKey = apiKey.Trim().Trim('"').Trim('\'');
                if (apiKey.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
                {
                    apiKey = apiKey.Substring("Bearer ".Length).Trim();
                }
            }
        }

        if (string.IsNullOrWhiteSpace(apiKey))
        {
            return AuthenticateResult.NoResult();
        }

        try
        {
            var keyEntity = await _apiKeyAuthenticator.ValidateApiKeyAsync(apiKey);

            if (keyEntity == null)
            {
                _logger.LogWarning("API Key not found for provided key.");
                return AuthenticateResult.Fail("Invalid or expired API Key.");
            }

            if (!keyEntity.IsActive)
            {
                _logger.LogWarning("API Key found but IsActive is false.");
                return AuthenticateResult.Fail("Invalid or expired API Key.");
            }

            if (keyEntity.ExpiresAt.HasValue && keyEntity.ExpiresAt.Value < DateTime.UtcNow)
            {
                _logger.LogWarning("API Key expired.");
                return AuthenticateResult.Fail("Invalid or expired API Key.");
            }

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, keyEntity.UserId.ToString()),
                new Claim(ClaimTypes.Name, keyEntity.Name),
                new Claim(ClaimTypes.AuthenticationMethod, "ApiKey")
            };

            var identity = new ClaimsIdentity(claims, ApiKeyAuthenticationOptions.DefaultScheme);
            var principal = new ClaimsPrincipal(identity);
            var ticket = new AuthenticationTicket(principal, ApiKeyAuthenticationOptions.DefaultScheme);

            return AuthenticateResult.Success(ticket);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error validating API key.");
            return AuthenticateResult.Fail("An error occurred processing your authentication.");
        }
    }
}
