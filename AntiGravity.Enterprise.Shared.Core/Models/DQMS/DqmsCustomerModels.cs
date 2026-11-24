using System;
using System.Collections.Generic;

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

    public class DisplayBoardQueueItemModel
    {
        public int Id { get; set; }
        public string TokenNumber { get; set; } = string.Empty;
        public int ProcessId { get; set; }
        public string ProcessName { get; set; } = string.Empty;
        public string Prefix { get; set; } = "A";
        public int PriorityTier { get; set; } = 19001;
        public int TokenStatus { get; set; } = 18001;
        public int? CounterId { get; set; }
        public string? CounterNumber { get; set; }
        public string? CounterName { get; set; }
        public DateTime? IssuedTime { get; set; }
        public DateTime? CalledTime { get; set; }
    }

    public class PublicDisplayBoardModel
    {
        public List<DisplayBoardItemModel> ActiveCalls { get; set; } = new();
        public List<DisplayBoardQueueItemModel> UpcomingQueue { get; set; } = new();
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
