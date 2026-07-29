using System;
using System.Data;
using System.Threading;
using System.Threading.Tasks;
using DNAQMSAPI.Application.SubscriptionSaaS.Interfaces;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Infrastructure.Models;
using Microsoft.Extensions.Logging;
using System.Linq;

namespace DNAQMSAPI.Infrastructure.SubscriptionSaaS.Services;

public class UsageMeteringService : IUsageMeteringService
{
    private readonly IDapperDBFactory _dbFactory;
    private readonly ILogger<UsageMeteringService> _logger;
    private readonly ISubscriptionService _subscriptionService;

    public UsageMeteringService(IDapperDBFactory dbFactory, ILogger<UsageMeteringService> logger, ISubscriptionService subscriptionService)
    {
        _dbFactory = dbFactory;
        _logger = logger;
        _subscriptionService = subscriptionService;
    }

    public async Task<bool> CanConsumeFeatureAsync(Guid tenantId, string featureKey, long amountToConsume = 1, CancellationToken cancellationToken = default)
    {
        var subscription = await _subscriptionService.GetActiveSubscriptionAsync(tenantId, cancellationToken);
        if (subscription == null)
        {
            _logger.LogWarning("Tenant {TenantId} has no active subscription.", tenantId);
            return false;
        }

        var featureResult = await _dbFactory.QueryAsync<string>(
            "PR_S_PlanFeatureLimit",
            new { p_PlanId = subscription.PlanId, p_FeatureKey = featureKey },
            commandType: CommandType.StoredProcedure);

        var limitStr = featureResult.FirstOrDefault();

        if (string.IsNullOrEmpty(limitStr) || !long.TryParse(limitStr, out var limit))
        {
            _logger.LogWarning("Feature {FeatureKey} not configured or invalid for PlanId {PlanId}", featureKey, subscription.PlanId);
            return false;
        }

        var usageResult = await _dbFactory.QueryAsync<long?>(
            "PR_S_CurrentUsage",
            new { p_TenantId = tenantId.ToString(), p_FeatureKey = featureKey },
            commandType: CommandType.StoredProcedure);

        var currentUsage = usageResult.FirstOrDefault() ?? 0;

        return (currentUsage + amountToConsume) <= limit;
    }

    public async Task RecordUsageAsync(Guid tenantId, string featureKey, long quantity, CancellationToken cancellationToken = default)
    {
        var subscription = await _subscriptionService.GetActiveSubscriptionAsync(tenantId, cancellationToken);
        if (subscription == null) return;

        await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_UsageTracking",
            new
            {
                p_TenantId = tenantId.ToString(),
                p_FeatureKey = featureKey,
                p_Quantity = quantity,
                p_PeriodStart = subscription.StartDate,
                p_PeriodEnd = subscription.ExpiryDate
            },
            commandType: CommandType.StoredProcedure);
    }
}

