using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Models;
using Dapper;
using Microsoft.Extensions.Logging;
using DNAQMSAPI.Application.TaxEngine.DTOs;
using DNAQMSAPI.Application.TaxEngine.Interfaces;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.TaxEngine.Enums;

namespace DNAQMSAPI.Infrastructure.TaxEngine.Services;

public class TaxService : ITaxService
{
    private readonly IDapperDBFactory _dbFactory;
    private readonly ILogger<TaxService> _logger;

    public TaxService(IDapperDBFactory dbFactory, ILogger<TaxService> logger)
    {
        _dbFactory = dbFactory ?? throw new ArgumentNullException(nameof(dbFactory));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ApiResponse<TaxResult>> CalculateTaxAsync(TaxRequest request, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Calculating tax dynamically for InvoiceId: {InvoiceId}, BaseAmount: {BaseAmount}, Regional Mapping: {CountryCode}-{StateCode}", 
            request.InvoiceId, request.BaseAmount, request.CountryCode, request.StateCode);

        try
        {
            // 1. Fetch valid TaxRules based on Region Mapping via stored procedure
            var validRules = await _dbFactory.QueryAsync<dynamic>(
                "PR_S_TaxCalculation",
                new { p_CountryCode = request.CountryCode, p_StateCode = request.StateCode },
                commandType: CommandType.StoredProcedure);

            if (!validRules.Any())
            {
                _logger.LogWarning("No active tax rules located for Region {CountryCode}-{StateCode}. Returning 0 tax liability.", request.CountryCode, request.StateCode);
                return ApiResponse<TaxResult>.Ok(new TaxResult
                {
                    InvoiceId = request.InvoiceId,
                    BaseAmount = request.BaseAmount,
                    TotalTaxAmount = 0,
                    TotalAmount = request.BaseAmount
                });
            }

            var result = new TaxResult
            {
                InvoiceId = request.InvoiceId,
                BaseAmount = request.BaseAmount
            };

            decimal accumulatedTax = 0;

            // 2. Compute Mathematics Based on Priority Map
            foreach (var rule in validRules)
            {
                decimal currentTaxAmount = 0;
                var calculationType = (TaxCalculationType)rule.CalculationType;
                var applicationType = (TaxApplicationType)rule.ApplicationType;
                decimal ruleRate = (decimal)rule.Rate;

                // Simple Math Mapping
                if (calculationType == TaxCalculationType.Percentage)
                {
                    // If Exclusive, calculate on strict Base Amount. (Ignoring Compound math for brevity)
                    currentTaxAmount = request.BaseAmount * (ruleRate / 100m);
                }
                else if (calculationType == TaxCalculationType.Fixed)
                {
                    currentTaxAmount = ruleRate;
                }

                accumulatedTax += currentTaxAmount;

                result.Breakdowns.Add(new TaxBreakdownItem
                {
                    TaxTypeId = (int)rule.TaxTypeId,
                    TaxName = "Dynamic " + applicationType.ToString() + " Tax", // In real scenario, join name from TaxTypes
                    Rate = ruleRate,
                    TaxAmount = currentTaxAmount
                });
            }

            // 3. Finalize Result Base
            result.TotalTaxAmount = accumulatedTax;
            result.TotalAmount = request.BaseAmount + accumulatedTax;

            _logger.LogInformation("Successfully mapped Tax Result Payload for {InvoiceId}. Total Tax Output: {TotalTaxAmount}", request.InvoiceId, result.TotalTaxAmount);

            return ApiResponse<TaxResult>.Ok(result, "Tax evaluated successfully based on regional database configurations.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "A fatal architecture error occurred evaluating SQL Database limits inside TaxEngine. Parameters: Invoice {InvoiceId}", request.InvoiceId);
            return ApiResponse<TaxResult>.Fail($"Internal Server Engine Error: {ex.Message}");
        }
    }
}

