using System.Data;
using AntiGravity.Enterprise.Shared.Core.Controllers;
using Dapper;
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
        [FromQuery] DateTime? logDate = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 100)
    {
        pageSize = Math.Clamp(pageSize, 1, 500);
        int offset = Math.Max(0, (page - 1) * pageSize);

        var parameters = new DynamicParameters();
        parameters.Add("PageSize", pageSize);
        parameters.Add("Offset", offset);

        var conditions = new List<string>();

        if (!string.IsNullOrWhiteSpace(level) && !level.Equals("ALL", StringComparison.OrdinalIgnoreCase))
        {
            conditions.Add("Level = @Level");
            parameters.Add("Level", level.Trim());
        }

        if (!string.IsNullOrWhiteSpace(logger))
        {
            conditions.Add("Logger LIKE @Logger");
            parameters.Add("Logger", $"%{logger.Trim()}%");
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            conditions.Add("(Message LIKE @Search OR Exception LIKE @Search OR Url LIKE @Search)");
            parameters.Add("Search", $"%{search.Trim()}%");
        }

        if (logDate.HasValue)
        {
            conditions.Add("DATE(Logged) = @LogDate");
            parameters.Add("LogDate", logDate.Value.ToString("yyyy-MM-dd"));
        }

        string whereClause = conditions.Count > 0 ? "WHERE " + string.Join(" AND ", conditions) : "";

        string sql = $@"
            SELECT Id, MachineName, Logged, Level, Message, Logger, Callsite, Exception, VerboseInfo, Url, Action 
            FROM AppLogs
            {whereClause}
            ORDER BY Logged DESC
            LIMIT @PageSize OFFSET @Offset;";

        try
        {
            var logs = await _dbFactory.QueryAsync<AppLogItemDto>(sql, parameters, commandType: CommandType.Text);
            return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(logs));
        }
        catch (Exception ex)
        {
            _loggerFactory.CreateLogger<LogsController>().LogWarning(ex, "MySQL AppLogs query fallback to SQL Server syntax");

            var sqlServerParams = new DynamicParameters();
            sqlServerParams.Add("PageSize", pageSize);
            sqlServerParams.Add("Offset", offset);

            var sqlServerConditions = new List<string>();
            if (!string.IsNullOrWhiteSpace(level) && !level.Equals("ALL", StringComparison.OrdinalIgnoreCase))
            {
                sqlServerConditions.Add("Level = @Level");
                sqlServerParams.Add("Level", level.Trim());
            }

            if (!string.IsNullOrWhiteSpace(logger))
            {
                sqlServerConditions.Add("Logger LIKE @Logger");
                sqlServerParams.Add("Logger", $"%{logger.Trim()}%");
            }

            if (!string.IsNullOrWhiteSpace(search))
            {
                sqlServerConditions.Add("(Message LIKE @Search OR Exception LIKE @Search OR Url LIKE @Search)");
                sqlServerParams.Add("Search", $"%{search.Trim()}%");
            }

            if (logDate.HasValue)
            {
                sqlServerConditions.Add("CAST(Logged AS DATE) = @LogDate");
                sqlServerParams.Add("LogDate", logDate.Value.ToString("yyyy-MM-dd"));
            }

            string sqlServerWhere = sqlServerConditions.Count > 0 ? "WHERE " + string.Join(" AND ", sqlServerConditions) : "";

            string sqlServer = $@"
                SELECT Id, MachineName, Logged, Level, Message, Logger, Callsite, Exception, VerboseInfo, Url, Action 
                FROM dbo.AppLogs
                {sqlServerWhere}
                ORDER BY Logged DESC
                OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;";

            var logs = await _dbFactory.QueryAsync<AppLogItemDto>(sqlServer, sqlServerParams, commandType: CommandType.Text);
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
