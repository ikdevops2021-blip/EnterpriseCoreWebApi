using System.Data;
using DNAQMSAPI.Application.Integration.Interfaces;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Integration;
using DNAQMSAPI.Infrastructure.Models;

namespace DNAQMSAPI.Infrastructure.Integration;

public class IntegrationManagementService : IIntegrationManagementService
{
    private readonly IDapperDBFactory _dbFactory;

    public IntegrationManagementService(IDapperDBFactory dbFactory)
    {
        _dbFactory = dbFactory;
    }

    public async Task<ApiIntegration?> GetIntegrationByIdAsync(int integrationId)
    {
        var result = await _dbFactory.QueryAsync<ApiIntegration>(
            "PR_S_APIIntegrations",
            new { p_IntegrationID = integrationId, p_ProviderName = "", p_TenantId = 0 },
            commandType: CommandType.StoredProcedure);

        return result.FirstOrDefault();
    }

    public async Task<ApiIntegration?> GetIntegrationByProviderAsync(string providerName, int tenantId)
    {
        var result = await _dbFactory.QueryAsync<ApiIntegration>(
            "PR_S_APIIntegrations",
            new { p_IntegrationID = 0, p_ProviderName = providerName, p_TenantId = tenantId },
            commandType: CommandType.StoredProcedure);

        return result.FirstOrDefault();
    }

    public async Task<IEnumerable<ApiIntegration>> GetAllIntegrationsAsync(int tenantId)
    {
        return await _dbFactory.QueryAsync<ApiIntegration>(
            "PR_S_APIIntegrations",
            new { p_IntegrationID = 0, p_ProviderName = "", p_TenantId = tenantId },
            commandType: CommandType.StoredProcedure);
    }

    public async Task<int> SaveIntegrationAsync(ApiIntegration integration)
    {
        var result = await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_APIIntegrations",
            new
            {
                p_IntegrationID = integration.IntegrationID,
                p_TenantId = integration.TenantId,
                p_ProviderName = integration.ProviderName,
                p_Description = integration.Description,
                p_BaseUrl = integration.BaseUrl,
                p_Active = integration.Active ? 1 : 0,
                p_AuditLevel = integration.AuditLevel,
                p_AuthType = (int)integration.AuthType,
                p_ApiKey = integration.ApiKey,
                p_ApiUsername = integration.ApiUsername,
                p_ApiPassword = integration.ApiPassword,
                p_TokenUrl = integration.TokenUrl,
                p_ClientID = integration.ClientID,
                p_ClientSecret = integration.ClientSecret,
                p_HMACSecretKey = integration.HMACSecretKey,
                p_HMACHeaderName = integration.HMACHeaderName,
                p_CreatedBy = integration.CreatedBy
            },
            commandType: CommandType.StoredProcedure);

        if (result != null && result.ErrNo == 0 && result.ID != null)
        {
            return Convert.ToInt32(result.ID);
        }

        throw new InvalidOperationException(result?.ErrMsg ?? "Failed to save API Integration.");
    }

    public async Task<ApiEndpoint?> GetEndpointByIdAsync(int endpointId)
    {
        var result = await _dbFactory.QueryAsync<ApiEndpoint>(
            "PR_S_ApiEndpoints",
            new { p_EndpointID = endpointId, p_IntegrationID = 0, p_ActionName = "" },
            commandType: CommandType.StoredProcedure);

        return result.FirstOrDefault();
    }

    public async Task<ApiEndpoint?> GetEndpointByActionAsync(string actionName, int integrationId)
    {
        var result = await _dbFactory.QueryAsync<ApiEndpoint>(
            "PR_S_ApiEndpoints",
            new { p_EndpointID = 0, p_IntegrationID = integrationId, p_ActionName = actionName },
            commandType: CommandType.StoredProcedure);

        return result.FirstOrDefault();
    }

    public async Task<IEnumerable<ApiEndpoint>> GetEndpointsByIntegrationAsync(int integrationId)
    {
        return await _dbFactory.QueryAsync<ApiEndpoint>(
            "PR_S_ApiEndpoints",
            new { p_EndpointID = 0, p_IntegrationID = integrationId, p_ActionName = "" },
            commandType: CommandType.StoredProcedure);
    }

    public async Task<int> SaveEndpointAsync(ApiEndpoint endpoint)
    {
        var result = await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_ApiEndpoints",
            new
            {
                p_EndpointID = endpoint.EndpointID,
                p_IntegrationID = endpoint.IntegrationID,
                p_ActionName = endpoint.ActionName,
                p_RelativePath = endpoint.RelativePath,
                p_HttpMethod = endpoint.HttpMethod,
                p_Description = endpoint.Description,
                p_Active = endpoint.Active ? 1 : 0,
                p_SampleAPIRequest = endpoint.SampleAPIRequest,
                p_SampleAPIResponse = endpoint.SampleAPIResponse,
                p_CreatedBy = endpoint.CreatedBy
            },
            commandType: CommandType.StoredProcedure);

        if (result != null && result.ErrNo == 0 && result.ID != null)
        {
            return Convert.ToInt32(result.ID);
        }

        throw new InvalidOperationException(result?.ErrMsg ?? "Failed to save API Endpoint.");
    }

    public async Task LogAuditAsync(ApiAuditLog auditLog)
    {
        await _dbFactory.ExecuteAsync(
            "PR_I_APIAuditLogs",
            new
            {
                p_IntegrationID = auditLog.IntegrationID,
                p_ActionName = auditLog.ActionName,
                p_RequestUrl = auditLog.RequestUrl,
                p_HttpMethod = auditLog.HttpMethod,
                p_RequestBody = auditLog.RequestBody,
                p_ResponseBody = auditLog.ResponseBody,
                p_StatusCode = auditLog.StatusCode,
                p_DurationMs = auditLog.DurationMs,
                p_ErrorMessage = auditLog.ErrorMessage,
                p_CreatedBy = auditLog.CreatedBy ?? 0
            },
            commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<ApiAuditLog>> GetAuditLogsAsync(int integrationId, int top = 50)
    {
        const string sql = @"
            SELECT AuditID, IntegrationID, ActionName, RequestUrl, HttpMethod, RequestBody, ResponseBody, StatusCode, DurationMs, ErrorMessage, CreatedBy, CreatedDate
            FROM APIAuditLogs
            WHERE (@IntegrationId = 0 OR IntegrationID = @IntegrationId)
            ORDER BY CreatedDate DESC
            LIMIT @Top";

        return await _dbFactory.QueryAsync<ApiAuditLog>(sql, new { IntegrationId = integrationId, Top = top });
    }
}
