using System.Diagnostics;
using DebuggingDemo.Extensions;

namespace DebuggingDemo.Middleware;

public class PerformanceMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<PerformanceMiddleware> _logger;
    private readonly int _slowRequestThresholdMs;

    public PerformanceMiddleware(RequestDelegate next, ILogger<PerformanceMiddleware> logger, IConfiguration configuration)
    {
        _next = next;
        _logger = logger;
        _slowRequestThresholdMs = configuration.GetValue<int>("Performance:SlowRequestThresholdMs", 1000);
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();
        var path = context.Request.Path;

        try
        {
            await _next(context);
        }
        finally
        {
            stopwatch.Stop();
            var elapsedMs = stopwatch.ElapsedMilliseconds;

            if (elapsedMs > _slowRequestThresholdMs)
            {
                _logger.LogPerformanceWarning($"{context.Request.Method} {path}", elapsedMs, _slowRequestThresholdMs);
            }

            // Add performance headers
            context.Response.Headers.Add("X-Response-Time-ms", elapsedMs.ToString());
            
            // Log performance metrics
            using (_logger.BeginScope(new Dictionary<string, object>
            {
                ["RequestPath"] = path.Value,
                ["RequestMethod"] = context.Request.Method,
                ["StatusCode"] = context.Response.StatusCode,
                ["ElapsedMilliseconds"] = elapsedMs
            }))
            {
                _logger.LogInformation("Request completed in {ElapsedMilliseconds}ms", elapsedMs);
            }
        }
    }
}

public static class PerformanceMiddlewareExtensions
{
    public static IApplicationBuilder UsePerformanceLogging(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<PerformanceMiddleware>();
    }
}
