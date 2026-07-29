using System;

namespace DNAQMSAPI.Domain.TaxEngine.Entities;

public class TaxType
{
    public int TaxTypeId { get; set; }
    public string TaxName { get; set; } = string.Empty;
    public short CalculationType { get; set; } // Map to TaxCalculationType
    public short ApplicationType { get; set; } // Map to TaxApplicationType
    public bool IsCompound { get; set; }

    public bool IsActive { get; set; } = true;
    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    public int? ModifiedBy { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool? IsDeleted { get; set; } = false;
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
