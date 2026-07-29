using DNAQMSAPI.Api.Extensions;
using DNAQMSAPI.Application.DependencyInjection;
using DNAQMSAPI.Infrastructure.DependencyInjection;
using DNAQMSAPI.Payments.DependencyInjection;
using DNAQMSAPI.Security.DependencyInjection;
using DNAQMSAPI.Security.Middlewares;
using DNAQMSAPI.Shared.Middlewares;
using DNAQMSAPI.Storage.DependencyInjection;
using Microsoft.AspNetCore.RateLimiting;
using NLog;
using NLog.Web;

var logger = NLog.LogManager.Setup().LoadConfigurationFromAppSettings().GetCurrentClassLogger();
logger.Debug("init main");

try
{
    var builder = WebApplication.CreateBuilder(args);

    // Setup NLog Database Connection dynamically from DatabaseSettings by name
    if (NLog.LogManager.Configuration != null)
    {
        var dbSettings = builder.Configuration.GetSection("DatabaseSettings").Get<DNAQMSAPI.Infrastructure.Data.DatabaseSettings>();
        var defaultConn = dbSettings?.Databases?.FirstOrDefault(d => d.Name == dbSettings.DefaultConnectionName);
        if (defaultConn != null)
        {
            NLog.LogManager.Configuration.Variables["DefaultConnectionString"] = defaultConn.ConnectionString;
            NLog.LogManager.Configuration.Variables["DefaultDbProvider"] = defaultConn.Type.ToLower() switch
            {
                "sqlserver" => "Microsoft.Data.SqlClient.SqlConnection, Microsoft.Data.SqlClient",
                "mysql" => "MySql.Data.MySqlClient.MySqlConnection, MySql.Data",
                "sqlite" => "Microsoft.Data.Sqlite.SqliteConnection, Microsoft.Data.Sqlite",
                "oracle" => "Oracle.ManagedDataAccess.Client.OracleConnection, Oracle.ManagedDataAccess",
                _ => "Microsoft.Data.SqlClient.SqlConnection, Microsoft.Data.SqlClient"
            };

            NLog.LogManager.Configuration.Variables["DefaultLogCommand"] = defaultConn.Type.ToLower() switch
            {
                "mysql" => "INSERT INTO AppLogs (MachineName, Logged, Level, Message, Logger, Callsite, Exception, VerboseInfo, Url, Action) VALUES (@MachineName, @Logged, @Level, @Message, @Logger, @Callsite, @Exception, @VerboseInfo, @Url, @Action);",
                _ => "INSERT INTO dbo.AppLogs (MachineName, Logged, Level, Message, Logger, Callsite, Exception, VerboseInfo, Url, Action) VALUES (@MachineName, @Logged, @Level, @Message, @Logger, @Callsite, @Exception, @VerboseInfo, @Url, @Action);"
            };

            NLog.LogManager.ReconfigExistingLoggers();
        }
    }

    // Setup NLog
    builder.Logging.ClearProviders();
    builder.Host.UseNLog();

    // Setup the Enterprise Layers via their respective DI registries
    builder.Services.AddApplicationServices();
    builder.Services.AddInfrastructureServices(builder.Configuration);
    builder.Services.AddSecurityServices(builder.Configuration);
    builder.Services.AddPaymentsServices(builder.Configuration);
    builder.Services.AddStorageServices(builder.Configuration);

    // Add API Controllers, Versioning and Swagger
    builder.Services.AddControllers();
    builder.Services.AddHealthChecks();

    builder.Services.AddRateLimiter(options =>
    {
        options.AddFixedWindowLimiter("GlobalPolicy", opt =>
        {
            opt.Window = TimeSpan.FromMinutes(1);
            opt.PermitLimit = 100;
            opt.QueueProcessingOrder = System.Threading.RateLimiting.QueueProcessingOrder.OldestFirst;
            opt.QueueLimit = 2;
        });
        options.RejectionStatusCode = 429;
    });
    
    builder.Services.AddApiVersioning(options =>
    {
        options.DefaultApiVersion = new Asp.Versioning.ApiVersion(1, 0);
        options.AssumeDefaultVersionWhenUnspecified = true;
        options.ReportApiVersions = true;
        options.ApiVersionReader = new Asp.Versioning.UrlSegmentApiVersionReader();
    }).AddApiExplorer(options =>
    {
        options.GroupNameFormat = "'v'VVV";
        options.SubstituteApiVersionInUrl = true;
    });

    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerDocumentation();

    var app = builder.Build();

    // Use Global Exception handler
    app.UseMiddleware<GlobalExceptionMiddleware>();

    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI();
    }

    app.UseHttpsRedirection();
    app.UseAuthentication();
    app.UseAuthorization();

    // Use Custom Middlewares
    app.UseMiddleware<RequestContextMiddleware>();
    app.UseMiddleware<ZeroTrustValidationMiddleware>();
    app.UseRateLimiter();

    app.MapControllers().RequireRateLimiting("GlobalPolicy");

    app.MapHealthChecks("/health");
    app.Run();
}
catch (Exception exception)
{
    logger.Error(exception, "Stopped program because of exception");
    throw;
}
finally
{
    NLog.LogManager.Shutdown();
}
