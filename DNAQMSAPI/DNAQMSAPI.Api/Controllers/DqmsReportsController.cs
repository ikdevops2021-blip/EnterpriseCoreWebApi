using System;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using DNAQMSAPI.Infrastructure.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers
{
    [ApiController]
    [Route("api/v1/dqms/reports")]
    [AllowAnonymous]
    public class DqmsReportsController : ApiControllerBase
    {
        private readonly IDqmsReportsService _reportsService;

        public DqmsReportsController(IDqmsReportsService reportsService)
        {
            _reportsService = reportsService;
        }

        /// <summary>
        /// Retrieves executive performance and queue SLA report breakdown.
        /// POST /api/v1/dqms/reports/summary
        /// </summary>
        [HttpPost("summary")]
        public async Task<IActionResult> GetExecutiveReportSummary([FromBody] DqmsReportRequestDto request)
        {
            var result = await _reportsService.GetExecutiveReportSummaryAsync(request ?? new DqmsReportRequestDto());
            return ApiResponse(result);
        }

        /// <summary>
        /// Exports queue transaction records & audit trail to CSV file download.
        /// POST /api/v1/dqms/reports/export/csv
        /// </summary>
        [HttpPost("export/csv")]
        public async Task<IActionResult> ExportQueueDataCsv([FromBody] DqmsReportRequestDto request)
        {
            var bytes = await _reportsService.ExportQueueDataCsvAsync(request ?? new DqmsReportRequestDto());
            return File(bytes, "text/csv", $"dqms_queue_analytics_{DateTime.UtcNow:yyyyMMdd_HHmmss}.csv");
        }
    }
}
