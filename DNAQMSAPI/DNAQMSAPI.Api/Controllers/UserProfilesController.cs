using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.DTOs;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Security.Middlewares;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

using DNAQMSAPI.Domain.Entities;
using Microsoft.AspNetCore.Hosting;
using System.IO;

namespace DNAQMSAPI.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/v1/users")]
public class UserProfilesController : ApiControllerBase
{
    private readonly ILocationAndUserProfileService _profileService;
    private readonly IUserService _userService;
    private readonly IWebHostEnvironment _env;
    private readonly RequestContext _requestContext;

    public UserProfilesController(
        ILocationAndUserProfileService profileService,
        IUserService userService,
        IWebHostEnvironment env,
        RequestContext requestContext)
    {
        _profileService = profileService;
        _userService = userService;
        _env = env;
        _requestContext = requestContext;
    }

    #region User CRUD and Avatar Endpoints
    [HttpGet]
    [AllowAnonymous]
    public async Task<IActionResult> GetAllUsers()
    {
        var users = await _userService.GetAllUsersAsync();
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<IEnumerable<User>>.Ok(users));
    }

    [HttpGet("{id:int}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetUserById(int id)
    {
        var user = await _userService.GetUserByIdAsync(id);
        if (user == null) return NotFound(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("User not found."));
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<User>.Ok(user));
    }

    [HttpPost]
    [AllowAnonymous]
    public async Task<IActionResult> CreateUser([FromBody] User request)
    {
        if (request == null) return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        request.CreatedBy = _requestContext.UserId > 0 ? _requestContext.UserId : 1;
        if (string.IsNullOrEmpty(request.PasswordHash)) request.PasswordHash = "Welc0me@555";
        var created = await _userService.CreateUserAsync(request);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<User>.Ok(created, "User created successfully."));
    }

    [HttpPut("{id:int}")]
    [AllowAnonymous]
    public async Task<IActionResult> UpdateUser(int id, [FromBody] User userUpdate)
    {
        if (userUpdate == null) return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        userUpdate.Id = id;
        userUpdate.ModifiedBy = _requestContext.UserId > 0 ? _requestContext.UserId : 1;
        var success = await _userService.UpdateUserAsync(userUpdate);
        return success 
            ? ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<bool>.Ok(true, "User updated successfully."))
            : BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Failed to update user."));
    }

    public class AvatarUploadRequest
    {
        public string? Base64Data { get; set; }
        public string? FileName { get; set; }
    }

    [HttpPost("{id:int}/avatar")]
    [AllowAnonymous]
    public async Task<IActionResult> UploadAvatar(int id)
    {
        byte[] fileBytes;
        string extension = ".png";
        string fileName = $"avatar_{id}.png";

        if (Request.HasFormContentType && Request.Form.Files.Count > 0)
        {
            var file = Request.Form.Files[0];
            using var ms = new MemoryStream();
            await file.CopyToAsync(ms);
            fileBytes = ms.ToArray();
            fileName = file.FileName;
            extension = Path.GetExtension(file.FileName);
        }
        else
        {
            using var reader = new StreamReader(Request.Body);
            var body = await reader.ReadToEndAsync();
            var jsonUpload = string.IsNullOrWhiteSpace(body) 
                ? null 
                : System.Text.Json.JsonSerializer.Deserialize<AvatarUploadRequest>(body, new System.Text.Json.JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            if (jsonUpload != null && !string.IsNullOrWhiteSpace(jsonUpload.Base64Data))
            {
                var rawBase64 = jsonUpload.Base64Data;
                if (rawBase64.Contains(","))
                {
                    rawBase64 = rawBase64.Substring(rawBase64.IndexOf(",") + 1);
                }
                fileBytes = Convert.FromBase64String(rawBase64);
                if (!string.IsNullOrEmpty(jsonUpload.FileName))
                {
                    fileName = jsonUpload.FileName;
                    extension = Path.GetExtension(jsonUpload.FileName);
                }
                if (string.IsNullOrEmpty(extension)) extension = ".png";
            }
            else
            {
                return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("No image file or base64 data provided."));
            }
        }

        var root = _env.WebRootPath ?? _env.ContentRootPath;
        var uploadDir = Path.Combine(root, "uploads", "avatars");
        if (!Directory.Exists(uploadDir))
        {
            Directory.CreateDirectory(uploadDir);
        }

        var uniqueFileName = $"user_{id}_{DateTime.UtcNow.Ticks}{extension}";
        var physicalPath = Path.Combine(uploadDir, uniqueFileName);
        await System.IO.File.WriteAllBytesAsync(physicalPath, fileBytes);

        var avatarUrl = $"/api/v1/users/{id}/avatar?v={DateTime.UtcNow.Ticks}";
        await _userService.UpdateProfileImageAsync(id, avatarUrl);

        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new 
        { 
            AvatarUrl = avatarUrl,
            UserId = id,
            FileName = uniqueFileName
        }, "Profile image uploaded and stored in DB successfully."));
    }

    [HttpGet("{id:int}/avatar")]
    [AllowAnonymous]
    public async Task<IActionResult> GetAvatar(int id)
    {
        var root = _env.WebRootPath ?? _env.ContentRootPath;
        var uploadDir = Path.Combine(root, "uploads", "avatars");
        if (Directory.Exists(uploadDir))
        {
            var files = Directory.GetFiles(uploadDir, $"user_{id}_*.*");
            if (files.Length > 0)
            {
                var latestFile = files.OrderByDescending(System.IO.File.GetLastWriteTimeUtc).First();
                var ext = Path.GetExtension(latestFile).ToLowerInvariant();
                var contentType = ext switch
                {
                    ".jpg" or ".jpeg" => "image/jpeg",
                    ".png" => "image/png",
                    ".gif" => "image/gif",
                    ".webp" => "image/webp",
                    _ => "application/octet-stream"
                };
                var stream = System.IO.File.OpenRead(latestFile);
                return File(stream, contentType);
            }
        }

        var user = await _userService.GetUserByIdAsync(id);
        if (!string.IsNullOrEmpty(user?.ProfileImageUrl) && !user.ProfileImageUrl.StartsWith("/api/v1/users/"))
        {
            return Redirect(user.ProfileImageUrl);
        }

        return NotFound("Avatar not found.");
    }
    #endregion

    #region User Addresses Endpoints
    [HttpGet("{userId:int}/addresses")]
    public async Task<IActionResult> GetUserAddresses(int userId)
    {
        return ApiResponse(await _profileService.GetUserAddressesAsync(userId));
    }

    [HttpGet("addresses/{addressId:long}")]
    public async Task<IActionResult> GetUserAddressById(long addressId)
    {
        return ApiResponse(await _profileService.GetUserAddressByIdAsync(addressId));
    }

    [HttpPost("{userId:int}/addresses")]
    public async Task<IActionResult> CreateUserAddress(int userId, [FromBody] SaveUserAddressRequestDto request)
    {
        if (request == null) return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        request.AddressId = 0;
        request.UserId = userId;
        return ApiResponse(await _profileService.SaveUserAddressAsync(request, _requestContext.UserId));
    }

    [HttpPut("{userId:int}/addresses/{addressId:long}")]
    public async Task<IActionResult> UpdateUserAddress(int userId, long addressId, [FromBody] SaveUserAddressRequestDto request)
    {
        if (request == null) return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        request.AddressId = addressId;
        request.UserId = userId;
        return ApiResponse(await _profileService.SaveUserAddressAsync(request, _requestContext.UserId));
    }

    [HttpDelete("addresses/{addressId:long}")]
    public async Task<IActionResult> DeleteUserAddress(long addressId)
    {
        return ApiResponse(await _profileService.DeleteUserAddressAsync(addressId, _requestContext.UserId));
    }
    #endregion

    #region User Contacts Endpoints
    [HttpGet("{userId:int}/contacts")]
    public async Task<IActionResult> GetUserContacts(int userId, [FromQuery] bool emergencyOnly = false)
    {
        return ApiResponse(await _profileService.GetUserContactsAsync(userId, emergencyOnly));
    }

    [HttpGet("contacts/{contactId:long}")]
    public async Task<IActionResult> GetUserContactById(long contactId)
    {
        return ApiResponse(await _profileService.GetUserContactByIdAsync(contactId));
    }

    [HttpPost("{userId:int}/contacts")]
    public async Task<IActionResult> CreateUserContact(int userId, [FromBody] SaveUserContactRequestDto request)
    {
        if (request == null) return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        request.ContactId = 0;
        request.UserId = userId;
        return ApiResponse(await _profileService.SaveUserContactAsync(request, _requestContext.UserId));
    }

    [HttpPut("{userId:int}/contacts/{contactId:long}")]
    public async Task<IActionResult> UpdateUserContact(int userId, long contactId, [FromBody] SaveUserContactRequestDto request)
    {
        if (request == null) return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        request.ContactId = contactId;
        request.UserId = userId;
        return ApiResponse(await _profileService.SaveUserContactAsync(request, _requestContext.UserId));
    }

    [HttpDelete("contacts/{contactId:long}")]
    public async Task<IActionResult> DeleteUserContact(long contactId)
    {
        return ApiResponse(await _profileService.DeleteUserContactAsync(contactId, _requestContext.UserId));
    }
    #endregion
}
