using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using Dapper;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Application.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Infrastructure.Security;

public class AesGcmDataPrivacyService : IDataPrivacyService
{
    private readonly IDapperDBFactory _dbFactory;
    private readonly ILogger<AesGcmDataPrivacyService> _logger;
    private readonly byte[] _masterKey;
    private readonly byte[] _masterBlindSalt;

    public const int NonceSize = 12; // 96 bits
    public const int TagSize = 16;   // 128 bits
    public const string CorruptedFallback = "[ENCRYPTED_DATA_CORRUPTED]";

    public AesGcmDataPrivacyService(
        IDapperDBFactory dbFactory,
        IConfiguration configuration,
        ILogger<AesGcmDataPrivacyService> logger)
    {
        _dbFactory = dbFactory ?? throw new ArgumentNullException(nameof(dbFactory));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));

        // Retrieve or generate master KMS key hierarchy
        var configuredKey = configuration["Security:MasterEncryptionKey"];
        if (!string.IsNullOrWhiteSpace(configuredKey))
        {
            _masterKey = SHA256.HashData(Encoding.UTF8.GetBytes(configuredKey));
        }
        else
        {
            // Default 256-bit fallback key for local dev/testing
            _masterKey = SHA256.HashData(Encoding.UTF8.GetBytes("DQMS-ENTERPRISE-SOVEREIGN-MASTER-KMS-2026"));
        }

        var configuredBlindSalt = configuration["Security:MasterBlindIndexSalt"];
        if (!string.IsNullOrWhiteSpace(configuredBlindSalt))
        {
            _masterBlindSalt = SHA256.HashData(Encoding.UTF8.GetBytes(configuredBlindSalt));
        }
        else
        {
            _masterBlindSalt = SHA256.HashData(Encoding.UTF8.GetBytes("DQMS-BLIND-INDEX-SALT-SHA256-2026"));
        }
    }

    private byte[] DeriveTenantKey(int organizationId, string region)
    {
        var salt = BitConverter.GetBytes(organizationId);
        var info = Encoding.UTF8.GetBytes(string.IsNullOrWhiteSpace(region) ? "eu-central-1" : region.Trim().ToLowerInvariant());
        return HKDF.DeriveKey(HashAlgorithmName.SHA256, _masterKey, 32, salt, info);
    }

    private byte[] DeriveTenantBlindKey(int organizationId)
    {
        var salt = BitConverter.GetBytes(organizationId);
        return HKDF.DeriveKey(HashAlgorithmName.SHA256, _masterBlindSalt, 32, salt, Encoding.UTF8.GetBytes("blind-index"));
    }

    public string NormalizeE164(string rawPhone)
    {
        if (string.IsNullOrWhiteSpace(rawPhone)) return string.Empty;

        var cleaned = Regex.Replace(rawPhone.Trim(), @"[^\d+]", "");
        if (cleaned.StartsWith("00"))
        {
            cleaned = "+" + cleaned[2..];
        }
        else if (!cleaned.StartsWith("+") && cleaned.Length >= 9)
        {
            cleaned = "+" + cleaned;
        }

        return cleaned;
    }

    public byte[]? EncryptField(string? plainText, int organizationId, string region = "eu-central-1")
    {
        if (string.IsNullOrEmpty(plainText)) return null;

        try
        {
            var tenantKey = DeriveTenantKey(organizationId, region);
            var plainBytes = Encoding.UTF8.GetBytes(plainText);

            var nonce = new byte[NonceSize];
            RandomNumberGenerator.Fill(nonce);

            var cipherBytes = new byte[plainBytes.Length];
            var tag = new byte[TagSize];

            using var aes = new AesGcm(tenantKey, TagSize);
            aes.Encrypt(nonce, plainBytes, cipherBytes, tag);

            // Construct payload: [12-byte Nonce][16-byte Tag][Ciphertext]
            var payload = new byte[NonceSize + TagSize + cipherBytes.Length];
            Buffer.BlockCopy(nonce, 0, payload, 0, NonceSize);
            Buffer.BlockCopy(tag, 0, payload, NonceSize, TagSize);
            Buffer.BlockCopy(cipherBytes, 0, payload, NonceSize + TagSize, cipherBytes.Length);

            return payload;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to encrypt PII field for Organization {OrgId}", organizationId);
            throw;
        }
    }

    public string? DecryptField(byte[]? cipherText, int organizationId, string region = "eu-central-1")
    {
        if (cipherText == null || cipherText.Length < (NonceSize + TagSize))
        {
            return null;
        }

        try
        {
            var tenantKey = DeriveTenantKey(organizationId, region);

            var nonce = new byte[NonceSize];
            var tag = new byte[TagSize];
            var actualCipherLength = cipherText.Length - (NonceSize + TagSize);
            var actualCipherBytes = new byte[actualCipherLength];

            Buffer.BlockCopy(cipherText, 0, nonce, 0, NonceSize);
            Buffer.BlockCopy(cipherText, NonceSize, tag, 0, TagSize);
            Buffer.BlockCopy(cipherText, NonceSize + TagSize, actualCipherBytes, 0, actualCipherLength);

            var plainBytes = new byte[actualCipherLength];
            using var aes = new AesGcm(tenantKey, TagSize);
            aes.Decrypt(nonce, actualCipherBytes, tag, plainBytes);

            return Encoding.UTF8.GetString(plainBytes);
        }
        catch (CryptographicException cryptEx)
        {
            _logger.LogWarning(cryptEx, "Authentication tag verification failed for Organization {OrgId}. Tampered ciphertext detected.", organizationId);
            return CorruptedFallback;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error decrypting PII field for Organization {OrgId}", organizationId);
            return CorruptedFallback;
        }
    }

    public string? ComputeBlindIndex(string? plainText, int organizationId)
    {
        if (string.IsNullOrWhiteSpace(plainText)) return null;

        var normalized = NormalizeE164(plainText);
        var tenantBlindKey = DeriveTenantBlindKey(organizationId);

        using var hmac = new HMACSHA256(tenantBlindKey);
        var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(normalized));
        return Convert.ToHexString(hash).ToLowerInvariant();
    }

    public async Task<OrganizationDataResidencyDto?> GetResidencyConfigAsync(int organizationId)
    {
        using var conn = _dbFactory.GetConnection();
        var dynamicParams = new DynamicParameters();
        dynamicParams.Add("@p_OrganizationId", organizationId);

        var result = await conn.QueryFirstOrDefaultAsync<OrganizationDataResidencyDto>(
            "PR_S_OrganizationDataResidency",
            dynamicParams,
            commandType: CommandType.StoredProcedure);

        return result;
    }

    public async Task<int> UpsertResidencyConfigAsync(UpsertDataResidencyRequest request)
    {
        if (request == null) throw new ArgumentNullException(nameof(request));

        using var conn = _dbFactory.GetConnection();
        var dynamicParams = new DynamicParameters();
        dynamicParams.Add("@p_OrganizationId", request.OrganizationId);
        dynamicParams.Add("@p_DataRegion", request.DataRegion);
        dynamicParams.Add("@p_Jurisdiction", request.Jurisdiction);
        dynamicParams.Add("@p_KmsKeyArn", request.KmsKeyArn);
        dynamicParams.Add("@p_DataRetentionDays", request.DataRetentionDays);
        dynamicParams.Add("@p_AutoAnonymizeOnComplete", request.AutoAnonymizeOnComplete);
        dynamicParams.Add("@p_EnableBlindIndexing", request.EnableBlindIndexing);
        dynamicParams.Add("@p_AllowCrossBorderDiagnostics", request.AllowCrossBorderDiagnostics);
        dynamicParams.Add("@p_ResidencyId", dbType: DbType.Int32, direction: ParameterDirection.Output);

        await conn.ExecuteAsync("PR_IU_OrganizationDataResidency", dynamicParams, commandType: CommandType.StoredProcedure);

        var residencyId = dynamicParams.Get<int>("@p_ResidencyId");

        // Sync local cache
        _dbFactory.RegisterOrganizationRegion(request.OrganizationId, request.DataRegion);

        return residencyId;
    }

    public async Task<GdprRightToBeForgottenResultDto> ExecuteRightToBeForgottenAsync(GdprRightToBeForgottenRequest request, int requestedByUserId)
    {
        if (request == null) throw new ArgumentNullException(nameof(request));

        var blindIndex = ComputeBlindIndex(request.CustomerPhoneNumber, request.OrganizationId);
        if (string.IsNullOrWhiteSpace(blindIndex))
        {
            return new GdprRightToBeForgottenResultDto
            {
                Success = false,
                OrganizationId = request.OrganizationId,
                AffectedRecordsCount = 0,
                Message = "Invalid phone number provided for Article 17 erasure."
            };
        }

        using var conn = _dbFactory.GetConnection();
        var dynamicParams = new DynamicParameters();
        dynamicParams.Add("@p_OrganizationId", request.OrganizationId);
        dynamicParams.Add("@p_PhoneBlindIndex", blindIndex);
        dynamicParams.Add("@p_RequestedByUserId", requestedByUserId > 0 ? requestedByUserId : 1);
        dynamicParams.Add("@p_AuditReason", request.Reason ?? "GDPR Article 17 Right-To-Be-Forgotten Request");
        dynamicParams.Add("@p_AffectedRecordsCount", dbType: DbType.Int32, direction: ParameterDirection.Output);

        await conn.ExecuteAsync("PR_IU_GdprRightToBeForgotten", dynamicParams, commandType: CommandType.StoredProcedure);

        var affected = dynamicParams.Get<int>("@p_AffectedRecordsCount");

        return new GdprRightToBeForgottenResultDto
        {
            Success = true,
            OrganizationId = request.OrganizationId,
            AffectedRecordsCount = affected,
            Message = $"Article 17 erasure complete. {affected} records scrubbed and tombstones applied."
        };
    }

    public async Task<CustomerDataExportDto> ExportCustomerDataAsync(int organizationId, string customerPhoneNumber)
    {
        var export = new CustomerDataExportDto
        {
            OrganizationId = organizationId,
            CustomerPhoneNumber = customerPhoneNumber
        };

        var blindIndex = ComputeBlindIndex(customerPhoneNumber, organizationId);
        if (string.IsNullOrWhiteSpace(blindIndex))
        {
            return export;
        }

        using var conn = _dbFactory.GetConnection();
        var sql = @"
            SELECT 
                t.Id AS TokenId,
                t.TokenNumber,
                p.ProcessName,
                c.CounterName,
                t.TokenStatus,
                t.IssuedTime,
                t.CalledTime,
                t.CompletedTime,
                DATEDIFF(SECOND, t.IssuedTime, ISNULL(t.CalledTime, t.IssuedTime)) AS WaitDurationSeconds,
                DATEDIFF(SECOND, ISNULL(t.CalledTime, t.IssuedTime), ISNULL(t.CompletedTime, ISNULL(t.CalledTime, t.IssuedTime))) AS ServiceDurationSeconds
            FROM dbo.TokenTransaction t
            LEFT JOIN dbo.Process p ON t.ProcessId = p.Id
            LEFT JOIN dbo.Counter c ON t.CounterId = c.Id
            WHERE t.OrganizationId = @OrgId
              AND (t.PhoneBlindIndex = @BlindIndex OR t.CustomerPhone = @RawPhone)
            ORDER BY t.IssuedTime DESC;";

        var rows = await conn.QueryAsync<CustomerTokenVisitExportItem>(sql, new
        {
            OrgId = organizationId,
            BlindIndex = blindIndex,
            RawPhone = customerPhoneNumber
        });

        export.Visits = rows.ToList();
        return export;
    }

    public async Task<RetentionPurgeResultDto> RunRetentionPurgeAsync(int organizationId)
    {
        using var conn = _dbFactory.GetConnection();
        var dynamicParams = new DynamicParameters();
        dynamicParams.Add("@p_OrganizationId", organizationId);
        dynamicParams.Add("@p_PurgedCount", dbType: DbType.Int32, direction: ParameterDirection.Output);

        await conn.ExecuteAsync("PR_IU_PurgeExpiredDataRetention", dynamicParams, commandType: CommandType.StoredProcedure);

        var purged = dynamicParams.Get<int>("@p_PurgedCount");

        return new RetentionPurgeResultDto
        {
            OrganizationId = organizationId,
            PurgedRecordsCount = purged,
            Message = $"Retention purge executed. {purged} expired customer records scrubbed."
        };
    }

    public async Task<IEnumerable<GdprAuditLogDto>> GetAuditLogsAsync(int organizationId, int pageSize = 50, int pageIndex = 1)
    {
        using var conn = _dbFactory.GetConnection();
        var dynamicParams = new DynamicParameters();
        dynamicParams.Add("@p_OrganizationId", organizationId);
        dynamicParams.Add("@p_PageSize", pageSize);
        dynamicParams.Add("@p_PageIndex", pageIndex);

        return await conn.QueryAsync<GdprAuditLogDto>(
            "PR_S_GdprAuditLogs",
            dynamicParams,
            commandType: CommandType.StoredProcedure);
    }
}
