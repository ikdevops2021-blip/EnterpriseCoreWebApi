namespace DNAQMSAPI.Domain.Integration;

public class IntegrationLog
{
    public int Id { get; set; }
    public int ConfigId { get; set; }
    public string Endpoint { get; set; } = string.Empty;
    public string HttpMethod { get; set; } = string.Empty;
    public string? RequestBody { get; set; }
    public string? ResponseBody { get; set; }
    public int StatusCode { get; set; }
    public int DurationMs { get; set; }
    public string? ErrorMessage { get; set; }
    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
}
