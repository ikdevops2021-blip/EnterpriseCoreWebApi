using System.Data;
using AntiGravity.Enterprise.Shared.Core.Data;
using AntiGravity.Enterprise.Shared.Core.Enums;
using AntiGravity.Enterprise.Shared.Core.Models.DQMS;
using Dapper;

namespace DNAQMSAPI.Infrastructure.Repositories
{
    public interface IDqmsAdminRepository
    {
        Task<IEnumerable<AreaModel>> GetAreasAsync(int? id, int? organizationId, int? locationId, e_ActiveSearchStatus isActive);
        Task<(int Id, int ErrNo, string ErrMsg)> SaveAreaAsync(AreaModel model, int userId);
        Task<IEnumerable<ProcessModel>> GetProcessesAsync(int? id, int? organizationId, e_ActiveSearchStatus isActive);
        Task<(int Id, int ErrNo, string ErrMsg)> SaveProcessAsync(ProcessModel model, int userId);
    }

    public class DqmsAdminRepository : IDqmsAdminRepository
    {
        private readonly IDapperDBFactory _dbFactory;

        public DqmsAdminRepository(IDapperDBFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<IEnumerable<AreaModel>> GetAreasAsync(int? id, int? organizationId, int? locationId, e_ActiveSearchStatus isActive)
        {
            var parameters = new DynamicParameters();
            parameters.Add("p_Id", id ?? -1);
            parameters.Add("p_OrganizationId", organizationId ?? -1);
            parameters.Add("p_LocationId", locationId ?? -1);
            parameters.Add("p_IsActive", (int)isActive);

            var result = await _dbFactory.QueryAsync<AreaModel>(
                "PR_S_Area",
                parameters,
                commandType: CommandType.StoredProcedure
            );

            return result.Where(r => r != null)!;
        }

        public async Task<(int Id, int ErrNo, string ErrMsg)> SaveAreaAsync(AreaModel model, int userId)
        {
            var parameters = new DynamicParameters();
            parameters.Add("p_Id", model.Id);
            parameters.Add("p_AreaCode", model.AreaCode);
            parameters.Add("p_OrganizationId", model.OrganizationId);
            parameters.Add("p_LocationId", model.LocationId);
            parameters.Add("p_AreaName", model.AreaName);
            parameters.Add("p_Description", model.Description);
            parameters.Add("p_IsActive", model.IsActive ? 1 : 0);
            parameters.Add("p_UID", userId);

            var response = await _dbFactory.QuerySingleAsync<dynamic>(
                "PR_IU_Area",
                parameters,
                commandType: CommandType.StoredProcedure
            );

            if (response != null)
            {
                var dict = (IDictionary<string, object>)response;
                int id = dict.ContainsKey("ID") ? Convert.ToInt32(dict["ID"]) : 0;
                int errNo = dict.ContainsKey("ErrNo") ? Convert.ToInt32(dict["ErrNo"]) : 0;
                string errMsg = dict.ContainsKey("ErrMsg") ? Convert.ToString(dict["ErrMsg"]) ?? "" : "";
                return (id, errNo, errMsg);
            }

            return (0, 999, "Failed to execute PR_IU_Area");
        }

        public async Task<IEnumerable<ProcessModel>> GetProcessesAsync(int? id, int? organizationId, e_ActiveSearchStatus isActive)
        {
            var parameters = new DynamicParameters();
            parameters.Add("p_Id", id ?? -1);
            parameters.Add("p_OrganizationId", organizationId ?? -1);
            parameters.Add("p_IsActive", (int)isActive);

            var result = await _dbFactory.QueryAsync<ProcessModel>(
                "PR_S_Process",
                parameters,
                commandType: CommandType.StoredProcedure
            );

            return result.Where(r => r != null)!;
        }

        public async Task<(int Id, int ErrNo, string ErrMsg)> SaveProcessAsync(ProcessModel model, int userId)
        {
            var parameters = new DynamicParameters();
            parameters.Add("p_Id", model.Id);
            parameters.Add("p_ProcessCode", model.ProcessCode);
            parameters.Add("p_OrganizationId", model.OrganizationId);
            parameters.Add("p_ProcessName", model.ProcessName);
            parameters.Add("p_Prefix", model.Prefix);
            parameters.Add("p_TargetTATMinutes", model.TargetTATMinutes);
            parameters.Add("p_AllowSubTokens", model.AllowSubTokens ? 1 : 0);
            parameters.Add("p_IsActive", model.IsActive ? 1 : 0);
            parameters.Add("p_UID", userId);

            var response = await _dbFactory.QuerySingleAsync<dynamic>(
                "PR_IU_Process",
                parameters,
                commandType: CommandType.StoredProcedure
            );

            if (response != null)
            {
                var dict = (IDictionary<string, object>)response;
                int id = dict.ContainsKey("ID") ? Convert.ToInt32(dict["ID"]) : 0;
                int errNo = dict.ContainsKey("ErrNo") ? Convert.ToInt32(dict["ErrNo"]) : 0;
                string errMsg = dict.ContainsKey("ErrMsg") ? Convert.ToString(dict["ErrMsg"]) ?? "" : "";
                return (id, errNo, errMsg);
            }

            return (0, 999, "Failed to execute PR_IU_Process");
        }
    }
}
