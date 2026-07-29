using System;
using DNAQMSAPI.Domain.SubscriptionSaaS.Enums;

namespace DNAQMSAPI.Domain.SubscriptionSaaS.Entities;

public class TenantSubscription
{
    public Guid SubscriptionId { get; set; }
    public Guid TenantId { get; set; }
    public int PlanId { get; set; }
    public SubscriptionStatus Status { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime ExpiryDate { get; set; }
    public DateTime? TrialEndDate { get; set; }
    public bool AutoRenew { get; set; }
    public DateTime? GracePeriodEnd { get; set; }
    public DateTime CreatedDate { get; set; }
    public DateTime ModifiedDate { get; set; }
}
