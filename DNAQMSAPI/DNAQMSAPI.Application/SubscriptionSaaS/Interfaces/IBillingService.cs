using System;
using System.Threading;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.SubscriptionSaaS.DTOs;

namespace DNAQMSAPI.Application.SubscriptionSaaS.Interfaces;

public interface IBillingService
{
    Task<ApiResponse<BillingResult>> GenerateInvoiceAsync(Guid subscriptionId, decimal baseAmount, string countryCode, string? stateCode, CancellationToken cancellationToken = default);
}
