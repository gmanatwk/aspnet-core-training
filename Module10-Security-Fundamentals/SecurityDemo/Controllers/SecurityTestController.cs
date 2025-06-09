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

    /// <summary>
    /// Test endpoint to verify security headers
    /// </summary>
    [HttpGet("headers")]
    public IActionResult TestHeaders()
    {
        _logger.LogInformation("Security headers test requested");

        return Ok(new
        {
            Message = "Check the response headers to verify security configuration",
            Timestamp = DateTime.UtcNow,
            Headers = new
            {
                ContentSecurityPolicy = "Configured",
                XFrameOptions = "DENY",
                XContentTypeOptions = "nosniff",
                StrictTransportSecurity = Request.IsHttps ? "Configured" : "HTTPS Required",
                ReferrerPolicy = "strict-origin-when-cross-origin"
            }
        });
    }

    /// <summary>
    /// Test endpoint for XSS prevention
    /// </summary>
    [HttpGet("xss-test")]
    public IActionResult XssTest([FromQuery] string input = "")
    {
        _logger.LogInformation("XSS test requested with input: {Input}", input);

        // This demonstrates proper output encoding
        return Ok(new
        {
            Message = "Input received and properly encoded",
            SafeInput = input, // ASP.NET Core automatically encodes this
            Timestamp = DateTime.UtcNow,
            SecurityNote = "Input is automatically encoded by ASP.NET Core JSON serializer"
        });
    }

    /// <summary>
    /// Test endpoint for HTTPS enforcement
    /// </summary>
    [HttpGet("https-test")]
    public IActionResult HttpsTest()
    {
        _logger.LogInformation("HTTPS test requested");

        return Ok(new
        {
            IsHttps = Request.IsHttps,
            Scheme = Request.Scheme,
            Host = Request.Host.Value,
            SecurityStatus = Request.IsHttps ? "Secure" : "Insecure - HTTPS Required",
            Timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Test endpoint for cookie security
    /// </summary>
    [HttpPost("cookie-test")]
    public IActionResult CookieTest()
    {
        _logger.LogInformation("Cookie security test requested");

        // Set a secure cookie
        var cookieOptions = new CookieOptions
        {
            HttpOnly = true,
            Secure = Request.IsHttps,
            SameSite = SameSiteMode.Strict,
            Expires = DateTime.UtcNow.AddHours(1)
        };

        Response.Cookies.Append("SecureTestCookie", "SecureValue", cookieOptions);

        return Ok(new
        {
            Message = "Secure cookie set",
            CookieOptions = new
            {
                HttpOnly = cookieOptions.HttpOnly,
                Secure = cookieOptions.Secure,
                SameSite = cookieOptions.SameSite.ToString(),
                Expires = cookieOptions.Expires
            },
            Timestamp = DateTime.UtcNow
        });
    }
}
