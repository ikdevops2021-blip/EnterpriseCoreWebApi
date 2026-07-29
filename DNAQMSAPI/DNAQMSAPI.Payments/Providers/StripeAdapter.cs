using System;
using System.Threading.Tasks;
using DNAQMSAPI.Application.DTOs.Payments;
using DNAQMSAPI.Application.Interfaces.Payments;

namespace DNAQMSAPI.Payments.Providers;

public class StripeAdapter : IPaymentProvider
{
    public string ProviderCode => "STRIPE";
    public System.Collections.Generic.IEnumerable<string> SupportedPaymentMethods => new[] { "CreditCard", "Wallet" };

    public Task<PaymentResponseDto> CreatePaymentAsync(PaymentRequestDto request)
    {
        // Simulate integration with Stripe SDK
        return Task.FromResult(new PaymentResponseDto 
        { 
            IsSuccess = true,
            ProviderName = "Stripe",
            ExternalTransactionId = "pi_mock_" + Guid.NewGuid().ToString("N"),
            Status = "Created",
            ClientSecret = "mock_secret_xyz789"
        });
    }

    public Task<PaymentResponseDto> CapturePaymentAsync(string externalTransactionId, decimal amount)
    {
        return Task.FromResult(new PaymentResponseDto 
        { 
            IsSuccess = true,
            ProviderName = "Stripe",
            ExternalTransactionId = externalTransactionId,
            Status = "Captured"
        });
    }

    public Task<PaymentResponseDto> RefundPaymentAsync(string externalTransactionId, decimal amount, string reason)
    {
        return Task.FromResult(new PaymentResponseDto 
        { 
            IsSuccess = true,
            ProviderName = "Stripe",
            ExternalTransactionId = externalTransactionId,
            Status = "Refunded"
        });
    }

    public Task<PaymentResponseDto> GeneratePaymentLinkAsync(PaymentRequestDto request)
    {
        return Task.FromResult(new PaymentResponseDto 
        { 
            IsSuccess = true,
            ProviderName = "Stripe",
            Status = "Created",
            PaymentLinkUrl = "https://buy.stripe.com/mocklink123"
        });
    }

    public Task<PaymentResponseDto> CreateUpiPaymentAsync(PaymentRequestDto request)
    {
        throw new NotSupportedException("Stripe does not natively support UPI directly in this mock.");
    }

    public Task<PaymentResponseDto> GenerateQrAsync(PaymentRequestDto request)
    {
        throw new NotSupportedException("Stripe does not support QR generation in this mock.");
    }

    public Task<PaymentResponseDto> CreateUpiIntentAsync(PaymentRequestDto request)
    {
        throw new NotSupportedException("Stripe does not support UPI intent in this mock.");
    }
}
