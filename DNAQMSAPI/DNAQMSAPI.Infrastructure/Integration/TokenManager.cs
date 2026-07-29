using System.Text.Json;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Integration;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Infrastructure.Integration;

public class TokenManager
{
    private readonly HttpClient _httpClient;
    private readonly IDapperDBFactory _dbFactory;
    private readonly ILogger<TokenManager> _logger;

    public TokenManager(HttpClient httpClient, IDapperDBFactory dbFactory, ILogger<TokenManager> logger)
    {
        _httpClient = httpClient;
        _dbFactory = dbFactory;
        _logger = logger;
    }

    public async Task<string?> GetValidAccessTokenAsync(ThirdPartyApiConfig config)
    {
        if (config.AuthType != AuthType.OAuth2)
            return null;

        // Check if token is still valid (with a 60 second buffer)
        if (!string.IsNullOrEmpty(config.AccessToken) && config.TokenExpiry.HasValue && config.TokenExpiry.Value > DateTime.UtcNow.AddSeconds(60))
        {
            return config.AccessToken;
        }

        _logger.LogInformation("OAuth token for {ConfigName} is expired or missing. Fetching a new token.", config.Name);

        // Fetch a new token
        if (string.IsNullOrEmpty(config.TokenEndpoint))
            throw new InvalidOperationException($"TokenEndpoint is missing for configuration '{config.Name}'");

        var tokenRequest = new HttpRequestMessage(HttpMethod.Post, config.TokenEndpoint);
        
        var requestContent = new List<KeyValuePair<string, string>>
        {
            new KeyValuePair<string, string>("grant_type", "client_credentials"),
            new KeyValuePair<string, string>("client_id", config.ClientId ?? string.Empty),
            new KeyValuePair<string, string>("client_secret", config.ClientSecret ?? string.Empty)
        };

        if (!string.IsNullOrEmpty(config.Scope))
        {
            requestContent.Add(new KeyValuePair<string, string>("scope", config.Scope));
        }

        tokenRequest.Content = new FormUrlEncodedContent(requestContent);

        try
        {
            var response = await _httpClient.SendAsync(tokenRequest);
            response.EnsureSuccessStatusCode();

            var responseBody = await response.Content.ReadAsStringAsync();
            using var doc = JsonDocument.Parse(responseBody);

            string? newAccessToken = null;
            if (doc.RootElement.TryGetProperty("access_token", out var accessTokenProp))
                newAccessToken = accessTokenProp.GetString();

            if (string.IsNullOrEmpty(newAccessToken))
                throw new InvalidOperationException("access_token not found in the response.");

            int expiresIn = 3600; // Default 1 hour
            if (doc.RootElement.TryGetProperty("expires_in", out var expiresInProp) && expiresInProp.ValueKind == JsonValueKind.Number)
                expiresIn = expiresInProp.GetInt32();

            var newExpiry = DateTime.UtcNow.AddSeconds(expiresIn);

            string? newRefreshToken = config.RefreshToken;
            if (doc.RootElement.TryGetProperty("refresh_token", out var refreshTokenProp))
                newRefreshToken = refreshTokenProp.GetString();

            // Persist the new tokens to the database
            await _dbFactory.ExecuteAsync("pr_UpdateOAuthTokens", new
            {
                ConfigId = config.Id,
                AccessToken = newAccessToken,
                RefreshToken = newRefreshToken,
                TokenExpiry = newExpiry
            }, commandType: System.Data.CommandType.StoredProcedure);

            // Update in memory for the current request
            config.AccessToken = newAccessToken;
            config.RefreshToken = newRefreshToken;
            config.TokenExpiry = newExpiry;

            return newAccessToken;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to refresh OAuth token for {ConfigName}", config.Name);
            throw;
        }
    }
}
