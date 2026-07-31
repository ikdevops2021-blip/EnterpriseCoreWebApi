using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using DNAQMSAPI.Infrastructure.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers
{
    [ApiController]
    [Route("api/v1/dqms")]
    [AllowAnonymous] // Allow anonymous during development/testing
    public class DqmsDashboardController : ApiControllerBase
    {
        private readonly IDqmsDashboardService _dashboardService;

        public DqmsDashboardController(IDqmsDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }

        /// <summary>
        /// Gets Command Center Dashboard Summary metrics & operational feeds.
        /// GET /api/v1/dqms/dashboard
        /// </summary>
        [HttpGet("dashboard")]
        public async Task<IActionResult> GetDashboard([FromQuery] int organizationId = 1, [FromQuery] int locationId = 1, [FromQuery] int? areaId = null)
        {
            var result = await _dashboardService.GetDashboardSummaryAsync(organizationId, locationId, areaId);
            return ApiResponse(result);
        }
    }
}
