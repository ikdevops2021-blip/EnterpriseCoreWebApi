namespace DNAQMSAPI.Application.Interfaces;

public interface IPaymentGatewayFactory
{
    IPaymentGateway GetGateway(string providerName);
}
