# Exercise 2: Custom Middleware Development

## 🎯 **Objective**
Build production-ready custom middleware components that handle cross-cutting concerns like logging, rate limiting, correlation IDs, and error handling.

## ⏱️ **Estimated Time**
45 minutes

## 📋 **Prerequisites**
- Understanding of ASP.NET Core request pipeline
- Basic knowledge of HttpContext and middleware concepts
- Familiarity with async/await patterns
- Completion of Exercise 1 (Service Lifetimes)

## 🎓 **Learning Outcomes**
- Create custom middleware using different patterns
- Understand middleware execution order and pipeline flow
- Implement cross-cutting concerns effectively
- Handle async operations in middleware
- Configure conditional middleware execution
- Integrate middleware with dependency injection

## 📝 **Exercise Tasks**

### **Task 1: Request/Response Logging Middleware** (10 minutes)

Create middleware that logs all incoming requests and outgoing responses:

```csharp
// RequestLoggingMiddleware.cs
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var requestId = context.TraceIdentifier;
        var startTime = DateTime.UtcNow;
        
        // Log request details
        _logger.LogInformation("Request {RequestId} started: {Method} {Path} at {StartTime}",
            requestId, 
            context.Request.Method, 
            context.Request.Path, 
            startTime);

        // Create a stopwatch to measure request duration
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();

        try
        {
            // Call the next middleware in the pipeline
            await _next(context);
        }
        finally
        {
            stopwatch.Stop();
            var endTime = DateTime.UtcNow;
            
            // Log response details
            _logger.LogInformation("Request {RequestId} completed: {StatusCode} in {Duration}ms at {EndTime}",
                requestId,
                context.Response.StatusCode,
                stopwatch.ElapsedMilliseconds,
                endTime);
        }
    }
}

// Extension method for easy registration
public static class RequestLoggingMiddlewareExtensions
{
    public static IApplicationBuilder UseRequestLogging(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<RequestLoggingMiddleware>();
    }
}
```

### **Task 2: API Rate Limiting Middleware** (12 minutes)

Implement rate limiting to prevent API abuse:

```csharp
// IRateLimitService.cs
public interface IRateLimitService
{
    Task<bool> IsAllowedAsync(string clientId, string endpoint);
    Task<RateLimitInfo> GetRateLimitInfoAsync(string clientId, string endpoint);
}

// RateLimitInfo.cs
public class RateLimitInfo
{
    public bool IsAllowed { get; set; }
    public int RequestsRemaining { get; set; }
    public TimeSpan ResetTime { get; set; }
    public int TotalRequests { get; set; }
}

// InMemoryRateLimitService.cs
public class InMemoryRateLimitService : IRateLimitService
{
    private readonly Dictionary<string, ClientRateLimit> _rateLimits = new();
    private readonly SemaphoreSlim _semaphore = new(1, 1);
    private readonly int _maxRequests = 100; // per minute
    private readonly TimeSpan _timeWindow = TimeSpan.FromMinutes(1);

    public async Task<bool> IsAllowedAsync(string clientId, string endpoint)
    {
        var info = await GetRateLimitInfoAsync(clientId, endpoint);
        return info.IsAllowed;
    }

    public async Task<RateLimitInfo> GetRateLimitInfoAsync(string clientId, string endpoint)
    {
        await _semaphore.WaitAsync();
        try
        {
            var key = $"{clientId}:{endpoint}";
            var now = DateTime.UtcNow;

            if (!_rateLimits.TryGetValue(key, out var rateLimit))
            {
                rateLimit = new ClientRateLimit
                {
                    RequestCount = 0,
                    WindowStart = now
                };
                _rateLimits[key] = rateLimit;
            }

            // Reset window if expired
            if (now - rateLimit.WindowStart >= _timeWindow)
            {
                rateLimit.RequestCount = 0;
                rateLimit.WindowStart = now;
            }

            var isAllowed = rateLimit.RequestCount < _maxRequests;
            
            if (isAllowed)
            {
                rateLimit.RequestCount++;
            }

            var resetTime = _timeWindow - (now - rateLimit.WindowStart);
            
            return new RateLimitInfo
            {
                IsAllowed = isAllowed,
                RequestsRemaining = Math.Max(0, _maxRequests - rateLimit.RequestCount),
                ResetTime = resetTime,
                TotalRequests = rateLimit.RequestCount
            };
        }
        finally
        {
            _semaphore.Release();
        }
    }

    private class ClientRateLimit
    {
        public int RequestCount { get; set; }
        public DateTime WindowStart { get; set; }
    }
}

// RateLimitingMiddleware.cs
public class RateLimitingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IRateLimitService _rateLimitService;
    private readonly ILogger<RateLimitingMiddleware> _logger;

    public RateLimitingMiddleware(
        RequestDelegate next, 
        IRateLimitService rateLimitService,
        ILogger<RateLimitingMiddleware> logger)
    {
        _next = next;
        _rateLimitService = rateLimitService;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var clientId = GetClientId(context);
        var endpoint = context.Request.Path.Value ?? "/";
        
        var rateLimitInfo = await _rateLimitService.GetRateLimitInfoAsync(clientId, endpoint);

        // Add rate limit headers
        context.Response.Headers.Add("X-RateLimit-Limit", "100");
        context.Response.Headers.Add("X-RateLimit-Remaining", rateLimitInfo.RequestsRemaining.ToString());
        context.Response.Headers.Add("X-RateLimit-Reset", ((int)rateLimitInfo.ResetTime.TotalSeconds).ToString());

        if (!rateLimitInfo.IsAllowed)
        {
            _logger.LogWarning("Rate limit exceeded for client {ClientId} on endpoint {Endpoint}", clientId, endpoint);
            
            context.Response.StatusCode = 429; // Too Many Requests
            await context.Response.WriteAsync("Rate limit exceeded. Please try again later.");
            return; // Short-circuit the pipeline
        }

        await _next(context);
    }

    private string GetClientId(HttpContext context)
    {
        // Try to get client ID from various sources
        if (context.Request.Headers.TryGetValue("X-Client-Id", out var clientId))
        {
            return clientId.ToString();
        }

        // Fallback to IP address
        return context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
    }
}

// Extension method
public static class RateLimitingMiddlewareExtensions
{
    public static IApplicationBuilder UseRateLimiting(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<RateLimitingMiddleware>();
    }
}
```

### **Task 3: Request Correlation ID Middleware** (8 minutes)

Add correlation IDs to track requests across the application:

```csharp
// CorrelationIdMiddleware.cs
public class CorrelationIdMiddleware
{
    private readonly RequestDelegate _next;
    private const string CorrelationIdHeaderName = "X-Correlation-ID";

    public CorrelationIdMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Try to get correlation ID from header, otherwise generate new one
        var correlationId = GetCorrelationId(context);
        
        // Set correlation ID in HttpContext for use throughout the request
        context.Items["CorrelationId"] = correlationId;
        
        // Add correlation ID to response headers
        context.Response.Headers.Add(CorrelationIdHeaderName, correlationId);
        
        // Add correlation ID to logging scope
        using var scope = context.RequestServices
            .GetRequiredService<ILoggerFactory>()
            .CreateLogger<CorrelationIdMiddleware>()
            .BeginScope(new Dictionary<string, object> { ["CorrelationId"] = correlationId });

        await _next(context);
    }

    private string GetCorrelationId(HttpContext context)
    {
        // Check if correlation ID is provided in request header
        if (context.Request.Headers.TryGetValue(CorrelationIdHeaderName, out var correlationId) &&
            !string.IsNullOrEmpty(correlationId))
        {
            return correlationId.ToString();
        }

        // Generate new correlation ID
        return Guid.NewGuid().ToString();
    }
}

// Extension method
public static class CorrelationIdMiddlewareExtensions
{
    public static IApplicationBuilder UseCorrelationId(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<CorrelationIdMiddleware>();
    }
}

// Helper service to access correlation ID
public interface ICorrelationIdService
{
    string GetCorrelationId();
}

public class CorrelationIdService : ICorrelationIdService
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CorrelationIdService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public string GetCorrelationId()
    {
        return _httpContextAccessor.HttpContext?.Items["CorrelationId"]?.ToString() ?? "unknown";
    }
}
```

### **Task 4: Global Error Handling Middleware** (10 minutes)

Create comprehensive error handling middleware:

```csharp
// GlobalErrorHandlingMiddleware.cs
public class GlobalErrorHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalErrorHandlingMiddleware> _logger;
    private readonly IWebHostEnvironment _environment;

    public GlobalErrorHandlingMiddleware(
        RequestDelegate next, 
        ILogger<GlobalErrorHandlingMiddleware> logger,
        IWebHostEnvironment environment)
    {
        _next = next;
        _logger = logger;
        _environment = environment;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An unhandled exception occurred during request processing");
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/json";

        var response = new ErrorResponse();

        switch (exception)
        {
            case ValidationException validationEx:
                response.StatusCode = 400;
                response.Message = "Validation failed";
                response.Details = validationEx.Message;
                break;
            
            case UnauthorizedAccessException:
                response.StatusCode = 401;
                response.Message = "Unauthorized access";
                break;
            
            case ArgumentNotFoundException notFoundEx:
                response.StatusCode = 404;
                response.Message = "Resource not found";
                response.Details = notFoundEx.Message;
                break;
            
            case TimeoutException:
                response.StatusCode = 408;
                response.Message = "Request timeout";
                break;
            
            default:
                response.StatusCode = 500;
                response.Message = "An internal server error occurred";
                break;
        }

        // Add correlation ID if available
        if (context.Items.TryGetValue("CorrelationId", out var correlationId))
        {
            response.CorrelationId = correlationId.ToString();
        }

        // Include stack trace in development environment
        if (_environment.IsDevelopment())
        {
            response.Details = exception.ToString();
        }

        context.Response.StatusCode = response.StatusCode;
        
        var jsonResponse = JsonSerializer.Serialize(response, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        });

        await context.Response.WriteAsync(jsonResponse);
    }
}

// ErrorResponse.cs
public class ErrorResponse
{
    public int StatusCode { get; set; }
    public string Message { get; set; } = string.Empty;
    public string? Details { get; set; }
    public string? CorrelationId { get; set; }
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}

// Custom exceptions
public class ValidationException : Exception
{
    public ValidationException(string message) : base(message) { }
}

public class ArgumentNotFoundException : Exception
{
    public ArgumentNotFoundException(string message) : base(message) { }
}

// Extension method
public static class GlobalErrorHandlingMiddlewareExtensions
{
    public static IApplicationBuilder UseGlobalErrorHandling(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<GlobalErrorHandlingMiddleware>();
    }
}
```

### **Task 5: Configure Middleware Pipeline** (5 minutes)

Configure all middleware in the correct order in `Program.cs`:

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddHttpContextAccessor();
builder.Services.AddSingleton<IRateLimitService, InMemoryRateLimitService>();
builder.Services.AddScoped<ICorrelationIdService, CorrelationIdService>();

var app = builder.Build();

// Configure middleware pipeline - ORDER MATTERS!

// 1. Global error handling (should be first to catch all errors)
app.UseGlobalErrorHandling();

// 2. Request correlation ID (early to ensure all logs have correlation ID)
app.UseCorrelationId();

// 3. Request logging (after correlation ID is set)
app.UseRequestLogging();

// 4. Rate limiting (before expensive operations)
app.UseRateLimiting();

// 5. HTTPS redirection
app.UseHttpsRedirection();

// 6. Authentication and Authorization
app.UseAuthentication();
app.UseAuthorization();

// 7. Controllers (last in the pipeline)
app.MapControllers();

app.Run();
```

## 🧪 **Testing Your Middleware**

### **Create a Test Controller**:

```csharp
[ApiController]
[Route("api/[controller]")]
public class TestController : ControllerBase
{
    private readonly ICorrelationIdService _correlationIdService;
    private readonly ILogger<TestController> _logger;

    public TestController(ICorrelationIdService correlationIdService, ILogger<TestController> logger)
    {
        _correlationIdService = correlationIdService;
        _logger = logger;
    }

    [HttpGet("success")]
    public IActionResult Success()
    {
        _logger.LogInformation("Success endpoint called with correlation ID: {CorrelationId}", 
            _correlationIdService.GetCorrelationId());
        
        return Ok(new { 
            Message = "Success", 
            CorrelationId = _correlationIdService.GetCorrelationId(),
            Timestamp = DateTime.UtcNow
        });
    }

    [HttpGet("error")]
    public IActionResult SimulateError()
    {
        throw new ValidationException("This is a simulated validation error");
    }

    [HttpGet("not-found")]
    public IActionResult SimulateNotFound()
    {
        throw new ArgumentNotFoundException("The requested resource was not found");
    }

    [HttpGet("timeout")]
    public IActionResult SimulateTimeout()
    {
        throw new TimeoutException("The operation timed out");
    }
}
```

## 🔍 **Expected Results**

### **Request Logging**:
- ✅ All requests logged with correlation ID, method, path, and duration
- ✅ Response status codes logged
- ✅ Performance metrics captured

### **Rate Limiting**:
- ✅ Requests within limit proceed normally
- ✅ Excess requests return 429 status
- ✅ Rate limit headers added to all responses
- ✅ Different clients tracked separately

### **Correlation ID**:
- ✅ Unique correlation ID for each request
- ✅ Correlation ID in response headers
- ✅ Correlation ID available throughout request pipeline
- ✅ Reuses correlation ID if provided in request

### **Error Handling**:
- ✅ Different exception types mapped to appropriate HTTP status codes
- ✅ Consistent error response format
- ✅ Stack traces only in development environment
- ✅ Correlation IDs included in error responses

## 🎯 **Testing Scenarios**

1. **Normal Request Flow**:
   ```bash
   curl -X GET "http://localhost:5000/api/test/success"
   ```

2. **Rate Limiting Test**:
   ```bash
   # Make many requests quickly
   for i in {1..105}; do
     curl -X GET "http://localhost:5000/api/test/success" &
   done
   wait
   ```

3. **Error Handling Test**:
   ```bash
   curl -X GET "http://localhost:5000/api/test/error"
   curl -X GET "http://localhost:5000/api/test/not-found"
   ```

4. **Correlation ID Test**:
   ```bash
   curl -X GET "http://localhost:5000/api/test/success" -H "X-Correlation-ID: my-custom-id"
   ```

## 🎯 **Success Criteria**

**You've successfully completed this exercise when you can**:
- ✅ Create custom middleware that properly handles async operations
- ✅ Integrate middleware with dependency injection
- ✅ Configure middleware in the correct order
- ✅ Handle cross-cutting concerns effectively
- ✅ Test middleware behavior with various scenarios

## 🚀 **Bonus Challenges**

1. **Add request/response body logging** (be careful with sensitive data)
2. **Implement distributed rate limiting** using Redis
3. **Add request size limiting middleware**
4. **Create middleware for API versioning**
5. **Implement request caching middleware**

## 📚 **Next Steps**

After mastering custom middleware, you'll be ready for:
- Exercise 3: Advanced DI Patterns
- Middleware unit testing
- Performance optimization techniques
- Production middleware monitoring