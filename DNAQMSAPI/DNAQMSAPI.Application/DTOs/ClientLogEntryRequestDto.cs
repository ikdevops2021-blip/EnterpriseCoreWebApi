namespace DNAQMSAPI.Application.DTOs;

public class ClientLogEntryRequestDto
{
    /// <summary>
    /// Log severity level: "Debug", "Info", "Warn", "Warning", "Error", "Fatal", "Trace"
    /// </summary>
    public string LogLevel { get; set; } = "Info";

    /// <summary>
    /// Primary log message content
    /// </summary>
    public string Message { get; set; } = string.Empty;

    /// <summary>
    /// Source component or logger name (e.g., "FlutterFrontend", "OperatorConsole", "KioskTerminal", "TvDisplay")
    /// </summary>
    public string? LoggerName { get; set; } = "ClientApplication";

    /// <summary>
    /// Optional exception details, stack trace, or error payload
    /// </summary>
    public string? ExceptionDetails { get; set; }

    /// <summary>
    /// Client-side URL or route where the event occurred
    /// </summary>
    public string? Url { get; set; }

    /// <summary>
    /// Client metadata (e.g. browser user agent, OS, app version)
    /// </summary>
    public string? ClientInfo { get; set; }

    /// <summary>
    /// Optional key-value pair attributes or custom properties
    /// </summary>
    public Dictionary<string, string>? Properties { get; set; }
}
