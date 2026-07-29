using System;
using System.Threading;
using System.Threading.Tasks;
using DNAQMSAPI.Application.SubscriptionSaaS.DTOs;
using DNAQMSAPI.Domain.SubscriptionSaaS.Entities;

namespace DNAQMSAPI.Application.SubscriptionSaaS.Interfaces;

public interface ISubscriptionService
{
    Task<TenantSubscription?> GetActiveSubscriptionAsync(Guid tenantId, CancellationToken cancellationToken = default);
    Task<TenantSubscription> CreateSubscriptionAsync(CreateSubscriptionRequest request, CancellationToken cancellationToken = default);
    Task<bool> CancelSubscriptionAsync(Guid tenantId, CancellationToken cancellationToken = default);
}
