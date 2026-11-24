using System;

namespace DNAQMSAPI.Domain.Entities
{
    public class EmergencyBroadcast
    {
        public int Id { get; set; }
        public int OrganizationId { get; set; }
        public int? LocationId { get; set; }
        public int? AreaId { get; set; }
        public string BroadcastCode { get; set; } = "CODE_RED";
        public string Title { get; set; } = "EMERGENCY ALERT";
        public string MessageText { get; set; } = string.Empty;
        public int Severity { get; set; } = 3;
        public int AudioSirenType { get; set; } = 1;
        public string FlashColorHex { get; set; } = "#FF1744";
        public bool IsActive { get; set; } = true;
        public int TriggeredByUserId { get; set; }
        public DateTime TriggeredAt { get; set; } = DateTime.UtcNow;
        public int? DismissedByUserId { get; set; }
        public DateTime? DismissedAt { get; set; }
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    }
}
