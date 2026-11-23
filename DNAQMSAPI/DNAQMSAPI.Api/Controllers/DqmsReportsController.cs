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
        /// Supports POST and GET at /api/v1/dqms/reports/summary and /api/v1/reports/summary
        /// </summary>
        [HttpPost("summary")]
        [HttpGet("summary")]
        [HttpGet("/api/v1/reports/summary")]
        [HttpPost("/api/v1/reports/summary")]
        public async Task<IActionResult> GetExecutiveReportSummary([FromBody] DqmsReportRequestDto? request, [FromQuery] int? organizationId, [FromQuery] int? locationId)
        {
            var dto = request ?? new DqmsReportRequestDto
            {
                OrganizationId = organizationId ?? 1,
                LocationId = locationId ?? 1
            };
            var result = await _reportsService.GetExecutiveReportSummaryAsync(dto);
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

        /// <summary>
        /// Retrieves Turnaround Time (TAT) variance analysis and statistical dispersion metrics.
        /// GET /api/v1/dqms/reports/tat-variance or POST /api/v1/dqms/reports/tat-variance
        /// </summary>
        [HttpPost("tat-variance")]
        [HttpGet("tat-variance")]
        [HttpGet("/api/v1/dqms/analytics/tat-variance")]
        public async Task<IActionResult> GetTatVarianceReport(
            [FromBody] DqmsTatVarianceFilterDto? filter,
            [FromQuery] int? organizationId,
            [FromQuery] int? locationId,
            [FromQuery] int? processId,
            [FromQuery] int? areaId)
        {
            var dto = filter ?? new DqmsTatVarianceFilterDto
            {
                OrganizationId = organizationId ?? 1,
                LocationId = locationId ?? 1,
                ProcessId = processId,
                AreaId = areaId
            };
            var result = await _reportsService.GetTatVarianceReportAsync(dto);
            return ApiResponse(result);
        }

        /// <summary>
        /// Retrieves 2D matrix Bottleneck Heatmap across time-of-day and operational dimensions.
        /// GET /api/v1/dqms/reports/bottleneck-heatmap or POST /api/v1/dqms/reports/bottleneck-heatmap
        /// </summary>
        [HttpPost("bottleneck-heatmap")]
        [HttpGet("bottleneck-heatmap")]
        [HttpGet("/api/v1/dqms/analytics/bottleneck-heatmap")]
        public async Task<IActionResult> GetBottleneckHeatmap(
            [FromBody] DqmsHeatmapFilterDto? filter,
            [FromQuery] int? organizationId,
            [FromQuery] int? locationId,
            [FromQuery] string? dimensionType,
            [FromQuery] int? areaId)
        {
            var dto = filter ?? new DqmsHeatmapFilterDto
            {
                OrganizationId = organizationId ?? 1,
                LocationId = locationId ?? 1,
                DimensionType = dimensionType ?? "HourByDayOfWeek",
                AreaId = areaId
            };
            var result = await _reportsService.GetBottleneckHeatmapAsync(dto);
            return ApiResponse(result);
        }
    }
}
