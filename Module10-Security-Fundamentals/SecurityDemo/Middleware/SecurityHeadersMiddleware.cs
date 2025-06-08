using Microsoft.Extensions.Primitives;

namespace SecurityDemo.Middleware;

/// <summary>
/// Middleware to add comprehensive security headers
/// </summary>
public class SecurityHeadersMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<SecurityHeadersMiddleware> _logger;

    public SecurityHeadersMiddleware(RequestDelegate next, ILogger<SecurityHeadersMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Add security headers before processing the request
        AddSecurityHeaders(context);

        await _next(context);
    }

    private void AddSecurityHeaders(HttpContext context)
    {
        var headers = context.Response.Headers;

        // Content Security Policy - Prevent XSS attacks
        headers.Append("Content-Security-Policy",
            "default-src 'self'; " +
            "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdnjs.cloudflare.com; " +
            "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; " +
            "font-src 'self' https://fonts.gstatic.com; " +
            "img-src 'self' data: https:; " +
            "connect-src 'self'; " +
            "frame-ancestors 'none'; " +
            "base-uri 'self'; " +
            "form-action 'self'");

        // X-Frame-Options - Prevent clickjacking
        headers.Append("X-Frame-Options", "DENY");

        // X-Content-Type-Options - Prevent MIME sniffing
        headers.Append("X-Content-Type-Options", "nosniff");

        // X-XSS-Protection - Enable XSS filtering
        headers.Append("X-XSS-Protection", "1; mode=block");

        // Strict-Transport-Security - Enforce HTTPS
        if (context.Request.IsHttps)
        {
            headers.Append("Strict-Transport-Security", "max-age=31536000; includeSubDomains; preload");
        }

        // Referrer-Policy - Control referrer information
        headers.Append("Referrer-Policy", "strict-origin-when-cross-origin");

        // Permissions-Policy - Control browser features
        headers.Append("Permissions-Policy",
            "camera=(), " +
            "microphone=(), " +
            "geolocation=(), " +
            "payment=(), " +
            "usb=(), " +
            "magnetometer=(), " +
            "accelerometer=(), " +
            "gyroscope=()");

        // Remove server information
        headers.Remove("Server");
        headers.Append("Server", "SecureServer");

        // Remove X-Powered-By header
        headers.Remove("X-Powered-By");

        _logger.LogDebug("Security headers added to response");
    }
}

/// <summary>
/// Extension methods for adding security headers middleware
/// </summary>
public static class SecurityHeadersMiddlewareExtensions
{
    public static IApplicationBuilder UseSecurityHeaders(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<SecurityHeadersMiddleware>();
    }
}
