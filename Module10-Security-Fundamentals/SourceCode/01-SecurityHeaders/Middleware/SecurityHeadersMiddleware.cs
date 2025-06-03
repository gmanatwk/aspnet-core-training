namespace SecurityHeaders.Middleware;

/// <summary>
/// Middleware to add comprehensive security headers to HTTP responses
/// Implements OWASP security header recommendations
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

        // Log security-relevant information
        LogSecurityInfo(context);

        await _next(context);
    }

    private void AddSecurityHeaders(HttpContext context)
    {
        var headers = context.Response.Headers;

        // X-Content-Type-Options: Prevents MIME type sniffing
        headers["X-Content-Type-Options"] = "nosniff";

        // X-Frame-Options: Prevents clickjacking attacks
        headers["X-Frame-Options"] = "DENY";

        // X-XSS-Protection: Enables XSS filtering (legacy browsers)
        headers["X-XSS-Protection"] = "1; mode=block";

        // Referrer-Policy: Controls referrer information
        headers["Referrer-Policy"] = "strict-origin-when-cross-origin";

        // Permissions-Policy: Controls browser features
        headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=(), payment=()";

        // Content Security Policy: Prevents XSS and data injection attacks
        var csp = "default-src 'self'; " +
                  "script-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com; " +
                  "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; " +
                  "font-src 'self' https://fonts.gstatic.com; " +
                  "img-src 'self' data: https:; " +
                  "connect-src 'self'; " +
                  "frame-ancestors 'none'; " +
                  "base-uri 'self'; " +
                  "form-action 'self';";
        
        headers["Content-Security-Policy"] = csp;

        // Server header removal (security through obscurity)
        headers.Remove("Server");
        headers.Remove("X-Powered-By");

        // Cache-Control for sensitive pages
        if (IsSensitivePage(context.Request.Path))
        {
            headers["Cache-Control"] = "no-cache, no-store, must-revalidate";
            headers["Pragma"] = "no-cache";
            headers["Expires"] = "0";
        }

        _logger.LogDebug("Security headers added for path: {Path}", context.Request.Path);
    }

    private void LogSecurityInfo(HttpContext context)
    {
        var request = context.Request;
        
        // Log potential security issues
        if (string.IsNullOrEmpty(request.Headers["User-Agent"]))
        {
            _logger.LogWarning("Request without User-Agent header from IP: {IP}", 
                context.Connection.RemoteIpAddress);
        }

        // Log suspicious request patterns
        if (ContainsSuspiciousPatterns(request.Path))
        {
            _logger.LogWarning("Suspicious request pattern detected: {Path} from IP: {IP}", 
                request.Path, context.Connection.RemoteIpAddress);
        }

        // Log HTTPS usage
        if (!request.IsHttps && !context.Request.Headers.ContainsKey("X-Forwarded-Proto"))
        {
            _logger.LogInformation("Non-HTTPS request detected: {Path}", request.Path);
        }
    }

    private static bool IsSensitivePage(PathString path)
    {
        var sensitivePaths = new[] { "/admin", "/account", "/api", "/secure" };
        return sensitivePaths.Any(sp => path.StartsWithSegments(sp, StringComparison.OrdinalIgnoreCase));
    }

    private static bool ContainsSuspiciousPatterns(PathString path)
    {
        var suspiciousPatterns = new[]
        {
            "../", "..\\", "<script", "javascript:", "vbscript:",
            "eval(", "expression(", "import(", "document.cookie",
            "window.location", "document.write"
        };

        var pathString = path.ToString();
        return suspiciousPatterns.Any(pattern => 
            pathString.Contains(pattern, StringComparison.OrdinalIgnoreCase));
    }
}

/// <summary>
/// Extension method to register security headers middleware
/// </summary>
public static class SecurityHeadersMiddlewareExtensions
{
    public static IApplicationBuilder UseSecurityHeaders(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<SecurityHeadersMiddleware>();
    }
}
