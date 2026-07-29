using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.DependencyInjection;
using DNAQMSAPI.Application.SubscriptionSaaS.Interfaces;

namespace DNAQMSAPI.Api.Attributes;

[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, Inherited = true, AllowMultiple = true)]
public class FeatureGateAttribute : Attribute, IAsyncActionFilter
{
    private readonly string _featureKey;

    public FeatureGateAttribute(string featureKey)
    {
        _featureKey = featureKey;
    }

    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        // Example: Retrieve TenantId from Claims or Headers
        var tenantIdClaim = context.HttpContext.Request.Headers["X-Tenant-Id"].ToString();

        if (!Guid.TryParse(tenantIdClaim, out var tenantId))
        {
            context.Result = new UnauthorizedObjectResult(new { Message = "Tenant ID missing or invalid." });
            return;
        }

        var meteringService = context.HttpContext.RequestServices.GetRequiredService<IUsageMeteringService>();

        bool canConsume = await meteringService.CanConsumeFeatureAsync(tenantId, _featureKey);

        if (!canConsume)
        {
            context.Result = new ObjectResult(new { Message = $"Feature '{_featureKey}' limit reached or not available in current plan." })
            {
                StatusCode = 403 // Forbidden
            };
            return;
        }

        await next();
    }
}
