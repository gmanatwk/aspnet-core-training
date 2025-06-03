# Module 6: Debugging and Troubleshooting

## 🎯 Learning Objectives
By the end of this module, participants will be able to:
- Set up effective debugging environments for ASP.NET Core applications
- Use debugging tools and techniques to identify and fix issues
- Implement comprehensive logging strategies
- Handle exceptions properly throughout the application
- Monitor application performance and health
- Troubleshoot common ASP.NET Core problems
- Use diagnostic tools and middleware for problem identification
- Debug both development and production environments

## 📚 Module Overview
**Duration**: 2 hours  
**Difficulty**: Intermediate  
**Prerequisites**: Module 1 (Introduction), Module 3 (Web APIs), Basic understanding of .NET debugging

### What You'll Learn
Debugging and troubleshooting are critical skills for any developer. This module covers comprehensive debugging strategies, logging implementation, exception handling, and monitoring techniques specific to ASP.NET Core applications.

## 🏗️ Topics Covered

### 1. Debugging Fundamentals
- Setting up debugging in Visual Studio and VS Code
- Breakpoints, watch windows, and call stack analysis
- Hot Reload and Edit and Continue features
- Remote debugging capabilities

### 2. Logging Implementation
- Built-in logging providers and configuration
- Structured logging with Serilog
- Log levels and filtering strategies
- Custom logging providers and formatters

### 3. Exception Handling
- Global exception handling middleware
- Custom exception types and handling strategies
- Problem Details (RFC 7807) implementation
- Exception logging and monitoring

### 4. Diagnostic Tools and Middleware
- Health checks implementation
- Application insights integration
- Custom diagnostic middleware
- Performance counters and metrics

### 5. Production Debugging
- Environment-specific configurations
- Remote debugging strategies
- Log aggregation and analysis
- Performance monitoring tools

### 6. Common Troubleshooting Scenarios
- Dependency injection issues
- Configuration problems
- Database connectivity issues
- Performance bottlenecks
- Memory leaks and resource management

## 🚀 Hands-On Lab: Comprehensive Debugging System

### Lab Overview
Build a complete debugging and monitoring system with the following features:
- Multi-level logging with different providers
- Global exception handling with detailed error responses
- Health checks for dependencies
- Performance monitoring and diagnostics
- Custom debugging middleware

### Lab Components
- **Logging**: Structured logging with file, console, and database providers
- **Exception Handling**: Global exception middleware with custom error responses
- **Health Checks**: Database, external API, and custom health checks
- **Diagnostics**: Custom middleware for request/response logging and performance tracking
- **Monitoring**: Application insights and custom metrics

## 📁 Project Structure
```
DebuggingDemo/
├── DebuggingDemo.csproj
├── Program.cs
├── appsettings.json
├── appsettings.Development.json
├── appsettings.Production.json
├── Middleware/
│   ├── ExceptionHandlingMiddleware.cs
│   ├── RequestLoggingMiddleware.cs
│   └── PerformanceMiddleware.cs
├── Services/
│   ├── HealthChecks/
│   │   ├── DatabaseHealthCheck.cs
│   │   ├── ExternalApiHealthCheck.cs
│   │   └── CustomHealthCheck.cs
│   ├── IExternalApiService.cs
│   ├── ExternalApiService.cs
│   └── DiagnosticService.cs
├── Models/
│   ├── ErrorResponse.cs
│   ├── DiagnosticInfo.cs
│   └── PerformanceMetrics.cs
├── Controllers/
│   ├── DiagnosticsController.cs
│   ├── HealthController.cs
│   └── TestController.cs
├── Extensions/
│   ├── LoggingExtensions.cs
│   ├── ExceptionExtensions.cs
│   └── ServiceCollectionExtensions.cs
└── Logs/
    └── (Generated log files)
```

## 🛠️ Key Implementation Features

### Structured Logging
```csharp
// Using Serilog with multiple sinks
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Debug()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Information)
    .Enrich.FromLogContext()
    .Enrich.WithMachineName()
    .Enrich.WithThreadId()
    .WriteTo.Console()
    .WriteTo.File("logs/app-.txt", rollingInterval: RollingInterval.Day)
    .WriteTo.MSSqlServer(connectionString, sinkOptions: sinkOpts, columnOptions: columnOpts)
    .CreateLogger();
```

### Global Exception Handling
```csharp
public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An unhandled exception occurred. RequestId: {RequestId}", 
                context.TraceIdentifier);
            await HandleExceptionAsync(context, ex);
        }
    }
}
```

### Health Checks Implementation
```csharp
// Custom health checks for various dependencies
public class DatabaseHealthCheck : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context, 
        CancellationToken cancellationToken = default)
    {
        try
        {
            // Check database connectivity
            await _context.Database.CanConnectAsync(cancellationToken);
            return HealthCheckResult.Healthy("Database connection is healthy");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy("Database connection failed", ex);
        }
    }
}
```

### Performance Monitoring
```csharp
public class PerformanceMiddleware
{
    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();
        
        await _next(context);
        
        stopwatch.Stop();
        
        if (stopwatch.ElapsedMilliseconds > _slowRequestThreshold)
        {
            _logger.LogWarning("Slow request detected: {Method} {Path} took {ElapsedMs}ms",
                context.Request.Method,
                context.Request.Path,
                stopwatch.ElapsedMilliseconds);
        }
    }
}
```

## 🎯 Learning Activities

### Activity 1: Setting Up Debugging Environment (15 minutes)
Configure debugging settings in Visual Studio/VS Code and practice using breakpoints.

### Activity 2: Implementing Structured Logging (20 minutes)
Set up Serilog with multiple providers and implement structured logging.

### Activity 3: Global Exception Handling (20 minutes)
Create middleware for global exception handling with custom error responses.

### Activity 4: Health Checks Configuration (15 minutes)
Implement health checks for database and external dependencies.

### Activity 5: Performance Monitoring Setup (15 minutes)
Create middleware to monitor request performance and log slow requests.

### Activity 6: Troubleshooting Common Issues (15 minutes)
Practice identifying and fixing common ASP.NET Core problems.

## 📋 Exercises

### Exercise 1: Debugging Fundamentals
**Objective**: Master debugging tools and techniques in ASP.NET Core
**Time**: 25 minutes
**Skills**: Breakpoints, variable inspection, call stack analysis

### Exercise 2: Comprehensive Logging Implementation
**Objective**: Implement multi-provider logging with different log levels
**Time**: 30 minutes
**Skills**: Serilog configuration, structured logging, log filtering

### Exercise 3: Exception Handling and Monitoring
**Objective**: Create robust exception handling with monitoring capabilities
**Time**: 25 minutes
**Skills**: Middleware development, exception handling, error reporting

## 🔧 Technology Stack
- **Framework**: ASP.NET Core 8.0
- **Logging**: Serilog, Microsoft.Extensions.Logging
- **Monitoring**: Application Insights, Health Checks
- **Debugging**: Visual Studio Debugger, dotnet-trace, dotnet-dump
- **Packages**: 
  - Serilog.AspNetCore
  - Serilog.Sinks.MSSqlServer
  - Microsoft.AspNetCore.Diagnostics.HealthChecks
  - Microsoft.ApplicationInsights.AspNetCore

## 📚 Key Debugging Techniques

### 1. Breakpoint Strategies
- **Conditional breakpoints**: Break only when specific conditions are met
- **Hit count breakpoints**: Break after a certain number of hits
- **Function breakpoints**: Break when entering specific methods
- **Exception breakpoints**: Break when exceptions are thrown

### 2. Advanced Debugging Features
- **DataTips**: Hover over variables to see their values
- **Watch windows**: Monitor specific variables during execution
- **Immediate window**: Execute code during debugging sessions
- **Call stack analysis**: Understand the execution path

### 3. Remote Debugging
- Configure remote debugging for production environments
- Debug applications running in containers
- Attach to running processes for live debugging

## 🔍 Logging Best Practices

### 1. Log Levels Usage
- **Trace**: Very detailed logs for diagnosing issues
- **Debug**: Information useful during development
- **Information**: General information about application flow
- **Warning**: Unexpected situations that don't stop the application
- **Error**: Error events that still allow the application to continue
- **Critical**: Serious errors that may cause the application to terminate

### 2. Structured Logging
```csharp
// Good: Structured logging with parameters
_logger.LogInformation("User {UserId} created order {OrderId} with total {Total:C}", 
    userId, orderId, total);

// Bad: String concatenation
_logger.LogInformation($"User {userId} created order {orderId} with total {total:C}");
```

### 3. Performance Considerations
- Use log level checks for expensive operations
- Implement asynchronous logging for high-throughput scenarios
- Configure appropriate log retention policies

## 🚨 Common Troubleshooting Scenarios

### 1. Dependency Injection Issues
- Service not registered
- Circular dependencies
- Incorrect service lifetime

### 2. Configuration Problems
- Missing configuration values
- Environment-specific configuration issues
- Connection string problems

### 3. Database Issues
- Connection timeouts
- Migration problems
- Query performance issues

### 4. Performance Problems
- Memory leaks
- Slow database queries
- Inefficient algorithms
- Resource contention

## 📊 Monitoring and Metrics

### Application Insights Integration
```csharp
// Track custom events and metrics
_telemetryClient.TrackEvent("OrderCreated", new Dictionary<string, string>
{
    ["UserId"] = userId.ToString(),
    ["OrderValue"] = orderValue.ToString()
});

_telemetryClient.TrackMetric("OrderProcessingTime", processingTime);
```

### Custom Health Checks
```csharp
// Register health checks
services.AddHealthChecks()
    .AddCheck<DatabaseHealthCheck>("database")
    .AddCheck<ExternalApiHealthCheck>("external-api")
    .AddUrlGroup(new Uri("https://api.example.com/health"), "external-service");
```

## ✅ Module Completion Checklist
- [ ] Understand debugging tools and techniques
- [ ] Can implement structured logging with multiple providers
- [ ] Able to create global exception handling middleware
- [ ] Proficient in health checks implementation
- [ ] Know how to monitor application performance
- [ ] Can troubleshoot common ASP.NET Core issues
- [ ] Understand production debugging strategies
- [ ] Completed all hands-on exercises
- [ ] Built the complete debugging and monitoring system

## 🔄 What's Next?
After completing this module, you'll be ready for:
- **Module 7**: Testing Applications (including debugging tests)
- **Module 8**: Performance Optimization (advanced performance troubleshooting)
- **Module 10**: Security Fundamentals (security-related debugging)

---

**Note**: Effective debugging and troubleshooting skills are essential for maintaining robust ASP.NET Core applications. This module provides practical, real-world techniques you'll use daily as a developer.
