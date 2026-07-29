namespace DNAQMSAPI.Domain.Entities;

public class OrganizationPaymentProvider
{
    public int Id { get; set; }
    public int OrganizationId { get; set; }
    public string ProviderName { get; set; } = null!; // Razorpay, Stripe, Paypal
    public string ConfigurationJson { get; set; } = string.Empty; // Encrypted JSON holding API keys, secrets
    public bool IsActive { get; set; }

    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int? ModifiedBy { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool? IsDeleted { get; set; }
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
