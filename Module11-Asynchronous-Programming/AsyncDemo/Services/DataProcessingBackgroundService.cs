using Microsoft.Extensions.DependencyInjection;
using AsyncDemo.Data;

namespace AsyncDemo.Services;

/// <summary>
/// Background service for processing data periodically
/// </summary>
public class DataProcessingBackgroundService : BackgroundService
{
    private readonly ILogger<DataProcessingBackgroundService> _logger;
    private readonly IServiceProvider _serviceProvider;
    private readonly TimeSpan _period = TimeSpan.FromSeconds(30);

    public DataProcessingBackgroundService(
        ILogger<DataProcessingBackgroundService> logger,
        IServiceProvider serviceProvider)
    {
        _logger = logger;
        _serviceProvider = serviceProvider;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Data Processing Background Service started");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessDataAsync(stoppingToken);
                await Task.Delay(_period, stoppingToken);
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Data Processing Background Service is stopping");
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in Data Processing Background Service");
                // Continue processing after error
                await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
            }
        }
    }

    private async Task ProcessDataAsync(CancellationToken cancellationToken)
    {
        using var scope = _serviceProvider.CreateScope();
        var dataService = scope.ServiceProvider.GetRequiredService<IAsyncDataService>();

        _logger.LogInformation("Starting data processing cycle");

        // Simulate data processing
        var users = await dataService.GetAllUsersAsync();
        _logger.LogInformation("Processing {UserCount} users", users.Count);

        foreach (var user in users)
        {
            if (cancellationToken.IsCancellationRequested)
                break;

            // Simulate processing each user
            await Task.Delay(100, cancellationToken);
            _logger.LogDebug("Processed user: {UserId}", user.Id);
        }

        _logger.LogInformation("Data processing cycle completed");
    }

    public override async Task StopAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Data Processing Background Service is stopping");
        await base.StopAsync(cancellationToken);
    }
}
