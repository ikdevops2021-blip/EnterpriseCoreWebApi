using System;
using System.Threading.Tasks;
using DNAQMSAPI.Domain.Entities;

namespace DNAQMSAPI.Application.Interfaces.Payments;

public interface IPaymentService
{
    Task<int> CreatePaymentTransactionAsync(PaymentTransaction transaction);
    Task UpdatePaymentStatusAsync(int transactionId, string newStatus, string reason, string modifiedBy);
    Task LogWebhookEventAsync(WebhookLog log);
}
