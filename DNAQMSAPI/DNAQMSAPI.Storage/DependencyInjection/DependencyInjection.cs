using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Storage.Providers;
using DNAQMSAPI.Storage.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace DNAQMSAPI.Storage.DependencyInjection;

public static class DependencyInjection
{
    public static IServiceCollection AddStorageServices(this IServiceCollection services, IConfiguration configuration)
    {
        // Register Providers (Strategy implementations)
        services.AddScoped<IFileProvider, GoogleDriveProvider>();
        services.AddScoped<IFileProvider, AwsS3Provider>();
        services.AddScoped<IFileProvider, AzureBlobProvider>();
        services.AddScoped<IFileProvider, LocalStorageProvider>();

        // Register Factory
        services.AddScoped<IFileProviderFactory, FileProviderFactory>();

        // Register Core Service
        services.AddScoped<IFileStorageService, FileStorageService>();

        return services;
    }
}
