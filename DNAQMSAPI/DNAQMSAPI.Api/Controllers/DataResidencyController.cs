using System;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using DNAQMSAPI.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers;

[ApiController]
[Route("api/v1/dqms/residency")]
[AllowAnonymous]
public class DataResidencyController : ApiControllerBase
{
    private readonly IDataPrivacyService _privacyService;

    public DataResidencyController(IDataPrivacyService privacyService)
    {
        _privacyService = privacyService ?? throw new ArgumentNullException(nameof(privacyService));
    }

    /// <summary>
    /// Gets the current data residency and sovereignty configuration for an organization.
    /// </summary>
    [HttpGet("config")]
    public async Task<IActionResult> GetConfig([FromQuery] int organizationId = 1)
    {
        var config = await _privacyService.GetResidencyConfigAsync(organizationId);
        if (config == null)
        {
            // Default response if not yet explicitly saved
            config = new OrganizationDataResidencyDto
            {
                OrganizationId = organizationId,
                DataRegion = "eu-central-1",
                Jurisdiction = "GDPR",
                DataRetentionDays = 90,
                AutoAnonymizeOnComplete = false,
                EnableBlindIndexing = true,
                AllowCrossBorderDiagnostics = false,
                CreatedDate = DateTime.UtcNow,
                ModifiedDate = DateTime.UtcNow
            };
        }

        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(config, "Data residency configuration retrieved."));
    }

    /// <summary>
    /// Upserts (creates or updates) data residency and retention configuration for an organization.
    /// </summary>
    [HttpPost("config")]
    public async Task<IActionResult> SaveConfig([FromBody] UpsertDataResidencyRequest request)
    {
        if (request == null || request.OrganizationId <= 0)
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Valid OrganizationId is required."));
        }

        if (string.IsNullOrWhiteSpace(request.DataRegion))
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("DataRegion is required."));
        }

        var residencyId = await _privacyService.UpsertResidencyConfigAsync(request);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new { Id = residencyId, request.OrganizationId, request.DataRegion }, "Data residency configuration saved successfully."));
    }

    /// <summary>
    /// Manually triggers an expired data retention purge for an organization.
    /// </summary>
    [HttpPost("purge")]
    public async Task<IActionResult> TriggerPurge([FromBody] TriggerRetentionPurgeRequest request)
    {
        if (request == null || request.OrganizationId <= 0)
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Valid OrganizationId is required."));
        }

        var result = await _privacyService.RunRetentionPurgeAsync(request.OrganizationId);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(result, result.Message));
    }

    /// <summary>
    /// Queries the sovereign audit log records for an organization.
    /// </summary>
    [HttpGet("audit")]
    public async Task<IActionResult> GetAuditLogs(
        [FromQuery] int organizationId = 1,
        [FromQuery] int pageSize = 50,
        [FromQuery] int pageIndex = 1)
    {
        var logs = await _privacyService.GetAuditLogsAsync(organizationId, pageSize, pageIndex);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(logs, "GDPR and residency audit logs retrieved."));
    }
}
