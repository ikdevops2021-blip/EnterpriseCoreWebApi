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

    public class ConfigCategoryDto
    {
        public int CategoryId { get; set; }
        public string CategoryCode { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public int Priority { get; set; } = 1;
        public bool Active { get; set; } = true;
        public bool AllowModify { get; set; } = true;
        public string RangeText { get; set; } = string.Empty;
        public string? CategoryExternalId { get; set; }
        public string? CategoryExternalCode { get; set; }
        public string? CategoryColor { get; set; } = "#2F81F7";
        public string? CategoryIcon { get; set; } = "category";
        public string? CategoryImage { get; set; }
    }

    public class ConfigParameterDto
    {
        public int ParameterId { get; set; }
        public int CategoryId { get; set; }
        public string ParamCode { get; set; } = string.Empty;
        public string ParamName { get; set; } = string.Empty;
        public bool IsDefault { get; set; }
        public int Priority { get; set; } = 1;
        public bool IsActive { get; set; } = true;
        public string Description { get; set; } = string.Empty;
        public string? ParameterExternalId { get; set; }
        public string? ParameterExternalCode { get; set; }
        public string? ParameterColor { get; set; } = "#2F81F7";
        public string? ParameterIcon { get; set; } = "code";
        public string? ParameterImage { get; set; }
    }
}
