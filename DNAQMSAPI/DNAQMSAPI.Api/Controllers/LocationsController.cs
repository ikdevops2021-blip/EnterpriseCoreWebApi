using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.DTOs;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Security.Middlewares;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/v1/[controller]")]
public class LocationsController : ApiControllerBase
{
    private readonly ILocationAndUserProfileService _locationService;
    private readonly RequestContext _requestContext;

    public LocationsController(ILocationAndUserProfileService locationService, RequestContext requestContext)
    {
        _locationService = locationService;
        _requestContext = requestContext;
    }

    #region Country Endpoints
    [HttpGet("countries")]
    public async Task<IActionResult> GetCountries([FromQuery] string? search = "", [FromQuery] bool activeOnly = true)
    {
        return ApiResponse(await _locationService.GetCountriesAsync(search ?? "", activeOnly));
    }

    [HttpGet("countries/{countryId:int}")]
    public async Task<IActionResult> GetCountryById(int countryId)
    {
        return ApiResponse(await _locationService.GetCountryByIdAsync(countryId));
    }

    [HttpPost("countries")]
    public async Task<IActionResult> CreateCountry([FromBody] CreateCountryRequestDto request)
    {
        if (request == null) return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        var saveDto = new SaveCountryDto
        {
            CountryId = 0,
            CountryName = request.CountryName,
            CountryCode = request.CountryCode,
            InternationalDialing = request.InternationalDialing,
            Attribute1 = request.Attribute1,
            Attribute2 = request.Attribute2,
            Attribute3 = request.Attribute3,
            IsActive = request.IsActive
        };
        return ApiResponse(await _locationService.SaveCountryAsync(saveDto, _requestContext.UserId));
    }

    [HttpPut("countries/{countryId:int}")]
    public async Task<IActionResult> UpdateCountry(int countryId, [FromBody] CreateCountryRequestDto request)
    {
        if (request == null) return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        var saveDto = new SaveCountryDto
        {
            CountryId = countryId,
            CountryName = request.CountryName,
            CountryCode = request.CountryCode,
            InternationalDialing = request.InternationalDialing,
            Attribute1 = request.Attribute1,
            Attribute2 = request.Attribute2,
            Attribute3 = request.Attribute3,
            IsActive = request.IsActive
        };
        return ApiResponse(await _locationService.SaveCountryAsync(saveDto, _requestContext.UserId));
    }

    [HttpDelete("countries/{countryId:int}")]
    public async Task<IActionResult> DeleteCountry(int countryId)
    {
        return ApiResponse(await _locationService.DeleteCountryAsync(countryId, _requestContext.UserId));
    }
    #endregion

    #region State Endpoints
    [HttpGet("states")]
    public async Task<IActionResult> GetStates([FromQuery] int countryId = -1, [FromQuery] string? search = "", [FromQuery] bool activeOnly = true)
    {
        return ApiResponse(await _locationService.GetStatesAsync(countryId, search ?? "", activeOnly));
    }

    [HttpGet("states/{stateId:int}")]
    public async Task<IActionResult> GetStateById(int stateId)
    {
        return ApiResponse(await _locationService.GetStateByIdAsync(stateId));
    }

    [HttpPost("states")]
    public async Task<IActionResult> CreateState([FromBody] CreateStateRequestDto request)
    {
        if (request == null) return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        var saveDto = new SaveStateDto
        {
            StateId = 0,
            CountryId = request.CountryId,
            StateName = request.StateName,
            StateCode = request.StateCode,
            Attribute1 = request.Attribute1,
            Attribute2 = request.Attribute2,
            Attribute3 = request.Attribute3,
            IsActive = request.IsActive
        };
        return ApiResponse(await _locationService.SaveStateAsync(saveDto, _requestContext.UserId));
    }

    [HttpPut("states/{stateId:int}")]
    public async Task<IActionResult> UpdateState(int stateId, [FromBody] CreateStateRequestDto request)
    {
        if (request == null) return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        var saveDto = new SaveStateDto
        {
            StateId = stateId,
            CountryId = request.CountryId,
            StateName = request.StateName,
            StateCode = request.StateCode,
            Attribute1 = request.Attribute1,
            Attribute2 = request.Attribute2,
            Attribute3 = request.Attribute3,
            IsActive = request.IsActive
        };
        return ApiResponse(await _locationService.SaveStateAsync(saveDto, _requestContext.UserId));
    }

    [HttpDelete("states/{stateId:int}")]
    public async Task<IActionResult> DeleteState(int stateId)
    {
        return ApiResponse(await _locationService.DeleteStateAsync(stateId, _requestContext.UserId));
    }
    #endregion

    #region City Endpoints
    [HttpGet("cities")]
    public async Task<IActionResult> GetCities([FromQuery] int stateId = -1, [FromQuery] int countryId = -1, [FromQuery] string? search = "", [FromQuery] bool activeOnly = true)
    {
        return ApiResponse(await _locationService.GetCitiesAsync(stateId, countryId, search ?? "", activeOnly));
    }

    [HttpGet("cities/{cityId:int}")]
    public async Task<IActionResult> GetCityById(int cityId)
    {
        return ApiResponse(await _locationService.GetCityByIdAsync(cityId));
    }

    [HttpPost("cities")]
    public async Task<IActionResult> CreateCity([FromBody] CreateCityRequestDto request)
    {
        if (request == null) return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        var saveDto = new SaveCityDto
        {
            CityId = 0,
            StateId = request.StateId,
            CityName = request.CityName,
            CityCode = request.CityCode,
            Attribute1 = request.Attribute1,
            Attribute2 = request.Attribute2,
            Attribute3 = request.Attribute3,
            IsActive = request.IsActive
        };
        return ApiResponse(await _locationService.SaveCityAsync(saveDto, _requestContext.UserId));
    }

    [HttpPut("cities/{cityId:int}")]
    public async Task<IActionResult> UpdateCity(int cityId, [FromBody] CreateCityRequestDto request)
    {
        if (request == null) return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        var saveDto = new SaveCityDto
        {
            CityId = cityId,
            StateId = request.StateId,
            CityName = request.CityName,
            CityCode = request.CityCode,
            Attribute1 = request.Attribute1,
            Attribute2 = request.Attribute2,
            Attribute3 = request.Attribute3,
            IsActive = request.IsActive
        };
        return ApiResponse(await _locationService.SaveCityAsync(saveDto, _requestContext.UserId));
    }

    [HttpDelete("cities/{cityId:int}")]
    public async Task<IActionResult> DeleteCity(int cityId)
    {
        return ApiResponse(await _locationService.DeleteCityAsync(cityId, _requestContext.UserId));
    }
    #endregion
}
