using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace DebuggingDemo.Services.HealthChecks;

public class ExternalApiHealthCheck : IHealthCheck
{
    private readonly IExternalApiService _externalApiService;
    private readonly ILogger<ExternalApiHealthCheck> _logger;

    public ExternalApiHealthCheck(IExternalApiService externalApiService, ILogger<ExternalApiHealthCheck> logger)
    {
        _externalApiService = externalApiService;
        _logger = logger;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context, 
        CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogDebug("Checking external API health");

            var startTime = DateTime.UtcNow;
            var isHealthy = await _externalApiService.CheckServiceHealthAsync();
            var responseTime = DateTime.UtcNow - startTime;

            var data = new Dictionary<string, object>
            {
                ["ServiceUrl"] = "https://jsonplaceholder.typicode.com",
                ["ResponseTimeMs"] = responseTime.TotalMilliseconds,
                ["CheckedAt"] = DateTime.UtcNow
            };

            if (isHealthy)
            {
                _logger.LogDebug("External API health check passed. Response time: {ResponseTime}ms", 
                    responseTime.TotalMilliseconds);

                return HealthCheckResult.Healthy("External API is responding", data);
            }
            else
            {
                _logger.LogWarning("External API health check failed. Service is not responding properly");

                return HealthCheckResult.Degraded("External API is not responding properly", null, data);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "External API health check failed with exception");

            var data = new Dictionary<string, object>
            {
                ["Error"] = ex.Message,
                ["ExceptionType"] = ex.GetType().Name,
                ["CheckedAt"] = DateTime.UtcNow
            };

            return HealthCheckResult.Unhealthy("External API health check failed", ex, data);
        }
    }
}
