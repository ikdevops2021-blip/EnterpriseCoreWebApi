using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Entities;
using System.Security.Cryptography;
using System.Text;

namespace DNAQMSAPI.Application.Services;

public class ApiKeyService : IApiKeyService
{
    private readonly IApiKeyRepository _apiKeyRepository;
    private const string ApiKeyPrefix = "dnaqms_live_";

    public ApiKeyService(IApiKeyRepository apiKeyRepository)
    {
        _apiKeyRepository = apiKeyRepository;
    }

    public async Task<(ApiKey ApiKey, string RawKey)> GenerateApiKeyAsync(int userId, string name, DateTime? expiresAt = null)
    {
        var randomBytes = new byte[32];
        using (var rng = RandomNumberGenerator.Create())
        {
            rng.GetBytes(randomBytes);
        }
        
        var rawKeySegment = Convert.ToBase64String(randomBytes)
            .Replace("+", "-")
            .Replace("/", "_")
            .Replace("=", "");
            
        var rawKey = $"{ApiKeyPrefix}{rawKeySegment}";
        var hashedKey = HashApiKey(rawKey);

        var apiKey = new ApiKey
        {
            Id = Guid.NewGuid(),
            KeyHash = hashedKey,
            Name = name,
            UserId = userId,
            ExpiresAt = expiresAt,
            IsActive = true,
            CreatedBy = userId,
            CreatedDate = DateTime.UtcNow,
            ModifiedBy = userId,
            ModifiedDate = DateTime.UtcNow
        };

        await _apiKeyRepository.CreateAsync(apiKey);

        return (apiKey, rawKey);
    }

    public async Task<IEnumerable<ApiKey>> GetUserApiKeysAsync(int userId)
    {
        return await _apiKeyRepository.GetByUserIdAsync(userId);
    }

    public async Task RevokeApiKeyAsync(Guid apiKeyId, int deletedByUserId)
    {
        await _apiKeyRepository.RevokeAsync(apiKeyId, deletedByUserId);
    }

    private string HashApiKey(string rawKey)
    {
        using var sha256 = SHA256.Create();
        var bytes = Encoding.UTF8.GetBytes(rawKey);
        var hash = sha256.ComputeHash(bytes);
        return Convert.ToBase64String(hash);
    }
}
