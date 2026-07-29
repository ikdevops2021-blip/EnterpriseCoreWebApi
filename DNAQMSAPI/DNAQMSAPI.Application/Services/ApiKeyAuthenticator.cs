using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Entities;
using System.Security.Cryptography;
using System.Text;

namespace DNAQMSAPI.Application.Services;

public class ApiKeyAuthenticator : IApiKeyAuthenticator
{
    private readonly IApiKeyRepository _apiKeyRepository;

    public ApiKeyAuthenticator(IApiKeyRepository apiKeyRepository)
    {
        _apiKeyRepository = apiKeyRepository;
    }

    public async Task<ApiKey?> ValidateApiKeyAsync(string apiKeyRaw)
    {
        if (string.IsNullOrWhiteSpace(apiKeyRaw))
            return null;

        var hashedKey = HashApiKey(apiKeyRaw);
        return await _apiKeyRepository.GetByKeyHashAsync(hashedKey);
    }

    private string HashApiKey(string rawKey)
    {
        using var sha256 = SHA256.Create();
        var bytes = Encoding.UTF8.GetBytes(rawKey);
        var hash = sha256.ComputeHash(bytes);
        return Convert.ToBase64String(hash);
    }
}
