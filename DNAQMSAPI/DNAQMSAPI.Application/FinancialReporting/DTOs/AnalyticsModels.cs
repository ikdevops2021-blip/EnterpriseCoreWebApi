using System;

namespace DNAQMSAPI.Application.FinancialReporting.DTOs;

public class MonthlyTaxSummaryDto
{
    public int? TaxYear { get; set; }
    public int? TaxMonth { get; set; }
    public string? TotalTaxCollectedField { get; set; }
    public string? BaseTaxableAmount { get; set; }
    public long TotalInvoicesProcessed { get; set; }
}

public class PaymentAnalyticsDto
{
    public int? PaymentYear { get; set; }
    public int? PaymentMonth { get; set; }
    public string PaymentProvider { get; set; } = string.Empty;
    public long SuccessfulTransactions { get; set; }
    public long FailedTransactions { get; set; }
    public decimal? TotalVolumeProcessed { get; set; }
}

public class RevenueAnalyticsDto
{
    public int? RevenueYear { get; set; }
    public int? RevenueMonth { get; set; }
    public int SubscriptionPlanId { get; set; }
    public long TotalInvoices { get; set; }
    public decimal? TotalGrossRevenue { get; set; }
    public decimal? TotalTaxCollected { get; set; }
    public decimal? NetRevenue { get; set; }
}

public class SaaSMetricsDto
{
    public int? SnapshotDay { get; set; }
    public long ActiveSubscriptions { get; set; }
    public long CanceledOrExpiredSubscriptions { get; set; }
    public decimal? EstimatedMRR { get; set; }
    public decimal? EstimatedARR { get; set; }
}
