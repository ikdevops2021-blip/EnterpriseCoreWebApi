namespace DNAQMSAPI.Domain.Entities;

public class OrganizationStorageConfig
{
    public int Id { get; set; }
    public int OrganizationId { get; set; }
    public string ProviderName { get; set; } = null!; // GoogleDrive, AWS, Azure, Local
    public string ConfigurationJson { get; set; } = string.Empty; // Encrypted credentials, bucket names, base baths, etc.
    public bool IsActive { get; set; }

    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int? ModifiedBy { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool? IsDeleted { get; set; }
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
