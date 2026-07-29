namespace DNAQMSAPI.Domain.Entities;

public class UserDevice
{
    public Guid Id { get; set; }
    public int UserId { get; set; }
    public string DeviceIdentifier { get; set; } = null!;
    public string DeviceName { get; set; } = string.Empty;
    public DateTime LastSeenAt { get; set; }
    public bool IsTrusted { get; set; }

    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int? ModifiedBy { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool? IsDeleted { get; set; }
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
