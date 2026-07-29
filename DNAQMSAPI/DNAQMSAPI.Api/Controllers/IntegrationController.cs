using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.Integration.DTOs;
using DNAQMSAPI.Application.Integration.Interfaces;
using DNAQMSAPI.Domain.Integration;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class IntegrationController : ApiControllerBase
{
    private readonly IGenericApiClient _apiClient;
    private readonly IIntegrationManagementService _integrationService;

    public IntegrationController(
        IGenericApiClient apiClient, 
        IIntegrationManagementService integrationService)
    {
        _apiClient = apiClient;
        _integrationService = integrationService;
    }

    /// <summary>
    /// Executes an outbound request to a registered Third-Party provider endpoint.
    /// </summary>
    [HttpPost("execute")]
    public async Task<IActionResult> ExecuteIntegrationAsync([FromBody] ApiRequest request)
    {
        try
        {
            request.ExecutingUserId = CurrentRequestContext?.UserId ?? 1;
            var response = await _apiClient.SendAsync<object>(request);
            return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(response, "Integration request executed successfully."));
        }
        catch (Exception ex)
        {
            return StatusCode(500, AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail($"Integration Execution Failed: {ex.Message}"));
        }
    }

    /// <summary>
    /// Retrieves registered Third-Party API Integration providers.
    /// </summary>
    [HttpGet("providers")]
    public async Task<IActionResult> GetProvidersAsync([FromQuery] int tenantId = 1)
    {
        var providers = await _integrationService.GetAllIntegrationsAsync(tenantId);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<IEnumerable<ApiIntegration>>.Ok(providers));
    }

    /// <summary>
    /// Saves or updates a Third-Party API Integration provider.
    /// </summary>
    [HttpPost("providers")]
    public async Task<IActionResult> SaveProviderAsync([FromBody] ApiIntegration integration)
    {
        integration.CreatedBy = CurrentRequestContext?.UserId ?? 1;
        var integrationId = await _integrationService.SaveIntegrationAsync(integration);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new { IntegrationID = integrationId }, "API Integration provider saved successfully."));
    }

    /// <summary>
    /// Retrieves registered endpoints for a given integration provider.
    /// </summary>
    [HttpGet("providers/{integrationId}/endpoints")]
    public async Task<IActionResult> GetEndpointsAsync(int integrationId)
    {
        var endpoints = await _integrationService.GetEndpointsByIntegrationAsync(integrationId);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<IEnumerable<ApiEndpoint>>.Ok(endpoints));
    }

    /// <summary>
    /// Saves or updates a third-party action endpoint mapping.
    /// </summary>
    [HttpPost("endpoints")]
    public async Task<IActionResult> SaveEndpointAsync([FromBody] ApiEndpoint endpoint)
    {
        endpoint.CreatedBy = CurrentRequestContext?.UserId ?? 1;
        var endpointId = await _integrationService.SaveEndpointAsync(endpoint);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new { EndpointID = endpointId }, "API Endpoint configuration saved successfully."));
    }

    /// <summary>
    /// Retrieves execution audit telemetry logs.
    /// </summary>
    [HttpGet("audit-logs")]
    public async Task<IActionResult> GetAuditLogsAsync([FromQuery] int integrationId = 0, [FromQuery] int top = 50)
    {
        var logs = await _integrationService.GetAuditLogsAsync(integrationId, top);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<IEnumerable<ApiAuditLog>>.Ok(logs));
    }
}
