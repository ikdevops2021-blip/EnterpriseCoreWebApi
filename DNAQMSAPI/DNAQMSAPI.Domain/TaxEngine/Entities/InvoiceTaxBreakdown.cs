using System;

namespace DNAQMSAPI.Domain.TaxEngine.Entities;

public class InvoiceTaxBreakdown
{
    public int InvoiceTaxBreakdownId { get; set; }
    public Guid InvoiceId { get; set; }
    public int TaxTypeId { get; set; }
    public string TaxName { get; set; } = string.Empty;
    public decimal Rate { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal BaseAmount { get; set; }

    public bool IsActive { get; set; } = true;
    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    public int? ModifiedBy { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool? IsDeleted { get; set; } = false;
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
