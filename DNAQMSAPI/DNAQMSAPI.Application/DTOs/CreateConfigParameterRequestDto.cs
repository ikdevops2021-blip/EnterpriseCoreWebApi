namespace DNAQMSAPI.Application.DTOs;

public class CreateConfigParameterRequestDto
{
    public int CategoryID { get; set; }
    public string ParameterCode { get; set; } = string.Empty;
    public string ParameterName { get; set; } = string.Empty;
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
}
