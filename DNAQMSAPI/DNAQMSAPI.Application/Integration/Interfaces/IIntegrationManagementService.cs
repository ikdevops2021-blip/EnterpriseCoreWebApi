using DNAQMSAPI.Domain.Integration;

namespace DNAQMSAPI.Application.Integration.Interfaces;

public interface IIntegrationManagementService
{
    // API Integrations CRUD
    Task<ApiIntegration?> GetIntegrationByIdAsync(int integrationId);
    Task<ApiIntegration?> GetIntegrationByProviderAsync(string providerName, int tenantId);
    Task<IEnumerable<ApiIntegration>> GetAllIntegrationsAsync(int tenantId);
    Task<int> SaveIntegrationAsync(ApiIntegration integration);

    // API Endpoints Registry CRUD
    Task<ApiEndpoint?> GetEndpointByIdAsync(int endpointId);
    Task<ApiEndpoint?> GetEndpointByActionAsync(string actionName, int integrationId);
    Task<IEnumerable<ApiEndpoint>> GetEndpointsByIntegrationAsync(int integrationId);
    Task<int> SaveEndpointAsync(ApiEndpoint endpoint);

    // Audit Logging
    Task LogAuditAsync(ApiAuditLog auditLog);
    Task<IEnumerable<ApiAuditLog>> GetAuditLogsAsync(int integrationId, int top = 50);
}
