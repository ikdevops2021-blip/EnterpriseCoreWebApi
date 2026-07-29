namespace DNAQMSAPI.Domain.Entities;

public class ConfigParameter
{
    public int ParameterID { get; set; }
    public int CategoryID { get; set; }
    public string ParameterCode { get; set; } = null!;
    public string ParameterName { get; set; } = null!;
    public bool IsDefault { get; set; }
    public int Priority { get; set; } = 1;
    public bool IsActive { get; set; } = true;

    public string? ParameterExternalID { get; set; }
    public string? ParameterExternalName { get; set; }
    public string? ParameterExternalCode { get; set; }
    public string? ParameterColor { get; set; }
    public string? ParameterIcon { get; set; }
    public string? ParameterImage { get; set; }
    public string? Attribute1 { get; set; }
    public string? Attribute2 { get; set; }
    public string? Attribute3 { get; set; }

    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int ModifiedBy { get; set; }
    public DateTime ModifiedDate { get; set; }
    public bool IsDeleted { get; set; }
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
