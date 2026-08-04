using System.Data;
using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.DTOs;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Entities;
using DNAQMSAPI.Infrastructure.Models;

namespace DNAQMSAPI.Infrastructure.Services;

/// <summary>
/// Implements INavigationMenuService using Dapper with MySQL stored procedures.
/// Follows PR_S_ / PR_IU_ naming conventions established in this project.
/// </summary>
public class NavigationMenuService : INavigationMenuService
{
    private readonly IDapperDBFactory _dbFactory;

    public NavigationMenuService(IDapperDBFactory dbFactory)
    {
        _dbFactory = dbFactory;
    }

    // -------------------------------------------------------------------------
    // GET: Fetch navigation menus from PR_S_NavigationMenu
    // -------------------------------------------------------------------------
    public async Task<ApiResponse<IEnumerable<NavigationMenuDto>>> GetMenusAsync(int id = -1, bool activeOnly = true)
    {
        try
        {
            var parameters = new
            {
                p_Id        = id < 0 ? (object)DBNull.Value : id,
                p_RoutePath = (object)DBNull.Value,
                p_IsActive  = activeOnly ? 1 : -1   // -1 = all, 1 = active only
            };

            var rows = await _dbFactory.QueryAsync<NavigationMenu>(
                "PR_S_NavigationMenu",
                parameters,
                commandType: CommandType.StoredProcedure
            );

            var dtos = rows
                .Where(r => r != null)
                .Select(r => MapToDto(r!))
                .ToList();

            return ApiResponse<IEnumerable<NavigationMenuDto>>.Ok(dtos);
        }
        catch (Exception ex)
        {
            return ApiResponse<IEnumerable<NavigationMenuDto>>.Ok(
                Enumerable.Empty<NavigationMenuDto>(),
                $"Note: Navigation menu query failed ({ex.Message})");
        }
    }

    // -------------------------------------------------------------------------
    // GET BY ID
    // -------------------------------------------------------------------------
    public async Task<ApiResponse<NavigationMenuDto>> GetMenuByIdAsync(int id)
    {
        try
        {
            var parameters = new
            {
                p_Id        = id,
                p_RoutePath = (object)DBNull.Value,
                p_IsActive  = -1
            };

            var row = await _dbFactory.QuerySingleAsync<NavigationMenu>(
                "PR_S_NavigationMenu",
                parameters,
                commandType: CommandType.StoredProcedure
            );

            if (row == null)
                return ApiResponse<NavigationMenuDto>.Fail($"Navigation menu item with ID {id} not found.");

            return ApiResponse<NavigationMenuDto>.Ok(MapToDto(row));
        }
        catch (Exception ex)
        {
            return ApiResponse<NavigationMenuDto>.Fail($"Database error: {ex.Message}");
        }
    }

    // -------------------------------------------------------------------------
    // INSERT / UPDATE via PR_IU_NavigationMenu
    // -------------------------------------------------------------------------
    public async Task<ApiResponse<NavigationMenuDto>> SaveMenuAsync(SaveNavigationMenuRequestDto request, int userId)
    {
        try
        {
            var parameters = new
            {
                p_Id                 = request.Id <= 0 ? (object)DBNull.Value : request.Id,
                p_Title              = request.Title?.Trim(),
                p_IconName           = request.IconName?.Trim(),
                p_RoutePath          = request.RoutePath?.Trim(),
                p_SortOrder          = request.SortOrder,
                p_ParentId           = request.ParentId.HasValue ? (object)request.ParentId.Value : DBNull.Value,
                p_RequiredPermission = request.RequiredPermission ?? (object)DBNull.Value,
                p_IsActive           = request.IsActive ? 1 : 0,
                p_UID                = userId
            };

            var result = await _dbFactory.QuerySingleAsync<SPResult>(
                "PR_IU_NavigationMenu",
                parameters,
                commandType: CommandType.StoredProcedure
            );

            if (result != null && result.ErrNo == 0)
            {
                // Fetch the saved record and return it
                int savedId = Convert.ToInt32(result.ID);
                var saved = await GetMenuByIdAsync(savedId);
                return ApiResponse<NavigationMenuDto>.Ok(
                    saved.Data,
                    request.Id <= 0 ? "Navigation menu item created successfully." : "Navigation menu item updated successfully.");
            }

            return ApiResponse<NavigationMenuDto>.Fail(result?.ErrMsg ?? "Failed to save navigation menu item.");
        }
        catch (Exception ex)
        {
            return ApiResponse<NavigationMenuDto>.Fail($"Database error: {ex.Message}");
        }
    }

    // -------------------------------------------------------------------------
    // SOFT DELETE (set IsActive = 0, IsDeleted = 1 via update)
    // -------------------------------------------------------------------------
    public async Task<ApiResponse<bool>> DeleteMenuAsync(int id, int userId)
    {
        try
        {
            // Soft delete: PR_IU_NavigationMenu with IsActive=0 then mark deleted via direct pattern
            // We use the upsert SP: fetch first, then set IsDeleted manually via update request
            var parameters = new
            {
                p_Id                 = id,
                p_Title              = (object)DBNull.Value,  // SP will preserve existing values on update
                p_IconName           = (object)DBNull.Value,
                p_RoutePath          = (object)DBNull.Value,
                p_SortOrder          = (object)DBNull.Value,
                p_ParentId           = (object)DBNull.Value,
                p_RequiredPermission = (object)DBNull.Value,
                p_IsActive           = 0,
                p_UID                = userId
            };

            // Use a direct SQL for soft delete since SP doesn't support partial nulls on update well
            var sql = @"UPDATE NavigationMenu 
                        SET IsActive = 0, IsDeleted = 1, DeletedBy = @p_UID, DeletedDate = CURRENT_TIMESTAMP,
                            ModifiedBy = @p_UID, ModifiedDate = CURRENT_TIMESTAMP
                        WHERE Id = @p_Id AND IsDeleted = 0";

            var directParams = new { p_Id = id, p_UID = userId };
            var rows = await _dbFactory.ExecuteAsync(sql, directParams);

            if (rows > 0)
                return ApiResponse<bool>.Ok(true, "Navigation menu item deleted successfully.");

            return ApiResponse<bool>.Fail("Navigation menu item not found or already deleted.");
        }
        catch (Exception ex)
        {
            return ApiResponse<bool>.Fail($"Database error: {ex.Message}");
        }
    }

    // -------------------------------------------------------------------------
    // Mapping helper: Entity -> DTO
    // -------------------------------------------------------------------------
    private static NavigationMenuDto MapToDto(NavigationMenu entity) => new()
    {
        Id                  = entity.Id,
        Title               = entity.Title,
        IconName            = entity.IconName,
        RoutePath           = entity.RoutePath,
        SortOrder           = entity.SortOrder,
        ParentId            = entity.ParentId,
        RequiredPermission  = entity.RequiredPermission,
        IsActive            = entity.IsActive
    };
}
