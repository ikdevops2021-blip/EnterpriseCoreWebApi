using System.Data;
using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.DTOs;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Entities;
using DNAQMSAPI.Infrastructure.Models;
using Microsoft.Extensions.Caching.Memory;

namespace DNAQMSAPI.Infrastructure.Services;

public class LocationAndUserProfileService : ILocationAndUserProfileService
{
    private readonly IDapperDBFactory _dbFactory;
    private readonly IMemoryCache _cache;
    private static readonly TimeSpan CacheDuration = TimeSpan.FromMinutes(30);

    public LocationAndUserProfileService(IDapperDBFactory dbFactory, IMemoryCache cache)
    {
        _dbFactory = dbFactory;
        _cache = cache;
    }

    #region Location Masters (Country, State, City)
    public async Task<ApiResponse<IEnumerable<CountryDto>>> GetCountriesAsync(string search = "", bool activeOnly = true)
    {
        try
        {
            string cacheKey = $"loc_countries_s_{search}_act_{activeOnly}";
            if (_cache.TryGetValue(cacheKey, out IEnumerable<CountryDto>? cached) && cached != null)
            {
                return ApiResponse<IEnumerable<CountryDto>>.Ok(cached);
            }

            var countries = await _dbFactory.QueryAsync<Country>(
                "PR_S_Country",
                new { p_CountryId = -1, p_Search = search ?? "", p_IsActive = activeOnly ? 1 : -1 },
                commandType: CommandType.StoredProcedure);

            var dtos = countries.Where(c => c != null).Select(c => new CountryDto
            {
                CountryId = c.CountryId,
                CountryName = c.CountryName,
                CountryCode = c.CountryCode,
                InternationalDialing = c.InternationalDialing,
                Attribute1 = c.Attribute1,
                Attribute2 = c.Attribute2,
                Attribute3 = c.Attribute3,
                IsActive = c.IsActive
            }).ToList();

            _cache.Set(cacheKey, dtos.AsEnumerable(), CacheDuration);
            return ApiResponse<IEnumerable<CountryDto>>.Ok(dtos);
        }
        catch (Exception ex)
        {
            return ApiResponse<IEnumerable<CountryDto>>.Fail($"Failed to fetch countries: {ex.Message}");
        }
    }

    public async Task<ApiResponse<CountryDto>> GetCountryByIdAsync(int countryId)
    {
        try
        {
            var countries = await _dbFactory.QueryAsync<Country>(
                "PR_S_Country",
                new { p_CountryId = countryId, p_Search = "", p_IsActive = -1 },
                commandType: CommandType.StoredProcedure);

            var c = countries.FirstOrDefault();
            if (c == null) return ApiResponse<CountryDto>.Fail("Country not found.");

            var dto = new CountryDto
            {
                CountryId = c.CountryId,
                CountryName = c.CountryName,
                CountryCode = c.CountryCode,
                InternationalDialing = c.InternationalDialing,
                Attribute1 = c.Attribute1,
                Attribute2 = c.Attribute2,
                Attribute3 = c.Attribute3,
                IsActive = c.IsActive
            };

            return ApiResponse<CountryDto>.Ok(dto);
        }
        catch (Exception ex)
        {
            return ApiResponse<CountryDto>.Fail($"Failed to fetch country: {ex.Message}");
        }
    }

    public async Task<ApiResponse<CountryDto>> SaveCountryAsync(SaveCountryDto request, int userId)
    {
        try
        {
            var paramsObj = new
            {
                p_CountryId = request.CountryId,
                p_CountryName = request.CountryName,
                p_CountryCode = request.CountryCode,
                p_InternationalDialing = request.InternationalDialing,
                p_Attribute1 = request.Attribute1,
                p_Attribute2 = request.Attribute2,
                p_Attribute3 = request.Attribute3,
                p_IsActive = request.IsActive,
                p_UID = userId
            };

            var res = await _dbFactory.QuerySingleAsync<SPResult>(
                "PR_IU_Country",
                paramsObj,
                commandType: CommandType.StoredProcedure);

            var newId = Convert.ToInt32(res?.ID ?? 0);

            if (res != null && res.ErrNo == 0 && newId > 0)
            {
                var created = await GetCountryByIdAsync(newId);
                return created;
            }

            return ApiResponse<CountryDto>.Fail(res?.ErrMsg ?? "Failed to save country.");
        }
        catch (Exception ex)
        {
            return ApiResponse<CountryDto>.Fail($"Error saving country: {ex.Message}");
        }
    }

    public async Task<ApiResponse<bool>> DeleteCountryAsync(int countryId, int userId)
    {
        try
        {
            var countryRes = await GetCountryByIdAsync(countryId);
            if (!countryRes.Success || countryRes.Data == null) return ApiResponse<bool>.Fail("Country not found.");

            var request = new SaveCountryDto
            {
                CountryId = countryRes.Data.CountryId,
                CountryName = countryRes.Data.CountryName,
                CountryCode = countryRes.Data.CountryCode,
                InternationalDialing = countryRes.Data.InternationalDialing,
                Attribute1 = countryRes.Data.Attribute1,
                Attribute2 = countryRes.Data.Attribute2,
                Attribute3 = countryRes.Data.Attribute3,
                IsActive = false
            };

            var saveRes = await SaveCountryAsync(request, userId);
            return saveRes.Success ? ApiResponse<bool>.Ok(true, "Country deactivated successfully.") : ApiResponse<bool>.Fail(saveRes.Message);
        }
        catch (Exception ex)
        {
            return ApiResponse<bool>.Fail($"Error deleting country: {ex.Message}");
        }
    }

    public async Task<ApiResponse<IEnumerable<StateDto>>> GetStatesAsync(int countryId = -1, string search = "", bool activeOnly = true)
    {
        try
        {
            string cacheKey = $"loc_states_c_{countryId}_s_{search}_act_{activeOnly}";
            if (_cache.TryGetValue(cacheKey, out IEnumerable<StateDto>? cached) && cached != null)
            {
                return ApiResponse<IEnumerable<StateDto>>.Ok(cached);
            }

            var states = await _dbFactory.QueryAsync<State>(
                "PR_S_State",
                new { p_StateId = -1, p_CountryId = countryId, p_Search = search ?? "", p_IsActive = activeOnly ? 1 : -1 },
                commandType: CommandType.StoredProcedure);

            var dtos = states.Where(s => s != null).Select(s => new StateDto
            {
                StateId = s.StateId,
                CountryId = s.CountryId,
                StateName = s.StateName,
                StateCode = s.StateCode,
                CountryName = s.CountryName,
                CountryCode = s.CountryCode,
                Attribute1 = s.Attribute1,
                Attribute2 = s.Attribute2,
                Attribute3 = s.Attribute3,
                IsActive = s.IsActive
            }).ToList();

            _cache.Set(cacheKey, dtos.AsEnumerable(), CacheDuration);
            return ApiResponse<IEnumerable<StateDto>>.Ok(dtos);
        }
        catch (Exception ex)
        {
            return ApiResponse<IEnumerable<StateDto>>.Fail($"Failed to fetch states: {ex.Message}");
        }
    }

    public async Task<ApiResponse<StateDto>> GetStateByIdAsync(int stateId)
    {
        try
        {
            var states = await _dbFactory.QueryAsync<State>(
                "PR_S_State",
                new { p_StateId = stateId, p_CountryId = -1, p_Search = "", p_IsActive = -1 },
                commandType: CommandType.StoredProcedure);

            var s = states.FirstOrDefault();
            if (s == null) return ApiResponse<StateDto>.Fail("State not found.");

            var dto = new StateDto
            {
                StateId = s.StateId,
                CountryId = s.CountryId,
                StateName = s.StateName,
                StateCode = s.StateCode,
                CountryName = s.CountryName,
                CountryCode = s.CountryCode,
                Attribute1 = s.Attribute1,
                Attribute2 = s.Attribute2,
                Attribute3 = s.Attribute3,
                IsActive = s.IsActive
            };

            return ApiResponse<StateDto>.Ok(dto);
        }
        catch (Exception ex)
        {
            return ApiResponse<StateDto>.Fail($"Failed to fetch state: {ex.Message}");
        }
    }

    public async Task<ApiResponse<StateDto>> SaveStateAsync(SaveStateDto request, int userId)
    {
        try
        {
            var paramsObj = new
            {
                p_StateId = request.StateId,
                p_CountryId = request.CountryId,
                p_StateName = request.StateName,
                p_StateCode = request.StateCode,
                p_Attribute1 = request.Attribute1,
                p_Attribute2 = request.Attribute2,
                p_Attribute3 = request.Attribute3,
                p_IsActive = request.IsActive,
                p_UID = userId
            };

            var res = await _dbFactory.QuerySingleAsync<SPResult>(
                "PR_IU_State",
                paramsObj,
                commandType: CommandType.StoredProcedure);

            var newId = Convert.ToInt32(res?.ID ?? 0);

            if (res != null && res.ErrNo == 0 && newId > 0)
            {
                return await GetStateByIdAsync(newId);
            }

            return ApiResponse<StateDto>.Fail(res?.ErrMsg ?? "Failed to save state.");
        }
        catch (Exception ex)
        {
            return ApiResponse<StateDto>.Fail($"Error saving state: {ex.Message}");
        }
    }

    public async Task<ApiResponse<bool>> DeleteStateAsync(int stateId, int userId)
    {
        try
        {
            var stateRes = await GetStateByIdAsync(stateId);
            if (!stateRes.Success || stateRes.Data == null) return ApiResponse<bool>.Fail("State not found.");

            var request = new SaveStateDto
            {
                StateId = stateRes.Data.StateId,
                CountryId = stateRes.Data.CountryId,
                StateName = stateRes.Data.StateName,
                StateCode = stateRes.Data.StateCode,
                Attribute1 = stateRes.Data.Attribute1,
                Attribute2 = stateRes.Data.Attribute2,
                Attribute3 = stateRes.Data.Attribute3,
                IsActive = false
            };

            var saveRes = await SaveStateAsync(request, userId);
            return saveRes.Success ? ApiResponse<bool>.Ok(true, "State deactivated successfully.") : ApiResponse<bool>.Fail(saveRes.Message);
        }
        catch (Exception ex)
        {
            return ApiResponse<bool>.Fail($"Error deleting state: {ex.Message}");
        }
    }

    public async Task<ApiResponse<IEnumerable<CityDto>>> GetCitiesAsync(int stateId = -1, int countryId = -1, string search = "", bool activeOnly = true)
    {
        try
        {
            string cacheKey = $"loc_cities_st_{stateId}_co_{countryId}_s_{search}_act_{activeOnly}";
            if (_cache.TryGetValue(cacheKey, out IEnumerable<CityDto>? cached) && cached != null)
            {
                return ApiResponse<IEnumerable<CityDto>>.Ok(cached);
            }

            var cities = await _dbFactory.QueryAsync<City>(
                "PR_S_City",
                new { p_CityId = -1, p_StateId = stateId, p_CountryId = countryId, p_Search = search ?? "", p_IsActive = activeOnly ? 1 : -1 },
                commandType: CommandType.StoredProcedure);

            var dtos = cities.Where(c => c != null).Select(c => new CityDto
            {
                CityId = c.CityId,
                StateId = c.StateId,
                CityName = c.CityName,
                CityCode = c.CityCode,
                StateName = c.StateName,
                StateCode = c.StateCode,
                CountryId = c.CountryId,
                CountryName = c.CountryName,
                CountryCode = c.CountryCode,
                Attribute1 = c.Attribute1,
                Attribute2 = c.Attribute2,
                Attribute3 = c.Attribute3,
                IsActive = c.IsActive
            }).ToList();

            _cache.Set(cacheKey, dtos.AsEnumerable(), CacheDuration);
            return ApiResponse<IEnumerable<CityDto>>.Ok(dtos);
        }
        catch (Exception ex)
        {
            return ApiResponse<IEnumerable<CityDto>>.Fail($"Failed to fetch cities: {ex.Message}");
        }
    }

    public async Task<ApiResponse<CityDto>> GetCityByIdAsync(int cityId)
    {
        try
        {
            var cities = await _dbFactory.QueryAsync<City>(
                "PR_S_City",
                new { p_CityId = cityId, p_StateId = -1, p_CountryId = -1, p_Search = "", p_IsActive = -1 },
                commandType: CommandType.StoredProcedure);

            var c = cities.FirstOrDefault();
            if (c == null) return ApiResponse<CityDto>.Fail("City not found.");

            var dto = new CityDto
            {
                CityId = c.CityId,
                StateId = c.StateId,
                CityName = c.CityName,
                CityCode = c.CityCode,
                StateName = c.StateName,
                StateCode = c.StateCode,
                CountryId = c.CountryId,
                CountryName = c.CountryName,
                CountryCode = c.CountryCode,
                Attribute1 = c.Attribute1,
                Attribute2 = c.Attribute2,
                Attribute3 = c.Attribute3,
                IsActive = c.IsActive
            };

            return ApiResponse<CityDto>.Ok(dto);
        }
        catch (Exception ex)
        {
            return ApiResponse<CityDto>.Fail($"Failed to fetch city: {ex.Message}");
        }
    }

    public async Task<ApiResponse<CityDto>> SaveCityAsync(SaveCityDto request, int userId)
    {
        try
        {
            var paramsObj = new
            {
                p_CityId = request.CityId,
                p_StateId = request.StateId,
                p_CityName = request.CityName,
                p_CityCode = request.CityCode,
                p_Attribute1 = request.Attribute1,
                p_Attribute2 = request.Attribute2,
                p_Attribute3 = request.Attribute3,
                p_IsActive = request.IsActive,
                p_UID = userId
            };

            var res = await _dbFactory.QuerySingleAsync<SPResult>(
                "PR_IU_City",
                paramsObj,
                commandType: CommandType.StoredProcedure);

            var newId = Convert.ToInt32(res?.ID ?? 0);

            if (res != null && res.ErrNo == 0 && newId > 0)
            {
                return await GetCityByIdAsync(newId);
            }

            return ApiResponse<CityDto>.Fail(res?.ErrMsg ?? "Failed to save city.");
        }
        catch (Exception ex)
        {
            return ApiResponse<CityDto>.Fail($"Error saving city: {ex.Message}");
        }
    }

    public async Task<ApiResponse<bool>> DeleteCityAsync(int cityId, int userId)
    {
        try
        {
            var cityRes = await GetCityByIdAsync(cityId);
            if (!cityRes.Success || cityRes.Data == null) return ApiResponse<bool>.Fail("City not found.");

            var request = new SaveCityDto
            {
                CityId = cityRes.Data.CityId,
                StateId = cityRes.Data.StateId,
                CityName = cityRes.Data.CityName,
                CityCode = cityRes.Data.CityCode,
                Attribute1 = cityRes.Data.Attribute1,
                Attribute2 = cityRes.Data.Attribute2,
                Attribute3 = cityRes.Data.Attribute3,
                IsActive = false
            };

            var saveRes = await SaveCityAsync(request, userId);
            return saveRes.Success ? ApiResponse<bool>.Ok(true, "City deactivated successfully.") : ApiResponse<bool>.Fail(saveRes.Message);
        }
        catch (Exception ex)
        {
            return ApiResponse<bool>.Fail($"Error deleting city: {ex.Message}");
        }
    }
    #endregion

    #region User Addresses
    public async Task<ApiResponse<IEnumerable<UserAddressDto>>> GetUserAddressesAsync(int targetUserId)
    {
        try
        {
            var addresses = await _dbFactory.QueryAsync<UserAddress>(
                "PR_S_UserAddresses",
                new { p_AddressId = -1, p_UserId = targetUserId },
                commandType: CommandType.StoredProcedure);

            var dtos = addresses.Where(a => a != null).Select(a => new UserAddressDto
            {
                AddressId = a.AddressId,
                UserId = a.UserId,
                AddressTypeId = a.AddressTypeId,
                AddressTypeName = a.AddressTypeName,
                AddressLine1 = a.AddressLine1,
                AddressLine2 = a.AddressLine2,
                PostalCode = a.PostalCode,
                CountryId = a.CountryId,
                CountryName = a.CountryName,
                CountryCode = a.CountryCode,
                StateId = a.StateId,
                StateName = a.StateName,
                StateCode = a.StateCode,
                CityId = a.CityId,
                CityName = a.CityName,
                CityCode = a.CityCode,
                Latitude = a.Latitude,
                Longitude = a.Longitude,
                IsPrimary = a.IsPrimary,
                IsActive = a.IsActive
            });

            return ApiResponse<IEnumerable<UserAddressDto>>.Ok(dtos);
        }
        catch (Exception ex)
        {
            return ApiResponse<IEnumerable<UserAddressDto>>.Fail($"Failed to fetch user addresses: {ex.Message}");
        }
    }

    public async Task<ApiResponse<UserAddressDto>> GetUserAddressByIdAsync(long addressId)
    {
        try
        {
            var addresses = await _dbFactory.QueryAsync<UserAddress>(
                "PR_S_UserAddresses",
                new { p_AddressId = addressId, p_UserId = -1 },
                commandType: CommandType.StoredProcedure);

            var a = addresses.FirstOrDefault();
            if (a == null) return ApiResponse<UserAddressDto>.Fail("Address not found.");

            var dto = new UserAddressDto
            {
                AddressId = a.AddressId,
                UserId = a.UserId,
                AddressTypeId = a.AddressTypeId,
                AddressTypeName = a.AddressTypeName,
                AddressLine1 = a.AddressLine1,
                AddressLine2 = a.AddressLine2,
                PostalCode = a.PostalCode,
                CountryId = a.CountryId,
                CountryName = a.CountryName,
                CountryCode = a.CountryCode,
                StateId = a.StateId,
                StateName = a.StateName,
                StateCode = a.StateCode,
                CityId = a.CityId,
                CityName = a.CityName,
                CityCode = a.CityCode,
                Latitude = a.Latitude,
                Longitude = a.Longitude,
                IsPrimary = a.IsPrimary,
                IsActive = a.IsActive
            };

            return ApiResponse<UserAddressDto>.Ok(dto);
        }
        catch (Exception ex)
        {
            return ApiResponse<UserAddressDto>.Fail($"Failed to fetch user address: {ex.Message}");
        }
    }

    public async Task<ApiResponse<UserAddressDto>> SaveUserAddressAsync(SaveUserAddressRequestDto request, int actionUserId)
    {
        try
        {
            var paramsObj = new
            {
                p_AddressId = request.AddressId,
                p_UserId = request.UserId,
                p_AddressTypeId = request.AddressTypeId,
                p_AddressLine1 = request.AddressLine1,
                p_AddressLine2 = request.AddressLine2,
                p_PostalCode = request.PostalCode,
                p_CountryId = request.CountryId,
                p_StateId = request.StateId,
                p_CityId = request.CityId,
                p_Latitude = request.Latitude,
                p_Longitude = request.Longitude,
                p_IsPrimary = request.IsPrimary ? 1 : 0,
                p_IsActive = request.IsActive ? 1 : 0,
                p_UID = actionUserId
            };

            var res = await _dbFactory.QuerySingleAsync<SPResult>(
                "PR_IU_UserAddresses",
                paramsObj,
                commandType: CommandType.StoredProcedure);

            var newId = Convert.ToInt64(res?.ID ?? 0);

            if (res != null && res.ErrNo == 0 && newId > 0)
            {
                return await GetUserAddressByIdAsync(newId);
            }

            return ApiResponse<UserAddressDto>.Fail(res?.ErrMsg ?? "Failed to save user address.");
        }
        catch (Exception ex)
        {
            return ApiResponse<UserAddressDto>.Fail($"Error saving user address: {ex.Message}");
        }
    }

    public async Task<ApiResponse<bool>> DeleteUserAddressAsync(long addressId, int actionUserId)
    {
        try
        {
            var addrRes = await GetUserAddressByIdAsync(addressId);
            if (!addrRes.Success || addrRes.Data == null) return ApiResponse<bool>.Fail("Address not found.");

            var request = new SaveUserAddressRequestDto
            {
                AddressId = addrRes.Data.AddressId,
                UserId = addrRes.Data.UserId,
                AddressTypeId = addrRes.Data.AddressTypeId,
                AddressLine1 = addrRes.Data.AddressLine1,
                AddressLine2 = addrRes.Data.AddressLine2,
                PostalCode = addrRes.Data.PostalCode,
                CountryId = addrRes.Data.CountryId,
                StateId = addrRes.Data.StateId,
                CityId = addrRes.Data.CityId,
                Latitude = addrRes.Data.Latitude,
                Longitude = addrRes.Data.Longitude,
                IsPrimary = addrRes.Data.IsPrimary,
                IsActive = false
            };

            var saveRes = await SaveUserAddressAsync(request, actionUserId);
            return saveRes.Success ? ApiResponse<bool>.Ok(true, "User address deactivated successfully.") : ApiResponse<bool>.Fail(saveRes.Message);
        }
        catch (Exception ex)
        {
            return ApiResponse<bool>.Fail($"Error deleting user address: {ex.Message}");
        }
    }
    #endregion

    #region User Contacts
    public async Task<ApiResponse<IEnumerable<UserContactDto>>> GetUserContactsAsync(int targetUserId, bool emergencyOnly = false)
    {
        try
        {
            var contacts = await _dbFactory.QueryAsync<UserContact>(
                "PR_S_UserContacts",
                new { p_ContactId = -1, p_UserId = targetUserId, p_EmergencyOnly = emergencyOnly ? 1 : 0 },
                commandType: CommandType.StoredProcedure);

            var dtos = contacts.Where(c => c != null).Select(c => new UserContactDto
            {
                ContactId = c.ContactId,
                UserId = c.UserId,
                ContactTypeId = c.ContactTypeId,
                ContactTypeName = c.ContactTypeName,
                RelationshipTypeId = c.RelationshipTypeId,
                RelationshipTypeName = c.RelationshipTypeName,
                ContactValue = c.ContactValue,
                CountryCode = c.CountryCode,
                IsPrimary = c.IsPrimary,
                IsEmergency = c.IsEmergency,
                IsVerified = c.IsVerified,
                IsActive = c.IsActive
            });

            return ApiResponse<IEnumerable<UserContactDto>>.Ok(dtos);
        }
        catch (Exception ex)
        {
            return ApiResponse<IEnumerable<UserContactDto>>.Fail($"Failed to fetch user contacts: {ex.Message}");
        }
    }

    public async Task<ApiResponse<UserContactDto>> GetUserContactByIdAsync(long contactId)
    {
        try
        {
            var contacts = await _dbFactory.QueryAsync<UserContact>(
                "PR_S_UserContacts",
                new { p_ContactId = contactId, p_UserId = -1, p_EmergencyOnly = 0 },
                commandType: CommandType.StoredProcedure);

            var c = contacts.FirstOrDefault();
            if (c == null) return ApiResponse<UserContactDto>.Fail("Contact not found.");

            var dto = new UserContactDto
            {
                ContactId = c.ContactId,
                UserId = c.UserId,
                ContactTypeId = c.ContactTypeId,
                ContactTypeName = c.ContactTypeName,
                RelationshipTypeId = c.RelationshipTypeId,
                RelationshipTypeName = c.RelationshipTypeName,
                ContactValue = c.ContactValue,
                CountryCode = c.CountryCode,
                IsPrimary = c.IsPrimary,
                IsEmergency = c.IsEmergency,
                IsVerified = c.IsVerified,
                IsActive = c.IsActive
            };

            return ApiResponse<UserContactDto>.Ok(dto);
        }
        catch (Exception ex)
        {
            return ApiResponse<UserContactDto>.Fail($"Failed to fetch user contact: {ex.Message}");
        }
    }

    public async Task<ApiResponse<UserContactDto>> SaveUserContactAsync(SaveUserContactRequestDto request, int actionUserId)
    {
        try
        {
            var paramsObj = new
            {
                p_ContactId = request.ContactId,
                p_UserId = request.UserId,
                p_ContactTypeId = request.ContactTypeId,
                p_RelationshipTypeId = request.RelationshipTypeId,
                p_ContactValue = request.ContactValue,
                p_CountryCode = request.CountryCode,
                p_IsPrimary = request.IsPrimary ? 1 : 0,
                p_IsEmergency = request.IsEmergency ? 1 : 0,
                p_IsVerified = request.IsVerified ? 1 : 0,
                p_IsActive = request.IsActive ? 1 : 0,
                p_UID = actionUserId
            };

            var res = await _dbFactory.QuerySingleAsync<SPResult>(
                "PR_IU_UserContacts",
                paramsObj,
                commandType: CommandType.StoredProcedure);

            var newId = Convert.ToInt64(res?.ID ?? 0);

            if (res != null && res.ErrNo == 0 && newId > 0)
            {
                return await GetUserContactByIdAsync(newId);
            }

            return ApiResponse<UserContactDto>.Fail(res?.ErrMsg ?? "Failed to save user contact.");
        }
        catch (Exception ex)
        {
            return ApiResponse<UserContactDto>.Fail($"Error saving user contact: {ex.Message}");
        }
    }

    public async Task<ApiResponse<bool>> DeleteUserContactAsync(long contactId, int actionUserId)
    {
        try
        {
            var contactRes = await GetUserContactByIdAsync(contactId);
            if (!contactRes.Success || contactRes.Data == null) return ApiResponse<bool>.Fail("Contact not found.");

            var request = new SaveUserContactRequestDto
            {
                ContactId = contactRes.Data.ContactId,
                UserId = contactRes.Data.UserId,
                ContactTypeId = contactRes.Data.ContactTypeId,
                RelationshipTypeId = contactRes.Data.RelationshipTypeId,
                ContactValue = contactRes.Data.ContactValue,
                CountryCode = contactRes.Data.CountryCode,
                IsPrimary = contactRes.Data.IsPrimary,
                IsEmergency = contactRes.Data.IsEmergency,
                IsVerified = contactRes.Data.IsVerified,
                IsActive = false
            };

            var saveRes = await SaveUserContactAsync(request, actionUserId);
            return saveRes.Success ? ApiResponse<bool>.Ok(true, "User contact deactivated successfully.") : ApiResponse<bool>.Fail(saveRes.Message);
        }
        catch (Exception ex)
        {
            return ApiResponse<bool>.Fail($"Error deleting user contact: {ex.Message}");
        }
    }
    #endregion
}
