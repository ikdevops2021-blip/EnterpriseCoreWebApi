using System;
using AntiGravity.Enterprise.Shared.Core.Enums;

namespace AntiGravity.Enterprise.Shared.Core.Models.DQMS
{
    public class TokenTransactionModel
    {
        public int Id { get; set; }
        public string TokenNumber { get; set; } = string.Empty;
        public int OrganizationId { get; set; }
        public int LocationId { get; set; }
        public int AreaId { get; set; }
        public int ProcessId { get; set; }
        public int? CounterId { get; set; }
        public int? UserId { get; set; }
        public int PriorityTier { get; set; } = (int)e_PriorityTier.Standard; // 19001
        public int TokenStatus { get; set; } = (int)e_TokenStatus.Queued; // 18001
        public int QueuePosition { get; set; } = 1;
        public string? CustomerName { get; set; }
        public string? CustomerPhone { get; set; }
        public string? Notes { get; set; }
        public DateTime IssuedTime { get; set; }
        public DateTime? CalledTime { get; set; }
        public DateTime? ServedTime { get; set; }
        public DateTime? CompletedTime { get; set; }
    }

    public class IssueTokenRequestDto
    {
        public int OrganizationId { get; set; } = 1;
        public int LocationId { get; set; } = 1;
        public int AreaId { get; set; } = 1;
        public int ProcessId { get; set; } = 1;
        public int PriorityTier { get; set; } = 19001; // e_PriorityTier.Standard
        public string? CustomerName { get; set; }
        public string? CustomerPhone { get; set; }
    }

    public class CallNextTokenRequestDto
    {
        public int OrganizationId { get; set; } = 1;
        public int LocationId { get; set; } = 1;
        public int CounterId { get; set; } = 1;
        public int ProcessId { get; set; } = 1;
    }

    public class UpdateTokenStatusRequestDto
    {
        public int TokenId { get; set; }
        public int NewStatus { get; set; } // e_TokenStatus value
        public string? Reason { get; set; }
    }
}
