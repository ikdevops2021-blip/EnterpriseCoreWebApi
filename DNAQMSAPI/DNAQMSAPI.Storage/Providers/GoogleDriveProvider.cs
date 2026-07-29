using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Entities;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Storage.Providers;

public class GoogleDriveProvider : IFileProvider
{
    private readonly ILogger<GoogleDriveProvider> _logger;
    public string ProviderName => "GoogleDrive";

    public GoogleDriveProvider(ILogger<GoogleDriveProvider> logger)
    {
        _logger = logger;
    }

    public Task<string> UploadAsync(Stream fileStream, string fileName, string contentType, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Uploading {FileName} to Google Drive", fileName);
        // Note: Real implementation uses Google.Apis.Drive.v3
        // We parse config.ConfigurationJson for OAuth credentials.
        return Task.FromResult($"gdrive_file_{Guid.NewGuid():N}");
    }

    public Task<Stream?> DownloadAsync(string providerFileId, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Downloading {ProviderFileId} from Google Drive", providerFileId);
        // Mock returning an empty stream
        return Task.FromResult<Stream?>(new MemoryStream());
    }

    public Task<bool> DeleteAsync(string providerFileId, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Deleting {ProviderFileId} from Google Drive", providerFileId);
        return Task.FromResult(true);
    }

    public Task<IEnumerable<string>> SearchAsync(string query, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Searching Google Drive for {Query}", query);
        return Task.FromResult<IEnumerable<string>>(new List<string>());
    }

    public Task<string> ShareAsync(string providerFileId, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Generating Share link for {ProviderFileId} in Google Drive", providerFileId);
        return Task.FromResult($"https://drive.google.com/file/d/{providerFileId}/view");
    }
}
