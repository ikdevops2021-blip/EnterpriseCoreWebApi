using AntiGravity.Enterprise.Shared.Core.Models;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace DNAQMSAPI.Security.Middlewares;

public class RequestContextMiddleware
{
    private readonly RequestDelegate _next;

    public RequestContextMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context, RequestContext requestContext)
    {
        requestContext.IpAddress = context.Connection.RemoteIpAddress?.ToString() ?? string.Empty;
        requestContext.UserAgent = context.Request.Headers["User-Agent"].ToString();
        
        // Extract from headers
        if (context.Request.Headers.TryGetValue("X-Organization-Id", out var organizationIdSpan))
        {
            if (int.TryParse(organizationIdSpan.ToString(), out int organizationId))
            {
                requestContext.CurrentOrganizationId = organizationId;
            }
        }

        if (context.Request.Headers.TryGetValue("X-Center-Id", out var centerIdSpan))
        {
            if (int.TryParse(centerIdSpan.ToString(), out int centerId))
            {
                requestContext.CurrentCenterId = centerId;
            }
        }

        // If authenticated via JWT/ApiKey, extract User Context
        if (context.User.Identity?.IsAuthenticated == true)
        {
            var userIdStr = context.User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (int.TryParse(userIdStr, out int userId))
            {
                requestContext.UserId = userId;
            }

            requestContext.Roles = context.User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();
            requestContext.Permissions = context.User.FindAll("Permission").Select(c => c.Value).ToList();
        }

        await _next(context);
    }
}
