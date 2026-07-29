using System;

namespace DNAQMSAPI.Domain.Entities;

public class PaymentTransaction
{
    public int Id { get; set; }
    public Guid Guid { get; set; }
    public int OrganizationId { get; set; }
    public int BranchId { get; set; }
    public int PaymentProviderId { get; set; }
    public string? ExternalTransactionId { get; set; }
    public decimal Amount { get; set; }
    public int CurrencyId { get; set; }
    public string Status { get; set; } = string.Empty;
    public string PaymentMethod { get; set; } = string.Empty;
    public string? CustomerId { get; set; }
    public string? Description { get; set; }
    public string? IdempotencyKey { get; set; }

    // Phase 5: UPI & QR Code enhancements
    public string? UpiIntentUri { get; set; }
    public string? QrContent { get; set; }
    public string? QrImage { get; set; }
    public DateTime? ExpiryTime { get; set; }

    // Audit fields
    public DateTime CreatedOn { get; set; }
    public string CreatedBy { get; set; } = string.Empty;
    public DateTime? ModifiedOn { get; set; }
    public string? ModifiedBy { get; set; }
    public bool IsDeleted { get; set; }
    public byte[]? RowVersion { get; set; }
}
