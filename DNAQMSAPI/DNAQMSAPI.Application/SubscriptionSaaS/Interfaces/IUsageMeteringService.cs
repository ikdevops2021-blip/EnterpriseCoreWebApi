using System;
using System.Threading;
using System.Threading.Tasks;

namespace DNAQMSAPI.Application.SubscriptionSaaS.Interfaces;

public interface IUsageMeteringService
{
    Task<bool> CanConsumeFeatureAsync(Guid tenantId, string featureKey, long amountToConsume = 1, CancellationToken cancellationToken = default);
    Task RecordUsageAsync(Guid tenantId, string featureKey, long quantity, CancellationToken cancellationToken = default);
}
