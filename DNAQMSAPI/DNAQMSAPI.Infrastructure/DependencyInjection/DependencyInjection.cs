using DNAQMSAPI.Application.Integration.Interfaces;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Infrastructure.Data;
using DNAQMSAPI.Infrastructure.Integration;
using DNAQMSAPI.Infrastructure.Integration.AuthProviders;
using DNAQMSAPI.Application.Email.Interfaces;
using DNAQMSAPI.Infrastructure.Repositories;
using DNAQMSAPI.Infrastructure.Email;
using DNAQMSAPI.Infrastructure.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace DNAQMSAPI.Infrastructure.DependencyInjection;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<DatabaseSettings>(configuration.GetSection("DatabaseSettings"));
        services.AddScoped<IDapperDBFactory, DapperDBFactory>();
        services.AddScoped<IConfigurationService, ConfigurationService>();
        services.AddScoped<IUserService, UserService>();
        services.AddScoped<IOrganizationService, OrganizationService>();
        services.AddScoped<ILocationAndUserProfileService, LocationAndUserProfileService>();
        services.AddScoped<INotificationService, NotificationService>();
        
        // --- API Key Auth ---
        services.AddScoped<IApiKeyRepository, ApiKeyRepository>();
        
        // --- Phase 7 : Integration Module DI ---
        services.AddHttpClient(); // Registers IHttpClientFactory and raw HttpClient
        services.AddScoped<IAuthProviderFactory, AuthProviderFactory>();
        services.AddScoped<TokenManager>();
        services.AddScoped<IConfigurationResolver, ConfigurationResolver>();
        services.AddScoped<IGenericApiClient, GenericApiClient>();
        services.AddScoped<IIntegrationManagementService, IntegrationManagementService>();
        
        // Concrete Auth Providers
        services.AddScoped<ApiKeyAuthProvider>();
        services.AddScoped<BasicAuthProvider>();
        services.AddScoped<JwtAuthProvider>();
        services.AddScoped<OAuth2AuthProvider>();
        
        // --- Phase 9 : Generic Email Gateway ---
        services.AddScoped<IGenericEmailGateway, GenericEmailGateway>();
        services.AddScoped<IEmailQueueProcessor, EmailQueueProcessor>();
        services.AddScoped<IEmailService, EmailService>();
        services.AddHostedService<EmailQueueBackgroundService>();
        
        // --- Modular Monolith : TaxEngine & SubscriptionSaaS ---
        services.AddScoped<DNAQMSAPI.Application.TaxEngine.Interfaces.ITaxService, DNAQMSAPI.Infrastructure.TaxEngine.Services.TaxService>();
        services.AddScoped<DNAQMSAPI.Application.SubscriptionSaaS.Interfaces.IBillingService, DNAQMSAPI.Infrastructure.SubscriptionSaaS.Services.BillingService>();
        services.AddScoped<DNAQMSAPI.Application.SubscriptionSaaS.Interfaces.ISubscriptionService, DNAQMSAPI.Infrastructure.SubscriptionSaaS.Services.SubscriptionService>();
        services.AddScoped<DNAQMSAPI.Application.SubscriptionSaaS.Interfaces.IUsageMeteringService, DNAQMSAPI.Infrastructure.SubscriptionSaaS.Services.UsageMeteringService>();
        services.AddScoped<DNAQMSAPI.Application.InvoiceGeneration.Interfaces.IInvoiceService, DNAQMSAPI.Infrastructure.InvoiceGeneration.Services.InvoiceService>();
        services.AddScoped<DNAQMSAPI.Application.FinancialReporting.Interfaces.IFinancialReportingService, DNAQMSAPI.Infrastructure.FinancialReporting.Services.FinancialReportingService>();

        // --- DQMS Stage 1, 2 & 3 Services ---
        services.AddScoped<IDqmsAdminService, DqmsAdminService>();
        services.AddScoped<IDqmsStaffService, DqmsStaffService>();
        services.AddScoped<IDqmsCustomerService, DqmsCustomerService>();
        services.AddScoped<IDqmsDashboardService, DqmsDashboardService>();

        return services;
    }
}
