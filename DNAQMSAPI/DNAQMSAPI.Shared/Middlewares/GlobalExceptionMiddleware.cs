using System.Net;
using System.Text.Json;
using AntiGravity.Enterprise.Shared.Core.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Shared.Middlewares;

public class GlobalExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalExceptionMiddleware> _logger;

    public GlobalExceptionMiddleware(RequestDelegate next, ILogger<GlobalExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An unhandled exception occurred while processing request {Path}", context.Request.Path);
            await HandleExceptionAsync(context, ex);
        }
    }

    private static Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/json";
        
        // Define default error code
        var statusCode = HttpStatusCode.InternalServerError;
        var message = "An internal server error occurred.";

        // Special handling for known exception types (e.g. UnauthorizedAccessException)
        if (exception is UnauthorizedAccessException)
        {
            statusCode = HttpStatusCode.Unauthorized;
            message = "Unauthorized access.";
        }
        else if (exception is ArgumentException || exception is ArgumentNullException)
        {
            statusCode = HttpStatusCode.BadRequest;
            message = "Invalid request arguments.";
        }

        context.Response.StatusCode = (int)statusCode;
        
        var response = ApiResponse<object>.Fail(message, new List<string> { exception.Message });
        return context.Response.WriteAsync(JsonSerializer.Serialize(response));
    }
}
