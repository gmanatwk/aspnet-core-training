# Debugging and Troubleshooting - Comprehensive Resources

## 📚 Table of Contents
- [Quick Reference Guides](#quick-reference-guides)
- [Debugging Tools and Techniques](#debugging-tools-and-techniques)
- [Logging Best Practices](#logging-best-practices)
- [Exception Handling Patterns](#exception-handling-patterns)
- [Performance Monitoring](#performance-monitoring)
- [Production Debugging](#production-debugging)
- [Common Issues and Solutions](#common-issues-and-solutions)
- [External Resources](#external-resources)

---

## 🚀 Quick Reference Guides

### Essential Debugging Shortcuts

#### Visual Studio
| Shortcut | Action |
|----------|--------|
| `F5` | Start Debugging |
| `F9` | Toggle Breakpoint |
| `F10` | Step Over |
| `F11` | Step Into |
| `Shift + F11` | Step Out |
| `Ctrl + Shift + F9` | Clear All Breakpoints |
| `Ctrl + Alt + E` | Exception Settings |
| `Ctrl + Alt + W, L` | Locals Window |
| `Ctrl + Alt + W, A` | Autos Window |
| `Ctrl + Alt + W, W` | Watch Window |

#### VS Code
| Shortcut | Action |
|----------|--------|
| `F5` | Start Debugging |
| `F9` | Toggle Breakpoint |
| `F10` | Step Over |
| `F11` | Step Into |
| `Shift + F11` | Step Out |
| `Ctrl + Shift + F5` | Restart Debugging |
| `Ctrl + K, Ctrl + Shift + O` | Go to Symbol |

### Log Levels Quick Reference
| Level | When to Use | Example |
|-------|-------------|---------|
| **Trace** | Very detailed, temporary debugging | Method entry/exit, detailed flow |
| **Debug** | Development debugging information | Variable values, internal state |
| **Information** | General application flow | User actions, business events |
| **Warning** | Unexpected but recoverable situations | Deprecated API usage, fallback values |
| **Error** | Errors that don't stop the application | Handled exceptions, failed operations |
| **Critical** | Serious errors that may cause termination | Unhandled exceptions, system failures |

### HTTP Status Codes for Exceptions
| Exception Type | HTTP Status | Code |
|----------------|-------------|------|
| `ArgumentException` | Bad Request | 400 |
| `KeyNotFoundException` | Not Found | 404 |
| `UnauthorizedAccessException` | Unauthorized | 401 |
| `InvalidOperationException` | Bad Request | 400 |
| `TimeoutException` | Request Timeout | 408 |
| `HttpRequestException` | Bad Gateway | 502 |
| `Generic Exception` | Internal Server Error | 500 |

---

## 🔧 Debugging Tools and Techniques

### Breakpoint Strategies

#### 1. Conditional Breakpoints
```csharp
// Set condition: userId == "12345"
public ActionResult ProcessUser(string userId)
{
    // Breakpoint here will only trigger for specific user
    var result = ProcessUserData(userId);
    return Ok(result);
}
```

#### 2. Hit Count Breakpoints
- Useful for loops or frequently called methods
- Break on the Nth execution
- Example: Break on 100th iteration of a loop

#### 3. Function Breakpoints
- Break when entering specific methods
- Useful when you don't know the exact line
- Format: `Namespace.Class.Method`

### Advanced Debugging Techniques

#### 1. Call Stack Analysis
```csharp
// Understanding the call flow
public void Method1()
{
    Method2(); // Level 1
}

public void Method2()
{
    Method3(); // Level 2
}

public void Method3()
{
    // Breakpoint here - examine full call stack
    throw new Exception("Debug point");
}
```

#### 2. Exception Breakpoints
```csharp
// Configure debugger to break on:
// - All exceptions
// - Specific exception types
// - User-unhandled exceptions only
// - CLR exceptions

try
{
    // Risky operation
}
catch (SpecificException ex)
{
    // Debugger can break here before catch block
}
```

#### 3. Data Inspection Techniques
```csharp
// Use DataTips for quick inspection
var complexObject = new
{
    Id = 123,
    Items = new[] { "A", "B", "C" },
    Timestamp = DateTime.Now
};

// Watch window expressions:
// - complexObject.Items.Length
// - complexObject.Timestamp.ToString("yyyy-MM-dd")
// - complexObject.Items[0]
```

---

## 📝 Logging Best Practices

### Structured Logging Examples

#### ✅ Good Structured Logging
```csharp
// Parameterized messages
_logger.LogInformation("User {UserId} created order {OrderId} with {ItemCount} items and total {Total:C}",
    userId, orderId, itemCount, total);

// With timing information
using var activity = _logger.BeginScope("Processing order {OrderId}", orderId);
_logger.LogInformation("Order processing started");
// ... processing logic
_logger.LogInformation("Order processing completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
```

#### ❌ Poor Logging Practices
```csharp
// String interpolation (not structured)
_logger.LogInformation($"User {userId} created order {orderId}");

// Too verbose
_logger.LogInformation("Starting method ProcessOrder");
_logger.LogInformation("Validating input parameters");
_logger.LogInformation("Input validation completed");
// ... (every single step)

// Not enough context
_logger.LogError("Error occurred");
```

### Logging Context and Correlation

#### Request Correlation
```csharp
// In middleware
public async Task InvokeAsync(HttpContext context)
{
    var correlationId = context.TraceIdentifier;
    
    using var scope = _logger.BeginScope(new Dictionary<string, object>
    {
        ["CorrelationId"] = correlationId,
        ["UserId"] = context.User.Identity?.Name,
        ["RequestPath"] = context.Request.Path
    });
    
    await _next(context);
}
```

#### Scoped Logging
```csharp
// Business operation scope
using var operationScope = _logger.BeginScope("Order Processing {OrderId}", orderId);

_logger.LogInformation("Validating order");
// All logs in this scope will include OrderId

_logger.LogInformation("Processing payment");
// This will also include OrderId automatically

if (error)
{
    _logger.LogError("Payment processing failed");
    // Error log will include OrderId for easy tracking
}
```

### Performance-Conscious Logging

#### Conditional Logging
```csharp
// Expensive operation logging
if (_logger.IsEnabled(LogLevel.Debug))
{
    var expensiveDebugInfo = GenerateDetailedDiagnostics();
    _logger.LogDebug("Detailed diagnostics: {@DiagnosticInfo}", expensiveDebugInfo);
}

// Template for expensive string operations
_logger.LogDebug("Complex calculation result: {Result}", () => PerformComplexCalculation());
```

#### Log Level Configuration
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "Microsoft.Hosting.Lifetime": "Information",
      "YourApp.Controllers": "Debug",
      "YourApp.Services.ExternalApi": "Information"
    }
  }
}
```

---

## 🚨 Exception Handling Patterns

### Global Exception Handling

#### Comprehensive Exception Middleware
```csharp
public class GlobalExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalExceptionMiddleware> _logger;

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var response = CreateErrorResponse(context, exception);
        
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = response.Status;
        
        var json = JsonSerializer.Serialize(response);
        await context.Response.WriteAsync(json);
    }
}
```

### Exception Categories and Handling

#### 1. Business Logic Exceptions
```csharp
public class BusinessRuleException : Exception
{
    public string RuleName { get; }
    public object Context { get; }
    
    public BusinessRuleException(string ruleName, string message, object context = null) 
        : base(message)
    {
        RuleName = ruleName;
        Context = context;
    }
}

// Usage
if (order.Total > customer.CreditLimit)
{
    throw new BusinessRuleException("CreditLimit", 
        "Order exceeds customer credit limit", 
        new { OrderTotal = order.Total, CreditLimit = customer.CreditLimit });
}
```

#### 2. Validation Exceptions
```csharp
public class ValidationException : Exception
{
    public Dictionary<string, string[]> Errors { get; }
    
    public ValidationException(Dictionary<string, string[]> errors) 
        : base("Validation failed")
    {
        Errors = errors;
    }
}

// Usage
var errors = new Dictionary<string, string[]>();
if (string.IsNullOrEmpty(model.Email))
    errors.Add("Email", new[] { "Email is required" });
if (model.Age < 18)
    errors.Add("Age", new[] { "Must be at least 18 years old" });

if (errors.Any())
    throw new ValidationException(errors);
```

#### 3. External Service Exceptions
```csharp
public class ExternalServiceException : Exception
{
    public string ServiceName { get; }
    public int? StatusCode { get; }
    public TimeSpan? ResponseTime { get; }
    
    public ExternalServiceException(string serviceName, string message, 
        int? statusCode = null, TimeSpan? responseTime = null) : base(message)
    {
        ServiceName = serviceName;
        StatusCode = statusCode;
        ResponseTime = responseTime;
    }
}
```

### Retry Patterns

#### Exponential Backoff Retry
```csharp
public async Task<T> ExecuteWithRetryAsync<T>(
    Func<Task<T>> operation, 
    int maxRetries = 3, 
    TimeSpan baseDelay = default)
{
    if (baseDelay == default) baseDelay = TimeSpan.FromSeconds(1);
    
    for (int attempt = 0; attempt <= maxRetries; attempt++)
    {
        try
        {
            return await operation();
        }
        catch (Exception ex) when (IsTransientException(ex) && attempt < maxRetries)
        {
            var delay = TimeSpan.FromMilliseconds(
                baseDelay.TotalMilliseconds * Math.Pow(2, attempt));
            
            _logger.LogWarning("Attempt {Attempt} failed, retrying in {Delay}ms. Error: {Error}",
                attempt + 1, delay.TotalMilliseconds, ex.Message);
            
            await Task.Delay(delay);
        }
    }
    
    throw new InvalidOperationException("Max retries exceeded");
}

private bool IsTransientException(Exception ex)
{
    return ex is TimeoutException || 
           ex is HttpRequestException ||
           ex is SocketException;
}
```

---

## 📊 Performance Monitoring

### Performance Metrics Collection

#### Custom Performance Counters
```csharp
public class PerformanceTracker
{
    private readonly ILogger<PerformanceTracker> _logger;
    private readonly Dictionary<string, PerformanceCounter> _counters = new();
    
    public async Task<T> TrackAsync<T>(string operationName, Func<Task<T>> operation)
    {
        var stopwatch = Stopwatch.StartNew();
        var memoryBefore = GC.GetTotalMemory(false);
        
        try
        {
            var result = await operation();
            
            stopwatch.Stop();
            var memoryAfter = GC.GetTotalMemory(false);
            
            LogPerformanceMetrics(operationName, stopwatch.Elapsed, 
                memoryAfter - memoryBefore, true);
            
            return result;
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            LogPerformanceMetrics(operationName, stopwatch.Elapsed, 0, false);
            throw;
        }
    }
    
    private void LogPerformanceMetrics(string operation, TimeSpan duration, 
        long memoryUsed, bool success)
    {
        _logger.LogInformation("Performance: {Operation} took {Duration}ms, " +
                             "used {MemoryKB}KB memory, success: {Success}",
            operation, duration.TotalMilliseconds, memoryUsed / 1024, success);
    }
}
```

#### Application Insights Integration
```csharp
public class TelemetryTracker
{
    private readonly TelemetryClient _telemetryClient;
    
    public void TrackCustomEvent(string eventName, Dictionary<string, string> properties = null)
    {
        _telemetryClient.TrackEvent(eventName, properties);
    }
    
    public void TrackCustomMetric(string metricName, double value, 
        Dictionary<string, string> properties = null)
    {
        _telemetryClient.TrackMetric(metricName, value, properties);
    }
    
    public void TrackDependency(string dependencyName, string commandName, 
        DateTime startTime, TimeSpan duration, bool success)
    {
        _telemetryClient.TrackDependency(dependencyName, commandName, 
            startTime, duration, success);
    }
}
```

### Memory and Resource Monitoring

#### Memory Usage Tracking
```csharp
public class MemoryMonitor
{
    private readonly ILogger<MemoryMonitor> _logger;
    
    public void LogMemoryUsage(string context = "")
    {
        var process = Process.GetCurrentProcess();
        
        var memoryInfo = new
        {
            WorkingSet = process.WorkingSet64 / (1024 * 1024), // MB
            PrivateMemory = process.PrivateMemorySize64 / (1024 * 1024), // MB
            VirtualMemory = process.VirtualMemorySize64 / (1024 * 1024), // MB
            GCMemory = GC.GetTotalMemory(false) / (1024 * 1024), // MB
            Gen0Collections = GC.CollectionCount(0),
            Gen1Collections = GC.CollectionCount(1),
            Gen2Collections = GC.CollectionCount(2)
        };
        
        _logger.LogInformation("Memory usage {Context}: {@MemoryInfo}", 
            context, memoryInfo);
    }
}
```

---

## 🔍 Production Debugging

### Safe Production Debugging

#### Feature Flags for Debugging
```csharp
public class DebugFeatureFlags
{
    private readonly IConfiguration _config;
    
    public bool EnableVerboseLogging => 
        _config.GetValue<bool>("Debug:EnableVerboseLogging", false);
    
    public bool EnablePerformanceTracking => 
        _config.GetValue<bool>("Debug:EnablePerformanceTracking", false);
    
    public bool EnableDetailedErrors => 
        _config.GetValue<bool>("Debug:EnableDetailedErrors", false);
}

// Usage in controller
if (_debugFlags.EnableVerboseLogging)
{
    _logger.LogDebug("Detailed operation info: {@OperationData}", operationData);
}
```

#### Environment-Specific Error Details
```csharp
public ErrorResponse CreateErrorResponse(Exception ex, bool isDevelopment)
{
    return new ErrorResponse
    {
        Type = ex.GetType().Name,
        Title = GetErrorTitle(ex),
        Status = GetStatusCode(ex),
        Detail = isDevelopment ? ex.Message : GetSafeErrorMessage(ex),
        StackTrace = isDevelopment ? ex.StackTrace : null,
        InnerException = isDevelopment ? ex.InnerException?.Message : null
    };
}
```

### Remote Debugging Strategies

#### Correlation ID Tracking
```csharp
public class CorrelationMiddleware
{
    public async Task InvokeAsync(HttpContext context)
    {
        var correlationId = context.Request.Headers["X-Correlation-ID"].FirstOrDefault() 
                          ?? Guid.NewGuid().ToString();
        
        context.Items["CorrelationId"] = correlationId;
        context.Response.Headers.Add("X-Correlation-ID", correlationId);
        
        using var scope = _logger.BeginScope(new Dictionary<string, object>
        {
            ["CorrelationId"] = correlationId
        });
        
        await _next(context);
    }
}
```

#### Health Check Diagnostics
```csharp
public class DiagnosticHealthCheck : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, 
        CancellationToken cancellationToken = default)
    {
        var diagnostics = new Dictionary<string, object>
        {
            ["Timestamp"] = DateTime.UtcNow,
            ["MachineName"] = Environment.MachineName,
            ["ProcessId"] = Environment.ProcessId,
            ["ThreadCount"] = Process.GetCurrentProcess().Threads.Count,
            ["WorkingSetMB"] = Process.GetCurrentProcess().WorkingSet64 / (1024 * 1024),
            ["GCMemoryMB"] = GC.GetTotalMemory(false) / (1024 * 1024)
        };
        
        return HealthCheckResult.Healthy("Diagnostic information collected", diagnostics);
    }
}
```

---

## 🚨 Common Issues and Solutions

### Issue: High Memory Usage

#### Symptoms
- OutOfMemoryException
- Slow application performance
- High GC pressure

#### Diagnostic Steps
```csharp
// Memory leak detection
public class MemoryLeakDetector
{
    private readonly Timer _timer;
    private readonly List<long> _memorySnapshots = new();
    
    public MemoryLeakDetector()
    {
        _timer = new Timer(TakeMemorySnapshot, null, 
            TimeSpan.FromMinutes(1), TimeSpan.FromMinutes(1));
    }
    
    private void TakeMemorySnapshot(object state)
    {
        var memory = GC.GetTotalMemory(false);
        _memorySnapshots.Add(memory);
        
        if (_memorySnapshots.Count > 10)
        {
            var trend = CalculateMemoryTrend();
            if (trend > 0.1) // 10% increase trend
            {
                // Alert: Possible memory leak
            }
        }
    }
}
```

#### Solutions
- Use `using` statements for disposable resources
- Implement proper disposal patterns
- Avoid static collections that grow indefinitely
- Use weak references for caches
- Configure appropriate GC settings

### Issue: Slow Database Queries

#### Detection
```csharp
public class SlowQueryDetector : IInterceptor
{
    public async Task<InterceptionResult<DbDataReader>> ReaderExecutingAsync(
        DbCommand command, CommandEventData eventData, 
        InterceptionResult<DbDataReader> result, CancellationToken cancellationToken = default)
    {
        var stopwatch = Stopwatch.StartNew();
        var queryResult = await result.ConfigureAwait(false);
        stopwatch.Stop();
        
        if (stopwatch.ElapsedMilliseconds > 1000) // Slow query threshold
        {
            _logger.LogWarning("Slow query detected: {Query} took {ElapsedMs}ms",
                command.CommandText, stopwatch.ElapsedMilliseconds);
        }
        
        return queryResult;
    }
}
```

#### Solutions
- Add database indexes
- Optimize LINQ queries
- Use pagination
- Implement query caching
- Use async methods

### Issue: Deadlocks

#### Detection and Logging
```csharp
public async Task<T> ExecuteWithDeadlockRetryAsync<T>(Func<Task<T>> operation, int maxRetries = 3)
{
    for (int attempt = 0; attempt < maxRetries; attempt++)
    {
        try
        {
            return await operation();
        }
        catch (SqlException ex) when (ex.Number == 1205) // Deadlock
        {
            _logger.LogWarning("Deadlock detected on attempt {Attempt}, retrying...", attempt + 1);
            
            if (attempt == maxRetries - 1)
                throw;
            
            await Task.Delay(Random.Next(100, 1000)); // Random delay
        }
    }
    
    throw new InvalidOperationException("Should not reach here");
}
```

### Issue: External Service Timeouts

#### Circuit Breaker Pattern
```csharp
public class CircuitBreaker
{
    private int _failureCount = 0;
    private DateTime _lastFailureTime = DateTime.MinValue;
    private readonly int _threshold;
    private readonly TimeSpan _timeout;
    
    public async Task<T> ExecuteAsync<T>(Func<Task<T>> operation)
    {
        if (_failureCount >= _threshold && 
            DateTime.UtcNow - _lastFailureTime < _timeout)
        {
            throw new CircuitBreakerOpenException();
        }
        
        try
        {
            var result = await operation();
            _failureCount = 0; // Reset on success
            return result;
        }
        catch (Exception)
        {
            _failureCount++;
            _lastFailureTime = DateTime.UtcNow;
            throw;
        }
    }
}
```

---

## 📚 External Resources

### Official Documentation
- [ASP.NET Core Logging](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/logging/)
- [ASP.NET Core Error Handling](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/error-handling)
- [Health Checks in ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/health-checks)
- [Application Insights for ASP.NET Core](https://docs.microsoft.com/en-us/azure/azure-monitor/app/asp-net-core)

### Tools and Libraries
- [Serilog](https://serilog.net/) - Structured logging library
- [Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview) - Application performance monitoring
- [dotnet-trace](https://docs.microsoft.com/en-us/dotnet/core/diagnostics/dotnet-trace) - Performance tracing tool
- [dotnet-dump](https://docs.microsoft.com/en-us/dotnet/core/diagnostics/dotnet-dump) - Memory dump analysis
- [PerfView](https://github.com/Microsoft/perfview) - Advanced performance analysis

### Best Practices Articles
- [Logging best practices](https://docs.microsoft.com/en-us/dotnet/core/extensions/logging-providers)
- [Exception handling patterns](https://docs.microsoft.com/en-us/dotnet/standard/exceptions/best-practices-for-exceptions)
- [Performance optimization](https://docs.microsoft.com/en-us/aspnet/core/performance/performance-best-practices)

### Community Resources
- [ASP.NET Core GitHub Repository](https://github.com/dotnet/aspnetcore)
- [Stack Overflow ASP.NET Core Tag](https://stackoverflow.com/questions/tagged/asp.net-core)
- [Reddit r/dotnet](https://www.reddit.com/r/dotnet/)

---

## 🎯 Key Takeaways

1. **Debugging is a skill** - Practice regularly with different scenarios
2. **Logging is investment** - Good logging pays dividends in production
3. **Exception handling is user experience** - Handle errors gracefully
4. **Performance monitoring is proactive** - Catch issues before users do
5. **Production debugging requires planning** - Build in diagnostic capabilities
6. **Health checks are early warning** - Monitor system health continuously
7. **Correlation is critical** - Track requests across all layers

---

**💡 Remember**: Effective debugging and troubleshooting is not just about fixing problems—it's about building systems that are observable, maintainable, and resilient. Invest in these practices early and consistently throughout your application development lifecycle.
