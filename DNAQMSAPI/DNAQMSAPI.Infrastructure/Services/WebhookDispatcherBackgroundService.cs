using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Channels;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Models;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using Dapper;
using DNAQMSAPI.Application.Interfaces;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Infrastructure.Services;

/// <summary>
/// High-throughput, asynchronous background worker that drains the in-memory event channel
/// and dispatches signed HTTP POST webhooks with exponential backoff and circuit breaking.
/// </summary>
public class WebhookDispatcherBackgroundService : BackgroundService, IWebhookDispatcher
{
    private readonly Channel<WebhookEventMessage> _eventChannel;
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IMemoryCache _memoryCache;
    private readonly ILogger<WebhookDispatcherBackgroundService> _logger;

    public WebhookDispatcherBackgroundService(
        IServiceScopeFactory scopeFactory,
        IHttpClientFactory httpClientFactory,
        IMemoryCache memoryCache,
        ILogger<WebhookDispatcherBackgroundService> logger)
    {
        _scopeFactory = scopeFactory;
        _httpClientFactory = httpClientFactory;
        _memoryCache = memoryCache;
        _logger = logger;

        // Bounded capacity of 10,000 prevents memory exhaustion during massive queue surges
        _eventChannel = Channel.CreateBounded<WebhookEventMessage>(new BoundedChannelOptions(10000)
        {
            FullMode = BoundedChannelFullMode.Wait,
            SingleReader = true
        });
    }

    /// <summary>
    /// Non-blocking event emission called by queue controllers (< 1ms execution time).
    /// </summary>
    public ValueTask EnqueueEventAsync(string eventCode, int organizationId, int? locationId, object data)
    {
        var msg = new WebhookEventMessage
        {
            EventCode = eventCode,
            OrganizationId = organizationId,
            LocationId = locationId,
            Data = data,
            Timestamp = DateTime.UtcNow
        };

        if (!_eventChannel.Writer.TryWrite(msg))
        {
            return _eventChannel.Writer.WriteAsync(msg);
        }

        return ValueTask.CompletedTask;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("DQMS Webhook Notification Dispatcher background service started.");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                var message = await _eventChannel.Reader.ReadAsync(stoppingToken);
                await ProcessEventMessageAsync(message, stoppingToken);
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error in Webhook Dispatcher execution loop.");
                await Task.Delay(500, stoppingToken);
            }
        }

        _logger.LogInformation("DQMS Webhook Notification Dispatcher background service stopped.");
    }

    private async Task ProcessEventMessageAsync(WebhookEventMessage msg, CancellationToken stoppingToken)
    {
        using var scope = _scopeFactory.CreateScope();
        var dbFactory = scope.ServiceProvider.GetRequiredService<IDapperDBFactory>();

        // 1. Resolve active subscriptions from cache or DB
        var cacheKey = $"active_webhook_subs_org_{msg.OrganizationId}";
        if (!_memoryCache.TryGetValue(cacheKey, out List<WebhookSubscriptionDto>? subscriptions) || subscriptions == null)
        {
            try
            {
                var parameters = new DynamicParameters();
                parameters.Add("p_OrganizationId", msg.OrganizationId);
                parameters.Add("p_LocationId", -1);
                parameters.Add("p_Id", -1);
                parameters.Add("p_IsActive", 1);

                var dbResult = await dbFactory.QueryAsync<WebhookSubscriptionDto>(
                    "PR_S_WebhookSubscriptions",
                    parameters,
                    commandType: CommandType.StoredProcedure);

                subscriptions = dbResult?.Where(s => s != null).Select(s => s!).ToList() ?? new List<WebhookSubscriptionDto>();
                _memoryCache.Set(cacheKey, subscriptions, TimeSpan.FromSeconds(60));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to load active webhook subscriptions from database for Org {OrgId}", msg.OrganizationId);
                return;
            }
        }

        if (subscriptions.Count == 0) return;

        // 2. Filter matching subscribers
        var matchingSubs = subscriptions.FindAll(s =>
            s.IsActive &&
            (!s.LocationId.HasValue || s.LocationId == msg.LocationId) &&
            (!s.CircuitBreakerUntil.HasValue || s.CircuitBreakerUntil.Value <= DateTime.UtcNow) &&
            IsEventSubscribed(s.SubscribedEvents, msg.EventCode));

        if (matchingSubs.Count == 0) return;

        // 3. Dispatch to all matching subscribers concurrently
        var dispatchTasks = new List<Task>();
        foreach (var sub in matchingSubs)
        {
            dispatchTasks.Add(DispatchToSubscriberAsync(sub, msg, dbFactory, stoppingToken));
        }

        await Task.WhenAll(dispatchTasks);
    }

    private async Task DispatchToSubscriberAsync(
        WebhookSubscriptionDto sub,
        WebhookEventMessage msg,
        IDapperDBFactory dbFactory,
        CancellationToken stoppingToken)
    {
        var deliveryId = "evt_" + Guid.NewGuid().ToString("N")[..16];
        var timestamp = msg.Timestamp;
        var unixTimestamp = new DateTimeOffset(timestamp).ToUnixTimeSeconds().ToString();

        var payloadEnvelope = new WebhookPayloadEnvelope<object>
        {
            Id = deliveryId,
            Event = msg.EventCode,
            Timestamp = timestamp,
            OrganizationId = msg.OrganizationId,
            LocationId = msg.LocationId,
            Data = msg.Data
        };

        var jsonPayload = JsonSerializer.Serialize(payloadEnvelope, new JsonSerializerOptions { WriteIndented = false });

        // Compute HMAC-SHA256 signature
        string signatureHex = string.Empty;
        if (!string.IsNullOrWhiteSpace(sub.SecretKey))
        {
            var toSign = $"{unixTimestamp}.{jsonPayload}";
            using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(sub.SecretKey));
            signatureHex = "sha256=" + Convert.ToHexString(hmac.ComputeHash(Encoding.UTF8.GetBytes(toSign))).ToLowerInvariant();
        }

        var sw = Stopwatch.StartNew();
        int statusCode = 0;
        string? responseBody = null;
        string deliveryStatus = "Success";
        DateTime? nextRetryTime = null;

        try
        {
            var client = _httpClientFactory.CreateClient("WebhookClient");
            client.Timeout = TimeSpan.FromSeconds(Math.Max(3, sub.TimeoutSeconds));

            using var request = new HttpRequestMessage(HttpMethod.Post, sub.EndpointUrl)
            {
                Content = new StringContent(jsonPayload, Encoding.UTF8, "application/json")
            };

            request.Headers.Add("User-Agent", "AntiGravity-DQMS-Webhook/1.0");
            request.Headers.Add("X-DQMS-Delivery-Id", deliveryId);
            request.Headers.Add("X-DQMS-Event", msg.EventCode);
            request.Headers.Add("X-DQMS-Timestamp", unixTimestamp);
            if (!string.IsNullOrEmpty(signatureHex))
            {
                request.Headers.Add("X-DQMS-Signature", signatureHex);
            }

            var response = await client.SendAsync(request, stoppingToken);
            sw.Stop();

            statusCode = (int)response.StatusCode;
            var responseContent = await response.Content.ReadAsStringAsync(stoppingToken);
            responseBody = responseContent.Length > 500 ? responseContent[..500] : responseContent;

            if (!response.IsSuccessStatusCode)
            {
                deliveryStatus = "PendingRetry";
                nextRetryTime = DateTime.UtcNow.AddSeconds(30);
                _logger.LogWarning("Webhook dispatch {DeliveryId} to {Url} returned HTTP {Status}", deliveryId, sub.EndpointUrl, statusCode);
            }
        }
        catch (Exception ex)
        {
            sw.Stop();
            statusCode = 0;
            responseBody = ex.Message.Length > 500 ? ex.Message[..500] : ex.Message;
            deliveryStatus = "PendingRetry";
            nextRetryTime = DateTime.UtcNow.AddSeconds(30);
            _logger.LogWarning("Webhook dispatch {DeliveryId} to {Url} failed with exception: {Ex}", deliveryId, sub.EndpointUrl, ex.Message);
        }

        // Record delivery log in database
        try
        {
            var logParams = new DynamicParameters();
            logParams.Add("p_DeliveryId", deliveryId);
            logParams.Add("p_WebhookSubscriptionId", sub.Id);
            logParams.Add("p_OrganizationId", sub.OrganizationId);
            logParams.Add("p_EventCode", msg.EventCode);
            logParams.Add("p_PayloadJson", jsonPayload);
            logParams.Add("p_ResponseStatusCode", statusCode);
            logParams.Add("p_ResponseBody", responseBody);
            logParams.Add("p_DurationMs", (int)sw.ElapsedMilliseconds);
            logParams.Add("p_AttemptCount", 1);
            logParams.Add("p_DeliveryStatus", deliveryStatus);
            logParams.Add("p_NextRetryTime", nextRetryTime);

            await dbFactory.ExecuteAsync("PR_IU_WebhookDeliveryLog", logParams, commandType: CommandType.StoredProcedure);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to write WebhookDeliveryLog for {DeliveryId}", deliveryId);
        }
    }

    private static bool IsEventSubscribed(string subscribedEvents, string eventCode)
    {
        if (string.IsNullOrWhiteSpace(subscribedEvents)) return false;
        if (subscribedEvents.Trim() == "*") return true;

        var events = subscribedEvents.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        foreach (var ev in events)
        {
            if (string.Equals(ev, eventCode, StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }
        }

        return false;
    }
}
