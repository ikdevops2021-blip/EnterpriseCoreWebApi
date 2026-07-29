using DNAQMSAPI.Application.Interfaces.Payments;
using DNAQMSAPI.Payments.Providers;
using DNAQMSAPI.Payments.Routing;
using DNAQMSAPI.Payments.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace DNAQMSAPI.Payments.DependencyInjection;

public static class DependencyInjection
{
    public static IServiceCollection AddPaymentsServices(this IServiceCollection services, IConfiguration configuration)
    {
        // Register Providers (Strategy implementations)
        services.AddScoped<IPaymentProvider, RazorpayAdapter>();
        services.AddScoped<IPaymentProvider, StripeAdapter>();
        // Add more providers here as needed

        // Register Factory
        services.AddScoped<IPaymentGatewayFactory, PaymentGatewayFactory>();

        // Register Routing Engine
        services.AddScoped<IPaymentRouter, PaymentRouter>();

        // Register Dapper Service
        services.AddScoped<IPaymentService, PaymentService>();

        return services;
    }
}
