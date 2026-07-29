namespace DNAQMSAPI.Domain.Entities;

public class ApiKey
{
    public Guid Id { get; set; }
    public string KeyHash { get; set; } = null!;
    public string Name { get; set; } = null!;
    public int UserId { get; set; }
    public DateTime? ExpiresAt { get; set; }
    public bool IsActive { get; set; }

    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int? ModifiedBy { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool? IsDeleted { get; set; }
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
