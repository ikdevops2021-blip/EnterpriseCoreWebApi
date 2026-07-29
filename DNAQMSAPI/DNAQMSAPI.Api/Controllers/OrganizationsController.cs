using AntiGravity.Enterprise.Shared.Core.Controllers;
using DNAQMSAPI.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers;

[Authorize(AuthenticationSchemes = "BearerOrApiKey,Bearer,ApiKey")]
public class OrganizationsController : ApiControllerBase
{
    private readonly IOrganizationService _organizationService;

    public OrganizationsController(IOrganizationService organizationService)
    {
        _organizationService = organizationService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAllOrganizations()
    {
        // Using CurrentRequestContext to restrict or log
        var result = await _organizationService.GetAllOrganizationsAsync();
        return ApiResponse(result);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetOrganizationById(Guid id)
    {
        var result = await _organizationService.GetOrganizationByIdAsync(id);
        return ApiResponse(result);
    }
}
