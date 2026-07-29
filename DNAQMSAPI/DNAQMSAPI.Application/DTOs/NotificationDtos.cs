namespace DNAQMSAPI.Application.DTOs;

public class SendNotificationRequestDto
{
    public int OrganizationId { get; set; }
    public int? EventId { get; set; }
    public string? EventCode { get; set; }
    public List<int> TargetUserIds { get; set; } = new();
    public Dictionary<string, string> Parameters { get; set; } = new();
    public string? ActionUrl { get; set; }
    public int Priority { get; set; } = 1;
}

public class NotificationTemplateDto
{
    public int Id { get; set; }
    public int? OrganizationId { get; set; }
    public string? OrganizationName { get; set; }
    public int EventId { get; set; }
    public string EventCode { get; set; } = string.Empty;
    public string? EventName { get; set; }
    public int CategoryId { get; set; }
    public string SubjectTemplate { get; set; } = string.Empty;
    public string BodyTemplate { get; set; } = string.Empty;
    public bool SendInApp { get; set; } = true;
    public bool SendEmail { get; set; } = true;
    public bool SendSMS { get; set; } = false;
    public bool IsActive { get; set; } = true;
}

public class SaveNotificationTemplateRequestDto
{
    public int Id { get; set; }
    public int? OrganizationId { get; set; }
    public int? EventId { get; set; }
    public string? EventCode { get; set; }
    public int CategoryId { get; set; } = 2001;
    public string SubjectTemplate { get; set; } = string.Empty;
    public string BodyTemplate { get; set; } = string.Empty;
    public bool SendInApp { get; set; } = true;
    public bool SendEmail { get; set; } = true;
    public bool SendSMS { get; set; } = false;
    public bool IsActive { get; set; } = true;
}

public class UserNotificationDto
{
    public long Id { get; set; }
    public int OrganizationId { get; set; }
    public string? OrganizationName { get; set; }
    public int UserId { get; set; }
    public int? EventId { get; set; }
    public string EventCode { get; set; } = string.Empty;
    public string? EventName { get; set; }
    public int CategoryId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string? ActionUrl { get; set; }
    public bool IsRead { get; set; }
    public DateTime CreatedDate { get; set; }
}

public class UnreadCountDto
{
    public int UnreadCount { get; set; }
}
