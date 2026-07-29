using System;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using Microsoft.AspNetCore.Mvc;
using DNAQMSAPI.Api.Attributes;
using DNAQMSAPI.Application.SubscriptionSaaS.DTOs;
using DNAQMSAPI.Application.SubscriptionSaaS.Interfaces;

namespace DNAQMSAPI.Api.Controllers.SubscriptionSaaS;

[ApiController]
[Route("api/v1/[controller]")]
public class SubscriptionController : ApiControllerBase
{
    private readonly ISubscriptionService _subscriptionService;

    public SubscriptionController(ISubscriptionService subscriptionService)
    {
        _subscriptionService = subscriptionService;
    }

    [HttpGet("{tenantId}")]
    public async Task<IActionResult> GetActiveSubscription(Guid tenantId)
    {
        var subscription = await _subscriptionService.GetActiveSubscriptionAsync(tenantId);
        if (subscription == null) return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<DNAQMSAPI.Domain.SubscriptionSaaS.Entities.TenantSubscription>.Fail("No active subscription found."));
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<DNAQMSAPI.Domain.SubscriptionSaaS.Entities.TenantSubscription>.Ok(subscription));
    }

    [HttpPost]
    public async Task<IActionResult> Subscribe([FromBody] CreateSubscriptionRequest request)
    {
        var subscription = await _subscriptionService.CreateSubscriptionAsync(request);
        return CreatedAtAction(nameof(GetActiveSubscription), new { tenantId = subscription.TenantId }, ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<DNAQMSAPI.Domain.SubscriptionSaaS.Entities.TenantSubscription>.Ok(subscription)));
    }

    [HttpPost("{tenantId}/cancel")]
    public async Task<IActionResult> Cancel(Guid tenantId)
    {
        var success = await _subscriptionService.CancelSubscriptionAsync(tenantId);
        if (!success) return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<string>.Fail("Could not cancel subscription."));
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<string>.Ok("Subscription cancelled successfully."));
    }

    [HttpPost("test-feature")]
    [FeatureGate("MaxApiUsage")]
    public IActionResult TestFeatureGating()
    {
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<string>.Ok("You have access to this feature because your usage hasn't exceeded the plan limit!"));
    }
}
