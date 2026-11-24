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
    public class SignageService : ISignageService
    {
        private readonly IDapperDBFactory _dbFactory;
        private readonly ILogger<SignageService> _logger;

        public SignageService(IDapperDBFactory dbFactory, ILogger<SignageService> logger)
        {
            _dbFactory = dbFactory;
            _logger = logger;
        }

        public async Task<List<SignageCampaignDto>> GetCampaignsAsync(int organizationId)
        {
            try
            {
                const string sql = @"
                    SELECT 
                        C.Id, C.OrganizationId, C.CampaignName, C.CampaignType, C.Priority,
                        C.StartDate, C.EndDate, C.DailyStartTime, C.DailyEndTime, C.DaysOfWeek,
                        C.IsActive, MAP.LocationId, MAP.AreaId
                    FROM SignageCampaign C
                    LEFT JOIN SignageCampaignMapping MAP ON C.Id = MAP.CampaignId AND MAP.IsActive = 1
                    WHERE C.OrganizationId = @OrganizationId AND C.IsDeleted = 0
                    ORDER BY C.Priority DESC, C.CreatedDate DESC";

                var campaigns = (await _dbFactory.QueryAsync<SignageCampaignDto>(
                    sql, new { OrganizationId = organizationId })).ToList();

                if (campaigns.Any())
                {
                    const string mediaSql = @"
                        SELECT 
                            Id, CampaignId, MediaType, MediaUrl, LocalCachePath,
                            Title, DurationSeconds, DisplayOrder, MuteAudio, IsActive
                        FROM SignageMediaItem
                        WHERE CampaignId IN @CampaignIds AND IsActive = 1
                        ORDER BY DisplayOrder ASC";

                    var campaignIds = campaigns.Select(c => c.Id).Distinct().ToList();
                    var mediaItems = (await _dbFactory.QueryAsync<SignageMediaItemDto>(
                        mediaSql, new { CampaignIds = campaignIds })).ToList();

                    var mediaLookup = mediaItems.GroupBy(m => m.CampaignId).ToDictionary(g => g.Key, g => g.ToList());
                    foreach (var c in campaigns)
                    {
                        if (mediaLookup.TryGetValue(c.Id, out var items))
                        {
                            c.MediaItems = items;
                        }
                    }
                }

                return campaigns;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting signage campaigns for Org: {OrgId}", organizationId);
                return new List<SignageCampaignDto>();
            }
        }

        public async Task<SignageCampaignDto?> GetCampaignByIdAsync(int id, int organizationId)
        {
            try
            {
                const string sql = @"
                    SELECT 
                        C.Id, C.OrganizationId, C.CampaignName, C.CampaignType, C.Priority,
                        C.StartDate, C.EndDate, C.DailyStartTime, C.DailyEndTime, C.DaysOfWeek,
                        C.IsActive, MAP.LocationId, MAP.AreaId
                    FROM SignageCampaign C
                    LEFT JOIN SignageCampaignMapping MAP ON C.Id = MAP.CampaignId AND MAP.IsActive = 1
                    WHERE C.Id = @Id AND C.OrganizationId = @OrganizationId AND C.IsDeleted = 0";

                var campaign = (await _dbFactory.QueryAsync<SignageCampaignDto>(
                    sql, new { Id = id, OrganizationId = organizationId })).FirstOrDefault();

                if (campaign != null)
                {
                    const string mediaSql = @"
                        SELECT 
                            Id, CampaignId, MediaType, MediaUrl, LocalCachePath,
                            Title, DurationSeconds, DisplayOrder, MuteAudio, IsActive
                        FROM SignageMediaItem
                        WHERE CampaignId = @CampaignId AND IsActive = 1
                        ORDER BY DisplayOrder ASC";

                    var mediaItems = (await _dbFactory.QueryAsync<SignageMediaItemDto>(
                        mediaSql, new { CampaignId = id })).ToList();

                    campaign.MediaItems = mediaItems;
                }

                return campaign;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting signage campaign {Id} for Org: {OrgId}", id, organizationId);
                return null;
            }
        }

        public async Task<int> SaveCampaignAsync(SaveSignageCampaignRequestDto request, int userId)
        {
            try
            {
                TimeSpan? dailyStart = null;
                TimeSpan? dailyEnd = null;
                if (!string.IsNullOrWhiteSpace(request.DailyStartTime) && TimeSpan.TryParse(request.DailyStartTime, out var s))
                    dailyStart = s;
                if (!string.IsNullOrWhiteSpace(request.DailyEndTime) && TimeSpan.TryParse(request.DailyEndTime, out var e))
                    dailyEnd = e;

                var parameters = new DynamicParameters();
                parameters.Add("p_Id", request.Id);
                parameters.Add("p_OrganizationId", request.OrganizationId);
                parameters.Add("p_CampaignName", request.CampaignName);
                parameters.Add("p_CampaignType", request.CampaignType);
                parameters.Add("p_Priority", request.Priority);
                parameters.Add("p_StartDate", request.StartDate);
                parameters.Add("p_EndDate", request.EndDate);
                parameters.Add("p_DailyStartTime", dailyStart);
                parameters.Add("p_DailyEndTime", dailyEnd);
                parameters.Add("p_DaysOfWeek", request.DaysOfWeek ?? "1,2,3,4,5,6,7");
                parameters.Add("p_LocationId", request.LocationId ?? 0);
                parameters.Add("p_AreaId", request.AreaId);
                parameters.Add("p_IsActive", request.IsActive ? 1 : 0);
                parameters.Add("p_UserId", userId);

                // Add non-prefixed parameter aliases for DB engine flexibility
                parameters.Add("Id", request.Id);
                parameters.Add("OrganizationId", request.OrganizationId);
                parameters.Add("CampaignName", request.CampaignName);
                parameters.Add("CampaignType", request.CampaignType);
                parameters.Add("Priority", request.Priority);
                parameters.Add("StartDate", request.StartDate);
                parameters.Add("EndDate", request.EndDate);
                parameters.Add("DailyStartTime", dailyStart);
                parameters.Add("DailyEndTime", dailyEnd);
                parameters.Add("DaysOfWeek", request.DaysOfWeek ?? "1,2,3,4,5,6,7");
                parameters.Add("LocationId", request.LocationId ?? 0);
                parameters.Add("AreaId", request.AreaId);
                parameters.Add("IsActive", request.IsActive ? 1 : 0);
                parameters.Add("UserId", userId);

                var campaignId = await _dbFactory.QuerySingleAsync<int>(
                    "PR_IU_SignageCampaign",
                    parameters,
                    commandType: CommandType.StoredProcedure);

                if (campaignId > 0 && request.MediaItems != null && request.MediaItems.Any())
                {
                    await SaveMediaItemsAsync(campaignId, request.MediaItems);
                }

                _logger.LogInformation("Saved SignageCampaign {CampaignId} for Org {OrgId}", campaignId, request.OrganizationId);
                return campaignId;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error saving signage campaign: {Name}", request.CampaignName);
                throw;
            }
        }

        public async Task<bool> DeleteCampaignAsync(int id, int organizationId, int userId)
        {
            try
            {
                const string sql = @"
                    UPDATE SignageCampaign 
                    SET IsDeleted = 1, IsActive = 0, ModifiedBy = @UserId, ModifiedDate = GETDATE()
                    WHERE Id = @Id AND OrganizationId = @OrganizationId";

                var rows = await _dbFactory.ExecuteAsync(sql, new { Id = id, OrganizationId = organizationId, UserId = userId });
                return rows > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting signage campaign {Id}", id);
                return false;
            }
        }

        public async Task<SignagePlaylistResponseDto> GetActivePlaylistAsync(int organizationId, int locationId, int? areaId = null)
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

                var items = (await _dbFactory.QueryAsync<SignageMediaItemDto>(
                    "PR_S_ActiveSignagePlaylist",
                    parameters,
                    commandType: CommandType.StoredProcedure)).ToList();

                return new SignagePlaylistResponseDto
                {
                    OrganizationId = organizationId,
                    LocationId = locationId,
                    AreaId = areaId,
                    Items = items,
                    GeneratedAt = DateTime.UtcNow
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching active playlist for Org: {OrgId}, Loc: {LocId}", organizationId, locationId);
                return new SignagePlaylistResponseDto
                {
                    OrganizationId = organizationId,
                    LocationId = locationId,
                    AreaId = areaId,
                    Items = new List<SignageMediaItemDto>()
                };
            }
        }

        public async Task<bool> SaveMediaItemsAsync(int campaignId, List<SignageMediaItemDto> items)
        {
            try
            {
                const string deleteSql = "DELETE FROM SignageMediaItem WHERE CampaignId = @CampaignId";
                await _dbFactory.ExecuteAsync(deleteSql, new { CampaignId = campaignId });

                const string insertSql = @"
                    INSERT INTO SignageMediaItem (
                        CampaignId, MediaType, MediaUrl, LocalCachePath, Title,
                        DurationSeconds, DisplayOrder, MuteAudio, IsActive, CreatedDate
                    ) VALUES (
                        @CampaignId, @MediaType, @MediaUrl, @LocalCachePath, @Title,
                        @DurationSeconds, @DisplayOrder, @MuteAudio, @IsActive, GETDATE()
                    )";

                int order = 1;
                foreach (var item in items)
                {
                    await _dbFactory.ExecuteAsync(insertSql, new
                    {
                        CampaignId = campaignId,
                        MediaType = item.MediaType,
                        MediaUrl = item.MediaUrl ?? "",
                        LocalCachePath = item.LocalCachePath,
                        Title = item.Title ?? $"Slide {order}",
                        DurationSeconds = item.DurationSeconds > 0 ? item.DurationSeconds : 15,
                        DisplayOrder = order++,
                        MuteAudio = item.MuteAudio ? 1 : 0,
                        IsActive = item.IsActive ? 1 : 0
                    });
                }

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error saving media items for campaign {CampaignId}", campaignId);
                return false;
            }
        }
    }
}
