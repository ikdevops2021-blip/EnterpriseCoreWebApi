using System.Collections.Generic;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;

namespace DNAQMSAPI.Application.Services;

public interface IDataPrivacyService
{
    byte[]? EncryptField(string? plainText, int organizationId, string region = "eu-central-1");
    string? DecryptField(byte[]? cipherText, int organizationId, string region = "eu-central-1");
    string? ComputeBlindIndex(string? plainText, int organizationId);
    string NormalizeE164(string rawPhone);
    Task<OrganizationDataResidencyDto?> GetResidencyConfigAsync(int organizationId);
    Task<int> UpsertResidencyConfigAsync(UpsertDataResidencyRequest request);
    Task<GdprRightToBeForgottenResultDto> ExecuteRightToBeForgottenAsync(GdprRightToBeForgottenRequest request, int requestedByUserId);
    Task<CustomerDataExportDto> ExportCustomerDataAsync(int organizationId, string customerPhoneNumber);
    Task<RetentionPurgeResultDto> RunRetentionPurgeAsync(int organizationId);
    Task<IEnumerable<GdprAuditLogDto>> GetAuditLogsAsync(int organizationId, int pageSize = 50, int pageIndex = 1);
}
