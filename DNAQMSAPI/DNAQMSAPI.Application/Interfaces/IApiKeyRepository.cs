using DNAQMSAPI.Domain.Entities;

namespace DNAQMSAPI.Application.Interfaces;

public interface IApiKeyRepository
{
    Task<ApiKey?> GetByKeyHashAsync(string keyHash);
    Task<IEnumerable<ApiKey>> GetByUserIdAsync(int userId);
    Task<string> CreateAsync(ApiKey apiKey);
    Task RevokeAsync(Guid apiKeyId, int deletedBy);
}
