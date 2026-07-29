using System.Threading.Tasks;
using DNAQMSAPI.Application.DTOs.Payments;

namespace DNAQMSAPI.Application.Interfaces.Payments;

public interface IPaymentProvider
{
    string ProviderCode { get; }
    System.Collections.Generic.IEnumerable<string> SupportedPaymentMethods { get; }

    Task<PaymentResponseDto> CreatePaymentAsync(PaymentRequestDto request);
    Task<PaymentResponseDto> CapturePaymentAsync(string externalTransactionId, decimal amount);
    Task<PaymentResponseDto> RefundPaymentAsync(string externalTransactionId, decimal amount, string reason);
    Task<PaymentResponseDto> GeneratePaymentLinkAsync(PaymentRequestDto request);

    // Phase 5: UPI & QR Code enhancements
    Task<PaymentResponseDto> CreateUpiPaymentAsync(PaymentRequestDto request);
    Task<PaymentResponseDto> GenerateQrAsync(PaymentRequestDto request);
    Task<PaymentResponseDto> CreateUpiIntentAsync(PaymentRequestDto request);
}
