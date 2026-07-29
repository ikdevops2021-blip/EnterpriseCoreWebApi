using System.Threading;
using System.Threading.Tasks;
using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.TaxEngine.DTOs;

namespace DNAQMSAPI.Application.TaxEngine.Interfaces;

public interface ITaxService
{
    Task<ApiResponse<TaxResult>> CalculateTaxAsync(TaxRequest request, CancellationToken cancellationToken = default);
}
