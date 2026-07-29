using System;

namespace DNAQMSAPI.Application.DTOs.Payments;

public class PaymentRequestDto
{
    public int OrganizationId { get; set; }
    public int BranchId { get; set; }
    public decimal Amount { get; set; }
    public string CurrencyCode { get; set; } = "USD";
    public string PaymentMethod { get; set; } = string.Empty;
    public string? CustomerId { get; set; }
    public string? Description { get; set; }
    public string? IdempotencyKey { get; set; }
}
