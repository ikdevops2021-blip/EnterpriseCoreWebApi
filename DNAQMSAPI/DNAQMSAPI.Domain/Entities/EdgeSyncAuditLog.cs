using System;

namespace DNAQMSAPI.Domain.Entities
{
    public class EdgeSyncAuditLog
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
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    }
}
