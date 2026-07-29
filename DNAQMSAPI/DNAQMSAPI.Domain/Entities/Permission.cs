namespace DNAQMSAPI.Domain.Entities;

public class Permission
{
    public int Id { get; set; }
    public string Name { get; set; } = null!; // e.g., "users.read"
    public string Description { get; set; } = string.Empty;

    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int? ModifiedBy { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool? IsDeleted { get; set; }
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
