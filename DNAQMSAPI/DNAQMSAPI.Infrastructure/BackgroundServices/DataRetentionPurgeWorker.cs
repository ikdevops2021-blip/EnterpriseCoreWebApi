using System;
using System.Threading;
using System.Threading.Tasks;
using Dapper;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Application.Services;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Infrastructure.BackgroundServices;

public class DataRetentionPurgeWorker : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<DataRetentionPurgeWorker> _logger;
    private readonly TimeSpan _checkInterval = TimeSpan.FromHours(12);

    public DataRetentionPurgeWorker(
        IServiceProvider serviceProvider,
        ILogger<DataRetentionPurgeWorker> logger)
    {
        _serviceProvider = serviceProvider ?? throw new ArgumentNullException(nameof(serviceProvider));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Data Retention Purge Background Worker started. Interval: {Interval}", _checkInterval);

        // Initial delay on startup
        await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _serviceProvider.CreateScope();
                var privacyService = scope.ServiceProvider.GetRequiredService<IDataPrivacyService>();
                var dbFactory = scope.ServiceProvider.GetRequiredService<IDapperDBFactory>();

                // Query all configured organizations for residency
                using var conn = dbFactory.GetConnection();
                var orgIds = await conn.QueryAsync<int>("SELECT OrganizationId FROM dbo.OrganizationDataResidency");

                foreach (var orgId in orgIds)
                {
                    if (stoppingToken.IsCancellationRequested) break;

                    try
                    {
                        var result = await privacyService.RunRetentionPurgeAsync(orgId);
                        if (result.PurgedRecordsCount > 0)
                        {
                            _logger.LogInformation("Purged {Count} expired records for Organization {OrgId}", result.PurgedRecordsCount, orgId);
                        }
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed retention purge for Organization {OrgId}", orgId);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error in DataRetentionPurgeWorker execution cycle");
            }

            try
            {
                await Task.Delay(_checkInterval, stoppingToken);
            }
            catch (OperationCanceledException)
            {
                break;
            }
        }

        _logger.LogInformation("Data Retention Purge Background Worker stopped.");
    }
}
