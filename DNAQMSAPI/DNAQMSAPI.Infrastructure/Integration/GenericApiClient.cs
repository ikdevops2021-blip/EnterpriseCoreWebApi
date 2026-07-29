using System.Diagnostics;
using System.Text;
using System.Text.Json;
using DNAQMSAPI.Application.Integration.DTOs;
using DNAQMSAPI.Application.Integration.Interfaces;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Integration;
using DNAQMSAPI.Infrastructure.Integration.AuthProviders;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Infrastructure.Integration;

public class GenericApiClient : IGenericApiClient
{
    private readonly HttpClient _httpClient;
    private readonly IConfigurationResolver _configResolver;
    private readonly IAuthProviderFactory _authProviderFactory;
    private readonly IDapperDBFactory _dbFactory;
    private readonly ILogger<GenericApiClient> _logger;

    public GenericApiClient(
        HttpClient httpClient,
        IConfigurationResolver configResolver,
        IAuthProviderFactory authProviderFactory,
        IDapperDBFactory dbFactory,
        ILogger<GenericApiClient> logger)
    {
        _httpClient = httpClient;
        _configResolver = configResolver;
        _authProviderFactory = authProviderFactory;
        _dbFactory = dbFactory;
        _logger = logger;
    }

    public async Task<T?> SendAsync<T>(ApiRequest request)
    {
        var stopwatch = Stopwatch.StartNew();
        var config = await _configResolver.ResolveConfigAsync(request.ConfigName, request.TenantId);

        if (config == null)
            throw new InvalidOperationException($"No active configuration found for '{request.ConfigName}'");

        // Process Route Parameters
        var relativePath = request.Endpoint;
        foreach (var param in request.RouteParameters)
        {
            relativePath = relativePath.Replace($"{{{param.Key}}}", Uri.EscapeDataString(param.Value));
        }

        var baseUri = new Uri(config.BaseUrl.EndsWith("/") ? config.BaseUrl : config.BaseUrl + "/");
        var requestUri = new Uri(baseUri, relativePath.TrimStart('/'));
        var httpMethod = new HttpMethod(request.Method);
        
        string? requestBodyString = null;
        if (request.Body != null)
        {
            requestBodyString = JsonSerializer.Serialize(request.Body);
        }

        HttpResponseMessage? response = null;
        string? responseBodyString = null;
        string? errorMessage = null;

        int maxRetries = Math.Max(1, request.MaxRetries);
        int currentAttempt = 0;

        _httpClient.Timeout = TimeSpan.FromSeconds(request.TimeoutSeconds);

        while (currentAttempt < maxRetries)
        {
            currentAttempt++;
            try
            {
                using var httpRequest = new HttpRequestMessage(httpMethod, requestUri);

                // Apply Custom Headers
                foreach (var header in request.Headers)
                {
                    httpRequest.Headers.Add(header.Key, header.Value);
                }

                if (requestBodyString != null)
                {
                    httpRequest.Content = new StringContent(requestBodyString, Encoding.UTF8, "application/json");
                }

                // Apply Auth Configuration
                var authProvider = _authProviderFactory.CreateProvider(config.AuthType);
                await authProvider.ApplyAuthenticationAsync(httpRequest, config);

                response = await _httpClient.SendAsync(httpRequest);
                responseBodyString = await response.Content.ReadAsStringAsync();

                // If transient server error (5xx) or rate limited (429), trigger retry if attempts remain
                if (((int)response.StatusCode >= 500 || (int)response.StatusCode == 429) && currentAttempt < maxRetries)
                {
                    var delayMs = (int)Math.Pow(2, currentAttempt) * 500; // Exponential backoff (1s, 2s, 4s...)
                    _logger.LogWarning("API Call to {Url} returned HTTP {StatusCode}. Retrying attempt {Attempt}/{MaxRetries} after {DelayMs}ms...", 
                        requestUri, (int)response.StatusCode, currentAttempt + 1, maxRetries, delayMs);
                    await Task.Delay(delayMs);
                    continue;
                }

                response.EnsureSuccessStatusCode();

                return JsonSerializer.Deserialize<T>(responseBodyString, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            }
            catch (HttpRequestException ex) when (currentAttempt < maxRetries)
            {
                var delayMs = (int)Math.Pow(2, currentAttempt) * 500;
                _logger.LogWarning(ex, "Network request to {Url} failed on attempt {Attempt}/{MaxRetries}. Retrying after {DelayMs}ms...", 
                    requestUri, currentAttempt, maxRetries, delayMs);
                errorMessage = ex.Message;
                await Task.Delay(delayMs);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "API Call to {Url} failed permanently on attempt {Attempt}.", requestUri, currentAttempt);
                errorMessage = ex.Message;
                throw;
            }
            finally
            {
                if (currentAttempt == maxRetries || (response != null && response.IsSuccessStatusCode))
                {
                    stopwatch.Stop();
                    var statusCode = response != null ? (int)response.StatusCode : 500;
                    await LogAuditAsync(config.Id, relativePath, httpMethod.Method, requestBodyString, responseBodyString, statusCode, (int)stopwatch.ElapsedMilliseconds, errorMessage, request.ExecutingUserId);
                }
            }
        }

        throw new InvalidOperationException($"API Call to {requestUri} failed after {maxRetries} retry attempt(s). Error: {errorMessage}");
    }

    private async Task LogAuditAsync(int configId, string endpoint, string httpMethod, string? requestBody, string? responseBody, int statusCode, int durationMs, string? errorMessage, int createdBy)
    {
        try 
        {
            await _dbFactory.ExecuteAsync("pr_InsertIntegrationLog", new {
                ConfigId = configId,
                Endpoint = endpoint,
                HttpMethod = httpMethod,
                RequestBody = requestBody,
                ResponseBody = responseBody,
                StatusCode = statusCode,
                DurationMs = durationMs,
                ErrorMessage = errorMessage,
                CreatedBy = createdBy
            }, commandType: System.Data.CommandType.StoredProcedure);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to write API audit log to the database.");
        }
    }
}
