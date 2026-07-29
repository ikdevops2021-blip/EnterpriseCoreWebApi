namespace DNAQMSAPI.Application.Interfaces.Payments;

public interface IPaymentGatewayFactory
{
    IPaymentProvider GetProvider(string providerCode);
}
