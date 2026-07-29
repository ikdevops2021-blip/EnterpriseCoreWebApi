using System.Collections.Generic;
using System.Data;
using System.Threading;
using System.Threading.Tasks;
using DNAQMSAPI.Application.FinancialReporting.DTOs;
using DNAQMSAPI.Application.FinancialReporting.Interfaces;
using DNAQMSAPI.Application.Interfaces;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Infrastructure.FinancialReporting.Services;

public class FinancialReportingService : IFinancialReportingService
{
    private readonly IDapperDBFactory _dbFactory;
    private readonly ILogger<FinancialReportingService> _logger;

    public FinancialReportingService(IDapperDBFactory dbFactory, ILogger<FinancialReportingService> logger)
    {
        _dbFactory = dbFactory;
        _logger = logger;
    }

    public async Task<IEnumerable<MonthlyTaxSummaryDto>> GetMonthlyTaxSummaryAsync(int? year = null, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Executing Financial Reporting: Monthly Tax Summary");
        return await _dbFactory.QueryAsync<MonthlyTaxSummaryDto>(
            "PR_S_MonthlyTaxSummary",
            new { p_Year = year ?? -1 },
            commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<PaymentAnalyticsDto>> GetPaymentAnalyticsAsync(int? year = null, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Executing Financial Reporting: Payment Analytics");
        return await _dbFactory.QueryAsync<PaymentAnalyticsDto>(
            "PR_S_PaymentAnalytics",
            new { p_Year = year ?? -1 },
            commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<RevenueAnalyticsDto>> GetRevenueAnalyticsAsync(int? year = null, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Executing Financial Reporting: Revenue Analytics");
        return await _dbFactory.QueryAsync<RevenueAnalyticsDto>(
            "PR_S_RevenueAnalytics",
            new { p_Year = year ?? -1 },
            commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<SaaSMetricsDto>> GetSaaSMetricsAsync(CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Executing Financial Reporting: SaaS Metrics");
        return await _dbFactory.QueryAsync<SaaSMetricsDto>(
            "PR_S_SaaSMetrics",
            null,
            commandType: CommandType.StoredProcedure);
    }
}

