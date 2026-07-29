using System;
using System.Data;
using System.Threading;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Models;
using Microsoft.Extensions.Logging;
using DNAQMSAPI.Application.SubscriptionSaaS.DTOs;
using DNAQMSAPI.Application.SubscriptionSaaS.Interfaces;
using DNAQMSAPI.Application.TaxEngine.DTOs;
using DNAQMSAPI.Application.TaxEngine.Interfaces;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Infrastructure.Models;

namespace DNAQMSAPI.Infrastructure.SubscriptionSaaS.Services;

public class BillingService : IBillingService
{
    private readonly ITaxService _taxService;
    private readonly IDapperDBFactory _dbFactory;
    private readonly ILogger<BillingService> _logger;

    public BillingService(ITaxService taxService, IDapperDBFactory dbFactory, ILogger<BillingService> logger)
    {
        _taxService = taxService ?? throw new ArgumentNullException(nameof(taxService));
        _dbFactory = dbFactory ?? throw new ArgumentNullException(nameof(dbFactory));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ApiResponse<BillingResult>> GenerateInvoiceAsync(Guid subscriptionId, decimal baseAmount, string countryCode, string? stateCode, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Generating Global Invoice for SubscriptionId: {SubscriptionId} at BaseAmount: {BaseAmount}", subscriptionId, baseAmount);

        try
        {
            var invoiceId = Guid.NewGuid();

            // 1. Calculate taxes logically by invoking the TaxEngine boundaries
            var taxRequest = new TaxRequest
            {
                InvoiceId = invoiceId,
                BaseAmount = baseAmount,
                CountryCode = countryCode,
                StateCode = stateCode
            };

            var taxApiResponse = await _taxService.CalculateTaxAsync(taxRequest, cancellationToken);
            if (!taxApiResponse.Success || taxApiResponse.Data == null)
            {
                _logger.LogError("Failed to generate tax evaluations via internal DI resolution.");
                return ApiResponse<BillingResult>.Fail("Dependency Tax Computation Engine failed. Halt billing execution.");
            }

            var taxResponse = taxApiResponse.Data;

            // 2. Persist via stored procedure (handles both BillingHistory + InvoiceMetadata atomically)
            var result = await _dbFactory.QuerySingleAsync<SPResult>(
                "PR_IU_BillingInvoice",
                new
                {
                    p_BillingHistoryId = invoiceId.ToString(),
                    p_SubscriptionId = subscriptionId.ToString(),
                    p_NetAmount = baseAmount,
                    p_TotalTax = taxResponse.TotalTaxAmount,
                    p_GrossAmount = taxResponse.TotalAmount,
                    p_InvoiceUrl = $"/invoices/{invoiceId}.pdf",
                    p_Status = 1,
                    p_CustomerVat = "VAT-CUST-987654",
                    p_TenantVat = "VAT-TNT-123456",
                    p_IsReverseCharge = false,
                    p_CountryData = "{\"region\": \"EU\", \"compliance_code\": \"XYZ-123\"}",
                    p_UID = 0
                },
                commandType: CommandType.StoredProcedure);

            _logger.LogInformation("Successfully mapped Tax Data into the SQL Billing Pipeline seamlessly linking Dapper Architectures.");

            return ApiResponse<BillingResult>.Ok(new BillingResult
            {
                InvoiceId = invoiceId,
                NetAmount = baseAmount,
                TaxAmount = taxResponse.TotalTaxAmount,
                GrossAmount = taxResponse.TotalAmount,
                BillingDate = DateTime.UtcNow,
                Status = "Invoice Generated and Saved to Ledger via Analytics Dapper Schema"
            }, "Invoice completely formulated and persisted globally.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fatal Error encountered rendering Invoices within the Operational Dapper pipeline.");
            return ApiResponse<BillingResult>.Fail($"Internal Core Error: {ex.Message}");
        }
    }
}

