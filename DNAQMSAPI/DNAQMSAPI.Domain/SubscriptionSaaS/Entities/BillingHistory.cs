using System;

namespace DNAQMSAPI.Domain.SubscriptionSaaS.Entities;

public class BillingHistory
{
    public Guid BillingId { get; set; }
    public Guid SubscriptionId { get; set; }
    public DateTime BillingStart { get; set; }
    public DateTime BillingEnd { get; set; }
    public decimal Amount { get; set; }
    public string? InvoiceNumber { get; set; }
    public bool Paid { get; set; }
    public DateTime CreatedDate { get; set; }
}
