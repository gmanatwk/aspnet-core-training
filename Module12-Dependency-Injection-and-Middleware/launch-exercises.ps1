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
    param($ExerciseName)

    Write-Host "🎯 DI/Middleware Objectives for $ExerciseName:" -ForegroundColor Blue

    switch ($ExerciseName) {
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
    param($ExerciseName)

    Write-Host "📋 DI/Middleware Components for $ExerciseName:" -ForegroundColor Cyan

    switch ($ExerciseName) {
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
Show-LearningObjectives $ExerciseName

# Show what will be created
Show-CreationOverview $ExerciseName

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
        }

        # Create service interfaces and implementations
        Create-FileInteractive "Services/ILifetimeService.cs" @'
namespace DIMiddlewareDemo.Services;

public interface ITransientService
{
    Guid Id { get; }
    DateTime CreatedAt { get; }
    string GetInfo();
}

public interface IScopedService
{
    Guid Id { get; }
    DateTime CreatedAt { get; }
    string GetInfo();
}

public interface ISingletonService
{
    Guid Id { get; }
    DateTime CreatedAt { get; }
    string GetInfo();
}
'@ "Service interfaces for demonstrating different lifetimes"

        Create-FileInteractive "Services/LifetimeServices.cs" @'
namespace DIMiddlewareDemo.Services;

public class TransientService : ITransientService
{
    public Guid Id { get; } = Guid.NewGuid();
    public DateTime CreatedAt { get; } = DateTime.UtcNow;

    public string GetInfo()
    {
        return $"Transient Service - ID: {Id}, Created: {CreatedAt:HH:mm:ss.fff}";
    }
}

public class ScopedService : IScopedService
{
    public Guid Id { get; } = Guid.NewGuid();
    public DateTime CreatedAt { get; } = DateTime.UtcNow;

    public string GetInfo()
    {
        return $"Scoped Service - ID: {Id}, Created: {CreatedAt:HH:mm:ss.fff}";
    }
}

public class SingletonService : ISingletonService
{
    public Guid Id { get; } = Guid.NewGuid();
    public DateTime CreatedAt { get; } = DateTime.UtcNow;

    public string GetInfo()
    {
        return $"Singleton Service - ID: {Id}, Created: {CreatedAt:HH:mm:ss.fff}";
    }
}
'@ "Service implementations demonstrating different lifetime behaviors"

        Write-Success "✅ Exercise 1: Service Lifetime Exploration completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Register services with different lifetimes in Program.cs" -ForegroundColor Cyan
        Write-Host "2. Create controller to test lifetime behaviors" -ForegroundColor Cyan
        Write-Host "3. Compare service instances across requests" -ForegroundColor Cyan
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

        # Create custom middleware
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
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        var requestId = Guid.NewGuid().ToString("N")[..8];

        _logger.LogInformation("Request {RequestId} started: {Method} {Path}",
            requestId, context.Request.Method, context.Request.Path);

        try
        {
            await _next(context);
        }
        finally
        {
            stopwatch.Stop();
            _logger.LogInformation("Request {RequestId} completed in {ElapsedMs}ms with status {StatusCode}",
                requestId, stopwatch.ElapsedMilliseconds, context.Response.StatusCode);
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
'@ "Custom middleware for request logging with timing"

        Write-Success "✅ Exercise 2: Custom Middleware Development completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Add middleware to the pipeline in Program.cs" -ForegroundColor Cyan
        Write-Host "2. Test middleware with different requests" -ForegroundColor Cyan
        Write-Host "3. Create additional middleware for other concerns" -ForegroundColor Cyan
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

        # Create factory pattern example
        Create-FileInteractive "Services/NotificationFactory.cs" @'
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

        Write-Success "✅ Exercise 3: Advanced DI Patterns completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Register factory and services in Program.cs" -ForegroundColor Cyan
        Write-Host "2. Implement decorator pattern examples" -ForegroundColor Cyan
        Write-Host "3. Test factory pattern with different service types" -ForegroundColor Cyan
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

        Write-Success "✅ Exercise 4: Production Integration completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Configure health checks in Program.cs" -ForegroundColor Cyan
        Write-Host "2. Add monitoring and metrics middleware" -ForegroundColor Cyan
        Write-Host "3. Test health check endpoints" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Success "🎉 $ExerciseName DI/Middleware template created successfully!"
Write-Host ""
Write-Info "📚 For detailed DI and middleware guidance, refer to ASP.NET Core documentation."
Write-Info "🔗 Additional DI/Middleware resources available in the Resources/ directory."
