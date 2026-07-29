namespace DNAQMSAPI.Application.DTOs;

#region Country DTOs
public class CountryDto
{
    public int CountryId { get; set; }
    public string CountryName { get; set; } = string.Empty;
    public string CountryCode { get; set; } = string.Empty;
    public string? InternationalDialing { get; set; }
    public string? Attribute1 { get; set; }
    public string? Attribute2 { get; set; }
    public string? Attribute3 { get; set; }
    public bool IsActive { get; set; }
}

public class CreateCountryRequestDto
{
    public string CountryName { get; set; } = string.Empty;
    public string CountryCode { get; set; } = string.Empty;
    public string? InternationalDialing { get; set; }
    public string? Attribute1 { get; set; }
    public string? Attribute2 { get; set; }
    public string? Attribute3 { get; set; }
    public bool IsActive { get; set; } = true;
}

public class UpdateCountryRequestDto : CreateCountryRequestDto
{
    public int CountryId { get; set; }
}
#endregion

#region State DTOs
public class StateDto
{
    public int StateId { get; set; }
    public int CountryId { get; set; }
    public string StateName { get; set; } = string.Empty;
    public string? StateCode { get; set; }
    public string? CountryName { get; set; }
    public string? CountryCode { get; set; }
    public string? Attribute1 { get; set; }
    public string? Attribute2 { get; set; }
    public string? Attribute3 { get; set; }
    public bool IsActive { get; set; }
}

public class CreateStateRequestDto
{
    public int CountryId { get; set; }
    public string StateName { get; set; } = string.Empty;
    public string? StateCode { get; set; }
    public string? Attribute1 { get; set; }
    public string? Attribute2 { get; set; }
    public string? Attribute3 { get; set; }
    public bool IsActive { get; set; } = true;
}

public class UpdateStateRequestDto : CreateStateRequestDto
{
    public int StateId { get; set; }
}
#endregion

#region City DTOs
public class CityDto
{
    public int CityId { get; set; }
    public int StateId { get; set; }
    public string CityName { get; set; } = string.Empty;
    public string? CityCode { get; set; }
    public string? StateName { get; set; }
    public string? StateCode { get; set; }
    public int CountryId { get; set; }
    public string? CountryName { get; set; }
    public string? CountryCode { get; set; }
    public string? Attribute1 { get; set; }
    public string? Attribute2 { get; set; }
    public string? Attribute3 { get; set; }
    public bool IsActive { get; set; }
}

public class CreateCityRequestDto
{
    public int StateId { get; set; }
    public string CityName { get; set; } = string.Empty;
    public string? CityCode { get; set; }
    public string? Attribute1 { get; set; }
    public string? Attribute2 { get; set; }
    public string? Attribute3 { get; set; }
    public bool IsActive { get; set; } = true;
}

public class UpdateCityRequestDto : CreateCityRequestDto
{
    public int CityId { get; set; }
}
#endregion

#region UserAddress DTOs
public class UserAddressDto
{
    public long AddressId { get; set; }
    public int UserId { get; set; }
    public int AddressTypeId { get; set; }
    public string? AddressTypeName { get; set; }
    public string AddressLine1 { get; set; } = string.Empty;
    public string? AddressLine2 { get; set; }
    public string PostalCode { get; set; } = string.Empty;
    public int CountryId { get; set; }
    public string? CountryName { get; set; }
    public string? CountryCode { get; set; }
    public int StateId { get; set; }
    public string? StateName { get; set; }
    public string? StateCode { get; set; }
    public int CityId { get; set; }
    public string? CityName { get; set; }
    public string? CityCode { get; set; }
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }
    public bool IsPrimary { get; set; }
    public bool IsActive { get; set; }
}

public class SaveUserAddressRequestDto
{
    public long AddressId { get; set; } // 0 for Insert, >0 for Update
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
}
#endregion

#region UserContact DTOs
public class UserContactDto
{
    public long ContactId { get; set; }
    public int UserId { get; set; }
    public int ContactTypeId { get; set; }
    public string? ContactTypeName { get; set; }
    public int RelationshipTypeId { get; set; }
    public string? RelationshipTypeName { get; set; }
    public string ContactValue { get; set; } = string.Empty;
    public string? CountryCode { get; set; }
    public bool IsPrimary { get; set; }
    public bool IsEmergency { get; set; }
    public bool IsVerified { get; set; }
    public bool IsActive { get; set; }
}

public class SaveUserContactRequestDto
{
    public long ContactId { get; set; } // 0 for Insert, >0 for Update
    public int UserId { get; set; }
    public int ContactTypeId { get; set; }
    public int RelationshipTypeId { get; set; }
    public string ContactValue { get; set; } = string.Empty;
    public string? CountryCode { get; set; }
    public bool IsPrimary { get; set; }
    public bool IsEmergency { get; set; }
    public bool IsVerified { get; set; }
    public bool IsActive { get; set; } = true;
}
#endregion
