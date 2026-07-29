using System;

namespace AntiGravity.Enterprise.Shared.Core.Models.DQMS
{
    public class AreaModel
    {
        public int Id { get; set; }
        public string AreaCode { get; set; } = string.Empty;
        public int OrganizationId { get; set; }
        public int LocationId { get; set; }
        public string AreaName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public bool IsActive { get; set; } = true;
        public int CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public int ModifiedBy { get; set; }
        public DateTime ModifiedDate { get; set; }
    }

    public class CounterModel
    {
        public int Id { get; set; }
        public string CounterCode { get; set; } = string.Empty;
        public int OrganizationId { get; set; }
        public int LocationId { get; set; }
        public int AreaId { get; set; }
        public string CounterNumber { get; set; } = string.Empty;
        public string CounterName { get; set; } = string.Empty;
        public int CurrentStatus { get; set; } = 20001; // Default to Idle (18001/20001)
        public bool IsActive { get; set; } = true;
        public int CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public int ModifiedBy { get; set; }
        public DateTime ModifiedDate { get; set; }
    }

    public class ProcessModel
    {
        public int Id { get; set; }
        public string ProcessCode { get; set; } = string.Empty;
        public int OrganizationId { get; set; }
        public string ProcessName { get; set; } = string.Empty;
        public string Prefix { get; set; } = "A";
        public int TargetTATMinutes { get; set; } = 15;
        public bool AllowSubTokens { get; set; }
        public bool IsActive { get; set; } = true;
        public int CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public int ModifiedBy { get; set; }
        public DateTime ModifiedDate { get; set; }
    }

    public class DisplayTemplateModel
    {
        public int Id { get; set; }
        public int OrganizationId { get; set; }
        public string TemplateName { get; set; } = string.Empty;
        public int TemplateType { get; set; } = 21001; // Default to GridView (21001)
        public string? LayoutConfigJson { get; set; }
        public bool IsDefault { get; set; }
        public bool IsActive { get; set; } = true;
        public int CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public int ModifiedBy { get; set; }
        public DateTime ModifiedDate { get; set; }
    }

    public class ProcessBlackoutDayModel
    {
        public int Id { get; set; }
        public int OrganizationId { get; set; }
        public int LocationId { get; set; }
        public int ProcessId { get; set; }
        public int DayOfWeek { get; set; }
        public string? Reason { get; set; }
        public bool IsActive { get; set; } = true;
        public int CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
    }
}
