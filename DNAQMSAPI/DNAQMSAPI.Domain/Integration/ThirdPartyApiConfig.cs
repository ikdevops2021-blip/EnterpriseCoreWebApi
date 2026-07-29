using System.Text.Json.Serialization;
using AntiGravity.Enterprise.Shared.Core.Models;

namespace DNAQMSAPI.Domain.Integration;

public class ThirdPartyApiConfig
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int? TenantId { get; set; }
    public string BaseUrl { get; set; } = string.Empty;
    public AuthType AuthType { get; set; }
    
    [JsonIgnore]
    public string? ApiKey { get; set; }
    
    [JsonIgnore]
    public string? Username { get; set; }
    
    [JsonIgnore]
    public string? Password { get; set; }
    
    [JsonIgnore]
    public string? ClientId { get; set; }
    
    [JsonIgnore]
    public string? ClientSecret { get; set; }
    
    [JsonIgnore]
    public string? TokenEndpoint { get; set; }
    
    [JsonIgnore]
    public string? Scope { get; set; }
    
    [JsonIgnore]
    public string? AccessToken { get; set; }
    
    [JsonIgnore]
    public string? RefreshToken { get; set; }
    
    public DateTime? TokenExpiry { get; set; }
    public bool IsGlobal { get; set; }
    public bool IsActive { get; set; }

    // Audit Fields
    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int ModifiedBy { get; set; }
    public DateTime ModifiedDate { get; set; }
    public bool IsDeleted { get; set; } = false;
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
