#!/bin/bash

# Module 12: Dependency Injection & Middleware - Interactive Exercise Launcher
# This script provides guided, hands-on exercises for DI patterns and middleware development

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
PROJECT_NAME="DIMiddlewareDemo"
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
    echo -e "${MAGENTA}🔧 DI/MIDDLEWARE CONCEPT: $concept${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}$explanation${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    pause_for_user
}

# Function to show learning objectives
show_learning_objectives() {
    local exercise=$1
    
    echo -e "${BLUE}🎯 DI/Middleware Learning Objectives for $exercise:${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${CYAN}Service Lifetime Exploration:${NC}"
            echo "  🔧 1. Understand Singleton, Scoped, and Transient lifetimes"
            echo "  🔧 2. Track service instance creation and disposal"
            echo "  🔧 3. Demonstrate lifetime behavior in different contexts"
            echo "  🔧 4. Implement proper resource management"
            echo ""
            echo -e "${YELLOW}DI concepts:${NC}"
            echo "  • Service registration patterns"
            echo "  • Lifetime scope management"
            echo "  • IDisposable implementation"
            echo "  • Thread safety considerations"
            ;;
        "exercise02")
            echo -e "${CYAN}Custom Middleware Development:${NC}"
            echo "  🔧 1. Create request/response logging middleware"
            echo "  🔧 2. Implement rate limiting middleware"
            echo "  🔧 3. Build correlation ID middleware"
            echo "  🔧 4. Create error handling middleware"
            echo ""
            echo -e "${YELLOW}Middleware concepts:${NC}"
            echo "  • Pipeline execution order"
            echo "  • Middleware composition"
            echo "  • Cross-cutting concerns"
            echo "  • Conditional middleware execution"
            ;;
        "exercise03")
            echo -e "${CYAN}Advanced DI Patterns:${NC}"
            echo "  🔧 1. Factory pattern implementation"
            echo "  🔧 2. Decorator pattern for service enhancement"
            echo "  🔧 3. Multiple service implementations"
            echo "  🔧 4. Configuration-based service selection"
            echo ""
            echo -e "${YELLOW}Advanced DI concepts:${NC}"
            echo "  • Generic service registration"
            echo "  • Service location anti-pattern"
            echo "  • Circular dependency resolution"
            echo "  • Service validation"
            ;;
        "exercise04")
            echo -e "${CYAN}Production Integration:${NC}"
            echo "  🔧 1. Complete layered architecture with DI"
            echo "  🔧 2. Comprehensive middleware pipeline"
            echo "  🔧 3. Health checks and monitoring"
            echo "  🔧 4. Environment-specific configuration"
            echo ""
            echo -e "${YELLOW}Production concepts:${NC}"
            echo "  • Performance optimization"
            echo "  • Error handling strategies"
            echo "  • Monitoring and diagnostics"
            echo "  • Configuration management"
            ;;
    esac
    echo ""
}

# Function to show what will be created
show_creation_overview() {
    local exercise=$1
    
    echo -e "${CYAN}📋 DI/Middleware Components for $exercise:${NC}"
    
    case $exercise in
        "exercise01")
            echo "• Service lifetime demonstration classes"
            echo "• Lifetime tracking and logging"
            echo "• Resource disposal examples"
            echo "• Thread safety demonstrations"
            echo "• Performance comparison tools"
            ;;
        "exercise02")
            echo "• Custom middleware implementations"
            echo "• Request/response logging middleware"
            echo "• Rate limiting middleware"
            echo "• Correlation ID middleware"
            echo "• Error handling middleware"
            ;;
        "exercise03")
            echo "• Factory pattern implementations"
            echo "• Decorator pattern examples"
            echo "• Multiple service implementations"
            echo "• Generic service registration"
            echo "• Configuration-driven services"
            ;;
        "exercise04")
            echo "• Complete application architecture"
            echo "• Layered service design"
            echo "• Production middleware pipeline"
            echo "• Health check implementations"
            echo "• Environment configuration"
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
    echo -e "${CYAN}Module 12 - Dependency Injection & Middleware${NC}"
    echo -e "${CYAN}Available Exercises:${NC}"
    echo ""
    echo "  - exercise01: Service Lifetime Exploration"
    echo "  - exercise02: Custom Middleware Development"
    echo "  - exercise03: Advanced DI Patterns"
    echo "  - exercise04: Production Integration"
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
    "exercise01"|"exercise02"|"exercise03"|"exercise04")
        ;;
    *)
        echo_error "Unknown exercise: $EXERCISE_NAME"
        echo ""
        show_exercises
        exit 1
        ;;
esac

# Welcome message
echo -e "${MAGENTA}🔧 Module 12: Dependency Injection & Middleware${NC}"
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
echo_info "Checking DI/Middleware prerequisites..."

# Check .NET SDK
if ! command -v dotnet &> /dev/null; then
    echo_error ".NET SDK is not installed. Please install .NET 8.0 SDK."
    exit 1
fi

echo_success "Prerequisites check completed"
echo ""

# Check if project exists in current directory
if [ -d "$PROJECT_NAME" ]; then
    if [[ $EXERCISE_NAME == "exercise02" ]] || [[ $EXERCISE_NAME == "exercise03" ]] || [[ $EXERCISE_NAME == "exercise04" ]]; then
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
    # Exercise 1: Service Lifetime Exploration

    explain_concept "Service Lifetimes in DI" \
"Dependency Injection Service Lifetimes:
• Singleton: Single instance for the entire application lifetime
• Scoped: One instance per request/scope (default for web requests)
• Transient: New instance every time the service is requested
• Service Disposal: Proper resource cleanup with IDisposable
• Thread Safety: Considerations for shared instances"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_info "Creating new ASP.NET Core Web API project..."
        dotnet new webapi -n "$PROJECT_NAME" --framework net8.0
        cd "$PROJECT_NAME"
    fi

    # Create lifetime demonstration services
    create_file_interactive "Services/LifetimeServices.cs" \
'using System.Collections.Concurrent;

namespace DIMiddlewareDemo.Services;

/// <summary>
/// Interface for lifetime demonstration
/// </summary>
public interface ILifetimeService
{
    string ServiceId { get; }
    DateTime CreatedAt { get; }
    string GetServiceInfo();
}

/// <summary>
/// Singleton service - single instance for application lifetime
/// </summary>
public class SingletonService : ILifetimeService, IDisposable
{
    private static readonly ConcurrentDictionary<string, int> _instanceCounter = new();
    private readonly ILogger<SingletonService> _logger;
    private bool _disposed = false;

    public string ServiceId { get; }
    public DateTime CreatedAt { get; }

    public SingletonService(ILogger<SingletonService> logger)
    {
        ServiceId = Guid.NewGuid().ToString("N")[..8];
        CreatedAt = DateTime.UtcNow;
        _logger = logger;

        _instanceCounter.AddOrUpdate("Singleton", 1, (key, value) => value + 1);
        _logger.LogInformation("Singleton service created: {ServiceId} at {CreatedAt}", ServiceId, CreatedAt);
    }

    public string GetServiceInfo()
    {
        return $"Singleton Service - ID: {ServiceId}, Created: {CreatedAt:HH:mm:ss.fff}, Total Instances: {_instanceCounter["Singleton"]}";
    }

    public void Dispose()
    {
        if (!_disposed)
        {
            _logger.LogInformation("Singleton service disposed: {ServiceId}", ServiceId);
            _disposed = true;
        }
    }
}

/// <summary>
/// Scoped service - one instance per request/scope
/// </summary>
public class ScopedService : ILifetimeService, IDisposable
{
    private static readonly ConcurrentDictionary<string, int> _instanceCounter = new();
    private readonly ILogger<ScopedService> _logger;
    private bool _disposed = false;

    public string ServiceId { get; }
    public DateTime CreatedAt { get; }

    public ScopedService(ILogger<ScopedService> logger)
    {
        ServiceId = Guid.NewGuid().ToString("N")[..8];
        CreatedAt = DateTime.UtcNow;
        _logger = logger;

        _instanceCounter.AddOrUpdate("Scoped", 1, (key, value) => value + 1);
        _logger.LogInformation("Scoped service created: {ServiceId} at {CreatedAt}", ServiceId, CreatedAt);
    }

    public string GetServiceInfo()
    {
        return $"Scoped Service - ID: {ServiceId}, Created: {CreatedAt:HH:mm:ss.fff}, Total Instances: {_instanceCounter["Scoped"]}";
    }

    public void Dispose()
    {
        if (!_disposed)
        {
            _logger.LogInformation("Scoped service disposed: {ServiceId}", ServiceId);
            _disposed = true;
        }
    }
}

/// <summary>
/// Transient service - new instance every time
/// </summary>
public class TransientService : ILifetimeService, IDisposable
{
    private static readonly ConcurrentDictionary<string, int> _instanceCounter = new();
    private readonly ILogger<TransientService> _logger;
    private bool _disposed = false;

    public string ServiceId { get; }
    public DateTime CreatedAt { get; }

    public TransientService(ILogger<TransientService> logger)
    {
        ServiceId = Guid.NewGuid().ToString("N")[..8];
        CreatedAt = DateTime.UtcNow;
        _logger = logger;

        _instanceCounter.AddOrUpdate("Transient", 1, (key, value) => value + 1);
        _logger.LogInformation("Transient service created: {ServiceId} at {CreatedAt}", ServiceId, CreatedAt);
    }

    public string GetServiceInfo()
    {
        return $"Transient Service - ID: {ServiceId}, Created: {CreatedAt:HH:mm:ss.fff}, Total Instances: {_instanceCounter["Transient"]}";
    }

    public void Dispose()
    {
        if (!_disposed)
        {
            _logger.LogInformation("Transient service disposed: {ServiceId}", ServiceId);
            _disposed = true;
        }
    }
}

/// <summary>
/// Service that demonstrates dependency injection of different lifetimes
/// </summary>
public interface ILifetimeDemoService
{
    LifetimeInfo GetLifetimeInfo();
}

public class LifetimeDemoService : ILifetimeDemoService
{
    private readonly SingletonService _singletonService;
    private readonly ScopedService _scopedService;
    private readonly TransientService _transientService1;
    private readonly TransientService _transientService2;
    private readonly ILogger<LifetimeDemoService> _logger;

    public LifetimeDemoService(
        SingletonService singletonService,
        ScopedService scopedService,
        TransientService transientService1,
        TransientService transientService2,
        ILogger<LifetimeDemoService> logger)
    {
        _singletonService = singletonService;
        _scopedService = scopedService;
        _transientService1 = transientService1;
        _transientService2 = transientService2;
        _logger = logger;

        _logger.LogInformation("LifetimeDemoService created with injected services");
    }

    public LifetimeInfo GetLifetimeInfo()
    {
        return new LifetimeInfo
        {
            Singleton = _singletonService.GetServiceInfo(),
            Scoped = _scopedService.GetServiceInfo(),
            Transient1 = _transientService1.GetServiceInfo(),
            Transient2 = _transientService2.GetServiceInfo(),
            RequestTime = DateTime.UtcNow
        };
    }
}

public class LifetimeInfo
{
    public string Singleton { get; set; } = string.Empty;
    public string Scoped { get; set; } = string.Empty;
    public string Transient1 { get; set; } = string.Empty;
    public string Transient2 { get; set; } = string.Empty;
    public DateTime RequestTime { get; set; }
}' \
"Comprehensive service lifetime demonstration with proper disposal patterns"

elif [[ $EXERCISE_NAME == "exercise02" ]]; then
    # Exercise 2: Custom Middleware Development

    explain_concept "Custom Middleware Development" \
"Middleware Pipeline Concepts:
• Request Pipeline: Sequential processing of HTTP requests
• Middleware Order: Critical importance of middleware sequence
• Cross-cutting Concerns: Logging, authentication, error handling
• Conditional Middleware: Environment-specific middleware
• Middleware Composition: Building complex pipelines"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 2 requires Exercise 1 to be completed first!"
        echo_info "Please run: ./launch-exercises.sh exercise01"
        exit 1
    fi

    # Create custom middleware
    create_file_interactive "Middleware/RequestLoggingMiddleware.cs" \
'using System.Diagnostics;
using System.Text;

namespace DIMiddlewareDemo.Middleware;

/// <summary>
/// Middleware for comprehensive request/response logging
/// </summary>
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
        var stopwatch = Stopwatch.StartNew();
        var requestId = Guid.NewGuid().ToString("N")[..8];

        // Log request
        await LogRequestAsync(context, requestId);

        // Capture response
        var originalBodyStream = context.Response.Body;
        using var responseBody = new MemoryStream();
        context.Response.Body = responseBody;

        try
        {
            await _next(context);
        }
        finally
        {
            stopwatch.Stop();

            // Log response
            await LogResponseAsync(context, requestId, stopwatch.ElapsedMilliseconds, responseBody);

            // Copy response back to original stream
            responseBody.Seek(0, SeekOrigin.Begin);
            await responseBody.CopyToAsync(originalBodyStream);
        }
    }

    private async Task LogRequestAsync(HttpContext context, string requestId)
    {
        var request = context.Request;
        var requestBody = string.Empty;

        if (request.ContentLength > 0 && request.ContentType?.Contains("application/json") == true)
        {
            request.EnableBuffering();
            using var reader = new StreamReader(request.Body, Encoding.UTF8, leaveOpen: true);
            requestBody = await reader.ReadToEndAsync();
            request.Body.Position = 0;
        }

        _logger.LogInformation(
            "Request {RequestId}: {Method} {Path} {QueryString} - Content-Type: {ContentType}, Content-Length: {ContentLength}",
            requestId,
            request.Method,
            request.Path,
            request.QueryString,
            request.ContentType ?? "N/A",
            request.ContentLength ?? 0);

        if (!string.IsNullOrEmpty(requestBody))
        {
            _logger.LogDebug("Request {RequestId} Body: {RequestBody}", requestId, requestBody);
        }
    }

    private async Task LogResponseAsync(HttpContext context, string requestId, long elapsedMs, MemoryStream responseBody)
    {
        var response = context.Response;
        var responseBodyText = string.Empty;

        if (responseBody.Length > 0 && response.ContentType?.Contains("application/json") == true)
        {
            responseBody.Seek(0, SeekOrigin.Begin);
            using var reader = new StreamReader(responseBody, Encoding.UTF8, leaveOpen: true);
            responseBodyText = await reader.ReadToEndAsync();
        }

        _logger.LogInformation(
            "Response {RequestId}: {StatusCode} - Content-Type: {ContentType}, Content-Length: {ContentLength}, Duration: {Duration}ms",
            requestId,
            response.StatusCode,
            response.ContentType ?? "N/A",
            responseBody.Length,
            elapsedMs);

        if (!string.IsNullOrEmpty(responseBodyText))
        {
            _logger.LogDebug("Response {RequestId} Body: {ResponseBody}", requestId, responseBodyText);
        }
    }
}

/// <summary>
/// Extension method for adding request logging middleware
/// </summary>
public static class RequestLoggingMiddlewareExtensions
{
    public static IApplicationBuilder UseRequestLogging(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<RequestLoggingMiddleware>();
    }
}' \
"Comprehensive request/response logging middleware with performance tracking"

fi

# Final completion message
echo ""
echo_success "🎉 $EXERCISE_NAME template created successfully!"
echo ""
echo_info "📋 Next steps:"

case $EXERCISE_NAME in
    "exercise01")
        echo "1. Register services with different lifetimes in Program.cs"
        echo "2. Run: ${CYAN}dotnet run${NC}"
        echo "3. Test lifetime behavior with multiple requests"
        echo "4. Monitor service creation and disposal logs"
        ;;
    "exercise02")
        echo "1. Add middleware to the pipeline in Program.cs"
        echo "2. Test middleware with various requests"
        echo "3. Monitor request/response logging"
        echo "4. Verify middleware execution order"
        ;;
    "exercise03")
        echo "1. Implement factory and decorator patterns"
        echo "2. Test multiple service implementations"
        echo "3. Verify configuration-based service selection"
        echo "4. Test generic service registration"
        ;;
    "exercise04")
        echo "1. Configure complete production pipeline"
        echo "2. Test health checks and monitoring"
        echo "3. Verify environment-specific configuration"
        echo "4. Performance test the complete application"
        ;;
esac

echo ""
echo_info "📚 For detailed instructions, refer to the exercise guide files created."
echo_info "🔗 Additional DI/Middleware resources available in the Resources/ directory."
