using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using Microsoft.AspNetCore.Mvc;
using DNAQMSAPI.Application.FinancialReporting.Interfaces;

namespace DNAQMSAPI.Api.Controllers.FinancialReporting;

[ApiController]
[Route("api/v1/[controller]")]
public class FinancialReportingController : ApiControllerBase
{
    private readonly IFinancialReportingService _financialReportingService;

    public FinancialReportingController(IFinancialReportingService financialReportingService)
    {
        _financialReportingService = financialReportingService;
    }

    [HttpGet("tax-summary")]
    public async Task<IActionResult> GetMonthlyTaxSummary([FromQuery] int? year = null)
    {
        var result = await _financialReportingService.GetMonthlyTaxSummaryAsync(year);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<System.Collections.Generic.IEnumerable<DNAQMSAPI.Application.FinancialReporting.DTOs.MonthlyTaxSummaryDto>>.Ok(result));
    }

    [HttpGet("payment-analytics")]
    public async Task<IActionResult> GetPaymentAnalytics([FromQuery] int? year = null)
    {
        var result = await _financialReportingService.GetPaymentAnalyticsAsync(year);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<System.Collections.Generic.IEnumerable<DNAQMSAPI.Application.FinancialReporting.DTOs.PaymentAnalyticsDto>>.Ok(result));
    }

    [HttpGet("revenue-analytics")]
    public async Task<IActionResult> GetRevenueAnalytics([FromQuery] int? year = null)
    {
        var result = await _financialReportingService.GetRevenueAnalyticsAsync(year);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<System.Collections.Generic.IEnumerable<DNAQMSAPI.Application.FinancialReporting.DTOs.RevenueAnalyticsDto>>.Ok(result));
    }

    [HttpGet("saas-metrics")]
    public async Task<IActionResult> GetSaaSMetrics()
    {
        var result = await _financialReportingService.GetSaaSMetricsAsync();
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<System.Collections.Generic.IEnumerable<DNAQMSAPI.Application.FinancialReporting.DTOs.SaaSMetricsDto>>.Ok(result));
    }
}
