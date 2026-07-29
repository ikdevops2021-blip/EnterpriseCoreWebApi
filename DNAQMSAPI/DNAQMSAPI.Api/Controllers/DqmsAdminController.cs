using AntiGravity.Enterprise.Shared.Core.Enums;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using DNAQMSAPI.Infrastructure.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers
{
    [ApiController]
    [Route("api/v1/admin")]
    public class DqmsAdminController : ControllerBase
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
            return Ok(new { success = true, data = areas });
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
                return BadRequest(new { success = false, errorCode = errNo, message = errMsg });
            }
            return Ok(new { success = true, areaId = id, message = "Area saved successfully" });
        }

        /// <summary>
        /// Gets Process pipelines by Organization using e_ActiveSearchStatus.
        /// </summary>
        [HttpGet("processes")]
        public async Task<IActionResult> GetProcesses([FromQuery] int? id, [FromQuery] int? organizationId, [FromQuery] e_ActiveSearchStatus isActive = e_ActiveSearchStatus.Active)
        {
            var processes = await _adminRepository.GetProcessesAsync(id, organizationId, isActive);
            return Ok(new { success = true, data = processes });
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
                return BadRequest(new { success = false, errorCode = errNo, message = errMsg });
            }
            return Ok(new { success = true, processId = id, message = "Process saved successfully" });
        }
    }
}
