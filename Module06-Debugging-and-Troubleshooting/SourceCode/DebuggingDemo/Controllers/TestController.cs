using Microsoft.AspNetCore.Mvc;
using DebuggingDemo.Services;
using DebuggingDemo.Data;
using Microsoft.EntityFrameworkCore;

namespace DebuggingDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TestController : ControllerBase
{
    private readonly IExternalApiService _externalApiService;
    private readonly DebuggingContext _context;
    private readonly ILogger<TestController> _logger;

    public TestController(
        IExternalApiService externalApiService, 
        DebuggingContext context, 
        ILogger<TestController> logger)
    {
        _externalApiService = externalApiService;
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Test endpoint that always works - use for basic connectivity testing
    /// </summary>
    [HttpGet("ping")]
    public ActionResult<object> Ping()
    {
        _logger.LogInformation("Ping endpoint called");

        return Ok(new
        {
            Message = "Pong",
            Timestamp = DateTime.UtcNow,
            Server = Environment.MachineName,
            Environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")
        });
    }

    /// <summary>
    /// Test endpoint that simulates slow response
    /// </summary>
    [HttpGet("slow/{delayMs:int}")]
    public async Task<ActionResult<object>> SlowResponse(int delayMs)
    {
        if (delayMs < 0 || delayMs > 30000)
        {
            return BadRequest("Delay must be between 0 and 30000 milliseconds");
        }

        _logger.LogInformation("Slow response endpoint called with delay: {DelayMs}ms", delayMs);

        await Task.Delay(delayMs);

        return Ok(new
        {
            Message = $"Response delayed by {delayMs}ms",
            DelayMs = delayMs,
            Timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Test endpoint that throws different types of exceptions
    /// </summary>
    [HttpGet("error/{errorType}")]
    public ActionResult TestError(string errorType)
    {
        _logger.LogWarning("Error endpoint called with type: {ErrorType}", errorType);

        return errorType.ToLowerInvariant() switch
        {
            "argument" => throw new ArgumentException($"Test argument exception triggered at {DateTime.UtcNow}"),
            "notfound" => throw new KeyNotFoundException($"Test not found exception triggered at {DateTime.UtcNow}"),
            "unauthorized" => throw new UnauthorizedAccessException($"Test unauthorized exception triggered at {DateTime.UtcNow}"),
            "timeout" => throw new TimeoutException($"Test timeout exception triggered at {DateTime.UtcNow}"),
            "invalid" => throw new InvalidOperationException($"Test invalid operation exception triggered at {DateTime.UtcNow}"),
            "http" => throw new HttpRequestException($"Test HTTP request exception triggered at {DateTime.UtcNow}"),
            "generic" => throw new Exception($"Test generic exception triggered at {DateTime.UtcNow}"),
            _ => BadRequest($"Unknown error type: {errorType}. Available types: argument, notfound, unauthorized, timeout, invalid, http, generic")
        };
    }

    /// <summary>
    /// Test endpoint that uses external API service
    /// </summary>
    [HttpGet("external/{id:int}")]
    public async Task<ActionResult<string>> TestExternalApi(int id)
    {
        try
        {
            _logger.LogInformation("External API test called with ID: {Id}", id);

            var result = await _externalApiService.GetDataAsync(id);
            return Ok(result);
        }
        catch (ArgumentException ex)
        {
            _logger.LogWarning(ex, "Invalid argument for external API test: {Id}", id);
            return BadRequest(ex.Message);
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "HTTP error during external API test");
            return StatusCode(502, "External service error");
        }
        catch (TimeoutException ex)
        {
            _logger.LogError(ex, "Timeout during external API test");
            return StatusCode(408, "Request timeout");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error during external API test");
            throw;
        }
    }

    /// <summary>
    /// Test endpoint that performs database operations
    /// </summary>
    [HttpGet("database")]
    public async Task<ActionResult<object>> TestDatabase()
    {
        try
        {
            _logger.LogInformation("Database test endpoint called");

            var entities = await _context.TestEntities
                .Where(e => e.IsActive)
                .OrderBy(e => e.CreatedAt)
                .Take(5)
                .ToListAsync();

            var result = new
            {
                TotalActiveEntities = entities.Count,
                Entities = entities.Select(e => new
                {
                    e.Id,
                    e.Name,
                    e.Description,
                    e.CreatedAt
                }),
                QueryExecutedAt = DateTime.UtcNow
            };

            _logger.LogInformation("Database test completed successfully. Found {Count} entities", entities.Count);

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during database test");
            throw;
        }
    }

    /// <summary>
    /// Test endpoint that consumes memory
    /// </summary>
    [HttpPost("memory/{sizeMB:int}")]
    public ActionResult<object> TestMemoryConsumption(int sizeMB)
    {
        if (sizeMB <= 0 || sizeMB > 100)
        {
            return BadRequest("Size must be between 1 and 100 MB");
        }

        _logger.LogWarning("Memory consumption test called with size: {SizeMB}MB", sizeMB);

        var memoryBefore = GC.GetTotalMemory(false);
        
        // Allocate memory (this will be collected by GC)
        var data = new byte[sizeMB * 1024 * 1024];
        Array.Fill(data, (byte)1);

        var memoryAfter = GC.GetTotalMemory(false);

        var result = new
        {
            AllocatedMB = sizeMB,
            MemoryBeforeBytes = memoryBefore,
            MemoryAfterBytes = memoryAfter,
            MemoryIncreasedBytes = memoryAfter - memoryBefore,
            Timestamp = DateTime.UtcNow,
            Warning = "This memory will be collected by the garbage collector"
        };

        _logger.LogInformation("Memory test completed. Allocated {SizeMB}MB, memory increased by {IncreaseBytes} bytes", 
            sizeMB, result.MemoryIncreasedBytes);

        return Ok(result);
    }

    /// <summary>
    /// Test endpoint for logging different levels
    /// </summary>
    [HttpPost("logging/{level}")]
    public ActionResult TestLogging(string level, [FromBody] string? message = null)
    {
        var logMessage = message ?? $"Test log message at {level} level - {DateTime.UtcNow}";

        switch (level.ToLowerInvariant())
        {
            case "trace":
                _logger.LogTrace(logMessage);
                break;
            case "debug":
                _logger.LogDebug(logMessage);
                break;
            case "information":
            case "info":
                _logger.LogInformation(logMessage);
                break;
            case "warning":
            case "warn":
                _logger.LogWarning(logMessage);
                break;
            case "error":
                _logger.LogError(logMessage);
                break;
            case "critical":
                _logger.LogCritical(logMessage);
                break;
            default:
                return BadRequest($"Unknown log level: {level}. Available levels: trace, debug, information, warning, error, critical");
        }

        return Ok(new
        {
            Level = level,
            Message = logMessage,
            Timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Get all available test endpoints
    /// </summary>
    [HttpGet("endpoints")]
    public ActionResult<object> GetTestEndpoints()
    {
        var endpoints = new
        {
            Basic = new
            {
                Ping = "GET /api/test/ping",
                Description = "Basic connectivity test"
            },
            Performance = new
            {
                SlowResponse = "GET /api/test/slow/{delayMs}",
                Description = "Test endpoint with configurable delay"
            },
            Errors = new
            {
                TestError = "GET /api/test/error/{errorType}",
                AvailableTypes = new[] { "argument", "notfound", "unauthorized", "timeout", "invalid", "http", "generic" },
                Description = "Test different exception types"
            },
            External = new
            {
                ExternalApi = "GET /api/test/external/{id}",
                Description = "Test external API integration"
            },
            Database = new
            {
                DatabaseTest = "GET /api/test/database",
                Description = "Test database connectivity and queries"
            },
            Memory = new
            {
                MemoryTest = "POST /api/test/memory/{sizeMB}",
                Description = "Test memory allocation (1-100 MB)"
            },
            Logging = new
            {
                LoggingTest = "POST /api/test/logging/{level}",
                AvailableLevels = new[] { "trace", "debug", "information", "warning", "error", "critical" },
                Description = "Test different logging levels"
            }
        };

        return Ok(endpoints);
    }
}
