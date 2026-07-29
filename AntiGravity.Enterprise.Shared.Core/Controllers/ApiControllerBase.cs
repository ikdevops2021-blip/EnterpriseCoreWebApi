using System;
using AntiGravity.Enterprise.Shared.Core.Models;
using Microsoft.AspNetCore.Mvc;

namespace AntiGravity.Enterprise.Shared.Core.Controllers;

[ApiController]
[Route("api/v{version:apiVersion}/[controller]")]
[Produces("application/json")]
public abstract class ApiControllerBase : ControllerBase
{
    protected RequestContext CurrentRequestContext => 
        HttpContext.Items["RequestContext"] as RequestContext ?? 
        throw new InvalidOperationException("RequestContext not found in HttpContext. Ensure RequestContextMiddleware is registered.");

    protected IActionResult ApiResponse<T>(ApiResponse<T> response)
    {
        if (response.Success)
        {
            return Ok(response);
        }

        // Simplistic mapping for now, can be expanded to return 4xx based on Error types
        return BadRequest(response);
    }

    protected IActionResult PaginatedResponse<T>(PaginatedApiResponse<T> response)
    {
        if (response.Success)
        {
            return Ok(response);
        }

        return BadRequest(response);
    }
}
