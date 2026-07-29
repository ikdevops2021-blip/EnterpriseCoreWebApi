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
        /// </summary>
        [HttpPost("issue-token")]
        public async Task<IActionResult> IssueToken([FromBody] IssueTokenRequestDto dto, [FromHeader(Name = "X-User-Id")] int userId = 1)
        {
            var result = await _staffService.IssueTokenAsync(dto, userId);
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
