using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System.Text;
using System.Text.Json;
using InputValidation.Services;

namespace InputValidation.Middleware
{
    public class InputValidationMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<InputValidationMiddleware> _logger;
        private readonly IInputSanitizer _sanitizer;
        private readonly int _maxRequestSize = 1048576; // 1MB

        public InputValidationMiddleware(
            RequestDelegate next, 
            ILogger<InputValidationMiddleware> logger,
            IInputSanitizer sanitizer)
        {
            _next = next;
            _logger = logger;
            _sanitizer = sanitizer;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            // Skip validation for GET requests and specific paths
            if (context.Request.Method == HttpMethods.Get || 
                ShouldSkipValidation(context.Request.Path))
            {
                await _next(context);
                return;
            }

            try
            {
                // Validate content length
                if (context.Request.ContentLength > _maxRequestSize)
                {
                    _logger.LogWarning("Request size {Size} exceeds maximum allowed size", context.Request.ContentLength);
                    context.Response.StatusCode = 413; // Payload Too Large
                    await context.Response.WriteAsync("Request size exceeds maximum allowed size");
                    return;
                }

                // Validate content type for POST/PUT requests
                if ((context.Request.Method == HttpMethods.Post || context.Request.Method == HttpMethods.Put) &&
                    !IsValidContentType(context.Request.ContentType))
                {
                    _logger.LogWarning("Invalid content type: {ContentType}", context.Request.ContentType);
                    context.Response.StatusCode = 415; // Unsupported Media Type
                    await context.Response.WriteAsync("Unsupported content type");
                    return;
                }

                // Enable buffering to read the request body multiple times
                context.Request.EnableBuffering();

                // Read and validate the request body
                if (context.Request.ContentLength > 0)
                {
                    var body = await ReadRequestBody(context.Request);
                    
                    if (!string.IsNullOrEmpty(body))
                    {
                        // Check for common attack patterns
                        if (ContainsSuspiciousPatterns(body))
                        {
                            _logger.LogWarning("Suspicious patterns detected in request body");
                            context.Response.StatusCode = 400;
                            await context.Response.WriteAsync("Invalid request data");
                            return;
                        }

                        // Reset the request body stream position
                        context.Request.Body.Position = 0;
                    }
                }

                // Validate headers
                foreach (var header in context.Request.Headers)
                {
                    if (ContainsSuspiciousPatterns(header.Value.ToString()))
                    {
                        _logger.LogWarning("Suspicious patterns detected in header: {HeaderName}", header.Key);
                        context.Response.StatusCode = 400;
                        await context.Response.WriteAsync("Invalid request headers");
                        return;
                    }
                }

                // Validate query string
                if (!string.IsNullOrEmpty(context.Request.QueryString.Value) && 
                    ContainsSuspiciousPatterns(context.Request.QueryString.Value))
                {
                    _logger.LogWarning("Suspicious patterns detected in query string");
                    context.Response.StatusCode = 400;
                    await context.Response.WriteAsync("Invalid query parameters");
                    return;
                }

                await _next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in input validation middleware");
                context.Response.StatusCode = 500;
                await context.Response.WriteAsync("An error occurred during request validation");
            }
        }

        private bool ShouldSkipValidation(PathString path)
        {
            var skipPaths = new[] { "/health", "/swagger", "/api-docs" };
            return skipPaths.Any(skip => path.StartsWithSegments(skip, StringComparison.OrdinalIgnoreCase));
        }

        private bool IsValidContentType(string contentType)
        {
            if (string.IsNullOrEmpty(contentType))
                return false;

            var allowedTypes = new[]
            {
                "application/json",
                "application/xml",
                "application/x-www-form-urlencoded",
                "multipart/form-data",
                "text/plain"
            };

            return allowedTypes.Any(type => contentType.Contains(type, StringComparison.OrdinalIgnoreCase));
        }

        private async Task<string> ReadRequestBody(HttpRequest request)
        {
            using var reader = new StreamReader(
                request.Body, 
                encoding: Encoding.UTF8, 
                detectEncodingFromByteOrderMarks: false, 
                leaveOpen: true);
            
            var body = await reader.ReadToEndAsync();
            request.Body.Position = 0;
            
            return body;
        }

        private bool ContainsSuspiciousPatterns(string input)
        {
            if (string.IsNullOrEmpty(input))
                return false;

            var suspiciousPatterns = new[]
            {
                // SQL Injection patterns
                "';--", "' OR ", "' AND ", "UNION SELECT", "DROP TABLE", "INSERT INTO",
                "UPDATE SET", "DELETE FROM", "exec sp_", "xp_cmdshell",
                
                // XSS patterns
                "<script", "javascript:", "onerror=", "onload=", "onclick=",
                "eval(", "expression(", "vbscript:", "data:text/html",
                
                // Path traversal
                "../", "..\\", "%2e%2e/", "%2e%2e\\",
                
                // Command injection
                "|", ";", "&", "&&", "||", "`", "$(", "${",
                
                // LDAP injection
                ")(", "(&", "(|",
                
                // XML injection
                "<!ENTITY", "<!DOCTYPE", "SYSTEM"
            };

            var lowerInput = input.ToLower();
            return suspiciousPatterns.Any(pattern => lowerInput.Contains(pattern.ToLower()));
        }
    }

    public static class InputValidationMiddlewareExtensions
    {
        public static IApplicationBuilder UseInputValidation(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<InputValidationMiddleware>();
        }
    }
}