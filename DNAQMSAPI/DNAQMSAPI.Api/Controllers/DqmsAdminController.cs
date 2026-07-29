using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Enums;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using DNAQMSAPI.Infrastructure.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers
{
    [Authorize(AuthenticationSchemes = "BearerOrApiKey,Bearer,ApiKey")]
    public class DqmsAdminController : ApiControllerBase
    {
        private readonly IDqmsAdminRepository _adminRepository;

        public DqmsAdminController(IDqmsAdminRepository adminRepository)
        {
            _adminRepository = adminRepository;
        }

        /// <summary>
        /// Gets Areas by Organization and Location using e_ActiveSearchStatus.
        /// </summary>
        [HttpGet("areas")]
        public async Task<IActionResult> GetAreas([FromQuery] int? id, [FromQuery] int? organizationId, [FromQuery] int? locationId, [FromQuery] e_ActiveSearchStatus isActive = e_ActiveSearchStatus.Active)
        {
            var areas = await _adminRepository.GetAreasAsync(id, organizationId, locationId, isActive);
            return ApiResponse(areas);
        }

        /// <summary>
        /// Creates or Updates an Area/Zone.
        /// </summary>
        [HttpPost("area")]
        public async Task<IActionResult> SaveArea([FromBody] AreaModel model, [FromHeader(Name = "X-User-Id")] int userId = 1)
        {
            var (id, errNo, errMsg) = await _adminRepository.SaveAreaAsync(model, userId);
            if (errNo != 0)
            {
                return ApiResponse<object>(null!, errMsg, isSuccess: false);
            }
            return ApiResponse(new { areaId = id }, "Area saved successfully");
        }

        /// <summary>
        /// Gets Process pipelines by Organization using e_ActiveSearchStatus.
        /// </summary>
        [HttpGet("processes")]
        public async Task<IActionResult> GetProcesses([FromQuery] int? id, [FromQuery] int? organizationId, [FromQuery] e_ActiveSearchStatus isActive = e_ActiveSearchStatus.Active)
        {
            var processes = await _adminRepository.GetProcessesAsync(id, organizationId, isActive);
            return ApiResponse(processes);
        }

        /// <summary>
        /// Creates or Updates a Process pipeline.
        /// </summary>
        [HttpPost("process")]
        public async Task<IActionResult> SaveProcess([FromBody] ProcessModel model, [FromHeader(Name = "X-User-Id")] int userId = 1)
        {
            var (id, errNo, errMsg) = await _adminRepository.SaveProcessAsync(model, userId);
            if (errNo != 0)
            {
                return ApiResponse<object>(null!, errMsg, isSuccess: false);
            }
            return ApiResponse(new { processId = id }, "Process saved successfully");
        }
    }
}
