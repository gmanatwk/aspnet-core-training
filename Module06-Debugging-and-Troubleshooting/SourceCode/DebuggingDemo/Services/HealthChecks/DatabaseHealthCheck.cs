using Microsoft.Extensions.Diagnostics.HealthChecks;
using DebuggingDemo.Data;
using Microsoft.EntityFrameworkCore;

namespace DebuggingDemo.Services.HealthChecks;

public class DatabaseHealthCheck : IHealthCheck
{
    private readonly DebuggingContext _context;
    private readonly ILogger<DatabaseHealthCheck> _logger;

    public DatabaseHealthCheck(DebuggingContext context, ILogger<DatabaseHealthCheck> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context, 
        CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogDebug("Checking database health");

            // Check if we can connect to the database
            await _context.Database.CanConnectAsync(cancellationToken);

            // Perform a simple query to verify database functionality
            var testEntitiesCount = await _context.TestEntities.CountAsync(cancellationToken);

            var data = new Dictionary<string, object>
            {
                ["ConnectionState"] = _context.Database.GetDbConnection().State.ToString(),
                ["TestEntitiesCount"] = testEntitiesCount,
                ["DatabaseProvider"] = _context.Database.ProviderName ?? "Unknown",
                ["CheckedAt"] = DateTime.UtcNow
            };

            _logger.LogDebug("Database health check passed. Test entities count: {Count}", testEntitiesCount);

            return HealthCheckResult.Healthy("Database connection is healthy", data);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Database health check failed");

            var data = new Dictionary<string, object>
            {
                ["Error"] = ex.Message,
                ["ExceptionType"] = ex.GetType().Name,
                ["CheckedAt"] = DateTime.UtcNow
            };

            return HealthCheckResult.Unhealthy("Database connection failed", ex, data);
        }
    }
}
