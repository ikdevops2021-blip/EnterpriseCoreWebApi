using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using DNAQMSAPI.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers;

[ApiController]
[Route("api/v1/dqms/signage")]
[AllowAnonymous]
public class SignageController : ApiControllerBase
{
    private readonly ISignageService _signageService;

    public SignageController(ISignageService signageService)
    {
        _signageService = signageService;
    }

    /// <summary>
    /// Gets all digital signage campaigns for an organization.
    /// </summary>
    [HttpGet("campaigns")]
    public async Task<IActionResult> GetCampaigns([FromQuery] int organizationId = 1)
    {
        var campaigns = await _signageService.GetCampaignsAsync(organizationId);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(campaigns, "Campaigns retrieved successfully."));
    }

    /// <summary>
    /// Gets a single signage campaign by ID.
    /// </summary>
    [HttpGet("campaigns/{id:int}")]
    public async Task<IActionResult> GetCampaignById(int id, [FromQuery] int organizationId = 1)
    {
        var campaign = await _signageService.GetCampaignByIdAsync(id, organizationId);
        if (campaign == null)
            return NotFound(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Campaign not found."));

        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(campaign, "Campaign details retrieved."));
    }

    /// <summary>
    /// Saves (creates or updates) a signage campaign with optional media items.
    /// </summary>
    [HttpPost("campaigns")]
    public async Task<IActionResult> SaveCampaign(
        [FromBody] SaveSignageCampaignRequestDto request,
        [FromHeader(Name = "X-User-Id")] int userId = 1)
    {
        if (request == null || string.IsNullOrWhiteSpace(request.CampaignName))
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("CampaignName is required."));

        var campaignId = await _signageService.SaveCampaignAsync(request, userId);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new { Id = campaignId }, "Signage campaign saved successfully."));
    }

    /// <summary>
    /// Soft deletes a signage campaign.
    /// </summary>
    [HttpDelete("campaigns/{id:int}")]
    public async Task<IActionResult> DeleteCampaign(
        int id,
        [FromQuery] int organizationId = 1,
        [FromHeader(Name = "X-User-Id")] int userId = 1)
    {
        var success = await _signageService.DeleteCampaignAsync(id, organizationId, userId);
        if (!success)
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Failed to delete campaign."));

        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new { Id = id }, "Campaign deleted successfully."));
    }

    /// <summary>
    /// Public endpoint consumed by Waiting Room TV displays to fetch the active media playlist.
    /// </summary>
    [HttpGet("playlist")]
    public async Task<IActionResult> GetPlaylist(
        [FromQuery] int organizationId = 1,
        [FromQuery] int locationId = 1,
        [FromQuery] int? areaId = null)
    {
        var playlist = await _signageService.GetActivePlaylistAsync(organizationId, locationId, areaId);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(playlist, "Active playlist retrieved successfully."));
    }

    /// <summary>
    /// Updates the media playlist items for an existing campaign.
    /// </summary>
    [HttpPost("campaigns/{id:int}/media")]
    public async Task<IActionResult> SaveMediaItems(int id, [FromBody] List<SignageMediaItemDto> items)
    {
        var success = await _signageService.SaveMediaItemsAsync(id, items ?? new List<SignageMediaItemDto>());
        if (!success)
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Failed to update media items."));

        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new { CampaignId = id, Count = items?.Count ?? 0 }, "Media items updated successfully."));
    }
}
