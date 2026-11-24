using System;
using System.Collections.Generic;

namespace AntiGravity.Enterprise.Shared.Core.Models.DQMS;

/// <summary>
/// Status of an outbound webhook dispatch attempt.
/// </summary>
public enum e_WebhookDeliveryStatus
{
    Success,
    PendingRetry,
    DeadLetter
}

/// <summary>
/// Webhook subscription DTO representing registered external HTTP listener.
/// </summary>
public class WebhookSubscriptionDto
{
    public int Id { get; set; }
    public int OrganizationId { get; set; }
    public int? LocationId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string EndpointUrl { get; set; } = string.Empty;
    public string SecretKey { get; set; } = string.Empty;
    public string SubscribedEvents { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    public int MaxRetryAttempts { get; set; } = 3;
    public int TimeoutSeconds { get; set; } = 10;
    public int ConsecutiveFailures { get; set; }
    public DateTime? CircuitBreakerUntil { get; set; }
    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int ModifiedBy { get; set; }
    public DateTime ModifiedDate { get; set; }

    // Summary statistics for UI
    public string? LastDeliveryStatus { get; set; }
    public int? LastResponseStatusCode { get; set; }
    public DateTime? LastDeliveryDate { get; set; }
}

/// <summary>
/// Request DTO for creating or updating a webhook subscription.
/// </summary>
public class SaveWebhookSubscriptionRequestDto
{
    public int Id { get; set; }
    public int OrganizationId { get; set; } = 1;
    public int? LocationId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string EndpointUrl { get; set; } = string.Empty;
    public string? SecretKey { get; set; }
    public string SubscribedEvents { get; set; } = "token.issued,token.called,token.completed";
    public bool IsActive { get; set; } = true;
    public int MaxRetryAttempts { get; set; } = 3;
    public int TimeoutSeconds { get; set; } = 10;
}

/// <summary>
/// Webhook delivery log record detailing dispatch latency, HTTP status, and payload.
/// </summary>
public class WebhookDeliveryLogDto
{
    public long Id { get; set; }
    public string DeliveryId { get; set; } = string.Empty;
    public int WebhookSubscriptionId { get; set; }
    public string? SubscriptionName { get; set; }
    public int OrganizationId { get; set; }
    public string EventCode { get; set; } = string.Empty;
    public string PayloadJson { get; set; } = string.Empty;
    public int? ResponseStatusCode { get; set; }
    public string? ResponseBody { get; set; }
    public int DurationMs { get; set; }
    public int AttemptCount { get; set; }
    public string DeliveryStatus { get; set; } = "Success";
    public DateTime? NextRetryTime { get; set; }
    public DateTime CreatedDate { get; set; }
}

/// <summary>
/// Request DTO for testing a webhook endpoint with a simulated ping payload.
/// </summary>
public class WebhookTestRequestDto
{
    public int? SubscriptionId { get; set; }
    public string? EndpointUrl { get; set; }
    public string? SecretKey { get; set; }
    public string EventCode { get; set; } = "token.called";
}

/// <summary>
/// Result of an interactive test ping against a webhook subscriber endpoint.
/// </summary>
public class WebhookTestResultDto
{
    public bool IsSuccess { get; set; }
    public int StatusCode { get; set; }
    public int LatencyMs { get; set; }
    public string? ResponseBody { get; set; }
    public string Message { get; set; } = string.Empty;
    public string? ComputedSignature { get; set; }
    public string? SentPayload { get; set; }
}

/// <summary>
/// Standardized JSON payload envelope delivered to all external webhook endpoints.
/// </summary>
public class WebhookPayloadEnvelope<T>
{
    public string Id { get; set; } = string.Empty;
    public string Event { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    public int OrganizationId { get; set; }
    public int? LocationId { get; set; }
    public T? Data { get; set; }
}

/// <summary>
/// Queue token event data payload.
/// </summary>
public class TokenWebhookDataDto
{
    public long TokenId { get; set; }
    public string TokenNumber { get; set; } = string.Empty;
    public long? ParentTokenId { get; set; }
    public int StepOrder { get; set; } = 1;
    public int ProcessId { get; set; }
    public string ProcessCode { get; set; } = string.Empty;
    public string ProcessName { get; set; } = string.Empty;
    public int? CounterId { get; set; }
    public string? CounterNumber { get; set; }
    public string? CounterName { get; set; }
    public int? TellerUserId { get; set; }
    public string? TellerName { get; set; }
    public int PriorityTierId { get; set; } = 19004;
    public string PriorityTier { get; set; } = "Standard";
    public DateTime IssuedTime { get; set; }
    public DateTime? CalledTime { get; set; }
    public DateTime? ServedTime { get; set; }
    public DateTime? CompletedTime { get; set; }
    public double WaitingDurationMinutes { get; set; }
    public double ServiceDurationMinutes { get; set; }
    public int TargetTatMinutes { get; set; }
    public double VarianceMinutes { get; set; }
    public double VariancePercentage { get; set; }
    public string? Comments { get; set; }
}
