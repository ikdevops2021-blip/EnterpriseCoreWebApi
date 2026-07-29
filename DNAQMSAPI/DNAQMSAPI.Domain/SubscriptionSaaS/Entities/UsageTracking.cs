using System;

namespace DNAQMSAPI.Domain.SubscriptionSaaS.Entities;

public class UsageTracking
{
    public Guid UsageId { get; set; }
    public Guid TenantId { get; set; }
    public string FeatureKey { get; set; } = string.Empty;
    public long UsageCount { get; set; }
    public DateTime PeriodStart { get; set; }
    public DateTime PeriodEnd { get; set; }
}
