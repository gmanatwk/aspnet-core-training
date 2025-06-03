using Serilog.Context;

namespace DebuggingDemo.Middleware;

public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var requestId = context.TraceIdentifier;
        var userAgent = context.Request.Headers.UserAgent.ToString();
        var clientIp = GetClientIpAddress(context);

        // Add context to all log entries for this request
        using (LogContext.PushProperty("RequestId", requestId))
        using (LogContext.PushProperty("ClientIP", clientIp))
        using (LogContext.PushProperty("UserAgent", userAgent))
        {
            // Log request start
            _logger.LogInformation("Request started: {Method} {Path} {QueryString}", 
                context.Request.Method, 
                context.Request.Path, 
                context.Request.QueryString);

            // Log request headers in development
            if (_logger.IsEnabled(LogLevel.Debug))
            {
                var headers = context.Request.Headers
                    .Where(h => !IsSecuritySensitiveHeader(h.Key))
                    .ToDictionary(h => h.Key, h => h.Value.ToString());
                
                _logger.LogDebug("Request headers: {@Headers}", headers);
            }

            var originalBodyStream = context.Response.Body;

            try
            {
                await _next(context);
                
                // Log response
                _logger.LogInformation("Request completed: {Method} {Path} responded {StatusCode}", 
                    context.Request.Method, 
                    context.Request.Path, 
                    context.Response.StatusCode);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Request failed: {Method} {Path}", 
                    context.Request.Method, 
                    context.Request.Path);
                throw;
            }
            finally
            {
                context.Response.Body = originalBodyStream;
            }
        }
    }

    private static string GetClientIpAddress(HttpContext context)
    {
        // Check for forwarded IP first (common in load balancer scenarios)
        var forwardedFor = context.Request.Headers["X-Forwarded-For"].FirstOrDefault();
        if (!string.IsNullOrEmpty(forwardedFor))
        {
            return forwardedFor.Split(',')[0].Trim();
        }

        var realIp = context.Request.Headers["X-Real-IP"].FirstOrDefault();
        if (!string.IsNullOrEmpty(realIp))
        {
            return realIp;
        }

        return context.Connection.RemoteIpAddress?.ToString() ?? "Unknown";
    }

    private static bool IsSecuritySensitiveHeader(string headerName)
    {
        var sensitiveHeaders = new[]
        {
            "Authorization",
            "Cookie",
            "X-API-Key",
            "X-Auth-Token"
        };

        return sensitiveHeaders.Contains(headerName, StringComparer.OrdinalIgnoreCase);
    }
}
