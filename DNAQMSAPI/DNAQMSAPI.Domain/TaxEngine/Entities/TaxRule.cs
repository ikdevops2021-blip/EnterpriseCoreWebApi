using System;

namespace DNAQMSAPI.Domain.TaxEngine.Entities;

public class TaxRule
{
    public int TaxRuleId { get; set; }
    public int TaxTypeId { get; set; }
    public string RuleName { get; set; } = string.Empty;
    public int Priority { get; set; }
    public string? Condition { get; set; }

    public bool IsActive { get; set; } = true;
    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    public int? ModifiedBy { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool? IsDeleted { get; set; } = false;
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
