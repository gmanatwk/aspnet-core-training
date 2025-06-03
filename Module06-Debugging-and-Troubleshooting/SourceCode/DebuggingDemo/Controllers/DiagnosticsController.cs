using Microsoft.AspNetCore.Mvc;
using DebuggingDemo.Models;
using DebuggingDemo.Services;

namespace DebuggingDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DiagnosticsController : ControllerBase
{
    private readonly DiagnosticService _diagnosticService;
    private readonly ILogger<DiagnosticsController> _logger;

    public DiagnosticsController(DiagnosticService diagnosticService, ILogger<DiagnosticsController> logger)
    {
        _diagnosticService = diagnosticService;
        _logger = logger;
    }

    /// <summary>
    /// Get comprehensive diagnostic information about the application
    /// </summary>
    [HttpGet("info")]
    public ActionResult<DiagnosticInfo> GetDiagnosticInfo()
    {
        try
        {
            _logger.LogInformation("Diagnostic info requested");

            var diagnosticInfo = _diagnosticService.GetDiagnosticInfo();
            return Ok(diagnosticInfo);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving diagnostic information");
            return StatusCode(500, "Error retrieving diagnostic information");
        }
    }

    /// <summary>
    /// Get recent application logs
    /// </summary>
    [HttpGet("logs")]
    public async Task<ActionResult<List<LogEntry>>> GetRecentLogs([FromQuery] int count = 50)
    {
        try
        {
            _logger.LogInformation("Recent logs requested, count: {Count}", count);

            if (count <= 0 || count > 1000)
            {
                return BadRequest("Count must be between 1 and 1000");
            }

            var logs = await _diagnosticService.GetRecentLogsAsync(count);
            return Ok(logs);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving recent logs");
            return StatusCode(500, "Error retrieving recent logs");
        }
    }

    /// <summary>
    /// Get current performance metrics
    /// </summary>
    [HttpGet("performance")]
    public ActionResult<PerformanceMetrics> GetPerformanceMetrics()
    {
        try
        {
            _logger.LogInformation("Performance metrics requested");

            var metrics = _diagnosticService.GetPerformanceSnapshot();
            return Ok(metrics);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving performance metrics");
            return StatusCode(500, "Error retrieving performance metrics");
        }
    }

    /// <summary>
    /// Run a specific diagnostic test
    /// </summary>
    [HttpPost("test/{testName}")]
    public async Task<ActionResult<string>> RunDiagnosticTest(string testName)
    {
        try
        {
            _logger.LogInformation("Diagnostic test requested: {TestName}", testName);

            var result = await _diagnosticService.RunDiagnosticTestAsync(testName);
            return Ok(result);
        }
        catch (ArgumentException ex)
        {
            _logger.LogWarning(ex, "Invalid test name: {TestName}", testName);
            return BadRequest($"Invalid test name: {testName}. Available tests: memory, performance, exception, logging");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error running diagnostic test: {TestName}", testName);
            return StatusCode(500, "Error running diagnostic test");
        }
    }

    /// <summary>
    /// Force garbage collection (use with caution)
    /// </summary>
    [HttpPost("gc")]
    public ActionResult ForceGarbageCollection()
    {
        try
        {
            _logger.LogWarning("Forced garbage collection requested");

            var beforeMemory = GC.GetTotalMemory(false);
            
            GC.Collect();
            GC.WaitForPendingFinalizers();
            GC.Collect();
            
            var afterMemory = GC.GetTotalMemory(true);

            var result = new
            {
                MemoryBeforeBytes = beforeMemory,
                MemoryAfterBytes = afterMemory,
                MemoryReleasedBytes = beforeMemory - afterMemory,
                Timestamp = DateTime.UtcNow
            };

            _logger.LogInformation("Forced garbage collection completed. Memory released: {MemoryReleased} bytes", 
                result.MemoryReleasedBytes);

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during forced garbage collection");
            return StatusCode(500, "Error during forced garbage collection");
        }
    }

    /// <summary>
    /// Get available diagnostic tests
    /// </summary>
    [HttpGet("tests")]
    public ActionResult<string[]> GetAvailableTests()
    {
        var tests = new[] { "memory", "performance", "exception", "logging" };
        
        _logger.LogDebug("Available diagnostic tests requested");
        
        return Ok(tests);
    }
}
