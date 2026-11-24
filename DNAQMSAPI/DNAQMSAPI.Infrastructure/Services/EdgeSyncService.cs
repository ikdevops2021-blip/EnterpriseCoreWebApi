using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using Dapper;
using DNAQMSAPI.Application.Interfaces;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Infrastructure.Services
{
    public class EdgeSyncService : IEdgeSyncService
    {
        private readonly IDapperDBFactory _dbFactory;
        private readonly ILogger<EdgeSyncService> _logger;

        public EdgeSyncService(IDapperDBFactory dbFactory, ILogger<EdgeSyncService> logger)
        {
            _dbFactory = dbFactory;
            _logger = logger;
        }

        public async Task<int> RegisterOrUpdateNodeAsync(RegisterEdgeNodeRequestDto request, int userId = 1)
        {
            try
            {
                var parameters = new DynamicParameters();
                parameters.Add("Id", request.Id);
                parameters.Add("NodeId", request.NodeId);
                parameters.Add("NodeName", request.NodeName);
                parameters.Add("OrganizationId", request.OrganizationId);
                parameters.Add("LocationId", request.LocationId);
                parameters.Add("MacAddress", request.MacAddress);
                parameters.Add("IpAddress", request.IpAddress);
                parameters.Add("SecretKeyHash", string.IsNullOrWhiteSpace(request.SecretKey) ? "" : request.SecretKey);
                parameters.Add("SoftwareVersion", request.SoftwareVersion ?? "1.0.0");
                parameters.Add("IsActive", request.IsActive ? 1 : 0);
                parameters.Add("UserId", userId);

                // Check stored proc name (supports both standard and p_ prefixes)
                parameters.Add("p_Id", request.Id);
                parameters.Add("p_NodeId", request.NodeId);
                parameters.Add("p_NodeName", request.NodeName);
                parameters.Add("p_OrganizationId", request.OrganizationId);
                parameters.Add("p_LocationId", request.LocationId);
                parameters.Add("p_MacAddress", request.MacAddress);
                parameters.Add("p_IpAddress", request.IpAddress);
                parameters.Add("p_SecretKeyHash", string.IsNullOrWhiteSpace(request.SecretKey) ? "" : request.SecretKey);
                parameters.Add("p_SoftwareVersion", request.SoftwareVersion ?? "1.0.0");
                parameters.Add("p_IsActive", request.IsActive ? 1 : 0);
                parameters.Add("p_UserId", userId);

                var newId = await _dbFactory.QuerySingleAsync<int>(
                    "PR_IU_EdgeNodeRegistration",
                    parameters,
                    commandType: CommandType.StoredProcedure);

                _logger.LogInformation("Edge Node registered/updated: {NodeId} with Id: {Id}", request.NodeId, newId);
                return newId;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to register Edge Node: {NodeId}", request.NodeId);
                throw;
            }
        }

        public async Task<IEnumerable<EdgeNodeRegistrationDto>> GetNodesAsync(int organizationId = -1, int locationId = -1, string? nodeId = null)
        {
            try
            {
                var parameters = new DynamicParameters();
                parameters.Add("OrganizationId", organizationId);
                parameters.Add("LocationId", locationId);
                parameters.Add("NodeId", nodeId);

                parameters.Add("p_OrganizationId", organizationId);
                parameters.Add("p_LocationId", locationId);
                parameters.Add("p_NodeId", nodeId);

                var nodes = await _dbFactory.QueryAsync<EdgeNodeRegistrationDto>(
                    "PR_S_EdgeNodes",
                    parameters,
                    commandType: CommandType.StoredProcedure);

                return nodes ?? Enumerable.Empty<EdgeNodeRegistrationDto>();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to query Edge Nodes for Org: {OrgId}", organizationId);
                return Enumerable.Empty<EdgeNodeRegistrationDto>();
            }
        }

        public async Task<EdgeHeartbeatResponseDto> ProcessHeartbeatAsync(EdgeHeartbeatRequestDto request)
        {
            try
            {
                var sql = @"
                    UPDATE EdgeNodeRegistration
                    SET LastHeartbeatAt = GETUTCDATE(),
                        PendingJournalCount = @PendingJournalCount,
                        IpAddress = ISNULL(@IpAddress, IpAddress),
                        SoftwareVersion = ISNULL(@SoftwareVersion, SoftwareVersion)
                    WHERE NodeId = @NodeId;";

                var parameters = new DynamicParameters();
                parameters.Add("NodeId", request.NodeId);
                parameters.Add("PendingJournalCount", request.PendingJournalCount);
                parameters.Add("IpAddress", request.IpAddress);
                parameters.Add("SoftwareVersion", request.SoftwareVersion);

                await _dbFactory.ExecuteAsync(sql, parameters, commandType: CommandType.Text);

                return new EdgeHeartbeatResponseDto
                {
                    IsAcknowledged = true,
                    NodeId = request.NodeId,
                    ServerUtcTime = DateTime.UtcNow,
                    ConfigurationInvalidated = false,
                    Message = "Heartbeat acknowledged successfully"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing heartbeat for Node: {NodeId}", request.NodeId);
                return new EdgeHeartbeatResponseDto
                {
                    IsAcknowledged = false,
                    NodeId = request.NodeId,
                    ServerUtcTime = DateTime.UtcNow,
                    Message = ex.Message
                };
            }
        }

        public async Task<EdgeSyncResultDto> ProcessSyncBatchAsync(EdgeSyncBatchDto batch, int userId = 1)
        {
            var startTime = DateTime.UtcNow;
            try
            {
                var jsonOptions = new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                };
                var payloadJson = JsonSerializer.Serialize(batch.Items, jsonOptions);

                var parameters = new DynamicParameters();
                parameters.Add("BatchId", batch.BatchId);
                parameters.Add("NodeId", batch.NodeId);
                parameters.Add("OrganizationId", batch.OrganizationId);
                parameters.Add("LocationId", batch.LocationId);
                parameters.Add("PayloadJson", payloadJson);
                parameters.Add("UserId", userId);

                parameters.Add("p_BatchId", batch.BatchId);
                parameters.Add("p_NodeId", batch.NodeId);
                parameters.Add("p_OrganizationId", batch.OrganizationId);
                parameters.Add("p_LocationId", batch.LocationId);
                parameters.Add("p_PayloadJson", payloadJson);
                parameters.Add("p_UserId", userId);

                var result = await _dbFactory.QuerySingleAsync<EdgeSyncResultDto>(
                    "PR_IU_ProcessEdgeSyncBatch",
                    parameters,
                    commandType: CommandType.StoredProcedure);

                _logger.LogInformation("Reconciled Edge batch {BatchId} from {NodeId}: {Ingested} ingested, {Conflicts} conflicts resolved in {Ms}ms",
                    batch.BatchId, batch.NodeId, result?.RecordsIngested ?? 0, result?.ConflictsResolved ?? 0, result?.DurationMs ?? 0);

                return result ?? new EdgeSyncResultDto
                {
                    BatchId = batch.BatchId,
                    Status = "Success"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error executing PR_IU_ProcessEdgeSyncBatch for {BatchId} from {NodeId}", batch.BatchId, batch.NodeId);
                return new EdgeSyncResultDto
                {
                    BatchId = batch.BatchId,
                    Status = "Failed",
                    ErrorMessage = ex.Message,
                    DurationMs = (int)(DateTime.UtcNow - startTime).TotalMilliseconds
                };
            }
        }

        public async Task<IEnumerable<EdgeSyncAuditLogDto>> GetSyncAuditLogsAsync(int organizationId = -1, string? nodeId = null, int limit = 50)
        {
            try
            {
                var sql = @"
                    SELECT TOP (@Limit)
                        Id, BatchId, NodeId, OrganizationId, LocationId,
                        RecordsCount, ConflictsResolved, DurationMs, Status, ErrorMessage, CreatedDate
                    FROM EdgeSyncAuditLog
                    WHERE (@OrganizationId = -1 OR OrganizationId = @OrganizationId)
                      AND (@NodeId IS NULL OR NodeId = @NodeId)
                    ORDER BY CreatedDate DESC;";

                var parameters = new DynamicParameters();
                parameters.Add("OrganizationId", organizationId);
                parameters.Add("NodeId", nodeId);
                parameters.Add("Limit", limit);

                var logs = await _dbFactory.QueryAsync<EdgeSyncAuditLogDto>(sql, parameters, commandType: CommandType.Text);
                return logs ?? Enumerable.Empty<EdgeSyncAuditLogDto>();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to retrieve Edge sync audit logs for Org: {OrgId}", organizationId);
                return Enumerable.Empty<EdgeSyncAuditLogDto>();
            }
        }
    }
}
