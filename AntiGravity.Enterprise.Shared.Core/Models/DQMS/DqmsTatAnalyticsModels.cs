using System;
using System.Collections.Generic;

namespace AntiGravity.Enterprise.Shared.Core.Models.DQMS
{
    /// <summary>
    /// Filter parameters for TAT Variance analytics queries.
    /// </summary>
    public class DqmsTatVarianceFilterDto
    {
        public int OrganizationId { get; set; } = 1;
        public int LocationId { get; set; } = 1;
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public int? AreaId { get; set; }
        public int? ProcessId { get; set; }
    }

    /// <summary>
    /// Executive summary of queue Turnaround Time (TAT) variance and dispersion metrics.
    /// </summary>
    public class DqmsTatVarianceSummaryDto
    {
        public int TotalTokens { get; set; }
        public int CompletedTokens { get; set; }
        public double AverageWaitMinutes { get; set; }
        public double AverageServiceMinutes { get; set; }
        public double AverageTatMinutes { get; set; }
        public double TargetTatMinutes { get; set; }
        public double VariancePercentage { get; set; }
        public double StdDevMinutes { get; set; }
        public double CoefficientOfVariation { get; set; }
        public double P95TatMinutes { get; set; }
        public double SlaPassPercentage { get; set; }
        public string StatusTier { get; set; } = "OPTIMAL"; // OPTIMAL, ACCEPTABLE, CONGESTED, CRITICAL
    }

    /// <summary>
    /// Per-process breakdown of Turnaround Time (TAT) and variance against SLA.
    /// </summary>
    public class DqmsProcessTatVarianceDto
    {
        public int ProcessId { get; set; }
        public string ProcessName { get; set; } = string.Empty;
        public string ProcessCode { get; set; } = string.Empty;
        public int TargetTATMinutes { get; set; }
        public int TotalTokens { get; set; }
        public int CompletedTokens { get; set; }
        public double AvgWaitMinutes { get; set; }
        public double AvgServiceMinutes { get; set; }
        public double ActualTatMinutes { get; set; }
        public double VariancePercentage { get; set; }
        public double StdDevMinutes { get; set; }
        public double SlaPassRate { get; set; }
        public string StatusTier { get; set; } = "OPTIMAL";
    }

    /// <summary>
    /// Complete TAT Variance report payload with summary and process breakdowns.
    /// </summary>
    public class DqmsTatVarianceReportDto
    {
        public DateTime GeneratedAt { get; set; } = DateTime.UtcNow;
        public DateTime PeriodStart { get; set; }
        public DateTime PeriodEnd { get; set; }
        public DqmsTatVarianceSummaryDto Summary { get; set; } = new DqmsTatVarianceSummaryDto();
        public List<DqmsProcessTatVarianceDto> ProcessBreakdown { get; set; } = new List<DqmsProcessTatVarianceDto>();
    }

    /// <summary>
    /// Filter parameters for 2D Bottleneck Heatmap analytics queries.
    /// </summary>
    public class DqmsHeatmapFilterDto
    {
        public int OrganizationId { get; set; } = 1;
        public int LocationId { get; set; } = 1;
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string DimensionType { get; set; } = "HourByDayOfWeek"; // HourByDayOfWeek, HourByProcess, HourByCounter
        public int? AreaId { get; set; }
    }

    /// <summary>
    /// Individual data cell in the 2D Bottleneck Heatmap matrix.
    /// </summary>
    public class DqmsHeatmapCellDto
    {
        public int HourOfDay { get; set; }
        public int DimensionKey { get; set; }
        public string DimensionLabel { get; set; } = string.Empty;
        public int TokenCount { get; set; }
        public double AvgWaitMinutes { get; set; }
        public double AvgServiceMinutes { get; set; }
        public double AvgTatMinutes { get; set; }
        public double VariancePercentage { get; set; }
        public int CongestionScore { get; set; } // 0 to 100
        public string CongestionLevel { get; set; } = "LOW"; // LOW, MODERATE, HIGH, CRITICAL
    }

    /// <summary>
    /// Matrix payload representing complete Bottleneck Heatmap across time and operational dimensions.
    /// </summary>
    public class DqmsBottleneckHeatmapDto
    {
        public DateTime GeneratedAt { get; set; } = DateTime.UtcNow;
        public DateTime PeriodStart { get; set; }
        public DateTime PeriodEnd { get; set; }
        public string DimensionType { get; set; } = "HourByDayOfWeek";
        public List<DqmsHeatmapCellDto> Cells { get; set; } = new List<DqmsHeatmapCellDto>();
        public int PeakCongestionHour { get; set; }
        public int PeakCongestionScore { get; set; }
        public string PeakCongestionLabel { get; set; } = string.Empty;
    }
}
