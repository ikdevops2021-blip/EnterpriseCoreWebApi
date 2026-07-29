using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Entities;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Storage.Providers;

public class AwsS3Provider : IFileProvider
{
    private readonly ILogger<AwsS3Provider> _logger;
    public string ProviderName => "AWS";

    public AwsS3Provider(ILogger<AwsS3Provider> logger)
    {
        _logger = logger;
    }

    public Task<string> UploadAsync(Stream fileStream, string fileName, string contentType, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Uploading {FileName} to AWS S3", fileName);
        return Task.FromResult($"s3_file_{Guid.NewGuid():N}");
    }

    public Task<Stream?> DownloadAsync(string providerFileId, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Downloading {ProviderFileId} from AWS S3", providerFileId);
        return Task.FromResult<Stream?>(new MemoryStream());
    }

    public Task<bool> DeleteAsync(string providerFileId, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Deleting {ProviderFileId} from AWS S3", providerFileId);
        return Task.FromResult(true);
    }

    public Task<IEnumerable<string>> SearchAsync(string query, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Searching AWS S3 for prefix {Query}", query);
        return Task.FromResult<IEnumerable<string>>(new List<string>());
    }

    public Task<string> ShareAsync(string providerFileId, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Generating Pre-signed URL for {ProviderFileId} in AWS S3", providerFileId);
        return Task.FromResult($"https://s3.amazonaws.com/mock-bucket/{providerFileId}?sig=mock");
    }
}
