using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using AntiGravity.Enterprise.Shared.Core.Controllers;
using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.Interfaces.Payments;
using DNAQMSAPI.Domain.Entities;

namespace DNAQMSAPI.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class WebhookController : ApiControllerBase
{
    private readonly IPaymentService _paymentService;

    public WebhookController(IPaymentService paymentService)
    {
        _paymentService = paymentService;
    }

    [HttpPost("{providerCode}")]
    public async Task<IActionResult> ReceiveWebhook(string providerCode)
    {
        using var reader = new StreamReader(Request.Body);
        var payload = await reader.ReadToEndAsync();

        // Typically you'd validate the signature here using an IWebhookProcessor per provider

        var webhookLog = new WebhookLog
        {
            Guid = Guid.NewGuid(),
            PaymentProviderId = providerCode.ToUpper() == "RAZORPAY" ? 1 : 2, // Map to DB ID
            EventId = Guid.NewGuid().ToString(), // Should be parsed from payload
            EventType = "webhook.received",
            Payload = payload,
            CreatedBy = "System"
        };

        // Logs to DB via Stored Procedure pr_LogWebhookEvent
        await _paymentService.LogWebhookEventAsync(webhookLog);

        return Ok();
    }
}
