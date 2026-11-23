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
        public int? ParentTokenId { get; set; }
        public int StepOrder { get; set; } = 1;
        public int SubTokenSequence { get; set; } = 0;
        public string? CustomerName { get; set; }
        public string? CustomerPhone { get; set; }
        public string? Notes { get; set; }
        public DateTime IssuedTime { get; set; }
        public DateTime? CalledTime { get; set; }
        public DateTime? ServedTime { get; set; }
        public DateTime? CompletedTime { get; set; }
    }

    public class ForwardTokenRequestDto
    {
        public int TokenId { get; set; }
        public int? TargetProcessId { get; set; }
        public int? TargetCounterId { get; set; }
        public bool IsSubToken { get; set; } = false;
        public string? Reason { get; set; }
        public int StaffUserId { get; set; } = 1;
    }

    public class ProcessStepDto
    {
        public int Id { get; set; }
        public int ProcessId { get; set; }
        public string ProcessName { get; set; } = string.Empty;
        public string ProcessCode { get; set; } = string.Empty;
        public int StepOrder { get; set; }
        public string StepName { get; set; } = string.Empty;
        public int TargetTATMinutes { get; set; } = 10;
        public bool IsActive { get; set; } = true;
    }

    public class TokenWorkflowStepDto
    {
        public int TransactionId { get; set; }
        public string TokenNumber { get; set; } = string.Empty;
        public int StepOrder { get; set; }
        public string StepName { get; set; } = string.Empty;
        public int TargetTATMinutes { get; set; } = 10;
        public int ProcessId { get; set; }
        public string ProcessName { get; set; } = string.Empty;
        public int? CounterId { get; set; }
        public string? CounterNumber { get; set; }
        public string? CounterName { get; set; }
        public int TokenStatus { get; set; }
        public string StatusName { get; set; } = string.Empty;
        public DateTime IssuedTime { get; set; }
        public DateTime? CalledTime { get; set; }
        public DateTime? ServedTime { get; set; }
        public DateTime? CompletedTime { get; set; }
        public long DurationSeconds { get; set; }
        public string? Notes { get; set; }
    }

    public class SubTokenDto
    {
        public int SubTokenId { get; set; }
        public string TokenNumber { get; set; } = string.Empty;
        public int SubTokenSequence { get; set; }
        public int ProcessId { get; set; }
        public string ProcessName { get; set; } = string.Empty;
        public int? CounterId { get; set; }
        public string? CounterNumber { get; set; }
        public int TokenStatus { get; set; }
        public string StatusName { get; set; } = string.Empty;
        public DateTime IssuedTime { get; set; }
        public DateTime? ServedTime { get; set; }
        public DateTime? CompletedTime { get; set; }
        public string? Notes { get; set; }
    }

    public class TokenWorkflowHistoryDto
    {
        public int RootTokenId { get; set; }
        public string TokenNumber { get; set; } = string.Empty;
        public int OrganizationId { get; set; }
        public int LocationId { get; set; }
        public int ProcessId { get; set; }
        public string ProcessName { get; set; } = string.Empty;
        public string ProcessCode { get; set; } = string.Empty;
        public string? CustomerName { get; set; }
        public string? CustomerPhone { get; set; }
        public int PriorityTier { get; set; }
        public DateTime IssuedTime { get; set; }
        public int TotalConfiguredSteps { get; set; }
        public int CurrentStepOrder { get; set; }
        public List<TokenWorkflowStepDto> Steps { get; set; } = new();
        public List<SubTokenDto> SubTokens { get; set; } = new();
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
        public int StaffUserId { get; set; } = 1;
    }

    public class CallNextTokenRequestDto
    {
        public int OrganizationId { get; set; } = 1;
        public int LocationId { get; set; } = 1;
        public int CounterId { get; set; } = 1;
        public int ProcessId { get; set; } = 1;
        public int StaffUserId { get; set; } = 1;
    }

    public class UpdateTokenStatusRequestDto
    {
        public int TokenId { get; set; }
        public int NewStatus { get; set; } // e_TokenStatus value
        public string? Reason { get; set; }
    }
}
