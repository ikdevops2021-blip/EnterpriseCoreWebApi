using System;

namespace DNAQMSAPI.Domain.Entities;

public class WebhookDeliveryLog
{
    public long Id { get; set; }
    public string DeliveryId { get; set; } = string.Empty;
    public int WebhookSubscriptionId { get; set; }
    public int OrganizationId { get; set; }
    public string EventCode { get; set; } = string.Empty;
    public string PayloadJson { get; set; } = string.Empty;
    public int? ResponseStatusCode { get; set; }
    public string? ResponseBody { get; set; }
    public int DurationMs { get; set; }
    public int AttemptCount { get; set; } = 1;
    public string DeliveryStatus { get; set; } = "Success";
    public DateTime? NextRetryTime { get; set; }
    public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
}
