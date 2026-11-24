using System.Collections.Generic;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;

namespace DNAQMSAPI.Application.Interfaces
{
    public interface ISignageService
    {
        Task<List<SignageCampaignDto>> GetCampaignsAsync(int organizationId);
        Task<SignageCampaignDto?> GetCampaignByIdAsync(int id, int organizationId);
        Task<int> SaveCampaignAsync(SaveSignageCampaignRequestDto request, int userId);
        Task<bool> DeleteCampaignAsync(int id, int organizationId, int userId);
        Task<SignagePlaylistResponseDto> GetActivePlaylistAsync(int organizationId, int locationId, int? areaId = null);
        Task<bool> SaveMediaItemsAsync(int campaignId, List<SignageMediaItemDto> items);
    }
}
