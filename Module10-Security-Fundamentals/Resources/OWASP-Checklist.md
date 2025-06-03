# OWASP Security Checklist for ASP.NET Core Applications

## 🎯 Overview
This checklist provides a comprehensive guide for implementing security best practices in ASP.NET Core applications based on OWASP guidelines and industry standards.

## 🔐 A01: Broken Access Control

### ✅ Authentication
- [ ] **Strong Password Policy**: Minimum 8 characters, complexity requirements
- [ ] **Multi-Factor Authentication**: Implement MFA for sensitive accounts
- [ ] **Account Lockout**: Prevent brute force attacks with progressive delays
- [ ] **Session Management**: Secure session tokens, proper timeout, regeneration
- [ ] **Secure Password Storage**: Use bcrypt, scrypt, or Argon2 for hashing

### ✅ Authorization
- [ ] **Principle of Least Privilege**: Users have minimal necessary permissions
- [ ] **Role-Based Access Control**: Implement RBAC consistently
- [ ] **Resource-Based Authorization**: Check permissions for specific resources
- [ ] **API Authorization**: Secure all API endpoints appropriately
- [ ] **Administrative Functions**: Extra protection for admin operations

### Implementation Examples:
```csharp
// Strong password policy
builder.Services.Configure<IdentityOptions>(options =>
{
    options.Password.RequireDigit = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireUppercase = true;
    options.Password.RequireNonAlphanumeric = true;
    options.Password.RequiredLength = 8;
    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
    options.Lockout.MaxFailedAccessAttempts = 5;
});

// Resource-based authorization
[Authorize]
public async Task<IActionResult> EditDocument(int id)
{
    var document = await _context.Documents.FindAsync(id);
    var authResult = await _authorizationService
        .AuthorizeAsync(User, document, "EditDocumentPolicy");
    
    if (!authResult.Succeeded)
        return Forbid();
    
    return View(document);
}
```

## 🔐 A02: Cryptographic Failures

### ✅ Data Protection
- [ ] **Encryption at Rest**: Encrypt sensitive data in databases
- [ ] **Encryption in Transit**: Use TLS 1.2+ for all communications
- [ ] **Key Management**: Secure storage and rotation of encryption keys
- [ ] **Sensitive Data Identification**: Classify and protect PII, financial data
- [ ] **Data Masking**: Mask sensitive data in logs and error messages

### ✅ Cryptographic Implementation
- [ ] **Strong Algorithms**: Use AES-256, RSA-2048+, SHA-256+
- [ ] **Secure Random Generation**: Use cryptographically secure random generators
- [ ] **Salt Usage**: Use unique salts for password hashing
- [ ] **Key Derivation**: Use proper key derivation functions (PBKDF2, scrypt)
- [ ] **Certificate Validation**: Proper SSL/TLS certificate validation

### Implementation Examples:
```csharp
// Data Protection API
builder.Services.AddDataProtection()
    .SetApplicationName("YourApp")
    .PersistKeysToAzureKeyVault(keyVaultUri, credential)
    .ProtectKeysWithAzureKeyVault(keyVaultKeyUri, credential);

// Secure password hashing
public string HashPassword(string password)
{
    var salt = BCrypt.Net.BCrypt.GenerateSalt(12);
    return BCrypt.Net.BCrypt.HashPassword(password, salt);
}

// Encrypt sensitive data
public async Task<string> EncryptSensitiveDataAsync(string plaintext)
{
    var protector = _dataProtectionProvider.CreateProtector("SensitiveData");
    return protector.Protect(plaintext);
}
```

## 🔐 A03: Injection

### ✅ SQL Injection Prevention
- [ ] **Parameterized Queries**: Use Entity Framework or parameterized SQL
- [ ] **Stored Procedures**: Use stored procedures with parameters
- [ ] **Input Validation**: Validate all user inputs
- [ ] **Least Privilege DB Access**: Database users have minimal permissions
- [ ] **ORM Security**: Configure Entity Framework securely

### ✅ Other Injection Types
- [ ] **Command Injection**: Avoid system command execution
- [ ] **LDAP Injection**: Validate LDAP queries
- [ ] **XML Injection**: Validate XML inputs
- [ ] **NoSQL Injection**: Secure NoSQL database queries
- [ ] **Template Injection**: Secure template engines

### Implementation Examples:
```csharp
// Safe Entity Framework query
public async Task<User> GetUserByEmailAsync(string email)
{
    return await _context.Users
        .Where(u => u.Email == email) // EF handles parameterization
        .FirstOrDefaultAsync();
}

// Safe parameterized SQL (if raw SQL needed)
public async Task<List<Product>> SearchProductsAsync(string searchTerm)
{
    var sql = "SELECT * FROM Products WHERE Name LIKE @searchTerm";
    return await _context.Products
        .FromSqlRaw(sql, new SqlParameter("@searchTerm", $"%{searchTerm}%"))
        .ToListAsync();
}

// Input validation
[HttpPost]
public IActionResult Search([Required][StringLength(100)] string query)
{
    if (!ModelState.IsValid)
        return BadRequest(ModelState);
    
    // Safe to use validated input
    return Ok(SearchService.Search(query));
}
```

## 🔐 A04: Insecure Design

### ✅ Security by Design
- [ ] **Threat Modeling**: Identify and mitigate potential threats
- [ ] **Security Architecture**: Build security into system architecture
- [ ] **Fail Securely**: Default to secure state on failures
- [ ] **Defense in Depth**: Multiple layers of security controls
- [ ] **Secure Defaults**: Secure configuration out of the box

### ✅ Business Logic Security
- [ ] **Rate Limiting**: Prevent abuse of business functions
- [ ] **Transaction Limits**: Implement appropriate business limits
- [ ] **Workflow Validation**: Validate business process steps
- [ ] **Data Integrity**: Ensure data consistency and validity
- [ ] **Audit Trails**: Log all significant business actions

### Implementation Examples:
```csharp
// Rate limiting middleware
public class RateLimitingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IRateLimitService _rateLimitService;

    public async Task InvokeAsync(HttpContext context)
    {
        var clientId = GetClientIdentifier(context);
        
        if (!await _rateLimitService.IsAllowedAsync(clientId))
        {
            context.Response.StatusCode = 429; // Too Many Requests
            await context.Response.WriteAsync("Rate limit exceeded");
            return;
        }

        await _next(context);
    }
}

// Secure business logic
public class BankingService
{
    public async Task<Result> TransferFundsAsync(TransferRequest request)
    {
        // Validate business rules
        if (request.Amount <= 0 || request.Amount > 10000)
            return Result.Failure("Invalid transfer amount");

        // Check account ownership
        if (!await _authService.CanAccessAccountAsync(request.UserId, request.FromAccount))
            return Result.Failure("Unauthorized account access");

        // Implement transaction with rollback capability
        using var transaction = await _context.Database.BeginTransactionAsync();
        try
        {
            await ProcessTransferAsync(request);
            await transaction.CommitAsync();
            await _auditService.LogTransferAsync(request);
            return Result.Success();
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }
}
```

## 🔐 A05: Security Misconfiguration

### ✅ Secure Configuration
- [ ] **Remove Default Accounts**: Remove or secure default accounts
- [ ] **Error Handling**: Don't expose sensitive information in errors
- [ ] **Security Headers**: Implement comprehensive security headers
- [ ] **Unnecessary Features**: Disable unused features and services
- [ ] **Environment Separation**: Separate dev/test/prod configurations

### ✅ Server Security
- [ ] **Operating System Hardening**: Keep OS updated and configured securely
- [ ] **Web Server Configuration**: Secure IIS/Nginx/Apache configuration
- [ ] **Network Security**: Implement proper network segmentation
- [ ] **Monitoring**: Comprehensive logging and monitoring
- [ ] **Backup Security**: Secure backup and recovery procedures

### Implementation Examples:
```csharp
// Secure error handling
public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    if (env.IsDevelopment())
    {
        app.UseDeveloperExceptionPage();
    }
    else
    {
        app.UseExceptionHandler("/Error");
        app.UseHsts();
    }
    
    // Security headers
    app.Use(async (context, next) =>
    {
        context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
        context.Response.Headers.Add("X-Frame-Options", "DENY");
        context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
        await next();
    });
}

// Secure appsettings.json structure
{
    "ConnectionStrings": {
        "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=MyApp;Trusted_Connection=true;MultipleActiveResultSets=true"
    },
    "Logging": {
        "LogLevel": {
            "Default": "Information",
            "Microsoft.AspNetCore": "Warning",
            "System.Net.Http.HttpClient": "Warning"
        }
    },
    "Security": {
        "RequireHttps": true,
        "RequireConfirmedAccount": true,
        "CookieTimeout": "00:30:00"
    }
}
```

## 🔐 A06: Vulnerable and Outdated Components

### ✅ Dependency Management
- [ ] **Inventory Management**: Maintain inventory of all components
- [ ] **Vulnerability Scanning**: Regular scanning for known vulnerabilities
- [ ] **Update Policy**: Regular updates and patch management
- [ ] **Source Verification**: Verify component sources and integrity
- [ ] **License Compliance**: Ensure license compatibility

### ✅ .NET Specific
- [ ] **Framework Updates**: Keep .NET runtime updated
- [ ] **NuGet Package Security**: Monitor NuGet packages for vulnerabilities
- [ ] **Dependency Conflicts**: Resolve version conflicts securely
- [ ] **Unused Dependencies**: Remove unused packages
- [ ] **Security Advisories**: Monitor Microsoft security advisories

### Implementation Examples:
```xml
<!-- Use specific versions to avoid unexpected updates -->
<PackageReference Include="Microsoft.AspNetCore.Authentication.JwtBearer" Version="8.0.0" />
<PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="8.0.0" />

<!-- Enable package vulnerability auditing -->
<PropertyGroup>
    <EnableNETAnalyzers>true</EnableNETAnalyzers>
    <AnalysisLevel>latest</AnalysisLevel>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
</PropertyGroup>
```

```bash
# Regular vulnerability scanning
dotnet list package --vulnerable
dotnet list package --outdated
```

## 🔐 A07: Identification and Authentication Failures

### ✅ Authentication Security
- [ ] **Session Management**: Secure session handling and timeout
- [ ] **Credential Storage**: Secure storage of authentication credentials
- [ ] **Brute Force Protection**: Implement account lockout and delays
- [ ] **Multi-Factor Authentication**: Require MFA for sensitive operations
- [ ] **Password Recovery**: Secure password reset mechanisms

### ✅ Session Security
- [ ] **Session Timeout**: Appropriate session timeout periods
- [ ] **Session Regeneration**: Regenerate session IDs after login
- [ ] **Concurrent Sessions**: Control concurrent session limits
- [ ] **Logout Security**: Proper session invalidation on logout
- [ ] **Remember Me**: Secure "remember me" functionality

### Implementation Examples:
```csharp
// Secure cookie configuration
builder.Services.ConfigureApplicationCookie(options =>
{
    options.Cookie.HttpOnly = true;
    options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    options.Cookie.SameSite = SameSiteMode.Strict;
    options.ExpireTimeSpan = TimeSpan.FromMinutes(30);
    options.SlidingExpiration = true;
    options.LoginPath = "/Account/Login";
    options.LogoutPath = "/Account/Logout";
    options.AccessDeniedPath = "/Account/AccessDenied";
});

// MFA implementation
public async Task<IActionResult> Login(LoginModel model)
{
    var result = await _signInManager.PasswordSignInAsync(
        model.Email, 
        model.Password, 
        model.RememberMe, 
        lockoutOnFailure: true);

    if (result.RequiresTwoFactor)
    {
        return RedirectToAction("SendCode", new { RememberMe = model.RememberMe });
    }

    if (result.IsLockedOut)
    {
        _logger.LogWarning("User account locked out: {Email}", model.Email);
        return RedirectToAction("Lockout");
    }

    return result.Succeeded ? 
        RedirectToAction("Index", "Home") : 
        View(model);
}
```

## 🔐 A08: Software and Data Integrity Failures

### ✅ Code Integrity
- [ ] **Code Signing**: Sign assemblies and deployment packages
- [ ] **CI/CD Security**: Secure build and deployment pipelines
- [ ] **Supply Chain Security**: Verify third-party component integrity
- [ ] **Version Control**: Secure version control and code review
- [ ] **Deployment Verification**: Verify deployment integrity

### ✅ Data Integrity
- [ ] **Data Validation**: Comprehensive input and data validation
- [ ] **Checksums**: Use checksums for critical data
- [ ] **Digital Signatures**: Sign critical data and documents
- [ ] **Audit Trails**: Maintain comprehensive audit logs
- [ ] **Backup Integrity**: Verify backup data integrity

### Implementation Examples:
```csharp
// Data integrity checks
public class DataIntegrityService
{
    public async Task<bool> VerifyDataIntegrityAsync<T>(T data, string expectedHash)
    {
        var actualHash = ComputeHash(JsonSerializer.Serialize(data));
        return actualHash.Equals(expectedHash, StringComparison.OrdinalIgnoreCase);
    }

    private string ComputeHash(string input)
    {
        using var sha256 = SHA256.Create();
        var hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(input));
        return Convert.ToBase64String(hashBytes);
    }
}

// Secure deployment verification
public class DeploymentVerificationService
{
    public async Task<bool> VerifyDeploymentIntegrityAsync()
    {
        var assemblies = Assembly.GetExecutingAssembly().GetReferencedAssemblies();
        
        foreach (var assembly in assemblies)
        {
            if (!await VerifyAssemblySignatureAsync(assembly))
            {
                _logger.LogError("Assembly signature verification failed: {Assembly}", assembly.Name);
                return false;
            }
        }
        
        return true;
    }
}
```

## 🔐 A09: Security Logging and Monitoring Failures

### ✅ Security Logging
- [ ] **Authentication Events**: Log all authentication attempts
- [ ] **Authorization Failures**: Log authorization failures
- [ ] **Input Validation Failures**: Log validation failures
- [ ] **Security Events**: Log security-relevant events
- [ ] **Error Logging**: Log errors without exposing sensitive data

### ✅ Monitoring and Alerting
- [ ] **Real-time Monitoring**: Monitor security events in real-time
- [ ] **Anomaly Detection**: Detect unusual patterns and behaviors
- [ ] **Incident Response**: Automated incident response procedures
- [ ] **Log Analysis**: Regular analysis of security logs
- [ ] **Compliance Reporting**: Generate compliance reports

### Implementation Examples:
```csharp
// Security event logging
public class SecurityEventLogger
{
    private readonly ILogger<SecurityEventLogger> _logger;

    public void LogAuthenticationFailure(string userName, string ipAddress, string reason)
    {
        _logger.LogWarning("Authentication failure for user {UserName} from IP {IpAddress}. Reason: {Reason}",
            userName, ipAddress, reason);
    }

    public void LogAuthorizationFailure(string userName, string resource, string action)
    {
        _logger.LogWarning("Authorization failure: User {UserName} attempted {Action} on {Resource}",
            userName, action, resource);
    }

    public void LogSuspiciousActivity(string ipAddress, string userAgent, string activity)
    {
        _logger.LogWarning("Suspicious activity detected from IP {IpAddress} with User-Agent {UserAgent}: {Activity}",
            ipAddress, userAgent, activity);
    }
}

// Structured logging with Serilog
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Information)
    .Enrich.FromLogContext()
    .Enrich.WithMachineName()
    .Enrich.WithEnvironmentName()
    .WriteTo.Console()
    .WriteTo.File("logs/security-.txt", 
        rollingInterval: RollingInterval.Day,
        retainedFileCountLimit: 30)
    .WriteTo.Seq("http://localhost:5341") // For centralized logging
    .CreateLogger();
```

## 🔐 A10: Server-Side Request Forgery (SSRF)

### ✅ SSRF Prevention
- [ ] **URL Validation**: Validate and sanitize all URLs
- [ ] **Whitelist Approach**: Use whitelist for allowed domains
- [ ] **Network Segmentation**: Isolate internal resources
- [ ] **Request Filtering**: Filter outbound requests
- [ ] **Timeout Configuration**: Set appropriate request timeouts

### ✅ Implementation
- [ ] **HTTP Client Security**: Secure HTTP client configuration
- [ ] **DNS Resolution**: Control DNS resolution
- [ ] **Port Restrictions**: Restrict allowed ports
- [ ] **Protocol Restrictions**: Allow only necessary protocols
- [ ] **Response Validation**: Validate response content

### Implementation Examples:
```csharp
// Secure HTTP client for external requests
public class SecureHttpClientService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<SecureHttpClientService> _logger;
    private readonly List<string> _allowedDomains;

    public SecureHttpClientService(HttpClient httpClient, IConfiguration config, ILogger<SecureHttpClientService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
        _allowedDomains = config.GetSection("Security:AllowedDomains").Get<List<string>>() ?? new List<string>();
        
        // Configure secure defaults
        _httpClient.Timeout = TimeSpan.FromSeconds(30);
        _httpClient.DefaultRequestHeaders.Add("User-Agent", "YourApp/1.0");
    }

    public async Task<string> GetContentAsync(string url)
    {
        if (!IsUrlAllowed(url))
        {
            _logger.LogWarning("Blocked request to disallowed URL: {Url}", url);
            throw new SecurityException("URL not allowed");
        }

        try
        {
            var response = await _httpClient.GetAsync(url);
            response.EnsureSuccessStatusCode();
            return await response.Content.ReadAsStringAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error making request to {Url}", url);
            throw;
        }
    }

    private bool IsUrlAllowed(string url)
    {
        if (!Uri.TryCreate(url, UriKind.Absolute, out var uri))
            return false;

        // Only allow HTTP/HTTPS
        if (uri.Scheme != "http" && uri.Scheme != "https")
            return false;

        // Check against whitelist
        return _allowedDomains.Any(domain => 
            uri.Host.Equals(domain, StringComparison.OrdinalIgnoreCase) ||
            uri.Host.EndsWith($".{domain}", StringComparison.OrdinalIgnoreCase));
    }
}
```

## 📋 Security Testing Checklist

### ✅ Automated Testing
- [ ] **Static Analysis**: Use static code analysis tools
- [ ] **Dependency Scanning**: Scan for vulnerable dependencies
- [ ] **SAST Integration**: Integrate security testing in CI/CD
- [ ] **Unit Tests**: Security-focused unit tests
- [ ] **Integration Tests**: Security integration tests

### ✅ Manual Testing
- [ ] **Penetration Testing**: Regular penetration testing
- [ ] **Code Review**: Security-focused code reviews
- [ ] **Configuration Review**: Review security configurations
- [ ] **Threat Modeling**: Update threat models regularly
- [ ] **Red Team Exercises**: Simulate real attacks

### ✅ Compliance
- [ ] **OWASP ASVS**: Follow OWASP Application Security Verification Standard
- [ ] **Industry Standards**: Comply with relevant industry standards
- [ ] **Regulatory Requirements**: Meet regulatory requirements (GDPR, HIPAA, etc.)
- [ ] **Internal Policies**: Follow organizational security policies
- [ ] **Documentation**: Maintain security documentation

## 🚀 Quick Implementation Guide

### Phase 1: Foundation (Week 1)
1. Implement security headers
2. Configure HTTPS and HSTS
3. Set up secure authentication
4. Implement basic input validation

### Phase 2: Advanced Security (Week 2)
1. Implement comprehensive logging
2. Add rate limiting
3. Configure data protection
4. Implement CSRF protection

### Phase 3: Monitoring & Testing (Week 3)
1. Set up security monitoring
2. Implement vulnerability scanning
3. Create security tests
4. Establish incident response

### Phase 4: Continuous Improvement (Ongoing)
1. Regular security assessments
2. Update dependencies
3. Review and improve policies
4. Stay current with threats

## 📚 Additional Resources

### OWASP Resources
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)

### Microsoft Security
- [ASP.NET Core Security](https://docs.microsoft.com/aspnet/core/security/)
- [.NET Security Guidelines](https://docs.microsoft.com/dotnet/standard/security/)
- [Azure Security Center](https://azure.microsoft.com/services/security-center/)

### Tools
- [OWASP ZAP](https://zaproxy.org/) - Security testing
- [SonarQube](https://www.sonarqube.org/) - Code quality and security
- [Snyk](https://snyk.io/) - Dependency vulnerability scanning

---

## 🎯 Remember
Security is not a destination, but a journey. Regular review and updates of this checklist are essential to maintain a strong security posture.

**Last Updated**: December 2024  
**Version**: 1.0  
**Review Frequency**: Quarterly
