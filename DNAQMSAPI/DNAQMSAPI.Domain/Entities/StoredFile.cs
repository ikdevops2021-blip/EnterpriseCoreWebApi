namespace DNAQMSAPI.Domain.Entities;

public class StoredFile
{
    public Guid Id { get; set; }
    public string FileName { get; set; } = null!;
    public string ContentType { get; set; } = null!;
    public long SizeBytes { get; set; }
    public string StorageProvider { get; set; } = null!; // e.g., Local, S3, AzureBlob
    public string PathOrUrl { get; set; } = null!;
    public int? OrganizationId { get; set; }

    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int? ModifiedBy { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool? IsDeleted { get; set; }
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}
