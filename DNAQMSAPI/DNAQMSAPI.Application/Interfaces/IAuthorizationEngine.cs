namespace DNAQMSAPI.Application.Interfaces;

public interface IAuthorizationEngine
{
    Task<bool> AuthorizeAsync(int userId, int organizationId, string requiredPermission);
    Task<IEnumerable<string>> GetUserPermissionsAsync(int userId, int organizationId);
}
