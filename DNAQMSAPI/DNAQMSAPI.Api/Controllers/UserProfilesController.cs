using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.DTOs;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Security.Middlewares;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/v1/users")]
public class UserProfilesController : ApiControllerBase
{
    private readonly ILocationAndUserProfileService _profileService;
    private readonly RequestContext _requestContext;

    public UserProfilesController(ILocationAndUserProfileService profileService, RequestContext requestContext)
    {
        _profileService = profileService;
        _requestContext = requestContext;
    }

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
