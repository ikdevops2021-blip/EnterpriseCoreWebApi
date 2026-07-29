using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using DNAQMSAPI.Application.FinancialReporting.DTOs;

namespace DNAQMSAPI.Application.FinancialReporting.Interfaces;

public interface IFinancialReportingService
{
    Task<IEnumerable<MonthlyTaxSummaryDto>> GetMonthlyTaxSummaryAsync(int? year = null, CancellationToken cancellationToken = default);
    Task<IEnumerable<PaymentAnalyticsDto>> GetPaymentAnalyticsAsync(int? year = null, CancellationToken cancellationToken = default);
    Task<IEnumerable<RevenueAnalyticsDto>> GetRevenueAnalyticsAsync(int? year = null, CancellationToken cancellationToken = default);
    Task<IEnumerable<SaaSMetricsDto>> GetSaaSMetricsAsync(CancellationToken cancellationToken = default);
}
