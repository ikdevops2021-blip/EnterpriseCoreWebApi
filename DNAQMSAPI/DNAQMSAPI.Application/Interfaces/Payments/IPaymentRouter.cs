using System.Threading.Tasks;

namespace DNAQMSAPI.Application.Interfaces.Payments;

public interface IPaymentRouter
{
    Task<string> GetPreferredProviderCodeAsync(int organizationId, int branchId, string paymentMethod);
}
