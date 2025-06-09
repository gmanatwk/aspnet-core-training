using Microsoft.AspNetCore.Mvc;

namespace SecurityDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SecurityTestController : ControllerBase
{
    private readonly ILogger<SecurityTestController> _logger;

    public SecurityTestController(ILogger<SecurityTestController> logger)
    {
        _logger = logger;
    }

    [HttpGet("headers")]
    public IActionResult GetSecurityHeaders()
    {
        _logger.LogInformation("Security headers test endpoint called");

        return Ok(new
        {
            Message = "Check the response headers to see security headers in action",
            Timestamp = DateTime.UtcNow,
            Headers = new
            {
                ContentSecurityPolicy = "Prevents XSS attacks",
                XFrameOptions = "Prevents clickjacking",
                XContentTypeOptions = "Prevents MIME sniffing",
                StrictTransportSecurity = "Enforces HTTPS",
                ReferrerPolicy = "Controls referrer information"
            }
        });
    }

    [HttpGet("test-csp")]
    public IActionResult TestContentSecurityPolicy()
    {
        return Content(@"
<!DOCTYPE html>
<html>
<head>
    <title>CSP Test</title>
</head>
<body>
    <h1>Content Security Policy Test</h1>
    <p>This page tests CSP headers. Check browser console for CSP violations.</p>
    <script>
        console.log('This inline script should be blocked by CSP if configured properly');
    </script>
</body>
</html>", "text/html");
    }

    [HttpGet("secure-info")]
    public IActionResult GetSecureInformation()
    {
        return Ok(new
        {
            ApplicationName = "Security Demo API",
            SecurityFeatures = new[]
            {
                "Security Headers Middleware",
                "HTTPS Enforcement",
                "Input Validation",
                "CSRF Protection",
                "Data Encryption"
            },
            SecurityTip = "Always validate input, encode output, and use HTTPS in production"
        });
    }
}
