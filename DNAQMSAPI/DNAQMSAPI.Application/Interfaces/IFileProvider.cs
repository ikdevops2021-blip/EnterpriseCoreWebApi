using DNAQMSAPI.Domain.Entities;

namespace DNAQMSAPI.Application.Interfaces;

public interface IFileProvider
{
    string ProviderName { get; }
    
    Task<string> UploadAsync(Stream fileStream, string fileName, string contentType, OrganizationStorageConfig config);
    Task<Stream?> DownloadAsync(string providerFileId, OrganizationStorageConfig config);
    Task<bool> DeleteAsync(string providerFileId, OrganizationStorageConfig config);
    Task<IEnumerable<string>> SearchAsync(string query, OrganizationStorageConfig config);
    Task<string> ShareAsync(string providerFileId, OrganizationStorageConfig config);
    
    // Future expansion: Token refresh, custom authorization logic could go here or inside provider implementation
}
