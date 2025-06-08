using Microsoft.AspNetCore.Mvc;
using DebuggingDemo.Models;
using DebuggingDemo.Extensions;
using Serilog;

namespace DebuggingDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class LoggingTestController : ControllerBase
{
    private readonly ILogger<LoggingTestController> _logger;
    private readonly Serilog.ILogger _serilogLogger;
    private readonly IDiagnosticContext _diagnosticContext;

    public LoggingTestController(ILogger<LoggingTestController> logger, IDiagnosticContext diagnosticContext)
    {
        _logger = logger;
        _serilogLogger = Log.ForContext<LoggingTestController>();
        _diagnosticContext = diagnosticContext;
    }

    /// <summary>
    /// Test structured logging with different levels
    /// </summary>
    [HttpGet("test-levels")]
    public IActionResult TestLogLevels()
    {
        _logger.LogTrace("This is a trace message - very detailed");
        _logger.LogDebug("This is a debug message - debugging info");
        _logger.LogInformation("This is an information message - general info");
        _logger.LogWarning("This is a warning message - something to watch");
        _logger.LogError("This is an error message - something went wrong");
        _logger.LogCritical("This is a critical message - system failure");

        return Ok(new { Message = "Check the logs for different log levels" });
    }

    /// <summary>
    /// Test structured logging with parameters
    /// </summary>
    [HttpGet("test-structured/{id}")]
    public IActionResult TestStructuredLogging(int id, [FromQuery] string name)
    {
        // Good: Structured logging
        _logger.LogInformation("Processing request for user {UserId} with name {UserName}", id, name);

        // Add custom properties to the log context
        using (_logger.BeginScope(new Dictionary<string, object>
        {
            ["UserId"] = id,
            ["UserName"] = name,
            ["RequestTime"] = DateTime.UtcNow
        }))
        {
            _logger.LogInformation("User details retrieved successfully");
            _logger.LogInformation("Performing additional operations for user");
        }

        // Use diagnostic context for request-wide properties
        _diagnosticContext.Set("UserId", id);
        _diagnosticContext.Set("UserName", name);

        return Ok(new { UserId = id, UserName = name });
    }

    /// <summary>
    /// Test performance logging
    /// </summary>
    [HttpGet("test-performance")]
    public async Task<IActionResult> TestPerformanceLogging()
    {
        using (var scope = _serilogLogger.BeginMethodScope(nameof(TestPerformanceLogging)))
        {
            _logger.LogInformation("Starting performance test");

            // Simulate some work
            await Task.Delay(500);
            _logger.LogInformation("Phase 1 completed");

            await Task.Delay(800);
            _logger.LogInformation("Phase 2 completed");

            // Log a performance warning if slow
            var totalTime = 1300;
            _serilogLogger.LogPerformanceWarning("TestPerformanceLogging", totalTime);

            return Ok(new { Message = "Performance test completed", ElapsedMs = totalTime });
        }
    }

    /// <summary>
    /// Test exception logging
    /// </summary>
    [HttpGet("test-exception")]
    public IActionResult TestExceptionLogging()
    {
        try
        {
            _logger.LogInformation("Attempting risky operation");
            
            // Simulate an error
            throw new InvalidOperationException("This is a test exception with inner exception",
                new ArgumentException("Inner exception details"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while processing request for {Controller}.{Action}",
                nameof(LoggingTestController), nameof(TestExceptionLogging));

            return StatusCode(500, new { Error = "An error occurred", Details = ex.Message });
        }
    }

    /// <summary>
    /// Test business event logging
    /// </summary>
    [HttpPost("test-business-event")]
    public IActionResult TestBusinessEventLogging([FromBody] Order order)
    {
        // Log business event
        _serilogLogger.LogBusinessEvent("OrderCreated", new
        {
            OrderId = order.Id,
            UserId = order.UserId,
            ItemCount = order.Items.Count,
            Total = order.Total
        });

        // Log with correlation
        using (_logger.BeginScope("OrderProcessing"))
        {
            _logger.LogInformation("Processing order {OrderId}", order.Id);
            _logger.LogInformation("Validating {ItemCount} items", order.Items.Count);
            _logger.LogInformation("Order total: {OrderTotal:C}", order.Total);
        }

        return Ok(new { Message = "Order logged successfully", OrderId = order.Id });
    }

    /// <summary>
    /// Test security event logging
    /// </summary>
    [HttpPost("test-security")]
    public IActionResult TestSecurityLogging([FromBody] LoginRequest request)
    {
        // Simulate authentication
        var success = request.Username == "admin";

        _serilogLogger.LogSecurityEvent("Login", request.Username, success);

        if (!success)
        {
            _logger.LogWarning("Failed login attempt for user {Username} from IP {IPAddress}",
                request.Username, HttpContext.Connection.RemoteIpAddress);
        }

        return success ? Ok(new { Message = "Login successful" }) : Unauthorized();
    }
}

public class LoginRequest
{
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}
