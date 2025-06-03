using System.Diagnostics;
using DebuggingDemo.Models;

namespace DebuggingDemo.Middleware;

public class PerformanceMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<PerformanceMiddleware> _logger;
    private readonly IConfiguration _configuration;

    public PerformanceMiddleware(RequestDelegate next, ILogger<PerformanceMiddleware> logger, IConfiguration configuration)
    {
        _next = next;
        _logger = logger;
        _configuration = configuration;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();
        var memoryBefore = GC.GetTotalMemory(false);

        try
        {
            await _next(context);
        }
        finally
        {
            stopwatch.Stop();
            var memoryAfter = GC.GetTotalMemory(false);
            var memoryUsed = memoryAfter - memoryBefore;

            var performanceData = new PerformanceMetrics
            {
                RequestId = context.TraceIdentifier,
                Method = context.Request.Method,
                Path = context.Request.Path,
                StatusCode = context.Response.StatusCode,
                ElapsedMilliseconds = stopwatch.ElapsedMilliseconds,
                MemoryUsedBytes = memoryUsed,
                Timestamp = DateTime.UtcNow
            };

            // Log performance data
            LogPerformanceData(performanceData);

            // Add performance headers for debugging
            if (_configuration.GetValue<bool>("PerformanceSettings:EnablePerformanceLogging"))
            {
                context.Response.Headers.Add("X-Response-Time", stopwatch.ElapsedMilliseconds.ToString());
                context.Response.Headers.Add("X-Memory-Used", memoryUsed.ToString());
            }
        }
    }

    private void LogPerformanceData(PerformanceMetrics metrics)
    {
        var slowRequestThreshold = _configuration.GetValue<int>("PerformanceSettings:SlowRequestThresholdMs", 1000);

        if (metrics.ElapsedMilliseconds > slowRequestThreshold)
        {
            _logger.LogWarning("Slow request detected: {Method} {Path} took {ElapsedMs}ms and used {MemoryUsed} bytes of memory. Status: {StatusCode}",
                metrics.Method,
                metrics.Path,
                metrics.ElapsedMilliseconds,
                metrics.MemoryUsedBytes,
                metrics.StatusCode);
        }
        else
        {
            _logger.LogDebug("Request performance: {Method} {Path} took {ElapsedMs}ms and used {MemoryUsed} bytes of memory. Status: {StatusCode}",
                metrics.Method,
                metrics.Path,
                metrics.ElapsedMilliseconds,
                metrics.MemoryUsedBytes,
                metrics.StatusCode);
        }

        // Log extreme performance cases
        if (metrics.ElapsedMilliseconds > slowRequestThreshold * 5)
        {
            _logger.LogError("Extremely slow request: {Method} {Path} took {ElapsedMs}ms. This requires immediate attention!",
                metrics.Method,
                metrics.Path,
                metrics.ElapsedMilliseconds);
        }

        if (Math.Abs(metrics.MemoryUsedBytes) > 10_000_000) // 10MB
        {
            _logger.LogWarning("High memory usage detected: {Method} {Path} used {MemoryUsed} bytes of memory",
                metrics.Method,
                metrics.Path,
                metrics.MemoryUsedBytes);
        }
    }
}
