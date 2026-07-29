namespace DNAQMSAPI.Domain.Entities;

public class SystemConfigurationKey
{
    public int SystemConfigurationKeyID { get; set; }
    public string Key { get; set; } = null!;
    public string Value { get; set; } = null!;
    public string? Description { get; set; }
    public string? AcceptedValues { get; set; }
    public int DataTypeID { get; set; }
    public string? DataTypeCode { get; set; }
    public string? DataTypeName { get; set; }
    public int? DataTypeCategoryID { get; set; }
    public bool AllowEdit { get; set; }
    public bool Active { get; set; } = true;

    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int ModifiedBy { get; set; }
    public DateTime ModifiedDate { get; set; }
    public bool IsDeleted { get; set; }
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
