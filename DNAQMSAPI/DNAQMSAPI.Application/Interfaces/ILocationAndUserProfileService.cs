using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.DTOs;

namespace DNAQMSAPI.Application.Interfaces;

public interface ILocationAndUserProfileService
{
    #region Location Masters (Country, State, City)
    Task<ApiResponse<IEnumerable<CountryDto>>> GetCountriesAsync(string search = "", bool activeOnly = true);
    Task<ApiResponse<CountryDto>> GetCountryByIdAsync(int countryId);
    Task<ApiResponse<CountryDto>> SaveCountryAsync(SaveCountryDto request, int userId);
    Task<ApiResponse<bool>> DeleteCountryAsync(int countryId, int userId);

    Task<ApiResponse<IEnumerable<StateDto>>> GetStatesAsync(int countryId = -1, string search = "", bool activeOnly = true);
    Task<ApiResponse<StateDto>> GetStateByIdAsync(int stateId);
    Task<ApiResponse<StateDto>> SaveStateAsync(SaveStateDto request, int userId);
    Task<ApiResponse<bool>> DeleteStateAsync(int stateId, int userId);

    Task<ApiResponse<IEnumerable<CityDto>>> GetCitiesAsync(int stateId = -1, int countryId = -1, string search = "", bool activeOnly = true);
    Task<ApiResponse<CityDto>> GetCityByIdAsync(int cityId);
    Task<ApiResponse<CityDto>> SaveCityAsync(SaveCityDto request, int userId);
    Task<ApiResponse<bool>> DeleteCityAsync(int cityId, int userId);
    #endregion

    #region User Addresses
    Task<ApiResponse<IEnumerable<UserAddressDto>>> GetUserAddressesAsync(int targetUserId);
    Task<ApiResponse<UserAddressDto>> GetUserAddressByIdAsync(long addressId);
    Task<ApiResponse<UserAddressDto>> SaveUserAddressAsync(SaveUserAddressRequestDto request, int actionUserId);
    Task<ApiResponse<bool>> DeleteUserAddressAsync(long addressId, int actionUserId);
    #endregion

    #region User Contacts
    Task<ApiResponse<IEnumerable<UserContactDto>>> GetUserContactsAsync(int targetUserId, bool emergencyOnly = false);
    Task<ApiResponse<UserContactDto>> GetUserContactByIdAsync(long contactId);
    Task<ApiResponse<UserContactDto>> SaveUserContactAsync(SaveUserContactRequestDto request, int actionUserId);
    Task<ApiResponse<bool>> DeleteUserContactAsync(long contactId, int actionUserId);
    #endregion
}

public class SaveCountryDto : CreateCountryRequestDto
{
    public int CountryId { get; set; }
}

public class SaveStateDto : CreateStateRequestDto
{
    public int StateId { get; set; }
}

public class SaveCityDto : CreateCityRequestDto
{
    public int CityId { get; set; }
}
