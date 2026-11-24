using System;

namespace DNAQMSAPI.Domain.Entities
{
    public class SignageMediaItem
    {
        public int Id { get; set; }
        public int CampaignId { get; set; }
        public int MediaType { get; set; } = 1;
        public string MediaUrl { get; set; } = string.Empty;
        public string? LocalCachePath { get; set; }
        public string Title { get; set; } = string.Empty;
        public int DurationSeconds { get; set; } = 15;
        public int DisplayOrder { get; set; } = 1;
        public bool MuteAudio { get; set; } = true;
        public bool IsActive { get; set; } = true;
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    }
}
