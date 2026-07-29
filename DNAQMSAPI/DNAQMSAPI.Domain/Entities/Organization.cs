namespace DNAQMSAPI.Domain.Entities;

public class Organization
{
    public int Id { get; set; }
    public Guid RegistrationKey { get; set; }
    public string Name { get; set; } = null!;
    public int? ParentOrganizationId { get; set; } // Hierarchical support
    public bool IsActive { get; set; }

    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int? ModifiedBy { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool? IsDeleted { get; set; }
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
