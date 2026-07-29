namespace DNAQMSAPI.Domain.Entities;

public class Country
{
    public int CountryId { get; set; }
    public string CountryName { get; set; } = string.Empty;
    public string CountryCode { get; set; } = string.Empty;
    public string? InternationalDialing { get; set; }
    public string? Attribute1 { get; set; }
    public string? Attribute2 { get; set; }
    public string? Attribute3 { get; set; }
    public bool IsActive { get; set; } = true;
    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int ModifiedBy { get; set; }
    public DateTime ModifiedDate { get; set; }
    public bool IsDeleted { get; set; } = false;
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }
}

public class State
{
    public int StateId { get; set; }
    public int CountryId { get; set; }
    public string StateName { get; set; } = string.Empty;
    public string? StateCode { get; set; }
    public string? Attribute1 { get; set; }
    public string? Attribute2 { get; set; }
    public string? Attribute3 { get; set; }
    public bool IsActive { get; set; } = true;
    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int ModifiedBy { get; set; }
    public DateTime ModifiedDate { get; set; }
    public bool IsDeleted { get; set; } = false;
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }

    // Joined / Navigation properties
    public string? CountryName { get; set; }
    public string? CountryCode { get; set; }
}

public class City
{
    public int CityId { get; set; }
    public int StateId { get; set; }
    public string CityName { get; set; } = string.Empty;
    public string? CityCode { get; set; }
    public string? Attribute1 { get; set; }
    public string? Attribute2 { get; set; }
    public string? Attribute3 { get; set; }
    public bool IsActive { get; set; } = true;
    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int ModifiedBy { get; set; }
    public DateTime ModifiedDate { get; set; }
    public bool IsDeleted { get; set; } = false;
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }

    // Joined / Navigation properties
    public string? StateName { get; set; }
    public string? StateCode { get; set; }
    public int CountryId { get; set; }
    public string? CountryName { get; set; }
    public string? CountryCode { get; set; }
}

public class UserAddress
{
    public long AddressId { get; set; }
    public int UserId { get; set; }
    public int AddressTypeId { get; set; }
    public string AddressLine1 { get; set; } = string.Empty;
    public string? AddressLine2 { get; set; }
    public string PostalCode { get; set; } = string.Empty;
    public int CountryId { get; set; }
    public int StateId { get; set; }
    public int CityId { get; set; }
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }
    public bool IsPrimary { get; set; }
    public bool IsActive { get; set; } = true;
    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int ModifiedBy { get; set; }
    public DateTime ModifiedDate { get; set; }
    public bool IsDeleted { get; set; } = false;
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }

    // Joined / Navigation properties
    public string? AddressTypeName { get; set; }
    public string? AddressTypeCode { get; set; }
    public string? CountryName { get; set; }
    public string? CountryCode { get; set; }
    public string? StateName { get; set; }
    public string? StateCode { get; set; }
    public string? CityName { get; set; }
    public string? CityCode { get; set; }
}

public class UserContact
{
    public long ContactId { get; set; }
    public int UserId { get; set; }
    public int ContactTypeId { get; set; }
    public int RelationshipTypeId { get; set; }
    public string ContactValue { get; set; } = string.Empty;
    public string? CountryCode { get; set; }
    public bool IsPrimary { get; set; }
    public bool IsEmergency { get; set; }
    public bool IsVerified { get; set; }
    public bool IsActive { get; set; } = true;
    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public int ModifiedBy { get; set; }
    public DateTime ModifiedDate { get; set; }
    public bool IsDeleted { get; set; } = false;
    public int? DeletedBy { get; set; }
    public DateTime? DeletedDate { get; set; }

    // Joined / Navigation properties
    public string? ContactTypeName { get; set; }
    public string? ContactTypeCode { get; set; }
    public string? RelationshipTypeName { get; set; }
    public string? RelationshipTypeCode { get; set; }
}
