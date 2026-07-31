namespace DNAQMSAPI.Application.DTOs;

public class AppLogItemDto
{
    public int Id { get; set; }
    public string MachineName { get; set; } = string.Empty;
    public DateTime Logged { get; set; }
    public string Level { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string Logger { get; set; } = string.Empty;
    public string? Callsite { get; set; }
    public string? Exception { get; set; }
    public string? VerboseInfo { get; set; }
    public string? Url { get; set; }
    public string? Action { get; set; }
}
