using System;

namespace DNAQMSAPI.Domain.Entities;

public class WebhookSubscription
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
    public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    public int ModifiedBy { get; set; }
    public DateTime ModifiedDate { get; set; } = DateTime.UtcNow;
    public bool IsDeleted { get; set; }
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
