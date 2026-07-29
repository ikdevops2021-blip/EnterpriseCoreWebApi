namespace DNAQMSAPI.Application.Email.DTOs;

public class MailServerConfig
{
    public string SmtpHost { get; set; } = string.Empty;
    public int SmtpPort { get; set; }
    public string SmtpUser { get; set; } = string.Empty;
    public string SmtpPass { get; set; } = string.Empty;
    public bool EnableSSL { get; set; } = true;
    public bool BypassCertificateValidation { get; set; } = false;
    public string SenderDescription { get; set; } = string.Empty;
}
