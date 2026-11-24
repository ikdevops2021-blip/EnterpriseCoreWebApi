using System.Collections.Generic;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Models;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;

namespace DNAQMSAPI.Application.Interfaces;

public interface IWebhookService
{
    Task<ApiResponse<IEnumerable<WebhookSubscriptionDto>>> GetSubscriptionsAsync(int organizationId, int? locationId = null, int? id = null, int? isActive = null);
    Task<ApiResponse<WebhookSubscriptionDto>> SaveSubscriptionAsync(SaveWebhookSubscriptionRequestDto request, int userId);
    Task<ApiResponse<bool>> DeleteSubscriptionAsync(int id, int userId);
    Task<ApiResponse<WebhookTestResultDto>> TestWebhookAsync(WebhookTestRequestDto request, int organizationId);
    Task<ApiResponse<IEnumerable<WebhookDeliveryLogDto>>> GetDeliveryLogsAsync(int subscriptionId = -1, int organizationId = -1, string? status = null, int pageNumber = 1, int pageSize = 50);
}
