#!/usr/bin/env pwsh

# Module 11: Asynchronous Programming - Interactive Exercise Launcher (PowerShell)
# This script provides guided, hands-on exercises for async programming in ASP.NET Core

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
$ProjectName = "AsyncDemo"
$InteractiveMode = -not $Auto

# Function to display colored output
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Blue }
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }

# Function to explain concepts interactively
function Explain-Concept {
    param($Concept, $Explanation)
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "⚡ ASYNC CONCEPT: $Concept" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host $Explanation -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
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

    Write-Host "🎯 Async Programming Objectives for ${Exercise}:" -ForegroundColor Blue

    switch ($Exercise) {
        "exercise01" {
            Write-Host "Basic Async/Await Fundamentals:" -ForegroundColor Cyan
            Write-Host "  ⚡ 1. Understanding async/await patterns"
            Write-Host "  ⚡ 2. Task-based asynchronous programming"
            Write-Host "  ⚡ 3. ConfigureAwait best practices"
            Write-Host "  ⚡ 4. Exception handling in async methods"
            Write-Host ""
            Write-Host "Async concepts:" -ForegroundColor Yellow
            Write-Host "  • Task vs ValueTask usage"
            Write-Host "  • Async method naming conventions"
            Write-Host "  • Deadlock prevention techniques"
            Write-Host "  • Performance implications"
        }
        "exercise02" {
            Write-Host "Async API Development:" -ForegroundColor Cyan
            Write-Host "  ⚡ 1. Async controllers and action methods"
            Write-Host "  ⚡ 2. HttpClient best practices"
            Write-Host "  ⚡ 3. Database async operations"
            Write-Host "  ⚡ 4. Cancellation token usage"
            Write-Host ""
            Write-Host "API concepts:" -ForegroundColor Yellow
            Write-Host "  • Async HTTP operations"
            Write-Host "  • Request timeout handling"
            Write-Host "  • Parallel processing patterns"
            Write-Host "  • Resource management"
        }
        "exercise03" {
            Write-Host "Background Tasks & Services:" -ForegroundColor Cyan
            Write-Host "  ⚡ 1. Background service implementation"
            Write-Host "  ⚡ 2. Hosted service patterns"
            Write-Host "  ⚡ 3. Timer-based background tasks"
            Write-Host "  ⚡ 4. Queue-based processing"
            Write-Host ""
            Write-Host "Background concepts:" -ForegroundColor Yellow
            Write-Host "  • Long-running services"
            Write-Host "  • Graceful shutdown handling"
            Write-Host "  • Error handling and retry logic"
            Write-Host "  • Resource cleanup"
        }
    }
    Write-Host ""
}

# Function to show what will be created
function Show-CreationOverview {
    param([string]$Exercise)

    Write-Host "📋 Async Components for ${Exercise}:" -ForegroundColor Cyan

    switch ($Exercise) {
        "exercise01" {
            Write-Host "• Basic async service implementations"
            Write-Host "• Task-based method examples"
            Write-Host "• Exception handling patterns"
            Write-Host "• Performance comparison demos"
            Write-Host "• ConfigureAwait examples"
        }
        "exercise02" {
            Write-Host "• Async API controllers"
            Write-Host "• HttpClient service implementations"
            Write-Host "• Database async operations"
            Write-Host "• Cancellation token examples"
            Write-Host "• Parallel processing demos"
        }
        "exercise03" {
            Write-Host "• Background service implementations"
            Write-Host "• Hosted service examples"
            Write-Host "• Timer-based task scheduling"
            Write-Host "• Queue processing services"
            Write-Host "• Graceful shutdown handling"
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
    Write-Host "Module 11 - Asynchronous Programming" -ForegroundColor Cyan
    Write-Host "Available Exercises:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  - exercise01: Basic Async/Await Fundamentals"
    Write-Host "  - exercise02: Async API Development"
    Write-Host "  - exercise03: Background Tasks & Services"
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
$ValidExercises = @("exercise01", "exercise02", "exercise03")
if ($ExerciseName -notin $ValidExercises) {
    Write-Error "Unknown exercise: $ExerciseName"
    Write-Host ""
    Show-Exercises
    exit 1
}

# Welcome message
Write-Host "⚡ Module 11: Asynchronous Programming" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
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
Write-Info "Checking async programming prerequisites..."

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
    if ($ExerciseName -in @("exercise02", "exercise03")) {
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
        # Exercise 1: Basic Async/Await Fundamentals

        Explain-Concept "Async/Await Fundamentals" @"
Asynchronous programming improves application responsiveness and scalability:
• Task-based Asynchronous Pattern (TAP): Modern async programming model
• async/await keywords: Simplify asynchronous code writing
• ConfigureAwait(false): Prevents deadlocks in library code
• ValueTask: Performance optimization for frequently synchronous operations
• Exception handling: Proper error management in async methods
"@

        if (-not $SkipProjectCreation) {
            Write-Info "Creating new ASP.NET Core Web API project..."
            dotnet new webapi -n $ProjectName --framework net8.0
            Set-Location $ProjectName
        }

        # Create basic async service
        Create-FileInteractive "Services/AsyncBasicsService.cs" @'
namespace AsyncDemo.Services;

public interface IAsyncBasicsService
{
    Task<string> GetDataAsync();
    Task<List<string>> GetMultipleDataAsync();
    ValueTask<int> CalculateAsync(int value);
    Task<string> HandleExceptionAsync();
}

public class AsyncBasicsService : IAsyncBasicsService
{
    private readonly ILogger<AsyncBasicsService> _logger;

    public AsyncBasicsService(ILogger<AsyncBasicsService> logger)
    {
        _logger = logger;
    }

    public async Task<string> GetDataAsync()
    {
        _logger.LogInformation("Starting async data retrieval");

        // Simulate async I/O operation
        await Task.Delay(1000);

        _logger.LogInformation("Async data retrieval completed");
        return "Data retrieved asynchronously";
    }

    public async Task<List<string>> GetMultipleDataAsync()
    {
        _logger.LogInformation("Starting multiple async operations");

        // Run multiple async operations concurrently
        var tasks = new List<Task<string>>
        {
            GetSingleDataAsync("Data 1", 500),
            GetSingleDataAsync("Data 2", 800),
            GetSingleDataAsync("Data 3", 300)
        };

        var results = await Task.WhenAll(tasks);

        _logger.LogInformation("All async operations completed");
        return results.ToList();
    }

    public async ValueTask<int> CalculateAsync(int value)
    {
        // ValueTask is useful when the operation might complete synchronously
        if (value < 0)
        {
            return 0; // Synchronous path
        }

        // Asynchronous path
        await Task.Delay(100);
        return value * 2;
    }

    public async Task<string> HandleExceptionAsync()
    {
        try
        {
            _logger.LogInformation("Starting operation that might throw");

            await Task.Delay(500);

            // Simulate an exception
            throw new InvalidOperationException("Simulated async exception");
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogError(ex, "Handled async exception");
            return "Exception handled gracefully";
        }
    }

    private async Task<string> GetSingleDataAsync(string dataName, int delayMs)
    {
        await Task.Delay(delayMs);
        return $"{dataName} (retrieved in {delayMs}ms)";
    }
}
'@ "Basic async service demonstrating fundamental async patterns"

        Write-Success "✅ Exercise 1: Basic Async/Await Fundamentals completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Register service in Program.cs" -ForegroundColor Cyan
        Write-Host "2. Create controller to test async methods" -ForegroundColor Cyan
        Write-Host "3. Compare sync vs async performance" -ForegroundColor Cyan
    }

    "exercise02" {
        # Exercise 2: Async API Development

        Explain-Concept "Async API Development" @"
Async APIs provide better scalability and user experience:
• Async controllers: Non-blocking request processing
• HttpClient: Async HTTP operations with proper lifecycle management
• Cancellation tokens: Graceful request cancellation
• Parallel processing: Concurrent operations for better performance
• Database async operations: Non-blocking data access
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 2 requires Exercise 1 to be completed first!"
            Write-Info "Please run: .\launch-exercises.ps1 exercise01"
            exit 1
        }

        # Create async API service
        Create-FileInteractive "Services/AsyncApiService.cs" @'
namespace AsyncDemo.Services;

public interface IAsyncApiService
{
    Task<List<WeatherData>> GetWeatherDataAsync(CancellationToken cancellationToken = default);
    Task<string> ProcessDataAsync(string data, CancellationToken cancellationToken = default);
    Task<List<T>> ProcessInParallelAsync<T>(IEnumerable<T> items, Func<T, Task<T>> processor, CancellationToken cancellationToken = default);
}

public class AsyncApiService : IAsyncApiService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<AsyncApiService> _logger;

    public AsyncApiService(HttpClient httpClient, ILogger<AsyncApiService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<List<WeatherData>> GetWeatherDataAsync(CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Fetching weather data from external API");

        try
        {
            // Simulate external API call with cancellation support
            using var response = await _httpClient.GetAsync("https://api.openweathermap.org/data/2.5/weather?q=London&appid=demo", cancellationToken);

            if (response.IsSuccessStatusCode)
            {
                var content = await response.Content.ReadAsStringAsync(cancellationToken);
                _logger.LogInformation("Weather data retrieved successfully");

                // Return mock data for demo
                return new List<WeatherData>
                {
                    new WeatherData { City = "London", Temperature = 20, Description = "Sunny" },
                    new WeatherData { City = "Paris", Temperature = 18, Description = "Cloudy" }
                };
            }
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "Failed to fetch weather data");
        }
        catch (TaskCanceledException ex)
        {
            _logger.LogWarning(ex, "Weather data request was cancelled");
        }

        return new List<WeatherData>();
    }

    public async Task<string> ProcessDataAsync(string data, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Processing data: {Data}", data);

        // Simulate processing with cancellation support
        for (int i = 0; i < 10; i++)
        {
            cancellationToken.ThrowIfCancellationRequested();
            await Task.Delay(100, cancellationToken);
        }

        return $"Processed: {data.ToUpper()}";
    }

    public async Task<List<T>> ProcessInParallelAsync<T>(IEnumerable<T> items, Func<T, Task<T>> processor, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Processing {Count} items in parallel", items.Count());

        var tasks = items.Select(item => processor(item));
        var results = await Task.WhenAll(tasks);

        return results.ToList();
    }
}

public class WeatherData
{
    public string City { get; set; } = string.Empty;
    public int Temperature { get; set; }
    public string Description { get; set; } = string.Empty;
}
'@ "Async API service with HttpClient and cancellation token support"

        Write-Success "✅ Exercise 2: Async API Development completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Configure HttpClient in Program.cs" -ForegroundColor Cyan
        Write-Host "2. Create async controllers" -ForegroundColor Cyan
        Write-Host "3. Test cancellation token functionality" -ForegroundColor Cyan
    }

    "exercise03" {
        # Exercise 3: Background Tasks & Services

        Explain-Concept "Background Services and Hosted Services" @"
Background services handle long-running operations:
• BackgroundService: Base class for long-running background tasks
• IHostedService: Interface for services that start/stop with the host
• Timer-based tasks: Periodic background operations
• Queue processing: Handling background work items
• Graceful shutdown: Proper cleanup when application stops
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 3 requires Exercises 1 and 2 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03"
            exit 1
        }

        # Create background service
        Create-FileInteractive "Services/TimerBackgroundService.cs" @'
namespace AsyncDemo.Services;

public class TimerBackgroundService : BackgroundService
{
    private readonly ILogger<TimerBackgroundService> _logger;
    private readonly IServiceProvider _serviceProvider;

    public TimerBackgroundService(ILogger<TimerBackgroundService> logger, IServiceProvider serviceProvider)
    {
        _logger = logger;
        _serviceProvider = serviceProvider;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Timer Background Service started");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await DoWorkAsync(stoppingToken);

                // Wait for 30 seconds before next execution
                await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
            }
            catch (OperationCanceledException)
            {
                // Expected when cancellation is requested
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred in background service");

                // Wait before retrying
                await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
            }
        }

        _logger.LogInformation("Timer Background Service stopped");
    }

    private async Task DoWorkAsync(CancellationToken cancellationToken)
    {
        using var scope = _serviceProvider.CreateScope();

        _logger.LogInformation("Background task executing at: {Time}", DateTimeOffset.Now);

        // Simulate some work
        await Task.Delay(1000, cancellationToken);

        _logger.LogInformation("Background task completed at: {Time}", DateTimeOffset.Now);
    }

    public override async Task StopAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Timer Background Service is stopping");
        await base.StopAsync(cancellationToken);
    }
}
'@ "Timer-based background service with proper lifecycle management"

        # Create queue processing service
        Create-FileInteractive "Services/QueueBackgroundService.cs" @'
using System.Collections.Concurrent;

namespace AsyncDemo.Services;

public interface IBackgroundTaskQueue
{
    void QueueBackgroundWorkItem(Func<CancellationToken, Task> workItem);
    Task<Func<CancellationToken, Task>> DequeueAsync(CancellationToken cancellationToken);
}

public class BackgroundTaskQueue : IBackgroundTaskQueue
{
    private readonly ConcurrentQueue<Func<CancellationToken, Task>> _workItems = new();
    private readonly SemaphoreSlim _signal = new(0);

    public void QueueBackgroundWorkItem(Func<CancellationToken, Task> workItem)
    {
        if (workItem == null)
            throw new ArgumentNullException(nameof(workItem));

        _workItems.Enqueue(workItem);
        _signal.Release();
    }

    public async Task<Func<CancellationToken, Task>> DequeueAsync(CancellationToken cancellationToken)
    {
        await _signal.WaitAsync(cancellationToken);
        _workItems.TryDequeue(out var workItem);
        return workItem!;
    }
}

public class QueuedHostedService : BackgroundService
{
    private readonly ILogger<QueuedHostedService> _logger;
    private readonly IBackgroundTaskQueue _taskQueue;

    public QueuedHostedService(IBackgroundTaskQueue taskQueue, ILogger<QueuedHostedService> logger)
    {
        _taskQueue = taskQueue;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Queued Hosted Service started");

        await BackgroundProcessing(stoppingToken);
    }

    private async Task BackgroundProcessing(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                var workItem = await _taskQueue.DequeueAsync(stoppingToken);
                await workItem(stoppingToken);
            }
            catch (OperationCanceledException)
            {
                // Expected when cancellation is requested
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred executing background work item");
            }
        }
    }

    public override async Task StopAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Queued Hosted Service is stopping");
        await base.StopAsync(cancellationToken);
    }
}
'@ "Queue-based background service for processing work items"

        Write-Success "✅ Exercise 3: Background Tasks & Services completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Register background services in Program.cs" -ForegroundColor Cyan
        Write-Host "2. Create API endpoints to queue background work" -ForegroundColor Cyan
        Write-Host "3. Test graceful shutdown behavior" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Success "🎉 $ExerciseName async template created successfully!"
Write-Host ""
Write-Info "📚 For detailed async programming guidance, refer to Microsoft's async best practices."
Write-Info "🔗 Additional async resources available in the Resources/ directory."
