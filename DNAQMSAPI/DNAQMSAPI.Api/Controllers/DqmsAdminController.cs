using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Enums;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using DNAQMSAPI.Infrastructure.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers
{
    [ApiController]
    [Route("api/v1/admin")]
    [AllowAnonymous] // Allow anonymous during development/testing
    public class DqmsAdminController : ApiControllerBase
    {
        private readonly IDqmsAdminService _adminService;

        public DqmsAdminController(IDqmsAdminService adminService)
        {
            _adminService = adminService;
        }

        /// <summary>
        /// Gets Areas by Organization and Location using e_ActiveSearchStatus.
        /// </summary>
        [HttpGet("areas")]
        public async Task<IActionResult> GetAreas([FromQuery] int? id, [FromQuery] int? organizationId, [FromQuery] int? locationId, [FromQuery] e_ActiveSearchStatus isActive = e_ActiveSearchStatus.Active)
        {
            var result = await _adminService.GetAreasAsync(id, organizationId, locationId, isActive);
            return ApiResponse(result);
        }

        /// <summary>
        /// Creates or Updates an Area/Zone.
        /// </summary>
        [HttpPost("area")]
        public async Task<IActionResult> SaveArea([FromBody] AreaModel model, [FromHeader(Name = "X-User-Id")] int userId = 1)
        {
            var result = await _adminService.SaveAreaAsync(model, userId);
            return ApiResponse(result);
        }

        /// <summary>
        /// Gets Process pipelines by Organization using e_ActiveSearchStatus.
        /// </summary>
        [HttpGet("processes")]
        public async Task<IActionResult> GetProcesses([FromQuery] int? id, [FromQuery] int? organizationId, [FromQuery] e_ActiveSearchStatus isActive = e_ActiveSearchStatus.Active)
        {
            var result = await _adminService.GetProcessesAsync(id, organizationId, isActive);
            return ApiResponse(result);
        }

        /// <summary>
        /// Creates or Updates a Process pipeline.
        /// </summary>
        [HttpPost("process")]
        public async Task<IActionResult> SaveProcess([FromBody] ProcessModel model, [FromHeader(Name = "X-User-Id")] int userId = 1)
        {
            var result = await _adminService.SaveProcessAsync(model, userId);
            return ApiResponse(result);
        }
    }
}
