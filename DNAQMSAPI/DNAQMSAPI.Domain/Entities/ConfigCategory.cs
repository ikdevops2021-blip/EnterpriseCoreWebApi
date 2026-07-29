namespace DNAQMSAPI.Domain.Entities;

public class ConfigCategory
{
    public int CategoryID { get; set; }
    public string CategoryCode { get; set; } = null!;
    public string CategoryName { get; set; } = null!;
    public string? Description { get; set; }
    public int Priority { get; set; } = 1;
    public bool Active { get; set; } = true;
    public bool AllowModify { get; set; }
    public int? ParentCategoryID { get; set; }

    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int ModifiedBy { get; set; }
    public DateTime ModifiedDate { get; set; }
    public bool IsDeleted { get; set; }
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }

    public string? CategoryExternalID { get; set; }
    public string? CategoryExternalName { get; set; }
    public string? CategoryExternalCode { get; set; }
    public string? CategoryColor { get; set; }
    public string? CategoryIcon { get; set; }
    public string? CategoryImage { get; set; }
    public string? Attribute1 { get; set; }
    public string? Attribute2 { get; set; }
    public string? Attribute3 { get; set; }
}
