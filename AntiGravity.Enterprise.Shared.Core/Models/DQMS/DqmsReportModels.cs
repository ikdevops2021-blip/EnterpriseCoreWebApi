using System;
using System.Collections.Generic;

namespace AntiGravity.Enterprise.Shared.Core.Models.DQMS
{
    /// <summary>
    /// Request parameters for generating DQMS queue analytics and audit reports.
    /// </summary>
    public class DqmsReportRequestDto
    {
        public int OrganizationId { get; set; } = 1;
        public int LocationId { get; set; } = 1;
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public int? AreaId { get; set; }
        public int? ProcessId { get; set; }
        public int? CounterId { get; set; }
        public string Format { get; set; } = "CSV"; // CSV, PDF, JSON
    }

    /// <summary>
    /// Executive summary response for executive performance and SLA reports.
    /// </summary>
    public class DqmsExecutiveReportSummaryDto
    {
        public DateTime GeneratedAt { get; set; } = DateTime.UtcNow;
        public DateTime PeriodStart { get; set; }
        public DateTime PeriodEnd { get; set; }
        public int TotalTokensIssued { get; set; }
        public int TotalTokensCompleted { get; set; }
        public int TotalTokensCanceled { get; set; }
        public int TotalTokensNoShow { get; set; }
        public double AverageWaitTimeMinutes { get; set; }
        public double AverageServiceTimeMinutes { get; set; }
        public double SlaCompliancePercentage { get; set; }
        public List<DqmsProcessPerformanceSummaryDto> ProcessBreakdown { get; set; } = new List<DqmsProcessPerformanceSummaryDto>();
        public List<DqmsCounterUtilizationSummaryDto> CounterUtilization { get; set; } = new List<DqmsCounterUtilizationSummaryDto>();
    }

    /// <summary>
    /// Per-process queue metrics summary.
    /// </summary>
    public class DqmsProcessPerformanceSummaryDto
    {
        public int ProcessId { get; set; }
        public string ProcessCode { get; set; } = string.Empty;
        public string ProcessName { get; set; } = string.Empty;
        public int TotalTokens { get; set; }
        public int CompletedTokens { get; set; }
        public double AvgWaitMinutes { get; set; }
        public double AvgServiceMinutes { get; set; }
        public double SlaPassRate { get; set; }
    }

    /// <summary>
    /// Per-counter performance & operator utilization breakdown.
    /// </summary>
    public class DqmsCounterUtilizationSummaryDto
    {
        public int CounterId { get; set; }
        public string CounterNumber { get; set; } = string.Empty;
        public string OperatorName { get; set; } = string.Empty;
        public int TokensServed { get; set; }
        public double TotalActiveHours { get; set; }
        public double AverageTransactionTimeMinutes { get; set; }
    }
}
