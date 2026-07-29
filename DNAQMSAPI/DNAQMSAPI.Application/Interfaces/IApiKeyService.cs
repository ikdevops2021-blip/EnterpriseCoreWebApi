using DNAQMSAPI.Domain.Entities;

namespace DNAQMSAPI.Application.Interfaces;

public interface IApiKeyService
{
    Task<(ApiKey ApiKey, string RawKey)> GenerateApiKeyAsync(int userId, string name, DateTime? expiresAt = null);
    Task<IEnumerable<ApiKey>> GetUserApiKeysAsync(int userId);
    Task RevokeApiKeyAsync(Guid apiKeyId, int deletedByUserId);
}
