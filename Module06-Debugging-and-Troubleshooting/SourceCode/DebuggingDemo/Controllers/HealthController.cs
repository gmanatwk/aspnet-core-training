using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace DebuggingDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HealthController : ControllerBase
{
    private readonly HealthCheckService _healthCheckService;
    private readonly ILogger<HealthController> _logger;

    public HealthController(HealthCheckService healthCheckService, ILogger<HealthController> logger)
    {
        _healthCheckService = healthCheckService;
        _logger = logger;
    }

    /// <summary>
    /// Get detailed health check results
    /// </summary>
    [HttpGet]
    public async Task<ActionResult> GetHealth()
    {
        try
        {
            _logger.LogDebug("Health check requested via API");

            var healthReport = await _healthCheckService.CheckHealthAsync();

            var response = new
            {
                Status = healthReport.Status.ToString(),
                Duration = healthReport.TotalDuration,
                Entries = healthReport.Entries.Select(entry => new
                {
                    Name = entry.Key,
                    Status = entry.Value.Status.ToString(),
                    Description = entry.Value.Description,
                    Duration = entry.Value.Duration,
                    Exception = entry.Value.Exception?.Message,
                    Data = entry.Value.Data
                }),
                Timestamp = DateTime.UtcNow
            };

            var statusCode = healthReport.Status switch
            {
                HealthStatus.Healthy => 200,
                HealthStatus.Degraded => 200,
                HealthStatus.Unhealthy => 503,
                _ => 500
            };

            _logger.LogInformation("Health check completed with status: {Status}", healthReport.Status);

            return StatusCode(statusCode, response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during health check");
            return StatusCode(500, "Error during health check");
        }
    }

    /// <summary>
    /// Get health status for readiness probe
    /// </summary>
    [HttpGet("ready")]
    public async Task<ActionResult> GetReadiness()
    {
        try
        {
            var healthReport = await _healthCheckService.CheckHealthAsync(check => 
                check.Tags.Contains("ready"));

            var response = new
            {
                Status = healthReport.Status.ToString(),
                Timestamp = DateTime.UtcNow
            };

            var statusCode = healthReport.Status == HealthStatus.Healthy ? 200 : 503;

            return StatusCode(statusCode, response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during readiness check");
            return StatusCode(503, "Service not ready");
        }
    }

    /// <summary>
    /// Get health status for liveness probe
    /// </summary>
    [HttpGet("live")]
    public ActionResult GetLiveness()
    {
        // Simple liveness check - if the application is running, it's alive
        return Ok(new
        {
            Status = "Healthy",
            Timestamp = DateTime.UtcNow
        });
    }
}
