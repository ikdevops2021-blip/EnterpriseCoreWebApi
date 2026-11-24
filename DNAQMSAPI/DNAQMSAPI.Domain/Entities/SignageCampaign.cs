using System;
using System.Collections.Generic;

namespace DNAQMSAPI.Domain.Entities
{
    public class SignageCampaign
    {
        public int Id { get; set; }
        public int OrganizationId { get; set; }
        public string CampaignName { get; set; } = string.Empty;
        public int CampaignType { get; set; } = 1;
        public int Priority { get; set; } = 5;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public TimeSpan? DailyStartTime { get; set; }
        public TimeSpan? DailyEndTime { get; set; }
        public string DaysOfWeek { get; set; } = "1,2,3,4,5,6,7";
        public bool IsActive { get; set; } = true;
        public int CreatedBy { get; set; } = 1;
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
        public int ModifiedBy { get; set; } = 1;
        public DateTime ModifiedDate { get; set; } = DateTime.UtcNow;
        public bool IsDeleted { get; set; } = false;

        public List<SignageMediaItem> MediaItems { get; set; } = new List<SignageMediaItem>();
    }
}
