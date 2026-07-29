namespace DNAQMSAPI.Application.Email.DTOs;

public class EmailSettingsDto
{
    public int SettingId { get; set; }
    public int OrganizationId { get; set; }
    public string SmtpHost { get; set; } = string.Empty;
    public int SmtpPort { get; set; } = 587;
    public string SmtpUser { get; set; } = string.Empty;
    public string SmtpPass { get; set; } = string.Empty;
    public string? SenderDescription { get; set; }
    public bool EnableSSL { get; set; } = true;
    public bool BypassCertificateValidation { get; set; } = false;
    public bool Active { get; set; } = true;

    // Audit columns
    public int CreatedBy { get; set; }
    public DateTime CreateDate { get; set; } = DateTime.UtcNow;
    public int ModifiedBy { get; set; }
    public DateTime ModifyDate { get; set; } = DateTime.UtcNow;
}
