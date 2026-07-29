using System;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using Microsoft.AspNetCore.Mvc;
using DNAQMSAPI.Application.InvoiceGeneration.Interfaces;
using DNAQMSAPI.Application.InvoiceGeneration.DTOs;

namespace DNAQMSAPI.Api.Controllers.InvoiceGeneration;

[ApiController]
[Route("api/v1/[controller]")]
public class InvoiceController : ApiControllerBase
{
    private readonly IInvoiceService _invoiceService;

    public InvoiceController(IInvoiceService invoiceService)
    {
        _invoiceService = invoiceService;
    }

    [HttpGet("{invoiceId}")]
    public async Task<IActionResult> GetInvoiceDetails(Guid invoiceId)
    {
        var invoice = await _invoiceService.GetInvoiceDetailsAsync(invoiceId);
        if (invoice == null) 
            return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<InvoiceModel>.Fail("Invoice not found."));
            
        return ApiResponse(AntiGravity.Enterprise.Shared.Core.Models.ApiResponse<InvoiceModel>.Ok(invoice));
    }

    [HttpGet("{invoiceId}/render")]
    [Produces("text/html")]
    public async Task<IActionResult> RenderInvoiceHtml(Guid invoiceId)
    {
        var html = await _invoiceService.GetInvoiceHtmlAsync(invoiceId);
        return Content(html, "text/html");
    }
}
