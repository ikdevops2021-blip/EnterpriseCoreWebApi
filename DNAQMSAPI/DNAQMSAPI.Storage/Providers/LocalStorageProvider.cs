using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Entities;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Storage.Providers;

public class LocalStorageProvider : IFileProvider
{
    private readonly ILogger<LocalStorageProvider> _logger;
    private readonly string _basePath;
    public string ProviderName => "Local";

    public LocalStorageProvider(ILogger<LocalStorageProvider> logger)
    {
        _logger = logger;
        _basePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App_Data", "Uploads");
        
        if (!Directory.Exists(_basePath))
        {
            Directory.CreateDirectory(_basePath);
        }
    }

    public async Task<string> UploadAsync(Stream fileStream, string fileName, string contentType, OrganizationStorageConfig config)
    {
        string uniqueId = Guid.NewGuid().ToString("N");
        string extension = Path.GetExtension(fileName);
        string fileKey = $"{uniqueId}{extension}";
        string fullPath = Path.Combine(_basePath, fileKey);

        _logger.LogInformation("Writing file {FileName} to Local Storage at {FullPath}", fileName, fullPath);

        using (var fs = new FileStream(fullPath, FileMode.Create, FileAccess.Write))
        {
            await fileStream.CopyToAsync(fs);
        }

        return fileKey;
    }

    public Task<Stream?> DownloadAsync(string providerFileId, OrganizationStorageConfig config)
    {
        string fullPath = Path.Combine(_basePath, providerFileId);
        _logger.LogInformation("Reading file from Local Storage at {FullPath}", fullPath);

        if (!File.Exists(fullPath))
        {
            return Task.FromResult<Stream?>(null);
        }

        var stream = new FileStream(fullPath, FileMode.Open, FileAccess.Read);
        return Task.FromResult<Stream?>(stream);
    }

    public Task<bool> DeleteAsync(string providerFileId, OrganizationStorageConfig config)
    {
        string fullPath = Path.Combine(_basePath, providerFileId);
        _logger.LogInformation("Deleting file from Local Storage at {FullPath}", fullPath);

        if (File.Exists(fullPath))
        {
            File.Delete(fullPath);
            return Task.FromResult(true);
        }

        return Task.FromResult(false);
    }

    public Task<IEnumerable<string>> SearchAsync(string query, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Searching Local Storage for {Query}", query);
        var files = Directory.GetFiles(_basePath, $"*{query}*")
                             .Select(Path.GetFileName)
                             .Where(name => name != null)
                             .Cast<string>();
                             
        return Task.FromResult(files);
    }

    public Task<string> ShareAsync(string providerFileId, OrganizationStorageConfig config)
    {
        _logger.LogInformation("Generating share link for Local Storage file {ProviderFileId}", providerFileId);
        return Task.FromResult($"/api/v1/storage/download/direct/{providerFileId}");
    }
}
