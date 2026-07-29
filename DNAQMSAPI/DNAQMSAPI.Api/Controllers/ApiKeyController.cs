using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Security.Middlewares;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers;

[Authorize]
public class ApiKeyController : ApiControllerBase
{
    private readonly IApiKeyService _apiKeyService;
    private readonly RequestContext _requestContext;

    public ApiKeyController(IApiKeyService apiKeyService, RequestContext requestContext)
    {
        _apiKeyService = apiKeyService;
        _requestContext = requestContext;
    }

    [HttpPost]
    public async Task<IActionResult> Generate([FromQuery] string name, [FromQuery] DateTime? expiresAt)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            return BadRequest(new { Message = "Name is required for the API Key." });
        }

        var result = await _apiKeyService.GenerateApiKeyAsync(_requestContext.UserId, name, expiresAt);
        
        var responseData = new 
        { 
            ApiKeyId = result.ApiKey.Id, 
            RawKey = result.RawKey,
            Message = "Please copy this key now. You will not be able to see it again." 
        };
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(responseData, "API Key generated successfully."));
    }

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var keys = await _apiKeyService.GetUserApiKeysAsync(_requestContext.UserId);
        
        var responseData = keys.Select(k => new 
        {
            k.Id,
            k.Name,
            k.ExpiresAt,
            k.IsActive,
            k.CreatedDate
        });

        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(responseData));
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Revoke(Guid id)
    {
        await _apiKeyService.RevokeApiKeyAsync(id, _requestContext.UserId);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new { Message = "API Key revoked successfully." }));
    }
}
