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

# Configuration
PROJECT_NAME="AsyncDemo"
INTERACTIVE_MODE=true
SKIP_PROJECT_CREATION=false

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

# Check if project exists in current directory
if [ -d "$PROJECT_NAME" ]; then
    if [[ $EXERCISE_NAME == "exercise02" ]] || [[ $EXERCISE_NAME == "exercise03" ]]; then
        echo_success "Found existing $PROJECT_NAME from previous exercise"
        echo_info "This exercise will build on your existing work"
        cd "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=true
    else
        echo_warning "Project '$PROJECT_NAME' already exists!"
        echo -n "Do you want to overwrite it? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            exit 1
        fi
        rm -rf "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=false
    fi
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
        echo_info "Creating new ASP.NET Core Web API project..."
        dotnet new webapi -n "$PROJECT_NAME" --framework net8.0
        cd "$PROJECT_NAME"
    fi

    # Create basic async service
    create_file_interactive "Services/AsyncBasicsService.cs" \
'using System.Diagnostics;

namespace AsyncDemo.Services;

public interface IAsyncBasicsService
{
    Task<string> GetDataAsync();
    Task<List<string>> GetMultipleDataAsync();
    Task<string> GetDataWithDelayAsync(int delayMs);
    Task<string> GetDataWithTimeoutAsync(int timeoutMs);
    Task<T> GetGenericDataAsync<T>(T data);
    ValueTask<int> GetCachedValueAsync(string key);
}

public class AsyncBasicsService : IAsyncBasicsService
{
    private readonly ILogger<AsyncBasicsService> _logger;
    private readonly HttpClient _httpClient;
    private readonly Dictionary<string, int> _cache = new();

    public AsyncBasicsService(ILogger<AsyncBasicsService> logger, HttpClient httpClient)
    {
        _logger = logger;
        _httpClient = httpClient;
    }

    /// <summary>
    /// Basic async method returning Task<string>
    /// </summary>
    public async Task<string> GetDataAsync()
    {
        _logger.LogInformation("Starting async data retrieval");

        // Simulate async work
        await Task.Delay(100);

        var result = $"Data retrieved at {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC";
        _logger.LogInformation("Async data retrieval completed");

        return result;
    }

    /// <summary>
    /// Async method with multiple concurrent operations
    /// </summary>
    public async Task<List<string>> GetMultipleDataAsync()
    {
        _logger.LogInformation("Starting multiple async operations");

        var tasks = new List<Task<string>>();

        // Create multiple async tasks
        for (int i = 0; i < 5; i++)
        {
            int index = i; // Capture loop variable
            tasks.Add(GetDataWithDelayAsync(100 + (index * 50)));
        }

        // Wait for all tasks to complete
        var results = await Task.WhenAll(tasks);

        _logger.LogInformation("All async operations completed");
        return results.ToList();
    }

    /// <summary>
    /// Async method with configurable delay
    /// </summary>
    public async Task<string> GetDataWithDelayAsync(int delayMs)
    {
        _logger.LogInformation("Starting async operation with {Delay}ms delay", delayMs);

        var stopwatch = Stopwatch.StartNew();

        // Use ConfigureAwait(false) for library code
        await Task.Delay(delayMs).ConfigureAwait(false);

        stopwatch.Stop();

        var result = $"Operation completed in {stopwatch.ElapsedMilliseconds}ms";
        _logger.LogInformation("Async operation with delay completed");

        return result;
    }

    /// <summary>
    /// Async method with timeout handling
    /// </summary>
    public async Task<string> GetDataWithTimeoutAsync(int timeoutMs)
    {
        _logger.LogInformation("Starting async operation with {Timeout}ms timeout", timeoutMs);

        using var cts = new CancellationTokenSource(TimeSpan.FromMilliseconds(timeoutMs));

        try
        {
            // Simulate work that might take longer than timeout
            await Task.Delay(timeoutMs + 100, cts.Token).ConfigureAwait(false);
            return "Operation completed successfully";
        }
        catch (OperationCanceledException)
        {
            _logger.LogWarning("Operation timed out after {Timeout}ms", timeoutMs);
            throw new TimeoutException($"Operation timed out after {timeoutMs}ms");
        }
    }

    /// <summary>
    /// Generic async method
    /// </summary>
    public async Task<T> GetGenericDataAsync<T>(T data)
    {
        _logger.LogInformation("Processing generic data of type {Type}", typeof(T).Name);

        // Simulate async processing
        await Task.Delay(50).ConfigureAwait(false);

        return data;
    }

    /// <summary>
    /// ValueTask example for performance optimization
    /// </summary>
    public ValueTask<int> GetCachedValueAsync(string key)
    {
        // If value is cached, return synchronously
        if (_cache.TryGetValue(key, out var cachedValue))
        {
            _logger.LogDebug("Cache hit for key: {Key}", key);
            return ValueTask.FromResult(cachedValue);
        }

        // Cache miss: compute asynchronously
        return ComputeAndCacheAsync(key);
    }

    private async ValueTask<int> ComputeAndCacheAsync(string key)
    {
        _logger.LogInformation("Cache miss - computing value for key: {Key}", key);

        // Simulate expensive computation
        await Task.Delay(200).ConfigureAwait(false);

        var value = key.GetHashCode() & 0x7FFFFFFF; // Simple hash-based value
        _cache[key] = value;

        return value;
    }
}' \
"Comprehensive async service demonstrating fundamental async/await patterns"

elif [[ $EXERCISE_NAME == "exercise02" ]]; then
    # Exercise 2: Async API Development

    explain_concept "Async API Development" \
"Async API Development Patterns:
• Async Controllers: Non-blocking request handling
• Async Middleware: Pipeline components with async operations
• Entity Framework Async: Database operations without blocking
• HttpClient Async: External API calls with proper async patterns
• Async Testing: Unit testing async methods effectively"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 2 requires Exercise 1 to be completed first!"
        echo_info "Please run: ./launch-exercises.sh exercise01"
        exit 1
    fi

    # Add Entity Framework packages
    dotnet add package Microsoft.EntityFrameworkCore.InMemory
    dotnet add package Microsoft.EntityFrameworkCore.Tools

    # Create async controller
    create_file_interactive "Controllers/AsyncApiController.cs" \
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
