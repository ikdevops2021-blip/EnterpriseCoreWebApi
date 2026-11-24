using System.Collections.Generic;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;

namespace DNAQMSAPI.Application.Interfaces
{
    public interface IEmergencyBroadcastService
    {
        Task<EmergencyBroadcastDto?> GetActiveBroadcastAsync(int organizationId, int? locationId = null, int? areaId = null);
        Task<int> TriggerBroadcastAsync(TriggerEmergencyBroadcastRequestDto request, int userId);
        Task<bool> DismissBroadcastAsync(DismissEmergencyBroadcastRequestDto request, int userId);
        Task<List<EmergencyBroadcastDto>> GetBroadcastHistoryAsync(int organizationId, int? locationId = null);
    }
}
