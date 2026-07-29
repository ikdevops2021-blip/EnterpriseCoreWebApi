using System;

namespace DNAQMSAPI.Domain.SubscriptionSaaS.Entities;

public class PaymentTransaction
{
    public Guid TransactionId { get; set; }
    public Guid SubscriptionId { get; set; }
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "USD";
    public string PaymentProvider { get; set; } = string.Empty;
    public string? ProviderTransactionId { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedDate { get; set; }
}
