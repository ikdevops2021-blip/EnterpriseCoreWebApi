using System;

namespace DNAQMSAPI.Domain.TaxEngine.Entities;

public class TaxRate
{
    public int TaxRateId { get; set; }
    public int TaxTypeId { get; set; }
    public string CountryCode { get; set; } = string.Empty;
    public string? StateCode { get; set; }
    public decimal Rate { get; set; }
    public DateTime EffectiveDate { get; set; }

    public bool IsActive { get; set; } = true;
    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    public int? ModifiedBy { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool? IsDeleted { get; set; } = false;
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
