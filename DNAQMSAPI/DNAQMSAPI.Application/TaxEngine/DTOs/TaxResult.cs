using System;
using System.Collections.Generic;

namespace DNAQMSAPI.Application.TaxEngine.DTOs;

public class TaxResult
{
    public Guid InvoiceId { get; set; }
    public decimal BaseAmount { get; set; }
    public decimal TotalTaxAmount { get; set; }
    public decimal TotalAmount { get; set; }

    public List<TaxBreakdownItem> Breakdowns { get; set; } = new();
}

public class TaxBreakdownItem
{
    public int TaxTypeId { get; set; }
    public string TaxName { get; set; } = string.Empty;
    public decimal Rate { get; set; }
    public decimal TaxAmount { get; set; }
}
