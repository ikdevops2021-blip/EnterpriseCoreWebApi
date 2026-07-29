using System;

namespace DNAQMSAPI.Domain.Entities;

public class WebhookLog
{
    public int Id { get; set; }
    public Guid Guid { get; set; }
    public int PaymentProviderId { get; set; }
    public string? EventId { get; set; }
    public string EventType { get; set; } = string.Empty;
    public string Payload { get; set; } = string.Empty;
    public bool IsProcessed { get; set; }

    // Audit fields
    public DateTime CreatedOn { get; set; }
    public string CreatedBy { get; set; } = string.Empty;
}
