namespace DNAQMSAPI.Domain.Entities;

public class NotificationTemplate
{
    public int Id { get; set; }
    public int? OrganizationId { get; set; }
    public string? OrganizationName { get; set; }
    public int EventId { get; set; }
    public string EventCode { get; set; } = null!;
    public string? EventName { get; set; }
    public int CategoryId { get; set; }
    public string SubjectTemplate { get; set; } = null!;
    public string BodyTemplate { get; set; } = null!;
    public bool SendInApp { get; set; } = true;
    public bool SendEmail { get; set; } = true;
    public bool SendSMS { get; set; } = false;
    public bool IsActive { get; set; } = true;

    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int? ModifiedBy { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool? IsDeleted { get; set; }
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}

public class UserNotification
{
    public long Id { get; set; }
    public int OrganizationId { get; set; }
    public string? OrganizationName { get; set; }
    public int UserId { get; set; }
    public int? EventId { get; set; }
    public string EventCode { get; set; } = null!;
    public string? EventName { get; set; }
    public int CategoryId { get; set; }
    public string Title { get; set; } = null!;
    public string Message { get; set; } = null!;
    public string? ActionUrl { get; set; }
    public bool IsRead { get; set; }
    public DateTime? ReadDate { get; set; }

    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int? ModifiedBy { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool? IsDeleted { get; set; }
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}

public class SmsQueue
{
    public string QueueId { get; set; } = Guid.NewGuid().ToString();
    public int OrganizationId { get; set; }
    public string RecipientPhoneNumber { get; set; } = null!;
    public string Message { get; set; } = null!;
    public int Status { get; set; } // 0: Pending, 1: Sent, 2: Failed
    public int RetryCount { get; set; }
    public int MaxRetryCount { get; set; } = 3;
    public string? ErrorMessage { get; set; }

    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int? ModifiedBy { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool? IsDeleted { get; set; }
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
