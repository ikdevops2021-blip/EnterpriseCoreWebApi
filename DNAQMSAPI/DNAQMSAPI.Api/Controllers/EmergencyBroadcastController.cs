using System;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using DNAQMSAPI.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers;

[ApiController]
[Route("api/v1/dqms/emergency")]
[AllowAnonymous]
public class EmergencyBroadcastController : ApiControllerBase
{
    private readonly IEmergencyBroadcastService _emergencyService;

    public EmergencyBroadcastController(IEmergencyBroadcastService emergencyService)
    {
        _emergencyService = emergencyService;
    }

    /// <summary>
    /// Public endpoint checked by TV displays and kiosks to query the active emergency broadcast.
    /// </summary>
    [HttpGet("active")]
    public async Task<IActionResult> GetActiveBroadcast(
        [FromQuery] int organizationId = 1,
        [FromQuery] int? locationId = null,
        [FromQuery] int? areaId = null)
    {
        var broadcast = await _emergencyService.GetActiveBroadcastAsync(organizationId, locationId, areaId);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(broadcast, "Active emergency status retrieved."));
    }

    /// <summary>
    /// Triggers an emergency public broadcast across waiting room displays and public kiosks.
    /// </summary>
    [HttpPost("trigger")]
    public async Task<IActionResult> TriggerBroadcast(
        [FromBody] TriggerEmergencyBroadcastRequestDto request,
        [FromHeader(Name = "X-User-Id")] int userId = 1)
    {
        if (request == null || string.IsNullOrWhiteSpace(request.Title))
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Emergency Title and BroadcastCode are required."));

        var broadcastId = await _emergencyService.TriggerBroadcastAsync(request, userId);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new { BroadcastId = broadcastId }, "Emergency public broadcast triggered successfully."));
    }

    /// <summary>
    /// Dismisses an active emergency broadcast (ALL CLEAR) restoring normal display operation.
    /// </summary>
    [HttpPost("dismiss")]
    public async Task<IActionResult> DismissBroadcast(
        [FromBody] DismissEmergencyBroadcastRequestDto request,
        [FromHeader(Name = "X-User-Id")] int userId = 1)
    {
        if (request == null)
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request payload is required."));

        var success = await _emergencyService.DismissBroadcastAsync(request, userId);
        if (!success)
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Failed to dismiss emergency broadcast."));

        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new { Dismissed = true }, "Emergency broadcast dismissed (ALL CLEAR)."));
    }

    /// <summary>
    /// Retrieves historical emergency broadcasts for compliance auditing.
    /// </summary>
    [HttpGet("history")]
    public async Task<IActionResult> GetBroadcastHistory(
        [FromQuery] int organizationId = 1,
        [FromQuery] int? locationId = null)
    {
        var history = await _emergencyService.GetBroadcastHistoryAsync(organizationId, locationId);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(history, "Emergency broadcast history retrieved."));
    }
}
