using System;

namespace AntiGravity.Enterprise.Shared.Core.Models.DQMS
{
    public class DisplayBoardItemModel
    {
        public int Id { get; set; }
        public string TokenNumber { get; set; } = string.Empty;
        public int ProcessId { get; set; }
        public string ProcessName { get; set; } = string.Empty;
        public string Prefix { get; set; } = "A";
        public int? CounterId { get; set; }
        public string? CounterNumber { get; set; }
        public string? CounterName { get; set; }
        public int TokenStatus { get; set; }
        public DateTime? CalledTime { get; set; }
        public bool FlashAlert { get; set; } = false;
    }

    public class PublicTokenStatusModel
    {
        public int Id { get; set; }
        public string TokenNumber { get; set; } = string.Empty;
        public string ProcessName { get; set; } = string.Empty;
        public int TokenStatus { get; set; }
        public int CustomersAhead { get; set; } = 0;
        public int EstimatedWaitMinutes { get; set; } = 0;
        public string? CounterNumber { get; set; }
        public string? CounterName { get; set; }
    }
}
