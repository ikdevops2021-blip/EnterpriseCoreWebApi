using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using Dapper;
using DNAQMSAPI.Application.Interfaces;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Infrastructure.Services
{
    public class EmergencyBroadcastService : IEmergencyBroadcastService
    {
        private readonly IDapperDBFactory _dbFactory;
        private readonly ILogger<EmergencyBroadcastService> _logger;

        public EmergencyBroadcastService(IDapperDBFactory dbFactory, ILogger<EmergencyBroadcastService> logger)
        {
            _dbFactory = dbFactory;
            _logger = logger;
        }

        public async Task<EmergencyBroadcastDto?> GetActiveBroadcastAsync(int organizationId, int? locationId = null, int? areaId = null)
        {
            try
            {
                var parameters = new DynamicParameters();
                parameters.Add("p_OrganizationId", organizationId);
                parameters.Add("p_LocationId", locationId);
                parameters.Add("p_AreaId", areaId);

                // Add non-prefixed parameter aliases
                parameters.Add("OrganizationId", organizationId);
                parameters.Add("LocationId", locationId);
                parameters.Add("AreaId", areaId);

                var broadcast = (await _dbFactory.QueryAsync<EmergencyBroadcastDto>(
                    "PR_S_ActiveEmergencyBroadcast",
                    parameters,
                    commandType: CommandType.StoredProcedure)).FirstOrDefault();

                return broadcast;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching active emergency broadcast for Org: {OrgId}", organizationId);
                return null;
            }
        }

        public async Task<int> TriggerBroadcastAsync(TriggerEmergencyBroadcastRequestDto request, int userId)
        {
            try
            {
                var parameters = new DynamicParameters();
                parameters.Add("p_Action", "TRIGGER");
                parameters.Add("p_BroadcastId", 0);
                parameters.Add("p_OrganizationId", request.OrganizationId);
                parameters.Add("p_LocationId", request.LocationId);
                parameters.Add("p_AreaId", request.AreaId);
                parameters.Add("p_BroadcastCode", request.BroadcastCode ?? "CODE_RED");
                parameters.Add("p_Title", request.Title ?? "EMERGENCY ALERT");
                parameters.Add("p_MessageText", request.MessageText ?? "");
                parameters.Add("p_Severity", request.Severity);
                parameters.Add("p_AudioSirenType", request.AudioSirenType);
                parameters.Add("p_FlashColorHex", request.FlashColorHex ?? "#FF1744");
                parameters.Add("p_UserId", userId);

                // Add non-prefixed parameter aliases
                parameters.Add("Action", "TRIGGER");
                parameters.Add("BroadcastId", 0);
                parameters.Add("OrganizationId", request.OrganizationId);
                parameters.Add("LocationId", request.LocationId);
                parameters.Add("AreaId", request.AreaId);
                parameters.Add("BroadcastCode", request.BroadcastCode ?? "CODE_RED");
                parameters.Add("Title", request.Title ?? "EMERGENCY ALERT");
                parameters.Add("MessageText", request.MessageText ?? "");
                parameters.Add("Severity", request.Severity);
                parameters.Add("AudioSirenType", request.AudioSirenType);
                parameters.Add("FlashColorHex", request.FlashColorHex ?? "#FF1744");
                parameters.Add("UserId", userId);

                var broadcastId = await _dbFactory.QuerySingleAsync<int>(
                    "PR_IU_EmergencyBroadcast",
                    parameters,
                    commandType: CommandType.StoredProcedure);

                _logger.LogWarning("EMERGENCY BROADCAST TRIGGERED: {BroadcastCode} '{Title}' for Org {OrgId}, Loc {LocId}. Id={BroadcastId}",
                    request.BroadcastCode, request.Title, request.OrganizationId, request.LocationId, broadcastId);

                return broadcastId;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error triggering emergency broadcast for Org: {OrgId}", request.OrganizationId);
                throw;
            }
        }

        public async Task<bool> DismissBroadcastAsync(DismissEmergencyBroadcastRequestDto request, int userId)
        {
            try
            {
                var parameters = new DynamicParameters();
                parameters.Add("p_Action", "DISMISS");
                parameters.Add("p_BroadcastId", request.BroadcastId);
                parameters.Add("p_OrganizationId", request.OrganizationId);
                parameters.Add("p_LocationId", null);
                parameters.Add("p_AreaId", null);
                parameters.Add("p_BroadcastCode", "");
                parameters.Add("p_Title", "");
                parameters.Add("p_MessageText", "");
                parameters.Add("p_Severity", 1);
                parameters.Add("p_AudioSirenType", 0);
                parameters.Add("p_FlashColorHex", "");
                parameters.Add("p_UserId", userId);

                // Add non-prefixed parameter aliases
                parameters.Add("Action", "DISMISS");
                parameters.Add("BroadcastId", request.BroadcastId);
                parameters.Add("OrganizationId", request.OrganizationId);
                parameters.Add("LocationId", null);
                parameters.Add("AreaId", null);
                parameters.Add("BroadcastCode", "");
                parameters.Add("Title", "");
                parameters.Add("MessageText", "");
                parameters.Add("Severity", 1);
                parameters.Add("AudioSirenType", 0);
                parameters.Add("FlashColorHex", "");
                parameters.Add("UserId", userId);

                await _dbFactory.ExecuteAsync(
                    "PR_IU_EmergencyBroadcast",
                    parameters,
                    commandType: CommandType.StoredProcedure);

                _logger.LogInformation("Emergency broadcast {BroadcastId} dismissed (ALL CLEAR) by user {UserId}",
                    request.BroadcastId, userId);

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error dismissing emergency broadcast {BroadcastId}", request.BroadcastId);
                return false;
            }
        }

        public async Task<List<EmergencyBroadcastDto>> GetBroadcastHistoryAsync(int organizationId, int? locationId = null)
        {
            try
            {
                const string sql = @"
                    SELECT 
                        Id, OrganizationId, LocationId, AreaId, BroadcastCode,
                        Title, MessageText, Severity, AudioSirenType, FlashColorHex,
                        IsActive, TriggeredByUserId, TriggeredAt, DismissedByUserId, DismissedAt
                    FROM EmergencyBroadcast
                    WHERE OrganizationId = @OrganizationId
                      AND (@LocationId IS NULL OR LocationId IS NULL OR LocationId = @LocationId)
                    ORDER BY TriggeredAt DESC";

                var list = (await _dbFactory.QueryAsync<EmergencyBroadcastDto>(
                    sql, new { OrganizationId = organizationId, LocationId = locationId })).ToList();

                return list;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching emergency broadcast history for Org: {OrgId}", organizationId);
                return new List<EmergencyBroadcastDto>();
            }
        }
    }
}
