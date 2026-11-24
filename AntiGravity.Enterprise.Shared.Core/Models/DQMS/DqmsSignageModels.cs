using System;
using System.Collections.Generic;

namespace AntiGravity.Enterprise.Shared.Core.Models.DQMS
{
    public class SignageCampaignDto
    {
        public int Id { get; set; }
        public int OrganizationId { get; set; }
        public string CampaignName { get; set; } = string.Empty;
        public int CampaignType { get; set; } = 1; // 1=Promotional, 2=Health Advisory, 3=Corporate
        public int Priority { get; set; } = 5;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public TimeSpan? DailyStartTime { get; set; }
        public TimeSpan? DailyEndTime { get; set; }
        public string DaysOfWeek { get; set; } = "1,2,3,4,5,6,7";
        public int? LocationId { get; set; }
        public int? AreaId { get; set; }
        public bool IsActive { get; set; } = true;
        public List<SignageMediaItemDto> MediaItems { get; set; } = new List<SignageMediaItemDto>();
    }

    public class SignageMediaItemDto
    {
        public int Id { get; set; }
        public int CampaignId { get; set; }
        public string CampaignName { get; set; } = string.Empty;
        public int MediaType { get; set; } = 1; // 1=Image, 2=Video, 3=Html5/Url, 4=TickerText
        public string MediaUrl { get; set; } = string.Empty;
        public string? LocalCachePath { get; set; }
        public string Title { get; set; } = string.Empty;
        public int DurationSeconds { get; set; } = 15;
        public int DisplayOrder { get; set; } = 1;
        public bool MuteAudio { get; set; } = true;
        public bool IsActive { get; set; } = true;
    }

    public class SaveSignageCampaignRequestDto
    {
        public int Id { get; set; }
        public int OrganizationId { get; set; }
        public string CampaignName { get; set; } = string.Empty;
        public int CampaignType { get; set; } = 1;
        public int Priority { get; set; } = 5;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string? DailyStartTime { get; set; }
        public string? DailyEndTime { get; set; }
        public string DaysOfWeek { get; set; } = "1,2,3,4,5,6,7";
        public int? LocationId { get; set; }
        public int? AreaId { get; set; }
        public bool IsActive { get; set; } = true;
        public List<SignageMediaItemDto> MediaItems { get; set; } = new List<SignageMediaItemDto>();
    }

    public class SignagePlaylistResponseDto
    {
        public int OrganizationId { get; set; }
        public int LocationId { get; set; }
        public int? AreaId { get; set; }
        public List<SignageMediaItemDto> Items { get; set; } = new List<SignageMediaItemDto>();
        public DateTime GeneratedAt { get; set; } = DateTime.UtcNow;
    }

    public class EmergencyBroadcastDto
    {
        public int Id { get; set; }
        public int OrganizationId { get; set; }
        public int? LocationId { get; set; }
        public int? AreaId { get; set; }
        public string BroadcastCode { get; set; } = "CODE_RED"; // CODE_RED, CODE_BLUE, EVACUATION, WEATHER, CUSTOM
        public string Title { get; set; } = "EMERGENCY ALERT";
        public string MessageText { get; set; } = string.Empty;
        public int Severity { get; set; } = 3; // 1=Info, 2=Warning, 3=Critical
        public int AudioSirenType { get; set; } = 1; // 0=None, 1=Pulse, 2=Wail, 3=Continuous
        public string FlashColorHex { get; set; } = "#FF1744";
        public bool IsActive { get; set; } = true;
        public int TriggeredByUserId { get; set; }
        public DateTime TriggeredAt { get; set; } = DateTime.UtcNow;
        public int? DismissedByUserId { get; set; }
        public DateTime? DismissedAt { get; set; }
    }

    public class TriggerEmergencyBroadcastRequestDto
    {
        public int OrganizationId { get; set; }
        public int? LocationId { get; set; }
        public int? AreaId { get; set; }
        public string BroadcastCode { get; set; } = "CODE_RED";
        public string Title { get; set; } = "EMERGENCY ALERT";
        public string MessageText { get; set; } = string.Empty;
        public int Severity { get; set; } = 3;
        public int AudioSirenType { get; set; } = 1;
        public string FlashColorHex { get; set; } = "#FF1744";
    }

    public class DismissEmergencyBroadcastRequestDto
    {
        public int BroadcastId { get; set; }
        public int OrganizationId { get; set; }
    }
}
