# Exercise 1: Security Headers Implementation

## 🎯 Objective
Learn to implement comprehensive security headers in ASP.NET Core to protect against common web vulnerabilities.

## ⏱️ Duration
45 minutes

## 📋 Prerequisites
- Basic understanding of HTTP headers
- .NET 8.0 SDK installed
- ASP.NET Core middleware concepts
- Web security fundamentals

## 🎓 Learning Outcomes
By completing this exercise, you will:
- ✅ Understand the purpose of security headers
- ✅ Implement multiple security headers in ASP.NET Core
- ✅ Configure Content Security Policy (CSP)
- ✅ Test security headers using browser tools
- ✅ Understand HSTS and secure cookie configuration

## 📝 Background
Security headers are HTTP response headers that help protect web applications from various attacks. They instruct browsers on how to behave when handling the website's content.

### Key Security Headers:
1. **X-Content-Type-Options** - Prevents MIME type confusion attacks
2. **X-Frame-Options** - Prevents clickjacking attacks
3. **X-XSS-Protection** - Enables browser XSS filtering
4. **Strict-Transport-Security** - Enforces HTTPS connections
5. **Content-Security-Policy** - Prevents XSS and data injection attacks
6. **Referrer-Policy** - Controls referrer information
7. **Permissions-Policy** - Controls browser features

## 🚀 Getting Started

### Step 1: Create a New ASP.NET Core Project
```bash
  - Updated dotnet new command
  - Updated dotnet new command with existing flags
dotnet new   --framework net8.0
cd SecurityHeadersDemo
```

### Step 2: Install Required Packages
```bash
dotnet add package Microsoft.AspNetCore.Mvc.NewtonsoftJson
```

## 🛠️ Task 1: Basic Security Headers Middleware

Create a custom middleware to add security headers.

### Instructions:
1. **Create SecurityHeadersMiddleware.cs**:

```csharp
using Microsoft.Extensions.Primitives;

namespace SecurityHeadersDemo.Middleware
{
    public class SecurityHeadersMiddleware
    {
        private readonly RequestDelegate _next;

        public SecurityHeadersMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            // Add security headers
            var headers = context.Response.Headers;
            
            // Prevent MIME type confusion attacks
            headers.Append("X-Content-Type-Options", "nosniff");
            
            // Prevent clickjacking
            headers.Append("X-Frame-Options", "DENY");
            
            // Enable XSS filtering
            headers.Append("X-XSS-Protection", "1; mode=block");
            
            // Remove server information
            headers.Remove("Server");
            
            await _next(context);
        }
    }

    public static class SecurityHeadersMiddlewareExtensions
    {
        public static IApplicationBuilder UseSecurityHeaders(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<SecurityHeadersMiddleware>();
        }
    }
}
```

2. **Register the middleware in Program.cs**:

```csharp
using SecurityHeadersDemo.Middleware;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

// Add custom security headers
app.UseSecurityHeaders();

app.UseRouting();
app.UseAuthorization();
app.MapRazorPages();

app.Run();
```

## 🛠️ Task 2: Content Security Policy (CSP)

Implement a comprehensive Content Security Policy.

### Instructions:

1. **Create CSPMiddleware.cs**:

```csharp
namespace SecurityHeadersDemo.Middleware
{
    public class CSPMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly IConfiguration _configuration;

        public CSPMiddleware(RequestDelegate next, IConfiguration configuration)
        {
            _next = next;
            _configuration = configuration;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            var cspPolicy = BuildCSPPolicy();
            context.Response.Headers.Append("Content-Security-Policy", cspPolicy);
            
            await _next(context);
        }

        private string BuildCSPPolicy()
        {
            var policy = new List<string>
            {
                "default-src 'self'",
                "script-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com",
                "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
                "font-src 'self' https://fonts.gstatic.com",
                "img-src 'self' data: https:",
                "connect-src 'self'",
                "frame-ancestors 'none'",
                "base-uri 'self'",
                "form-action 'self'"
            };

            return string.Join("; ", policy);
        }
    }

    public static class CSPMiddlewareExtensions
    {
        public static IApplicationBuilder UseCSP(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<CSPMiddleware>();
        }
    }
}
```

2. **Update Program.cs to include CSP**:

```csharp
// Add after UseSecurityHeaders()
app.UseCSP();
```

## 🛠️ Task 3: HSTS Configuration

Configure HTTP Strict Transport Security.

### Instructions:

1. **Add HSTS configuration in Program.cs**:

```csharp
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    
    // Configure HSTS
    app.UseHsts();
}
else
{
    app.UseDeveloperExceptionPage();
}

// Configure HSTS in services
builder.Services.AddHsts(options =>
{
    options.Includesubdomains = true;
    options.MaxAge = TimeSpan.FromDays(365);
    options.Preload = true;
});
```

## 🛠️ Task 4: Secure Cookie Configuration

Configure secure cookie settings.

### Instructions:

1. **Add secure cookie configuration**:

```csharp
builder.Services.Configure<CookiePolicyOptions>(options =>
{
    options.HttpOnly = Microsoft.AspNetCore.CookiePolicy.HttpOnlyPolicy.Always;
    options.Secure = CookieSecurePolicy.Always;
    options.SameSite = SameSiteMode.Strict;
    options.MinimumSameSitePolicy = SameSiteMode.Strict;
});
```

2. **Use cookie policy in Program.cs**:

```csharp
app.UseCookiePolicy();
```

## 🛠️ Task 5: Testing Security Headers

Create a test page to verify security headers.

### Instructions:

1. **Create Pages/SecurityTest.cshtml**:

```html
@page
@model SecurityHeadersDemo.Pages.SecurityTestModel

<h2>Security Headers Test Page</h2>

<div class="alert alert-info">
    <h4>Open Browser Developer Tools</h4>
    <p>1. Open F12 Developer Tools</p>
    <p>2. Go to Network tab</p>
    <p>3. Refresh this page</p>
    <p>4. Click on the document request</p>
    <p>5. Check Response Headers</p>
</div>

<div class="card">
    <div class="card-header">
        <h5>Expected Security Headers</h5>
    </div>
    <div class="card-body">
        <ul>
            <li><strong>X-Content-Type-Options:</strong> nosniff</li>
            <li><strong>X-Frame-Options:</strong> DENY</li>
            <li><strong>X-XSS-Protection:</strong> 1; mode=block</li>
            <li><strong>Content-Security-Policy:</strong> [Your CSP policy]</li>
            <li><strong>Strict-Transport-Security:</strong> [HSTS configuration]</li>
        </ul>
    </div>
</div>

<script>
    // This script tests CSP - it should be allowed
    console.log('Security test page loaded successfully');
</script>
```

2. **Create Pages/SecurityTest.cshtml.cs**:

```csharp
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace SecurityHeadersDemo.Pages
{
    public class SecurityTestModel : PageModel
    {
        public void OnGet()
        {
            ViewData["Title"] = "Security Headers Test";
        }
    }
}
```

## ✅ Verification Steps

### Step 1: Run the Application
```bash
dotnet run
```

### Step 2: Test Security Headers
1. Navigate to `https://localhost:5001/SecurityTest`
2. Open browser Developer Tools (F12)
3. Check Network tab for response headers
4. Verify all security headers are present

### Step 3: Online Security Scanner
Use online tools to test your headers:
- [SecurityHeaders.com](https://securityheaders.com/)
- [Mozilla Observatory](https://observatory.mozilla.org/)

## 🧪 Challenge Tasks

### Challenge 1: Nonce-based CSP
Implement nonce-based Content Security Policy for inline scripts.

### Challenge 2: Feature Policy
Add Permissions-Policy header to control browser features.

### Challenge 3: Certificate Transparency
Implement Expect-CT header for Certificate Transparency.

## 📊 Expected Results

After completing this exercise, your application should have:
- ✅ X-Content-Type-Options header
- ✅ X-Frame-Options header  
- ✅ X-XSS-Protection header
- ✅ Content-Security-Policy header
- ✅ Strict-Transport-Security header
- ✅ Secure cookie configuration
- ✅ A+ rating on SecurityHeaders.com

## 🔧 Troubleshooting

### Common Issues:

1. **CSP Blocking Resources**
   - Check browser console for CSP violations
   - Adjust CSP policy as needed
   - Use `Content-Security-Policy-Report-Only` for testing

2. **HSTS Not Working in Development**
   - HSTS only works with HTTPS
   - Use development certificates for local testing

3. **Cookies Not Secure**
   - Ensure HTTPS is enabled
   - Check SameSite compatibility

## 📚 Additional Reading

- [OWASP Secure Headers Project](https://owasp.org/www-project-secure-headers/)
- [MDN HTTP Headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers)
- [Content Security Policy Guide](https://content-security-policy.com/)

## 🎯 Assessment

Test your understanding:
1. What is the purpose of X-Content-Type-Options?
2. How does Content Security Policy prevent XSS attacks?
3. When should you use HSTS preloading?
4. What are the benefits of secure cookie configuration?

---

**Congratulations!** You've successfully implemented comprehensive security headers in ASP.NET Core. These headers form the foundation of web application security.

**Next Exercise**: [Exercise 2: Input Validation & Sanitization](Exercise2-InputValidation.md)
