using AntiGravity.Enterprise.Shared.Core.Models;

namespace DNAQMSAPI.Domain.Integration;

public class ApiIntegration
{
    public int IntegrationID { get; set; }
    public int TenantId { get; set; }
    public string ProviderName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string BaseUrl { get; set; } = string.Empty;
    public bool Active { get; set; } = true;
    public int AuditLevel { get; set; } = 1;
    public AuthType AuthType { get; set; } = AuthType.JwtBearer;
    
    public string? ApiKey { get; set; }
    public string? ApiUsername { get; set; }
    public string? ApiPassword { get; set; }
    public string? TokenUrl { get; set; }
    public string? ClientID { get; set; }
    public string? CurrentToken { get; set; }
    public string? ClientSecret { get; set; }
    public DateTime? TokenExpiration { get; set; }
    public string? HMACSecretKey { get; set; }
    public string? HMACHeaderName { get; set; }
    public bool RequiresCertificate { get; set; }

    // Audit Fields
    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    public int ModifiedBy { get; set; }
    public DateTime ModifiedDate { get; set; } = DateTime.UtcNow;
    public bool IsDeleted { get; set; } = false;
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
