using DNAQMSAPI.Domain.Entities;

namespace DNAQMSAPI.Application.Interfaces;

public interface IPaymentGateway
{
    string ProviderName { get; }
    Task<PaymentTransaction> CreateTransactionAsync(int userId, int organizationId, decimal amount, string currency, OrganizationPaymentProvider providerConfig);
    Task<PaymentTransaction?> VerifyTransactionAsync(string providerTransactionId, OrganizationPaymentProvider providerConfig);
    Task<bool> ValidateWebhookAsync(string payload, string signature, OrganizationPaymentProvider providerConfig);
}
