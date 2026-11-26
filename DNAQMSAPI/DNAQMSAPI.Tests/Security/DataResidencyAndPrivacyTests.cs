using System.Security.Cryptography;
using System.Text;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using DNAQMSAPI.Application.Services;
using DNAQMSAPI.Infrastructure.Data;
using DNAQMSAPI.Infrastructure.Security;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using Xunit;

namespace DNAQMSAPI.Tests.Security;

public class DataResidencyAndPrivacyTests
{
    private readonly IConfiguration _configuration;
    private readonly IOptions<DatabaseSettings> _dbSettingsOptions;
    private readonly DapperDBFactory _dbFactory;
    private readonly AesGcmDataPrivacyService _privacyService;

    public DataResidencyAndPrivacyTests()
    {
        var inMemorySettings = new Dictionary<string, string?>
        {
            {"Security:MasterEncryptionKey", "DQMS-ENTERPRISE-SOVEREIGN-MASTER-KMS-2026"},
            {"Security:MasterBlindIndexSalt", "DQMS-ENTERPRISE-BLIND-INDEX-SALT-2026"},
            {"DataResidency:DefaultRegion", "eu-central-1"},
            {"ConnectionStrings:DefaultConnection", "Server=localhost;Database=DQMS_DEFAULT;User Id=sa;Password=Pass!;TrustServerCertificate=True;"}
        };

        _configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(inMemorySettings)
            .Build();

        var dbSettings = new DatabaseSettings
        {
            DefaultConnectionName = "DefaultConnection",
            Databases = new List<DatabaseConfig>
            {
                new() { Name = "DefaultConnection", Type = "SqlServer", ConnectionString = "Server=127.0.0.1;Database=DQMS_DEFAULT;Connection Timeout=1;", Timeout = 1 },
                new() { Name = "eu-central-1", Type = "SqlServer", ConnectionString = "Server=127.0.0.1;Database=DQMS_EU;Connection Timeout=1;", Timeout = 1 },
                new() { Name = "me-central-1", Type = "SqlServer", ConnectionString = "Server=127.0.0.1;Database=DQMS_UAE;Connection Timeout=1;", Timeout = 1 },
                new() { Name = "me-south-1", Type = "SqlServer", ConnectionString = "Server=127.0.0.1;Database=DQMS_KSA;Connection Timeout=1;", Timeout = 1 }
            }
        };

        _dbSettingsOptions = Options.Create(dbSettings);
        _dbFactory = new DapperDBFactory(_dbSettingsOptions);

        _privacyService = new AesGcmDataPrivacyService(
            _dbFactory,
            _configuration,
            NullLogger<AesGcmDataPrivacyService>.Instance
        );
    }

    [Fact]
    public void AesGcm_Roundtrip_EncryptDecrypt_Succeeds()
    {
        // Arrange
        const string plainText = "John Doe Customer - Confidential PII";
        const int orgId = 101;

        // Act
        var encryptedBytes = _privacyService.EncryptField(plainText, orgId, "eu-central-1");
        var decryptedText = _privacyService.DecryptField(encryptedBytes, orgId, "eu-central-1");

        // Assert
        Assert.NotNull(encryptedBytes);
        Assert.NotEmpty(encryptedBytes);
        Assert.Equal(plainText, decryptedText);
    }

    [Fact]
    public void AesGcm_TamperedCiphertext_ReturnsCorruptedFallback()
    {
        // Arrange
        const string plainText = "Sensitive PII Data";
        const int orgId = 101;
        var encryptedBytes = _privacyService.EncryptField(plainText, orgId, "eu-central-1")!;

        // Tamper with GCM tag (last 16 bytes)
        var tampered = (byte[])encryptedBytes.Clone();
        tampered[^1] ^= 0xFF;

        // Act
        var decrypted = _privacyService.DecryptField(tampered, orgId, "eu-central-1");

        // Assert - Fail closed on tampering: GCM authentication tag mismatch
        Assert.Equal(AesGcmDataPrivacyService.CorruptedFallback, decrypted);
    }

    [Fact]
    public void NormalizePhone_VariousFormats_ProducesConsistentE164()
    {
        // Act & Assert
        Assert.Equal("+971501234567", _privacyService.NormalizeE164("+971 50 123 4567"));
        Assert.Equal("+971501234567", _privacyService.NormalizeE164("00971501234567"));
        Assert.Equal("+971501234567", _privacyService.NormalizeE164("00971 (50) 123-4567"));
        Assert.Equal("+15551234567", _privacyService.NormalizeE164("+1 (555) 123-4567"));
        Assert.Equal("+447911123456", _privacyService.NormalizeE164("0044 7911 123456"));
    }

    [Fact]
    public void ComputeBlindIndex_IsDeterministicAndMatchesHex64()
    {
        // Arrange
        const int orgId = 101;
        const string phone1 = "+971501234567";
        const string phone2 = "+971 50 123 4567"; // Equivalent after normalization
        const string phoneOther = "+971509999999";

        // Act
        var hash1 = _privacyService.ComputeBlindIndex(phone1, orgId);
        var hash2 = _privacyService.ComputeBlindIndex(phone2, orgId);
        var hashOther = _privacyService.ComputeBlindIndex(phoneOther, orgId);

        // Assert
        Assert.NotNull(hash1);
        Assert.Equal(64, hash1.Length); // HMAC-SHA256 in hex
        Assert.Equal(hash1, hash2); // Deterministic equality
        Assert.NotEqual(hash1, hashOther); // Differentiation
    }

    [Fact]
    public void DapperDBFactory_FailClosedSovereignty_ThrowsOnUnmappedOrg()
    {
        // Arrange
        var factory = new DapperDBFactory(_dbSettingsOptions);

        // Act & Assert
        // Unmapped organization (e.g. 99999) must fail closed with ERR_UNMAPPED_DATA_REGION
        var ex = Assert.Throws<InvalidOperationException>(() =>
        {
            factory.GetConnectionForOrganization(99999);
        });

        Assert.Contains("ERR_UNMAPPED_DATA_REGION", ex.Message);
        Assert.Contains("Access denied", ex.Message);
    }

    [Fact]
    public void DapperDBFactory_DynamicRegistration_ResolvesCorrectRegion()
    {
        // Arrange
        var factory = new DapperDBFactory(_dbSettingsOptions);

        // Act
        factory.RegisterOrganizationRegion(501, "eu-central-1");
        factory.RegisterOrganizationRegion(502, "me-central-1");

        var region1 = factory.ResolveRegionForOrganization(501);
        var region2 = factory.ResolveRegionForOrganization(502);

        // Assert
        Assert.Equal("eu-central-1", region1);
        Assert.Equal("me-central-1", region2);

        // Getting connection for registered region creates connection with target regional string
        using var connEu = factory.GetConnectionForRegion("eu-central-1");
        Assert.Contains("DQMS_EU", connEu.ConnectionString);

        using var connMe = factory.GetConnectionForRegion("me-central-1");
        Assert.Contains("DQMS_UAE", connMe.ConnectionString);
    }

    [Fact]
    public void RightToBeForgotten_Model_ValidatesSubjectErasureFields()
    {
        // Arrange
        var req = new GdprRightToBeForgottenRequest
        {
            OrganizationId = 101,
            CustomerPhoneNumber = "+971 50 123 4567",
            Reason = "GDPR Article 17 Erasure Notice from Data Protection Officer"
        };

        // Assert
        Assert.Equal(101, req.OrganizationId);
        Assert.Equal("+971 50 123 4567", req.CustomerPhoneNumber);
        Assert.Contains("Article 17", req.Reason);
    }
}
