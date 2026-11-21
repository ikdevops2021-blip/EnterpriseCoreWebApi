using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.DTOs;
using DNAQMSAPI.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers;

public class AuthController : ApiControllerBase
{
    private readonly IUserService _userService;

    public AuthController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
    {
        if (request == null || string.IsNullOrWhiteSpace(request.Identifier) || string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Identifier and Password are required."));
        }

        try
        {
            var result = await _userService.LoginAsync(request.Identifier, request.Password);
            if (!result.Success)
            {
                return Unauthorized(result);
            }
            return ApiResponse(result);
        }
        catch (Exception ex)
        {
            return StatusCode(StatusCodes.Status500InternalServerError, AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail($"Authentication server error: {ex.Message}"));
        }
    }

    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<IActionResult> Register([FromBody] RegisterRequestDto request)
    {
        if (request == null)
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Registration payload is required."));
        }

        try
        {
            var result = await _userService.RegisterAsync(request);
            if (!result.Success)
            {
                return BadRequest(result);
            }
            return ApiResponse(result);
        }
        catch (Exception ex)
        {
            return StatusCode(StatusCodes.Status500InternalServerError, AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail($"Registration server error: {ex.Message}"));
        }
    }
}
