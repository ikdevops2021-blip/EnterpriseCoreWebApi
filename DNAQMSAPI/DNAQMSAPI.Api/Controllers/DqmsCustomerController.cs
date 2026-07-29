using AntiGravity.Enterprise.Shared.Core.Controllers;
using DNAQMSAPI.Infrastructure.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers
{
    [ApiController]
    [Route("api/v1/public")]
    [AllowAnonymous] // Public endpoints for overhead TV displays and customer mobile web tracking
    public class DqmsCustomerController : ApiControllerBase
    {
        private readonly IDqmsCustomerService _customerService;

        public DqmsCustomerController(IDqmsCustomerService customerService)
        {
            _customerService = customerService;
        }

        /// <summary>
        /// Public endpoint for Overhead TV Waiting Room Display Boards.
        /// Returns now calling tokens with audio-visual flash alerts.
        /// </summary>
        [HttpGet("display-board")]
        public async Task<IActionResult> GetDisplayBoard([FromQuery] int organizationId = 1, [FromQuery] int locationId = 1, [FromQuery] int? areaId = null)
        {
            var result = await _customerService.GetPublicDisplayBoardAsync(organizationId, locationId, areaId);
            return ApiResponse(result);
        }

        /// <summary>
        /// Public endpoint for Mobile Web Ticket Status Tracking.
        /// Customers scan QR code or open link to see position ahead & estimated wait time.
        /// </summary>
        [HttpGet("ticket-status/{tokenId:int}")]
        public async Task<IActionResult> GetTicketStatus(int tokenId)
        {
            var result = await _customerService.GetPublicTokenStatusAsync(tokenId);
            return ApiResponse(result);
        }
    }
}
