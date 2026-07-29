using System;
using System.Collections.Generic;
using System.Linq;
using DNAQMSAPI.Application.Interfaces.Payments;

namespace DNAQMSAPI.Payments.Providers;

public class PaymentGatewayFactory : IPaymentGatewayFactory
{
    private readonly IEnumerable<IPaymentProvider> _providers;

    public PaymentGatewayFactory(IEnumerable<IPaymentProvider> providers)
    {
        _providers = providers;
    }

    public IPaymentProvider GetProvider(string providerCode)
    {
        var provider = _providers.FirstOrDefault(p => p.ProviderCode.Equals(providerCode, StringComparison.OrdinalIgnoreCase));
        
        if (provider == null)
        {
            throw new NotSupportedException($"Payment provider {providerCode} is not supported or registered.");
        }

        return provider;
    }
}
