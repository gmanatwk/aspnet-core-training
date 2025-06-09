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
$ProjectName = "AsyncExercise01"  # Match exercise naming
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
            Write-Host "🚨 PROBLEM: Sequential Data Processing" -ForegroundColor Red
            Write-Host "  🐌 Processing URLs one by one takes forever"
            Write-Host "  📊 3 URLs taking 6+ seconds when they could take 2 seconds"
            Write-Host "  🎯 GOAL: Learn async/await fundamentals with real scenarios"
            Write-Host ""
            Write-Host "You'll learn by building:" -ForegroundColor Yellow
            Write-Host "  • Download/Process/Save async workflow"
            Write-Host "  • Sequential vs concurrent processing"
            Write-Host "  • Retry logic with exponential backoff"
            Write-Host "  • Proper exception handling in async code"
        }
        "exercise02" {
            Write-Host "🚨 PROBLEM: Deadlocking Web App" -ForegroundColor Red
            Write-Host "  💀 App freezes randomly under load"
            Write-Host "  🔒 Classic async/sync deadlock scenario"
            Write-Host "  🎯 GOAL: Fix deadlocks and understand why they happen"
            Write-Host ""
            Write-Host "You'll learn by debugging:" -ForegroundColor Yellow
            Write-Host "  • How .Result causes deadlocks"
            Write-Host "  • ConfigureAwait(false) patterns"
            Write-Host "  • Identifying blocking async code"
            Write-Host "  • Proper async all the way down"
        }
        "exercise03" {
            Write-Host "🚨 PROBLEM: Inefficient Data Processing" -ForegroundColor Red
            Write-Host "  🐌 Processing 1000 records takes 10 minutes"
            Write-Host "  🔄 Currently processing one record at a time"
            Write-Host "  🎯 GOAL: Use concurrency to process in under 1 minute"
            Write-Host ""
            Write-Host "You'll learn by optimizing:" -ForegroundColor Yellow
            Write-Host "  • Task.WhenAll for concurrent processing"
            Write-Host "  • Controlling concurrency with SemaphoreSlim"
            Write-Host "  • Measuring actual performance gains"
            Write-Host "  • When concurrency helps vs hurts"
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
            Write-Host "• Console application with async Main"
            Write-Host "• DownloadDataAsync, ProcessDataAsync, SaveDataAsync methods"
            Write-Host "• ProcessedData model class"
            Write-Host "• Sequential vs concurrent processing comparison"
            Write-Host "• Retry logic with exponential backoff"
            Write-Host "• Comprehensive exception handling"
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

        Explain-Concept "🚨 THE PROBLEM: Sequential Processing is Slow" @"
You need to build a data processing system that downloads, processes, and saves data:

CURRENT CHALLENGE:
• Processing 3 URLs sequentially takes 6+ seconds
• Each operation waits for the previous one to complete
• No retry logic when downloads fail
• Poor exception handling

YOUR MISSION:
• Build async download/process/save workflow
• Compare sequential vs concurrent processing
• Implement retry logic with exponential backoff
• Handle exceptions properly in async code
"@

        if (-not $SkipProjectCreation) {
            Write-Info "Creating async console application..."
            Write-Info "This matches Exercise 1 requirements exactly!"
            dotnet new console -n $ProjectName --framework net8.0
            Set-Location $ProjectName
        }

        # Create the ProcessedData model class as required by exercise
        Create-FileInteractive "Models/ProcessedData.cs" @'
namespace AsyncExercise01.Models;

/// <summary>
/// Data model for processed information - matches Exercise 1 requirements
/// </summary>
public class ProcessedData
{
    public string Summary { get; set; } = string.Empty;
    public int CharacterCount { get; set; }
    public DateTime ProcessedAt { get; set; }

    public override string ToString()
    {
        return $"Summary: {Summary}, Characters: {CharacterCount}, Processed: {ProcessedAt:HH:mm:ss}";
    }
}
'@ "ProcessedData model class matching exercise requirements"

        # Create Program.cs with the exact methods required by Exercise 1
        Create-FileInteractive "Program.cs" @'
using System.Diagnostics;
using AsyncExercise01.Models;

namespace AsyncExercise01;

class Program
{
    static async Task Main(string[] args)
    {
        Console.WriteLine("=== Exercise 1: Basic Async Programming ===\n");

        // Test URLs with different delays (as specified in exercise)
        var urls = new List<string>
        {
            "https://api1.example.com", // 1000ms delay
            "https://api2.example.com", // 1500ms delay
            "https://api3.example.com"  // 800ms delay
        };

        Console.WriteLine("🚀 Testing Sequential vs Concurrent Processing\n");

        // Part 1: Sequential Processing
        await TestSequentialProcessing(urls);

        Console.WriteLine();

        // Part 2: Concurrent Processing
        await TestConcurrentProcessing(urls);

        Console.WriteLine();

        // Part 3: Retry Logic Test
        await TestRetryLogic();

        Console.WriteLine("\nPress any key to exit...");
        Console.ReadKey();
    }

    /// <summary>
    /// Method that simulates downloading data from a web service
    /// Matches Exercise 1 requirements exactly
    /// </summary>
    static async Task<string> DownloadDataAsync(string url, int delayMs)
    {
        Console.WriteLine($"Downloading from {url}...");

        // Simulate network delay
        await Task.Delay(delayMs);

        // Return simulated data
        return $"Data from {url} (simulated {delayMs}ms download)";
    }

    /// <summary>
    /// Method that processes downloaded data
    /// Matches Exercise 1 requirements exactly
    /// </summary>
    static async Task<ProcessedData> ProcessDataAsync(string rawData)
    {
        Console.WriteLine($"Processing data from {ExtractUrlFromData(rawData)}...");

        // Simulate processing time (500ms as specified)
        await Task.Delay(500);

        // Return ProcessedData object with summary
        return new ProcessedData
        {
            Summary = $"Processed: {ExtractUrlFromData(rawData)}",
            CharacterCount = rawData.Length,
            ProcessedAt = DateTime.Now
        };
    }

    /// <summary>
    /// Method that saves processed data
    /// Matches Exercise 1 requirements exactly
    /// </summary>
    static async Task SaveDataAsync(ProcessedData data, string fileName)
    {
        Console.WriteLine($"Saving data to {fileName}...");

        // Simulate file I/O (300ms as specified)
        await Task.Delay(300);

        // In real scenario, would save to file
        // For demo, just simulate the operation
        Console.WriteLine($"Data saved to {fileName}");
    }

    /// <summary>
    /// Sequential processing method - processes URLs one by one
    /// Matches Exercise 1 requirements exactly
    /// </summary>
    static async Task TestSequentialProcessing(List<string> urls)
    {
        Console.WriteLine("=== Sequential Processing ===");
        var stopwatch = Stopwatch.StartNew();

        foreach (var url in urls)
        {
            var delay = GetDelayForUrl(url);
            var rawData = await DownloadDataAsync(url, delay);
            var processedData = await ProcessDataAsync(rawData);
            var fileName = $"{ExtractApiName(url)}_data.txt";
            await SaveDataAsync(processedData, fileName);
        }

        stopwatch.Stop();
        Console.WriteLine($"Sequential processing completed in {stopwatch.ElapsedMilliseconds}ms");
    }

    /// <summary>
    /// Concurrent processing method - processes all URLs concurrently
    /// Matches Exercise 1 requirements exactly
    /// </summary>
    static async Task TestConcurrentProcessing(List<string> urls)
    {
        Console.WriteLine("=== Concurrent Processing ===");
        var stopwatch = Stopwatch.StartNew();

        // Process all URLs concurrently using Task.WhenAll
        var tasks = urls.Select(async url =>
        {
            var delay = GetDelayForUrl(url);
            var rawData = await DownloadDataAsync(url, delay);
            var processedData = await ProcessDataAsync(rawData);
            var fileName = $"{ExtractApiName(url)}_data.txt";
            await SaveDataAsync(processedData, fileName);
            return processedData;
        });

        var results = await Task.WhenAll(tasks);

        stopwatch.Stop();
        Console.WriteLine($"Concurrent processing completed in {stopwatch.ElapsedMilliseconds}ms");
    }

    /// <summary>
    /// Retry logic test - implements exponential backoff as required by Exercise 1
    /// </summary>
    static async Task TestRetryLogic()
    {
        Console.WriteLine("=== Retry Logic Test ===");

        try
        {
            var result = await DownloadWithRetryAsync("https://unreliable-api.example.com");
            Console.WriteLine($"Download successful: {result}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Download failed after all retries: {ex.Message}");
        }
    }

    /// <summary>
    /// Download with retry logic - implements exponential backoff
    /// Matches Exercise 1 requirements exactly
    /// </summary>
    static async Task<string> DownloadWithRetryAsync(string url)
    {
        const int maxRetries = 3;
        var random = new Random();

        for (int attempt = 1; attempt <= maxRetries; attempt++)
        {
            try
            {
                Console.WriteLine($"Attempting download (try {attempt}/{maxRetries})...");

                // Simulate 50% chance of failure
                if (random.NextDouble() < 0.5)
                {
                    throw new HttpRequestException($"Simulated network failure for {url}");
                }

                // Simulate successful download
                await Task.Delay(500);
                Console.WriteLine("Download successful!");
                return $"Data from {url}";
            }
            catch (Exception ex) when (attempt < maxRetries)
            {
                // Exponential backoff: 1s, 2s, 4s delays
                var delayMs = (int)Math.Pow(2, attempt - 1) * 1000;
                Console.WriteLine($"Download failed, retrying in {delayMs}ms...");
                await Task.Delay(delayMs);
            }
        }

        throw new Exception($"Failed to download from {url} after {maxRetries} attempts");
    }

    /// <summary>
    /// Helper method to get delay for specific URLs (as specified in exercise)
    /// </summary>
    static int GetDelayForUrl(string url)
    {
        return url switch
        {
            "https://api1.example.com" => 1000, // 1000ms delay
            "https://api2.example.com" => 1500, // 1500ms delay
            "https://api3.example.com" => 800,  // 800ms delay
            _ => 1000 // default delay
        };
    }

    /// <summary>
    /// Helper method to extract URL from data string
    /// </summary>
    static string ExtractUrlFromData(string data)
    {
        // Extract URL from the data string
        var parts = data.Split(' ');
        return parts.Length > 2 ? parts[2] : "unknown";
    }

    /// <summary>
    /// Helper method to extract API name from URL
    /// </summary>
    static string ExtractApiName(string url)
    {
        return url switch
        {
            "https://api1.example.com" => "api1",
            "https://api2.example.com" => "api2",
            "https://api3.example.com" => "api3",
            _ => "unknown"
        };
    }
}
'@ "Console application implementing Exercise 1 requirements exactly"

        Write-Success "✅ Exercise 1: Basic Async Programming - COMPLETE!"
        Write-Host ""
        Write-Host "🧪 NOW TEST YOUR ASYNC SKILLS:" -ForegroundColor Green
        Write-Host "1. Build and run: dotnet run" -ForegroundColor Cyan
        Write-Host "2. Watch sequential processing take 6+ seconds" -ForegroundColor Yellow
        Write-Host "3. See concurrent processing finish in ~2 seconds" -ForegroundColor Green
        Write-Host "4. Observe retry logic with exponential backoff" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "🎯 LEARNING OBJECTIVES ACHIEVED:" -ForegroundColor Yellow
        Write-Host "• ✅ Implemented DownloadDataAsync, ProcessDataAsync, SaveDataAsync" -ForegroundColor White
        Write-Host "• ✅ Created ProcessedData model with required properties" -ForegroundColor White
        Write-Host "• ✅ Built sequential vs concurrent processing comparison" -ForegroundColor White
        Write-Host "• ✅ Added retry logic with exponential backoff" -ForegroundColor White
        Write-Host "• ✅ Proper exception handling in async methods" -ForegroundColor White
        Write-Host ""
        Write-Host "📚 WHAT YOU LEARNED:" -ForegroundColor Blue
        Write-Host "• How async/await improves performance for I/O operations" -ForegroundColor White
        Write-Host "• Task.WhenAll for concurrent operations" -ForegroundColor White
        Write-Host "• Proper exception handling in async code" -ForegroundColor White
        Write-Host "• Retry patterns with exponential backoff" -ForegroundColor White
    }

    "exercise02" {
        # Exercise 2: Advanced Async Patterns

        Explain-Concept "🚨 THE PROBLEM: Complex Async Scenarios" @"
You need to handle more complex async scenarios in your console application:

CURRENT CHALLENGE:
• Managing multiple async operations with different completion times
• Handling cancellation and timeouts properly
• Working with async streams and IAsyncEnumerable
• Implementing proper error handling across async boundaries

YOUR MISSION:
• Build async data streaming functionality
• Implement cancellation token support
• Create timeout handling mechanisms
• Work with async LINQ operations
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 2 requires Exercise 1 to be completed first!"
            Write-Info "Please run: .\launch-exercises.ps1 exercise01"
            exit 1
        }

        # Add the advanced async functionality to the existing console app
        Create-FileInteractive "Services/AsyncStreamService.cs" @'
using System.Runtime.CompilerServices;

namespace AsyncExercise01.Services;

public class AsyncStreamService
{
    /// <summary>
    /// Demonstrates async enumerable for streaming data
    /// </summary>
    public static async IAsyncEnumerable<string> GetDataStreamAsync(
        [EnumeratorCancellation] CancellationToken cancellationToken = default)
    {
        for (int i = 1; i <= 10; i++)
        {
            cancellationToken.ThrowIfCancellationRequested();

            await Task.Delay(500, cancellationToken);
            yield return $"Stream item {i} at {DateTime.Now:HH:mm:ss.fff}";
        }
    }

    /// <summary>
    /// Demonstrates timeout handling with cancellation tokens
    /// </summary>
    public static async Task<string> GetDataWithTimeoutAsync(int timeoutMs)
    {
        using var cts = new CancellationTokenSource(TimeSpan.FromMilliseconds(timeoutMs));

        try
        {
            // Simulate work that might take longer than timeout
            await Task.Delay(timeoutMs + 1000, cts.Token);
            return "Operation completed successfully";
        }
        catch (OperationCanceledException)
        {
            return $"Operation timed out after {timeoutMs}ms";
        }
    }
}
'@ "Advanced async patterns service"

        # Update Program.cs to add Exercise 2 functionality
        Create-FileInteractive "Program.cs" @'
using System.Diagnostics;
using AsyncExercise01.Models;
using AsyncExercise01.Services;

namespace AsyncExercise01;

class Program
{
    static async Task Main(string[] args)
    {
        Console.WriteLine("=== Module 11: Asynchronous Programming ===\n");

        // Exercise 1: Basic async patterns
        await RunExercise1();

        Console.WriteLine("\n" + new string('=', 50) + "\n");

        // Exercise 2: Advanced async patterns
        await RunExercise2();

        Console.WriteLine("\nPress any key to exit...");
        Console.ReadKey();
    }

    static async Task RunExercise1()
    {
        Console.WriteLine("=== Exercise 1: Basic Async Programming ===\n");

        // Test URLs with different delays (as specified in exercise)
        var urls = new List<string>
        {
            "https://api1.example.com", // 1000ms delay
            "https://api2.example.com", // 1500ms delay
            "https://api3.example.com"  // 800ms delay
        };

        Console.WriteLine("🚀 Testing Sequential vs Concurrent Processing\n");

        // Part 1: Sequential Processing
        await TestSequentialProcessing(urls);

        Console.WriteLine();

        // Part 2: Concurrent Processing
        await TestConcurrentProcessing(urls);

        Console.WriteLine();

        // Part 3: Retry Logic Test
        await TestRetryLogic();
    }

    static async Task RunExercise2()
    {
        Console.WriteLine("=== Exercise 2: Advanced Async Patterns ===\n");

        // Part 1: Async Streams
        Console.WriteLine("🌊 Testing Async Streams:");
        await TestAsyncStreams();

        Console.WriteLine();

        // Part 2: Cancellation and Timeouts
        Console.WriteLine("⏰ Testing Cancellation and Timeouts:");
        await TestCancellationAndTimeouts();
    }

    static async Task TestAsyncStreams()
    {
        Console.WriteLine("Processing async stream...");

        await foreach (var item in AsyncStreamService.GetDataStreamAsync())
        {
            Console.WriteLine($"Received: {item}");
        }

        Console.WriteLine("Async stream processing completed!");
    }

    static async Task TestCancellationAndTimeouts()
    {
        // Test timeout scenarios
        Console.WriteLine("Testing timeout with 2000ms limit:");
        var result1 = await AsyncStreamService.GetDataWithTimeoutAsync(2000);
        Console.WriteLine($"Result: {result1}");

        Console.WriteLine("\nTesting timeout with 500ms limit:");
        var result2 = await AsyncStreamService.GetDataWithTimeoutAsync(500);
        Console.WriteLine($"Result: {result2}");
    }

    // Exercise 1 methods (from previous implementation)
    static async Task TestSequentialProcessing(List<string> urls)
    {
        Console.WriteLine("=== Sequential Processing ===");
        var stopwatch = Stopwatch.StartNew();

        foreach (var url in urls)
        {
            var delay = GetDelayForUrl(url);
            var rawData = await DownloadDataAsync(url, delay);
            var processedData = await ProcessDataAsync(rawData);
            var fileName = $"{ExtractApiName(url)}_data.txt";
            await SaveDataAsync(processedData, fileName);
        }

        stopwatch.Stop();
        Console.WriteLine($"Sequential processing completed in {stopwatch.ElapsedMilliseconds}ms");
    }

    static async Task TestConcurrentProcessing(List<string> urls)
    {
        Console.WriteLine("=== Concurrent Processing ===");
        var stopwatch = Stopwatch.StartNew();

        var tasks = urls.Select(async url =>
        {
            var delay = GetDelayForUrl(url);
            var rawData = await DownloadDataAsync(url, delay);
            var processedData = await ProcessDataAsync(rawData);
            var fileName = $"{ExtractApiName(url)}_data.txt";
            await SaveDataAsync(processedData, fileName);
            return processedData;
        });

        var results = await Task.WhenAll(tasks);

        stopwatch.Stop();
        Console.WriteLine($"Concurrent processing completed in {stopwatch.ElapsedMilliseconds}ms");
    }

    static async Task TestRetryLogic()
    {
        Console.WriteLine("=== Retry Logic Test ===");

        try
        {
            var result = await DownloadWithRetryAsync("https://unreliable-api.example.com");
            Console.WriteLine($"Download successful: {result}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Download failed after all retries: {ex.Message}");
        }
    }

    static async Task<string> DownloadDataAsync(string url, int delayMs)
    {
        Console.WriteLine($"Downloading from {url}...");
        await Task.Delay(delayMs);
        return $"Data from {url} (simulated {delayMs}ms download)";
    }

    static async Task<ProcessedData> ProcessDataAsync(string rawData)
    {
        Console.WriteLine($"Processing data from {ExtractUrlFromData(rawData)}...");
        await Task.Delay(500);

        return new ProcessedData
        {
            Summary = $"Processed: {ExtractUrlFromData(rawData)}",
            CharacterCount = rawData.Length,
            ProcessedAt = DateTime.Now
        };
    }

    static async Task SaveDataAsync(ProcessedData data, string fileName)
    {
        Console.WriteLine($"Saving data to {fileName}...");
        await Task.Delay(300);
        Console.WriteLine($"Data saved to {fileName}");
    }

    static async Task<string> DownloadWithRetryAsync(string url)
    {
        const int maxRetries = 3;
        var random = new Random();

        for (int attempt = 1; attempt <= maxRetries; attempt++)
        {
            try
            {
                Console.WriteLine($"Attempting download (try {attempt}/{maxRetries})...");

                if (random.NextDouble() < 0.5)
                {
                    throw new HttpRequestException($"Simulated network failure for {url}");
                }

                await Task.Delay(500);
                Console.WriteLine("Download successful!");
                return $"Data from {url}";
            }
            catch (Exception ex) when (attempt < maxRetries)
            {
                var delayMs = (int)Math.Pow(2, attempt - 1) * 1000;
                Console.WriteLine($"Download failed, retrying in {delayMs}ms...");
                await Task.Delay(delayMs);
            }
        }

        throw new Exception($"Failed to download from {url} after {maxRetries} attempts");
    }

    static int GetDelayForUrl(string url)
    {
        return url switch
        {
            "https://api1.example.com" => 1000,
            "https://api2.example.com" => 1500,
            "https://api3.example.com" => 800,
            _ => 1000
        };
    }

    static string ExtractUrlFromData(string data)
    {
        var parts = data.Split(' ');
        return parts.Length > 2 ? parts[2] : "unknown";
    }

    static string ExtractApiName(string url)
    {
        return url switch
        {
            "https://api1.example.com" => "api1",
            "https://api2.example.com" => "api2",
            "https://api3.example.com" => "api3",
            _ => "unknown"
        };
    }
}
'@ "Updated Program.cs with both Exercise 1 and Exercise 2 functionality"

        Write-Success "✅ Exercise 2: Advanced Async Patterns - COMPLETE!"
        Write-Host ""
        Write-Host "🧪 NOW TEST ADVANCED ASYNC:" -ForegroundColor Green
        Write-Host "1. Build and run: dotnet run" -ForegroundColor Cyan
        Write-Host "2. Watch async streams in action" -ForegroundColor Yellow
        Write-Host "3. See cancellation and timeout handling" -ForegroundColor Green
        Write-Host "4. Compare with Exercise 1 basic patterns" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "🎯 LEARNING OBJECTIVES ACHIEVED:" -ForegroundColor Yellow
        Write-Host "• ✅ Implemented async streams with IAsyncEnumerable" -ForegroundColor White
        Write-Host "• ✅ Added cancellation token support" -ForegroundColor White
        Write-Host "• ✅ Built timeout handling mechanisms" -ForegroundColor White
        Write-Host "• ✅ Combined basic and advanced async patterns" -ForegroundColor White
    }

    "exercise03" {
        # Exercise 3: Background Services and Tasks

        Explain-Concept "🚨 THE PROBLEM: Long-Running Background Work" @"
Your console application needs to handle background processing:

CURRENT CHALLENGE:
• Running background tasks alongside main application logic
• Managing task lifecycles and cleanup
• Handling background task failures gracefully
• Coordinating between foreground and background work

YOUR MISSION:
• Implement background task processing
• Add proper task cancellation and cleanup
• Create task coordination mechanisms
• Handle background task exceptions
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 3 requires Exercises 1 and 2 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03"
            exit 1
        }

        # Add background service functionality
        Create-FileInteractive "Services/BackgroundTaskService.cs" @'
namespace AsyncExercise01.Services;

public class BackgroundTaskService
{
    private readonly CancellationTokenSource _cancellationTokenSource = new();

    public async Task StartBackgroundWorkAsync()
    {
        Console.WriteLine("🔄 Starting background tasks...");

        // Start multiple background tasks
        var tasks = new[]
        {
            Task.Run(() => BackgroundTask1(_cancellationTokenSource.Token)),
            Task.Run(() => BackgroundTask2(_cancellationTokenSource.Token)),
            Task.Run(() => BackgroundTask3(_cancellationTokenSource.Token))
        };

        try
        {
            await Task.WhenAll(tasks);
        }
        catch (OperationCanceledException)
        {
            Console.WriteLine("Background tasks were cancelled");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Background task error: {ex.Message}");
        }
    }

    public void StopBackgroundWork()
    {
        Console.WriteLine("🛑 Stopping background tasks...");
        _cancellationTokenSource.Cancel();
    }

    private async Task BackgroundTask1(CancellationToken cancellationToken)
    {
        while (!cancellationToken.IsCancellationRequested)
        {
            Console.WriteLine($"Background Task 1 running at {DateTime.Now:HH:mm:ss}");
            await Task.Delay(2000, cancellationToken);
        }
    }

    private async Task BackgroundTask2(CancellationToken cancellationToken)
    {
        while (!cancellationToken.IsCancellationRequested)
        {
            Console.WriteLine($"Background Task 2 processing at {DateTime.Now:HH:mm:ss}");
            await Task.Delay(3000, cancellationToken);
        }
    }

    private async Task BackgroundTask3(CancellationToken cancellationToken)
    {
        while (!cancellationToken.IsCancellationRequested)
        {
            Console.WriteLine($"Background Task 3 monitoring at {DateTime.Now:HH:mm:ss}");
            await Task.Delay(5000, cancellationToken);
        }
    }

    public void Dispose()
    {
        _cancellationTokenSource?.Dispose();
    }
}
'@ "Background task service for Exercise 3"

        Write-Success "✅ Exercise 3: Background Services and Tasks - COMPLETE!"
        Write-Host ""
        Write-Host "🧪 NOW TEST BACKGROUND PROCESSING:" -ForegroundColor Green
        Write-Host "1. Build and run: dotnet run" -ForegroundColor Cyan
        Write-Host "2. Watch background tasks running concurrently" -ForegroundColor Yellow
        Write-Host "3. Test graceful shutdown with Ctrl+C" -ForegroundColor Green
        Write-Host "4. See proper task coordination and cleanup" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "🎯 LEARNING OBJECTIVES ACHIEVED:" -ForegroundColor Yellow
        Write-Host "• ✅ Implemented background task processing" -ForegroundColor White
        Write-Host "• ✅ Added proper task cancellation and cleanup" -ForegroundColor White
        Write-Host "• ✅ Created task coordination mechanisms" -ForegroundColor White
        Write-Host "• ✅ Handled background task exceptions" -ForegroundColor White
    }

    "exercise02" {
        # Exercise 2: Async API Development

        Explain-Concept "🚨 THE PROBLEM: Async/Sync Deadlocks" @"
You've inherited a web app that randomly freezes under load - classic deadlock scenario!

CURRENT ISSUES:
• Controllers call .Result on async methods (DEADLY!)
• SynchronizationContext deadlocks in ASP.NET
• App becomes completely unresponsive
• No clear error messages - just hangs forever

YOUR MISSION:
• Identify the deadlock patterns
• Fix blocking async calls
• Understand ConfigureAwait(false)
• Make the app truly async all the way down
"@

        if (-not $SkipProjectCreation) {
            Write-Info "Creating async web API application..."
            Write-Info "This will demonstrate deadlock scenarios and solutions!"
            dotnet new webapi -n AsyncDemo --framework net8.0
            Set-Location AsyncDemo
        }

        # Create User model for the API
        Create-FileInteractive "Models/User.cs" @'
namespace AsyncDemo.Models;

public class User
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
}

public class WeatherData
{
    public string City { get; set; } = string.Empty;
    public int Temperature { get; set; }
    public string Description { get; set; } = string.Empty;
}
'@ "Models for the async API demonstration"

        # Create async data service interface
        Create-FileInteractive "Data/IAsyncDataService.cs" @'
using AsyncDemo.Models;

namespace AsyncDemo.Data;

public interface IAsyncDataService
{
    Task<List<User>> GetAllUsersAsync();
    Task<User?> GetUserByIdAsync(int id);
    Task<User> CreateUserAsync(string name, string email);
    Task<object> GetExternalUserDataAsync(int userId);
}
'@ "Interface for async data operations"

        # Create async data service implementation
        Create-FileInteractive "Data/AsyncDataService.cs" @'
using AsyncDemo.Models;
using System.Text.Json;

namespace AsyncDemo.Data;

public class AsyncDataService : IAsyncDataService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<AsyncDataService> _logger;
    private static readonly List<User> _users = new()
    {
        new User { Id = 1, Name = "John Doe", Email = "john@example.com" },
        new User { Id = 2, Name = "Jane Smith", Email = "jane@example.com" }
    };

    public AsyncDataService(HttpClient httpClient, ILogger<AsyncDataService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<List<User>> GetAllUsersAsync()
    {
        _logger.LogInformation("Fetching all users");
        await Task.Delay(100);
        return _users.ToList();
    }

    public async Task<User?> GetUserByIdAsync(int id)
    {
        _logger.LogInformation("Fetching user with ID: {UserId}", id);
        await Task.Delay(50);
        return _users.FirstOrDefault(u => u.Id == id);
    }

    public async Task<User> CreateUserAsync(string name, string email)
    {
        _logger.LogInformation("Creating user: {Name}, {Email}", name, email);
        await Task.Delay(200);

        var user = new User
        {
            Id = _users.Count + 1,
            Name = name,
            Email = email
        };

        _users.Add(user);
        return user;
    }

    public async Task<object> GetExternalUserDataAsync(int userId)
    {
        _logger.LogInformation("Fetching external data for user: {UserId}", userId);

        try
        {
            var response = await _httpClient.GetAsync($"https://jsonplaceholder.typicode.com/users/{userId}");

            if (response.IsSuccessStatusCode)
            {
                var content = await response.Content.ReadAsStringAsync();
                return JsonSerializer.Deserialize<object>(content) ?? new { message = "No data" };
            }

            return new { message = "External service unavailable" };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to fetch external data");
            return new { message = "Error fetching external data" };
        }
    }
}
'@ "Implementation of async data service with mock data"

        # Create basic async service
        Create-FileInteractive "Services/AsyncBasicsService.cs" @'
namespace AsyncDemo.Services;

public interface IAsyncBasicsService
{
    Task<string> GetDataAsync();
    Task<List<string>> GetMultipleDataAsync();
    ValueTask<int> CalculateAsync(int value);
    Task<string> HandleExceptionAsync();
    Task<string> GetDataWithTimeoutAsync(int timeoutMs);
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

    public async Task<string> GetDataWithTimeoutAsync(int timeoutMs)
    {
        _logger.LogInformation("Starting data retrieval with timeout: {TimeoutMs}ms", timeoutMs);

        using var cts = new CancellationTokenSource(TimeSpan.FromMilliseconds(timeoutMs));

        try
        {
            // Simulate work that might take longer than timeout
            await Task.Delay(timeoutMs + 500, cts.Token);
            return "Data retrieved successfully";
        }
        catch (OperationCanceledException)
        {
            _logger.LogWarning("Data retrieval timed out after {TimeoutMs}ms", timeoutMs);
            throw new TimeoutException($"Operation timed out after {timeoutMs}ms");
        }
    }

    private async Task<string> GetSingleDataAsync(string dataName, int delayMs)
    {
        await Task.Delay(delayMs);
        return $"{dataName} (retrieved in {delayMs}ms)";
    }
}
'@ "Basic async service demonstrating fundamental async patterns"

        Write-Success "✅ Exercise 1: Slow File Processing API - READY TO TEST!"
        Write-Host ""
        Write-Host "🧪 NOW TEST THE PROBLEM:" -ForegroundColor Red
        Write-Host "1. Start the API: dotnet run" -ForegroundColor Cyan
        Write-Host "2. Run the load test: .\test-load.ps1" -ForegroundColor Cyan
        Write-Host "3. Watch sync requests FAIL under load!" -ForegroundColor Red
        Write-Host "4. See async requests SUCCEED under load!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎯 LEARNING OBJECTIVES:" -ForegroundColor Yellow
        Write-Host "• Understand WHY blocking I/O kills scalability" -ForegroundColor White
        Write-Host "• See the difference between File.ReadAllText vs File.ReadAllTextAsync" -ForegroundColor White
        Write-Host "• Measure thread pool usage with /thread-info endpoint" -ForegroundColor White
        Write-Host "• Experience the performance difference firsthand!" -ForegroundColor White
    }

    "exercise02" {
        # Exercise 2: Async API Development

        Explain-Concept "🚨 THE PROBLEM: Async/Sync Deadlocks" @"
You've inherited a web app that randomly freezes under load - classic deadlock scenario!

CURRENT ISSUES:
• Controllers call .Result on async methods (DEADLY!)
• SynchronizationContext deadlocks in ASP.NET
• App becomes completely unresponsive
• No clear error messages - just hangs forever

YOUR MISSION:
• Identify the deadlock patterns
• Fix blocking async calls
• Understand ConfigureAwait(false)
• Make the app truly async all the way down
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 2 requires Exercise 1 to be completed first!"
            Write-Info "Please run: .\launch-exercises.ps1 exercise01"
            exit 1
        }

        # Create a DEADLOCKING service that demonstrates the problem
        Create-FileInteractive "Services/DeadlockDemoService.cs" @'
namespace AsyncDemo.Services;

public interface IDeadlockDemoService
{
    string GetDataSync(); // This will cause deadlocks!
    Task<string> GetDataAsync(); // This is the correct way
    string GetDataSyncFixed(); // This shows how to fix it
}

public class DeadlockDemoService : IDeadlockDemoService
{
    private readonly ILogger<DeadlockDemoService> _logger;
    private readonly HttpClient _httpClient;

    public DeadlockDemoService(ILogger<DeadlockDemoService> logger, HttpClient httpClient)
    {
        _logger = logger;
        _httpClient = httpClient;
    }

    /// <summary>
    /// 🚨 DEADLOCK DANGER! This method will cause deadlocks in ASP.NET!
    /// It calls async methods synchronously using .Result
    /// </summary>
    public string GetDataSync()
    {
        _logger.LogWarning("🚨 DEADLOCK RISK: Calling async method with .Result!");

        try
        {
            // 💀 THIS CAUSES DEADLOCKS IN ASP.NET!
            // The async method tries to return to the original context
            // But the original thread is blocked waiting for .Result
            var result = GetDataAsync().Result; // DEADLOCK!

            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Deadlock occurred!");
            return "DEADLOCK OCCURRED!";
        }
    }

    /// <summary>
    /// ✅ CORRECT: This is the proper async method
    /// </summary>
    public async Task<string> GetDataAsync()
    {
        _logger.LogInformation("✅ Proper async method executing");

        // Simulate async work (like calling external API)
        await Task.Delay(1000);

        // Simulate HTTP call that could deadlock if called synchronously
        try
        {
            var response = await _httpClient.GetStringAsync("https://api.github.com/users/octocat");
            return $"Async data retrieved successfully. Response length: {response.Length}";
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "HTTP call failed");
            return "Async operation completed with simulated data";
        }
    }

    /// <summary>
    /// ✅ FIXED: This shows how to properly call async from sync
    /// Using ConfigureAwait(false) and proper async patterns
    /// </summary>
    public string GetDataSyncFixed()
    {
        _logger.LogInformation("✅ FIXED: Using ConfigureAwait(false) pattern");

        try
        {
            // ✅ SOLUTION: Use ConfigureAwait(false) to avoid deadlocks
            var result = GetDataAsyncWithConfigureAwait().ConfigureAwait(false).GetAwaiter().GetResult();
            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in fixed sync method");
            return "Error occurred in fixed method";
        }
    }

    private async Task<string> GetDataAsyncWithConfigureAwait()
    {
        // ✅ ConfigureAwait(false) prevents deadlocks by not capturing the synchronization context
        await Task.Delay(1000).ConfigureAwait(false);

        try
        {
            var response = await _httpClient.GetStringAsync("https://api.github.com/users/octocat").ConfigureAwait(false);
            return $"Fixed async data retrieved. Response length: {response.Length}";
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "HTTP call failed in fixed method");
            return "Fixed async operation completed with simulated data";
        }
    }
}
'@ "Service that demonstrates deadlock problems and solutions"

        # Create the DEADLOCKING controller
        Create-FileInteractive "Controllers/DeadlockController.cs" @'
using Microsoft.AspNetCore.Mvc;
using AsyncDemo.Services;
using System.Diagnostics;

namespace AsyncDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DeadlockController : ControllerBase
{
    private readonly IDeadlockDemoService _deadlockService;
    private readonly ILogger<DeadlockController> _logger;

    public DeadlockController(IDeadlockDemoService deadlockService, ILogger<DeadlockController> logger)
    {
        _deadlockService = deadlockService;
        _logger = logger;
    }

    /// <summary>
    /// 🚨 DEADLOCK DANGER! This endpoint will hang/freeze the application!
    /// DO NOT call this in production - it demonstrates the deadlock problem
    /// </summary>
    [HttpGet("dangerous-sync")]
    public IActionResult DangerousSync()
    {
        var stopwatch = Stopwatch.StartNew();
        _logger.LogWarning("🚨 DANGER: About to call deadlock-prone method!");

        try
        {
            // 💀 THIS WILL CAUSE A DEADLOCK!
            // The controller is running in ASP.NET context
            // The service calls async methods with .Result
            // This creates a deadlock scenario
            var result = _deadlockService.GetDataSync();

            stopwatch.Stop();

            return Ok(new
            {
                Message = "If you see this, the deadlock was avoided (unlikely!)",
                Result = result,
                ElapsedMs = stopwatch.ElapsedMilliseconds,
                Warning = "🚨 This method is dangerous and can cause deadlocks!"
            });
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            _logger.LogError(ex, "Deadlock or error occurred");

            return StatusCode(500, new
            {
                Error = "Deadlock or timeout occurred",
                Message = ex.Message,
                ElapsedMs = stopwatch.ElapsedMilliseconds,
                Explanation = "This demonstrates why you should never call .Result on async methods in ASP.NET!"
            });
        }
    }

    /// <summary>
    /// ✅ CORRECT: This endpoint uses proper async patterns
    /// </summary>
    [HttpGet("safe-async")]
    public async Task<IActionResult> SafeAsync()
    {
        var stopwatch = Stopwatch.StartNew();
        _logger.LogInformation("✅ SAFE: Using proper async patterns");

        try
        {
            // ✅ CORRECT: Proper async all the way down
            var result = await _deadlockService.GetDataAsync();

            stopwatch.Stop();

            return Ok(new
            {
                Message = "Success! No deadlocks with proper async patterns",
                Result = result,
                ElapsedMs = stopwatch.ElapsedMilliseconds,
                Pattern = "✅ Async all the way down"
            });
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            _logger.LogError(ex, "Error in safe async method");

            return StatusCode(500, new
            {
                Error = "Error occurred (but no deadlock)",
                Message = ex.Message,
                ElapsedMs = stopwatch.ElapsedMilliseconds
            });
        }
    }

    /// <summary>
    /// ✅ FIXED: This shows how to properly handle sync calls when needed
    /// </summary>
    [HttpGet("fixed-sync")]
    public IActionResult FixedSync()
    {
        var stopwatch = Stopwatch.StartNew();
        _logger.LogInformation("✅ FIXED: Using ConfigureAwait(false) pattern");

        try
        {
            // ✅ SOLUTION: Using ConfigureAwait(false) to avoid deadlocks
            var result = _deadlockService.GetDataSyncFixed();

            stopwatch.Stop();

            return Ok(new
            {
                Message = "Success! ConfigureAwait(false) prevents deadlocks",
                Result = result,
                ElapsedMs = stopwatch.ElapsedMilliseconds,
                Pattern = "✅ ConfigureAwait(false) pattern"
            });
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            _logger.LogError(ex, "Error in fixed sync method");

            return StatusCode(500, new
            {
                Error = "Error occurred",
                Message = ex.Message,
                ElapsedMs = stopwatch.ElapsedMilliseconds
            });
        }
    }

    /// <summary>
    /// 📊 Test multiple concurrent requests to see deadlock behavior
    /// </summary>
    [HttpGet("stress-test/{method}")]
    public async Task<IActionResult> StressTest(string method)
    {
        var stopwatch = Stopwatch.StartNew();
        var tasks = new List<Task<string>>();

        _logger.LogInformation("🧪 Starting stress test for method: {Method}", method);

        // Create 5 concurrent tasks
        for (int i = 0; i < 5; i++)
        {
            switch (method.ToLower())
            {
                case "dangerous":
                    // This will likely deadlock or timeout
                    tasks.Add(Task.Run(() => _deadlockService.GetDataSync()));
                    break;
                case "safe":
                    // This should work fine
                    tasks.Add(_deadlockService.GetDataAsync());
                    break;
                case "fixed":
                    // This should also work fine
                    tasks.Add(Task.Run(() => _deadlockService.GetDataSyncFixed()));
                    break;
                default:
                    return BadRequest("Method must be: dangerous, safe, or fixed");
            }
        }

        try
        {
            // Wait for all tasks with a timeout
            var timeoutTask = Task.Delay(10000); // 10 second timeout
            var completedTask = await Task.WhenAny(Task.WhenAll(tasks), timeoutTask);

            stopwatch.Stop();

            if (completedTask == timeoutTask)
            {
                return Ok(new
                {
                    Result = "TIMEOUT - Likely deadlock occurred!",
                    Method = method,
                    ElapsedMs = stopwatch.ElapsedMilliseconds,
                    CompletedTasks = tasks.Count(t => t.IsCompleted),
                    TotalTasks = tasks.Count,
                    Warning = "⚠️ Timeout suggests deadlock in dangerous method"
                });
            }

            var results = await Task.WhenAll(tasks);

            return Ok(new
            {
                Result = "All tasks completed successfully!",
                Method = method,
                ElapsedMs = stopwatch.ElapsedMilliseconds,
                CompletedTasks = results.Length,
                TotalTasks = tasks.Count,
                Results = results
            });
        }
        catch (Exception ex)
        {
            stopwatch.Stop();

            return Ok(new
            {
                Result = "Exception occurred during stress test",
                Method = method,
                ElapsedMs = stopwatch.ElapsedMilliseconds,
                Error = ex.Message,
                CompletedTasks = tasks.Count(t => t.IsCompleted),
                TotalTasks = tasks.Count
            });
        }
    }
}
'@ "Controller that demonstrates deadlock problems and solutions"

        # Create deadlock testing script
        Create-FileInteractive "test-deadlocks.ps1" @'
# Deadlock Testing Script - Demonstrates Async/Sync Deadlock Problems
# Run this after starting the API to see deadlock behavior!

Write-Host "🧪 Deadlock Testing: Async/Sync Problems" -ForegroundColor Cyan
Write-Host "Make sure your API is running on https://localhost:7000 (or update the URL below)"
Write-Host ""

$baseUrl = "https://localhost:7000/api/Deadlock"

Write-Host "⚠️  WARNING: Some of these tests may cause the application to hang!" -ForegroundColor Red
Write-Host "If the app becomes unresponsive, you'll need to restart it." -ForegroundColor Red
Write-Host ""

# Test 1: Safe async method (should always work)
Write-Host "📊 Test 1: Safe Async Method (Should Work)" -ForegroundColor Green
try {
    $result = Invoke-RestMethod "$baseUrl/safe-async" -TimeoutSec 30
    Write-Host "✅ Safe async completed successfully" -ForegroundColor Green
    Write-Host "   Time: $($result.ElapsedMs)ms" -ForegroundColor Gray
} catch {
    Write-Host "❌ Safe async failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 2: Fixed sync method (should work with ConfigureAwait)
Write-Host "📊 Test 2: Fixed Sync Method (ConfigureAwait Pattern)" -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod "$baseUrl/fixed-sync" -TimeoutSec 30
    Write-Host "✅ Fixed sync completed successfully" -ForegroundColor Green
    Write-Host "   Time: $($result.ElapsedMs)ms" -ForegroundColor Gray
    Write-Host "   Pattern: $($result.Pattern)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Fixed sync failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 3: Dangerous sync method (likely to deadlock!)
Write-Host "📊 Test 3: Dangerous Sync Method (⚠️  MAY DEADLOCK!)" -ForegroundColor Red
Write-Host "This test may hang the application - testing deadlock scenario..." -ForegroundColor Yellow

try {
    $result = Invoke-RestMethod "$baseUrl/dangerous-sync" -TimeoutSec 15
    Write-Host "😱 Dangerous sync somehow completed (unexpected!)" -ForegroundColor Yellow
    Write-Host "   Time: $($result.ElapsedMs)ms" -ForegroundColor Gray
} catch {
    if ($_.Exception.Message -like "*timeout*" -or $_.Exception.Message -like "*timed out*") {
        Write-Host "💀 DEADLOCK DETECTED! Request timed out - this proves the deadlock!" -ForegroundColor Red
        Write-Host "   This is exactly what happens in production with .Result calls!" -ForegroundColor Red
    } else {
        Write-Host "❌ Dangerous sync failed with error: $_" -ForegroundColor Red
    }
}
Write-Host ""

# Test 4: Stress test comparison
Write-Host "📊 Test 4: Stress Test Comparison" -ForegroundColor Cyan

Write-Host "Testing safe async under load..." -ForegroundColor Yellow
try {
    $safeResult = Invoke-RestMethod "$baseUrl/stress-test/safe" -TimeoutSec 30
    Write-Host "✅ Safe stress test: $($safeResult.CompletedTasks)/$($safeResult.TotalTasks) tasks completed" -ForegroundColor Green
    Write-Host "   Time: $($safeResult.ElapsedMs)ms" -ForegroundColor Gray
} catch {
    Write-Host "❌ Safe stress test failed: $_" -ForegroundColor Red
}

Write-Host "Testing fixed sync under load..." -ForegroundColor Yellow
try {
    $fixedResult = Invoke-RestMethod "$baseUrl/stress-test/fixed" -TimeoutSec 30
    Write-Host "✅ Fixed stress test: $($fixedResult.CompletedTasks)/$($fixedResult.TotalTasks) tasks completed" -ForegroundColor Green
    Write-Host "   Time: $($fixedResult.ElapsedMs)ms" -ForegroundColor Gray
} catch {
    Write-Host "❌ Fixed stress test failed: $_" -ForegroundColor Red
}

Write-Host "Testing dangerous sync under load (may hang!)..." -ForegroundColor Red
try {
    $dangerousResult = Invoke-RestMethod "$baseUrl/stress-test/dangerous" -TimeoutSec 20
    if ($dangerousResult.Result -like "*TIMEOUT*") {
        Write-Host "💀 DEADLOCK CONFIRMED! Dangerous method timed out under load" -ForegroundColor Red
        Write-Host "   Completed: $($dangerousResult.CompletedTasks)/$($dangerousResult.TotalTasks) tasks" -ForegroundColor Red
    } else {
        Write-Host "😱 Dangerous stress test somehow completed: $($dangerousResult.CompletedTasks)/$($dangerousResult.TotalTasks)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "💀 DEADLOCK! Dangerous stress test timed out completely" -ForegroundColor Red
    Write-Host "   This proves why .Result is dangerous in ASP.NET!" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 LEARNING SUMMARY:" -ForegroundColor Cyan
Write-Host "✅ Async methods work reliably under load" -ForegroundColor Green
Write-Host "✅ ConfigureAwait(false) prevents deadlocks in sync calls" -ForegroundColor Green
Write-Host "💀 .Result calls cause deadlocks in ASP.NET applications" -ForegroundColor Red
Write-Host ""
Write-Host "💡 Key Takeaways:" -ForegroundColor Yellow
Write-Host "• Never use .Result or .Wait() in ASP.NET applications"
Write-Host "• Use async/await all the way down"
Write-Host "• If you must call async from sync, use ConfigureAwait(false)"
Write-Host "• Deadlocks are silent killers - they just hang forever"
'@ "PowerShell script to test and demonstrate deadlock scenarios"

        # Create the async API service for Exercise 2
        Create-FileInteractive "Services/AsyncApiService.cs" @'
using AsyncDemo.Models;

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

        Write-Success "✅ Exercise 2: Deadlocking Web App - READY TO TEST!"
        Write-Host ""
        Write-Host "🧪 NOW TEST THE DEADLOCKS:" -ForegroundColor Red
        Write-Host "1. Register the service in Program.cs:" -ForegroundColor Cyan
        Write-Host "   builder.Services.AddScoped<IDeadlockDemoService, DeadlockDemoService>();" -ForegroundColor Gray
        Write-Host "   builder.Services.AddHttpClient<DeadlockDemoService>();" -ForegroundColor Gray
        Write-Host "2. Start the API: dotnet run" -ForegroundColor Cyan
        Write-Host "3. Run deadlock tests: .\test-deadlocks.ps1" -ForegroundColor Cyan
        Write-Host "4. Watch dangerous endpoints HANG!" -ForegroundColor Red
        Write-Host "5. See safe endpoints work perfectly!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎯 LEARNING OBJECTIVES:" -ForegroundColor Yellow
        Write-Host "• Experience deadlocks firsthand" -ForegroundColor White
        Write-Host "• Understand why .Result is dangerous in ASP.NET" -ForegroundColor White
        Write-Host "• Learn ConfigureAwait(false) patterns" -ForegroundColor White
        Write-Host "• Master async all the way down principle" -ForegroundColor White
    }

    "exercise03" {
        # Exercise 3: Background Tasks & Services

        Explain-Concept "🚨 THE PROBLEM: Manual Background Processing" @"
You're building a document processing system that needs background processing!

CURRENT ISSUES:
• Files uploaded but processing blocks the API response
• No way to monitor long-running file processing
• Manual folder monitoring is error-prone
• Reports need to be generated on a schedule
• Old files pile up without cleanup

YOUR MISSION:
• Implement background task queue system
• Create hosted services for file monitoring
• Build scheduled tasks for reports
• Add progress tracking for long operations
• Create automatic cleanup service
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 3 requires Exercises 1 and 2 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03"
            exit 1
        }

        # Create models for background processing
        Create-FileInteractive "Models/ProcessingJob.cs" @'
namespace AsyncDemo.Models;

public class ProcessingJob
{
    public int Id { get; set; }
    public string JobType { get; set; } = string.Empty;
    public string FileName { get; set; } = string.Empty;
    public string FilePath { get; set; } = string.Empty;
    public JobStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
    public string? ErrorMessage { get; set; }
    public string? ResultData { get; set; }
    public int Progress { get; set; } // 0-100
}

public enum JobStatus
{
    Queued,
    Processing,
    Completed,
    Failed,
    Cancelled
}

public class ProcessingResult
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public Dictionary<string, object> Metadata { get; set; } = new();
}
'@ "Models for background task processing system"

        # Create background task queue interface and implementation
        Create-FileInteractive "Services/BackgroundTaskQueue.cs" @'
using AsyncDemo.Models;
using System.Diagnostics;

namespace AsyncDemo.Services;

public interface IDataProcessingService
{
    Task<ProcessingResult> ProcessDataSequentiallyAsync(int recordCount);
    Task<ProcessingResult> ProcessDataConcurrentlyAsync(int recordCount);
    Task<ProcessingResult> ProcessDataWithConcurrencyControlAsync(int recordCount, int maxConcurrency);
    List<DataRecord> GenerateTestData(int count);
}

public class DataProcessingService : IDataProcessingService
{
    private readonly ILogger<DataProcessingService> _logger;
    private readonly HttpClient _httpClient;

    public DataProcessingService(ILogger<DataProcessingService> logger, HttpClient httpClient)
    {
        _logger = logger;
        _httpClient = httpClient;
    }

    /// <summary>
    /// 🚨 SLOW: Processes records one at a time (sequential)
    /// This simulates the common mistake of not using concurrency
    /// </summary>
    public async Task<ProcessingResult> ProcessDataSequentiallyAsync(int recordCount)
    {
        var stopwatch = Stopwatch.StartNew();
        var records = GenerateTestData(recordCount);
        var errors = new List<string>();
        int processedCount = 0;

        _logger.LogInformation("🐌 SEQUENTIAL: Processing {Count} records one by one", recordCount);

        foreach (var record in records)
        {
            try
            {
                // 🐌 PROBLEM: Processing one record at a time!
                await ProcessSingleRecordAsync(record);
                processedCount++;

                if (processedCount % 10 == 0)
                {
                    _logger.LogInformation("SEQUENTIAL: Processed {Processed}/{Total} records",
                        processedCount, recordCount);
                }
            }
            catch (Exception ex)
            {
                errors.Add($"Record {record.Id}: {ex.Message}");
                _logger.LogError(ex, "Failed to process record {RecordId}", record.Id);
            }
        }

        stopwatch.Stop();
        var recordsPerSecond = recordCount / (stopwatch.ElapsedMilliseconds / 1000.0);

        _logger.LogInformation("🐌 SEQUENTIAL: Completed {Processed}/{Total} records in {ElapsedMs}ms ({RecordsPerSec:F1} records/sec)",
            processedCount, recordCount, stopwatch.ElapsedMilliseconds, recordsPerSecond);

        return new ProcessingResult
        {
            TotalRecords = recordCount,
            ProcessedRecords = processedCount,
            FailedRecords = recordCount - processedCount,
            TotalProcessingTimeMs = stopwatch.ElapsedMilliseconds,
            Method = "SEQUENTIAL (SLOW)",
            RecordsPerSecond = recordsPerSecond,
            Errors = errors
        };
    }

    /// <summary>
    /// ✅ FAST: Processes all records concurrently
    /// This shows the power of Task.WhenAll for I/O bound operations
    /// </summary>
    public async Task<ProcessingResult> ProcessDataConcurrentlyAsync(int recordCount)
    {
        var stopwatch = Stopwatch.StartNew();
        var records = GenerateTestData(recordCount);
        var errors = new List<string>();

        _logger.LogInformation("🚀 CONCURRENT: Processing {Count} records concurrently", recordCount);

        // ✅ SOLUTION: Process all records concurrently!
        var tasks = records.Select(async record =>
        {
            try
            {
                await ProcessSingleRecordAsync(record);
                return new { Success = true, Record = record, Error = (string?)null };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to process record {RecordId}", record.Id);
                return new { Success = false, Record = record, Error = ex.Message };
            }
        });

        var results = await Task.WhenAll(tasks);

        var processedCount = results.Count(r => r.Success);
        errors.AddRange(results.Where(r => !r.Success).Select(r => $"Record {r.Record.Id}: {r.Error}"));

        stopwatch.Stop();
        var recordsPerSecond = recordCount / (stopwatch.ElapsedMilliseconds / 1000.0);

        _logger.LogInformation("🚀 CONCURRENT: Completed {Processed}/{Total} records in {ElapsedMs}ms ({RecordsPerSec:F1} records/sec)",
            processedCount, recordCount, stopwatch.ElapsedMilliseconds, recordsPerSecond);

        return new ProcessingResult
        {
            TotalRecords = recordCount,
            ProcessedRecords = processedCount,
            FailedRecords = recordCount - processedCount,
            TotalProcessingTimeMs = stopwatch.ElapsedMilliseconds,
            Method = "CONCURRENT (FAST)",
            RecordsPerSecond = recordsPerSecond,
            Errors = errors
        };
    }

    /// <summary>
    /// ✅ CONTROLLED: Processes records concurrently but with limited concurrency
    /// This shows how to balance performance with resource usage
    /// </summary>
    public async Task<ProcessingResult> ProcessDataWithConcurrencyControlAsync(int recordCount, int maxConcurrency)
    {
        var stopwatch = Stopwatch.StartNew();
        var records = GenerateTestData(recordCount);
        var errors = new List<string>();
        var semaphore = new SemaphoreSlim(maxConcurrency, maxConcurrency);
        int processedCount = 0;

        _logger.LogInformation("⚖️  CONTROLLED: Processing {Count} records with max {MaxConcurrency} concurrent operations",
            recordCount, maxConcurrency);

        // ✅ SOLUTION: Use SemaphoreSlim to control concurrency
        var tasks = records.Select(async record =>
        {
            await semaphore.WaitAsync();
            try
            {
                await ProcessSingleRecordAsync(record);
                Interlocked.Increment(ref processedCount);

                if (processedCount % 25 == 0)
                {
                    _logger.LogInformation("CONTROLLED: Processed {Processed}/{Total} records",
                        processedCount, recordCount);
                }

                return new { Success = true, Record = record, Error = (string?)null };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to process record {RecordId}", record.Id);
                return new { Success = false, Record = record, Error = ex.Message };
            }
            finally
            {
                semaphore.Release();
            }
        });

        var results = await Task.WhenAll(tasks);

        var successCount = results.Count(r => r.Success);
        errors.AddRange(results.Where(r => !r.Success).Select(r => $"Record {r.Record.Id}: {r.Error}"));

        stopwatch.Stop();
        var recordsPerSecond = recordCount / (stopwatch.ElapsedMilliseconds / 1000.0);

        _logger.LogInformation("⚖️  CONTROLLED: Completed {Processed}/{Total} records in {ElapsedMs}ms ({RecordsPerSec:F1} records/sec)",
            successCount, recordCount, stopwatch.ElapsedMilliseconds, recordsPerSecond);

        return new ProcessingResult
        {
            TotalRecords = recordCount,
            ProcessedRecords = successCount,
            FailedRecords = recordCount - successCount,
            TotalProcessingTimeMs = stopwatch.ElapsedMilliseconds,
            Method = $"CONTROLLED (Max {maxConcurrency} concurrent)",
            RecordsPerSecond = recordsPerSecond,
            Errors = errors
        };
    }

    /// <summary>
    /// Simulates processing a single record (with realistic I/O delay)
    /// </summary>
    private async Task ProcessSingleRecordAsync(DataRecord record)
    {
        var processingStopwatch = Stopwatch.StartNew();

        // Simulate different types of processing with varying delays
        var processingType = record.Id % 3;

        switch (processingType)
        {
            case 0:
                // Simulate database operation
                await Task.Delay(Random.Shared.Next(50, 150));
                break;
            case 1:
                // Simulate file I/O operation
                await Task.Delay(Random.Shared.Next(100, 200));
                break;
            case 2:
                // Simulate external API call
                try
                {
                    // Occasionally make a real HTTP call to add realism
                    if (Random.Shared.Next(1, 20) == 1)
                    {
                        await _httpClient.GetStringAsync("https://httpbin.org/delay/0");
                    }
                    else
                    {
                        await Task.Delay(Random.Shared.Next(75, 175));
                    }
                }
                catch
                {
                    // Ignore HTTP errors for this demo
                    await Task.Delay(Random.Shared.Next(75, 175));
                }
                break;
        }

        // Simulate occasional processing failures
        if (Random.Shared.Next(1, 50) == 1)
        {
            throw new InvalidOperationException($"Simulated processing failure for record {record.Id}");
        }

        processingStopwatch.Stop();
        record.IsProcessed = true;
        record.ProcessedAt = DateTime.UtcNow;
        record.ProcessingTimeMs = (int)processingStopwatch.ElapsedMilliseconds;
    }

    /// <summary>
    /// Generates test data for processing demonstrations
    /// </summary>
    public List<DataRecord> GenerateTestData(int count)
    {
        var records = new List<DataRecord>();

        for (int i = 1; i <= count; i++)
        {
            records.Add(new DataRecord
            {
                Id = i,
                Name = $"Record_{i:D4}",
                Data = $"Sample data for record {i} - {Guid.NewGuid()}",
                CreatedAt = DateTime.UtcNow.AddMinutes(-Random.Shared.Next(1, 1440)) // Random time in last 24 hours
            });
        }

        return records;
    }
}
'@ "Data processing service that demonstrates sequential vs concurrent processing"

        # Create the performance comparison controller
        Create-FileInteractive "Controllers/PerformanceController.cs" @'
using Microsoft.AspNetCore.Mvc;
using AsyncDemo.Services;
using AsyncDemo.Models;
using System.Diagnostics;

namespace AsyncDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PerformanceController : ControllerBase
{
    private readonly IDataProcessingService _dataProcessingService;
    private readonly ILogger<PerformanceController> _logger;

    public PerformanceController(IDataProcessingService dataProcessingService, ILogger<PerformanceController> logger)
    {
        _dataProcessingService = dataProcessingService;
        _logger = logger;
    }

    /// <summary>
    /// 🐌 SLOW: Process records sequentially (one at a time)
    /// This demonstrates the performance problem
    /// </summary>
    [HttpPost("process-sequential")]
    public async Task<IActionResult> ProcessSequential([FromBody] ProcessingRequest request)
    {
        _logger.LogInformation("🐌 Starting sequential processing of {Count} records", request.RecordCount);

        var result = await _dataProcessingService.ProcessDataSequentiallyAsync(request.RecordCount);

        return Ok(new
        {
            Success = true,
            Result = result,
            PerformanceAnalysis = new
            {
                Efficiency = "POOR - Sequential processing",
                Recommendation = "Use concurrent processing for better performance",
                ExpectedImprovement = "5-10x faster with concurrency"
            }
        });
    }

    /// <summary>
    /// 🚀 FAST: Process records concurrently (all at once)
    /// This demonstrates the performance solution
    /// </summary>
    [HttpPost("process-concurrent")]
    public async Task<IActionResult> ProcessConcurrent([FromBody] ProcessingRequest request)
    {
        _logger.LogInformation("🚀 Starting concurrent processing of {Count} records", request.RecordCount);

        var result = await _dataProcessingService.ProcessDataConcurrentlyAsync(request.RecordCount);

        return Ok(new
        {
            Success = true,
            Result = result,
            PerformanceAnalysis = new
            {
                Efficiency = "EXCELLENT - Concurrent processing",
                Recommendation = "This is the optimal approach for I/O bound operations",
                Benefit = "Maximizes CPU and I/O utilization"
            }
        });
    }

    /// <summary>
    /// ⚖️ CONTROLLED: Process records with limited concurrency
    /// This demonstrates how to balance performance with resource usage
    /// </summary>
    [HttpPost("process-controlled")]
    public async Task<IActionResult> ProcessControlled([FromBody] ControlledProcessingRequest request)
    {
        _logger.LogInformation("⚖️ Starting controlled processing of {Count} records with max {MaxConcurrency} concurrent",
            request.RecordCount, request.MaxConcurrency);

        var result = await _dataProcessingService.ProcessDataWithConcurrencyControlAsync(
            request.RecordCount, request.MaxConcurrency);

        return Ok(new
        {
            Success = true,
            Result = result,
            PerformanceAnalysis = new
            {
                Efficiency = $"BALANCED - Controlled concurrency (max {request.MaxConcurrency})",
                Recommendation = "Use this approach to prevent resource exhaustion",
                Benefit = "Balances performance with system stability"
            }
        });
    }

    /// <summary>
    /// 📊 Compare all three processing methods side by side
    /// This gives students a clear performance comparison
    /// </summary>
    [HttpPost("compare-all")]
    public async Task<IActionResult> CompareAllMethods([FromBody] ProcessingRequest request)
    {
        _logger.LogInformation("📊 Starting performance comparison for {Count} records", request.RecordCount);

        var overallStopwatch = Stopwatch.StartNew();
        var results = new List<object>();

        // Test sequential processing
        _logger.LogInformation("Testing sequential processing...");
        var sequentialResult = await _dataProcessingService.ProcessDataSequentiallyAsync(request.RecordCount);
        results.Add(new
        {
            Method = "Sequential",
            Result = sequentialResult,
            Rank = 3,
            Recommendation = "❌ Avoid - Too slow for production"
        });

        // Test concurrent processing
        _logger.LogInformation("Testing concurrent processing...");
        var concurrentResult = await _dataProcessingService.ProcessDataConcurrentlyAsync(request.RecordCount);
        results.Add(new
        {
            Method = "Concurrent",
            Result = concurrentResult,
            Rank = 1,
            Recommendation = "✅ Best - Use for I/O bound operations"
        });

        // Test controlled processing
        _logger.LogInformation("Testing controlled processing...");
        var controlledResult = await _dataProcessingService.ProcessDataWithConcurrencyControlAsync(
            request.RecordCount, Math.Min(10, request.RecordCount));
        results.Add(new
        {
            Method = "Controlled",
            Result = controlledResult,
            Rank = 2,
            Recommendation = "✅ Good - Use when resource limits matter"
        });

        overallStopwatch.Stop();

        // Calculate performance improvements
        var sequentialTime = sequentialResult.TotalProcessingTimeMs;
        var concurrentTime = concurrentResult.TotalProcessingTimeMs;
        var controlledTime = controlledResult.TotalProcessingTimeMs;

        var concurrentImprovement = (double)sequentialTime / concurrentTime;
        var controlledImprovement = (double)sequentialTime / controlledTime;

        return Ok(new
        {
            Success = true,
            TotalComparisonTimeMs = overallStopwatch.ElapsedMilliseconds,
            RecordCount = request.RecordCount,
            Results = results.OrderBy(r => ((dynamic)r).Rank),
            PerformanceAnalysis = new
            {
                SequentialTime = $"{sequentialTime}ms",
                ConcurrentTime = $"{concurrentTime}ms",
                ControlledTime = $"{controlledTime}ms",
                ConcurrentImprovement = $"{concurrentImprovement:F1}x faster",
                ControlledImprovement = $"{controlledImprovement:F1}x faster",
                Winner = concurrentTime < controlledTime ? "Concurrent" : "Controlled",
                KeyLearning = "Concurrency dramatically improves I/O bound operations"
            },
            Recommendations = new[]
            {
                "🚀 Use concurrent processing for I/O bound operations",
                "⚖️ Use controlled concurrency to prevent resource exhaustion",
                "🐌 Avoid sequential processing for multiple independent operations",
                "📊 Always measure performance to validate improvements"
            }
        });
    }

    /// <summary>
    /// 📈 Generate test data for performance testing
    /// </summary>
    [HttpGet("generate-test-data/{count}")]
    public IActionResult GenerateTestData(int count)
    {
        if (count > 1000)
        {
            return BadRequest("Maximum 1000 records for demo purposes");
        }

        var data = _dataProcessingService.GenerateTestData(count);

        return Ok(new
        {
            Success = true,
            GeneratedRecords = count,
            SampleData = data.Take(5), // Show first 5 records
            Message = $"Generated {count} test records for processing"
        });
    }
}

public class ProcessingRequest
{
    public int RecordCount { get; set; } = 100;
}

public class ControlledProcessingRequest : ProcessingRequest
{
    public int MaxConcurrency { get; set; } = 10;
}
'@ "Controller that demonstrates sequential vs concurrent processing performance"

        # Create performance testing script
        Create-FileInteractive "test-performance.ps1" @'
# Performance Testing Script - Demonstrates Sequential vs Concurrent Processing
# Run this after starting the API to see dramatic performance differences!

Write-Host "🧪 Performance Testing: Sequential vs Concurrent Processing" -ForegroundColor Cyan
Write-Host "Make sure your API is running on https://localhost:7000 (or update the URL below)"
Write-Host ""

$baseUrl = "https://localhost:7000/api/Performance"

# Test different record counts to show scaling behavior
$testCounts = @(50, 100, 200)

foreach ($recordCount in $testCounts) {
    Write-Host "📊 Testing with $recordCount records:" -ForegroundColor Yellow
    Write-Host "=" * 50

    # Test 1: Sequential Processing (SLOW)
    Write-Host "🐌 Testing Sequential Processing..." -ForegroundColor Red
    try {
        $sequentialResult = Invoke-RestMethod "$baseUrl/process-sequential" -Method POST -ContentType "application/json" -Body (@{recordCount=$recordCount} | ConvertTo-Json) -TimeoutSec 120

        $seqTime = $sequentialResult.Result.TotalProcessingTimeMs
        $seqRate = $sequentialResult.Result.RecordsPerSecond

        Write-Host "   ✅ Sequential: ${seqTime}ms (${seqRate:F1} records/sec)" -ForegroundColor White
    } catch {
        Write-Host "   ❌ Sequential failed: $_" -ForegroundColor Red
        continue
    }

    # Test 2: Concurrent Processing (FAST)
    Write-Host "🚀 Testing Concurrent Processing..." -ForegroundColor Green
    try {
        $concurrentResult = Invoke-RestMethod "$baseUrl/process-concurrent" -Method POST -ContentType "application/json" -Body (@{recordCount=$recordCount} | ConvertTo-Json) -TimeoutSec 120

        $concTime = $concurrentResult.Result.TotalProcessingTimeMs
        $concRate = $concurrentResult.Result.RecordsPerSecond

        Write-Host "   ✅ Concurrent: ${concTime}ms (${concRate:F1} records/sec)" -ForegroundColor White
    } catch {
        Write-Host "   ❌ Concurrent failed: $_" -ForegroundColor Red
        continue
    }

    # Test 3: Controlled Processing (BALANCED)
    Write-Host "⚖️  Testing Controlled Processing..." -ForegroundColor Yellow
    try {
        $controlledResult = Invoke-RestMethod "$baseUrl/process-controlled" -Method POST -ContentType "application/json" -Body (@{recordCount=$recordCount; maxConcurrency=10} | ConvertTo-Json) -TimeoutSec 120

        $ctrlTime = $controlledResult.Result.TotalProcessingTimeMs
        $ctrlRate = $controlledResult.Result.RecordsPerSecond

        Write-Host "   ✅ Controlled: ${ctrlTime}ms (${ctrlRate:F1} records/sec)" -ForegroundColor White
    } catch {
        Write-Host "   ❌ Controlled failed: $_" -ForegroundColor Red
        continue
    }

    # Calculate and display improvements
    if ($seqTime -and $concTime -and $ctrlTime) {
        $concurrentImprovement = [math]::Round($seqTime / $concTime, 1)
        $controlledImprovement = [math]::Round($seqTime / $ctrlTime, 1)

        Write-Host ""
        Write-Host "🎯 PERFORMANCE RESULTS for $recordCount records:" -ForegroundColor Cyan
        Write-Host "   Sequential:  ${seqTime}ms (baseline)" -ForegroundColor White
        Write-Host "   Concurrent:  ${concTime}ms (${concurrentImprovement}x faster!) 🚀" -ForegroundColor Green
        Write-Host "   Controlled:  ${ctrlTime}ms (${controlledImprovement}x faster!) ⚖️" -ForegroundColor Yellow

        if ($concurrentImprovement -gt 3) {
            Write-Host "   🎉 AMAZING! Concurrent processing is ${concurrentImprovement}x faster!" -ForegroundColor Green
        } elseif ($concurrentImprovement -gt 2) {
            Write-Host "   ✅ GREAT! Concurrent processing shows significant improvement!" -ForegroundColor Green
        } else {
            Write-Host "   📝 Note: Improvement may be limited by test environment" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "-" * 50
    Write-Host ""
}

# Comprehensive comparison test
Write-Host "🏆 COMPREHENSIVE COMPARISON TEST" -ForegroundColor Magenta
Write-Host "Testing all methods side-by-side with 100 records..."
Write-Host ""

try {
    $comparisonResult = Invoke-RestMethod "$baseUrl/compare-all" -Method POST -ContentType "application/json" -Body (@{recordCount=100} | ConvertTo-Json) -TimeoutSec 180

    Write-Host "📊 FINAL RESULTS:" -ForegroundColor Cyan
    foreach ($result in $comparisonResult.Results) {
        $method = $result.Method
        $time = $result.Result.TotalProcessingTimeMs
        $rate = $result.Result.RecordsPerSecond
        $rank = $result.Rank
        $recommendation = $result.Recommendation

        $rankEmoji = switch ($rank) {
            1 { "🥇" }
            2 { "🥈" }
            3 { "🥉" }
            default { "📊" }
        }

        Write-Host "   $rankEmoji $method`: ${time}ms (${rate:F1} records/sec)" -ForegroundColor White
        Write-Host "      $recommendation" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "🎯 KEY LEARNINGS:" -ForegroundColor Yellow
    Write-Host "• Sequential processing: $($comparisonResult.PerformanceAnalysis.SequentialTime)" -ForegroundColor White
    Write-Host "• Concurrent processing: $($comparisonResult.PerformanceAnalysis.ConcurrentTime)" -ForegroundColor White
    Write-Host "• Performance improvement: $($comparisonResult.PerformanceAnalysis.ConcurrentImprovement)" -ForegroundColor Green
    Write-Host "• Winner: $($comparisonResult.PerformanceAnalysis.Winner) method" -ForegroundColor Green

    Write-Host ""
    Write-Host "💡 RECOMMENDATIONS:" -ForegroundColor Cyan
    foreach ($recommendation in $comparisonResult.Recommendations) {
        Write-Host "   $recommendation" -ForegroundColor White
    }

} catch {
    Write-Host "❌ Comprehensive comparison failed: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎓 WHAT YOU LEARNED:" -ForegroundColor Green
Write-Host "✅ Task.WhenAll dramatically improves I/O bound operations" -ForegroundColor White
Write-Host "✅ Concurrent processing can be 5-10x faster than sequential" -ForegroundColor White
Write-Host "✅ SemaphoreSlim helps control concurrency for resource management" -ForegroundColor White
Write-Host "✅ Always measure performance to validate improvements" -ForegroundColor White
Write-Host ""
Write-Host "🚀 You now understand why async concurrency is crucial for scalable applications!" -ForegroundColor Green
'@ "PowerShell script to test and demonstrate sequential vs concurrent performance"

        # Create timer-based background service
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

        Write-Success "✅ Exercise 3: Slow Data Processing - READY TO OPTIMIZE!"
        Write-Host ""
        Write-Host "🧪 NOW TEST THE PERFORMANCE:" -ForegroundColor Red
        Write-Host "1. Register the service in Program.cs:" -ForegroundColor Cyan
        Write-Host "   builder.Services.AddScoped<IDataProcessingService, DataProcessingService>();" -ForegroundColor Gray
        Write-Host "   builder.Services.AddHttpClient<DataProcessingService>();" -ForegroundColor Gray
        Write-Host "2. Start the API: dotnet run" -ForegroundColor Cyan
        Write-Host "3. Run performance tests: .\test-performance.ps1" -ForegroundColor Cyan
        Write-Host "4. Watch sequential processing crawl!" -ForegroundColor Red
        Write-Host "5. See concurrent processing FLY!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎯 LEARNING OBJECTIVES:" -ForegroundColor Yellow
        Write-Host "• Experience 5-10x performance improvements" -ForegroundColor White
        Write-Host "• Understand Task.WhenAll for concurrent operations" -ForegroundColor White
        Write-Host "• Learn SemaphoreSlim for concurrency control" -ForegroundColor White
        Write-Host "• Measure real performance differences" -ForegroundColor White
    }
}

Write-Host ""
Write-Success "🎉 $ExerciseName async template created successfully!"
Write-Host ""
Write-Info "📚 For detailed async programming guidance, refer to Microsoft's async best practices."
Write-Info "🔗 Additional async resources available in the Resources/ directory."
