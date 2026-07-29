using System.Data;
using AntiGravity.Enterprise.Shared.Core.Data;
using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Entities;
using DNAQMSAPI.Infrastructure.Models;

namespace DNAQMSAPI.Infrastructure.Services;

public class OrganizationService : IOrganizationService
{
    private readonly DNAQMSAPI.Application.Interfaces.IDapperDBFactory _dbFactory;

    public OrganizationService(DNAQMSAPI.Application.Interfaces.IDapperDBFactory dbFactory)
    {
        _dbFactory = dbFactory;
    }

    public async Task<ApiResponse<IEnumerable<Organization>>> GetAllOrganizationsAsync()
    {
        var organizations = await _dbFactory.QueryAsync<Organization>(
            "PR_S_Organization",
            new { p_Id = -1, p_RegistrationKey = "", p_ParentOrganizationId = -1, p_IsActive = 1 },
            commandType: CommandType.StoredProcedure);

        return ApiResponse<IEnumerable<Organization>>.Ok(organizations.Where(o => o != null).Select(o => o!).ToList());
    }

    public async Task<ApiResponse<Organization>> GetOrganizationByIdAsync(Guid organizationId)
    {
        var organization = await GetOrganizationByRegistrationKeyAsync(organizationId);
        return organization == null
            ? ApiResponse<Organization>.Fail("Organization not found.")
            : ApiResponse<Organization>.Ok(organization);
    }

    public async Task<IEnumerable<Organization>> GetChildOrganizationsAsync(Guid parentOrganizationId)
    {
        var parent = await GetOrganizationByRegistrationKeyAsync(parentOrganizationId);
        if (parent == null)
        {
            return Array.Empty<Organization>();
        }

        var organizations = await _dbFactory.QueryAsync<Organization>(
            "PR_S_Organization",
            new { p_Id = -1, p_RegistrationKey = "", p_ParentOrganizationId = parent.Id, p_IsActive = 1 },
            commandType: CommandType.StoredProcedure);

        return organizations.Where(o => o != null).Select(o => o!).ToList();
    }

    public async Task<Organization> CreateOrganizationAsync(Organization organization)
    {
        var regKey = organization.RegistrationKey == Guid.Empty ? Guid.NewGuid().ToString() : organization.RegistrationKey.ToString();

        var parameters = new
        {
            p_Id = 0,
            p_RegistrationKey = regKey,
            p_Name = organization.Name,
            p_ParentOrganizationId = organization.ParentOrganizationId,
            p_Priority = 1,
            p_IsActive = organization.IsActive,
            p_UID = organization.CreatedBy
        };

        var result = await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_Organization",
            parameters,
            commandType: CommandType.StoredProcedure);

        var createdId = Convert.ToInt32(result?.ID ?? 0);
        if (createdId > 0)
        {
            var orgs = await _dbFactory.QueryAsync<Organization>(
                "PR_S_Organization",
                new { p_Id = createdId, p_RegistrationKey = "", p_ParentOrganizationId = -1, p_IsActive = -1 },
                commandType: CommandType.StoredProcedure);

            return orgs.First();
        }

        throw new InvalidOperationException(result?.ErrMsg ?? "Failed to create Organization.");
    }

    public async Task<bool> UpdateOrganizationAsync(Organization organization)
    {
        var parameters = new
        {
            p_Id = organization.Id,
            p_RegistrationKey = organization.RegistrationKey.ToString(),
            p_Name = organization.Name,
            p_ParentOrganizationId = organization.ParentOrganizationId,
            p_Priority = 1,
            p_IsActive = organization.IsActive,
            p_UID = organization.ModifiedBy
        };

        var result = await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_Organization",
            parameters,
            commandType: CommandType.StoredProcedure);

        return result != null && result.ErrNo == 0 && result.RowsCount > 0;
    }

    private async Task<Organization?> GetOrganizationByRegistrationKeyAsync(Guid registrationKey)
    {
        var organizations = await _dbFactory.QueryAsync<Organization>(
            "PR_S_Organization",
            new { p_Id = -1, p_RegistrationKey = registrationKey.ToString(), p_ParentOrganizationId = -1, p_IsActive = -1 },
            commandType: CommandType.StoredProcedure);

        return organizations.FirstOrDefault();
    }
}
