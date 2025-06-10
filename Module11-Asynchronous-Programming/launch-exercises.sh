#!/bin/bash

# Module 11: Asynchronous Programming - Interactive Exercise Launcher
# This script provides guided, hands-on exercises for async/await patterns in ASP.NET Core

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration - Match exercise requirements exactly
INTERACTIVE_MODE=true
SKIP_PROJECT_CREATION=false

# Project names must match exercise requirements
get_project_name() {
    case $1 in
        "exercise01") echo "AsyncExercise01" ;;
        "exercise02") echo "AsyncApiExercise" ;;
        "exercise03") echo "BackgroundTasksExercise" ;;
        *) echo "AsyncDemo" ;;
    esac
}

# Function to display colored output
echo_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
echo_success() { echo -e "${GREEN}✅ $1${NC}"; }
echo_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
echo_error() { echo -e "${RED}❌ $1${NC}"; }

# Function to pause for user interaction
pause_for_user() {
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -n "Press Enter to continue..."
        read -r
        echo ""
    fi
}

# Function to explain concepts interactively
explain_concept() {
    local concept=$1
    local explanation=$2
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}⚡ ASYNC CONCEPT: $concept${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}$explanation${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    pause_for_user
}

# Function to show learning objectives
show_learning_objectives() {
    local exercise=$1
    
    echo -e "${BLUE}🎯 Async Learning Objectives for $exercise:${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${CYAN}Basic Async/Await Fundamentals:${NC}"
            echo "  ⚡ 1. Understand Task and Task<T> types"
            echo "  ⚡ 2. Master async/await keywords"
            echo "  ⚡ 3. Learn proper async method signatures"
            echo "  ⚡ 4. Handle async exceptions correctly"
            echo ""
            echo -e "${YELLOW}Async concepts:${NC}"
            echo "  • Task-based Asynchronous Pattern (TAP)"
            echo "  • Async method naming conventions"
            echo "  • ConfigureAwait best practices"
            echo "  • Async void vs async Task"
            ;;
        "exercise02")
            echo -e "${CYAN}Async API Development:${NC}"
            echo "  ⚡ 1. Create async controllers and actions"
            echo "  ⚡ 2. Implement async middleware"
            echo "  ⚡ 3. Handle async database operations"
            echo "  ⚡ 4. Manage async HTTP client calls"
            echo ""
            echo -e "${YELLOW}Async concepts:${NC}"
            echo "  • Async controller patterns"
            echo "  • Async middleware pipeline"
            echo "  • Entity Framework async methods"
            echo "  • HttpClient async operations"
            ;;
        "exercise03")
            echo -e "${CYAN}Background Tasks & Services:${NC}"
            echo "  ⚡ 1. Implement IHostedService"
            echo "  ⚡ 2. Create BackgroundService implementations"
            echo "  ⚡ 3. Handle long-running operations"
            echo "  ⚡ 4. Manage service lifecycle and cancellation"
            echo ""
            echo -e "${YELLOW}Async concepts:${NC}"
            echo "  • Background service patterns"
            echo "  • CancellationToken usage"
            echo "  • Service dependency injection"
            echo "  • Graceful shutdown handling"
            ;;
    esac
    echo ""
}

# Function to show what will be created
show_creation_overview() {
    local exercise=$1
    
    echo -e "${CYAN}📋 Async Components for $exercise:${NC}"
    
    case $exercise in
        "exercise01")
            echo "• Basic async service implementations"
            echo "• Task and Task<T> examples"
            echo "• Async exception handling patterns"
            echo "• ConfigureAwait demonstrations"
            echo "• Performance comparison examples"
            ;;
        "exercise02")
            echo "• Async API controllers"
            echo "• Async middleware components"
            echo "• Entity Framework async operations"
            echo "• HttpClient async patterns"
            echo "• Async testing examples"
            ;;
        "exercise03")
            echo "• Background service implementations"
            echo "• Hosted service examples"
            echo "• Long-running task patterns"
            echo "• Cancellation token handling"
            echo "• Service lifecycle management"
            ;;
    esac
    echo ""
}

# Function to create files interactively
create_file_interactive() {
    local file_path=$1
    local content=$2
    local description=$3
    
    if [ "$PREVIEW_ONLY" = true ]; then
        echo -e "${CYAN}📄 Would create: $file_path${NC}"
        echo -e "${YELLOW}   Description: $description${NC}"
        return
    fi
    
    echo -e "${CYAN}📄 Creating: $file_path${NC}"
    echo -e "${YELLOW}   $description${NC}"
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$file_path")"
    
    # Write content to file
    echo "$content" > "$file_path"
    
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -n "   File created. Press Enter to continue..."
        read -r
    fi
    echo ""
}

# Function to show available exercises
show_exercises() {
    echo -e "${CYAN}Module 11 - Asynchronous Programming${NC}"
    echo -e "${CYAN}Available Exercises:${NC}"
    echo ""
    echo "  - exercise01: Basic Async/Await Fundamentals"
    echo "  - exercise02: Async API Development"
    echo "  - exercise03: Background Tasks & Services"
    echo ""
    echo "Usage:"
    echo "  ./launch-exercises.sh <exercise-name> [options]"
    echo ""
    echo "Options:"
    echo "  --list          Show all available exercises"
    echo "  --auto          Skip interactive mode"
    echo "  --preview       Show what will be created without creating"
}

# Main script starts here
if [ $# -eq 0 ]; then
    echo_error "Usage: $0 <exercise-name> [options]"
    echo ""
    show_exercises
    exit 1
fi

# Handle --list option
if [ "$1" == "--list" ]; then
    show_exercises
    exit 0
fi

EXERCISE_NAME=$1
PREVIEW_ONLY=false

# Parse options
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            INTERACTIVE_MODE=false
            shift
            ;;
        --preview)
            PREVIEW_ONLY=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Validate exercise name
case $EXERCISE_NAME in
    "exercise01"|"exercise02"|"exercise03")
        ;;
    *)
        echo_error "Unknown exercise: $EXERCISE_NAME"
        echo ""
        show_exercises
        exit 1
        ;;
esac

# Welcome message
echo -e "${MAGENTA}⚡ Module 11: Asynchronous Programming${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show learning objectives
show_learning_objectives $EXERCISE_NAME

# Show what will be created
show_creation_overview $EXERCISE_NAME

if [ "$PREVIEW_ONLY" = true ]; then
    echo_info "Preview mode - no files will be created"
    echo ""
fi

# Check prerequisites
echo_info "Checking async programming prerequisites..."

# Check .NET SDK
if ! command -v dotnet &> /dev/null; then
    echo_error ".NET SDK is not installed. Please install .NET 8.0 SDK."
    exit 1
fi

echo_success "Prerequisites check completed"
echo ""

# Get the correct project name for this exercise
PROJECT_NAME=$(get_project_name $EXERCISE_NAME)

# Check if project exists in current directory
if [ -d "$PROJECT_NAME" ]; then
    echo_warning "Project '$PROJECT_NAME' already exists!"
    echo -n "Do you want to overwrite it? (y/N): "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
    rm -rf "$PROJECT_NAME"
    SKIP_PROJECT_CREATION=false
else
    SKIP_PROJECT_CREATION=false
fi

# Exercise implementations
if [[ $EXERCISE_NAME == "exercise01" ]]; then
    # Exercise 1: Basic Async/Await Fundamentals

    explain_concept "Async/Await Fundamentals" \
"Async/Await Programming Concepts:
• Task-based Asynchronous Pattern (TAP): Modern async programming model
• async/await Keywords: Simplify asynchronous programming
• Task and Task<T>: Represent asynchronous operations
• ConfigureAwait: Control synchronization context
• Exception Handling: Proper async exception management"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_info "Creating console application for Exercise 1..."
        echo_info "This matches the exercise requirements exactly!"
        dotnet new console -n "$PROJECT_NAME" --framework net8.0
        cd "$PROJECT_NAME"
    fi

    # Create ProcessedData model as required by Exercise 1
    create_file_interactive "Models/ProcessedData.cs" \
'namespace AsyncExercise01.Models;

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
}' \
"ProcessedData model class matching Exercise 1 requirements exactly"

    # Create Program.cs with the exact methods required by Exercise 1
    create_file_interactive "Program.cs" \
'using System.Diagnostics;
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
            var result = await AsyncMethods.DownloadWithRetryAsync("https://unreliable-api.example.com");
            Console.WriteLine($"Download successful: {result}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Download failed after all retries: {ex.Message}");
        }
    }
}' \
"Complete Program.cs with all required methods for Exercise 1"

    # Add the required async methods to Program.cs
    create_file_interactive "AsyncMethods.cs" \
'using System.Diagnostics;
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

        // Simulate processing time (500ms)
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

        // Simulate file I/O (300ms)
        await Task.Delay(300);

        // Log completion
        Console.WriteLine($"Data saved to {fileName}");
    }

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
    /// Helper method to extract URL from data string
    /// </summary>
    public static string ExtractUrlFromData(string data)
    {
        if (data.Contains("api1.example.com")) return "https://api1.example.com";
        if (data.Contains("api2.example.com")) return "https://api2.example.com";
        if (data.Contains("api3.example.com")) return "https://api3.example.com";
        return "unknown";
    }
}' \
"Async methods required by Exercise 1 - DownloadDataAsync, ProcessDataAsync, SaveDataAsync, DownloadWithRetryAsync"

    # Add sequential and concurrent processing methods
    create_file_interactive "ProcessingMethods.cs" \
'using System.Diagnostics;
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
}' \
"Sequential and concurrent processing methods matching Exercise 1 requirements"

elif [[ $EXERCISE_NAME == "exercise02" ]]; then
    # Exercise 2: Async API Development

    explain_concept "Async Web API Development" \
"🚨 THE PROBLEM: Building Async Web APIs
You need to build a complete async Web API that demonstrates real-world patterns:

EXERCISE 2 REQUIREMENTS:
• Order management system with async CRUD operations
• Entity Framework Core with async database operations
• External API calls with proper async patterns
• Background processing integration
• Bulk operations and streaming responses
• Comprehensive error handling and cancellation

YOUR MISSION:
• Create AsyncApiExercise Web API project
• Implement Order/OrderItem models with EF Core
• Build async controllers with proper patterns
• Add external service integrations
• Implement background task queuing"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_info "Creating ASP.NET Core Web API project for Exercise 2..."
        echo_info "This matches Exercise 2 requirements exactly!"
        dotnet new webapi -n "$PROJECT_NAME" --framework net8.0
        cd "$PROJECT_NAME"
    fi

    # Add required packages for Exercise 2
    dotnet add package Microsoft.EntityFrameworkCore.InMemory
    dotnet add package Microsoft.EntityFrameworkCore.Tools
    dotnet add package Swashbuckle.AspNetCore
    dotnet add package System.Text.Json

    # Create Order model as required by Exercise 2
    create_file_interactive "Models/Order.cs" \
'namespace AsyncApiExercise.Models;

public class Order
{
    public int Id { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public List<OrderItem> Items { get; set; } = new();
    public decimal TotalAmount { get; set; }
    public OrderStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ProcessedAt { get; set; }
}

public class OrderItem
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal TotalPrice => Quantity * UnitPrice;
}

public enum OrderStatus
{
    Pending,
    Processing,
    Completed,
    Cancelled
}

public class ExternalApiResponse
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public object? Data { get; set; }
}' \
"Order models matching Exercise 2 requirements exactly"

    # Create OrderContext as required by Exercise 2
    create_file_interactive "Data/OrderContext.cs" \
'using Microsoft.EntityFrameworkCore;
using AsyncApiExercise.Models;

namespace AsyncApiExercise.Data;

public class OrderContext : DbContext
{
    public OrderContext(DbContextOptions<OrderContext> options) : base(options) { }

    public DbSet<Order> Orders { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Configure Order entity
        modelBuilder.Entity<Order>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.CustomerName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.TotalAmount).HasColumnType("decimal(18,2)");
            entity.HasMany(e => e.Items).WithOne().HasForeignKey(e => e.OrderId);
        });

        // Configure OrderItem entity
        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.ProductName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.UnitPrice).HasColumnType("decimal(18,2)");
        });
    }
}' \
"OrderContext with proper EF Core configuration matching Exercise 2 requirements"

    # Create async controller
    create_file_interactive "Controllers/OrdersController.cs" \
'using Microsoft.AspNetCore.Mvc;
using AsyncDemo.Services;
using AsyncDemo.Models;
using AsyncDemo.Data;
using Microsoft.EntityFrameworkCore;

namespace AsyncDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AsyncApiController : ControllerBase
{
    private readonly IAsyncBasicsService _asyncService;
    private readonly IAsyncDataService _dataService;
    private readonly ILogger<AsyncApiController> _logger;

    public AsyncApiController(
        IAsyncBasicsService asyncService,
        IAsyncDataService dataService,
        ILogger<AsyncApiController> logger)
    {
        _asyncService = asyncService;
        _dataService = dataService;
        _logger = logger;
    }

    /// <summary>
    /// Basic async endpoint
    /// </summary>
    [HttpGet("basic")]
    public async Task<ActionResult<string>> GetBasicDataAsync()
    {
        try
        {
            var result = await _asyncService.GetDataAsync();
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetBasicDataAsync");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Async endpoint with multiple concurrent operations
    /// </summary>
    [HttpGet("multiple")]
    public async Task<ActionResult<List<string>>> GetMultipleDataAsync()
    {
        try
        {
            var results = await _asyncService.GetMultipleDataAsync();
            return Ok(results);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetMultipleDataAsync");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Async endpoint with timeout
    /// </summary>
    [HttpGet("timeout/{timeoutMs}")]
    public async Task<ActionResult<string>> GetDataWithTimeoutAsync(int timeoutMs)
    {
        try
        {
            var result = await _asyncService.GetDataWithTimeoutAsync(timeoutMs);
            return Ok(result);
        }
        catch (TimeoutException ex)
        {
            _logger.LogWarning(ex, "Timeout in GetDataWithTimeoutAsync");
            return StatusCode(408, "Request timeout");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetDataWithTimeoutAsync");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Async database operations
    /// </summary>
    [HttpGet("users")]
    public async Task<ActionResult<List<User>>> GetUsersAsync()
    {
        try
        {
            var users = await _dataService.GetAllUsersAsync();
            return Ok(users);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetUsersAsync");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Async POST endpoint
    /// </summary>
    [HttpPost("users")]
    public async Task<ActionResult<User>> CreateUserAsync([FromBody] CreateUserRequest request)
    {
        try
        {
            var user = await _dataService.CreateUserAsync(request.Name, request.Email);
            return CreatedAtAction(nameof(GetUserAsync), new { id = user.Id }, user);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in CreateUserAsync");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Async GET by ID endpoint
    /// </summary>
    [HttpGet("users/{id}")]
    public async Task<ActionResult<User>> GetUserAsync(int id)
    {
        try
        {
            var user = await _dataService.GetUserByIdAsync(id);
            if (user == null)
            {
                return NotFound();
            }
            return Ok(user);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetUserAsync");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Async external API call
    /// </summary>
    [HttpGet("external/{userId}")]
    public async Task<ActionResult<object>> GetExternalDataAsync(int userId)
    {
        try
        {
            var externalData = await _dataService.GetExternalUserDataAsync(userId);
            return Ok(externalData);
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "External API error in GetExternalDataAsync");
            return StatusCode(502, "External service unavailable");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetExternalDataAsync");
            return StatusCode(500, "Internal server error");
        }
    }
}

public record CreateUserRequest(string Name, string Email);' \
"Comprehensive async API controller with various async patterns"

elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    # Exercise 3: Background Tasks & Services

    explain_concept "Background Tasks & Services" \
"Background Services in ASP.NET Core:
• IHostedService: Interface for background services
• BackgroundService: Base class for long-running services
• CancellationToken: Graceful shutdown handling
• Service Scopes: Managing dependency injection in background services
• Service Lifecycle: Startup, execution, and shutdown patterns"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 3 requires Exercises 1 and 2 to be completed first!"
        echo_info "Please run exercises in order: exercise01, exercise02, exercise03"
        exit 1
    fi

    # Create background service
    create_file_interactive "Services/DataProcessingBackgroundService.cs" \
'using Microsoft.Extensions.DependencyInjection;
using AsyncDemo.Data;

namespace AsyncDemo.Services;

/// <summary>
/// Background service for processing data periodically
/// </summary>
public class DataProcessingBackgroundService : BackgroundService
{
    private readonly ILogger<DataProcessingBackgroundService> _logger;
    private readonly IServiceProvider _serviceProvider;
    private readonly TimeSpan _period = TimeSpan.FromSeconds(30);

    public DataProcessingBackgroundService(
        ILogger<DataProcessingBackgroundService> logger,
        IServiceProvider serviceProvider)
    {
        _logger = logger;
        _serviceProvider = serviceProvider;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Data Processing Background Service started");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessDataAsync(stoppingToken);
                await Task.Delay(_period, stoppingToken);
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Data Processing Background Service is stopping");
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in Data Processing Background Service");
                // Continue processing after error
                await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
            }
        }
    }

    private async Task ProcessDataAsync(CancellationToken cancellationToken)
    {
        using var scope = _serviceProvider.CreateScope();
        var dataService = scope.ServiceProvider.GetRequiredService<IAsyncDataService>();

        _logger.LogInformation("Starting data processing cycle");

        // Simulate data processing
        var users = await dataService.GetAllUsersAsync();
        _logger.LogInformation("Processing {UserCount} users", users.Count);

        foreach (var user in users)
        {
            if (cancellationToken.IsCancellationRequested)
                break;

            // Simulate processing each user
            await Task.Delay(100, cancellationToken);
            _logger.LogDebug("Processed user: {UserId}", user.Id);
        }

        _logger.LogInformation("Data processing cycle completed");
    }

    public override async Task StopAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Data Processing Background Service is stopping");
        await base.StopAsync(cancellationToken);
    }
}' \
"Background service for periodic data processing with proper cancellation handling"

fi

# Final completion message
echo ""
echo_success "🎉 $EXERCISE_NAME template created successfully!"
echo ""
echo_info "📋 Next steps:"

case $EXERCISE_NAME in
    "exercise01")
        echo "1. Register async service in Program.cs"
        echo "2. Run: ${CYAN}dotnet run${NC}"
        echo "3. Test async endpoints with Swagger"
        echo "4. Monitor async performance and behavior"
        ;;
    "exercise02")
        echo "1. Configure Entity Framework and HttpClient"
        echo "2. Test async API endpoints"
        echo "3. Monitor database async operations"
        echo "4. Test external API integration"
        ;;
    "exercise03")
        echo "1. Register background service in Program.cs"
        echo "2. Test service startup and shutdown"
        echo "3. Monitor background processing logs"
        echo "4. Test graceful cancellation"
        ;;
esac

echo ""
echo_info "📚 For detailed instructions, refer to the exercise guide files created."
echo_info "🔗 Additional async resources available in the Resources/ directory."
