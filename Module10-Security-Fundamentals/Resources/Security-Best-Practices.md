# Security Best Practices for ASP.NET Core Development

## 🎯 Introduction

This guide provides comprehensive security best practices for developing secure ASP.NET Core applications. It covers everything from development practices to deployment and maintenance.

## 🏗️ Secure Development Lifecycle (SDL)

### Phase 1: Planning & Design
**Security should be considered from the very beginning of your project.**

#### Threat Modeling
- **Identify Assets**: What data and functionality need protection?
- **Identify Threats**: What could go wrong? Use STRIDE methodology
- **Identify Vulnerabilities**: Where are the weak points?
- **Identify Countermeasures**: How can risks be mitigated?

```csharp
// Example: Threat modeling for a banking application
public class BankingThreatModel
{
    // Assets to protect
    public class Assets
    {
        public const string CustomerData = "Customer PII and financial data";
        public const string TransactionData = "Financial transaction records";
        public const string AuthenticationTokens = "JWT tokens and session data";
        public const string ApplicationCode = "Source code and business logic";
    }

    // Identified threats using STRIDE
    public class Threats
    {
        // Spoofing - Impersonating another user
        public const string UserImpersonation = "Attacker gains access using stolen credentials";
        
        // Tampering - Modifying data or code
        public const string TransactionTampering = "Unauthorized modification of transaction amounts";
        
        // Repudiation - Denying actions
        public const string TransactionDenial = "User denies making a transaction";
        
        // Information Disclosure - Exposing information
        public const string DataLeakage = "Sensitive customer data exposed";
        
        // Denial of Service - Making service unavailable
        public const string ServiceDisruption = "Application becomes unavailable";
        
        // Elevation of Privilege - Gaining unauthorized access
        public const string PrivilegeEscalation = "User gains admin privileges";
    }
}
```

#### Security Architecture Principles
1. **Defense in Depth**: Multiple layers of security
2. **Fail Securely**: Default to secure state on errors
3. **Principle of Least Privilege**: Minimal necessary access
4. **Separation of Duties**: No single point of failure
5. **Zero Trust**: Never trust, always verify

### Phase 2: Implementation

#### Secure Coding Standards

**1. Input Validation**
```csharp
// ✅ Good: Comprehensive input validation
public class UserRegistrationModel
{
    [Required(ErrorMessage = "Email is required")]
    [EmailAddress(ErrorMessage = "Invalid email format")]
    [StringLength(254, ErrorMessage = "Email too long")]
    [RegularExpression(@"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Password is required")]
    [StringLength(128, MinimumLength = 8, ErrorMessage = "Password must be 8-128 characters")]
    [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]",
        ErrorMessage = "Password must contain uppercase, lowercase, digit, and special character")]
    public string Password { get; set; } = string.Empty;

    [Required(ErrorMessage = "Full name is required")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Name must be 2-100 characters")]
    [RegularExpression(@"^[a-zA-Z\s'-]+$", ErrorMessage = "Name contains invalid characters")]
    public string FullName { get; set; } = string.Empty;
}

// ✅ Good: Server-side validation with sanitization
[HttpPost]
public async Task<IActionResult> Register(UserRegistrationModel model)
{
    if (!ModelState.IsValid)
    {
        return View(model);
    }

    // Additional business rule validation
    if (await _userService.EmailExistsAsync(model.Email))
    {
        ModelState.AddModelError(nameof(model.Email), "Email already registered");
        return View(model);
    }

    // Sanitize input
    var sanitizedName = _htmlSanitizer.Sanitize(model.FullName);
    
    var user = new User
    {
        Email = model.Email.ToLowerInvariant().Trim(),
        FullName = sanitizedName,
        PasswordHash = _passwordHasher.HashPassword(model.Password)
    };

    await _userService.CreateUserAsync(user);
    return RedirectToAction("Welcome");
}
```

**2. Output Encoding**
```csharp
// ✅ Good: Context-appropriate encoding
public class SafeOutputHelper
{
    public static string HtmlEncode(string input)
    {
        return System.Web.HttpUtility.HtmlEncode(input);
    }

    public static string JavaScriptEncode(string input)
    {
        return System.Web.HttpUtility.JavaScriptStringEncode(input);
    }

    public static string UrlEncode(string input)
    {
        return System.Web.HttpUtility.UrlEncode(input);
    }

    public static string AttributeEncode(string input)
    {
        return System.Web.HttpUtility.HtmlAttributeEncode(input);
    }
}

// In Razor views
@{
    var userInput = ViewBag.UserInput as string;
}

<!-- ✅ Good: HTML context encoding -->
<p>Welcome, @Html.Encode(userInput)!</p>

<!-- ✅ Good: JavaScript context encoding -->
<script>
    var userName = '@Html.Raw(Html.JavaScriptEncode(userInput))';
</script>

<!-- ✅ Good: Attribute context encoding -->
<input type="text" value="@Html.AttributeEncode(userInput)" />

<!-- ✅ Good: URL context encoding -->
<a href="/profile/@Html.Raw(Html.UrlEncode(userInput))">View Profile</a>
```

**3. Authentication Security**
```csharp
// ✅ Good: Comprehensive authentication configuration
public void ConfigureAuthentication(IServiceCollection services, IConfiguration configuration)
{
    services.AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer(options =>
    {
        options.RequireHttpsMetadata = true;
        options.SaveToken = false; // Don't save tokens in AuthenticationProperties
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = configuration["JWT:Issuer"],
            ValidAudience = configuration["JWT:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(configuration["JWT:Key"])),
            ClockSkew = TimeSpan.FromMinutes(5), // Reduce clock skew tolerance
            RequireExpirationTime = true,
            RequireSignedTokens = true
        };

        options.Events = new JwtBearerEvents
        {
            OnAuthenticationFailed = context =>
            {
                // Log authentication failures
                var logger = context.HttpContext.RequestServices
                    .GetRequiredService<ILogger<Program>>();
                logger.LogWarning("JWT authentication failed: {Error}", context.Exception.Message);
                return Task.CompletedTask;
            },
            OnTokenValidated = context =>
            {
                // Additional token validation
                var tokenBlacklist = context.HttpContext.RequestServices
                    .GetRequiredService<ITokenBlacklistService>();
                
                var jti = context.Principal?.FindFirst(JwtRegisteredClaimNames.Jti)?.Value;
                if (!string.IsNullOrEmpty(jti) && tokenBlacklist.IsBlacklisted(jti))
                {
                    context.Fail("Token has been revoked");
                }
                return Task.CompletedTask;
            }
        };
    });

    // Configure Identity with secure options
    services.Configure<IdentityOptions>(options =>
    {
        // Password settings
        options.Password.RequireDigit = true;
        options.Password.RequireLowercase = true;
        options.Password.RequireNonAlphanumeric = true;
        options.Password.RequireUppercase = true;
        options.Password.RequiredLength = 8;
        options.Password.RequiredUniqueChars = 4;

        // Lockout settings
        options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
        options.Lockout.MaxFailedAccessAttempts = 5;
        options.Lockout.AllowedForNewUsers = true;

        // User settings
        options.User.AllowedUserNameCharacters = 
            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._@+";
        options.User.RequireUniqueEmail = true;

        // Sign-in settings
        options.SignIn.RequireConfirmedEmail = true;
        options.SignIn.RequireConfirmedPhoneNumber = false;
    });
}
```

**4. Authorization Best Practices**
```csharp
// ✅ Good: Resource-based authorization
public class DocumentAuthorizationHandler : AuthorizationHandler<DocumentOperationRequirement, Document>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        DocumentOperationRequirement requirement,
        Document document)
    {
        var userId = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        
        if (string.IsNullOrEmpty(userId))
        {
            return Task.CompletedTask; // Not authorized
        }

        switch (requirement.Operation)
        {
            case DocumentOperation.Read:
                if (document.IsPublic || 
                    document.OwnerId == userId || 
                    context.User.IsInRole("Admin") ||
                    document.SharedWith.Contains(userId))
                {
                    context.Succeed(requirement);
                }
                break;

            case DocumentOperation.Edit:
                if (document.OwnerId == userId || context.User.IsInRole("Admin"))
                {
                    context.Succeed(requirement);
                }
                break;

            case DocumentOperation.Delete:
                if (document.OwnerId == userId || context.User.IsInRole("Admin"))
                {
                    // Additional check: prevent deletion of system documents
                    if (!document.IsSystemDocument)
                    {
                        context.Succeed(requirement);
                    }
                }
                break;
        }

        return Task.CompletedTask;
    }
}

// Usage in controller
[HttpGet("{id}")]
public async Task<IActionResult> GetDocument(int id)
{
    var document = await _documentService.GetByIdAsync(id);
    if (document == null)
    {
        return NotFound();
    }

    var authResult = await _authorizationService
        .AuthorizeAsync(User, document, new DocumentOperationRequirement(DocumentOperation.Read));

    if (!authResult.Succeeded)
    {
        return Forbid();
    }

    return Ok(document);
}
```

## 🔒 Data Protection & Encryption

### 1. Data Protection API Usage
```csharp
// ✅ Good: Comprehensive data protection setup
public void ConfigureDataProtection(IServiceCollection services, IConfiguration configuration)
{
    var keyVaultUri = configuration["KeyVault:Uri"];
    var keyVaultKeyId = configuration["KeyVault:KeyId"];

    services.AddDataProtection(options =>
    {
        options.ApplicationDiscriminator = "YourApp";
    })
    .SetApplicationName("YourApplication")
    .PersistKeysToAzureKeyVault(new Uri(keyVaultUri), new DefaultAzureCredential())
    .ProtectKeysWithAzureKeyVault(new Uri(keyVaultKeyId), new DefaultAzureCredential())
    .SetDefaultKeyLifetime(TimeSpan.FromDays(90)) // Rotate keys every 90 days
    .AddKeyEscrowSink(sp => sp.GetRequiredService<IKeyEscrowSink>());
}

// Data protection service
public class SecureDataService
{
    private readonly IDataProtector _protector;
    private readonly ILogger<SecureDataService> _logger;

    public SecureDataService(IDataProtectionProvider provider, ILogger<SecureDataService> logger)
    {
        _protector = provider.CreateProtector("SecureData.PersonalInfo");
        _logger = logger;
    }

    public string ProtectSensitiveData(string plaintext)
    {
        try
        {
            if (string.IsNullOrEmpty(plaintext))
                return plaintext;

            return _protector.Protect(plaintext);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to protect sensitive data");
            throw new SecurityException("Data protection failed", ex);
        }
    }

    public string UnprotectSensitiveData(string ciphertext)
    {
        try
        {
            if (string.IsNullOrEmpty(ciphertext))
                return ciphertext;

            return _protector.Unprotect(ciphertext);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to unprotect sensitive data");
            throw new SecurityException("Data unprotection failed", ex);
        }
    }
}
```

### 2. Database Security
```csharp
// ✅ Good: Secure Entity Framework configuration
public class SecureDbContext : DbContext
{
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            // Connection string with encryption
            var connectionString = "Server=.;Database=MyApp;Integrated Security=true;Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;";
            optionsBuilder.UseSqlServer(connectionString, options =>
            {
                options.EnableRetryOnFailure(
                    maxRetryCount: 3,
                    maxRetryDelay: TimeSpan.FromSeconds(5),
                    errorNumbersToAdd: null);
            });
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Encrypt sensitive fields
        modelBuilder.Entity<User>()
            .Property(u => u.SocialSecurityNumber)
            .HasConversion(
                v => EncryptField(v),
                v => DecryptField(v));

        modelBuilder.Entity<User>()
            .Property(u => u.Email)
            .HasMaxLength(254)
            .IsRequired();

        // Add row-level security
        modelBuilder.Entity<Document>()
            .HasQueryFilter(d => d.IsDeleted == false);

        base.OnModelCreating(modelBuilder);
    }

    private string EncryptField(string value)
    {
        // Use data protection API or Azure Key Vault
        return _dataProtector.Protect(value);
    }

    private string DecryptField(string value)
    {
        return _dataProtector.Unprotect(value);
    }
}
```

## 🛡️ Security Headers & Middleware

### 1. Comprehensive Security Headers
```csharp
public class SecurityHeadersMiddleware
{
    private readonly RequestDelegate _next;
    private readonly SecurityHeadersOptions _options;

    public SecurityHeadersMiddleware(RequestDelegate next, SecurityHeadersOptions options)
    {
        _next = next;
        _options = options;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Add security headers
        AddSecurityHeaders(context);
        
        // Remove server information
        RemoveServerHeaders(context);
        
        await _next(context);
        
        // Post-processing security checks
        await PerformPostProcessingChecks(context);
    }

    private void AddSecurityHeaders(HttpContext context)
    {
        var headers = context.Response.Headers;

        // Prevent MIME type sniffing
        headers["X-Content-Type-Options"] = "nosniff";

        // Prevent clickjacking
        headers["X-Frame-Options"] = _options.XFrameOptions;

        // XSS protection (legacy browsers)
        headers["X-XSS-Protection"] = "1; mode=block";

        // Control referrer information
        headers["Referrer-Policy"] = _options.ReferrerPolicy;

        // Control browser features
        headers["Permissions-Policy"] = _options.PermissionsPolicy;

        // Content Security Policy
        if (!string.IsNullOrEmpty(_options.ContentSecurityPolicy))
        {
            headers["Content-Security-Policy"] = _options.ContentSecurityPolicy;
        }

        // HSTS (only for HTTPS)
        if (context.Request.IsHttps && !string.IsNullOrEmpty(_options.StrictTransportSecurity))
        {
            headers["Strict-Transport-Security"] = _options.StrictTransportSecurity;
        }

        // Cross-Origin policies
        if (!string.IsNullOrEmpty(_options.CrossOriginEmbedderPolicy))
        {
            headers["Cross-Origin-Embedder-Policy"] = _options.CrossOriginEmbedderPolicy;
        }

        if (!string.IsNullOrEmpty(_options.CrossOriginOpenerPolicy))
        {
            headers["Cross-Origin-Opener-Policy"] = _options.CrossOriginOpenerPolicy;
        }

        if (!string.IsNullOrEmpty(_options.CrossOriginResourcePolicy))
        {
            headers["Cross-Origin-Resource-Policy"] = _options.CrossOriginResourcePolicy;
        }
    }

    private void RemoveServerHeaders(HttpContext context)
    {
        context.Response.Headers.Remove("Server");
        context.Response.Headers.Remove("X-Powered-By");
        context.Response.Headers.Remove("X-AspNet-Version");
        context.Response.Headers.Remove("X-AspNetMvc-Version");
    }

    private async Task PerformPostProcessingChecks(HttpContext context)
    {
        // Check for potential security issues in response
        if (context.Response.ContentType?.Contains("text/html") == true)
        {
            // Log if response might contain unencoded user input
            var response = context.Response;
            if (response.StatusCode == 200 && response.ContentLength > 0)
            {
                // Additional security validations
            }
        }
    }
}

public class SecurityHeadersOptions
{
    public string XFrameOptions { get; set; } = "DENY";
    public string ReferrerPolicy { get; set; } = "strict-origin-when-cross-origin";
    public string PermissionsPolicy { get; set; } = "camera=(), microphone=(), geolocation=(), payment=()";
    public string ContentSecurityPolicy { get; set; } = string.Empty;
    public string StrictTransportSecurity { get; set; } = "max-age=31536000; includeSubDomains; preload";
    public string CrossOriginEmbedderPolicy { get; set; } = "require-corp";
    public string CrossOriginOpenerPolicy { get; set; } = "same-origin";
    public string CrossOriginResourcePolicy { get; set; } = "same-origin";
}
```

### 2. Rate Limiting Implementation
```csharp
public class RateLimitingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IRateLimitService _rateLimitService;
    private readonly ILogger<RateLimitingMiddleware> _logger;

    public RateLimitingMiddleware(RequestDelegate next, IRateLimitService rateLimitService, ILogger<RateLimitingMiddleware> logger)
    {
        _next = next;
        _rateLimitService = rateLimitService;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var clientId = GetClientIdentifier(context);
        var endpoint = GetEndpointIdentifier(context);

        var rateLimitResult = await _rateLimitService.CheckRateLimitAsync(clientId, endpoint);

        if (!rateLimitResult.IsAllowed)
        {
            _logger.LogWarning("Rate limit exceeded for client {ClientId} on endpoint {Endpoint}", 
                clientId, endpoint);

            context.Response.StatusCode = 429; // Too Many Requests
            context.Response.Headers["Retry-After"] = rateLimitResult.RetryAfter.ToString();
            context.Response.Headers["X-RateLimit-Limit"] = rateLimitResult.Limit.ToString();
            context.Response.Headers["X-RateLimit-Remaining"] = rateLimitResult.Remaining.ToString();
            context.Response.Headers["X-RateLimit-Reset"] = rateLimitResult.Reset.ToString();

            await context.Response.WriteAsync("Rate limit exceeded. Please try again later.");
            return;
        }

        // Add rate limit info to response headers
        context.Response.Headers["X-RateLimit-Limit"] = rateLimitResult.Limit.ToString();
        context.Response.Headers["X-RateLimit-Remaining"] = rateLimitResult.Remaining.ToString();
        context.Response.Headers["X-RateLimit-Reset"] = rateLimitResult.Reset.ToString();

        await _next(context);
    }

    private string GetClientIdentifier(HttpContext context)
    {
        // Priority: User ID > API Key > IP Address
        var userId = context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!string.IsNullOrEmpty(userId))
            return $"user:{userId}";

        var apiKey = context.Request.Headers["X-API-Key"].FirstOrDefault();
        if (!string.IsNullOrEmpty(apiKey))
            return $"api:{apiKey}";

        var ip = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        return $"ip:{ip}";
    }

    private string GetEndpointIdentifier(HttpContext context)
    {
        return $"{context.Request.Method}:{context.Request.Path}";
    }
}

public interface IRateLimitService
{
    Task<RateLimitResult> CheckRateLimitAsync(string clientId, string endpoint);
}

public class RateLimitResult
{
    public bool IsAllowed { get; set; }
    public int Limit { get; set; }
    public int Remaining { get; set; }
    public DateTime Reset { get; set; }
    public TimeSpan RetryAfter { get; set; }
}
```

## 📊 Security Monitoring & Logging

### 1. Comprehensive Security Logging
```csharp
public class SecurityEventService
{
    private readonly ILogger<SecurityEventService> _logger;
    private readonly IConfiguration _configuration;

    public SecurityEventService(ILogger<SecurityEventService> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
    }

    public void LogSecurityEvent(SecurityEventType eventType, string message, object additionalData = null)
    {
        var securityEvent = new SecurityEvent
        {
            EventType = eventType,
            Message = message,
            Timestamp = DateTime.UtcNow,
            AdditionalData = additionalData,
            Severity = GetSeverityForEventType(eventType)
        };

        // Log with structured data
        _logger.LogInformation("Security Event: {@SecurityEvent}", securityEvent);

        // Send to security monitoring system if configured
        if (_configuration.GetValue<bool>("Security:SendToSiem"))
        {
            SendToSecurityMonitoring(securityEvent);
        }
    }

    public void LogAuthenticationFailure(string username, string ipAddress, string reason)
    {
        LogSecurityEvent(SecurityEventType.AuthenticationFailure, 
            "Authentication failed", 
            new { Username = username, IpAddress = ipAddress, Reason = reason });
    }

    public void LogAuthorizationFailure(string username, string resource, string action)
    {
        LogSecurityEvent(SecurityEventType.AuthorizationFailure,
            "Authorization failed",
            new { Username = username, Resource = resource, Action = action });
    }

    public void LogSuspiciousActivity(string ipAddress, string userAgent, string description)
    {
        LogSecurityEvent(SecurityEventType.SuspiciousActivity,
            "Suspicious activity detected",
            new { IpAddress = ipAddress, UserAgent = userAgent, Description = description });
    }

    public void LogDataAccess(string username, string dataType, string operation)
    {
        LogSecurityEvent(SecurityEventType.DataAccess,
            "Data access",
            new { Username = username, DataType = dataType, Operation = operation });
    }

    public void LogConfigurationChange(string username, string setting, string oldValue, string newValue)
    {
        LogSecurityEvent(SecurityEventType.ConfigurationChange,
            "Configuration changed",
            new { Username = username, Setting = setting, OldValue = oldValue, NewValue = newValue });
    }

    private LogLevel GetSeverityForEventType(SecurityEventType eventType)
    {
        return eventType switch
        {
            SecurityEventType.AuthenticationFailure => LogLevel.Warning,
            SecurityEventType.AuthorizationFailure => LogLevel.Warning,
            SecurityEventType.SuspiciousActivity => LogLevel.Error,
            SecurityEventType.DataAccess => LogLevel.Information,
            SecurityEventType.ConfigurationChange => LogLevel.Warning,
            SecurityEventType.SecurityViolation => LogLevel.Critical,
            _ => LogLevel.Information
        };
    }

    private void SendToSecurityMonitoring(SecurityEvent securityEvent)
    {
        // Implementation for sending to SIEM, Splunk, Azure Sentinel, etc.
        // This could be done asynchronously in a background service
    }
}

public enum SecurityEventType
{
    AuthenticationFailure,
    AuthorizationFailure,
    SuspiciousActivity,
    DataAccess,
    ConfigurationChange,
    SecurityViolation
}

public class SecurityEvent
{
    public SecurityEventType EventType { get; set; }
    public string Message { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }
    public object? AdditionalData { get; set; }
    public LogLevel Severity { get; set; }
}
```

### 2. Anomaly Detection
```csharp
public class AnomalyDetectionService
{
    private readonly ILogger<AnomalyDetectionService> _logger;
    private readonly IMemoryCache _cache;
    private readonly SecurityEventService _securityEvents;

    public AnomalyDetectionService(
        ILogger<AnomalyDetectionService> logger,
        IMemoryCache cache,
        SecurityEventService securityEvents)
    {
        _logger = logger;
        _cache = cache;
        _securityEvents = securityEvents;
    }

    public async Task AnalyzeUserBehaviorAsync(string userId, string action, HttpContext context)
    {
        var userBehavior = GetUserBehaviorPattern(userId);
        
        // Check for unusual login times
        if (action == "login" && IsUnusualLoginTime(userBehavior, DateTime.UtcNow))
        {
            _securityEvents.LogSuspiciousActivity(
                context.Connection.RemoteIpAddress?.ToString() ?? "unknown",
                context.Request.Headers["User-Agent"],
                $"Unusual login time for user {userId}");
        }

        // Check for unusual locations (based on IP)
        var currentIp = context.Connection.RemoteIpAddress?.ToString();
        if (!string.IsNullOrEmpty(currentIp) && IsUnusualLocation(userBehavior, currentIp))
        {
            _securityEvents.LogSuspiciousActivity(
                currentIp,
                context.Request.Headers["User-Agent"],
                $"Login from unusual location for user {userId}");
        }

        // Check for rapid successive actions
        if (IsRapidActionPattern(userId, action))
        {
            _securityEvents.LogSuspiciousActivity(
                currentIp ?? "unknown",
                context.Request.Headers["User-Agent"],
                $"Rapid successive actions detected for user {userId}");
        }

        // Update behavior pattern
        UpdateUserBehaviorPattern(userId, action, context);
    }

    private UserBehaviorPattern GetUserBehaviorPattern(string userId)
    {
        var cacheKey = $"user_behavior_{userId}";
        return _cache.GetOrCreate(cacheKey, factory =>
        {
            factory.SlidingExpiration = TimeSpan.FromDays(30);
            return new UserBehaviorPattern { UserId = userId };
        });
    }

    private bool IsUnusualLoginTime(UserBehaviorPattern pattern, DateTime loginTime)
    {
        if (pattern.TypicalLoginHours.Count == 0)
            return false; // No baseline yet

        var hour = loginTime.Hour;
        var isTypicalHour = pattern.TypicalLoginHours.ContainsKey(hour) && 
                          pattern.TypicalLoginHours[hour] > 2; // At least 2 previous logins

        return !isTypicalHour;
    }

    private bool IsUnusualLocation(UserBehaviorPattern pattern, string ipAddress)
    {
        // Simplified geolocation check
        // In production, use a geolocation service
        var ipCountry = GetCountryFromIp(ipAddress);
        return !pattern.TypicalCountries.Contains(ipCountry);
    }

    private bool IsRapidActionPattern(string userId, string action)
    {
        var cacheKey = $"recent_actions_{userId}";
        var recentActions = _cache.GetOrCreate(cacheKey, factory =>
        {
            factory.SlidingExpiration = TimeSpan.FromMinutes(5);
            return new List<DateTime>();
        });

        var now = DateTime.UtcNow;
        recentActions.Add(now);

        // Remove actions older than 1 minute
        recentActions.RemoveAll(a => now - a > TimeSpan.FromMinutes(1));

        // Alert if more than 10 actions in 1 minute
        return recentActions.Count > 10;
    }

    private void UpdateUserBehaviorPattern(string userId, string action, HttpContext context)
    {
        var pattern = GetUserBehaviorPattern(userId);
        
        if (action == "login")
        {
            var hour = DateTime.UtcNow.Hour;
            pattern.TypicalLoginHours[hour] = pattern.TypicalLoginHours.GetValueOrDefault(hour, 0) + 1;

            var country = GetCountryFromIp(context.Connection.RemoteIpAddress?.ToString() ?? "");
            if (!string.IsNullOrEmpty(country))
            {
                pattern.TypicalCountries.Add(country);
            }
        }

        pattern.LastActivity = DateTime.UtcNow;
    }

    private string GetCountryFromIp(string ipAddress)
    {
        // Implement geolocation lookup
        // This is a placeholder implementation
        return "US";
    }
}

public class UserBehaviorPattern
{
    public string UserId { get; set; } = string.Empty;
    public Dictionary<int, int> TypicalLoginHours { get; set; } = new();
    public HashSet<string> TypicalCountries { get; set; } = new();
    public DateTime LastActivity { get; set; }
}
```

## 🚀 Deployment Security

### 1. Environment Configuration
```csharp
// appsettings.Production.json
{
    "ConnectionStrings": {
        "DefaultConnection": "#{ConnectionString}#" // Use Azure DevOps variable substitution
    },
    "Logging": {
        "LogLevel": {
            "Default": "Information",
            "Microsoft.AspNetCore": "Warning"
        }
    },
    "Security": {
        "RequireHttps": true,
        "RequireConfirmedAccount": true,
        "JwtKey": "#{JwtSecretKey}#",
        "CookieTimeout": "00:30:00",
        "EnableRateLimiting": true,
        "MaxRequestsPerMinute": 100
    },
    "KeyVault": {
        "Uri": "#{KeyVaultUri}#",
        "KeyId": "#{EncryptionKeyId}#"
    }
}

// Secure environment variable configuration
public static void Main(string[] args)
{
    var builder = WebApplication.CreateBuilder(args);

    // Configure Kestrel for production
    builder.WebHost.ConfigureKestrel(options =>
    {
        options.AddServerHeader = false; // Remove server header
        options.Limits.MaxRequestBodySize = 10 * 1024 * 1024; // 10MB limit
        options.Limits.MaxRequestHeaderCount = 50;
        options.Limits.MaxRequestHeadersTotalSize = 32 * 1024; // 32KB
        options.Limits.MaxRequestLineSize = 8 * 1024; // 8KB
        
        // HTTPS configuration
        options.ListenAnyIP(5001, listenOptions =>
        {
            listenOptions.UseHttps(httpsOptions =>
            {
                httpsOptions.SslProtocols = SslProtocols.Tls12 | SslProtocols.Tls13;
            });
        });
    });

    var app = builder.Build();

    // Validate configuration on startup
    ValidateSecurityConfiguration(app.Configuration);

    app.Run();
}

private static void ValidateSecurityConfiguration(IConfiguration configuration)
{
    var requiredSettings = new[]
    {
        "Security:JwtKey",
        "KeyVault:Uri",
        "ConnectionStrings:DefaultConnection"
    };

    foreach (var setting in requiredSettings)
    {
        if (string.IsNullOrEmpty(configuration[setting]))
        {
            throw new InvalidOperationException($"Required security setting '{setting}' is missing");
        }
    }

    // Validate JWT key length
    var jwtKey = configuration["Security:JwtKey"];
    if (jwtKey.Length < 32)
    {
        throw new InvalidOperationException("JWT key must be at least 32 characters long");
    }
}
```

### 2. Azure Deployment Security
```yaml
# azure-pipelines.yml - Secure deployment pipeline
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

variables:
- group: 'production-secrets' # Secure variable group
- name: 'buildConfiguration'
  value: 'Release'

stages:
- stage: Security
  displayName: 'Security Checks'
  jobs:
  - job: SecurityScan
    displayName: 'Security Scanning'
    steps:
    - task: UseDotNet@2
      displayName: 'Install .NET SDK'
      inputs:
        packageType: 'sdk'
        version: '8.0.x'

    - task: DotNetCoreCLI@2
      displayName: 'Restore dependencies'
      inputs:
        command: 'restore'
        projects: '**/*.csproj'

    - task: DotNetCoreCLI@2
      displayName: 'Build project'
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--configuration $(buildConfiguration) --no-restore'

    # Static Application Security Testing (SAST)
    - task: SonarCloudPrepare@1
      displayName: 'Prepare SonarCloud analysis'
      inputs:
        SonarCloud: 'SonarCloud'
        organization: 'your-org'
        scannerMode: 'MSBuild'
        projectKey: 'your-project-key'

    - task: SonarCloudAnalyze@1
      displayName: 'Run SonarCloud analysis'

    - task: SonarCloudPublish@1
      displayName: 'Publish SonarCloud results'

    # Dependency vulnerability scanning
    - task: dependency-check-build-task@6
      displayName: 'OWASP Dependency Check'
      inputs:
        projectName: 'YourProject'
        scanPath: '$(System.DefaultWorkingDirectory)'
        format: 'JSON'

    # Container security scanning
    - task: AzureContainerRegistry@0
      displayName: 'Build and scan container'
      inputs:
        azureSubscription: 'your-subscription'
        azureContainerRegistry: 'your-registry.azurecr.io'
        dockerFile: 'Dockerfile'
        buildContext: '$(System.DefaultWorkingDirectory)'
        repository: 'your-app'
        tags: '$(Build.BuildId)'
        includeLatestTag: true

- stage: Deploy
  displayName: 'Deploy to Production'
  condition: succeeded('Security')
  jobs:
  - deployment: DeployToProduction
    displayName: 'Deploy to Azure App Service'
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            displayName: 'Deploy to Azure Web App'
            inputs:
              azureSubscription: 'your-subscription'
              appType: 'webApp'
              WebAppName: 'your-web-app'
              packageForLinux: '$(Pipeline.Workspace)/**/*.zip'
              AppSettings: |
                -Security:JwtKey "$(JwtSecretKey)"
                -KeyVault:Uri "$(KeyVaultUri)"
                -ConnectionStrings:DefaultConnection "$(DatabaseConnectionString)"
```

## 📋 Security Checklist

### Development Phase
- [ ] Threat modeling completed
- [ ] Secure coding standards followed
- [ ] Input validation implemented
- [ ] Output encoding applied
- [ ] Authentication configured securely
- [ ] Authorization implemented properly
- [ ] Error handling doesn't leak information
- [ ] Logging captures security events
- [ ] Dependencies are up to date
- [ ] Static code analysis passed

### Testing Phase
- [ ] Unit tests include security scenarios
- [ ] Integration tests cover authentication/authorization
- [ ] Penetration testing completed
- [ ] Vulnerability scanning performed
- [ ] Code review focused on security
- [ ] Configuration reviewed for security
- [ ] Performance testing under load
- [ ] Security headers tested

### Deployment Phase
- [ ] Secure configuration deployed
- [ ] Secrets managed properly
- [ ] HTTPS enforced
- [ ] Security headers configured
- [ ] Monitoring and alerting set up
- [ ] Backup and recovery tested
- [ ] Incident response plan ready
- [ ] Documentation updated

### Maintenance Phase
- [ ] Regular security updates applied
- [ ] Dependency vulnerabilities monitored
- [ ] Security logs reviewed regularly
- [ ] Access reviews conducted
- [ ] Security training provided
- [ ] Threat model updated
- [ ] Incident response tested
- [ ] Compliance requirements met

## 🎯 Conclusion

Security is not a destination but a continuous journey. This guide provides a comprehensive foundation for building secure ASP.NET Core applications, but remember:

1. **Stay Updated**: Security threats evolve constantly
2. **Defense in Depth**: Use multiple layers of security
3. **Principle of Least Privilege**: Grant minimal necessary access
4. **Continuous Monitoring**: Watch for security events
5. **Regular Testing**: Test security measures regularly
6. **Team Training**: Keep the team security-aware
7. **Incident Preparedness**: Be ready to respond to incidents

**Remember**: The cost of prevention is always less than the cost of a security breach!

---

**Last Updated**: December 2024  
**Version**: 2.0  
**Next Review**: March 2025
