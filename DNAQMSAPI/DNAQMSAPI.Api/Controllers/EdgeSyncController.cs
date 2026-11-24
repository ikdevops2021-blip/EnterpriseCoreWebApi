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
[Route("api/v1/dqms/edge")]
[AllowAnonymous]
public class EdgeSyncController : ApiControllerBase
{
    private readonly IEdgeSyncService _edgeSyncService;

    public EdgeSyncController(IEdgeSyncService edgeSyncService)
    {
        _edgeSyncService = edgeSyncService;
    }

    /// <summary>
    /// Gets all registered Edge Appliances for an organization or location.
    /// </summary>
    [HttpGet("nodes")]
    public async Task<IActionResult> GetNodes(
        [FromQuery] int organizationId = 1,
        [FromQuery] int locationId = -1,
        [FromQuery] string? nodeId = null)
    {
        var nodes = await _edgeSyncService.GetNodesAsync(organizationId, locationId, nodeId);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(nodes, "Edge nodes retrieved successfully."));
    }

    /// <summary>
    /// Registers or updates a local branch Edge Appliance node.
    /// </summary>
    [HttpPost("register")]
    public async Task<IActionResult> RegisterNode(
        [FromBody] RegisterEdgeNodeRequestDto request,
        [FromHeader(Name = "X-User-Id")] int userId = 1)
    {
        if (request == null || string.IsNullOrWhiteSpace(request.NodeId))
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Valid NodeId and registration data are required."));
        }

        var nodeId = await _edgeSyncService.RegisterOrUpdateNodeAsync(request, userId);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new { Id = nodeId, request.NodeId }, "Edge node registered successfully."));
    }

    /// <summary>
    /// Receives periodic heartbeat from an Edge Appliance to track online status and journal backlog.
    /// </summary>
    [HttpPost("heartbeat")]
    public async Task<IActionResult> Heartbeat([FromBody] EdgeHeartbeatRequestDto request)
    {
        if (request == null || string.IsNullOrWhiteSpace(request.NodeId))
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("NodeId is required."));
        }

        var response = await _edgeSyncService.ProcessHeartbeatAsync(request);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(response, response.Message));
    }

    /// <summary>
    /// Ingests an offline transaction delta batch from an Edge Appliance with conflict resolution.
    /// </summary>
    [HttpPost("sync")]
    public async Task<IActionResult> SyncBatch(
        [FromBody] EdgeSyncBatchDto batch,
        [FromHeader(Name = "X-User-Id")] int userId = 1)
    {
        if (batch == null || string.IsNullOrWhiteSpace(batch.NodeId) || batch.Items == null)
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Valid batch payload with items is required."));
        }

        var result = await _edgeSyncService.ProcessSyncBatchAsync(batch, userId);
        if (result.Status == "Failed")
        {
            return StatusCode(500, AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail(result.ErrorMessage ?? "Batch sync execution failed."));
        }

        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(result, "Edge batch synced successfully."));
    }

    /// <summary>
    /// Queries the Edge Sync Audit Logs.
    /// </summary>
    [HttpGet("logs")]
    public async Task<IActionResult> GetAuditLogs(
        [FromQuery] int organizationId = 1,
        [FromQuery] string? nodeId = null,
        [FromQuery] int limit = 50)
    {
        var logs = await _edgeSyncService.GetSyncAuditLogsAsync(organizationId, nodeId, limit);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(logs, "Edge sync audit logs retrieved successfully."));
    }
}
