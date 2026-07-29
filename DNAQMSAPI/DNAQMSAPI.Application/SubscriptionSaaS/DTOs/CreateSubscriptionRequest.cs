using System;

namespace DNAQMSAPI.Application.SubscriptionSaaS.DTOs;

public class CreateSubscriptionRequest
{
    public Guid TenantId { get; set; }
    public int PlanId { get; set; }
    public string PaymentMethodId { get; set; } = string.Empty;
}
