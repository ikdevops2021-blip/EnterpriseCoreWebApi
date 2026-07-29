using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Domain.Entities;

namespace DNAQMSAPI.Application.Interfaces;

public interface IFileStorageService
{
    Task<ApiResponse<StoredFile>> UploadFileAsync(Stream fileStream, string fileName, string contentType, int userId, int? organizationId = null, string providerName = "GoogleDrive", string ipAddress = "");
    Task<ApiResponse<Stream?>> DownloadFileAsync(Guid fileId, int userId, string ipAddress = "");
    Task<ApiResponse<bool>> DeleteFileAsync(Guid fileId, int userId, string ipAddress = "");
    Task<ApiResponse<IEnumerable<string>>> SearchFilesAsync(string query, int organizationId, string providerName, int userId, string ipAddress = "");
    Task<ApiResponse<string>> ShareFileAsync(Guid fileId, int userId, string ipAddress = "");
}
