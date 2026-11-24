using System.Collections.Generic;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;

namespace DNAQMSAPI.Application.Interfaces
{
    public interface IEdgeSyncService
    {
        Task<int> RegisterOrUpdateNodeAsync(RegisterEdgeNodeRequestDto request, int userId = 1);
        Task<IEnumerable<EdgeNodeRegistrationDto>> GetNodesAsync(int organizationId = -1, int locationId = -1, string? nodeId = null);
        Task<EdgeHeartbeatResponseDto> ProcessHeartbeatAsync(EdgeHeartbeatRequestDto request);
        Task<EdgeSyncResultDto> ProcessSyncBatchAsync(EdgeSyncBatchDto batch, int userId = 1);
        Task<IEnumerable<EdgeSyncAuditLogDto>> GetSyncAuditLogsAsync(int organizationId = -1, string? nodeId = null, int limit = 50);
    }
}
