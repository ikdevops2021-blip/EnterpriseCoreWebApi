using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Domain.Entities;

namespace DNAQMSAPI.Application.Interfaces;

public interface IOrganizationService
{
    Task<ApiResponse<IEnumerable<Organization>>> GetAllOrganizationsAsync();
    Task<ApiResponse<Organization>> GetOrganizationByIdAsync(Guid organizationId);
    Task<IEnumerable<Organization>> GetChildOrganizationsAsync(Guid parentOrganizationId);
    Task<Organization> CreateOrganizationAsync(Organization organization);
    Task<bool> UpdateOrganizationAsync(Organization organization);
}
