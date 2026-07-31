using System;
using System.Collections.Generic;

namespace AntiGravity.Enterprise.Shared.Core.Models.DQMS
{
    public class DashboardSummaryDto
    {
        public int WaitingCustomers { get; set; }
        public int CurrentlyServing { get; set; }
        public int SlaBreachesToday { get; set; }
        public int AvgWaitTimeMins { get; set; }
        public int AvgServiceTimeMins { get; set; }
        public int CompletedToday { get; set; }
        public int ActiveCounters { get; set; }
        public int TotalCounters { get; set; }
        public string WaitingTrend { get; set; } = "+4.2% vs yesterday";
        
        public List<CounterStatusItemDto> CounterMatrix { get; set; } = new();
        public List<TatProcessAnalyticsDto> ProcessAnalytics { get; set; } = new();
        public List<QueueTrendPointDto> QueueTrend { get; set; } = new();
        public List<RecentActivityItemDto> RecentActivities { get; set; } = new();
        public List<BottleneckItemDto> Bottlenecks { get; set; } = new();
    }

    public class CounterStatusItemDto
    {
        public int CounterId { get; set; }
        public string CounterNumber { get; set; } = string.Empty;
        public string CounterName { get; set; } = string.Empty;
        public string ProcessName { get; set; } = string.Empty;
        public string OperatorName { get; set; } = string.Empty;
        public string Status { get; set; } = "Active";
        public string? CurrentTokenNumber { get; set; }
        public int ActiveSeconds { get; set; }
    }

    public class TatProcessAnalyticsDto
    {
        public int ProcessId { get; set; }
        public string ProcessCode { get; set; } = string.Empty;
        public string ProcessName { get; set; } = string.Empty;
        public int TargetSlaMins { get; set; }
        public int ActualAvgWaitMins { get; set; }
        public int ActualAvgServiceMins { get; set; }
        public int TotalVolume { get; set; }
        public int SlaBreaches { get; set; }
    }

    public class QueueTrendPointDto
    {
        public string Hour { get; set; } = string.Empty;
        public int WaitingCount { get; set; }
        public int ServedCount { get; set; }
        public int CapacityLimit { get; set; }
    }

    public class RecentActivityItemDto
    {
        public string ActivityId { get; set; } = string.Empty;
        public DateTime Timestamp { get; set; }
        public string ActivityType { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string OperatorCode { get; set; } = string.Empty;
        public string CounterNumber { get; set; } = string.Empty;
    }

    public class BottleneckItemDto
    {
        public string BottleneckId { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Severity { get; set; } = "Warning";
        public string ImpactDescription { get; set; } = string.Empty;
        public string RecommendedAction { get; set; } = string.Empty;
    }
}
