using System;

namespace DNAQMSAPI.Application.TaxEngine.DTOs;

public class TaxRequest
{
    public Guid InvoiceId { get; set; }
    public decimal BaseAmount { get; set; }
    public string CountryCode { get; set; } = string.Empty;
    public string? StateCode { get; set; }
}
