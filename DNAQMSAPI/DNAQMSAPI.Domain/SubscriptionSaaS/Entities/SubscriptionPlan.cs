using System;

namespace DNAQMSAPI.Domain.SubscriptionSaaS.Entities;

public class SubscriptionPlan
{
    public int PlanId { get; set; }
    public string PlanName { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int BillingCycleMonths { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedDate { get; set; }
}
