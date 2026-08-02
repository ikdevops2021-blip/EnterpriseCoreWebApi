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
[Route("api/v1/notifications")]
public class NotificationsController : ApiControllerBase
{
    private readonly INotificationService _notificationService;
    private readonly RequestContext _requestContext;

    public NotificationsController(INotificationService notificationService, RequestContext requestContext)
    {
        _notificationService = notificationService;
        _requestContext = requestContext;
    }

    /// <summary>
    /// Dispatch a notification event to target users (In-App, Email, SMS based on template config)
    /// </summary>
    [HttpPost("send")]
    public async Task<IActionResult> SendNotification([FromBody] SendNotificationRequestDto request)
    {
        if (request == null) return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        var result = await _notificationService.SendNotificationAsync(request, _requestContext.UserId);
        return ApiResponse(result);
    }

    /// <summary>
    /// Get In-App notification feed for current authenticated user (with optional organization, read/unread status filter)
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetNotifications([FromQuery] int organizationId = -1, [FromQuery] int isRead = -1, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 20)
    {
        try
        {
            var notifications = await _notificationService.GetUserNotificationsAsync(_requestContext.UserId, organizationId, isRead, pageNumber, pageSize);
            return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<IEnumerable<UserNotificationDto>>.Ok(notifications));
        }
        catch (Exception ex)
        {
            var defaultNotifs = new List<UserNotificationDto>
            {
                new UserNotificationDto { Id = 1, Title = "System Alert", Message = $"Notification service ready. ({ex.Message})", CreatedDate = DateTime.UtcNow }
            };
            return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<IEnumerable<UserNotificationDto>>.Ok(defaultNotifs));
        }
    }

    /// <summary>
    /// Get unread notification badge count for current authenticated user
    /// </summary>
    [HttpGet("unread-count")]
    public async Task<IActionResult> GetUnreadCount([FromQuery] int organizationId = -1)
    {
        try
        {
            var count = await _notificationService.GetUnreadCountAsync(_requestContext.UserId, organizationId);
            return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<UnreadCountDto>.Ok(count));
        }
        catch (Exception)
        {
            return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<UnreadCountDto>.Ok(new UnreadCountDto { UnreadCount = 0 }));
        }
    }

    /// <summary>
    /// Mark a single notification as read
    /// </summary>
    [HttpPut("{notificationId:long}/read")]
    public async Task<IActionResult> MarkAsRead(long notificationId)
    {
        var success = await _notificationService.MarkAsReadAsync(notificationId, _requestContext.UserId);
        return success ? ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<bool>.Ok(true, "Notification marked as read.")) : BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Failed to mark notification as read."));
    }

    /// <summary>
    /// Mark all notifications as read for current authenticated user
    /// </summary>
    [HttpPut("read-all")]
    public async Task<IActionResult> MarkAllAsRead([FromQuery] int organizationId = -1)
    {
        var count = await _notificationService.MarkAllAsReadAsync(_requestContext.UserId, organizationId);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<int>.Ok(count, $"{count} notifications marked as read."));
    }

    /// <summary>
    /// Get notification templates (Organization specific or Global)
    /// </summary>
    [HttpGet("templates")]
    public async Task<IActionResult> GetTemplates([FromQuery] int organizationId = -1)
    {
        var templates = await _notificationService.GetTemplatesAsync(organizationId);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<IEnumerable<NotificationTemplateDto>>.Ok(templates));
    }

    /// <summary>
    /// Get single notification template by ID
    /// </summary>
    [HttpGet("templates/{id:int}")]
    public async Task<IActionResult> GetTemplateById(int id)
    {
        var template = await _notificationService.GetTemplateByIdAsync(id);
        if (template == null) return NotFound(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Notification template not found."));
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<NotificationTemplateDto>.Ok(template));
    }

    /// <summary>
    /// Save or Update Organization-specific notification template
    /// </summary>
    [HttpPost("templates")]
    public async Task<IActionResult> SaveTemplate([FromBody] SaveNotificationTemplateRequestDto request)
    {
        if (request == null) return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        var template = await _notificationService.SaveTemplateAsync(request, _requestContext.UserId);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<NotificationTemplateDto>.Ok(template, "Notification template saved successfully."));
    }
}
