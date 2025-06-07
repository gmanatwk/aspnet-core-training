#!/bin/bash

# Module 10: Security Fundamentals - Interactive Exercise Launcher
# This script provides guided, hands-on exercises for ASP.NET Core security implementation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="SecurityDemo"
INTERACTIVE_MODE=true
SKIP_PROJECT_CREATION=false

# Function to display colored output
echo_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
echo_success() { echo -e "${GREEN}✅ $1${NC}"; }
echo_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
echo_error() { echo -e "${RED}❌ $1${NC}"; }

# Function to pause for user interaction
pause_for_user() {
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -n "Press Enter to continue..."
        read -r
        echo ""
    fi
}

# Function to explain concepts interactively
explain_concept() {
    local concept=$1
    local explanation=$2
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}🔐 SECURITY CONCEPT: $concept${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}$explanation${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    pause_for_user
}

# Function to show learning objectives
show_learning_objectives() {
    local exercise=$1
    
    echo -e "${BLUE}🎯 Security Learning Objectives for $exercise:${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${CYAN}Security Headers Implementation:${NC}"
            echo "  🛡️  1. Configure comprehensive HTTP security headers"
            echo "  🛡️  2. Implement Content Security Policy (CSP)"
            echo "  🛡️  3. Set up HTTPS enforcement and HSTS"
            echo "  🛡️  4. Configure secure cookie settings"
            echo ""
            echo -e "${YELLOW}Security concepts:${NC}"
            echo "  • Defense in depth through HTTP headers"
            echo "  • XSS prevention with CSP"
            echo "  • Transport security with HTTPS/HSTS"
            echo "  • Session security with secure cookies"
            ;;
        "exercise02")
            echo -e "${CYAN}Input Validation & Data Protection:${NC}"
            echo "  🛡️  1. Implement robust input validation"
            echo "  🛡️  2. Prevent XSS and injection attacks"
            echo "  🛡️  3. Configure CSRF protection"
            echo "  🛡️  4. Data sanitization techniques"
            echo ""
            echo -e "${YELLOW}Security concepts:${NC}"
            echo "  • Input validation strategies"
            echo "  • Output encoding and sanitization"
            echo "  • CSRF token implementation"
            echo "  • SQL injection prevention"
            ;;
        "exercise03")
            echo -e "${CYAN}Encryption & Key Management:${NC}"
            echo "  🛡️  1. Implement data encryption at rest"
            echo "  🛡️  2. Configure encryption in transit"
            echo "  🛡️  3. Secure key management practices"
            echo "  🛡️  4. Azure Key Vault integration"
            echo ""
            echo -e "${YELLOW}Security concepts:${NC}"
            echo "  • Symmetric and asymmetric encryption"
            echo "  • Key rotation and management"
            echo "  • Secure secret storage"
            echo "  • Digital signatures and hashing"
            ;;
        "exercise04")
            echo -e "${CYAN}Security Audit & Assessment:${NC}"
            echo "  🛡️  1. Perform comprehensive security audit"
            echo "  🛡️  2. Identify security vulnerabilities"
            echo "  🛡️  3. Implement security monitoring"
            echo "  🛡️  4. Create incident response procedures"
            echo ""
            echo -e "${YELLOW}Security concepts:${NC}"
            echo "  • OWASP Top 10 assessment"
            echo "  • Vulnerability scanning"
            echo "  • Security logging and monitoring"
            echo "  • Compliance and governance"
            ;;
        "exercise05")
            echo -e "${CYAN}Penetration Testing:${NC}"
            echo "  🛡️  1. Basic penetration testing with OWASP ZAP"
            echo "  🛡️  2. Automated security scanning"
            echo "  🛡️  3. Manual security testing techniques"
            echo "  🛡️  4. Security report generation"
            echo ""
            echo -e "${YELLOW}Security concepts:${NC}"
            echo "  • Ethical hacking principles"
            echo "  • Automated vulnerability scanning"
            echo "  • Manual testing methodologies"
            echo "  • Security reporting and remediation"
            ;;
    esac
    echo ""
}

# Function to show what will be created
show_creation_overview() {
    local exercise=$1
    
    echo -e "${CYAN}📋 Security Components for $exercise:${NC}"
    
    case $exercise in
        "exercise01")
            echo "• Security headers middleware"
            echo "• Content Security Policy configuration"
            echo "• HTTPS redirection and HSTS setup"
            echo "• Secure cookie configuration"
            echo "• Security testing endpoints"
            ;;
        "exercise02")
            echo "• Input validation models and attributes"
            echo "• XSS prevention mechanisms"
            echo "• CSRF protection implementation"
            echo "• Data sanitization utilities"
            echo "• Injection attack prevention"
            ;;
        "exercise03")
            echo "• Data encryption services"
            echo "• Key management utilities"
            echo "• Azure Key Vault integration"
            echo "• Secure configuration management"
            echo "• Encryption testing examples"
            ;;
        "exercise04")
            echo "• Security audit checklist"
            echo "• Vulnerability assessment tools"
            echo "• Security monitoring implementation"
            echo "• Incident response procedures"
            echo "• Compliance reporting tools"
            ;;
        "exercise05")
            echo "• OWASP ZAP integration scripts"
            echo "• Automated security test suite"
            echo "• Manual testing procedures"
            echo "• Security report templates"
            echo "• Remediation guidelines"
            ;;
    esac
    echo ""
}

# Function to create files interactively
create_file_interactive() {
    local file_path=$1
    local content=$2
    local description=$3
    
    if [ "$PREVIEW_ONLY" = true ]; then
        echo -e "${CYAN}📄 Would create: $file_path${NC}"
        echo -e "${YELLOW}   Description: $description${NC}"
        return
    fi
    
    echo -e "${CYAN}📄 Creating: $file_path${NC}"
    echo -e "${YELLOW}   $description${NC}"
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$file_path")"
    
    # Write content to file
    echo "$content" > "$file_path"
    
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -n "   File created. Press Enter to continue..."
        read -r
    fi
    echo ""
}

# Function to show available exercises
show_exercises() {
    echo -e "${CYAN}Module 10 - Security Fundamentals${NC}"
    echo -e "${CYAN}Available Exercises:${NC}"
    echo ""
    echo "  - exercise01: Security Headers Implementation"
    echo "  - exercise02: Input Validation & Data Protection"
    echo "  - exercise03: Encryption & Key Management"
    echo "  - exercise04: Security Audit & Assessment"
    echo "  - exercise05: Penetration Testing"
    echo ""
    echo "Usage:"
    echo "  ./launch-exercises.sh <exercise-name> [options]"
    echo ""
    echo "Options:"
    echo "  --list          Show all available exercises"
    echo "  --auto          Skip interactive mode"
    echo "  --preview       Show what will be created without creating"
}

# Main script starts here
if [ $# -eq 0 ]; then
    echo_error "Usage: $0 <exercise-name> [options]"
    echo ""
    show_exercises
    exit 1
fi

# Handle --list option
if [ "$1" == "--list" ]; then
    show_exercises
    exit 0
fi

EXERCISE_NAME=$1
PREVIEW_ONLY=false

# Parse options
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            INTERACTIVE_MODE=false
            shift
            ;;
        --preview)
            PREVIEW_ONLY=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Validate exercise name
case $EXERCISE_NAME in
    "exercise01"|"exercise02"|"exercise03"|"exercise04"|"exercise05")
        ;;
    *)
        echo_error "Unknown exercise: $EXERCISE_NAME"
        echo ""
        show_exercises
        exit 1
        ;;
esac

# Welcome message
echo -e "${MAGENTA}🔐 Module 10: Security Fundamentals${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show learning objectives
show_learning_objectives $EXERCISE_NAME

# Show what will be created
show_creation_overview $EXERCISE_NAME

if [ "$PREVIEW_ONLY" = true ]; then
    echo_info "Preview mode - no files will be created"
    echo ""
fi

# Check prerequisites
echo_info "Checking security prerequisites..."

# Check .NET SDK
if ! command -v dotnet &> /dev/null; then
    echo_error ".NET SDK is not installed. Please install .NET 8.0 SDK."
    exit 1
fi

echo_success "Prerequisites check completed"
echo ""

# Check if project exists in current directory
if [ -d "$PROJECT_NAME" ]; then
    if [[ $EXERCISE_NAME == "exercise02" ]] || [[ $EXERCISE_NAME == "exercise03" ]] || [[ $EXERCISE_NAME == "exercise04" ]] || [[ $EXERCISE_NAME == "exercise05" ]]; then
        echo_success "Found existing $PROJECT_NAME from previous exercise"
        echo_info "This exercise will build on your existing work"
        cd "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=true
    else
        echo_warning "Project '$PROJECT_NAME' already exists!"
        echo -n "Do you want to overwrite it? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            exit 1
        fi
        rm -rf "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=false
    fi
else
    SKIP_PROJECT_CREATION=false
fi

# Exercise implementations
if [[ $EXERCISE_NAME == "exercise01" ]]; then
    # Exercise 1: Security Headers Implementation

    explain_concept "HTTP Security Headers" \
"HTTP Security Headers provide defense-in-depth protection:
• Content-Security-Policy (CSP): Prevents XSS attacks by controlling resource loading
• X-Frame-Options: Prevents clickjacking attacks
• X-Content-Type-Options: Prevents MIME type sniffing
• Strict-Transport-Security (HSTS): Enforces HTTPS connections
• Referrer-Policy: Controls referrer information leakage
• Permissions-Policy: Controls browser feature access"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_info "Creating new ASP.NET Core Web API project..."
        dotnet new webapi -n "$PROJECT_NAME" --framework net8.0
        cd "$PROJECT_NAME"
    fi

    # Create security headers middleware
    create_file_interactive "Middleware/SecurityHeadersMiddleware.cs" \
'using Microsoft.Extensions.Primitives;

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
            "default-src '\''self'\''; " +
            "script-src '\''self'\'' '\''unsafe-inline'\'' '\''unsafe-eval'\'' https://cdnjs.cloudflare.com; " +
            "style-src '\''self'\'' '\''unsafe-inline'\'' https://fonts.googleapis.com; " +
            "font-src '\''self'\'' https://fonts.gstatic.com; " +
            "img-src '\''self'\'' data: https:; " +
            "connect-src '\''self'\''; " +
            "frame-ancestors '\''none'\''; " +
            "base-uri '\''self'\''; " +
            "form-action '\''self'\''");

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
}' \
"Comprehensive security headers middleware implementation"

    # Create security test controller
    create_file_interactive "Controllers/SecurityTestController.cs" \
'using Microsoft.AspNetCore.Mvc;

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
}' \
"Security testing controller with various security verification endpoints"

elif [[ $EXERCISE_NAME == "exercise02" ]]; then
    # Exercise 2: Input Validation & Data Protection

    explain_concept "Input Validation & Data Protection" \
"Input Validation & Data Protection Strategies:
• Input Validation: Validate all user inputs at multiple layers
• Output Encoding: Encode data for safe display
• CSRF Protection: Prevent cross-site request forgery
• SQL Injection Prevention: Use parameterized queries
• XSS Prevention: Sanitize and encode user content"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 2 requires Exercise 1 to be completed first!"
        echo_info "Please run: ./launch-exercises.sh exercise01"
        exit 1
    fi

    # Add required packages
    dotnet add package Microsoft.AspNetCore.Mvc.DataAnnotations
    dotnet add package System.ComponentModel.Annotations

    # Create input validation models
    create_file_interactive "Models/UserInputModel.cs" \
'using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;

namespace SecurityDemo.Models;

/// <summary>
/// Model demonstrating comprehensive input validation
/// </summary>
public class UserInputModel
{
    [Required(ErrorMessage = "Name is required")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 100 characters")]
    [RegularExpression(@"^[a-zA-Z\s]+$", ErrorMessage = "Name can only contain letters and spaces")]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Email is required")]
    [EmailAddress(ErrorMessage = "Invalid email format")]
    [StringLength(255, ErrorMessage = "Email cannot exceed 255 characters")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Age is required")]
    [Range(1, 120, ErrorMessage = "Age must be between 1 and 120")]
    public int Age { get; set; }

    [Phone(ErrorMessage = "Invalid phone number format")]
    public string? PhoneNumber { get; set; }

    [Url(ErrorMessage = "Invalid URL format")]
    public string? Website { get; set; }

    [StringLength(1000, ErrorMessage = "Comments cannot exceed 1000 characters")]
    [DataType(DataType.MultilineText)]
    public string? Comments { get; set; }

    [CreditCard(ErrorMessage = "Invalid credit card format")]
    public string? CreditCardNumber { get; set; }
}

/// <summary>
/// Custom validation attribute for safe HTML content
/// </summary>
public class SafeHtmlAttribute : ValidationAttribute
{
    protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
    {
        if (value is string htmlContent && !string.IsNullOrEmpty(htmlContent))
        {
            // Check for potentially dangerous HTML tags and scripts
            var dangerousPatterns = new[]
            {
                @"<script[^>]*>.*?</script>",
                @"<iframe[^>]*>.*?</iframe>",
                @"<object[^>]*>.*?</object>",
                @"<embed[^>]*>.*?</embed>",
                @"<form[^>]*>.*?</form>",
                @"javascript:",
                @"vbscript:",
                @"onload=",
                @"onerror=",
                @"onclick="
            };

            foreach (var pattern in dangerousPatterns)
            {
                if (Regex.IsMatch(htmlContent, pattern, RegexOptions.IgnoreCase))
                {
                    return new ValidationResult("Content contains potentially dangerous HTML or scripts");
                }
            }
        }

        return ValidationResult.Success;
    }
}' \
"Comprehensive input validation models with custom validation attributes"

elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    # Exercise 3: Encryption & Key Management

    explain_concept "Encryption & Key Management" \
"Encryption & Key Management Best Practices:
• Data Protection API: ASP.NET Core built-in encryption
• Azure Key Vault: Secure cloud-based key management
• Symmetric Encryption: Fast encryption for large data
• Asymmetric Encryption: Secure key exchange and digital signatures
• Key Rotation: Regular key updates for enhanced security"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 3 requires Exercises 1 and 2 to be completed first!"
        echo_info "Please run exercises in order: exercise01, exercise02, exercise03"
        exit 1
    fi

    # Add encryption packages
    dotnet add package Azure.Security.KeyVault.Secrets
    dotnet add package Azure.Identity

    # Create encryption service
    create_file_interactive "Services/EncryptionService.cs" \
'using Microsoft.AspNetCore.DataProtection;
using System.Security.Cryptography;
using System.Text;

namespace SecurityDemo.Services;

public interface IEncryptionService
{
    string EncryptString(string plainText);
    string DecryptString(string cipherText);
    string HashPassword(string password);
    bool VerifyPassword(string password, string hash);
    string GenerateSecureToken();
}

public class EncryptionService : IEncryptionService
{
    private readonly IDataProtector _dataProtector;
    private readonly ILogger<EncryptionService> _logger;

    public EncryptionService(IDataProtectionProvider dataProtectionProvider, ILogger<EncryptionService> logger)
    {
        _dataProtector = dataProtectionProvider.CreateProtector("SecurityDemo.EncryptionService");
        _logger = logger;
    }

    public string EncryptString(string plainText)
    {
        try
        {
            return _dataProtector.Protect(plainText);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error encrypting string");
            throw;
        }
    }

    public string DecryptString(string cipherText)
    {
        try
        {
            return _dataProtector.Unprotect(cipherText);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error decrypting string");
            throw;
        }
    }

    public string HashPassword(string password)
    {
        using var rng = RandomNumberGenerator.Create();
        var salt = new byte[32];
        rng.GetBytes(salt);

        using var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 100000, HashAlgorithmName.SHA256);
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

            using var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 100000, HashAlgorithmName.SHA256);
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

    public string GenerateSecureToken()
    {
        using var rng = RandomNumberGenerator.Create();
        var tokenBytes = new byte[32];
        rng.GetBytes(tokenBytes);
        return Convert.ToBase64String(tokenBytes);
    }
}' \
"Comprehensive encryption service with password hashing and secure token generation"

elif [[ $EXERCISE_NAME == "exercise04" ]]; then
    # Exercise 4: Security Audit & Assessment

    explain_concept "Security Audit & Assessment" \
"Security Audit & Assessment Components:
• OWASP Top 10 Assessment: Check for common vulnerabilities
• Dependency Scanning: Identify vulnerable packages
• Security Logging: Monitor security events
• Compliance Checking: Ensure regulatory compliance
• Incident Response: Procedures for security incidents"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 4 requires Exercises 1, 2, and 3 to be completed first!"
        echo_info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04"
        exit 1
    fi

    # Create security audit checklist
    create_file_interactive "SECURITY_AUDIT_CHECKLIST.md" \
'# Security Audit Checklist

## OWASP Top 10 (2023) Assessment

### 1. Broken Access Control
- [ ] Proper authorization checks on all endpoints
- [ ] Role-based access control implemented
- [ ] No direct object references exposed
- [ ] Access control failures logged

### 2. Cryptographic Failures
- [ ] Data encrypted in transit (HTTPS)
- [ ] Sensitive data encrypted at rest
- [ ] Strong encryption algorithms used
- [ ] Proper key management implemented

### 3. Injection
- [ ] Parameterized queries used
- [ ] Input validation implemented
- [ ] Output encoding applied
- [ ] SQL injection testing performed

### 4. Insecure Design
- [ ] Threat modeling completed
- [ ] Security requirements defined
- [ ] Secure design patterns used
- [ ] Security architecture reviewed

### 5. Security Misconfiguration
- [ ] Security headers configured
- [ ] Default credentials changed
- [ ] Unnecessary features disabled
- [ ] Security settings documented

### 6. Vulnerable and Outdated Components
- [ ] Dependency scanning performed
- [ ] Components regularly updated
- [ ] Vulnerability monitoring active
- [ ] Patch management process defined

### 7. Identification and Authentication Failures
- [ ] Strong password policies enforced
- [ ] Multi-factor authentication implemented
- [ ] Session management secure
- [ ] Account lockout mechanisms active

### 8. Software and Data Integrity Failures
- [ ] Code signing implemented
- [ ] Integrity checks performed
- [ ] Secure CI/CD pipeline configured
- [ ] Supply chain security verified

### 9. Security Logging and Monitoring Failures
- [ ] Security events logged
- [ ] Log monitoring implemented
- [ ] Alerting configured
- [ ] Incident response procedures defined

### 10. Server-Side Request Forgery (SSRF)
- [ ] Input validation for URLs
- [ ] Network segmentation implemented
- [ ] Allowlist for external requests
- [ ] SSRF testing performed
' \
"Comprehensive OWASP Top 10 security audit checklist"

elif [[ $EXERCISE_NAME == "exercise05" ]]; then
    # Exercise 5: Penetration Testing

    explain_concept "Penetration Testing" \
"Penetration Testing Fundamentals:
• OWASP ZAP: Automated security scanning
• Manual Testing: Human-driven security assessment
• Vulnerability Assessment: Systematic security evaluation
• Security Reporting: Document findings and remediation
• Ethical Hacking: Authorized security testing"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 5 requires all previous exercises to be completed first!"
        echo_info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04, exercise05"
        exit 1
    fi

    # Create OWASP ZAP automation script
    create_file_interactive "security-scan.sh" \
'#!/bin/bash

# OWASP ZAP Automated Security Scan Script
set -e

echo "🔍 Starting OWASP ZAP Security Scan..."

# Configuration
TARGET_URL="http://localhost:5000"
ZAP_PORT="8080"
REPORT_DIR="security-reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create reports directory
mkdir -p "$REPORT_DIR"

# Check if ZAP is available
if ! command -v zap.sh &> /dev/null; then
    echo "❌ OWASP ZAP is not installed or not in PATH"
    echo "Please install OWASP ZAP from: https://www.zaproxy.org/download/"
    exit 1
fi

# Start ZAP in daemon mode
echo "🚀 Starting ZAP daemon..."
zap.sh -daemon -port $ZAP_PORT -config api.disablekey=true &
ZAP_PID=$!

# Wait for ZAP to start
echo "⏳ Waiting for ZAP to initialize..."
sleep 30

# Spider the target
echo "🕷️  Spidering target: $TARGET_URL"
curl -s "http://localhost:$ZAP_PORT/JSON/spider/action/scan/?url=$TARGET_URL" > /dev/null

# Wait for spider to complete
echo "⏳ Waiting for spider to complete..."
while [ $(curl -s "http://localhost:$ZAP_PORT/JSON/spider/view/status/" | jq -r .status) != "100" ]; do
    sleep 5
done

# Active scan
echo "🔍 Starting active security scan..."
curl -s "http://localhost:$ZAP_PORT/JSON/ascan/action/scan/?url=$TARGET_URL" > /dev/null

# Wait for active scan to complete
echo "⏳ Waiting for active scan to complete..."
while [ $(curl -s "http://localhost:$ZAP_PORT/JSON/ascan/view/status/" | jq -r .status) != "100" ]; do
    sleep 10
done

# Generate reports
echo "📊 Generating security reports..."

# HTML Report
curl -s "http://localhost:$ZAP_PORT/OTHER/core/other/htmlreport/" > "$REPORT_DIR/security_report_$TIMESTAMP.html"

# JSON Report
curl -s "http://localhost:$ZAP_PORT/JSON/core/view/alerts/" > "$REPORT_DIR/security_report_$TIMESTAMP.json"

# XML Report
curl -s "http://localhost:$ZAP_PORT/OTHER/core/other/xmlreport/" > "$REPORT_DIR/security_report_$TIMESTAMP.xml"

# Stop ZAP
echo "🛑 Stopping ZAP daemon..."
kill $ZAP_PID

echo "✅ Security scan completed!"
echo "📁 Reports saved in: $REPORT_DIR/"
echo "📊 HTML Report: $REPORT_DIR/security_report_$TIMESTAMP.html"
' \
"OWASP ZAP automated security scanning script"

    chmod +x security-scan.sh

fi

# Final completion message
echo ""
echo_success "🎉 $EXERCISE_NAME template created successfully!"
echo ""
echo_info "📋 Next steps:"

case $EXERCISE_NAME in
    "exercise01")
        echo "1. Update Program.cs to use security headers middleware"
        echo "2. Run: ${CYAN}dotnet run${NC}"
        echo "3. Test security headers: ${CYAN}curl -I https://localhost:5001/api/securitytest/headers${NC}"
        echo "4. Use browser dev tools to verify headers"
        ;;
    "exercise02")
        echo "1. Implement input validation in controllers"
        echo "2. Test validation with various inputs"
        echo "3. Verify XSS and injection prevention"
        echo "4. Review validation error messages"
        ;;
    "exercise03")
        echo "1. Configure data protection in Program.cs"
        echo "2. Test encryption and decryption methods"
        echo "3. Implement password hashing"
        echo "4. Set up Azure Key Vault integration"
        ;;
    "exercise04")
        echo "1. Review the security audit checklist"
        echo "2. Perform OWASP Top 10 assessment"
        echo "3. Document security findings"
        echo "4. Create remediation plan"
        ;;
    "exercise05")
        echo "1. Install OWASP ZAP"
        echo "2. Run: ${CYAN}./security-scan.sh${NC}"
        echo "3. Review security scan reports"
        echo "4. Address identified vulnerabilities"
        ;;
esac

echo ""
echo_info "📚 For detailed instructions, refer to the exercise guide files created."
echo_info "🔗 Additional security resources available in the Resources/ directory."
