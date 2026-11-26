using System;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using DNAQMSAPI.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DNAQMSAPI.Api.Controllers;

[ApiController]
[Route("api/v1/dqms/gdpr")]
[AllowAnonymous]
public class GdprController : ApiControllerBase
{
    private readonly IDataPrivacyService _privacyService;

    public GdprController(IDataPrivacyService privacyService)
    {
        _privacyService = privacyService ?? throw new ArgumentNullException(nameof(privacyService));
    }

    /// <summary>
    /// Executes GDPR Article 17 Right-To-Be-Forgotten cryptographic erasure for a customer.
    /// Replaces PII with synthetic tombstones while preserving queue analytics metrics.
    /// </summary>
    [HttpPost("right-to-be-forgotten")]
    public async Task<IActionResult> RightToBeForgotten(
        [FromBody] GdprRightToBeForgottenRequest request,
        [FromHeader(Name = "X-User-Id")] int userId = 1)
    {
        if (request == null || request.OrganizationId <= 0)
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Valid OrganizationId is required."));
        }

        if (string.IsNullOrWhiteSpace(request.CustomerPhoneNumber))
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("CustomerPhoneNumber is required for Article 17 erasure lookup."));
        }

        var result = await _privacyService.ExecuteRightToBeForgottenAsync(request, userId);
        if (!result.Success)
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail(result.Message));
        }

        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(result, result.Message));
    }

    /// <summary>
    /// Exports all customer visits and token history in machine-readable format (GDPR Article 20 Data Portability).
    /// </summary>
    [HttpGet("export")]
    public async Task<IActionResult> ExportCustomerData(
        [FromQuery] int organizationId = 1,
        [FromQuery] string customerPhoneNumber = "")
    {
        if (organizationId <= 0)
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("Valid OrganizationId is required."));
        }

        if (string.IsNullOrWhiteSpace(customerPhoneNumber))
        {
            return BadRequest(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Fail("CustomerPhoneNumber is required for data portability export."));
        }

        var exportPackage = await _privacyService.ExportCustomerDataAsync(organizationId, customerPhoneNumber);
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<object>.Ok(exportPackage, "Customer data export package generated successfully."));
    }
}
