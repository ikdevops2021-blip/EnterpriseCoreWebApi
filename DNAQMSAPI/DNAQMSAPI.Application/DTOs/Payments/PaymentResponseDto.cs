using System;

namespace DNAQMSAPI.Application.DTOs.Payments;

public class PaymentResponseDto
{
    public int TransactionId { get; set; }
    public Guid TransactionGuid { get; set; }
    public string ExternalTransactionId { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public string ProviderName { get; set; } = string.Empty;
    public string? ClientSecret { get; set; } // E.g., for Stripe frontend initialization
    public string? PaymentLinkUrl { get; set; }
    public bool IsSuccess { get; set; }
    public string? ErrorMessage { get; set; }

    // Phase 5: UPI & QR Code enhancements
    public string PaymentMethod { get; set; } = string.Empty;
    public string? QrImage { get; set; }
    public string? QrContent { get; set; }
    public string? UpiIntentUri { get; set; }
    public DateTime? ExpiryTime { get; set; }
}
