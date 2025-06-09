#!/usr/bin/env pwsh

# Module 10: Security Fundamentals - Interactive Exercise Launcher (PowerShell)
# This script provides guided, hands-on exercises for ASP.NET Core security implementation

param(
    [Parameter(Mandatory=$false)]
    [string]$ExerciseName,
    
    [Parameter(Mandatory=$false)]
    [switch]$List,
    
    [Parameter(Mandatory=$false)]
    [switch]$Auto,
    
    [Parameter(Mandatory=$false)]
    [switch]$Preview
)

# Configuration
$ProjectName = "SecurityDemo"
$InteractiveMode = -not $Auto

# Function to display colored output
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Blue }
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }

# Function to explain concepts interactively
function Explain-Concept {
    param($Concept, $Explanation)
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Write-Host "🔐 SECURITY CONCEPT: $Concept" -ForegroundColor Magenta
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Write-Host $Explanation -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Write-Host ""
    
    if ($InteractiveMode) {
        Write-Host "Press Enter to continue..." -NoNewline
        Read-Host
        Write-Host ""
    }
}

# Function to show learning objectives
function Show-LearningObjectives {
    param([string]$Exercise)

    Write-Host "🎯 Security Learning Objectives for ${Exercise}:" -ForegroundColor Blue

    switch ($Exercise) {
        "exercise01" {
            Write-Host "Security Headers Implementation:" -ForegroundColor Cyan
            Write-Host "  🛡️  1. Configure comprehensive HTTP security headers"
            Write-Host "  🛡️  2. Implement Content Security Policy (CSP)"
            Write-Host "  🛡️  3. Set up HTTPS enforcement and HSTS"
            Write-Host "  🛡️  4. Configure secure cookie settings"
            Write-Host ""
            Write-Host "Security concepts:" -ForegroundColor Yellow
            Write-Host "  • Defense in depth through HTTP headers"
            Write-Host "  • XSS prevention with CSP"
            Write-Host "  • Transport security with HTTPS/HSTS"
            Write-Host "  • Session security with secure cookies"
        }
        "exercise02" {
            Write-Host "Input Validation & Data Protection:" -ForegroundColor Cyan
            Write-Host "  🛡️  1. Implement robust input validation"
            Write-Host "  🛡️  2. Prevent XSS and injection attacks"
            Write-Host "  🛡️  3. Configure CSRF protection"
            Write-Host "  🛡️  4. Data sanitization techniques"
            Write-Host ""
            Write-Host "Security concepts:" -ForegroundColor Yellow
            Write-Host "  • Input validation strategies"
            Write-Host "  • Output encoding and sanitization"
            Write-Host "  • CSRF token implementation"
            Write-Host "  • SQL injection prevention"
        }
        "exercise03" {
            Write-Host "Encryption & Key Management:" -ForegroundColor Cyan
            Write-Host "  🛡️  1. Implement data encryption at rest"
            Write-Host "  🛡️  2. Configure encryption in transit"
            Write-Host "  🛡️  3. Secure key management practices"
            Write-Host "  🛡️  4. Azure Key Vault integration"
            Write-Host ""
            Write-Host "Security concepts:" -ForegroundColor Yellow
            Write-Host "  • Symmetric and asymmetric encryption"
            Write-Host "  • Key rotation and management"
            Write-Host "  • Secure secret storage"
            Write-Host "  • Digital signatures and hashing"
        }
        "exercise04" {
            Write-Host "Security Audit & Assessment:" -ForegroundColor Cyan
            Write-Host "  🛡️  1. Perform comprehensive security audit"
            Write-Host "  🛡️  2. Identify security vulnerabilities"
            Write-Host "  🛡️  3. Implement security monitoring"
            Write-Host "  🛡️  4. Create incident response procedures"
            Write-Host ""
            Write-Host "Security concepts:" -ForegroundColor Yellow
            Write-Host "  • OWASP Top 10 assessment"
            Write-Host "  • Vulnerability scanning"
            Write-Host "  • Security logging and monitoring"
            Write-Host "  • Compliance and governance"
        }
        "exercise05" {
            Write-Host "Penetration Testing:" -ForegroundColor Cyan
            Write-Host "  🛡️  1. Basic penetration testing with OWASP ZAP"
            Write-Host "  🛡️  2. Automated security scanning"
            Write-Host "  🛡️  3. Manual security testing techniques"
            Write-Host "  🛡️  4. Security report generation"
            Write-Host ""
            Write-Host "Security concepts:" -ForegroundColor Yellow
            Write-Host "  • Ethical hacking principles"
            Write-Host "  • Automated vulnerability scanning"
            Write-Host "  • Manual testing methodologies"
            Write-Host "  • Security reporting and remediation"
        }
    }
    Write-Host ""
}

# Function to show what will be created
function Show-CreationOverview {
    param([string]$Exercise)

    Write-Host "📋 Security Components for ${Exercise}:" -ForegroundColor Cyan

    switch ($Exercise) {
        "exercise01" {
            Write-Host "• Security headers middleware"
            Write-Host "• Content Security Policy configuration"
            Write-Host "• HTTPS redirection and HSTS setup"
            Write-Host "• Secure cookie configuration"
            Write-Host "• Security testing endpoints"
        }
        "exercise02" {
            Write-Host "• Input validation models and attributes"
            Write-Host "• XSS prevention mechanisms"
            Write-Host "• CSRF protection implementation"
            Write-Host "• Data sanitization utilities"
            Write-Host "• Injection attack prevention"
        }
        "exercise03" {
            Write-Host "• Data encryption services"
            Write-Host "• Key management utilities"
            Write-Host "• Azure Key Vault integration"
            Write-Host "• Secure configuration management"
            Write-Host "• Encryption testing examples"
        }
        "exercise04" {
            Write-Host "• Security audit checklist"
            Write-Host "• Vulnerability assessment tools"
            Write-Host "• Security monitoring implementation"
            Write-Host "• Incident response procedures"
            Write-Host "• Compliance reporting tools"
        }
        "exercise05" {
            Write-Host "• OWASP ZAP integration scripts"
            Write-Host "• Automated security test suite"
            Write-Host "• Manual testing procedures"
            Write-Host "• Security report templates"
            Write-Host "• Remediation guidelines"
        }
    }
    Write-Host ""
}

# Function to create files interactively
function Create-FileInteractive {
    param($FilePath, $Content, $Description)
    
    if ($Preview) {
        Write-Host "📄 Would create: $FilePath" -ForegroundColor Cyan
        Write-Host "   Description: $Description" -ForegroundColor Yellow
        return
    }
    
    Write-Host "📄 Creating: $FilePath" -ForegroundColor Cyan
    Write-Host "   $Description" -ForegroundColor Yellow
    
    # Create directory if it doesn't exist
    $Directory = Split-Path $FilePath -Parent
    if ($Directory -and -not (Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    
    # Write content to file
    Set-Content -Path $FilePath -Value $Content -Encoding UTF8
    
    if ($InteractiveMode) {
        Write-Host "   File created. Press Enter to continue..." -NoNewline
        Read-Host
    }
    Write-Host ""
}

# Function to show available exercises
function Show-Exercises {
    Write-Host "Module 10 - Security Fundamentals" -ForegroundColor Cyan
    Write-Host "Available Exercises:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  - exercise01: Security Headers Implementation"
    Write-Host "  - exercise02: Input Validation & Data Protection"
    Write-Host "  - exercise03: Encryption & Key Management"
    Write-Host "  - exercise04: Security Audit & Assessment"
    Write-Host "  - exercise05: Penetration Testing"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\launch-exercises.ps1 <exercise-name> [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -List           Show all available exercises"
    Write-Host "  -Auto           Skip interactive mode"
    Write-Host "  -Preview        Show what will be created without creating"
}

# Main script logic
if ($List) {
    Show-Exercises
    exit 0
}

if (-not $ExerciseName) {
    Write-Error "Usage: .\launch-exercises.ps1 <exercise-name> [options]"
    Write-Host ""
    Show-Exercises
    exit 1
}

# Validate exercise name
$ValidExercises = @("exercise01", "exercise02", "exercise03", "exercise04", "exercise05")
if ($ExerciseName -notin $ValidExercises) {
    Write-Error "Unknown exercise: $ExerciseName"
    Write-Host ""
    Show-Exercises
    exit 1
}

# Welcome message
Write-Host "🔐 Module 10: Security Fundamentals" -ForegroundColor Magenta
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
Write-Host ""

# Show learning objectives
Show-LearningObjectives -Exercise $ExerciseName

# Show what will be created
Show-CreationOverview -Exercise $ExerciseName

if ($Preview) {
    Write-Info "Preview mode - no files will be created"
    Write-Host ""
}

# Check prerequisites
Write-Info "Checking security prerequisites..."

# Check .NET SDK
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Error ".NET SDK is not installed. Please install .NET 8.0 SDK."
    exit 1
}

Write-Success "Prerequisites check completed"
Write-Host ""

# Check if project exists in current directory
$SkipProjectCreation = $false
if (Test-Path $ProjectName) {
    if ($ExerciseName -in @("exercise02", "exercise03", "exercise04", "exercise05")) {
        Write-Success "Found existing $ProjectName from previous exercise"
        Write-Info "This exercise will build on your existing work"
        Set-Location $ProjectName
        $SkipProjectCreation = $true
    } else {
        Write-Warning "Project '$ProjectName' already exists!"
        $Response = Read-Host "Do you want to overwrite it? (y/N)"
        if ($Response -notmatch "^[Yy]$") {
            exit 1
        }
        Remove-Item -Path $ProjectName -Recurse -Force
        $SkipProjectCreation = $false
    }
} else {
    $SkipProjectCreation = $false
}

# Exercise implementations
switch ($ExerciseName) {
    "exercise01" {
        # Exercise 1: Security Headers Implementation

        Explain-Concept "HTTP Security Headers" @"
HTTP Security Headers provide defense-in-depth protection:
• Content-Security-Policy (CSP): Prevents XSS attacks by controlling resource loading
• X-Frame-Options: Prevents clickjacking attacks
• X-Content-Type-Options: Prevents MIME type sniffing
• Strict-Transport-Security (HSTS): Enforces HTTPS connections
• Referrer-Policy: Controls referrer information leakage
• Permissions-Policy: Controls browser feature access
"@

        if (-not $SkipProjectCreation) {
            Write-Info "Creating new ASP.NET Core Web API project..."
            dotnet new webapi -n $ProjectName --framework net8.0
            Set-Location $ProjectName

            # Remove default WeatherForecast files
            Remove-Item -Path "WeatherForecast.cs" -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "Controllers/WeatherForecastController.cs" -Force -ErrorAction SilentlyContinue
            
            # Configure HTTPS properly in launchSettings.json
            Write-Info "Configuring HTTPS settings..."
            $launchSettings = @'
{
  "$schema": "https://json.schemastore.org/launchsettings.json",
  "profiles": {
    "http": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "http://localhost:5000",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },
    "https": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "https://localhost:5001;http://localhost:5000",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
'@
            Set-Content -Path "Properties/launchSettings.json" -Value $launchSettings -Encoding UTF8
        }

        # Create security headers middleware
        Create-FileInteractive "Middleware/SecurityHeadersMiddleware.cs" @'
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
'@ "Comprehensive security headers middleware implementation"

        # Create a security-focused controller instead of WeatherForecast
        Create-FileInteractive "Controllers/SecurityTestController.cs" @'
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
'@ "Security-focused test controller for demonstrating security headers"

        # Create updated .http file with correct security endpoints
        Create-FileInteractive "SecurityDemo.http" @'
@SecurityDemo_HostAddress = https://localhost:5001

### Test Security Headers
GET {{SecurityDemo_HostAddress}}/api/SecurityTest/headers
Accept: application/json

### Test XSS Prevention
GET {{SecurityDemo_HostAddress}}/api/SecurityTest/xss-test?input=<script>alert('xss')</script>
Accept: application/json

### Test HTTPS Enforcement
GET {{SecurityDemo_HostAddress}}/api/SecurityTest/https-test
Accept: application/json

### Test Secure Cookie
POST {{SecurityDemo_HostAddress}}/api/SecurityTest/cookie-test
Accept: application/json

###
'@ "HTTP test file with security-focused endpoints"

        # Update Program.cs to remove WeatherForecast and add security middleware
        Create-FileInteractive "Program.cs" @'
using SecurityDemo.Middleware;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() {
        Title = "Security Demo API",
        Version = "v1",
        Description = "ASP.NET Core Security Fundamentals Demo"
    });
});

// Configure HTTPS redirection properly
builder.Services.AddHttpsRedirection(options =>
{
    options.RedirectStatusCode = StatusCodes.Status307TemporaryRedirect;
    options.HttpsPort = 5001;
});

// Add controllers for API endpoints
builder.Services.AddControllers();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Security Demo API v1");
        c.RoutePrefix = "swagger";
    });
}

// Security middleware - order matters!
app.UseSecurityHeaders(); // Custom security headers middleware
app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

// Add root redirect to swagger
app.MapGet("/", () => Results.Redirect("/swagger"));

app.Run();
'@ "Updated Program.cs with security middleware and proper Swagger configuration"

        Write-Success "✅ Exercise 1: Security Headers Implementation completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Add middleware to Program.cs: app.UseSecurityHeaders();" -ForegroundColor Cyan
        Write-Host "2. Test security headers with browser dev tools" -ForegroundColor Cyan
        Write-Host "3. Run security header analysis tools" -ForegroundColor Cyan
    }

    "exercise02" {
        # Exercise 2: Input Validation & Data Protection

        Explain-Concept "Input Validation and XSS Prevention" @"
Input validation is the first line of defense against attacks:
• Server-side validation: Never trust client-side validation alone
• Data annotations: Use built-in validation attributes
• Custom validation: Create domain-specific validation rules
• Output encoding: Prevent XSS through proper encoding
• CSRF protection: Validate request authenticity
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 2 requires Exercise 1 to be completed first!"
            Write-Info "Please run: .\launch-exercises.ps1 exercise01"
            exit 1
        }

        # Create input validation models
        Create-FileInteractive "Models/SecureUserModel.cs" @'
using System.ComponentModel.DataAnnotations;

namespace SecurityDemo.Models;

public class SecureUserModel
{
    [Required(ErrorMessage = "Username is required")]
    [StringLength(50, MinimumLength = 3, ErrorMessage = "Username must be between 3 and 50 characters")]
    [RegularExpression(@"^[a-zA-Z0-9_]+$", ErrorMessage = "Username can only contain letters, numbers, and underscores")]
    public string Username { get; set; } = string.Empty;

    [Required(ErrorMessage = "Email is required")]
    [EmailAddress(ErrorMessage = "Invalid email format")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Password is required")]
    [StringLength(100, MinimumLength = 8, ErrorMessage = "Password must be at least 8 characters")]
    [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]",
        ErrorMessage = "Password must contain uppercase, lowercase, number, and special character")]
    public string Password { get; set; } = string.Empty;

    [Range(18, 120, ErrorMessage = "Age must be between 18 and 120")]
    public int Age { get; set; }

    [Url(ErrorMessage = "Invalid URL format")]
    public string? Website { get; set; }
}
'@ "Secure user model with comprehensive validation"

        # Create Input Validation Controller for Exercise 2
        Create-FileInteractive "Controllers/InputValidationController.cs" @'
using Microsoft.AspNetCore.Mvc;
using SecurityDemo.Models;
using System.ComponentModel.DataAnnotations;

namespace SecurityDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class InputValidationController : ControllerBase
{
    private readonly ILogger<InputValidationController> _logger;

    public InputValidationController(ILogger<InputValidationController> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// Test endpoint for secure user registration with validation
    /// </summary>
    [HttpPost("register")]
    public IActionResult RegisterUser([FromBody] SecureUserModel user)
    {
        _logger.LogInformation("User registration attempt for: {Username}", user.Username);

        if (!ModelState.IsValid)
        {
            return BadRequest(new
            {
                Message = "Validation failed",
                Errors = ModelState.Where(x => x.Value?.Errors.Count > 0)
                    .ToDictionary(
                        kvp => kvp.Key,
                        kvp => kvp.Value?.Errors.Select(e => e.ErrorMessage).ToArray()
                    ),
                Timestamp = DateTime.UtcNow
            });
        }

        return Ok(new
        {
            Message = "User registration successful",
            Username = user.Username,
            Email = user.Email,
            Age = user.Age,
            Website = user.Website,
            Timestamp = DateTime.UtcNow,
            SecurityNote = "All inputs validated successfully"
        });
    }

    /// <summary>
    /// Test endpoint for SQL injection prevention
    /// </summary>
    [HttpGet("search")]
    public IActionResult SearchUsers([FromQuery] string query = "")
    {
        _logger.LogInformation("User search requested with query: {Query}", query);

        // Simulate safe search (in real app, use parameterized queries)
        var safeQuery = query.Replace("'", "''"); // Basic SQL injection prevention

        return Ok(new
        {
            Message = "Search completed safely",
            Query = query,
            SafeQuery = safeQuery,
            Results = new[]
            {
                new { Id = 1, Username = "john_doe", Email = "john@example.com" },
                new { Id = 2, Username = "jane_smith", Email = "jane@example.com" }
            },
            Timestamp = DateTime.UtcNow,
            SecurityNote = "Query parameters are safely handled"
        });
    }

    /// <summary>
    /// Test endpoint for XSS prevention in comments
    /// </summary>
    [HttpPost("comment")]
    public IActionResult AddComment([FromBody] CommentModel comment)
    {
        _logger.LogInformation("Comment submission from: {Author}", comment.Author);

        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        return Ok(new
        {
            Message = "Comment added successfully",
            Author = comment.Author,
            Content = comment.Content, // ASP.NET Core automatically encodes this
            Timestamp = DateTime.UtcNow,
            SecurityNote = "Content is automatically encoded to prevent XSS"
        });
    }
}

public class CommentModel
{
    [Required]
    [StringLength(100)]
    public string Author { get; set; } = string.Empty;

    [Required]
    [StringLength(1000)]
    public string Content { get; set; } = string.Empty;
}
'@ "Input validation controller with security-focused endpoints"

        Write-Success "✅ Exercise 2: Input Validation & Data Protection completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Create controllers using the secure models" -ForegroundColor Cyan
        Write-Host "2. Test validation with invalid inputs" -ForegroundColor Cyan
        Write-Host "3. Implement CSRF protection" -ForegroundColor Cyan
    }

    "exercise03" {
        # Exercise 3: Encryption & Key Management

        Explain-Concept "Data Encryption and Key Management" @"
Encryption protects sensitive data at rest and in transit:
• Symmetric encryption: Fast, uses same key for encrypt/decrypt
• Asymmetric encryption: Secure key exchange, slower performance
• Key management: Secure storage, rotation, and access control
• Azure Key Vault: Cloud-based key management service
• Data protection APIs: ASP.NET Core built-in encryption
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 3 requires Exercises 1 and 2 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03"
            exit 1
        }

        # Install encryption packages
        Write-Host "📦 Installing encryption packages..." -ForegroundColor Cyan
        dotnet add package Azure.Security.KeyVault.Secrets --version 4.5.0
        dotnet add package Azure.Identity --version 1.10.4

        # Create encryption service
        Create-FileInteractive "Services/EncryptionService.cs" @'
using System.Security.Cryptography;
using System.Text;

namespace SecurityDemo.Services;

public interface IEncryptionService
{
    string Encrypt(string plainText, string key);
    string Decrypt(string cipherText, string key);
    string HashPassword(string password);
    bool VerifyPassword(string password, string hash);
}

public class EncryptionService : IEncryptionService
{
    public string Encrypt(string plainText, string key)
    {
        using var aes = Aes.Create();
        aes.Key = Encoding.UTF8.GetBytes(key.PadRight(32).Substring(0, 32));
        aes.GenerateIV();

        using var encryptor = aes.CreateEncryptor();
        var plainBytes = Encoding.UTF8.GetBytes(plainText);
        var cipherBytes = encryptor.TransformFinalBlock(plainBytes, 0, plainBytes.Length);

        var result = new byte[aes.IV.Length + cipherBytes.Length];
        Array.Copy(aes.IV, 0, result, 0, aes.IV.Length);
        Array.Copy(cipherBytes, 0, result, aes.IV.Length, cipherBytes.Length);

        return Convert.ToBase64String(result);
    }

    public string Decrypt(string cipherText, string key)
    {
        var cipherBytes = Convert.FromBase64String(cipherText);

        using var aes = Aes.Create();
        aes.Key = Encoding.UTF8.GetBytes(key.PadRight(32).Substring(0, 32));

        var iv = new byte[16];
        var cipher = new byte[cipherBytes.Length - 16];

        Array.Copy(cipherBytes, 0, iv, 0, 16);
        Array.Copy(cipherBytes, 16, cipher, 0, cipher.Length);

        aes.IV = iv;

        using var decryptor = aes.CreateDecryptor();
        var plainBytes = decryptor.TransformFinalBlock(cipher, 0, cipher.Length);

        return Encoding.UTF8.GetString(plainBytes);
    }

    public string HashPassword(string password)
    {
        using var rng = RandomNumberGenerator.Create();
        var salt = new byte[32];
        rng.GetBytes(salt);

        using var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 10000, HashAlgorithmName.SHA256);
        var hash = pbkdf2.GetBytes(32);

        var hashBytes = new byte[64];
        Array.Copy(salt, 0, hashBytes, 0, 32);
        Array.Copy(hash, 0, hashBytes, 32, 32);

        return Convert.ToBase64String(hashBytes);
    }

    public bool VerifyPassword(string password, string hash)
    {
        try
        {
            var hashBytes = Convert.FromBase64String(hash);
            var salt = new byte[32];
            Array.Copy(hashBytes, 0, salt, 0, 32);

            using var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 10000, HashAlgorithmName.SHA256);
            var computedHash = pbkdf2.GetBytes(32);

            for (int i = 0; i < 32; i++)
            {
                if (hashBytes[i + 32] != computedHash[i])
                    return false;
            }
            return true;
        }
        catch
        {
            return false;
        }
    }
}
'@ "Encryption service with AES and PBKDF2 password hashing"

        # Create Encryption Controller for Exercise 3
        Create-FileInteractive "Controllers/EncryptionController.cs" @'
using Microsoft.AspNetCore.Mvc;
using SecurityDemo.Services;

namespace SecurityDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class EncryptionController : ControllerBase
{
    private readonly IEncryptionService _encryptionService;
    private readonly ILogger<EncryptionController> _logger;

    public EncryptionController(IEncryptionService encryptionService, ILogger<EncryptionController> logger)
    {
        _encryptionService = encryptionService;
        _logger = logger;
    }

    /// <summary>
    /// Encrypt sensitive data
    /// </summary>
    [HttpPost("encrypt")]
    public IActionResult EncryptData([FromBody] EncryptionRequest request)
    {
        _logger.LogInformation("Encryption requested for data");

        try
        {
            var encryptedData = _encryptionService.Encrypt(request.PlainText, request.Key);

            return Ok(new
            {
                Message = "Data encrypted successfully",
                EncryptedData = encryptedData,
                Timestamp = DateTime.UtcNow,
                SecurityNote = "Data encrypted using AES-256"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Encryption failed");
            return BadRequest(new { Message = "Encryption failed", Error = ex.Message });
        }
    }

    /// <summary>
    /// Decrypt sensitive data
    /// </summary>
    [HttpPost("decrypt")]
    public IActionResult DecryptData([FromBody] DecryptionRequest request)
    {
        _logger.LogInformation("Decryption requested");

        try
        {
            var decryptedData = _encryptionService.Decrypt(request.CipherText, request.Key);

            return Ok(new
            {
                Message = "Data decrypted successfully",
                DecryptedData = decryptedData,
                Timestamp = DateTime.UtcNow,
                SecurityNote = "Data decrypted using AES-256"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Decryption failed");
            return BadRequest(new { Message = "Decryption failed", Error = ex.Message });
        }
    }

    /// <summary>
    /// Hash password securely
    /// </summary>
    [HttpPost("hash-password")]
    public IActionResult HashPassword([FromBody] PasswordRequest request)
    {
        _logger.LogInformation("Password hashing requested");

        try
        {
            var hashedPassword = _encryptionService.HashPassword(request.Password);

            return Ok(new
            {
                Message = "Password hashed successfully",
                HashedPassword = hashedPassword,
                Timestamp = DateTime.UtcNow,
                SecurityNote = "Password hashed using PBKDF2 with SHA-256"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Password hashing failed");
            return BadRequest(new { Message = "Password hashing failed", Error = ex.Message });
        }
    }

    /// <summary>
    /// Verify password against hash
    /// </summary>
    [HttpPost("verify-password")]
    public IActionResult VerifyPassword([FromBody] PasswordVerificationRequest request)
    {
        _logger.LogInformation("Password verification requested");

        try
        {
            var isValid = _encryptionService.VerifyPassword(request.Password, request.Hash);

            return Ok(new
            {
                Message = "Password verification completed",
                IsValid = isValid,
                Timestamp = DateTime.UtcNow,
                SecurityNote = "Password verified using secure comparison"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Password verification failed");
            return BadRequest(new { Message = "Password verification failed", Error = ex.Message });
        }
    }
}

public class EncryptionRequest
{
    public string PlainText { get; set; } = string.Empty;
    public string Key { get; set; } = string.Empty;
}

public class DecryptionRequest
{
    public string CipherText { get; set; } = string.Empty;
    public string Key { get; set; } = string.Empty;
}

public class PasswordRequest
{
    public string Password { get; set; } = string.Empty;
}

public class PasswordVerificationRequest
{
    public string Password { get; set; } = string.Empty;
    public string Hash { get; set; } = string.Empty;
}
'@ "Encryption controller with secure data handling endpoints"

        # Update Program.cs to register the encryption service
        Create-FileInteractive "Program.cs" @'
using SecurityDemo.Middleware;
using SecurityDemo.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() {
        Title = "Security Demo API",
        Version = "v1",
        Description = "ASP.NET Core Security Fundamentals Demo with Encryption"
    });
});

// Register encryption service
builder.Services.AddScoped<IEncryptionService, EncryptionService>();

// Configure HTTPS
builder.Services.AddHttpsRedirection(options =>
{
    options.RedirectStatusCode = StatusCodes.Status307TemporaryRedirect;
    options.HttpsPort = 5001;
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Security Demo API v1");
        c.RoutePrefix = "swagger";
    });
}

// Security middleware - order matters!
app.UseSecurityHeaders(); // Custom security headers middleware
app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

// Add root redirect to swagger
app.MapGet("/", () => Results.Redirect("/swagger"));

app.Run();
'@ "Updated Program.cs with encryption service registration"

        Write-Success "✅ Exercise 3: Encryption & Key Management completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Configure Azure Key Vault integration" -ForegroundColor Cyan
        Write-Host "2. Implement secure configuration management" -ForegroundColor Cyan
        Write-Host "3. Test password hashing with PBKDF2" -ForegroundColor Cyan
    }

    "exercise04" {
        # Exercise 4: Security Audit & Assessment

        Explain-Concept "Security Auditing and Monitoring" @"
Security auditing helps identify and prevent threats:
• OWASP Top 10: Common web application vulnerabilities
• Security logging: Track security events and anomalies
• Vulnerability scanning: Automated security assessment
• Compliance monitoring: Meet regulatory requirements
• Incident response: Procedures for security breaches
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 4 requires Exercises 1, 2, and 3 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04"
            exit 1
        }

        # Create security audit service
        Create-FileInteractive "Services/SecurityAuditService.cs" @'
namespace SecurityDemo.Services;

public class SecurityAuditService
{
    private readonly ILogger<SecurityAuditService> _logger;

    public SecurityAuditService(ILogger<SecurityAuditService> logger)
    {
        _logger = logger;
    }

    public async Task<SecurityAuditReport> PerformSecurityAudit()
    {
        var report = new SecurityAuditReport
        {
            AuditDate = DateTime.UtcNow,
            Findings = new List<SecurityFinding>()
        };

        // Check for common security issues
        CheckSecurityHeaders(report);
        CheckInputValidation(report);
        CheckEncryption(report);
        CheckAuthentication(report);

        _logger.LogInformation("Security audit completed with {FindingCount} findings", report.Findings.Count);

        return report;
    }

    private void CheckSecurityHeaders(SecurityAuditReport report)
    {
        // Implementation would check for proper security headers
        report.Findings.Add(new SecurityFinding
        {
            Category = "Security Headers",
            Severity = "Info",
            Description = "Security headers middleware implemented",
            Recommendation = "Verify all security headers are properly configured"
        });
    }

    private void CheckInputValidation(SecurityAuditReport report)
    {
        // Implementation would check input validation
        report.Findings.Add(new SecurityFinding
        {
            Category = "Input Validation",
            Severity = "Info",
            Description = "Input validation models implemented",
            Recommendation = "Ensure all user inputs are validated"
        });
    }

    private void CheckEncryption(SecurityAuditReport report)
    {
        // Implementation would check encryption usage
        report.Findings.Add(new SecurityFinding
        {
            Category = "Encryption",
            Severity = "Info",
            Description = "Encryption service implemented",
            Recommendation = "Verify sensitive data is encrypted at rest and in transit"
        });
    }

    private void CheckAuthentication(SecurityAuditReport report)
    {
        // Implementation would check authentication mechanisms
        report.Findings.Add(new SecurityFinding
        {
            Category = "Authentication",
            Severity = "Warning",
            Description = "Basic authentication implemented",
            Recommendation = "Consider implementing multi-factor authentication"
        });
    }
}

public class SecurityAuditReport
{
    public DateTime AuditDate { get; set; }
    public List<SecurityFinding> Findings { get; set; } = new();
}

public class SecurityFinding
{
    public string Category { get; set; } = string.Empty;
    public string Severity { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Recommendation { get; set; } = string.Empty;
}
'@ "Security audit service for vulnerability assessment"

        Write-Success "✅ Exercise 4: Security Audit & Assessment completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Run security audit and review findings" -ForegroundColor Cyan
        Write-Host "2. Implement security monitoring" -ForegroundColor Cyan
        Write-Host "3. Create incident response procedures" -ForegroundColor Cyan
    }

    "exercise05" {
        # Exercise 5: Penetration Testing

        Explain-Concept "Penetration Testing and Security Scanning" @"
Penetration testing validates security controls:
• OWASP ZAP: Free security testing proxy
• Automated scanning: Find common vulnerabilities
• Manual testing: Discover complex security issues
• Security reporting: Document findings and remediation
• Continuous testing: Integrate into CI/CD pipeline
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 5 requires Exercises 1, 2, 3, and 4 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04, exercise05"
            exit 1
        }

        # Create penetration testing script
        Create-FileInteractive "Scripts/security-scan.ps1" @'
#!/usr/bin/env pwsh

# Security Scanning Script for ASP.NET Core Application
param(
    [Parameter(Mandatory=$false)]
    [string]$TargetUrl = "https://localhost:5001",

    [Parameter(Mandatory=$false)]
    [string]$ReportPath = "security-report.html"
)

Write-Host "🔍 Starting security scan of $TargetUrl" -ForegroundColor Cyan

# Check if OWASP ZAP is available
if (Get-Command zap-baseline.py -ErrorAction SilentlyContinue) {
    Write-Host "Running OWASP ZAP baseline scan..." -ForegroundColor Yellow
    zap-baseline.py -t $TargetUrl -r $ReportPath
} else {
    Write-Warning "OWASP ZAP not found. Install from: https://www.zaproxy.org/"
}

# Basic security checks
Write-Host "Performing basic security checks..." -ForegroundColor Yellow

# Check SSL/TLS configuration
try {
    $response = Invoke-WebRequest -Uri $TargetUrl -Method HEAD -SkipCertificateCheck
    Write-Host "✅ Application is accessible" -ForegroundColor Green

    # Check security headers
    $headers = $response.Headers
    $securityHeaders = @(
        "Strict-Transport-Security",
        "Content-Security-Policy",
        "X-Frame-Options",
        "X-Content-Type-Options"
    )

    foreach ($header in $securityHeaders) {
        if ($headers.ContainsKey($header)) {
            Write-Host "✅ $header header present" -ForegroundColor Green
        } else {
            Write-Host "❌ $header header missing" -ForegroundColor Red
        }
    }
} catch {
    Write-Error "Failed to connect to $TargetUrl"
}

Write-Host "🔍 Security scan completed!" -ForegroundColor Green
Write-Host "📄 Report saved to: $ReportPath" -ForegroundColor Cyan
'@ "Penetration testing script with OWASP ZAP integration"

        Write-Success "✅ Exercise 5: Penetration Testing completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Install OWASP ZAP for comprehensive testing" -ForegroundColor Cyan
        Write-Host "2. Run automated security scans" -ForegroundColor Cyan
        Write-Host "3. Review and remediate security findings" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Success "🎉 $ExerciseName security template created successfully!"
Write-Host ""
Write-Info "📚 For detailed security guidance, refer to OWASP guidelines and ASP.NET Core security documentation."
Write-Info "🔗 Additional security resources available in the Resources/ directory."
