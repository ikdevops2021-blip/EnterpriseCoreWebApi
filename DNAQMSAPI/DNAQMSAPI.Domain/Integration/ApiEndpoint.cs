namespace DNAQMSAPI.Domain.Integration;

public class ApiEndpoint
{
    public int EndpointID { get; set; }
    public int IntegrationID { get; set; }
    public string ActionName { get; set; } = string.Empty;
    public string RelativePath { get; set; } = string.Empty;
    public string HttpMethod { get; set; } = "POST";
    public string? Description { get; set; }
    public bool Active { get; set; } = true;
    public string? SampleAPIRequest { get; set; }
    public string? SampleAPIResponse { get; set; }

    // Joined Provider Metadata
    public string? ProviderName { get; set; }
    public string? BaseUrl { get; set; }
    public int AuthType { get; set; }

    // Audit Fields
    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    public int ModifiedBy { get; set; }
    public DateTime ModifiedDate { get; set; } = DateTime.UtcNow;
    public bool IsDeleted { get; set; } = false;
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
