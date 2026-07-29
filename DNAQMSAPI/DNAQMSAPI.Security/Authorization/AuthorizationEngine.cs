using System.Security.Claims;
using DNAQMSAPI.Application;
using DNAQMSAPI.Application.Interfaces;

namespace DNAQMSAPI.Security.Authorization;

public class AuthorizationEngine : IAuthorizationEngine
{
    // Need an injected IDapperDBFactory to query DB for permissions
    private readonly IDapperDBFactory _dbFactory;

    public AuthorizationEngine(IDapperDBFactory dbFactory)
    {
        _dbFactory = dbFactory;
    }

    public async Task<bool> AuthorizeAsync(int userId, int organizationId, string requiredPermission)
    {
        // Zero Trust Validation
        // Fetch all specific permissions for this User context in this Organization (RBAC + ABAC logic)
        // Note: For now, we mock true for testing the scaffold. Real implementation hits the database.
        
        var permissions = await GetUserPermissionsAsync(userId, organizationId);
        return permissions.Contains(requiredPermission, StringComparer.OrdinalIgnoreCase);
    }

    public async Task<IEnumerable<string>> GetUserPermissionsAsync(int userId, int organizationId)
    {
        // Example SQL to gather permissions via Roles assigned to User for Global or specific Organization
        const string sql = @"
            SELECT p.Name
            FROM UserRole ur
            INNER JOIN Role r ON ur.RoleId = r.Id
            INNER JOIN RolePermission rp ON r.Id = rp.RoleId
            INNER JOIN Permission p ON rp.PermissionId = p.Id
            WHERE ur.UserId = @UserId
              AND (ur.OrganizationId IS NULL OR ur.OrganizationId = @OrganizationId)
              AND ur.IsActive = 1
              AND r.IsActive = 1
              AND (r.OrganizationId IS NULL OR r.OrganizationId = @OrganizationId)";

        var permissions = await _dbFactory.QueryAsync<string>(sql, new { UserId = userId, OrganizationId = organizationId });

        return permissions.Distinct();
    }
}
