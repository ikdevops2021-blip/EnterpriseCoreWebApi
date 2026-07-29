using System;

namespace DNAQMSAPI.Application.SubscriptionSaaS.DTOs;

public class BillingResult
{
    public Guid InvoiceId { get; set; }
    public decimal NetAmount { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal GrossAmount { get; set; }
    public DateTime BillingDate { get; set; }
    public string Status { get; set; } = string.Empty;
}
