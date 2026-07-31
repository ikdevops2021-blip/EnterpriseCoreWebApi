using System.Data;
using AntiGravity.Enterprise.Shared.Core.Controllers;
using DNAQMSAPI.Application.DTOs;
using DNAQMSAPI.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers;

[AllowAnonymous]
[ApiController]
[Route("api/v1/[controller]")]
public class LogsController : ApiControllerBase
{
    private readonly ILoggerFactory _loggerFactory;
    private readonly IDapperDBFactory _dbFactory;

    public LogsController(ILoggerFactory loggerFactory, IDapperDBFactory dbFactory)
    {
        _loggerFactory = loggerFactory;
        _dbFactory = dbFactory;
    }

    /// <summary>
    /// Log a client-side application error, debug, info, warning, or fatal exception into NLog & database.
    /// </summary>
    [HttpPost]
    public IActionResult LogClientMessage([FromBody] ClientLogEntryRequestDto request)
    {
        if (request == null || string.IsNullOrWhiteSpace(request.Message))
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Log request body and Message field are required."));
        }

        ProcessLogEntry(request);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new { ProcessedCount = 1 }, "Client log entry recorded successfully."));
    }

    /// <summary>
    /// Batch log multiple client-side entries in a single request.
    /// </summary>
    [HttpPost("batch")]
    public IActionResult LogClientBatch([FromBody] List<ClientLogEntryRequestDto> requests)
    {
        if (requests == null || requests.Count == 0)
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body must contain at least one log entry."));
        }

        int count = 0;
        foreach (var entry in requests)
        {
            if (entry != null && !string.IsNullOrWhiteSpace(entry.Message))
            {
                ProcessLogEntry(entry);
                count++;
            }
        }

        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new { ProcessedCount = count }, $"{count} client log entries recorded successfully."));
    }

    /// <summary>
    /// Query recent application logs from AppLogs database table (For System Administrators & Monitoring).
    /// </summary>
    [Authorize]
    [HttpGet]
    public async Task<IActionResult> GetRecentLogs(
        [FromQuery] string? level = null,
        [FromQuery] string? logger = null,
        [FromQuery] string? search = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50)
    {
        pageSize = Math.Clamp(pageSize, 1, 200);
        int offset = Math.Max(0, (page - 1) * pageSize);

        string sql = @"
            SELECT Id, MachineName, Logged, Level, Message, Logger, Callsite, Exception, VerboseInfo, Url, Action 
            FROM AppLogs
            WHERE (@Level IS NULL OR Level = @Level)
              AND (@Logger IS NULL OR Logger LIKE CONCAT('%', @Logger, '%'))
              AND (@Search IS NULL OR Message LIKE CONCAT('%', @Search, '%') OR Exception LIKE CONCAT('%', @Search, '%'))
            ORDER BY Logged DESC
            LIMIT @PageSize OFFSET @Offset;";

        try
        {
            var logs = await _dbFactory.QueryAsync<AppLogItemDto>(
                sql,
                new { Level = level, Logger = logger, Search = search, PageSize = pageSize, Offset = offset },
                commandType: CommandType.Text);

            return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(logs));
        }
        catch
        {
            // Fallback for SQL Server syntax if MySQL syntax fails
            string sqlServer = @"
                SELECT Id, MachineName, Logged, Level, Message, Logger, Callsite, Exception, VerboseInfo, Url, Action 
                FROM dbo.AppLogs
                WHERE (@Level IS NULL OR Level = @Level)
                  AND (@Logger IS NULL OR Logger LIKE '%' + @Logger + '%')
                  AND (@Search IS NULL OR Message LIKE '%' + @Search + '%' OR Exception LIKE '%' + @Search + '%')
                ORDER BY Logged DESC
                OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;";

            var logs = await _dbFactory.QueryAsync<AppLogItemDto>(
                sqlServer,
                new { Level = level, Logger = logger, Search = search, PageSize = pageSize, Offset = offset },
                commandType: CommandType.Text);

            return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(logs));
        }
    }

    private void ProcessLogEntry(ClientLogEntryRequestDto request)
    {
        string loggerCategory = !string.IsNullOrWhiteSpace(request.LoggerName)
            ? $"ClientApp.{request.LoggerName}"
            : "ClientApp.General";

        var logger = _loggerFactory.CreateLogger(loggerCategory);
        var level = MapLogLevel(request.LogLevel);

        string formattedMsg = $"{request.Message} | Url: {request.Url ?? "N/A"} | ClientInfo: {request.ClientInfo ?? "N/A"}";

        if (!string.IsNullOrWhiteSpace(request.ExceptionDetails))
        {
            formattedMsg += $" | Exception: {request.ExceptionDetails}";
        }

        if (request.Properties != null && request.Properties.Count > 0)
        {
            formattedMsg += $" | Properties: {string.Join(", ", request.Properties.Select(p => $"{p.Key}={p.Value}"))}";
        }

        switch (level)
        {
            case LogLevel.Trace:
                logger.LogTrace(formattedMsg);
                break;
            case LogLevel.Debug:
                logger.LogDebug(formattedMsg);
                break;
            case LogLevel.Warning:
                logger.LogWarning(formattedMsg);
                break;
            case LogLevel.Error:
                logger.LogError(formattedMsg);
                break;
            case LogLevel.Critical:
                logger.LogCritical(formattedMsg);
                break;
            case LogLevel.Information:
            default:
                logger.LogInformation(formattedMsg);
                break;
        }
    }

    private static LogLevel MapLogLevel(string? levelStr)
    {
        if (string.IsNullOrWhiteSpace(levelStr)) return LogLevel.Information;

        return levelStr.Trim().ToLowerInvariant() switch
        {
            "trace" => LogLevel.Trace,
            "debug" => LogLevel.Debug,
            "warn" or "warning" => LogLevel.Warning,
            "error" => LogLevel.Error,
            "fatal" or "critical" => LogLevel.Critical,
            _ => LogLevel.Information
        };
    }
}
