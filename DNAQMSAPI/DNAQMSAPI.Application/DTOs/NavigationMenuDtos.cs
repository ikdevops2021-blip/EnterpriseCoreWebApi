namespace DNAQMSAPI.Application.DTOs;

/// <summary>
/// DTO returned by the API for a single navigation menu item.
/// </summary>
public class NavigationMenuDto
{
    public int Id { get; set; }
    public string Title { get; set; } = null!;
    public string IconName { get; set; } = null!;
    public string RoutePath { get; set; } = null!;
    public int SortOrder { get; set; }
    public int? ParentId { get; set; }
    public string? RequiredPermission { get; set; }
    public bool IsActive { get; set; }
}

/// <summary>
/// Request DTO to create or update a NavigationMenu entry.
/// </summary>
public class SaveNavigationMenuRequestDto
{
    public int Id { get; set; }
    public string Title { get; set; } = null!;
    public string IconName { get; set; } = null!;
    public string RoutePath { get; set; } = null!;
    public int SortOrder { get; set; } = 99;
    public int? ParentId { get; set; }
    public string? RequiredPermission { get; set; }
    public bool IsActive { get; set; } = true;
}
