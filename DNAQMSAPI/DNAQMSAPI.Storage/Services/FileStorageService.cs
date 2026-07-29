using DNAQMSAPI.Application;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Entities;
using AntiGravity.Enterprise.Shared.Core.Models;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Storage.Services;

public class FileStorageService : IFileStorageService
{
    private readonly IFileProviderFactory _providerFactory;
    private readonly IDapperDBFactory _dbFactory;
    private readonly ILogger<FileStorageService> _logger;

    public FileStorageService(
        IFileProviderFactory providerFactory,
        IDapperDBFactory dbFactory,
        ILogger<FileStorageService> logger)
    {
        _providerFactory = providerFactory;
        _dbFactory = dbFactory;
        _logger = logger;
    }

    public async Task<ApiResponse<StoredFile>> UploadFileAsync(Stream fileStream, string fileName, string contentType, int userId, int? organizationId = null, string providerName = "GoogleDrive", string ipAddress = "")
    {
        var config = await GetStorageConfigAsync(organizationId ?? 0, providerName);
        if (config == null || !config.IsActive)
        {
            return ApiResponse<StoredFile>.Fail($"Storage provider {providerName} is not configured or inactive.");
        }

        var provider = _providerFactory.GetProvider(providerName);
        var providerId = await provider.UploadAsync(fileStream, fileName, contentType, config);

        var storedFile = new StoredFile
        {
            Id = Guid.NewGuid(),
            FileName = fileName,
            ContentType = contentType,
            SizeBytes = fileStream.Length,
            StorageProvider = providerName,
            PathOrUrl = providerId,
            OrganizationId = organizationId,
            CreatedBy = userId,
            CreatedDate = DateTime.UtcNow
        };

        await SaveFileMetadataAsync(storedFile);
        await LogAuditActionAsync(storedFile.Id, "Upload", userId, organizationId, ipAddress);

        _logger.LogInformation("File {FileName} uploaded successfully to {ProviderName}", fileName, providerName);
        return ApiResponse<StoredFile>.Ok(storedFile);
    }

    public async Task<ApiResponse<Stream?>> DownloadFileAsync(Guid fileId, int userId, string ipAddress = "")
    {
        var metadata = await GetFileMetadataAsync(fileId);
        if (metadata == null || metadata.IsDeleted == true)
            return ApiResponse<Stream?>.Fail("File not found.");

        var config = await GetStorageConfigAsync(metadata.OrganizationId ?? 0, metadata.StorageProvider);
        if (config == null || !config.IsActive)
            return ApiResponse<Stream?>.Fail($"Storage provider {metadata.StorageProvider} is missing.");

        var provider = _providerFactory.GetProvider(metadata.StorageProvider);
        var stream = await provider.DownloadAsync(metadata.PathOrUrl, config);
        
        await LogAuditActionAsync(fileId, "Download", userId, metadata.OrganizationId, ipAddress);

        return ApiResponse<Stream?>.Ok(stream);
    }

    public async Task<ApiResponse<bool>> DeleteFileAsync(Guid fileId, int userId, string ipAddress = "")
    {
        var metadata = await GetFileMetadataAsync(fileId);
        if (metadata == null || metadata.IsDeleted == true)
            return ApiResponse<bool>.Fail("File not found.");

        var config = await GetStorageConfigAsync(metadata.OrganizationId ?? 0, metadata.StorageProvider);
        if (config != null && config.IsActive)
        {
            var provider = _providerFactory.GetProvider(metadata.StorageProvider);
            await provider.DeleteAsync(metadata.PathOrUrl, config);
        }

        await MarkFileAsDeletedAsync(fileId);
        await LogAuditActionAsync(fileId, "Delete", userId, metadata.OrganizationId, ipAddress);
        
        _logger.LogInformation("File {FileId} deleted successfully", fileId);
        return ApiResponse<bool>.Ok(true);
    }

    public async Task<ApiResponse<IEnumerable<string>>> SearchFilesAsync(string query, int organizationId, string providerName, int userId, string ipAddress = "")
    {
        var config = await GetStorageConfigAsync(organizationId, providerName);
        if (config == null || !config.IsActive)
            return ApiResponse<IEnumerable<string>>.Fail($"Storage provider {providerName} is missing.");

        var provider = _providerFactory.GetProvider(providerName);
        var results = await provider.SearchAsync(query, config);
        
        // Log audit with empty guid since search is not file-specific
        await LogAuditActionAsync(Guid.Empty, "Search", userId, organizationId, ipAddress);

        return ApiResponse<IEnumerable<string>>.Ok(results);
    }

    public async Task<ApiResponse<string>> ShareFileAsync(Guid fileId, int userId, string ipAddress = "")
    {
        var metadata = await GetFileMetadataAsync(fileId);
        if (metadata == null || metadata.IsDeleted == true)
            return ApiResponse<string>.Fail("File not found.");

        var config = await GetStorageConfigAsync(metadata.OrganizationId ?? 0, metadata.StorageProvider);
        if (config == null || !config.IsActive)
            return ApiResponse<string>.Fail($"Storage provider {metadata.StorageProvider} is missing.");

        var provider = _providerFactory.GetProvider(metadata.StorageProvider);
        var shareLink = await provider.ShareAsync(metadata.PathOrUrl, config);
        
        await LogAuditActionAsync(fileId, "Share", userId, metadata.OrganizationId, ipAddress);

        return ApiResponse<string>.Ok(shareLink);
    }

    private async Task<OrganizationStorageConfig?> GetStorageConfigAsync(int organizationId, string providerName)
    {
        return await _dbFactory.QuerySingleAsync<OrganizationStorageConfig>(
            "pr_GetOrganizationStorageConfig", 
            new { OrganizationId = organizationId, ProviderName = providerName },
            commandType: System.Data.CommandType.StoredProcedure);
    }

    private async Task<StoredFile?> GetFileMetadataAsync(Guid fileId)
    {
        return await _dbFactory.QuerySingleAsync<StoredFile>(
            "pr_GetStoredFileMetadata", 
            new { Id = fileId },
            commandType: System.Data.CommandType.StoredProcedure);
    }

    private async Task SaveFileMetadataAsync(StoredFile file)
    {
        await _dbFactory.ExecuteAsync(
            "pr_InsertStoredFileMetadata", 
            file,
            commandType: System.Data.CommandType.StoredProcedure);
    }

    private async Task MarkFileAsDeletedAsync(Guid fileId)
    {
        await _dbFactory.ExecuteAsync(
            "pr_MarkStoredFileAsDeleted", 
            new { Id = fileId, DeletedDate = DateTime.UtcNow },
            commandType: System.Data.CommandType.StoredProcedure);
    }

    private async Task LogAuditActionAsync(Guid fileId, string action, int userId, int? organizationId, string ipAddress)
    {
        await _dbFactory.ExecuteAsync(
            "pr_InsertFileAuditLog", 
            new { 
                Guid = Guid.NewGuid(),
                FileId = fileId, 
                Action = action, 
                UserId = userId, 
                OrganizationId = organizationId, 
                IPAddress = ipAddress,
                CreatedDate = DateTime.UtcNow
            },
            commandType: System.Data.CommandType.StoredProcedure);
    }
}
