using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Entities;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Storage.Providers;

public class AzureBlobProvider : IFileProvider
{
    private readonly ILogger<AzureBlobProvider> _logger;
    public string ProviderName => "Azure";

    public AzureBlobProvider(ILogger<AzureBlobProvider> logger)
    {
        _logger = logger;
    }

    public Task<string> UploadAsync(Stream fileStream, string fileName, string contentType, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Uploading {FileName} to Azure Blob", fileName);
        return Task.FromResult($"azure_blob_{Guid.NewGuid():N}");
    }

    public Task<Stream?> DownloadAsync(string providerFileId, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Downloading {ProviderFileId} from Azure Blob", providerFileId);
        return Task.FromResult<Stream?>(new MemoryStream());
    }

    public Task<bool> DeleteAsync(string providerFileId, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Deleting {ProviderFileId} from Azure Blob", providerFileId);
        return Task.FromResult(true);
    }

    public Task<IEnumerable<string>> SearchAsync(string query, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Searching Azure Blob for {Query}", query);
        return Task.FromResult<IEnumerable<string>>(new List<string>());
    }

    public Task<string> ShareAsync(string providerFileId, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Generating SAS Token link for {ProviderFileId} in Azure Blob", providerFileId);
        return Task.FromResult($"https://mockaccount.blob.core.windows.net/mock-container/{providerFileId}?sp=r&st=mock&sv=mock&sr=b&sig=mock");
    }
}
