using AntiGravity.Enterprise.Shared.Core.Controllers;
using DNAQMSAPI.Application.DTOs;
using DNAQMSAPI.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers;

/// <summary>
/// Manages the dynamic plug-and-play NavigationMenu entries.
/// These entries drive the sidebar of the frontend application.
/// </summary>
[ApiController]
[Route("api/v1/navigation")]
[AllowAnonymous] // TODO: lock down with [Authorize] when auth is wired
public class NavigationMenuController : ApiControllerBase
{
    private readonly INavigationMenuService _menuService;

    public NavigationMenuController(INavigationMenuService menuService)
    {
        _menuService = menuService;
    }

    /// <summary>
    /// Returns all active navigation menu items ordered by SortOrder.
    /// Used by the Flutter sidebar on startup to build the navigation list dynamically.
    /// </summary>
    [HttpGet("menus")]
    public async Task<IActionResult> GetMenus(
        [FromQuery] int? id,
        [FromQuery] bool activeOnly = true)
    {
        var result = await _menuService.GetMenusAsync(id ?? -1, activeOnly);
        return ApiResponse(result);
    }

    /// <summary>
    /// Returns a single navigation menu item by ID.
    /// </summary>
    [HttpGet("menu/{id:int}")]
    public async Task<IActionResult> GetMenuById([FromRoute] int id)
    {
        var result = await _menuService.GetMenuByIdAsync(id);
        return ApiResponse(result);
    }

    /// <summary>
    /// Creates or updates a navigation menu item.
    /// Pass Id = 0 for insert, Id > 0 for update.
    /// </summary>
    [HttpPost("menu")]
    public async Task<IActionResult> SaveMenu(
        [FromBody] SaveNavigationMenuRequestDto model,
        [FromHeader(Name = "X-User-Id")] int userId = 1)
    {
        var result = await _menuService.SaveMenuAsync(model, userId);
        return ApiResponse(result);
    }

    /// <summary>
    /// Soft-deletes a navigation menu item (sets IsDeleted = 1, IsActive = 0).
    /// </summary>
    [HttpDelete("menu/{id:int}")]
    public async Task<IActionResult> DeleteMenu(
        [FromRoute] int id,
        [FromHeader(Name = "X-User-Id")] int userId = 1)
    {
        var result = await _menuService.DeleteMenuAsync(id, userId);
        return ApiResponse(result);
    }

    /// <summary>
    /// Updates the sort order of multiple menu items in bulk.
    /// Accepts a list of { id, sortOrder } pairs.
    /// </summary>
    [HttpPatch("menus/reorder")]
    public async Task<IActionResult> ReorderMenus(
        [FromBody] List<MenuReorderItemDto> items,
        [FromHeader(Name = "X-User-Id")] int userId = 1)
    {
        if (items == null || items.Count == 0)
            return BadRequest(new { message = "No items provided for reordering." });

        var tasks = items.Select(item => _menuService.SaveMenuAsync(new SaveNavigationMenuRequestDto
        {
            Id        = item.Id,
            SortOrder = item.SortOrder,
            // These will be merged server-side from the existing record
            Title     = item.Title,
            IconName  = item.IconName,
            RoutePath = item.RoutePath,
            IsActive  = true
        }, userId));

        await Task.WhenAll(tasks);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<bool>.Ok(true, "Menu order updated successfully."));
    }
}

/// <summary>DTO for bulk sort order updates.</summary>
public record MenuReorderItemDto(int Id, int SortOrder, string Title, string IconName, string RoutePath);
