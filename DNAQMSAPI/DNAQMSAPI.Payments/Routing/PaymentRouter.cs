using System.Threading.Tasks;
using DNAQMSAPI.Application.Interfaces.Payments;
using DNAQMSAPI.Application.Interfaces;
using Dapper;
using System.Data;

namespace DNAQMSAPI.Payments.Routing;

public class PaymentRouter : IPaymentRouter
{
    private readonly IDapperDBFactory _dbFactory;

    public PaymentRouter(IDapperDBFactory dbFactory)
    {
        _dbFactory = dbFactory;
    }

    public async Task<string> GetPreferredProviderCodeAsync(int organizationId, int branchId, string paymentMethod)
    {
        // In a real scenario, this might call a function like fn_GetPreferredProvider
        // For now, we simulate a simple query returning the active top priority provider
        using var connection = _dbFactory.GetConnection();
        var query = @"
            SELECT TOP 1 pp.Code
            FROM BranchPaymentProviders bpp
            JOIN OrganizationPaymentProviders opp ON bpp.OrganizationPaymentProviderId = opp.Id
            JOIN PaymentProviders pp ON opp.PaymentProviderId = pp.Id
            JOIN ProviderPaymentMethods ppm ON pp.Id = ppm.PaymentProviderId
            WHERE bpp.BranchId = @BranchId 
              AND bpp.IsActive = 1 
              AND pp.IsActive = 1
              AND ppm.IsActive = 1
              AND ppm.PaymentMethod = @PaymentMethod
            ORDER BY opp.Priority ASC";
            
        var code = await connection.QueryFirstOrDefaultAsync<string>(query, new { BranchId = branchId, PaymentMethod = paymentMethod });
        
        // Default fallback if nothing is configured
        return code ?? "STRIPE";
    }
}
