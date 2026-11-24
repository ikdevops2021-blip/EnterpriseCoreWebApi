using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using DNAQMSAPI.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers;

[ApiController]
[Route("api/v1/dqms/webhooks")]
[Route("api/v1/webhooks")]
[AllowAnonymous]
public class WebhooksController : ApiControllerBase
{
    private readonly IWebhookService _webhookService;

    public WebhooksController(IWebhookService webhookService)
    {
        _webhookService = webhookService;
    }

    /// <summary>
    /// Gets all registered webhook subscriptions for an organization.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetSubscriptions(
        [FromQuery] int organizationId = 1,
        [FromQuery] int? locationId = null,
        [FromQuery] int? id = null,
        [FromQuery] int? isActive = null)
    {
        var result = await _webhookService.GetSubscriptionsAsync(organizationId, locationId, id, isActive);
        return ApiResponse(result);
    }

    /// <summary>
    /// Creates or updates a webhook subscription.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> SaveSubscription(
        [FromBody] SaveWebhookSubscriptionRequestDto request,
        [FromHeader(Name = "X-User-Id")] int userId = 1)
    {
        if (request == null)
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request payload is required."));
        }

        var result = await _webhookService.SaveSubscriptionAsync(request, userId);
        return ApiResponse(result);
    }

    /// <summary>
    /// Deletes (soft-deletes) a webhook subscription by ID.
    /// </summary>
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> DeleteSubscription(
        int id,
        [FromHeader(Name = "X-User-Id")] int userId = 1)
    {
        var result = await _webhookService.DeleteSubscriptionAsync(id, userId);
        return ApiResponse(result);
    }

    /// <summary>
    /// Dispatches an interactive test ping payload against a target endpoint.
    /// </summary>
    [HttpPost("test")]
    public async Task<IActionResult> TestWebhook(
        [FromBody] WebhookTestRequestDto request,
        [FromQuery] int organizationId = 1)
    {
        if (request == null)
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Test request payload is required."));
        }

        var result = await _webhookService.TestWebhookAsync(request, organizationId);
        return ApiResponse(result);
    }

    /// <summary>
    /// Retrieves paginated delivery logs and audit records.
    /// </summary>
    [HttpGet("logs")]
    public async Task<IActionResult> GetDeliveryLogs(
        [FromQuery] int subscriptionId = -1,
        [FromQuery] int organizationId = -1,
        [FromQuery] string? status = null,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 50)
    {
        var result = await _webhookService.GetDeliveryLogsAsync(subscriptionId, organizationId, status, pageNumber, pageSize);
        return ApiResponse(result);
    }
}
