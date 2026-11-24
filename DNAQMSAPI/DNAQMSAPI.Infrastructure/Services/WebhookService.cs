using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Models;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using Dapper;
using DNAQMSAPI.Application.Interfaces;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Infrastructure.Services;

public class WebhookService : IWebhookService
{
    private readonly IDapperDBFactory _dbFactory;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<WebhookService> _logger;

    public WebhookService(
        IDapperDBFactory dbFactory,
        IHttpClientFactory httpClientFactory,
        ILogger<WebhookService> logger)
    {
        _dbFactory = dbFactory;
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    public async Task<ApiResponse<IEnumerable<WebhookSubscriptionDto>>> GetSubscriptionsAsync(
        int organizationId, int? locationId = null, int? id = null, int? isActive = null)
    {
        try
        {
            var parameters = new DynamicParameters();
            parameters.Add("p_OrganizationId", organizationId);
            parameters.Add("p_LocationId", locationId ?? -1);
            parameters.Add("p_Id", id ?? -1);
            parameters.Add("p_IsActive", isActive ?? -1);

            var subscriptions = await _dbFactory.QueryAsync<WebhookSubscriptionDto>(
                "PR_S_WebhookSubscriptions",
                parameters,
                commandType: CommandType.StoredProcedure);

            var nonNullSubs = subscriptions?.Where(s => s != null).Select(s => s!) ?? Enumerable.Empty<WebhookSubscriptionDto>();
            return ApiResponse<IEnumerable<WebhookSubscriptionDto>>.Ok(nonNullSubs);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching webhook subscriptions for Org {OrgId}", organizationId);
            return ApiResponse<IEnumerable<WebhookSubscriptionDto>>.Fail($"Failed to retrieve webhook subscriptions: {ex.Message}");
        }
    }

    public async Task<ApiResponse<WebhookSubscriptionDto>> SaveSubscriptionAsync(
        SaveWebhookSubscriptionRequestDto request, int userId)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(request.EndpointUrl))
            {
                return ApiResponse<WebhookSubscriptionDto>.Fail("Endpoint URL is required.");
            }

            if (!Uri.TryCreate(request.EndpointUrl, UriKind.Absolute, out var uri) || 
                (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps))
            {
                return ApiResponse<WebhookSubscriptionDto>.Fail("Endpoint URL must be a valid HTTP or HTTPS address.");
            }

            // Generate a secure signing secret if not provided
            var secretKey = request.SecretKey;
            if (string.IsNullOrWhiteSpace(secretKey))
            {
                secretKey = "whsec_" + Convert.ToHexString(RandomNumberGenerator.GetBytes(24)).ToLowerInvariant();
            }

            var parameters = new DynamicParameters();
            parameters.Add("p_Id", request.Id);
            parameters.Add("p_OrganizationId", request.OrganizationId);
            parameters.Add("p_LocationId", request.LocationId);
            parameters.Add("p_Name", request.Name);
            parameters.Add("p_EndpointUrl", request.EndpointUrl);
            parameters.Add("p_SecretKey", secretKey);
            parameters.Add("p_SubscribedEvents", request.SubscribedEvents);
            parameters.Add("p_IsActive", request.IsActive ? 1 : 0);
            parameters.Add("p_MaxRetryAttempts", request.MaxRetryAttempts);
            parameters.Add("p_TimeoutSeconds", request.TimeoutSeconds);
            parameters.Add("p_UserId", userId);

            var newId = await _dbFactory.QuerySingleAsync<int>(
                "PR_IU_WebhookSubscription",
                parameters,
                commandType: CommandType.StoredProcedure);

            var savedResult = await GetSubscriptionsAsync(request.OrganizationId, id: newId > 0 ? newId : request.Id);
            var item = savedResult.Data?.FirstOrDefault(s => s.Id == (newId > 0 ? newId : request.Id));

            if (item != null)
            {
                return ApiResponse<WebhookSubscriptionDto>.Ok(item, "Webhook subscription saved successfully.");
            }

            return ApiResponse<WebhookSubscriptionDto>.Ok(new WebhookSubscriptionDto
            {
                Id = newId > 0 ? newId : request.Id,
                OrganizationId = request.OrganizationId,
                LocationId = request.LocationId,
                Name = request.Name,
                EndpointUrl = request.EndpointUrl,
                SecretKey = secretKey,
                SubscribedEvents = request.SubscribedEvents,
                IsActive = request.IsActive
            }, "Webhook subscription saved.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error saving webhook subscription {Name}", request.Name);
            return ApiResponse<WebhookSubscriptionDto>.Fail($"Failed to save webhook subscription: {ex.Message}");
        }
    }

    public async Task<ApiResponse<bool>> DeleteSubscriptionAsync(int id, int userId)
    {
        try
        {
            var parameters = new DynamicParameters();
            parameters.Add("p_Id", id);
            parameters.Add("p_UserId", userId);

            var rows = await _dbFactory.ExecuteAsync(
                "PR_D_WebhookSubscription",
                parameters,
                commandType: CommandType.StoredProcedure);

            return ApiResponse<bool>.Ok(rows > 0, "Webhook subscription deleted successfully.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting webhook subscription {Id}", id);
            return ApiResponse<bool>.Fail($"Failed to delete webhook subscription: {ex.Message}");
        }
    }

    public async Task<ApiResponse<WebhookTestResultDto>> TestWebhookAsync(
        WebhookTestRequestDto request, int organizationId)
    {
        var result = new WebhookTestResultDto();
        var sw = Stopwatch.StartNew();

        try
        {
            string endpointUrl = request.EndpointUrl ?? string.Empty;
            string secretKey = request.SecretKey ?? string.Empty;
            int timeoutSeconds = 10;

            if (request.SubscriptionId.HasValue && request.SubscriptionId.Value > 0)
            {
                var subResult = await GetSubscriptionsAsync(organizationId, id: request.SubscriptionId.Value);
                var sub = subResult.Data?.FirstOrDefault(s => s.Id == request.SubscriptionId.Value);
                if (sub != null)
                {
                    endpointUrl = sub.EndpointUrl;
                    secretKey = sub.SecretKey;
                    timeoutSeconds = sub.TimeoutSeconds > 0 ? sub.TimeoutSeconds : 10;
                }
            }

            if (string.IsNullOrWhiteSpace(endpointUrl))
            {
                return ApiResponse<WebhookTestResultDto>.Fail("A valid target endpoint URL is required to execute a test ping.");
            }

            // Create simulated test payload
            var testEvent = string.IsNullOrWhiteSpace(request.EventCode) ? "token.called" : request.EventCode;
            var deliveryId = "evt_test_" + Guid.NewGuid().ToString("N")[..12];
            var timestamp = DateTime.UtcNow;
            var unixTimestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString();

            var payloadEnvelope = new WebhookPayloadEnvelope<TokenWebhookDataDto>
            {
                Id = deliveryId,
                Event = testEvent,
                Timestamp = timestamp,
                OrganizationId = organizationId,
                LocationId = 1,
                Data = new TokenWebhookDataDto
                {
                    TokenId = 99999,
                    TokenNumber = "TEST-001",
                    ProcessCode = "TST",
                    ProcessName = "Webhook Verification Test",
                    CounterNumber = "C-01",
                    CounterName = "Test Counter 01",
                    TellerName = "System Test Agent",
                    PriorityTier = "Standard",
                    IssuedTime = timestamp.AddMinutes(-5),
                    CalledTime = timestamp,
                    WaitingDurationMinutes = 5.0,
                    TargetTatMinutes = 15,
                    VarianceMinutes = -10.0,
                    VariancePercentage = -66.7,
                    Comments = "This is a simulated test event emitted by AntiGravity DQMS."
                }
            };

            var jsonPayload = JsonSerializer.Serialize(payloadEnvelope, new JsonSerializerOptions { WriteIndented = true });
            result.SentPayload = jsonPayload;

            // Compute HMAC-SHA256 signature
            string signatureHex = string.Empty;
            if (!string.IsNullOrWhiteSpace(secretKey))
            {
                var toSign = $"{unixTimestamp}.{jsonPayload}";
                using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(secretKey));
                signatureHex = "sha256=" + Convert.ToHexString(hmac.ComputeHash(Encoding.UTF8.GetBytes(toSign))).ToLowerInvariant();
                result.ComputedSignature = signatureHex;
            }

            // Execute HTTP request
            var client = _httpClientFactory != null ? _httpClientFactory.CreateClient() : new HttpClient();
            client.Timeout = TimeSpan.FromSeconds(Math.Max(5, timeoutSeconds));

            using var httpRequest = new HttpRequestMessage(HttpMethod.Post, endpointUrl)
            {
                Content = new StringContent(jsonPayload, Encoding.UTF8, "application/json")
            };

            httpRequest.Headers.Add("User-Agent", "AntiGravity-DQMS-Webhook/1.0");
            httpRequest.Headers.Add("X-DQMS-Delivery-Id", deliveryId);
            httpRequest.Headers.Add("X-DQMS-Event", testEvent);
            httpRequest.Headers.Add("X-DQMS-Timestamp", unixTimestamp);
            if (!string.IsNullOrEmpty(signatureHex))
            {
                httpRequest.Headers.Add("X-DQMS-Signature", signatureHex);
            }

            var response = await client.SendAsync(httpRequest);
            sw.Stop();

            result.StatusCode = (int)response.StatusCode;
            result.LatencyMs = (int)sw.ElapsedMilliseconds;
            result.IsSuccess = response.IsSuccessStatusCode;

            var responseBodyText = await response.Content.ReadAsStringAsync();
            result.ResponseBody = responseBodyText.Length > 500 ? responseBodyText[..500] + "..." : responseBodyText;
            result.Message = response.IsSuccessStatusCode
                ? $"Ping succeeded with HTTP {result.StatusCode} in {result.LatencyMs}ms."
                : $"Target server responded with HTTP {result.StatusCode} error in {result.LatencyMs}ms.";

            // If tested against an existing subscription, record into DeliveryLog
            if (request.SubscriptionId.HasValue && request.SubscriptionId.Value > 0)
            {
                var logParams = new DynamicParameters();
                logParams.Add("p_DeliveryId", deliveryId);
                logParams.Add("p_WebhookSubscriptionId", request.SubscriptionId.Value);
                logParams.Add("p_OrganizationId", organizationId);
                logParams.Add("p_EventCode", testEvent);
                logParams.Add("p_PayloadJson", jsonPayload);
                logParams.Add("p_ResponseStatusCode", result.StatusCode);
                logParams.Add("p_ResponseBody", result.ResponseBody);
                logParams.Add("p_DurationMs", result.LatencyMs);
                logParams.Add("p_AttemptCount", 1);
                logParams.Add("p_DeliveryStatus", response.IsSuccessStatusCode ? "Success" : "Failed");
                logParams.Add("p_NextRetryTime", (DateTime?)null);

                await _dbFactory.ExecuteAsync("PR_IU_WebhookDeliveryLog", logParams, commandType: CommandType.StoredProcedure);
            }

            return ApiResponse<WebhookTestResultDto>.Ok(result);
        }
        catch (Exception ex)
        {
            sw.Stop();
            result.IsSuccess = false;
            result.StatusCode = 0;
            result.LatencyMs = (int)sw.ElapsedMilliseconds;
            result.ResponseBody = ex.Message;
            result.Message = $"Test failed: {ex.Message}";

            return ApiResponse<WebhookTestResultDto>.Ok(result, "Test ping encountered a connection exception.");
        }
    }

    public async Task<ApiResponse<IEnumerable<WebhookDeliveryLogDto>>> GetDeliveryLogsAsync(
        int subscriptionId = -1, int organizationId = -1, string? status = null, int pageNumber = 1, int pageSize = 50)
    {
        try
        {
            var parameters = new DynamicParameters();
            parameters.Add("p_WebhookSubscriptionId", subscriptionId);
            parameters.Add("p_OrganizationId", organizationId);
            parameters.Add("p_DeliveryStatus", string.IsNullOrWhiteSpace(status) ? null : status);
            parameters.Add("p_PageNumber", pageNumber);
            parameters.Add("p_PageSize", pageSize);

            var logs = await _dbFactory.QueryAsync<WebhookDeliveryLogDto>(
                "PR_S_WebhookDeliveryLogs",
                parameters,
                commandType: CommandType.StoredProcedure);

            var nonNullLogs = logs?.Where(l => l != null).Select(l => l!) ?? Enumerable.Empty<WebhookDeliveryLogDto>();
            return ApiResponse<IEnumerable<WebhookDeliveryLogDto>>.Ok(nonNullLogs);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching webhook delivery logs");
            return ApiResponse<IEnumerable<WebhookDeliveryLogDto>>.Fail($"Failed to retrieve delivery logs: {ex.Message}");
        }
    }
}
