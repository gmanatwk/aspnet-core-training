#!/usr/bin/env pwsh

# Module 12: Dependency Injection and Middleware - Interactive Exercise Launcher (PowerShell)
# This script provides guided, hands-on exercises for DI and middleware in ASP.NET Core

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
$ProjectName = "DIMiddlewareDemo"
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
    Write-Host "🔧 DI/MIDDLEWARE CONCEPT: $Concept" -ForegroundColor Magenta
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

    Write-Host "🎯 DI/Middleware Objectives for ${Exercise}:" -ForegroundColor Blue

    switch ($Exercise) {
        "exercise01" {
            Write-Host "Service Lifetime Exploration:" -ForegroundColor Cyan
            Write-Host "  🔧 1. Understanding service lifetimes (Singleton, Scoped, Transient)"
            Write-Host "  🔧 2. Service registration patterns"
            Write-Host "  🔧 3. Dependency resolution and injection"
            Write-Host "  🔧 4. Service lifetime impact on application behavior"
            Write-Host ""
            Write-Host "DI concepts:" -ForegroundColor Yellow
            Write-Host "  • Service container fundamentals"
            Write-Host "  • Lifetime management strategies"
            Write-Host "  • Constructor injection patterns"
            Write-Host "  • Service locator anti-pattern"
        }
        "exercise02" {
            Write-Host "Custom Middleware Development:" -ForegroundColor Cyan
            Write-Host "  🔧 1. Middleware pipeline understanding"
            Write-Host "  🔧 2. Custom middleware implementation"
            Write-Host "  🔧 3. Request/response processing"
            Write-Host "  🔧 4. Middleware ordering and dependencies"
            Write-Host ""
            Write-Host "Middleware concepts:" -ForegroundColor Yellow
            Write-Host "  • Request pipeline flow"
            Write-Host "  • Middleware composition"
            Write-Host "  • Exception handling middleware"
            Write-Host "  • Cross-cutting concerns"
        }
        "exercise03" {
            Write-Host "Advanced DI Patterns:" -ForegroundColor Cyan
            Write-Host "  🔧 1. Factory pattern implementation"
            Write-Host "  🔧 2. Decorator pattern with DI"
            Write-Host "  🔧 3. Generic service registration"
            Write-Host "  🔧 4. Conditional service registration"
            Write-Host ""
            Write-Host "Advanced concepts:" -ForegroundColor Yellow
            Write-Host "  • Service factory patterns"
            Write-Host "  • Decorator and proxy patterns"
            Write-Host "  • Open generic types"
            Write-Host "  • Service provider scoping"
        }
        "exercise04" {
            Write-Host "Production Integration:" -ForegroundColor Cyan
            Write-Host "  🔧 1. Configuration-based service registration"
            Write-Host "  🔧 2. Health checks integration"
            Write-Host "  🔧 3. Logging and monitoring middleware"
            Write-Host "  🔧 4. Performance optimization patterns"
            Write-Host ""
            Write-Host "Production concepts:" -ForegroundColor Yellow
            Write-Host "  • Configuration patterns"
            Write-Host "  • Health monitoring"
            Write-Host "  • Performance middleware"
            Write-Host "  • Production diagnostics"
        }
    }
    Write-Host ""
}

# Function to show what will be created
function Show-CreationOverview {
    param([string]$Exercise)

    Write-Host "📋 DI/Middleware Components for ${Exercise}:" -ForegroundColor Cyan

    switch ($Exercise) {
        "exercise01" {
            Write-Host "• Service lifetime demonstration classes"
            Write-Host "• Interface and implementation examples"
            Write-Host "• Service registration configurations"
            Write-Host "• Lifetime behavior test controllers"
            Write-Host "• Dependency injection examples"
        }
        "exercise02" {
            Write-Host "• Custom middleware implementations"
            Write-Host "• Request/response logging middleware"
            Write-Host "• Exception handling middleware"
            Write-Host "• Performance timing middleware"
            Write-Host "• Middleware extension methods"
        }
        "exercise03" {
            Write-Host "• Factory pattern implementations"
            Write-Host "• Decorator pattern examples"
            Write-Host "• Generic service registrations"
            Write-Host "• Conditional service configurations"
            Write-Host "• Advanced DI scenarios"
        }
        "exercise04" {
            Write-Host "• Configuration-driven service setup"
            Write-Host "• Health check implementations"
            Write-Host "• Monitoring and metrics middleware"
            Write-Host "• Production-ready configurations"
            Write-Host "• Performance optimization examples"
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
    Write-Host "Module 12 - Dependency Injection and Middleware" -ForegroundColor Cyan
    Write-Host "Available Exercises:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  - exercise01: Service Lifetime Exploration"
    Write-Host "  - exercise02: Custom Middleware Development"
    Write-Host "  - exercise03: Advanced DI Patterns"
    Write-Host "  - exercise04: Production Integration"
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
$ValidExercises = @("exercise01", "exercise02", "exercise03", "exercise04")
if ($ExerciseName -notin $ValidExercises) {
    Write-Error "Unknown exercise: $ExerciseName"
    Write-Host ""
    Show-Exercises
    exit 1
}

# Welcome message
Write-Host "🔧 Module 12: Dependency Injection and Middleware" -ForegroundColor Magenta
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
Write-Info "Checking DI and middleware prerequisites..."

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
    if ($ExerciseName -in @("exercise02", "exercise03", "exercise04")) {
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
        # Exercise 1: Service Lifetime Exploration

        Explain-Concept "Service Lifetimes in ASP.NET Core" @"
Service lifetimes control how long service instances live:
• Singleton: One instance for the entire application lifetime
• Scoped: One instance per HTTP request (or scope)
• Transient: New instance every time the service is requested
• Understanding lifetime helps prevent memory leaks and ensures correct behavior
"@

        if (-not $SkipProjectCreation) {
            Write-Info "Creating new ASP.NET Core Web API project..."
            dotnet new webapi -n $ProjectName --framework net8.0
            Set-Location $ProjectName

            # Remove default WeatherForecast files
            Remove-Item -Path "WeatherForecast.cs" -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "Controllers/WeatherForecastController.cs" -Force -ErrorAction SilentlyContinue
        }

        # Create service interfaces and implementations
        Create-FileInteractive "Services/ICounterService.cs" @'
namespace DIMiddlewareDemo.Services;

public interface ICounterService
{
    int GetCurrentCount();
    void Increment();
    string ServiceId { get; }
    DateTime CreatedAt { get; }
}
'@ "Counter service interface for demonstrating different lifetimes"

        Create-FileInteractive "Services/CounterServices.cs" @'
namespace DIMiddlewareDemo.Services;

public class SingletonCounterService : ICounterService, IDisposable
{
    private int _count = 0;
    public string ServiceId { get; } = Guid.NewGuid().ToString("N")[..8];
    public DateTime CreatedAt { get; } = DateTime.UtcNow;

    public int GetCurrentCount() => _count;

    public void Increment() => Interlocked.Increment(ref _count);

    public void Dispose()
    {
        Console.WriteLine($"SingletonCounterService {ServiceId} disposed at {DateTime.UtcNow}");
    }
}

public class ScopedCounterService : ICounterService, IDisposable
{
    private int _count = 0;
    public string ServiceId { get; } = Guid.NewGuid().ToString("N")[..8];
    public DateTime CreatedAt { get; } = DateTime.UtcNow;

    public int GetCurrentCount() => _count;

    public void Increment() => _count++;

    public void Dispose()
    {
        Console.WriteLine($"ScopedCounterService {ServiceId} disposed at {DateTime.UtcNow}");
    }
}

public class TransientCounterService : ICounterService, IDisposable
{
    private int _count = 0;
    public string ServiceId { get; } = Guid.NewGuid().ToString("N")[..8];
    public DateTime CreatedAt { get; } = DateTime.UtcNow;

    public int GetCurrentCount() => _count;

    public void Increment() => _count++;

    public void Dispose()
    {
        Console.WriteLine($"TransientCounterService {ServiceId} disposed at {DateTime.UtcNow}");
    }
}
'@ "Counter service implementations demonstrating different lifetime behaviors with disposal"

        # Create lifetime comparison service
        Create-FileInteractive "Services/ILifetimeComparisonService.cs" @'
namespace DIMiddlewareDemo.Services;

public interface ILifetimeComparisonService
{
    object GetLifetimeComparison();
}

public class LifetimeComparisonService : ILifetimeComparisonService
{
    private readonly SingletonCounterService _singleton;
    private readonly ScopedCounterService _scoped;
    private readonly TransientCounterService _transient;

    public LifetimeComparisonService(
        SingletonCounterService singleton,
        ScopedCounterService scoped,
        TransientCounterService transient)
    {
        _singleton = singleton;
        _scoped = scoped;
        _transient = transient;
    }

    public object GetLifetimeComparison()
    {
        _singleton.Increment();
        _scoped.Increment();
        _transient.Increment();

        return new
        {
            ServiceCreatedAt = DateTime.UtcNow,
            Singleton = new
            {
                _singleton.ServiceId,
                Count = _singleton.GetCurrentCount(),
                _singleton.CreatedAt
            },
            Scoped = new
            {
                _scoped.ServiceId,
                Count = _scoped.GetCurrentCount(),
                _scoped.CreatedAt
            },
            Transient = new
            {
                _transient.ServiceId,
                Count = _transient.GetCurrentCount(),
                _transient.CreatedAt
            }
        };
    }
}
'@ "Lifetime comparison service for advanced testing"

        # Create lifetime testing controller
        Create-FileInteractive "Controllers/LifetimeController.cs" @'
using Microsoft.AspNetCore.Mvc;
using DIMiddlewareDemo.Services;

namespace DIMiddlewareDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class LifetimeController : ControllerBase
{
    private readonly SingletonCounterService _singleton1;
    private readonly SingletonCounterService _singleton2;
    private readonly ScopedCounterService _scoped1;
    private readonly ScopedCounterService _scoped2;
    private readonly TransientCounterService _transient1;
    private readonly TransientCounterService _transient2;
    private readonly ILifetimeComparisonService _comparisonService;

    public LifetimeController(
        SingletonCounterService singleton1,
        SingletonCounterService singleton2,
        ScopedCounterService scoped1,
        ScopedCounterService scoped2,
        TransientCounterService transient1,
        TransientCounterService transient2,
        ILifetimeComparisonService comparisonService)
    {
        _singleton1 = singleton1;
        _singleton2 = singleton2;
        _scoped1 = scoped1;
        _scoped2 = scoped2;
        _transient1 = transient1;
        _transient2 = transient2;
        _comparisonService = comparisonService;
    }

    [HttpGet("test-lifetimes")]
    public IActionResult TestLifetimes()
    {
        // Increment all counters
        _singleton1.Increment();
        _scoped1.Increment();
        _transient1.Increment();

        var result = new
        {
            RequestId = HttpContext.TraceIdentifier,
            Timestamp = DateTime.UtcNow,
            Singleton = new
            {
                Instance1_Id = _singleton1.ServiceId,
                Instance1_Count = _singleton1.GetCurrentCount(),
                Instance1_Created = _singleton1.CreatedAt,
                Instance2_Id = _singleton2.ServiceId,
                Instance2_Count = _singleton2.GetCurrentCount(),
                Instance2_Created = _singleton2.CreatedAt,
                AreSameInstance = ReferenceEquals(_singleton1, _singleton2)
            },
            Scoped = new
            {
                Instance1_Id = _scoped1.ServiceId,
                Instance1_Count = _scoped1.GetCurrentCount(),
                Instance1_Created = _scoped1.CreatedAt,
                Instance2_Id = _scoped2.ServiceId,
                Instance2_Count = _scoped2.GetCurrentCount(),
                Instance2_Created = _scoped2.CreatedAt,
                AreSameInstance = ReferenceEquals(_scoped1, _scoped2)
            },
            Transient = new
            {
                Instance1_Id = _transient1.ServiceId,
                Instance1_Count = _transient1.GetCurrentCount(),
                Instance1_Created = _transient1.CreatedAt,
                Instance2_Id = _transient2.ServiceId,
                Instance2_Count = _transient2.GetCurrentCount(),
                Instance2_Created = _transient2.CreatedAt,
                AreSameInstance = ReferenceEquals(_transient1, _transient2)
            }
        };

        return Ok(result);
    }

    [HttpGet("comparison")]
    public IActionResult GetComparison()
    {
        return Ok(_comparisonService.GetLifetimeComparison());
    }
}
'@ "Comprehensive lifetime testing controller with multiple service injections"

        # Create Program.cs with service registrations
        Create-FileInteractive "Program.cs" @'
using DIMiddlewareDemo.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register services with different lifetimes
builder.Services.AddSingleton<SingletonCounterService>();
builder.Services.AddScoped<ScopedCounterService>();
builder.Services.AddTransient<TransientCounterService>();

// Register composite service
builder.Services.AddScoped<ILifetimeComparisonService, LifetimeComparisonService>();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
'@ "Program.cs with proper service lifetime registrations"

        Write-Success "✅ Exercise 1: Service Lifetime Exploration completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Build and run: dotnet run" -ForegroundColor Cyan
        Write-Host "2. Test lifetimes: GET /api/lifetime/test-lifetimes" -ForegroundColor Cyan
        Write-Host "3. Compare services: GET /api/lifetime/comparison" -ForegroundColor Cyan
        Write-Host "4. Make multiple requests to observe lifetime behaviors" -ForegroundColor Cyan
    }

    "exercise02" {
        # Exercise 2: Custom Middleware Development

        Explain-Concept "ASP.NET Core Middleware Pipeline" @"
Middleware components form a pipeline that processes HTTP requests:
• Each middleware can process requests before and after the next component
• Middleware order matters - earlier middleware wraps later middleware
• Custom middleware can handle cross-cutting concerns like logging, authentication
• Middleware can short-circuit the pipeline or pass control to the next component
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 2 requires Exercise 1 to be completed first!"
            Write-Info "Please run: .\launch-exercises.ps1 exercise01"
            exit 1
        }

        # Create request logging middleware
        Create-FileInteractive "Middleware/RequestLoggingMiddleware.cs" @'
namespace DIMiddlewareDemo.Middleware;

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

public static class RequestLoggingMiddlewareExtensions
{
    public static IApplicationBuilder UseRequestLogging(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<RequestLoggingMiddleware>();
    }
}
'@ "Enhanced request logging middleware with detailed timing"

        # Create rate limiting service and middleware
        Create-FileInteractive "Services/IRateLimitService.cs" @'
namespace DIMiddlewareDemo.Services;

public interface IRateLimitService
{
    Task<bool> IsAllowedAsync(string clientId, string endpoint);
    Task<RateLimitInfo> GetRateLimitInfoAsync(string clientId, string endpoint);
}

public class RateLimitInfo
{
    public bool IsAllowed { get; set; }
    public int RequestsRemaining { get; set; }
    public TimeSpan ResetTime { get; set; }
    public int TotalRequests { get; set; }
}

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
'@ "Rate limiting service with in-memory storage"

        # Create rate limiting middleware
        Create-FileInteractive "Middleware/RateLimitingMiddleware.cs" @'
namespace DIMiddlewareDemo.Middleware;

using DIMiddlewareDemo.Services;

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

public static class RateLimitingMiddlewareExtensions
{
    public static IApplicationBuilder UseRateLimiting(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<RateLimitingMiddleware>();
    }
}
'@ "Rate limiting middleware with configurable limits"

        # Create correlation ID middleware
        Create-FileInteractive "Middleware/CorrelationIdMiddleware.cs" @'
namespace DIMiddlewareDemo.Middleware;

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

public static class CorrelationIdMiddlewareExtensions
{
    public static IApplicationBuilder UseCorrelationId(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<CorrelationIdMiddleware>();
    }
}
'@ "Correlation ID middleware for request tracking"

        Write-Success "✅ Exercise 2: Custom Middleware Development completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Add all middleware to the pipeline in Program.cs" -ForegroundColor Cyan
        Write-Host "2. Test rate limiting with multiple requests" -ForegroundColor Cyan
        Write-Host "3. Verify correlation IDs in logs and responses" -ForegroundColor Cyan
        Write-Host "4. Test middleware ordering and pipeline flow" -ForegroundColor Cyan
    }

    "exercise03" {
        # Exercise 3: Advanced DI Patterns

        Explain-Concept "Advanced Dependency Injection Patterns" @"
Advanced DI patterns solve complex scenarios:
• Factory Pattern: Create services dynamically based on runtime conditions
• Decorator Pattern: Add behavior to existing services without modifying them
• Generic Services: Register open generic types for flexible service resolution
• Conditional Registration: Register services based on configuration or environment
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 3 requires Exercises 1 and 2 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03"
            exit 1
        }

        # Create notification services and factory pattern
        Create-FileInteractive "Services/NotificationServices.cs" @'
namespace DIMiddlewareDemo.Services;

public interface INotificationService
{
    Task SendAsync(string message, string recipient);
}

public class EmailNotificationService : INotificationService
{
    private readonly ILogger<EmailNotificationService> _logger;

    public EmailNotificationService(ILogger<EmailNotificationService> logger)
    {
        _logger = logger;
    }

    public async Task SendAsync(string message, string recipient)
    {
        _logger.LogInformation("Sending email to {Recipient}: {Message}", recipient, message);
        await Task.Delay(100); // Simulate async operation
    }
}

public class SmsNotificationService : INotificationService
{
    private readonly ILogger<SmsNotificationService> _logger;

    public SmsNotificationService(ILogger<SmsNotificationService> logger)
    {
        _logger = logger;
    }

    public async Task SendAsync(string message, string recipient)
    {
        _logger.LogInformation("Sending SMS to {Recipient}: {Message}", recipient, message);
        await Task.Delay(50); // Simulate async operation
    }
}

public interface INotificationFactory
{
    INotificationService CreateNotificationService(string type);
}

public class NotificationFactory : INotificationFactory
{
    private readonly IServiceProvider _serviceProvider;

    public NotificationFactory(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public INotificationService CreateNotificationService(string type)
    {
        return type.ToLower() switch
        {
            "email" => _serviceProvider.GetRequiredService<EmailNotificationService>(),
            "sms" => _serviceProvider.GetRequiredService<SmsNotificationService>(),
            _ => throw new ArgumentException($"Unknown notification type: {type}")
        };
    }
}
'@ "Factory pattern implementation for creating notification services"

        # Create decorator pattern example
        Create-FileInteractive "Services/NotificationDecorators.cs" @'
namespace DIMiddlewareDemo.Services;

// Decorator for logging notification attempts
public class LoggingNotificationDecorator : INotificationService
{
    private readonly INotificationService _inner;
    private readonly ILogger<LoggingNotificationDecorator> _logger;

    public LoggingNotificationDecorator(INotificationService inner, ILogger<LoggingNotificationDecorator> logger)
    {
        _inner = inner;
        _logger = logger;
    }

    public async Task SendAsync(string message, string recipient)
    {
        _logger.LogInformation("Starting notification send to {Recipient}", recipient);
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();

        try
        {
            await _inner.SendAsync(message, recipient);
            stopwatch.Stop();
            _logger.LogInformation("Notification sent successfully to {Recipient} in {ElapsedMs}ms",
                recipient, stopwatch.ElapsedMilliseconds);
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            _logger.LogError(ex, "Failed to send notification to {Recipient} after {ElapsedMs}ms",
                recipient, stopwatch.ElapsedMilliseconds);
            throw;
        }
    }
}

// Decorator for retry logic
public class RetryNotificationDecorator : INotificationService
{
    private readonly INotificationService _inner;
    private readonly ILogger<RetryNotificationDecorator> _logger;
    private readonly int _maxRetries;

    public RetryNotificationDecorator(INotificationService inner, ILogger<RetryNotificationDecorator> logger, int maxRetries = 3)
    {
        _inner = inner;
        _logger = logger;
        _maxRetries = maxRetries;
    }

    public async Task SendAsync(string message, string recipient)
    {
        var attempt = 0;
        while (attempt < _maxRetries)
        {
            try
            {
                await _inner.SendAsync(message, recipient);
                return; // Success
            }
            catch (Exception ex) when (attempt < _maxRetries - 1)
            {
                attempt++;
                _logger.LogWarning(ex, "Notification attempt {Attempt} failed for {Recipient}, retrying...",
                    attempt, recipient);
                await Task.Delay(TimeSpan.FromSeconds(Math.Pow(2, attempt))); // Exponential backoff
            }
        }
    }
}
'@ "Decorator pattern implementations for cross-cutting concerns"

        # Create generic repository pattern
        Create-FileInteractive "Services/GenericRepository.cs" @'
namespace DIMiddlewareDemo.Services;

public interface IEntity
{
    int Id { get; set; }
}

public interface IRepository<T> where T : class, IEntity
{
    Task<T?> GetByIdAsync(int id);
    Task<IEnumerable<T>> GetAllAsync();
    Task<T> AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(int id);
}

public class InMemoryRepository<T> : IRepository<T> where T : class, IEntity
{
    private readonly List<T> _entities = new();
    private readonly SemaphoreSlim _semaphore = new(1, 1);
    private int _nextId = 1;

    public async Task<T?> GetByIdAsync(int id)
    {
        await _semaphore.WaitAsync();
        try
        {
            return _entities.FirstOrDefault(e => e.Id == id);
        }
        finally
        {
            _semaphore.Release();
        }
    }

    public async Task<IEnumerable<T>> GetAllAsync()
    {
        await _semaphore.WaitAsync();
        try
        {
            return _entities.ToList();
        }
        finally
        {
            _semaphore.Release();
        }
    }

    public async Task<T> AddAsync(T entity)
    {
        await _semaphore.WaitAsync();
        try
        {
            entity.Id = _nextId++;
            _entities.Add(entity);
            return entity;
        }
        finally
        {
            _semaphore.Release();
        }
    }

    public async Task UpdateAsync(T entity)
    {
        await _semaphore.WaitAsync();
        try
        {
            var existing = _entities.FirstOrDefault(e => e.Id == entity.Id);
            if (existing != null)
            {
                var index = _entities.IndexOf(existing);
                _entities[index] = entity;
            }
        }
        finally
        {
            _semaphore.Release();
        }
    }

    public async Task DeleteAsync(int id)
    {
        await _semaphore.WaitAsync();
        try
        {
            var entity = _entities.FirstOrDefault(e => e.Id == id);
            if (entity != null)
            {
                _entities.Remove(entity);
            }
        }
        finally
        {
            _semaphore.Release();
        }
    }
}

// Example entity
public class User : IEntity
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
'@ "Generic repository pattern with in-memory implementation"

        Write-Success "✅ Exercise 3: Advanced DI Patterns completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Register factory, decorators, and generic services in Program.cs" -ForegroundColor Cyan
        Write-Host "2. Test decorator pattern with notification services" -ForegroundColor Cyan
        Write-Host "3. Use generic repository with different entity types" -ForegroundColor Cyan
        Write-Host "4. Experiment with conditional service registration" -ForegroundColor Cyan
    }

    "exercise04" {
        # Exercise 4: Production Integration

        Explain-Concept "Production-Ready DI and Middleware" @"
Production applications require robust DI and middleware configurations:
• Configuration-based service registration for different environments
• Health checks to monitor service dependencies
• Performance monitoring middleware for observability
• Proper error handling and logging throughout the pipeline
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 4 requires Exercises 1, 2, and 3 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04"
            exit 1
        }

        # Create health check service
        Create-FileInteractive "Services/DatabaseHealthCheck.cs" @'
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace DIMiddlewareDemo.Services;

public class DatabaseHealthCheck : IHealthCheck
{
    private readonly ILogger<DatabaseHealthCheck> _logger;

    public DatabaseHealthCheck(ILogger<DatabaseHealthCheck> logger)
    {
        _logger = logger;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        try
        {
            // Simulate database connectivity check
            await Task.Delay(100, cancellationToken);

            _logger.LogInformation("Database health check passed");
            return HealthCheckResult.Healthy("Database is responsive");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Database health check failed");
            return HealthCheckResult.Unhealthy("Database is not responsive", ex);
        }
    }
}
'@ "Health check implementation for monitoring database connectivity"

        # Create additional health checks
        Create-FileInteractive "Services/ExternalApiHealthCheck.cs" @'
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace DIMiddlewareDemo.Services;

public class ExternalApiHealthCheck : IHealthCheck
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<ExternalApiHealthCheck> _logger;

    public ExternalApiHealthCheck(HttpClient httpClient, ILogger<ExternalApiHealthCheck> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        try
        {
            // Simulate external API health check
            await Task.Delay(100, cancellationToken);

            // In real scenario, you would make actual HTTP request
            var isApiHealthy = true; // Simulate successful API response

            if (isApiHealthy)
            {
                _logger.LogInformation("External API health check passed");
                return HealthCheckResult.Healthy("External API is responding");
            }
            else
            {
                _logger.LogWarning("External API health check failed");
                return HealthCheckResult.Degraded("External API is slow or partially available");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "External API health check threw exception");
            return HealthCheckResult.Unhealthy("External API health check failed", ex);
        }
    }
}
'@ "External API health check for monitoring third-party dependencies"

        # Create metrics service
        Create-FileInteractive "Services/MetricsService.cs" @'
using System.Diagnostics.Metrics;

namespace DIMiddlewareDemo.Services;

public interface IMetricsService
{
    void IncrementRequestCount(string endpoint, string method);
    void RecordRequestDuration(string endpoint, string method, double durationMs);
    void IncrementErrorCount(string endpoint, string method, int statusCode);
}

public class MetricsService : IMetricsService, IDisposable
{
    private readonly Meter _meter;
    private readonly Counter<long> _requestCounter;
    private readonly Histogram<double> _requestDuration;
    private readonly Counter<long> _errorCounter;

    public MetricsService()
    {
        _meter = new Meter("DIMiddlewareDemo", "1.0.0");
        _requestCounter = _meter.CreateCounter<long>("http_requests_total", "count", "Total number of HTTP requests");
        _requestDuration = _meter.CreateHistogram<double>("http_request_duration_ms", "ms", "Duration of HTTP requests in milliseconds");
        _errorCounter = _meter.CreateCounter<long>("http_errors_total", "count", "Total number of HTTP errors");
    }

    public void IncrementRequestCount(string endpoint, string method)
    {
        _requestCounter.Add(1, new KeyValuePair<string, object?>("endpoint", endpoint), new KeyValuePair<string, object?>("method", method));
    }

    public void RecordRequestDuration(string endpoint, string method, double durationMs)
    {
        _requestDuration.Record(durationMs, new KeyValuePair<string, object?>("endpoint", endpoint), new KeyValuePair<string, object?>("method", method));
    }

    public void IncrementErrorCount(string endpoint, string method, int statusCode)
    {
        _errorCounter.Add(1,
            new KeyValuePair<string, object?>("endpoint", endpoint),
            new KeyValuePair<string, object?>("method", method),
            new KeyValuePair<string, object?>("status_code", statusCode));
    }

    public void Dispose()
    {
        _meter?.Dispose();
    }
}
'@ "Metrics service for collecting application performance data"

        # Create monitoring middleware
        Create-FileInteractive "Middleware/MonitoringMiddleware.cs" @'
namespace DIMiddlewareDemo.Middleware;

using DIMiddlewareDemo.Services;

public class MonitoringMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IMetricsService _metricsService;
    private readonly ILogger<MonitoringMiddleware> _logger;

    public MonitoringMiddleware(RequestDelegate next, IMetricsService metricsService, ILogger<MonitoringMiddleware> logger)
    {
        _next = next;
        _metricsService = metricsService;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var endpoint = context.Request.Path.Value ?? "/";
        var method = context.Request.Method;
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();

        try
        {
            _metricsService.IncrementRequestCount(endpoint, method);

            await _next(context);

            stopwatch.Stop();
            _metricsService.RecordRequestDuration(endpoint, method, stopwatch.ElapsedMilliseconds);

            // Log errors for non-success status codes
            if (context.Response.StatusCode >= 400)
            {
                _metricsService.IncrementErrorCount(endpoint, method, context.Response.StatusCode);
                _logger.LogWarning("Request {Method} {Endpoint} completed with error status {StatusCode}",
                    method, endpoint, context.Response.StatusCode);
            }
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            _metricsService.IncrementErrorCount(endpoint, method, 500);
            _logger.LogError(ex, "Request {Method} {Endpoint} failed with exception", method, endpoint);
            throw;
        }
    }
}

public static class MonitoringMiddlewareExtensions
{
    public static IApplicationBuilder UseMonitoring(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<MonitoringMiddleware>();
    }
}
'@ "Monitoring middleware for collecting request metrics"

        # Create comprehensive Program.cs with all exercises integrated
        Create-FileInteractive "Program.cs" @'
using DIMiddlewareDemo.Services;
using DIMiddlewareDemo.Middleware;
using Microsoft.Extensions.Diagnostics.HealthChecks;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Exercise 1: Service Lifetime Registration
builder.Services.AddSingleton<SingletonCounterService>();
builder.Services.AddScoped<ScopedCounterService>();
builder.Services.AddTransient<TransientCounterService>();
builder.Services.AddScoped<ILifetimeComparisonService, LifetimeComparisonService>();

// Exercise 2: Middleware Services
builder.Services.AddSingleton<IRateLimitService, InMemoryRateLimitService>();

// Exercise 3: Advanced DI Patterns
// Factory pattern
builder.Services.AddTransient<EmailNotificationService>();
builder.Services.AddTransient<SmsNotificationService>();
builder.Services.AddTransient<INotificationFactory, NotificationFactory>();

// Decorator pattern - register base service and decorators
builder.Services.AddTransient<INotificationService>(provider =>
{
    var emailService = provider.GetRequiredService<EmailNotificationService>();
    var logger = provider.GetRequiredService<ILogger<LoggingNotificationDecorator>>();
    var retryLogger = provider.GetRequiredService<ILogger<RetryNotificationDecorator>>();

    // Chain decorators: Email -> Retry -> Logging
    var withRetry = new RetryNotificationDecorator(emailService, retryLogger);
    return new LoggingNotificationDecorator(withRetry, logger);
});

// Generic repository pattern
builder.Services.AddScoped(typeof(IRepository<>), typeof(InMemoryRepository<>));

// Exercise 4: Production Integration
// Health checks
builder.Services.AddHealthChecks()
    .AddCheck<DatabaseHealthCheck>("database", HealthStatus.Unhealthy, tags: new[] { "db" })
    .AddCheck<ExternalApiHealthCheck>("external_api", HealthStatus.Degraded, tags: new[] { "api" });

// Metrics
builder.Services.AddSingleton<IMetricsService, MetricsService>();

// HTTP client for health checks
builder.Services.AddHttpClient<ExternalApiHealthCheck>();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Middleware pipeline - ORDER MATTERS!
app.UseCorrelationId();           // First: Add correlation ID
app.UseRequestLogging();          // Second: Log requests with correlation ID
app.UseMonitoring();              // Third: Collect metrics
app.UseRateLimiting();            // Fourth: Apply rate limiting
app.UseHttpsRedirection();        // Fifth: Enforce HTTPS
app.UseAuthorization();           // Sixth: Authorization

// Health check endpoints
app.MapHealthChecks("/health", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
{
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        var response = new
        {
            status = report.Status.ToString(),
            checks = report.Entries.Select(x => new
            {
                name = x.Key,
                status = x.Value.Status.ToString(),
                description = x.Value.Description,
                duration = x.Value.Duration.TotalMilliseconds
            }),
            totalDuration = report.TotalDuration.TotalMilliseconds
        };
        await context.Response.WriteAsync(System.Text.Json.JsonSerializer.Serialize(response));
    }
});

app.MapHealthChecks("/health/ready", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready")
});

app.MapHealthChecks("/health/live", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
{
    Predicate = _ => false // Only basic liveness check
});

app.MapControllers();

app.Run();
'@ "Comprehensive Program.cs integrating all exercises with proper middleware pipeline"

        # Create comprehensive demo controller
        Create-FileInteractive "Controllers/DemoController.cs" @'
using Microsoft.AspNetCore.Mvc;
using DIMiddlewareDemo.Services;

namespace DIMiddlewareDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DemoController : ControllerBase
{
    private readonly INotificationFactory _notificationFactory;
    private readonly INotificationService _decoratedNotificationService;
    private readonly IRepository<User> _userRepository;
    private readonly ILogger<DemoController> _logger;

    public DemoController(
        INotificationFactory notificationFactory,
        INotificationService decoratedNotificationService,
        IRepository<User> userRepository,
        ILogger<DemoController> logger)
    {
        _notificationFactory = notificationFactory;
        _decoratedNotificationService = decoratedNotificationService;
        _userRepository = userRepository;
        _logger = logger;
    }

    [HttpPost("send-notification/{type}")]
    public async Task<IActionResult> SendNotification(string type, [FromBody] NotificationRequest request)
    {
        try
        {
            // Demonstrate factory pattern
            var notificationService = _notificationFactory.CreateNotificationService(type);
            await notificationService.SendAsync(request.Message, request.Recipient);

            return Ok(new { Message = $"Notification sent via {type}", Timestamp = DateTime.UtcNow });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    [HttpPost("send-decorated-notification")]
    public async Task<IActionResult> SendDecoratedNotification([FromBody] NotificationRequest request)
    {
        try
        {
            // Demonstrate decorator pattern (with logging and retry)
            await _decoratedNotificationService.SendAsync(request.Message, request.Recipient);

            return Ok(new { Message = "Decorated notification sent", Timestamp = DateTime.UtcNow });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send decorated notification");
            return StatusCode(500, new { Error = "Failed to send notification" });
        }
    }

    [HttpGet("users")]
    public async Task<IActionResult> GetUsers()
    {
        // Demonstrate generic repository pattern
        var users = await _userRepository.GetAllAsync();
        return Ok(users);
    }

    [HttpPost("users")]
    public async Task<IActionResult> CreateUser([FromBody] CreateUserRequest request)
    {
        // Demonstrate generic repository pattern
        var user = new User
        {
            Name = request.Name,
            Email = request.Email
        };

        var createdUser = await _userRepository.AddAsync(user);
        return CreatedAtAction(nameof(GetUser), new { id = createdUser.Id }, createdUser);
    }

    [HttpGet("users/{id}")]
    public async Task<IActionResult> GetUser(int id)
    {
        var user = await _userRepository.GetByIdAsync(id);
        if (user == null)
        {
            return NotFound();
        }

        return Ok(user);
    }

    [HttpGet("correlation-id")]
    public IActionResult GetCorrelationId()
    {
        // Demonstrate correlation ID middleware
        var correlationId = HttpContext.Items["CorrelationId"]?.ToString();
        return Ok(new { CorrelationId = correlationId, Timestamp = DateTime.UtcNow });
    }

    [HttpGet("test-rate-limit")]
    public IActionResult TestRateLimit()
    {
        // This endpoint can be used to test rate limiting
        return Ok(new { Message = "Rate limit test", Timestamp = DateTime.UtcNow });
    }
}

public class NotificationRequest
{
    public string Message { get; set; } = string.Empty;
    public string Recipient { get; set; } = string.Empty;
}

public class CreateUserRequest
{
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
}
'@ "Comprehensive demo controller showcasing all DI patterns and middleware features"

        Write-Success "✅ Exercise 4: Production Integration completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Build and run: dotnet run" -ForegroundColor Cyan
        Write-Host "2. Test health checks: GET /health, /health/ready, /health/live" -ForegroundColor Cyan
        Write-Host "3. Test rate limiting: GET /api/demo/test-rate-limit (make 100+ requests)" -ForegroundColor Cyan
        Write-Host "4. Test factory pattern: POST /api/demo/send-notification/email" -ForegroundColor Cyan
        Write-Host "5. Test decorator pattern: POST /api/demo/send-decorated-notification" -ForegroundColor Cyan
        Write-Host "6. Test repository pattern: GET/POST /api/demo/users" -ForegroundColor Cyan
        Write-Host "7. Monitor logs for correlation IDs and metrics" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Success "🎉 $ExerciseName DI/Middleware template created successfully!"
Write-Host ""
Write-Info "📚 For detailed DI and middleware guidance, refer to ASP.NET Core documentation."
Write-Info "🔗 Additional DI/Middleware resources available in the Resources/ directory."
