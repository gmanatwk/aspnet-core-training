# Middleware Patterns Guide

## 🎯 **Overview**
This comprehensive guide covers middleware patterns, best practices, and common implementations for ASP.NET Core applications.

## 📚 **Table of Contents**
1. [Middleware Fundamentals](#middleware-fundamentals)
2. [Built-in Middleware Pipeline](#built-in-middleware-pipeline)
3. [Custom Middleware Patterns](#custom-middleware-patterns)
4. [Cross-Cutting Concerns](#cross-cutting-concerns)
5. [Performance Considerations](#performance-considerations)
6. [Testing Middleware](#testing-middleware)
7. [Production Patterns](#production-patterns)
8. [Common Pitfalls](#common-pitfalls)

---

## 🔧 **Middleware Fundamentals**

### **1. Basic Middleware Structure**

```csharp
// Convention-based middleware
public class CustomMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<CustomMiddleware> _logger;

    public CustomMiddleware(RequestDelegate next, ILogger<CustomMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Before logic
        _logger.LogInformation("Before next middleware");

        await _next(context);

        // After logic
        _logger.LogInformation("After next middleware");
    }
}

// Interface-based middleware
public class InterfaceBasedMiddleware : IMiddleware
{
    private readonly ILogger<InterfaceBasedMiddleware> _logger;

    public InterfaceBasedMiddleware(ILogger<InterfaceBasedMiddleware> logger)
    {
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context, RequestDelegate next)
    {
        _logger.LogInformation("Interface-based middleware executing");
        await next(context);
    }
}
```

### **2. Middleware Registration Patterns**

```csharp
// Extension method pattern
public static class MiddlewareExtensions
{
    public static IApplicationBuilder UseCustomMiddleware(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<CustomMiddleware>();
    }

    public static IApplicationBuilder UseCustomMiddleware(
        this IApplicationBuilder builder, 
        CustomMiddlewareOptions options)
    {
        return builder.UseMiddleware<CustomMiddleware>(options);
    }
}

// Usage in Program.cs
app.UseCustomMiddleware();
app.UseCustomMiddleware(new CustomMiddlewareOptions { Enabled = true });
```

---

## 🏗️ **Built-in Middleware Pipeline**

### **1. Recommended Middleware Order**

```csharp
var app = builder.Build();

// 1. Exception handling (should be first to catch all errors)
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
else
{
    app.UseExceptionHandler("/Error");
    app.UseHsts(); // HTTP Strict Transport Security
}

// 2. HTTPS redirection
app.UseHttpsRedirection();

// 3. Static files (before routing to serve files efficiently)
app.UseStaticFiles();

// 4. Routing
app.UseRouting();

// 5. CORS (after routing, before auth)
app.UseCors();

// 6. Authentication
app.UseAuthentication();

// 7. Authorization
app.UseAuthorization();

// 8. Custom middleware (after auth, before endpoints)
app.UseCustomMiddleware();

// 9. Endpoints (should be last)
app.MapControllers();
app.MapRazorPages();
```

### **2. Conditional Middleware**

```csharp
// Environment-based middleware
if (app.Environment.IsDevelopment())
{
    app.UseMiddleware<DevelopmentOnlyMiddleware>();
}

// Configuration-based middleware
if (builder.Configuration.GetValue<bool>("EnableCustomLogging"))
{
    app.UseMiddleware<CustomLoggingMiddleware>();
}

// Feature flag-based middleware
if (featureFlags.IsEnabled("NewFeature"))
{
    app.UseMiddleware<NewFeatureMiddleware>();
}
```

---

## 🛠️ **Custom Middleware Patterns**

### **1. Request/Response Modification**

```csharp
public class RequestModificationMiddleware
{
    private readonly RequestDelegate _next;

    public RequestModificationMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Modify request
        if (context.Request.Headers.ContainsKey("X-Legacy-Format"))
        {
            // Transform legacy request format
            await TransformLegacyRequest(context);
        }

        // Store original response stream
        var originalBodyStream = context.Response.Body;

        try
        {
            using var responseBody = new MemoryStream();
            context.Response.Body = responseBody;

            await _next(context);

            // Modify response
            context.Response.Body.Seek(0, SeekOrigin.Begin);
            var responseContent = await new StreamReader(context.Response.Body).ReadToEndAsync();
            
            // Transform response if needed
            var modifiedResponse = await TransformResponse(responseContent, context);
            
            context.Response.Body = originalBodyStream;
            await context.Response.WriteAsync(modifiedResponse);
        }
        finally
        {
            context.Response.Body = originalBodyStream;
        }
    }

    private async Task TransformLegacyRequest(HttpContext context)
    {
        // Legacy request transformation logic
        await Task.CompletedTask;
    }

    private async Task<string> TransformResponse(string content, HttpContext context)
    {
        // Response transformation logic
        await Task.CompletedTask;
        return content;
    }
}
```

### **2. Short-Circuiting Middleware**

```csharp
public class MaintenanceModeMiddleware
{
    private readonly RequestDelegate _next;
    private readonly MaintenanceOptions _options;

    public MaintenanceModeMiddleware(RequestDelegate next, MaintenanceOptions options)
    {
        _next = next;
        _options = options;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        if (_options.IsMaintenanceModeEnabled)
        {
            // Short-circuit the pipeline
            context.Response.StatusCode = 503; // Service Unavailable
            context.Response.Headers.Add("Retry-After", "3600"); // Retry after 1 hour
            
            await context.Response.WriteAsync(new
            {
                message = "System is under maintenance",
                expectedDuration = "1 hour",
                contact = "support@example.com"
            }.ToString());
            
            return; // Don't call _next, short-circuit here
        }

        await _next(context);
    }
}

public class MaintenanceOptions
{
    public bool IsMaintenanceModeEnabled { get; set; }
    public DateTime? ScheduledEndTime { get; set; }
    public string MaintenanceMessage { get; set; } = "System under maintenance";
}
```

### **3. Branching Middleware**

```csharp
// Branch based on path
app.Map("/api", apiApp =>
{
    apiApp.UseMiddleware<ApiKeyValidationMiddleware>();
    apiApp.UseMiddleware<ApiRateLimitingMiddleware>();
    apiApp.UseRouting();
    apiApp.MapControllers();
});

// Conditional branching
app.MapWhen(context => context.Request.Headers.ContainsKey("X-Mobile-App"), mobileApp =>
{
    mobileApp.UseMiddleware<MobileAppMiddleware>();
    mobileApp.UseRouting();
    mobileApp.MapControllers();
});

// Custom branching middleware
public class ConditionalBranchingMiddleware
{
    private readonly RequestDelegate _next;

    public ConditionalBranchingMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        if (ShouldBranch(context))
        {
            await HandleSpecialCase(context);
            return; // Don't continue to next middleware
        }

        await _next(context);
    }

    private bool ShouldBranch(HttpContext context)
    {
        return context.Request.Path.StartsWithSegments("/special") ||
               context.Request.Headers.ContainsKey("X-Special-Handling");
    }

    private async Task HandleSpecialCase(HttpContext context)
    {
        context.Response.StatusCode = 200;
        await context.Response.WriteAsync("Special handling applied");
    }
}
```

---

## 🌐 **Cross-Cutting Concerns**

### **1. Comprehensive Logging Middleware**

```csharp
public class RequestResponseLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestResponseLoggingMiddleware> _logger;
    private readonly RequestResponseLoggingOptions _options;

    public RequestResponseLoggingMiddleware(
        RequestDelegate next, 
        ILogger<RequestResponseLoggingMiddleware> logger,
        RequestResponseLoggingOptions options)
    {
        _next = next;
        _logger = logger;
        _options = options;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();
        var requestId = context.TraceIdentifier;

        // Log request
        await LogRequest(context, requestId);

        var originalBodyStream = context.Response.Body;
        using var responseBody = new MemoryStream();
        context.Response.Body = responseBody;

        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Request {RequestId} failed with exception", requestId);
            throw;
        }
        finally
        {
            stopwatch.Stop();
            
            // Log response
            await LogResponse(context, requestId, stopwatch.ElapsedMilliseconds);
            
            // Copy response back to original stream
            context.Response.Body.Seek(0, SeekOrigin.Begin);
            await responseBody.CopyToAsync(originalBodyStream);
        }
    }

    private async Task LogRequest(HttpContext context, string requestId)
    {
        var request = context.Request;
        
        var requestLog = new
        {
            RequestId = requestId,
            Method = request.Method,
            Path = request.Path.Value,
            QueryString = request.QueryString.Value,
            Headers = _options.LogHeaders ? request.Headers.ToDictionary(h => h.Key, h => h.Value.ToString()) : null,
            Body = _options.LogRequestBody ? await ReadBodyAsync(request) : null,
            Timestamp = DateTime.UtcNow
        };

        _logger.LogInformation("Request: {@RequestLog}", requestLog);
    }

    private async Task LogResponse(HttpContext context, string requestId, long elapsedMs)
    {
        var response = context.Response;
        
        var responseLog = new
        {
            RequestId = requestId,
            StatusCode = response.StatusCode,
            Headers = _options.LogHeaders ? response.Headers.ToDictionary(h => h.Key, h => h.Value.ToString()) : null,
            Body = _options.LogResponseBody ? await ReadResponseBodyAsync(response) : null,
            ElapsedMilliseconds = elapsedMs,
            Timestamp = DateTime.UtcNow
        };

        if (response.StatusCode >= 400)
        {
            _logger.LogWarning("Response (Error): {@ResponseLog}", responseLog);
        }
        else
        {
            _logger.LogInformation("Response: {@ResponseLog}", responseLog);
        }
    }

    private async Task<string> ReadBodyAsync(HttpRequest request)
    {
        request.EnableBuffering();
        var body = await new StreamReader(request.Body).ReadToEndAsync();
        request.Body.Position = 0;
        return body;
    }

    private async Task<string> ReadResponseBodyAsync(HttpResponse response)
    {
        response.Body.Seek(0, SeekOrigin.Begin);
        var body = await new StreamReader(response.Body).ReadToEndAsync();
        response.Body.Seek(0, SeekOrigin.Begin);
        return body;
    }
}

public class RequestResponseLoggingOptions
{
    public bool LogHeaders { get; set; } = false;
    public bool LogRequestBody { get; set; } = false;
    public bool LogResponseBody { get; set; } = false;
    public string[] ExcludePaths { get; set; } = Array.Empty<string>();
}
```

### **2. Security Headers Middleware**

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
        // Add security headers before processing
        AddSecurityHeaders(context.Response);

        await _next(context);
    }

    private void AddSecurityHeaders(HttpResponse response)
    {
        // X-Frame-Options
        if (_options.EnableXFrameOptions)
        {
            response.Headers.Add("X-Frame-Options", _options.XFrameOptionsValue);
        }

        // X-Content-Type-Options
        if (_options.EnableXContentTypeOptions)
        {
            response.Headers.Add("X-Content-Type-Options", "nosniff");
        }

        // X-XSS-Protection
        if (_options.EnableXXssProtection)
        {
            response.Headers.Add("X-XSS-Protection", "1; mode=block");
        }

        // Referrer-Policy
        if (_options.EnableReferrerPolicy)
        {
            response.Headers.Add("Referrer-Policy", _options.ReferrerPolicyValue);
        }

        // Content-Security-Policy
        if (_options.EnableContentSecurityPolicy && !string.IsNullOrEmpty(_options.ContentSecurityPolicyValue))
        {
            response.Headers.Add("Content-Security-Policy", _options.ContentSecurityPolicyValue);
        }

        // Strict-Transport-Security
        if (_options.EnableHsts && !string.IsNullOrEmpty(_options.HstsValue))
        {
            response.Headers.Add("Strict-Transport-Security", _options.HstsValue);
        }

        // Custom headers
        foreach (var header in _options.CustomHeaders)
        {
            response.Headers.Add(header.Key, header.Value);
        }
    }
}

public class SecurityHeadersOptions
{
    public bool EnableXFrameOptions { get; set; } = true;
    public string XFrameOptionsValue { get; set; } = "DENY";

    public bool EnableXContentTypeOptions { get; set; } = true;

    public bool EnableXXssProtection { get; set; } = true;

    public bool EnableReferrerPolicy { get; set; } = true;
    public string ReferrerPolicyValue { get; set; } = "strict-origin-when-cross-origin";

    public bool EnableContentSecurityPolicy { get; set; } = false;
    public string ContentSecurityPolicyValue { get; set; } = "default-src 'self'";

    public bool EnableHsts { get; set; } = false;
    public string HstsValue { get; set; } = "max-age=31536000; includeSubDomains";

    public Dictionary<string, string> CustomHeaders { get; set; } = new();
}
```

### **3. Performance Monitoring Middleware**

```csharp
public class PerformanceMonitoringMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<PerformanceMonitoringMiddleware> _logger;
    private readonly PerformanceOptions _options;
    private static readonly ConcurrentDictionary<string, PerformanceMetrics> _metrics = new();

    public PerformanceMonitoringMiddleware(
        RequestDelegate next, 
        ILogger<PerformanceMonitoringMiddleware> logger,
        PerformanceOptions options)
    {
        _next = next;
        _logger = logger;
        _options = options;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();
        var endpoint = GetEndpoint(context);
        
        try
        {
            await _next(context);
        }
        finally
        {
            stopwatch.Stop();
            await RecordMetrics(endpoint, stopwatch.ElapsedMilliseconds, context.Response.StatusCode);
            
            // Log slow requests
            if (stopwatch.ElapsedMilliseconds > _options.SlowRequestThresholdMs)
            {
                _logger.LogWarning("Slow request detected: {Endpoint} took {Duration}ms", 
                    endpoint, stopwatch.ElapsedMilliseconds);
            }
        }
    }

    private string GetEndpoint(HttpContext context)
    {
        var endpoint = context.GetEndpoint();
        if (endpoint != null)
        {
            return endpoint.DisplayName ?? $"{context.Request.Method} {context.Request.Path}";
        }
        
        return $"{context.Request.Method} {context.Request.Path}";
    }

    private async Task RecordMetrics(string endpoint, long durationMs, int statusCode)
    {
        await Task.Run(() =>
        {
            _metrics.AddOrUpdate(endpoint, 
                new PerformanceMetrics(durationMs, statusCode),
                (key, existing) => existing.AddSample(durationMs, statusCode));
        });
    }

    public static Dictionary<string, object> GetMetrics()
    {
        return _metrics.ToDictionary(
            kvp => kvp.Key,
            kvp => (object)new
            {
                RequestCount = kvp.Value.RequestCount,
                AverageResponseTime = kvp.Value.AverageResponseTime,
                MinResponseTime = kvp.Value.MinResponseTime,
                MaxResponseTime = kvp.Value.MaxResponseTime,
                ErrorRate = kvp.Value.ErrorRate,
                LastUpdated = kvp.Value.LastUpdated
            });
    }
}

public class PerformanceMetrics
{
    private readonly object _lock = new();
    private readonly List<long> _responseTimes = new();
    private int _errorCount = 0;

    public int RequestCount { get; private set; }
    public DateTime LastUpdated { get; private set; }

    public PerformanceMetrics(long initialDuration, int statusCode)
    {
        AddSample(initialDuration, statusCode);
    }

    public PerformanceMetrics AddSample(long durationMs, int statusCode)
    {
        lock (_lock)
        {
            RequestCount++;
            _responseTimes.Add(durationMs);
            
            if (statusCode >= 400)
            {
                _errorCount++;
            }
            
            // Keep only last 1000 samples
            if (_responseTimes.Count > 1000)
            {
                _responseTimes.RemoveAt(0);
            }
            
            LastUpdated = DateTime.UtcNow;
        }
        
        return this;
    }

    public double AverageResponseTime => _responseTimes.Any() ? _responseTimes.Average() : 0;
    public long MinResponseTime => _responseTimes.Any() ? _responseTimes.Min() : 0;
    public long MaxResponseTime => _responseTimes.Any() ? _responseTimes.Max() : 0;
    public double ErrorRate => RequestCount > 0 ? (double)_errorCount / RequestCount * 100 : 0;
}

public class PerformanceOptions
{
    public int SlowRequestThresholdMs { get; set; } = 1000;
    public bool EnableMetricsCollection { get; set; } = true;
    public int MaxSamplesPerEndpoint { get; set; } = 1000;
}
```

---

## ⚡ **Performance Considerations**

### **1. Efficient Middleware Design**

```csharp
// ✅ Good: Minimal allocation and efficient processing
public class EfficientMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<EfficientMiddleware> _logger;
    private static readonly Action<ILogger, string, Exception?> LogRequestStarted =
        LoggerMessage.Define<string>(LogLevel.Information, new EventId(1), "Request started for {Path}");

    public EfficientMiddleware(RequestDelegate next, ILogger<EfficientMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Use LoggerMessage for performance
        LogRequestStarted(_logger, context.Request.Path, null);

        // Avoid unnecessary allocations
        var path = context.Request.Path.Value;
        if (path?.StartsWith("/health", StringComparison.OrdinalIgnoreCase) == true)
        {
            await _next(context);
            return;
        }

        // Efficient processing
        await _next(context);
    }
}

// ❌ Bad: Inefficient middleware with allocations
public class InefficientMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<InefficientMiddleware> _logger;

    public InefficientMiddleware(RequestDelegate next, ILogger<InefficientMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // ❌ String concatenation creates new objects
        _logger.LogInformation("Request started for " + context.Request.Path + " at " + DateTime.Now);

        // ❌ Unnecessary LINQ operation
        var headers = context.Request.Headers.Where(h => h.Key.StartsWith("X-")).ToList();

        // ❌ Inefficient path checking
        if (context.Request.Path.Value.ToLower().Contains("/health"))
        {
            await _next(context);
            return;
        }

        await _next(context);
    }
}
```

### **2. Middleware Ordering for Performance**

```csharp
// ✅ Good: Performance-optimized ordering
var app = builder.Build();

// Fast middleware first
app.UseMiddleware<HealthCheckMiddleware>(); // Very fast, exits early for health checks

// Static files before routing (avoid expensive routing for static content)
app.UseStaticFiles();

// Authentication/authorization
app.UseAuthentication();
app.UseAuthorization();

// Expensive middleware after auth (only for authenticated requests)
app.UseMiddleware<ExpensiveLoggingMiddleware>();

// Routing last
app.UseRouting();
app.MapControllers();
```

---

## 🧪 **Testing Middleware**

### **1. Unit Testing Middleware**

```csharp
[Test]
public async Task CustomMiddleware_ShouldAddHeader()
{
    // Arrange
    var context = new DefaultHttpContext();
    var nextCalled = false;
    
    RequestDelegate next = (HttpContext ctx) =>
    {
        nextCalled = true;
        return Task.CompletedTask;
    };

    var middleware = new CustomHeaderMiddleware(next);

    // Act
    await middleware.InvokeAsync(context);

    // Assert
    Assert.True(nextCalled);
    Assert.True(context.Response.Headers.ContainsKey("X-Custom-Header"));
    Assert.Equal("CustomValue", context.Response.Headers["X-Custom-Header"]);
}

[Test]
public async Task SecurityMiddleware_ShouldShortCircuitOnMaintenanceMode()
{
    // Arrange
    var context = new DefaultHttpContext();
    var nextCalled = false;
    
    RequestDelegate next = (HttpContext ctx) =>
    {
        nextCalled = true;
        return Task.CompletedTask;
    };

    var options = new MaintenanceOptions { IsMaintenanceModeEnabled = true };
    var middleware = new MaintenanceModeMiddleware(next, options);

    // Act
    await middleware.InvokeAsync(context);

    // Assert
    Assert.False(nextCalled); // Should not call next middleware
    Assert.Equal(503, context.Response.StatusCode);
}
```

### **2. Integration Testing Middleware**

```csharp
public class MiddlewareIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public MiddlewareIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    [Test]
    public async Task SecurityHeaders_ShouldBePresent()
    {
        // Arrange
        var client = _factory.CreateClient();

        // Act
        var response = await client.GetAsync("/");

        // Assert
        Assert.True(response.Headers.Contains("X-Frame-Options"));
        Assert.True(response.Headers.Contains("X-Content-Type-Options"));
    }

    [Test]
    public async Task RequestLogging_ShouldLogRequests()
    {
        // Arrange
        var client = _factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                services.Configure<RequestResponseLoggingOptions>(options =>
                {
                    options.LogHeaders = true;
                });
            });
        }).CreateClient();

        // Act
        var response = await client.GetAsync("/api/test");

        // Assert
        response.EnsureSuccessStatusCode();
        // Verify logs using test logging provider
    }
}
```

---

## 🚀 **Production Patterns**

### **1. Circuit Breaker Middleware**

```csharp
public class CircuitBreakerMiddleware
{
    private readonly RequestDelegate _next;
    private readonly CircuitBreakerOptions _options;
    private readonly ILogger<CircuitBreakerMiddleware> _logger;
    private static readonly ConcurrentDictionary<string, CircuitBreakerState> _states = new();

    public CircuitBreakerMiddleware(
        RequestDelegate next, 
        CircuitBreakerOptions options,
        ILogger<CircuitBreakerMiddleware> logger)
    {
        _next = next;
        _options = options;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var endpoint = GetEndpoint(context);
        var state = _states.GetOrAdd(endpoint, _ => new CircuitBreakerState());

        if (state.IsOpen && DateTime.UtcNow < state.OpenUntil)
        {
            _logger.LogWarning("Circuit breaker is open for {Endpoint}", endpoint);
            context.Response.StatusCode = 503;
            await context.Response.WriteAsync("Service temporarily unavailable");
            return;
        }

        try
        {
            await _next(context);
            
            // Success - reset failure count
            if (context.Response.StatusCode < 500)
            {
                state.Reset();
            }
            else
            {
                state.RecordFailure(_options);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Request failed for {Endpoint}", endpoint);
            state.RecordFailure(_options);
            throw;
        }
    }

    private string GetEndpoint(HttpContext context)
    {
        return $"{context.Request.Method} {context.Request.Path}";
    }
}

public class CircuitBreakerState
{
    private int _failureCount = 0;
    private DateTime _lastFailure = DateTime.MinValue;

    public bool IsOpen { get; private set; }
    public DateTime OpenUntil { get; private set; }

    public void RecordFailure(CircuitBreakerOptions options)
    {
        _failureCount++;
        _lastFailure = DateTime.UtcNow;

        if (_failureCount >= options.FailureThreshold)
        {
            IsOpen = true;
            OpenUntil = DateTime.UtcNow.Add(options.OpenDuration);
        }
    }

    public void Reset()
    {
        _failureCount = 0;
        IsOpen = false;
        OpenUntil = DateTime.MinValue;
    }
}

public class CircuitBreakerOptions
{
    public int FailureThreshold { get; set; } = 5;
    public TimeSpan OpenDuration { get; set; } = TimeSpan.FromMinutes(1);
}
```

## 🎯 **Key Takeaways**

### **DO**
- ✅ Order middleware correctly for performance and functionality
- ✅ Use extension methods for clean registration
- ✅ Implement proper error handling in middleware
- ✅ Consider short-circuiting when appropriate
- ✅ Use efficient patterns to minimize allocations
- ✅ Test middleware thoroughly
- ✅ Document middleware behavior and dependencies

### **DON'T**
- ❌ Block the pipeline unnecessarily
- ❌ Ignore the order of middleware registration
- ❌ Forget to call next middleware (unless intentionally short-circuiting)
- ❌ Create middleware with heavy processing
- ❌ Access disposed objects in async middleware
- ❌ Use middleware for business logic (use filters instead)
- ❌ Forget to handle exceptions properly

---

**Remember**: Middleware is powerful but should be used judiciously. Focus on cross-cutting concerns and keep business logic in appropriate layers of your application.