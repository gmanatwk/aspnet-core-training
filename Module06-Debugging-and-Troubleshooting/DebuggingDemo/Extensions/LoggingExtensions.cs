using Serilog;
using System.Diagnostics;

namespace DebuggingDemo.Extensions;

public static class LoggingExtensions
{
    /// <summary>
    /// Logs method entry with parameters
    /// </summary>
    public static IDisposable BeginMethodScope(this Serilog.ILogger logger, string methodName, params object[] parameters)
    {
        logger.Information("Entering {MethodName} with parameters {@Parameters}", methodName, parameters);
        var stopwatch = Stopwatch.StartNew();
        
        return new MethodScope(logger, methodName, stopwatch);
    }

    /// <summary>
    /// Enriches log context with correlation ID
    /// </summary>
    public static void EnrichWithCorrelationId(this IDiagnosticContext diagnosticContext, HttpContext httpContext)
    {
        var correlationId = httpContext.TraceIdentifier;
        diagnosticContext.Set("CorrelationId", correlationId);
    }

    private class MethodScope : IDisposable
    {
        private readonly Serilog.ILogger _logger;
        private readonly string _methodName;
        private readonly Stopwatch _stopwatch;

        public MethodScope(Serilog.ILogger logger, string methodName, Stopwatch stopwatch)
        {
            _logger = logger;
            _methodName = methodName;
            _stopwatch = stopwatch;
        }

        public void Dispose()
        {
            _stopwatch.Stop();
            _logger.Information("Exiting {MethodName} after {ElapsedMilliseconds}ms", 
                _methodName, _stopwatch.ElapsedMilliseconds);
        }
    }
}

/// <summary>
/// Helper class for structured logging
/// </summary>
public static class LogHelper
{
    public static void LogPerformanceWarning(this ILogger logger, string operation, long elapsedMs, long thresholdMs = 1000)
    {
        if (elapsedMs > thresholdMs)
        {
            logger.Warning("Slow operation detected: {Operation} took {ElapsedMs}ms (threshold: {ThresholdMs}ms)",
                operation, elapsedMs, thresholdMs);
        }
    }

    public static void LogBusinessEvent(this ILogger logger, string eventName, object data)
    {
        logger.Information("Business event: {EventName} with data {@EventData}", eventName, data);
    }

    public static void LogSecurityEvent(this ILogger logger, string action, string username, bool success)
    {
        if (success)
        {
            logger.Information("Security: {Action} succeeded for user {Username}", action, username);
        }
        else
        {
            logger.Warning("Security: {Action} failed for user {Username}", action, username);
        }
    }
}
