namespace DNAQMSAPI.Application.DTOs;

public class UpdateConfigCategoryRequestDto
{
    public string CategoryCode { get; set; } = string.Empty;
    public string CategoryName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int Priority { get; set; } = 1;
    public bool Active { get; set; } = true;
    public bool AllowModify { get; set; }
    public int? ParentCategoryID { get; set; }
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
