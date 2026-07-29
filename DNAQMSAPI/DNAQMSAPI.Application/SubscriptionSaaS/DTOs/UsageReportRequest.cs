using System;

namespace DNAQMSAPI.Application.SubscriptionSaaS.DTOs;

public class UsageReportRequest
{
    public Guid TenantId { get; set; }
    public string FeatureKey { get; set; } = string.Empty;
    public long IncrementBy { get; set; } = 1;
}
