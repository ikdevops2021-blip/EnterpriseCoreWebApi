using System;
using System.Data;
using System.Threading.Tasks;
using Dapper;
using DNAQMSAPI.Application.Interfaces.Payments;
using DNAQMSAPI.Domain.Entities;
using DNAQMSAPI.Application.Interfaces;

namespace DNAQMSAPI.Payments.Services;

public class PaymentService : IPaymentService
{
    private readonly IDapperDBFactory _dbFactory;

    public PaymentService(IDapperDBFactory dbFactory)
    {
        _dbFactory = dbFactory;
    }

    public async Task<int> CreatePaymentTransactionAsync(PaymentTransaction transaction)
    {
        using var connection = _dbFactory.GetConnection();
        var parameters = new DynamicParameters();
        parameters.Add("@Guid", transaction.Guid);
        parameters.Add("@OrganizationId", transaction.OrganizationId);
        parameters.Add("@BranchId", transaction.BranchId);
        parameters.Add("@PaymentProviderId", transaction.PaymentProviderId);
        parameters.Add("@ExternalTransactionId", transaction.ExternalTransactionId);
        parameters.Add("@Amount", transaction.Amount);
        parameters.Add("@CurrencyId", transaction.CurrencyId);
        parameters.Add("@Status", transaction.Status);
        parameters.Add("@PaymentMethod", transaction.PaymentMethod);
        parameters.Add("@CustomerId", transaction.CustomerId);
        parameters.Add("@Description", transaction.Description);
        parameters.Add("@IdempotencyKey", transaction.IdempotencyKey);
        parameters.Add("@CreatedBy", transaction.CreatedBy);
        
        // Phase 5: UPI & QR Code enhancements
        parameters.Add("@UpiIntentUri", transaction.UpiIntentUri);
        parameters.Add("@QrContent", transaction.QrContent);
        parameters.Add("@QrImage", transaction.QrImage);
        parameters.Add("@ExpiryTime", transaction.ExpiryTime);
        
        parameters.Add("@NewId", dbType: DbType.Int32, direction: ParameterDirection.Output);

        await connection.ExecuteAsync(
            "pr_CreatePaymentTransaction", 
            parameters, 
            commandType: CommandType.StoredProcedure);

        return parameters.Get<int>("@NewId");
    }

    public async Task UpdatePaymentStatusAsync(int transactionId, string newStatus, string reason, string modifiedBy)
    {
        using var connection = _dbFactory.GetConnection();
        var parameters = new DynamicParameters();
        parameters.Add("@TransactionId", transactionId);
        parameters.Add("@NewStatus", newStatus);
        parameters.Add("@Reason", reason);
        parameters.Add("@ModifiedBy", modifiedBy);

        await connection.ExecuteAsync(
            "pr_UpdatePaymentStatus", 
            parameters, 
            commandType: CommandType.StoredProcedure);
    }

    public async Task LogWebhookEventAsync(WebhookLog log)
    {
        using var connection = _dbFactory.GetConnection();
        var parameters = new DynamicParameters();
        parameters.Add("@PaymentProviderId", log.PaymentProviderId);
        parameters.Add("@EventId", log.EventId);
        parameters.Add("@EventType", log.EventType);
        parameters.Add("@Payload", log.Payload);
        parameters.Add("@CreatedBy", log.CreatedBy);

        await connection.ExecuteAsync(
            "pr_LogWebhookEvent", 
            parameters, 
            commandType: CommandType.StoredProcedure);
    }
}
