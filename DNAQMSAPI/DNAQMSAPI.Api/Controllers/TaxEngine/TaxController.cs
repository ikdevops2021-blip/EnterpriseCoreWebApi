using System;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Controllers;
using Microsoft.AspNetCore.Mvc;
using DNAQMSAPI.Application.TaxEngine.DTOs;
using DNAQMSAPI.Application.TaxEngine.Interfaces;

namespace DNAQMSAPI.Api.Controllers.TaxEngine;

[ApiController]
[Route("api/v1/[controller]")]
public class TaxController : ApiControllerBase
{
    private readonly ITaxService _taxService;

    public TaxController(ITaxService taxService)
    {
        _taxService = taxService;
    }

    [HttpPost("calculate")]
    public async Task<IActionResult> CalculateTax([FromBody] TaxRequest request)
    {
        if (request.BaseAmount < 0)
        {
            return BadRequest("Base amount cannot be negative.");
        }

        var result = await _taxService.CalculateTaxAsync(request);
        return ApiResponse(result);
    }
}
