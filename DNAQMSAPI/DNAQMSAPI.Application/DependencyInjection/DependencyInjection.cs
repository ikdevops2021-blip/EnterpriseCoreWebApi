using Microsoft.Extensions.DependencyInjection;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Application.Services;

namespace DNAQMSAPI.Application.DependencyInjection;

public static class DependencyInjection
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddScoped<IApiKeyAuthenticator, ApiKeyAuthenticator>();
        services.AddScoped<IApiKeyService, ApiKeyService>();

        // Register MediatR, FluentValidation, AutoMapper, etc. here
        // services.AddMediatR(cfg => { ... });
        
        return services;
    }
}
