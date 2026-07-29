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
public class ConfigurationController : ApiControllerBase
{
    private readonly IConfigurationService _configurationService;
    private readonly RequestContext _requestContext;

    public ConfigurationController(IConfigurationService configurationService, RequestContext requestContext)
    {
        _configurationService = configurationService;
        _requestContext = requestContext;
    }

    [HttpGet("categories")]
    public async Task<IActionResult> GetCategories()
    {
        var result = await _configurationService.GetConfigCategoriesAsync();
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(result));
    }

    [HttpGet("categories/{categoryId:int}")]
    public async Task<IActionResult> GetCategoryById(int categoryId)
    {
        var result = await _configurationService.GetConfigCategoryByIdAsync(categoryId);
        return result == null
            ? NotFound(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Category not found."))
            : ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(result));
    }

    [HttpPost("categories")]
    public async Task<IActionResult> CreateCategory([FromBody] CreateConfigCategoryRequestDto request)
    {
        if (request == null)
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        }

        var category = new DNAQMSAPI.Domain.Entities.ConfigCategory
        {
            CategoryCode = request.CategoryCode.Trim(),
            CategoryName = request.CategoryName.Trim(),
            Description = request.Description,
            Priority = request.Priority,
            Active = request.Active,
            AllowModify = request.AllowModify,
            ParentCategoryID = request.ParentCategoryID,
            CategoryExternalID = request.CategoryExternalID,
            CategoryExternalName = request.CategoryExternalName,
            CategoryExternalCode = request.CategoryExternalCode,
            CategoryColor = request.CategoryColor,
            CategoryIcon = request.CategoryIcon,
            CategoryImage = request.CategoryImage,
            Attribute1 = request.Attribute1,
            Attribute2 = request.Attribute2,
            Attribute3 = request.Attribute3,
            CreatedBy = _requestContext.UserId,
            ModifiedBy = _requestContext.UserId,
            IsDeleted = false
        };

        var created = await _configurationService.CreateConfigCategoryAsync(category);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(created, "Category created successfully."));
    }

    [HttpPut("categories/{categoryId:int}")]
    public async Task<IActionResult> UpdateCategory(int categoryId, [FromBody] UpdateConfigCategoryRequestDto request)
    {
        if (request == null)
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        }

        var category = new DNAQMSAPI.Domain.Entities.ConfigCategory
        {
            CategoryID = categoryId,
            CategoryCode = request.CategoryCode.Trim(),
            CategoryName = request.CategoryName.Trim(),
            Description = request.Description,
            Priority = request.Priority,
            Active = request.Active,
            AllowModify = request.AllowModify,
            ParentCategoryID = request.ParentCategoryID,
            CategoryExternalID = request.CategoryExternalID,
            CategoryExternalName = request.CategoryExternalName,
            CategoryExternalCode = request.CategoryExternalCode,
            CategoryColor = request.CategoryColor,
            CategoryIcon = request.CategoryIcon,
            CategoryImage = request.CategoryImage,
            Attribute1 = request.Attribute1,
            Attribute2 = request.Attribute2,
            Attribute3 = request.Attribute3,
            ModifiedBy = _requestContext.UserId
        };

        var updated = await _configurationService.UpdateConfigCategoryAsync(category);
        return updated
            ? ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(category, "Category updated successfully."))
            : NotFound(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Category not found."));
    }

    [HttpDelete("categories/{categoryId:int}")]
    public async Task<IActionResult> DeleteCategory(int categoryId)
    {
        var deleted = await _configurationService.DeleteConfigCategoryAsync(categoryId, _requestContext.UserId);
        return deleted
            ? ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new { CategoryID = categoryId }, "Category deleted successfully."))
            : NotFound(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Category not found."));
    }

    [HttpGet("categories/{categoryId:int}/parameters")]
    public async Task<IActionResult> GetParametersByCategory(int categoryId)
    {
        var result = await _configurationService.GetConfigParametersByCategoryAsync(categoryId);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(result));
    }

    [HttpGet("categories/by-code/{categoryCode}/parameters")]
    public async Task<IActionResult> GetParametersByCategoryCode(string categoryCode)
    {
        if (string.IsNullOrWhiteSpace(categoryCode))
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Category code is required."));
        }

        var result = await _configurationService.GetConfigParametersByCategoryCodeAsync(categoryCode.Trim());
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(result));
    }

    [HttpGet("parameters/{parameterId:int}")]
    public async Task<IActionResult> GetParameterById(int parameterId)
    {
        var result = await _configurationService.GetConfigParameterByIdAsync(parameterId);
        return result == null
            ? NotFound(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Parameter not found."))
            : ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(result));
    }

    [HttpPost("parameters")]
    public async Task<IActionResult> CreateParameter([FromBody] CreateConfigParameterRequestDto request)
    {
        if (request == null)
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        }

        var parameter = new DNAQMSAPI.Domain.Entities.ConfigParameter
        {
            CategoryID = request.CategoryID,
            ParameterCode = request.ParameterCode.Trim(),
            ParameterName = request.ParameterName.Trim(),
            IsDefault = request.IsDefault,
            Priority = request.Priority,
            IsActive = request.IsActive,
            ParameterExternalID = request.ParameterExternalID,
            ParameterExternalName = request.ParameterExternalName,
            ParameterExternalCode = request.ParameterExternalCode,
            ParameterColor = request.ParameterColor,
            ParameterIcon = request.ParameterIcon,
            ParameterImage = request.ParameterImage,
            Attribute1 = request.Attribute1,
            Attribute2 = request.Attribute2,
            Attribute3 = request.Attribute3,
            CreatedBy = _requestContext.UserId,
            ModifiedBy = _requestContext.UserId,
            IsDeleted = false
        };

        var created = await _configurationService.CreateConfigParameterAsync(parameter);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(created, "Parameter created successfully."));
    }

    [HttpPut("parameters/{parameterId:int}")]
    public async Task<IActionResult> UpdateParameter(int parameterId, [FromBody] UpdateConfigParameterRequestDto request)
    {
        if (request == null)
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        }

        var parameter = new DNAQMSAPI.Domain.Entities.ConfigParameter
        {
            ParameterID = parameterId,
            CategoryID = request.CategoryID,
            ParameterCode = request.ParameterCode.Trim(),
            ParameterName = request.ParameterName.Trim(),
            IsDefault = request.IsDefault,
            Priority = request.Priority,
            IsActive = request.IsActive,
            ParameterExternalID = request.ParameterExternalID,
            ParameterExternalName = request.ParameterExternalName,
            ParameterExternalCode = request.ParameterExternalCode,
            ParameterColor = request.ParameterColor,
            ParameterIcon = request.ParameterIcon,
            ParameterImage = request.ParameterImage,
            Attribute1 = request.Attribute1,
            Attribute2 = request.Attribute2,
            Attribute3 = request.Attribute3,
            ModifiedBy = _requestContext.UserId
        };

        var updated = await _configurationService.UpdateConfigParameterAsync(parameter);
        return updated
            ? ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(parameter, "Parameter updated successfully."))
            : NotFound(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Parameter not found."));
    }

    [HttpDelete("parameters/{parameterId:int}")]
    public async Task<IActionResult> DeleteParameter(int parameterId)
    {
        var deleted = await _configurationService.DeleteConfigParameterAsync(parameterId, _requestContext.UserId);
        return deleted
            ? ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(new { ParameterID = parameterId }, "Parameter deleted successfully."))
            : NotFound(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Parameter not found."));
    }

    [HttpGet("system-configurations")]
    public async Task<IActionResult> GetSystemConfigurations()
    {
        var result = await _configurationService.GetSystemConfigurationsAsync();
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(result));
    }

    [HttpGet("system-configurations/{key}")]
    public async Task<IActionResult> GetSystemConfigurationByKey(string key)
    {
        var result = await _configurationService.GetSystemConfigurationByKeyAsync(key);
        return result == null
            ? NotFound(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Configuration key not found."))
            : ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(result));
    }

    [HttpPut("system-configurations/{key}")]
    public async Task<IActionResult> UpdateSystemConfiguration(string key, [FromBody] UpdateSystemConfigurationRequestDto request)
    {
        if (request == null)
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Request body is required."));
        }

        var updated = await _configurationService.UpdateSystemConfigurationAsync(key, request.Value, _requestContext.UserId);
        if (!updated)
        {
            return StatusCode(500, AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Configuration update failed."));
        }

        var current = await _configurationService.GetSystemConfigurationByKeyAsync(key);
        if (current == null)
        {
            return NotFound(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Configuration key not found after update."));
        }

        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(current, "Configuration updated successfully."));
    }
}
