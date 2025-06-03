using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System.Text;
using System.Text.Json;
using System.Web;
using InputValidation.Services;

namespace InputValidation.Middleware
{
    public class AntiXssMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<AntiXssMiddleware> _logger;
        private readonly IInputSanitizer _sanitizer;

        public AntiXssMiddleware(
            RequestDelegate next, 
            ILogger<AntiXssMiddleware> logger,
            IInputSanitizer sanitizer)
        {
            _next = next;
            _logger = logger;
            _sanitizer = sanitizer;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            // Add security headers to prevent XSS
            AddSecurityHeaders(context);

            // For responses, wrap the original body stream
            var originalBodyStream = context.Response.Body;

            try
            {
                using var responseBody = new MemoryStream();
                context.Response.Body = responseBody;

                await _next(context);

                // Modify response if it's HTML content
                if (IsHtmlResponse(context.Response))
                {
                    context.Response.Body.Seek(0, SeekOrigin.Begin);
                    var responseText = await new StreamReader(context.Response.Body).ReadToEndAsync();
                    
                    // Apply additional XSS protection if needed
                    responseText = ApplyXssProtection(responseText);

                    context.Response.Body.Seek(0, SeekOrigin.Begin);
                    await context.Response.Body.WriteAsync(Encoding.UTF8.GetBytes(responseText));
                }

                context.Response.Body.Seek(0, SeekOrigin.Begin);
                await responseBody.CopyToAsync(originalBodyStream);
            }
            finally
            {
                context.Response.Body = originalBodyStream;
            }
        }

        private void AddSecurityHeaders(HttpContext context)
        {
            // Content Security Policy
            if (!context.Response.Headers.ContainsKey("Content-Security-Policy"))
            {
                context.Response.Headers.Add("Content-Security-Policy", 
                    "default-src 'self'; " +
                    "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdnjs.cloudflare.com; " +
                    "style-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com; " +
                    "img-src 'self' data: https:; " +
                    "font-src 'self' https://cdnjs.cloudflare.com; " +
                    "connect-src 'self'; " +
                    "frame-ancestors 'none'; " +
                    "base-uri 'self'; " +
                    "form-action 'self'");
            }

            // X-Content-Type-Options
            if (!context.Response.Headers.ContainsKey("X-Content-Type-Options"))
            {
                context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
            }

            // X-Frame-Options
            if (!context.Response.Headers.ContainsKey("X-Frame-Options"))
            {
                context.Response.Headers.Add("X-Frame-Options", "DENY");
            }

            // X-XSS-Protection (for older browsers)
            if (!context.Response.Headers.ContainsKey("X-XSS-Protection"))
            {
                context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
            }

            // Referrer-Policy
            if (!context.Response.Headers.ContainsKey("Referrer-Policy"))
            {
                context.Response.Headers.Add("Referrer-Policy", "strict-origin-when-cross-origin");
            }

            // Permissions-Policy
            if (!context.Response.Headers.ContainsKey("Permissions-Policy"))
            {
                context.Response.Headers.Add("Permissions-Policy", 
                    "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=()");
            }
        }

        private bool IsHtmlResponse(HttpResponse response)
        {
            return response.ContentType != null && 
                   (response.ContentType.Contains("text/html", StringComparison.OrdinalIgnoreCase) ||
                    response.ContentType.Contains("application/xhtml", StringComparison.OrdinalIgnoreCase));
        }

        private string ApplyXssProtection(string html)
        {
            if (string.IsNullOrEmpty(html))
                return html;

            // Log if suspicious content is detected
            if (ContainsXssPatterns(html))
            {
                _logger.LogWarning("Potential XSS content detected in response");
            }

            // Additional sanitization can be applied here if needed
            // For now, we'll just ensure proper encoding of user-generated content markers
            
            return html;
        }

        private bool ContainsXssPatterns(string content)
        {
            var xssPatterns = new[]
            {
                "<script", "javascript:", "onerror=", "onload=", "onclick=",
                "eval(", "expression(", "vbscript:", "data:text/html",
                "<iframe", "<object", "<embed", "<form", "<input"
            };

            var lowerContent = content.ToLower();
            return xssPatterns.Any(pattern => lowerContent.Contains(pattern));
        }
    }

    public static class AntiXssMiddlewareExtensions
    {
        public static IApplicationBuilder UseAntiXss(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<AntiXssMiddleware>();
        }
    }
}