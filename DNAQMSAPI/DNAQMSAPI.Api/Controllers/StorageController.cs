using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc;
using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using Microsoft.AspNetCore.Http;
using DNAQMSAPI.Application.Interfaces;
using System.Security.Claims;

namespace DNAQMSAPI.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class StorageController : ApiControllerBase
{
    private readonly IFileStorageService _storageService;

    public StorageController(IFileStorageService storageService)
    {
        _storageService = storageService;
    }

    private int GetCurrentUserId()
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier);
        return claim != null && int.TryParse(claim.Value, out int id) ? id : 1; // Defaulting to 1 for mock
    }

    private string GetClientIpAddress()
    {
        return HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";
    }

    [HttpPost("upload")]
    public async Task<IActionResult> UploadFile(IFormFile file, [FromQuery] int? organizationId, [FromQuery] string provider = "GoogleDrive")
    {
        if (file == null || file.Length == 0)
            return BadRequest("No file uploaded.");

        using var stream = file.OpenReadStream();
        var result = await _storageService.UploadFileAsync(stream, file.FileName, file.ContentType, GetCurrentUserId(), organizationId, provider, GetClientIpAddress());
        
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpGet("download/{id}")]
    public async Task<IActionResult> DownloadFile(Guid id)
    {
        var result = await _storageService.DownloadFileAsync(id, GetCurrentUserId(), GetClientIpAddress());
        
        if (!result.Success || result.Data == null)
            return NotFound(result.Message);

        return File(result.Data, "application/octet-stream");
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteFile(Guid id)
    {
        var result = await _storageService.DeleteFileAsync(id, GetCurrentUserId(), GetClientIpAddress());
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpGet("search")]
    public async Task<IActionResult> SearchFiles([FromQuery] string query, [FromQuery] int organizationId, [FromQuery] string provider)
    {
        var result = await _storageService.SearchFilesAsync(query, organizationId, provider, GetCurrentUserId(), GetClientIpAddress());
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpPost("{id}/share")]
    public async Task<IActionResult> ShareFile(Guid id)
    {
        var result = await _storageService.ShareFileAsync(id, GetCurrentUserId(), GetClientIpAddress());
        return result.Success ? Ok(result) : BadRequest(result);
    }
}
