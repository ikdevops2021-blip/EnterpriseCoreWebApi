using System.Data;
using AntiGravity.Enterprise.Shared.Core.Models;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using DNAQMSAPI.Application.Interfaces;

namespace DNAQMSAPI.Infrastructure.Services
{
    public interface IDqmsCustomerService
    {
        Task<ApiResponse<IEnumerable<DisplayBoardItemModel>>> GetPublicDisplayBoardAsync(int organizationId, int locationId, int? areaId);
        Task<ApiResponse<PublicTokenStatusModel>> GetPublicTokenStatusAsync(int tokenId);
    }

    public class DqmsCustomerService : IDqmsCustomerService
    {
        private readonly DNAQMSAPI.Application.Interfaces.IDapperDBFactory _dbFactory;

        public DqmsCustomerService(DNAQMSAPI.Application.Interfaces.IDapperDBFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<ApiResponse<IEnumerable<DisplayBoardItemModel>>> GetPublicDisplayBoardAsync(int organizationId, int locationId, int? areaId)
        {
            try
            {
                var parameters = new
                {
                    p_OrganizationId = organizationId,
                    p_LocationId = locationId,
                    p_AreaId = areaId ?? -1
                };

                var items = await _dbFactory.QueryAsync<DisplayBoardItemModel>(
                    "PR_S_PublicDisplayBoard",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                return ApiResponse<IEnumerable<DisplayBoardItemModel>>.Ok(items.Where(i => i != null).Select(i => i!).ToList());
            }
            catch (Exception ex)
            {
                return ApiResponse<IEnumerable<DisplayBoardItemModel>>.Ok(Enumerable.Empty<DisplayBoardItemModel>(), $"Display notice ({ex.Message})");
            }
        }

        public async Task<ApiResponse<PublicTokenStatusModel>> GetPublicTokenStatusAsync(int tokenId)
        {
            try
            {
                var parameters = new { p_TokenId = tokenId };

                var status = await _dbFactory.QuerySingleAsync<PublicTokenStatusModel>(
                    "PR_S_PublicTokenStatus",
                    parameters,
                    commandType: CommandType.StoredProcedure
                );

                if (status != null)
                {
                    return ApiResponse<PublicTokenStatusModel>.Ok(status);
                }

                return ApiResponse<PublicTokenStatusModel>.Fail("Token not found or already completed.");
            }
            catch (Exception ex)
            {
                return ApiResponse<PublicTokenStatusModel>.Fail($"Status notice ({ex.Message})");
            }
        }
    }
}
