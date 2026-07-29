using System.Data;
using Dapper;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Entities;
using DNAQMSAPI.Infrastructure.Data;
using DNAQMSAPI.Infrastructure.Models;

namespace DNAQMSAPI.Infrastructure.Repositories;

public class ApiKeyRepository : IApiKeyRepository
{
    private readonly IDapperDBFactory _dbFactory;

    public ApiKeyRepository(IDapperDBFactory dbFactory)
    {
        _dbFactory = dbFactory;
    }

    public async Task<ApiKey?> GetByKeyHashAsync(string keyHash)
    {
        var result = await _dbFactory.QueryAsync<ApiKey>(
            "PR_S_ApiKey",
            new { p_Id = "", p_KeyHash = keyHash, p_UserId = -1, p_IsActive = -1 },
            commandType: CommandType.StoredProcedure);

        return result.FirstOrDefault();
    }

    public async Task<IEnumerable<ApiKey>> GetByUserIdAsync(int userId)
    {
        var result = await _dbFactory.QueryAsync<ApiKey>(
            "PR_S_ApiKey",
            new { p_Id = "", p_KeyHash = "", p_UserId = userId, p_IsActive = 1 },
            commandType: CommandType.StoredProcedure);

        return result;
    }

    public async Task<string> CreateAsync(ApiKey apiKey)
    {
        var parameters = new
        {
            p_Id = apiKey.Id == Guid.Empty ? "" : apiKey.Id.ToString(),
            p_KeyHash = apiKey.KeyHash,
            p_Name = apiKey.Name,
            p_UserId = apiKey.UserId,
            p_ExpiresAt = apiKey.ExpiresAt,
            p_IsActive = apiKey.IsActive,
            p_UID = apiKey.CreatedBy
        };

        var result = await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_ApiKey",
            parameters,
            commandType: CommandType.StoredProcedure);

        if (result != null && result.ErrNo == 0)
        {
            return apiKey.Id.ToString();
        }

        throw new InvalidOperationException(result?.ErrMsg ?? "Failed to create ApiKey.");
    }

    public async Task RevokeAsync(Guid apiKeyId, int deletedBy)
    {
        var keys = await _dbFactory.QueryAsync<ApiKey>(
            "PR_S_ApiKey",
            new { p_Id = apiKeyId.ToString(), p_KeyHash = "", p_UserId = -1, p_IsActive = -1 },
            commandType: CommandType.StoredProcedure);

        var key = keys.FirstOrDefault();
        if (key != null)
        {
            var parameters = new
            {
                p_Id = key.Id.ToString(),
                p_KeyHash = key.KeyHash,
                p_Name = key.Name,
                p_UserId = key.UserId,
                p_ExpiresAt = key.ExpiresAt,
                p_IsActive = 0,
                p_UID = deletedBy
            };

            await _dbFactory.QuerySingleAsync<SPResult>(
                "PR_IU_ApiKey",
                parameters,
                commandType: CommandType.StoredProcedure);
        }
    }
}
