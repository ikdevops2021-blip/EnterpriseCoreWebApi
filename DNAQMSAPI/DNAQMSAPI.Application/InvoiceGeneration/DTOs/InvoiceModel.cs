using System;
using System.Collections.Generic;

namespace DNAQMSAPI.Application.InvoiceGeneration.DTOs;

public class InvoiceModel
{
    public Guid InvoiceId { get; set; }
    public Guid SubscriptionId { get; set; }
    public DateTime BillingDate { get; set; }
    public decimal NetAmount { get; set; }
    public decimal TotalTax { get; set; }
    public decimal GrossAmount { get; set; }
    public int Status { get; set; }
    
    // Metadata properties
    public string? CustomerVatNumber { get; set; }
    public string? TenantVatNumber { get; set; }
    public bool IsReverseCharge { get; set; }
    public string? CountrySpecificData { get; set; } // JSON String
}
