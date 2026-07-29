namespace DNAQMSAPI.Domain.Integration;

public class ApiAuditLog
{
    public long AuditID { get; set; }
    public int IntegrationID { get; set; }
    public string ActionName { get; set; } = string.Empty;
    public string RequestUrl { get; set; } = string.Empty;
    public string HttpMethod { get; set; } = string.Empty;
    public string? RequestBody { get; set; }
    public string? ResponseBody { get; set; }
    public int? StatusCode { get; set; }
    public int DurationMs { get; set; }
    public string? ErrorMessage { get; set; }
    public int? CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
}
