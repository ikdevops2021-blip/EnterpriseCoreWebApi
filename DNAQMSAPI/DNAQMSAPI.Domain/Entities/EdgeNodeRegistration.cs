using System;

namespace DNAQMSAPI.Domain.Entities
{
    public class EdgeNodeRegistration
    {
        public int Id { get; set; }
        public string NodeId { get; set; } = string.Empty;
        public string NodeName { get; set; } = string.Empty;
        public int OrganizationId { get; set; }
        public int LocationId { get; set; }
        public string? MacAddress { get; set; }
        public string? IpAddress { get; set; }
        public string SecretKeyHash { get; set; } = string.Empty;
        public string? SoftwareVersion { get; set; }
        public bool IsActive { get; set; } = true;
        public DateTime? LastHeartbeatAt { get; set; }
        public DateTime? LastSyncAt { get; set; }
        public int PendingJournalCount { get; set; }
        public int CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
        public int ModifiedBy { get; set; }
        public DateTime ModifiedDate { get; set; } = DateTime.UtcNow;
    }
}
