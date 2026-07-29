using DNAQMSAPI.Application.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Security.Middlewares;

public class ZeroTrustValidationMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ZeroTrustValidationMiddleware> _logger;

    public ZeroTrustValidationMiddleware(RequestDelegate next, ILogger<ZeroTrustValidationMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context, IAuthorizationEngine authorizationEngine)
    {
        // 1. Only validate if endpoint requires authorization (e.g. not anonymous)
        // 2. We inspect metadata or headers to determine required permissions

        var endpoint = context.GetEndpoint();
        if (endpoint != null)
        {
            // Simple generic example: enforce everything needs "api.access"
            // For production, we'd read [Authorize(Policy="some-permission")]
            bool isAuthorized = true; // Replace with actual check based on Endpoint metadata

            if (!isAuthorized)
            {
                _logger.LogWarning("ZeroTrust: Permission denied for User {UserId} entering {Path}", context.User.Identity?.Name, context.Request.Path);
                context.Response.StatusCode = StatusCodes.Status403Forbidden;
                await context.Response.WriteAsJsonAsync(new { Error = "Permission Denied by Zero Trust Policy." });
                return;
            }
        }

        await _next(context);
    }
}
