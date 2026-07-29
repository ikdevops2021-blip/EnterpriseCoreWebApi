namespace DNAQMSAPI.Domain.Entities;

public class User
{
    public int Id { get; set; }
    public string UserCode { get; set; } = null!;
    public int? TitleId { get; set; }
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string? DisplayName { get; set; }
    public int? GenderId { get; set; }
    public string? ProfileImageUrl { get; set; }
    public string Email { get; set; } = null!;
    public string PasswordHash { get; set; } = null!;
    public bool IsActive { get; set; }

    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int? ModifiedBy { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool? IsDeleted { get; set; }
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }

    // Joined / Navigation properties
    public string? TitleName { get; set; }
    public string? GenderName { get; set; }
}
