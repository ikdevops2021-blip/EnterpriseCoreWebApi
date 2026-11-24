using System;
using System.Collections.Generic;

namespace AntiGravity.Enterprise.Shared.Core.Models.DQMS
{
    public class EdgeNodeRegistrationDto
    {
        public int Id { get; set; }
        public string NodeId { get; set; } = string.Empty;
        public string NodeName { get; set; } = string.Empty;
        public int OrganizationId { get; set; }
        public int LocationId { get; set; }
        public string? MacAddress { get; set; }
        public string? IpAddress { get; set; }
        public string? SoftwareVersion { get; set; }
        public bool IsActive { get; set; } = true;
        public DateTime? LastHeartbeatAt { get; set; }
        public DateTime? LastSyncAt { get; set; }
        public int PendingJournalCount { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime ModifiedDate { get; set; }
    }

    public class RegisterEdgeNodeRequestDto
    {
        public int Id { get; set; }
        public string NodeId { get; set; } = string.Empty;
        public string NodeName { get; set; } = string.Empty;
        public int OrganizationId { get; set; }
        public int LocationId { get; set; }
        public string? MacAddress { get; set; }
        public string? IpAddress { get; set; }
        public string SecretKey { get; set; } = string.Empty;
        public string? SoftwareVersion { get; set; }
        public bool IsActive { get; set; } = true;
    }

    public class EdgeHeartbeatRequestDto
    {
        public string NodeId { get; set; } = string.Empty;
        public string? SoftwareVersion { get; set; }
        public int PendingJournalCount { get; set; }
        public string? IpAddress { get; set; }
    }

    public class EdgeHeartbeatResponseDto
    {
        public bool IsAcknowledged { get; set; }
        public string NodeId { get; set; } = string.Empty;
        public DateTime ServerUtcTime { get; set; } = DateTime.UtcNow;
        public bool ConfigurationInvalidated { get; set; }
        public string Message { get; set; } = "Heartbeat acknowledged";
    }

    public class EdgeSyncBatchDto
    {
        public string BatchId { get; set; } = Guid.NewGuid().ToString("N");
        public string NodeId { get; set; } = string.Empty;
        public int OrganizationId { get; set; }
        public int LocationId { get; set; }
        public List<EdgeSyncItemDto> Items { get; set; } = new();
    }

    public class EdgeSyncItemDto
    {
        public string ClientTokenGuid { get; set; } = string.Empty;
        public string TokenNumber { get; set; } = string.Empty;
        public int ProcessId { get; set; }
        public int? CounterId { get; set; }
        public int? PriorityTier { get; set; } = 19001; // Standard
        public int TokenStatus { get; set; } = 18001; // Queued
        public DateTime CreatedDate { get; set; }
        public DateTime? CalledTime { get; set; }
        public DateTime? CompletedTime { get; set; }
        public string? CustomerName { get; set; }
        public string? CustomerPhone { get; set; }
    }

    public class EdgeSyncResultDto
    {
        public string BatchId { get; set; } = string.Empty;
        public int RecordsIngested { get; set; }
        public int ConflictsResolved { get; set; }
        public int DurationMs { get; set; }
        public string Status { get; set; } = "Success";
        public string? ErrorMessage { get; set; }
    }

    public class EdgeSyncAuditLogDto
    {
        public long Id { get; set; }
        public string BatchId { get; set; } = string.Empty;
        public string NodeId { get; set; } = string.Empty;
        public int OrganizationId { get; set; }
        public int LocationId { get; set; }
        public int RecordsCount { get; set; }
        public int ConflictsResolved { get; set; }
        public int DurationMs { get; set; }
        public string Status { get; set; } = string.Empty;
        public string? ErrorMessage { get; set; }
        public DateTime CreatedDate { get; set; }
    }
}
