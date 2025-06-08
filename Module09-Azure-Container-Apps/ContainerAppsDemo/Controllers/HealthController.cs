using Microsoft.AspNetCore.Mvc;

namespace ContainerAppsDemo.Controllers;

[ApiController]
[Route("[controller]")]
public class HealthController : ControllerBase
{
    private readonly ILogger<HealthController> _logger;

    public HealthController(ILogger<HealthController> logger)
    {
        _logger = logger;
    }

    [HttpGet]
    public IActionResult Get()
    {
        _logger.LogInformation("Health check requested");

        var healthStatus = new
        {
            Status = "Healthy",
            Timestamp = DateTime.UtcNow,
            Version = "1.0.0",
            Environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Production"
        };

        return Ok(healthStatus);
    }

    [HttpGet("ready")]
    public IActionResult Ready()
    {
        // Add readiness checks here (database connectivity, external services, etc.)
        _logger.LogInformation("Readiness check requested");

        var readinessStatus = new
        {
            Status = "Ready",
            Timestamp = DateTime.UtcNow,
            Checks = new
            {
                Database = "Connected",
                ExternalServices = "Available"
            }
        };

        return Ok(readinessStatus);
    }

    [HttpGet("live")]
    public IActionResult Live()
    {
        _logger.LogInformation("Liveness check requested");

        var livenessStatus = new
        {
            Status = "Alive",
            Timestamp = DateTime.UtcNow,
            Uptime = Environment.TickCount64
        };

        return Ok(livenessStatus);
    }
}
