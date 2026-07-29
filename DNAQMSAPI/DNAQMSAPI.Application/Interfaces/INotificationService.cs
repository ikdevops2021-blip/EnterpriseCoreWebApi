using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.DTOs;
using DNAQMSAPI.Domain.Entities;

namespace DNAQMSAPI.Application.Interfaces;

public interface INotificationService
{
    // Event Dispatching
    Task<ApiResponse<bool>> SendNotificationAsync(SendNotificationRequestDto request, int performedByUserId);

    // In-App Bell Feed
    Task<IEnumerable<UserNotificationDto>> GetUserNotificationsAsync(int userId, int organizationId = -1, int isRead = -1, int pageNumber = 1, int pageSize = 20);
    Task<UnreadCountDto> GetUnreadCountAsync(int userId, int organizationId = -1);
    Task<bool> MarkAsReadAsync(long notificationId, int userId);
    Task<int> MarkAllAsReadAsync(int userId, int organizationId = -1);

    // Template Management
    Task<NotificationTemplateDto?> GetTemplateByIdAsync(int id);
    Task<NotificationTemplateDto?> GetTemplateByEventAsync(string eventCode, int organizationId, int eventId = -1);
    Task<IEnumerable<NotificationTemplateDto>> GetTemplatesAsync(int organizationId = -1);
    Task<NotificationTemplateDto> SaveTemplateAsync(SaveNotificationTemplateRequestDto request, int performedByUserId);
}
