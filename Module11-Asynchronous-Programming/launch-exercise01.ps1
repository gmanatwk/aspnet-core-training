#!/usr/bin/env pwsh

# Module 11: Exercise 1 - Basic Async Programming (PowerShell)
# Creates console application matching Exercise01-BasicAsync.md requirements exactly

param(
    [Parameter(Mandatory=$false)]
    [switch]$Auto,
    
    [Parameter(Mandatory=$false)]
    [switch]$Preview
)

# Configuration
$ProjectName = "AsyncExercise01"  # Exact match to exercise requirements
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

# Welcome message
Write-Host "⚡ Module 11: Exercise 1 - Basic Async Programming" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Show learning objectives
Write-Host "🎯 Exercise 1 Learning Objectives:" -ForegroundColor Blue
Write-Host "🚨 PROBLEM: Sequential Data Processing is Slow" -ForegroundColor Red
Write-Host "  🐌 Processing URLs one by one takes forever"
Write-Host "  📊 3 URLs taking 6+ seconds when they could take 2 seconds"
Write-Host "  🎯 GOAL: Learn async/await fundamentals with real scenarios"
Write-Host ""
Write-Host "You'll learn by building:" -ForegroundColor Yellow
Write-Host "  • Download/Process/Save async workflow"
Write-Host "  • Sequential vs concurrent processing"
Write-Host "  • Retry logic with exponential backoff"
Write-Host "  • Proper exception handling in async code"
Write-Host ""

# Show what will be created
Write-Host "📋 Components to be created:" -ForegroundColor Cyan
Write-Host "• Console application with async Main"
Write-Host "• DownloadDataAsync, ProcessDataAsync, SaveDataAsync methods"
Write-Host "• ProcessedData model class"
Write-Host "• Sequential vs concurrent processing comparison"
Write-Host "• Retry logic with exponential backoff"
Write-Host "• Comprehensive exception handling"
Write-Host ""

if ($Preview) {
    Write-Info "Preview mode - no files will be created"
    Write-Host ""
}

# Check prerequisites
Write-Info "Checking prerequisites..."

# Check .NET SDK
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Error ".NET SDK is not installed. Please install .NET 8.0 SDK."
    exit 1
}

Write-Success "Prerequisites check completed"
Write-Host ""

# Check if project exists
if (Test-Path $ProjectName) {
    Write-Warning "Project '$ProjectName' already exists!"
    $Response = Read-Host "Do you want to overwrite it? (y/N)"
    if ($Response -notmatch "^[Yy]$") {
        exit 1
    }
    Remove-Item -Path $ProjectName -Recurse -Force
}

# Explain the async problem
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

EXPECTED PERFORMANCE:
• Sequential: ~6600ms (1000+500+300 + 1500+500+300 + 800+500+300)
• Concurrent: ~2300ms (max(1000,1500,800) + 500 + 300)
"@

# Create the project
if (-not $Preview) {
    Write-Info "Creating console application for Exercise 1..."
    Write-Info "This matches the exercise requirements exactly!"
    dotnet new console -n $ProjectName --framework net8.0
    Set-Location $ProjectName
}

# Create ProcessedData model class as required by exercise
Create-FileInteractive "Models/ProcessedData.cs" @'
namespace AsyncExercise01.Models;

/// <summary>
/// Data model for processed information - matches Exercise 1 requirements exactly
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
'@ "ProcessedData model class matching Exercise 1 requirements exactly"

# Create async methods as required by Exercise 1
Create-FileInteractive "AsyncMethods.cs" @'
using System.Diagnostics;
using AsyncExercise01.Models;

namespace AsyncExercise01;

public static class AsyncMethods
{
    /// <summary>
    /// Method that simulates downloading data from a web service
    /// Matches Exercise 1 requirements exactly
    /// </summary>
    public static async Task<string> DownloadDataAsync(string url, int delayMs)
    {
        Console.WriteLine($"Downloading from {url}...");
        
        // Simulate network delay using Task.Delay
        await Task.Delay(delayMs);
        
        // Return simulated data
        return $"Data from {url} (simulated {delayMs}ms download)";
    }

    /// <summary>
    /// Method that processes downloaded data
    /// Matches Exercise 1 requirements exactly
    /// </summary>
    public static async Task<ProcessedData> ProcessDataAsync(string rawData)
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
    public static async Task SaveDataAsync(ProcessedData data, string fileName)
    {
        Console.WriteLine($"Saving data to {fileName}...");
        
        // Simulate file I/O (300ms as specified)
        await Task.Delay(300);
        
        // Log completion
        Console.WriteLine($"Data saved to {fileName}");
    }

    /// <summary>
    /// Helper method to extract URL from data string
    /// </summary>
    public static string ExtractUrlFromData(string data)
    {
        if (data.Contains("api1.example.com")) return "https://api1.example.com";
        if (data.Contains("api2.example.com")) return "https://api2.example.com";
        if (data.Contains("api3.example.com")) return "https://api3.example.com";
        return "unknown";
    }
}
'@ "Core async methods required by Exercise 1 - DownloadDataAsync, ProcessDataAsync, SaveDataAsync"

# Create processing methods for sequential and concurrent operations
Create-FileInteractive "ProcessingMethods.cs" @'
using System.Diagnostics;
using AsyncExercise01.Models;

namespace AsyncExercise01;

public static class ProcessingMethods
{
    /// <summary>
    /// Sequential processing method - processes URLs one by one
    /// Matches Exercise 1 requirements exactly
    /// </summary>
    public static async Task ProcessUrlsSequentiallyAsync(List<string> urls)
    {
        Console.WriteLine("=== Sequential Processing ===");
        var stopwatch = Stopwatch.StartNew();

        foreach (var url in urls)
        {
            var delay = GetDelayForUrl(url);
            var rawData = await AsyncMethods.DownloadDataAsync(url, delay);
            var processedData = await AsyncMethods.ProcessDataAsync(rawData);
            var fileName = $"{ExtractApiName(url)}_data.txt";
            await AsyncMethods.SaveDataAsync(processedData, fileName);
        }

        stopwatch.Stop();
        Console.WriteLine($"Sequential processing completed in {stopwatch.ElapsedMilliseconds}ms");
    }

    /// <summary>
    /// Concurrent processing method - processes all URLs concurrently
    /// Matches Exercise 1 requirements exactly
    /// </summary>
    public static async Task ProcessUrlsConcurrentlyAsync(List<string> urls)
    {
        Console.WriteLine("=== Concurrent Processing ===");
        var stopwatch = Stopwatch.StartNew();

        // Process all URLs concurrently using Task.WhenAll
        var tasks = urls.Select(async url =>
        {
            var delay = GetDelayForUrl(url);
            var rawData = await AsyncMethods.DownloadDataAsync(url, delay);
            var processedData = await AsyncMethods.ProcessDataAsync(rawData);
            var fileName = $"{ExtractApiName(url)}_data.txt";
            await AsyncMethods.SaveDataAsync(processedData, fileName);
            return processedData;
        });

        var results = await Task.WhenAll(tasks);

        stopwatch.Stop();
        Console.WriteLine($"Concurrent processing completed in {stopwatch.ElapsedMilliseconds}ms");
    }

    /// <summary>
    /// Helper method to get delay for specific URLs (as specified in exercise)
    /// </summary>
    public static int GetDelayForUrl(string url)
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
    /// Helper method to extract API name from URL
    /// </summary>
    public static string ExtractApiName(string url)
    {
        return url switch
        {
            "https://api1.example.com" => "api1",
            "https://api2.example.com" => "api2",
            "https://api3.example.com" => "api3",
            _ => "api"
        };
    }
}
'@ "Sequential and concurrent processing methods matching Exercise 1 requirements"

# Create retry logic methods
Create-FileInteractive "RetryMethods.cs" @'
namespace AsyncExercise01;

public static class RetryMethods
{
    /// <summary>
    /// Download with retry logic - implements exponential backoff
    /// Matches Exercise 1 requirements exactly
    /// </summary>
    public static async Task<string> DownloadWithRetryAsync(string url)
    {
        const int maxRetries = 3;
        var random = new Random();

        for (int attempt = 1; attempt <= maxRetries; attempt++)
        {
            try
            {
                Console.WriteLine($"Attempting download (try {attempt}/{maxRetries})...");

                // Simulate 50% chance of failure on each attempt
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
}
'@ "Retry logic with exponential backoff matching Exercise 1 requirements"

# Create Program.cs with the exact structure required by Exercise 1
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
        await ProcessingMethods.ProcessUrlsSequentiallyAsync(urls);

        Console.WriteLine();

        // Part 2: Concurrent Processing
        await ProcessingMethods.ProcessUrlsConcurrentlyAsync(urls);

        Console.WriteLine();

        // Part 3: Retry Logic Test
        await TestRetryLogic();

        Console.WriteLine("\nPress any key to exit...");
        Console.ReadKey();
    }

    /// <summary>
    /// Retry logic test - implements exponential backoff as required by Exercise 1
    /// </summary>
    static async Task TestRetryLogic()
    {
        Console.WriteLine("=== Retry Logic Test ===");

        try
        {
            var result = await RetryMethods.DownloadWithRetryAsync("https://unreliable-api.example.com");
            Console.WriteLine($"Download successful: {result}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Download failed after all retries: {ex.Message}");
        }
    }
}
'@ "Complete Program.cs with async Main and all required test scenarios"

# Final completion message
Write-Host ""
Write-Success "🎉 Exercise 1 template created successfully!"
Write-Host ""
Write-Info "📋 Next steps:"
Write-Host "1. Run: " -NoNewline
Write-Host "dotnet run" -ForegroundColor Cyan
Write-Host "2. Observe the performance difference between sequential and concurrent processing"
Write-Host "3. Watch the retry logic with exponential backoff in action"
Write-Host "4. Study the async/await patterns in the generated code"
Write-Host ""
Write-Info "🎯 Expected Results:"
Write-Host "• Sequential processing: ~6600ms (slow)"
Write-Host "• Concurrent processing: ~2300ms (fast!)"
Write-Host "• Retry logic: Demonstrates exponential backoff (1s, 2s, 4s)"
Write-Host ""
Write-Info "📚 This implementation matches Exercise01-BasicAsync.md requirements exactly!"
Write-Info "🔗 Study the code to understand fundamental async/await patterns."
