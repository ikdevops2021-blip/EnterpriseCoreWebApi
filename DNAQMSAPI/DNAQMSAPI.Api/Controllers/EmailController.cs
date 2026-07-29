using System;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.Email.DTOs;
using DNAQMSAPI.Application.Email.Interfaces;
using DNAQMSAPI.Security.Middlewares;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/v1/[controller]")]
public class EmailController : ApiControllerBase
{
    private readonly IEmailService _emailService;
    private readonly RequestContext _requestContext;

    public EmailController(IEmailService emailService, RequestContext requestContext)
    {
        _emailService = emailService;
        _requestContext = requestContext;
    }

    /// <summary>
    /// Queues an email for background dispatching.
    /// </summary>
    [HttpPost("queue")]
    public async Task<IActionResult> QueueEmail([FromBody] EmailRequest request, [FromQuery] int priority = 0)
    {
        if (request == null || request.To == null || request.To.Count == 0)
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Invalid email request. Recipient 'To' is required."));
        }

        int centerId = _requestContext.CurrentCenterId > 0 ? _requestContext.CurrentCenterId : 1;
        var queueId = await _emailService.QueueEmailAsync(centerId, request, priority, _requestContext.UserId);

        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new { QueueId = queueId }, "Email queued successfully."));
    }

    /// <summary>
    /// Fetches the active SMTP Email Configuration for an Organization.
    /// </summary>
    [HttpGet("settings")]
    public async Task<IActionResult> GetEmailSettings([FromQuery] int organizationId = 1)
    {
        var settings = await _emailService.GetEmailSettingsAsync(organizationId);
        if (settings == null)
        {
            return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail($"No Email Settings found for Organization ID {organizationId}."));
        }

        // Mask password for security before returning
        settings.SmtpPass = "********";
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<EmailSettingsDto>.Ok(settings));
    }

    /// <summary>
    /// Saves or updates the SMTP Email Configuration for an Organization.
    /// </summary>
    [HttpPost("settings")]
    public async Task<IActionResult> SaveEmailSettings([FromBody] EmailSettingsDto settings)
    {
        if (settings == null || string.IsNullOrWhiteSpace(settings.SmtpHost) || string.IsNullOrWhiteSpace(settings.SmtpUser))
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("SmtpHost and SmtpUser are required fields."));
        }

        settings.CreatedBy = _requestContext.UserId > 0 ? _requestContext.UserId : 1;
        settings.ModifiedBy = _requestContext.UserId > 0 ? _requestContext.UserId : 1;

        var settingId = await _emailService.SaveEmailSettingsAsync(settings);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new { SettingId = settingId }, "Email settings saved successfully."));
    }

    /// <summary>
    /// Tests live connection to an SMTP Mail Server.
    /// </summary>
    [HttpPost("test-connection")]
    public async Task<IActionResult> TestSmtpConnection([FromBody] MailServerConfig config)
    {
        if (config == null || string.IsNullOrWhiteSpace(config.SmtpHost) || string.IsNullOrWhiteSpace(config.SmtpUser))
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("SmtpHost and SmtpUser are required for testing SMTP connection."));
        }

        var result = await _emailService.TestSmtpConnectionAsync(config);
        if (result.Success)
        {
            return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(null, result.Message));
        }

        return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail(result.Message));
    }
}
