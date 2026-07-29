using System;
using System.Data;
using System.Threading;
using System.Threading.Tasks;
using DNAQMSAPI.Application.SubscriptionSaaS.DTOs;
using DNAQMSAPI.Application.SubscriptionSaaS.Interfaces;
using DNAQMSAPI.Domain.SubscriptionSaaS.Entities;
using DNAQMSAPI.Domain.SubscriptionSaaS.Enums;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Infrastructure.Models;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Infrastructure.SubscriptionSaaS.Services;

public class SubscriptionService : ISubscriptionService
{
    private readonly IDapperDBFactory _dbFactory;
    private readonly ILogger<SubscriptionService> _logger;

    public SubscriptionService(IDapperDBFactory dbFactory, ILogger<SubscriptionService> logger)
    {
        _dbFactory = dbFactory;
        _logger = logger;
    }

    public async Task<TenantSubscription?> GetActiveSubscriptionAsync(Guid tenantId, CancellationToken cancellationToken = default)
    {
        var result = await _dbFactory.QueryAsync<TenantSubscription>(
            "PR_S_TenantSubscription",
            new { p_TenantId = tenantId.ToString(), p_Status = -1 },
            commandType: CommandType.StoredProcedure);

        return System.Linq.Enumerable.FirstOrDefault(result);
    }

    public async Task<TenantSubscription> CreateSubscriptionAsync(CreateSubscriptionRequest request, CancellationToken cancellationToken = default)
    {
        var subscription = new TenantSubscription
        {
            SubscriptionId = Guid.NewGuid(),
            TenantId = request.TenantId,
            PlanId = request.PlanId,
            Status = SubscriptionStatus.Active,
            StartDate = DateTime.UtcNow,
            ExpiryDate = DateTime.UtcNow.AddMonths(1),
            AutoRenew = true
        };

        var parameters = new
        {
            p_SubscriptionId = "",
            p_TenantId = subscription.TenantId.ToString(),
            p_PlanId = subscription.PlanId,
            p_Status = (int)subscription.Status,
            p_StartDate = subscription.StartDate,
            p_ExpiryDate = subscription.ExpiryDate,
            p_AutoRenew = subscription.AutoRenew
        };

        var result = await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_TenantSubscription",
            parameters,
            commandType: CommandType.StoredProcedure);

        if (result != null && !string.IsNullOrEmpty(result.ID?.ToString()))
        {
            subscription.SubscriptionId = Guid.Parse(result.ID.ToString()!);
        }

        _logger.LogInformation("Created new subscription {SubscriptionId} for Tenant {TenantId}", subscription.SubscriptionId, subscription.TenantId);

        return subscription;
    }

    public async Task<bool> CancelSubscriptionAsync(Guid tenantId, CancellationToken cancellationToken = default)
    {
        var activeSub = await GetActiveSubscriptionAsync(tenantId, cancellationToken);
        if (activeSub == null) return false;

        var parameters = new
        {
            p_SubscriptionId = activeSub.SubscriptionId.ToString(),
            p_TenantId = tenantId.ToString(),
            p_PlanId = activeSub.PlanId,
            p_Status = (int)SubscriptionStatus.Cancelled,
            p_StartDate = activeSub.StartDate,
            p_ExpiryDate = activeSub.ExpiryDate,
            p_AutoRenew = 0
        };

        var result = await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_TenantSubscription",
            parameters,
            commandType: CommandType.StoredProcedure);

        var rowsAffected = result?.RowsCount ?? 0;
        _logger.LogInformation("Cancelled subscription for Tenant {TenantId}. Rows affected: {Rows}", tenantId, rowsAffected);
        
        return rowsAffected > 0;
    }
}

