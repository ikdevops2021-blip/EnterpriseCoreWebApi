namespace DNAQMSAPI.Application.Integration.DTOs;

public class ApiRequest
{
    public int? TenantId { get; set; }
    public int ExecutingUserId { get; set; }
    public string ConfigName { get; set; } = string.Empty;
    public string Method { get; set; } = "GET";
    public string Endpoint { get; set; } = string.Empty;
    public object? Body { get; set; }
    public Dictionary<string, string> Headers { get; set; } = new Dictionary<string, string>();
    public Dictionary<string, string> RouteParameters { get; set; } = new Dictionary<string, string>();
    public int TimeoutSeconds { get; set; } = 100;
    public int MaxRetries { get; set; } = 3;
}
