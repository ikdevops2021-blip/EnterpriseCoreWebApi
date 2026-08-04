using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.DTOs;

namespace DNAQMSAPI.Application.Interfaces;

/// <summary>
/// Manages the dynamic plug-and-play NavigationMenu entries served to the sidebar.
/// </summary>
public interface INavigationMenuService
{
    Task<ApiResponse<IEnumerable<NavigationMenuDto>>> GetMenusAsync(int id = -1, bool activeOnly = true);
    Task<ApiResponse<NavigationMenuDto>> GetMenuByIdAsync(int id);
    Task<ApiResponse<NavigationMenuDto>> SaveMenuAsync(SaveNavigationMenuRequestDto request, int userId);
    Task<ApiResponse<bool>> DeleteMenuAsync(int id, int userId);
}
