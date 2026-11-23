using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using DNAQMSAPI.Infrastructure.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers
{
    [ApiController]
    [Route("api/v1/staff")]
    [AllowAnonymous] // Allow anonymous during development/testing
    public class DqmsStaffController : ApiControllerBase
    {
        private readonly IDqmsStaffService _staffService;

        public DqmsStaffController(IDqmsStaffService staffService)
        {
            _staffService = staffService;
        }

        /// <summary>
        /// Issues a new token (Kiosk / Reception).
        /// Supports both /api/v1/staff/issue-token and /api/v1/dqms/tickets
        /// </summary>
        [HttpPost("issue-token")]
        [HttpPost("/api/v1/dqms/tickets")]
        public async Task<IActionResult> IssueToken([FromBody] IssueTokenRequestDto dto, [FromHeader(Name = "X-User-Id")] int userId = 1)
        {
            var effectiveUserId = (dto?.StaffUserId > 0) ? dto.StaffUserId : (userId > 0 ? userId : 1);
            var result = await _staffService.IssueTokenAsync(dto ?? new IssueTokenRequestDto(), effectiveUserId);
            return ApiResponse(result);
        }

        /// <summary>
        /// Operator calls next token in queue (Hotkey Space / F1).
        /// </summary>
        [HttpPost("call-next")]
        public async Task<IActionResult> CallNextToken([FromBody] CallNextTokenRequestDto dto, [FromHeader(Name = "X-User-Id")] int userId = 1)
        {
            var result = await _staffService.CallNextTokenAsync(dto, userId);
            return ApiResponse(result);
        }

        /// <summary>
        /// Updates active token status (Active 18004, Hold 18005, Canceled 18006, Completed 18007, Forwarded 18008).
        /// </summary>
        [HttpPost("update-status")]
        public async Task<IActionResult> UpdateTokenStatus([FromBody] UpdateTokenStatusRequestDto dto, [FromHeader(Name = "X-User-Id")] int userId = 1)
        {
            var result = await _staffService.UpdateTokenStatusAsync(dto, userId);
            return ApiResponse(result);
        }

        /// <summary>
        /// Forwards a token along the N-level pipeline (Step N -> Step N+1, cross-process handoff, or sub-token generation).
        /// </summary>
        [HttpPost("forward-token")]
        [HttpPost("forward")]
        [HttpPost("/api/v1/dqms/tickets/forward")]
        public async Task<IActionResult> ForwardToken([FromBody] ForwardTokenRequestDto dto, [FromHeader(Name = "X-User-Id")] int userId = 1)
        {
            var effectiveUserId = (dto?.StaffUserId > 0) ? dto.StaffUserId : (userId > 0 ? userId : 1);
            var result = await _staffService.ForwardTokenAsync(dto ?? new ForwardTokenRequestDto(), effectiveUserId);
            return ApiResponse(result);
        }

        /// <summary>
        /// Retrieves the complete N-level lifecycle journey, steps, and sub-tokens for a token.
        /// </summary>
        [HttpGet("token/{tokenId}/workflow")]
        [HttpGet("/api/v1/dqms/tickets/{tokenId}/workflow")]
        public async Task<IActionResult> GetTokenWorkflow(int tokenId, [FromQuery] string? tokenNumber)
        {
            var result = await _staffService.GetTokenWorkflowHistoryAsync(tokenId, tokenNumber);
            return ApiResponse(result);
        }

        /// <summary>
        /// Retrieves the sequential step catalog for a process or all processes.
        /// </summary>
        [HttpGet("process/{processId}/steps")]
        [HttpGet("steps")]
        public async Task<IActionResult> GetProcessSteps(int? processId)
        {
            var result = await _staffService.GetProcessStepsAsync(processId);
            return ApiResponse(result);
        }

        /// <summary>
        /// Gets current active token and waiting queue list for counter station.
        /// </summary>
        [HttpGet("queue")]
        public async Task<IActionResult> GetTokenQueue([FromQuery] int organizationId = 1, [FromQuery] int locationId = 1, [FromQuery] int processId = 1, [FromQuery] int counterId = 1)
        {
            var result = await _staffService.GetTokenQueueAsync(organizationId, locationId, processId, counterId);
            return ApiResponse(result);
        }
    }
}
