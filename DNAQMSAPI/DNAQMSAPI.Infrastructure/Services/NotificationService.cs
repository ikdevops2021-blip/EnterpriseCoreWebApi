using System.Data;
using System.Text.RegularExpressions;
using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.DTOs;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Entities;
using DNAQMSAPI.Infrastructure.Models;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Infrastructure.Services;

public class NotificationService : INotificationService
{
    private readonly IDapperDBFactory _dbFactory;
    private readonly IUserService _userService;
    private readonly ILogger<NotificationService> _logger;

    public NotificationService(IDapperDBFactory dbFactory, IUserService userService, ILogger<NotificationService> logger)
    {
        _dbFactory = dbFactory;
        _userService = userService;
        _logger = logger;
    }

    public async Task<ApiResponse<bool>> SendNotificationAsync(SendNotificationRequestDto request, int performedByUserId)
    {
        var eventCode = request.EventCode ?? string.Empty;
        var eventId = request.EventId ?? -1;

        if (string.IsNullOrWhiteSpace(eventCode) && eventId <= 0)
        {
            return ApiResponse<bool>.Fail("Either EventCode or EventId is required.");
        }

        if (request.TargetUserIds == null || request.TargetUserIds.Count == 0)
        {
            return ApiResponse<bool>.Fail("TargetUserIds cannot be empty.");
        }

        // 1. Resolve Center/Organization-specific template (or fall back to Global System template)
        var template = await GetTemplateByEventAsync(eventCode, request.OrganizationId, eventId);
        if (template == null)
        {
            _logger.LogWarning("No notification template found for EventCode {EventCode} / EventId {EventId} and OrganizationId {OrgId}", eventCode, eventId, request.OrganizationId);
            return ApiResponse<bool>.Fail($"No notification template configured for event '{eventCode}'.");
        }

        if (!template.IsActive)
        {
            return ApiResponse<bool>.Fail($"Notification template for '{template.EventCode}' is disabled.");
        }

        // 2. Dispatch for each target user
        foreach (var userId in request.TargetUserIds)
        {
            var targetUser = await _userService.GetUserByIdAsync(userId);
            if (targetUser == null || !targetUser.IsActive) continue;

            // Prepare context parameters with automatic user fallbacks
            var contextParams = new Dictionary<string, string>(request.Parameters, StringComparer.OrdinalIgnoreCase)
            {
                ["UserName"] = targetUser.DisplayName ?? $"{targetUser.FirstName} {targetUser.LastName}".Trim(),
                ["UserCode"] = targetUser.UserCode ?? targetUser.Email,
                ["UserEmail"] = targetUser.Email
            };

            // Interpolate dynamic placeholders in Subject and Body
            var renderedTitle = InterpolatePlaceholders(template.SubjectTemplate, contextParams);
            var renderedBody = InterpolatePlaceholders(template.BodyTemplate, contextParams);

            // Channel 1: In-App Bell Feed
            if (template.SendInApp)
            {
                await _dbFactory.ExecuteAsync(
                    "PR_IU_UserNotification",
                    new
                    {
                        p_Id = 0L,
                        p_OrganizationId = request.OrganizationId,
                        p_UserId = userId,
                        p_EventId = template.EventId,
                        p_EventCode = template.EventCode,
                        p_CategoryId = template.CategoryId,
                        p_Title = renderedTitle,
                        p_Message = renderedBody,
                        p_ActionUrl = request.ActionUrl,
                        p_IsRead = 0,
                        p_UID = performedByUserId
                    },
                    commandType: CommandType.StoredProcedure);
            }

            // Channel 2: Email Queue
            if (template.SendEmail && !string.IsNullOrWhiteSpace(targetUser.Email))
            {
                var queueId = Guid.NewGuid().ToString();
                const string sql = @"
                    INSERT INTO `EmailQueue` (
                        QueueId, CenterId, RecipientTo, Subject, Body, IsHtml,
                        Status, Priority, RetryCount, MaxRetryCount, CreatedBy, CreateDate, ModifiedBy, ModifyDate, IsDeleted
                    ) VALUES (
                        @QueueId, @CenterId, @RecipientTo, @Subject, @Body, 1,
                        0, @Priority, 0, 3, @UID, CURRENT_TIMESTAMP, @UID, CURRENT_TIMESTAMP, 0
                    )";

                await _dbFactory.ExecuteAsync(sql, new
                {
                    QueueId = queueId,
                    CenterId = request.OrganizationId,
                    RecipientTo = targetUser.Email,
                    Subject = renderedTitle,
                    Body = renderedBody,
                    Priority = request.Priority,
                    UID = performedByUserId
                });
            }

            // Channel 3: SMS Queue
            if (template.SendSMS)
            {
                var smsQueueId = Guid.NewGuid().ToString();
                const string smsSql = @"
                    INSERT INTO `SmsQueue` (
                        QueueId, OrganizationId, RecipientPhoneNumber, Message, Status, RetryCount, MaxRetryCount, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
                    ) VALUES (
                        @QueueId, @OrganizationId, @RecipientPhoneNumber, @Message, 0, 0, 3, @UID, CURRENT_TIMESTAMP, @UID, CURRENT_TIMESTAMP, 0
                    )";

                await _dbFactory.ExecuteAsync(smsSql, new
                {
                    QueueId = smsQueueId,
                    OrganizationId = request.OrganizationId,
                    RecipientPhoneNumber = targetUser.Email,
                    Message = renderedTitle + ": " + renderedBody,
                    UID = performedByUserId
                });
            }
        }

        return ApiResponse<bool>.Ok(true, "Notifications dispatched successfully.");
    }

    public async Task<IEnumerable<UserNotificationDto>> GetUserNotificationsAsync(int userId, int organizationId = -1, int isRead = -1, int pageNumber = 1, int pageSize = 20)
    {
        var notifications = await _dbFactory.QueryAsync<UserNotificationDto>(
            "PR_S_UserNotification",
            new
            {
                p_UserId = userId,
                p_OrganizationId = organizationId,
                p_IsRead = isRead,
                p_PageNumber = pageNumber,
                p_PageSize = pageSize
            },
            commandType: CommandType.StoredProcedure);

        return notifications;
    }

    public async Task<UnreadCountDto> GetUnreadCountAsync(int userId, int organizationId = -1)
    {
        var count = await _dbFactory.QuerySingleAsync<UnreadCountDto>(
            "PR_S_UnreadNotificationCount",
            new
            {
                p_UserId = userId,
                p_OrganizationId = organizationId
            },
            commandType: CommandType.StoredProcedure);

        return count ?? new UnreadCountDto { UnreadCount = 0 };
    }

    public async Task<bool> MarkAsReadAsync(long notificationId, int userId)
    {
        var result = await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_UserNotification",
            new
            {
                p_Id = notificationId,
                p_OrganizationId = (int?)null,
                p_UserId = userId,
                p_EventId = (int?)null,
                p_EventCode = (string?)null,
                p_CategoryId = (int?)null,
                p_Title = (string?)null,
                p_Message = (string?)null,
                p_ActionUrl = (string?)null,
                p_IsRead = 1,
                p_UID = userId
            },
            commandType: CommandType.StoredProcedure);

        return result != null && result.ErrNo == 0 && result.RowsCount > 0;
    }

    public async Task<int> MarkAllAsReadAsync(int userId, int organizationId = -1)
    {
        var affected = await _dbFactory.ExecuteAsync(
            "PR_U_MarkAllNotificationsRead",
            new
            {
                p_UserId = userId,
                p_OrganizationId = organizationId
            },
            commandType: CommandType.StoredProcedure);

        return affected;
    }

    public async Task<NotificationTemplateDto?> GetTemplateByIdAsync(int id)
    {
        var templates = await _dbFactory.QueryAsync<NotificationTemplateDto>(
            "PR_S_NotificationTemplate",
            new { p_Id = id, p_OrganizationId = -1, p_EventCode = "", p_EventId = -1 },
            commandType: CommandType.StoredProcedure);

        return templates.FirstOrDefault();
    }

    public async Task<NotificationTemplateDto?> GetTemplateByEventAsync(string eventCode, int organizationId, int eventId = -1)
    {
        var templates = await _dbFactory.QueryAsync<NotificationTemplateDto>(
            "PR_S_NotificationTemplate",
            new { p_Id = -1, p_OrganizationId = organizationId, p_EventCode = eventCode ?? "", p_EventId = eventId },
            commandType: CommandType.StoredProcedure);

        return templates.FirstOrDefault();
    }

    public async Task<IEnumerable<NotificationTemplateDto>> GetTemplatesAsync(int organizationId = -1)
    {
        var templates = await _dbFactory.QueryAsync<NotificationTemplateDto>(
            "PR_S_NotificationTemplate",
            new { p_Id = -1, p_OrganizationId = organizationId, p_EventCode = "", p_EventId = -1 },
            commandType: CommandType.StoredProcedure);

        return templates;
    }

    public async Task<NotificationTemplateDto> SaveTemplateAsync(SaveNotificationTemplateRequestDto request, int performedByUserId)
    {
        var result = await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_NotificationTemplate",
            new
            {
                p_Id = request.Id,
                p_OrganizationId = request.OrganizationId,
                p_EventId = request.EventId ?? 0,
                p_EventCode = request.EventCode ?? "",
                p_CategoryId = request.CategoryId,
                p_SubjectTemplate = request.SubjectTemplate,
                p_BodyTemplate = request.BodyTemplate,
                p_SendInApp = request.SendInApp ? 1 : 0,
                p_SendEmail = request.SendEmail ? 1 : 0,
                p_SendSMS = request.SendSMS ? 1 : 0,
                p_IsActive = request.IsActive ? 1 : 0,
                p_UID = performedByUserId
            },
            commandType: CommandType.StoredProcedure);

        var savedId = Convert.ToInt32(result?.ID ?? 0);
        if (savedId > 0)
        {
            return (await GetTemplateByIdAsync(savedId))!;
        }

        throw new InvalidOperationException(result?.ErrMsg ?? "Failed to save notification template.");
    }

    private static string InterpolatePlaceholders(string templateText, Dictionary<string, string> parameters)
    {
        if (string.IsNullOrEmpty(templateText)) return string.Empty;

        return Regex.Replace(templateText, @"\{(?<key>[a-zA-Z0-9_]+)\}", match =>
        {
            var key = match.Groups["key"].Value;
            return parameters.TryGetValue(key, out var val) ? val : match.Value;
        });
    }
}
