using System.Diagnostics;
using System.Text;
using Serilog;
using Serilog.Events;

namespace DebuggingDemo.Middleware;

public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly Serilog.ILogger _logger = Log.ForContext<RequestLoggingMiddleware>();

    public RequestLoggingMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Skip logging for certain paths
        if (ShouldSkipLogging(context.Request.Path))
        {
            await _next(context);
            return;
        }

        var stopwatch = Stopwatch.StartNew();
        var originalBodyStream = context.Response.Body;

        try
        {
            // Log request
            await LogRequest(context);

            // Capture response body
            using var responseBody = new MemoryStream();
            context.Response.Body = responseBody;

            await _next(context);

            // Log response
            await LogResponse(context, responseBody, stopwatch.ElapsedMilliseconds);

            // Copy the response body back to the original stream
            await responseBody.CopyToAsync(originalBodyStream);
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            LogError(context, ex, stopwatch.ElapsedMilliseconds);
            throw;
        }
        finally
        {
            context.Response.Body = originalBodyStream;
        }
    }

    private bool ShouldSkipLogging(PathString path)
    {
        var pathValue = path.Value?.ToLower() ?? string.Empty;
        return pathValue.Contains("/swagger") || 
               pathValue.Contains("/health") ||
               pathValue.Contains(".js") ||
               pathValue.Contains(".css");
    }

    private async Task LogRequest(HttpContext context)
    {
        // Enable buffering to allow multiple reads
        context.Request.EnableBuffering();

        var request = context.Request;
        var body = string.Empty;

        if (request.ContentLength > 0 && request.ContentLength < 10000)
        {
            request.Body.Position = 0;
            using var reader = new StreamReader(request.Body, Encoding.UTF8, leaveOpen: true);
            body = await reader.ReadToEndAsync();
            request.Body.Position = 0;
        }

        _logger.Information("HTTP Request: {Method} {Path} {QueryString} Body: {Body}",
            request.Method,
            request.Path,
            request.QueryString,
            body);
    }

    private async Task LogResponse(HttpContext context, MemoryStream responseBody, long elapsedMs)
    {
        responseBody.Position = 0;
        var body = string.Empty;

        if (responseBody.Length > 0 && responseBody.Length < 10000)
        {
            body = await new StreamReader(responseBody).ReadToEndAsync();
        }

        responseBody.Position = 0;

        var level = context.Response.StatusCode >= 400 ? LogEventLevel.Warning : LogEventLevel.Information;

        _logger.Write(level, "HTTP Response: {StatusCode} {ElapsedMs}ms Body: {Body}",
            context.Response.StatusCode,
            elapsedMs,
            body);
    }

    private void LogError(HttpContext context, Exception ex, long elapsedMs)
    {
        _logger.Error(ex, "HTTP Request failed: {Method} {Path} after {ElapsedMs}ms",
            context.Request.Method,
            context.Request.Path,
            elapsedMs);
    }
}

public static class RequestLoggingMiddlewareExtensions
{
    public static IApplicationBuilder UseRequestLogging(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<RequestLoggingMiddleware>();
    }
}
