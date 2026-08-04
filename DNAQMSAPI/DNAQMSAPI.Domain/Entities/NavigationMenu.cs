namespace DNAQMSAPI.Domain.Entities;

/// <summary>
/// Represents a dynamic navigation menu item for plug-and-play sidebar configuration.
/// </summary>
public class NavigationMenu
{
    public int Id { get; set; }
    public string Title { get; set; } = null!;
    public string IconName { get; set; } = null!;
    public string RoutePath { get; set; } = null!;
    public int SortOrder { get; set; }
    public int? ParentId { get; set; }
    public string? RequiredPermission { get; set; }
    public bool IsActive { get; set; } = true;

    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int ModifiedBy { get; set; }
    public DateTime ModifiedDate { get; set; }
    public bool IsDeleted { get; set; }
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
