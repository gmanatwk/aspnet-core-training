#!/bin/bash

# Module 6 Interactive Exercise Launcher
# Debugging and Troubleshooting

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Interactive mode flag
INTERACTIVE_MODE=true

# Function to pause and wait for user
pause_for_user() {
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -e "${YELLOW}Press Enter to continue...${NC}"
        read -r
    fi
}

# Function to show what will be created
preview_file() {
    local file_path=$1
    local description=$2
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📄 Will create: $file_path${NC}"
    echo -e "${YELLOW}📝 Purpose: $description${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to create file with preview
create_file_interactive() {
    local file_path=$1
    local content=$2
    local description=$3
    
    preview_file "$file_path" "$description"
    
    # Show first 20 lines of content
    echo -e "${GREEN}Content preview:${NC}"
    echo "$content" | head -20
    if [ $(echo "$content" | wc -l) -gt 20 ]; then
        echo -e "${YELLOW}... (content truncated for preview)${NC}"
    fi
    echo ""
    
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -e "${YELLOW}Create this file? (Y/n/s to skip all):${NC} \c"
        read -r response
        
        case $response in
            [nN])
                echo -e "${RED}⏭️  Skipped: $file_path${NC}"
                return
                ;;
            [sS])
                INTERACTIVE_MODE=false
                echo -e "${CYAN}📌 Switching to automatic mode...${NC}"
                ;;
        esac
    fi
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$file_path")"
    
    # Write content to file
    echo "$content" > "$file_path"
    echo -e "${GREEN}✅ Created: $file_path${NC}"
    echo ""
}

# Function to show learning objectives
show_learning_objectives() {
    local exercise=$1
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}🎯 Learning Objectives${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${CYAN}In this exercise, you will learn:${NC}"
            echo "  🐛 1. Setting up debugging environments in VS Code and Visual Studio"
            echo "  🐛 2. Using breakpoints, watch windows, and call stack analysis"
            echo "  🐛 3. Hot Reload and Edit and Continue features"
            echo "  🐛 4. Debugging ASP.NET Core applications effectively"
            echo ""
            echo -e "${YELLOW}Key debugging skills:${NC}"
            echo "  • Conditional and function breakpoints"
            echo "  • Variable inspection and modification"
            echo "  • Step-through debugging techniques"
            echo "  • Exception handling during debugging"
            ;;
        "exercise02")
            echo -e "${CYAN}Building on Exercise 1, you will add:${NC}"
            echo "  📊 1. Structured logging with Serilog"
            echo "  📊 2. Multiple logging providers (Console, File, Database)"
            echo "  📊 3. Log levels and filtering strategies"
            echo "  📊 4. Performance logging and monitoring"
            echo ""
            echo -e "${YELLOW}Logging concepts:${NC}"
            echo "  • Structured vs unstructured logging"
            echo "  • Log correlation and context"
            echo "  • Log aggregation and analysis"
            echo "  • Production logging best practices"
            ;;
        "exercise03")
            echo -e "${CYAN}Advanced debugging and monitoring:${NC}"
            echo "  🚨 1. Global exception handling middleware"
            echo "  🚨 2. Health checks for dependencies"
            echo "  🚨 3. Application performance monitoring"
            echo "  🚨 4. Custom diagnostic middleware"
            echo ""
            echo -e "${YELLOW}Production concepts:${NC}"
            echo "  • Exception handling strategies"
            echo "  • Health check patterns"
            echo "  • Performance metrics collection"
            echo "  • Monitoring and alerting"
            ;;
    esac
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to show what will be created overview
show_creation_overview() {
    local exercise=$1
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📋 Overview: What will be created${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${GREEN}🎯 Exercise 01: Debugging Fundamentals${NC}"
            echo ""
            echo -e "${YELLOW}📋 What you'll build:${NC}"
            echo "  ✅ Debugging-ready ASP.NET Core application"
            echo "  ✅ Sample controllers with intentional bugs to fix"
            echo "  ✅ Debug configuration and launch settings"
            echo "  ✅ Comprehensive debugging examples"
            echo ""
            echo -e "${BLUE}🚀 RECOMMENDED: Use the Complete Working Example${NC}"
            echo "  ${CYAN}cd SourceCode/DebuggingDemo && dotnet run${NC}"
            echo "  Then visit: ${CYAN}http://localhost:5000${NC} for the debugging interface"
            echo ""
            echo -e "${GREEN}📁 Template Structure:${NC}"
            echo "  DebuggingDemo/"
            echo "  ├── Controllers/"
            echo "  │   ├── TestController.cs       ${YELLOW}# Sample controller with bugs${NC}"
            echo "  │   └── DiagnosticsController.cs ${YELLOW}# Debugging utilities${NC}"
            echo "  ├── Models/"
            echo "  │   └── DiagnosticModels.cs     ${YELLOW}# Debug data models${NC}"
            echo "  ├── .vscode/"
            echo "  │   └── launch.json             ${YELLOW}# VS Code debug config${NC}"
            echo "  ├── Properties/"
            echo "  │   └── launchSettings.json     ${YELLOW}# Debug launch settings${NC}"
            echo "  └── Program.cs                  ${YELLOW}# App configuration${NC}"
            ;;
            
        "exercise02")
            echo -e "${GREEN}🎯 Exercise 02: Comprehensive Logging Implementation${NC}"
            echo ""
            echo -e "${YELLOW}📋 Building on Exercise 1:${NC}"
            echo "  ✅ Serilog integration with multiple sinks"
            echo "  ✅ Structured logging with correlation IDs"
            echo "  ✅ Performance logging middleware"
            echo "  ✅ Log filtering and configuration"
            echo ""
            echo -e "${GREEN}📁 New additions:${NC}"
            echo "  DebuggingDemo/"
            echo "  ├── Middleware/"
            echo "  │   ├── RequestLoggingMiddleware.cs ${YELLOW}# Request/response logging${NC}"
            echo "  │   └── PerformanceMiddleware.cs    ${YELLOW}# Performance tracking${NC}"
            echo "  ├── Extensions/"
            echo "  │   └── LoggingExtensions.cs        ${YELLOW}# Logging configuration${NC}"
            echo "  ├── appsettings.json                ${YELLOW}# Serilog configuration${NC}"
            echo "  └── Logs/ (created at runtime)      ${YELLOW}# Log files directory${NC}"
            ;;
            
        "exercise03")
            echo -e "${GREEN}🎯 Exercise 03: Exception Handling and Monitoring${NC}"
            echo ""
            echo -e "${YELLOW}📋 Production-ready features:${NC}"
            echo "  ✅ Global exception handling middleware"
            echo "  ✅ Health checks for dependencies"
            echo "  ✅ Custom error responses and monitoring"
            echo "  ✅ Application performance metrics"
            echo ""
            echo -e "${GREEN}📁 Production features:${NC}"
            echo "  DebuggingDemo/"
            echo "  ├── Middleware/"
            echo "  │   └── ExceptionHandlingMiddleware.cs ${YELLOW}# Global exception handler${NC}"
            echo "  ├── HealthChecks/"
            echo "  │   ├── DatabaseHealthCheck.cs         ${YELLOW}# Database connectivity${NC}"
            echo "  │   └── ExternalApiHealthCheck.cs      ${YELLOW}# External dependencies${NC}"
            echo "  ├── Models/"
            echo "  │   └── ErrorResponse.cs               ${YELLOW}# Standardized error format${NC}"
            echo "  └── Controllers/"
            echo "      └── HealthController.cs            ${YELLOW}# Health check endpoints${NC}"
            ;;
    esac
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to explain a concept
explain_concept() {
    local concept=$1
    local explanation=$2
    
    echo -e "${MAGENTA}💡 Concept: $concept${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "$explanation"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to show available exercises
show_exercises() {
    echo -e "${CYAN}Module 6 - Debugging and Troubleshooting${NC}"
    echo -e "${CYAN}Available Exercises:${NC}"
    echo ""
    echo "  - exercise01: Debugging Fundamentals"
    echo "  - exercise02: Comprehensive Logging Implementation"
    echo "  - exercise03: Exception Handling and Monitoring"
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
    echo -e "${RED}❌ Usage: $0 <exercise-name> [options]${NC}"
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
PROJECT_NAME="DebuggingDemo"
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
        echo -e "${RED}❌ Unknown exercise: $EXERCISE_NAME${NC}"
        echo ""
        show_exercises
        exit 1
        ;;
esac

# Welcome screen
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}🚀 Module 6: Debugging and Troubleshooting${NC}"
echo -e "${MAGENTA}Exercise: $EXERCISE_NAME${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show the recommended approach
echo -e "${GREEN}🎯 RECOMMENDED APPROACH:${NC}"
echo -e "${CYAN}For the best learning experience, use the complete working implementation:${NC}"
echo ""
echo -e "${YELLOW}1. Use the working source code:${NC}"
echo -e "   ${CYAN}cd SourceCode/DebuggingDemo${NC}"
echo -e "   ${CYAN}dotnet run${NC}"
echo -e "   ${CYAN}# Visit: http://localhost:5000 for the debugging interface${NC}"
echo ""
echo -e "${YELLOW}2. Or use Docker for complete setup:${NC}"
echo -e "   ${CYAN}cd SourceCode${NC}"
echo -e "   ${CYAN}docker-compose up --build${NC}"
echo -e "   ${CYAN}# Includes logging aggregation and monitoring${NC}"
echo ""
echo -e "${YELLOW}⚠️  The template created by this script is basic and may not match${NC}"
echo -e "${YELLOW}   all exercise requirements. The SourceCode version is complete!${NC}"
echo ""

if [ "$INTERACTIVE_MODE" = true ]; then
    echo -e "${YELLOW}🎮 Interactive Mode: ON${NC}"
    echo -e "${CYAN}You'll see what each file does before it's created${NC}"
else
    echo -e "${YELLOW}⚡ Automatic Mode: ON${NC}"
fi

echo ""
echo -n "Continue with template creation? (y/N): "
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}💡 Great choice! Use the SourceCode version for the best experience.${NC}"
    exit 0
fi

# Show learning objectives
show_learning_objectives $EXERCISE_NAME

# Show creation overview
show_creation_overview $EXERCISE_NAME

if [ "$PREVIEW_ONLY" = true ]; then
    echo -e "${YELLOW}Preview mode - no files will be created${NC}"
    exit 0
fi

# Check if project exists in current directory
if [ -d "$PROJECT_NAME" ]; then
    if [[ $EXERCISE_NAME == "exercise02" ]] || [[ $EXERCISE_NAME == "exercise03" ]]; then
        echo -e "${GREEN}✓ Found existing $PROJECT_NAME from previous exercise${NC}"
        echo -e "${CYAN}This exercise will build on your existing work${NC}"
        cd "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=true
    else
        echo -e "${YELLOW}⚠️  Project '$PROJECT_NAME' already exists!${NC}"
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

# Exercise-specific implementation
if [[ $EXERCISE_NAME == "exercise01" ]]; then
    # Exercise 1: Debugging Fundamentals

    explain_concept "Debugging in ASP.NET Core" \
"Effective debugging is crucial for development:
• Breakpoints: Pause execution to inspect state
• Watch windows: Monitor variable values in real-time
• Call stack: Understand the execution path
• Hot Reload: Make changes without restarting
• Exception handling: Catch and analyze errors"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${CYAN}Creating new Web API project for debugging...${NC}"
        dotnet new webapi -n "$PROJECT_NAME" --framework net8.0
        cd "$PROJECT_NAME"
        rm -f WeatherForecast.cs Controllers/WeatherForecastController.cs

        # Update Program.cs with debugging-friendly configuration
        create_file_interactive "Program.cs" \
'using Microsoft.AspNetCore.Diagnostics;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "Debugging Demo API", Version = "v1" });
});

// Add CORS for development
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Debugging Demo API v1");
        c.RoutePrefix = "swagger";
    });

    // Enable detailed error pages in development
    app.UseDeveloperExceptionPage();
}
else
{
    // Use generic error handling in production
    app.UseExceptionHandler("/Error");
}

app.UseCors("AllowAll");
app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

// Add a root redirect to swagger
app.MapGet("/", () => Results.Redirect("/swagger"));

app.Run();' \
"Program.cs with debugging-friendly configuration"
    fi

    explain_concept "Debugging Models and Test Data" \
"Creating models for debugging practice:
• Simple data structures to inspect during debugging
• Properties with different data types
• Methods that can be stepped through
• Intentional bugs to practice fixing"

    # Create debugging models
    create_file_interactive "Models/DiagnosticModels.cs" \
'namespace DebuggingDemo.Models;

/// <summary>
/// Sample model for debugging exercises
/// </summary>
public class User
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public bool IsActive { get; set; }

    // Method with potential bug for debugging practice
    public string GetDisplayName()
    {
        // TODO: Fix the bug in this method during debugging
        return $"{Name} ({Email})";
    }
}

/// <summary>
/// Sample order model for debugging complex scenarios
/// </summary>
public class Order
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public List<OrderItem> Items { get; set; } = new();
    public DateTime OrderDate { get; set; }
    public decimal Total { get; set; }

    // Method with calculation bug for debugging
    public decimal CalculateTotal()
    {
        // TODO: Debug this calculation method
        decimal total = 0;
        foreach (var item in Items)
        {
            total += item.Price * item.Quantity;
        }
        return total;
    }
}

/// <summary>
/// Order item model
/// </summary>
public class OrderItem
{
    public int Id { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int Quantity { get; set; }
}

/// <summary>
/// Diagnostic information model
/// </summary>
public class DiagnosticInfo
{
    public string MachineName { get; set; } = Environment.MachineName;
    public string OSVersion { get; set; } = Environment.OSVersion.ToString();
    public DateTime ServerTime { get; set; } = DateTime.UtcNow;
    public string ApplicationVersion { get; set; } = "1.0.0";
    public long WorkingSet { get; set; } = Environment.WorkingSet;
}' \
"Diagnostic models with intentional bugs for debugging practice"

    explain_concept "Debugging Controllers" \
"Controllers with debugging scenarios:
• Breakpoint placement strategies
• Variable inspection techniques
• Exception handling and debugging
• Step-through debugging practice"

    # Create test controller with debugging scenarios
    create_file_interactive "Controllers/TestController.cs" \
'using Microsoft.AspNetCore.Mvc;
using DebuggingDemo.Models;

namespace DebuggingDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TestController : ControllerBase
{
    private readonly ILogger<TestController> _logger;
    private static readonly List<User> _users = new();
    private static readonly List<Order> _orders = new();

    public TestController(ILogger<TestController> logger)
    {
        _logger = logger;
        InitializeTestData();
    }

    /// <summary>
    /// Get all users - Practice basic debugging
    /// </summary>
    [HttpGet("users")]
    public ActionResult<IEnumerable<User>> GetUsers()
    {
        _logger.LogInformation("Getting all users");

        // TODO: Set a breakpoint here and inspect the _users collection
        var activeUsers = _users.Where(u => u.IsActive).ToList();

        return Ok(activeUsers);
    }

    /// <summary>
    /// Get user by ID - Practice conditional debugging
    /// </summary>
    [HttpGet("users/{id}")]
    public ActionResult<User> GetUser(int id)
    {
        _logger.LogInformation("Getting user with ID: {UserId}", id);

        // TODO: Set a conditional breakpoint here (id == 2)
        var user = _users.FirstOrDefault(u => u.Id == id);

        if (user == null)
        {
            _logger.LogWarning("User not found: {UserId}", id);
            return NotFound($"User with ID {id} not found");
        }

        return Ok(user);
    }

    /// <summary>
    /// Create user - Practice exception debugging
    /// </summary>
    [HttpPost("users")]
    public ActionResult<User> CreateUser([FromBody] User user)
    {
        try
        {
            _logger.LogInformation("Creating user: {UserName}", user.Name);

            // TODO: This method has a potential null reference bug
            // Practice debugging exceptions
            if (string.IsNullOrEmpty(user.Name))
            {
                throw new ArgumentException("User name cannot be empty");
            }

            user.Id = _users.Count + 1;
            user.CreatedAt = DateTime.UtcNow;
            _users.Add(user);

            return CreatedAtAction(nameof(GetUser), new { id = user.Id }, user);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating user");
            return BadRequest($"Error creating user: {ex.Message}");
        }
    }

    /// <summary>
    /// Calculate order total - Practice debugging calculations
    /// </summary>
    [HttpPost("orders/calculate")]
    public ActionResult<decimal> CalculateOrderTotal([FromBody] Order order)
    {
        try
        {
            _logger.LogInformation("Calculating total for order with {ItemCount} items", order.Items.Count);

            // TODO: Step through this calculation and find the bug
            var total = order.CalculateTotal();

            // TODO: Set a watch on the total variable
            order.Total = total;

            return Ok(new { OrderId = order.Id, Total = total });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error calculating order total");
            return BadRequest($"Calculation error: {ex.Message}");
        }
    }

    /// <summary>
    /// Simulate slow operation - Practice performance debugging
    /// </summary>
    [HttpGet("slow-operation")]
    public async Task<ActionResult> SlowOperation()
    {
        _logger.LogInformation("Starting slow operation");

        // TODO: Use debugging tools to measure performance
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();

        // Simulate slow work
        await Task.Delay(2000);

        stopwatch.Stop();
        _logger.LogInformation("Slow operation completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);

        return Ok(new { Message = "Operation completed", ElapsedMs = stopwatch.ElapsedMilliseconds });
    }

    private void InitializeTestData()
    {
        if (!_users.Any())
        {
            _users.AddRange(new[]
            {
                new User { Id = 1, Name = "John Doe", Email = "john@example.com", IsActive = true, CreatedAt = DateTime.UtcNow.AddDays(-10) },
                new User { Id = 2, Name = "Jane Smith", Email = "jane@example.com", IsActive = true, CreatedAt = DateTime.UtcNow.AddDays(-5) },
                new User { Id = 3, Name = "Bob Johnson", Email = "bob@example.com", IsActive = false, CreatedAt = DateTime.UtcNow.AddDays(-15) }
            });
        }
    }
}' \
"Test controller with various debugging scenarios and intentional bugs"

    # Create VS Code debug configuration
    create_file_interactive ".vscode/launch.json" \
'{
    "version": "0.2.0",
    "configurations": [
        {
            "name": ".NET Core Launch (web)",
            "type": "coreclr",
            "request": "launch",
            "preLaunchTask": "build",
            "program": "${workspaceFolder}/bin/Debug/net8.0/DebuggingDemo.dll",
            "args": [],
            "cwd": "${workspaceFolder}",
            "stopAtEntry": false,
            "serverReadyAction": {
                "action": "openExternally",
                "pattern": "\\bNow listening on:\\s+(https?://\\S+)"
            },
            "env": {
                "ASPNETCORE_ENVIRONMENT": "Development"
            },
            "sourceFileMap": {
                "/Views": "${workspaceFolder}/Views"
            }
        },
        {
            "name": ".NET Core Attach",
            "type": "coreclr",
            "request": "attach"
        }
    ]
}' \
"VS Code debug configuration for ASP.NET Core"

    # Create tasks.json for VS Code
    create_file_interactive ".vscode/tasks.json" \
'{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build",
            "command": "dotnet",
            "type": "process",
            "args": [
                "build",
                "${workspaceFolder}/DebuggingDemo.csproj",
                "/property:GenerateFullPaths=true",
                "/consoleloggerparameters:NoSummary"
            ],
            "problemMatcher": "$msCompile"
        },
        {
            "label": "publish",
            "command": "dotnet",
            "type": "process",
            "args": [
                "publish",
                "${workspaceFolder}/DebuggingDemo.csproj",
                "/property:GenerateFullPaths=true",
                "/consoleloggerparameters:NoSummary"
            ],
            "problemMatcher": "$msCompile"
        },
        {
            "label": "watch",
            "command": "dotnet",
            "type": "process",
            "args": [
                "watch",
                "run",
                "--project",
                "${workspaceFolder}/DebuggingDemo.csproj"
            ],
            "problemMatcher": "$msCompile"
        }
    ]
}' \
"VS Code tasks configuration for building and running"

    # Create exercise guide
    create_file_interactive "DEBUGGING_GUIDE.md" \
'# Exercise 1: Debugging Fundamentals

## 🎯 Objective
Master debugging tools and techniques in ASP.NET Core applications.

## ⏱️ Time Allocation
**Total Time**: 25 minutes
- Environment Setup: 5 minutes
- Basic Debugging: 10 minutes
- Advanced Techniques: 10 minutes

## 🚀 Getting Started

### Step 1: Set Up Debugging Environment
1. Open the project in VS Code or Visual Studio
2. Ensure the debugger is configured (check .vscode/launch.json)
3. Build the project: `dotnet build`
4. Start debugging: F5 or "Run and Debug" in VS Code

### Step 2: Basic Breakpoint Debugging
1. Set a breakpoint in `TestController.GetUsers()` method
2. Call the endpoint: `GET /api/test/users`
3. Inspect the `_users` collection in the debugger
4. Step through the LINQ query execution

### Step 3: Conditional Breakpoints
1. Set a conditional breakpoint in `GetUser(int id)` method
2. Condition: `id == 2`
3. Call: `GET /api/test/users/1` (should not break)
4. Call: `GET /api/test/users/2` (should break)

### Step 4: Exception Debugging
1. Set a breakpoint in `CreateUser()` method
2. Send a POST request with empty name
3. Step through the exception handling
4. Examine the exception details

### Step 5: Watch Variables and Call Stack
1. Set breakpoints in `CalculateOrderTotal()` method
2. Add watches for: `order.Items`, `total`, `item.Price * item.Quantity`
3. Step through the calculation loop
4. Examine the call stack

## 🔧 Debugging Techniques to Practice

### Breakpoint Types
- **Line breakpoints**: Basic pause points
- **Conditional breakpoints**: Break only when condition is true
- **Hit count breakpoints**: Break after N hits
- **Function breakpoints**: Break when entering specific methods

### Variable Inspection
- **Locals window**: See all local variables
- **Watch window**: Monitor specific expressions
- **Immediate window**: Execute code during debugging
- **DataTips**: Hover over variables to see values

### Navigation
- **Step Over (F10)**: Execute current line
- **Step Into (F11)**: Enter method calls
- **Step Out (Shift+F11)**: Exit current method
- **Continue (F5)**: Resume execution

## 🧪 Debugging Exercises

### Exercise A: Find the Display Name Bug
1. Set breakpoint in `User.GetDisplayName()`
2. Create a user with null email
3. Debug the null reference exception
4. Fix the method to handle null values

### Exercise B: Debug Order Calculation
1. Create an order with multiple items
2. Set breakpoints in `CalculateTotal()`
3. Watch the running total calculation
4. Verify the math is correct

### Exercise C: Performance Debugging
1. Set breakpoint in `SlowOperation()`
2. Use the stopwatch to measure performance
3. Identify the slow operation
4. Consider optimization strategies

## ✅ Success Criteria
- [ ] Can set and use different types of breakpoints
- [ ] Comfortable with variable inspection tools
- [ ] Can navigate through code during debugging
- [ ] Able to debug exceptions effectively
- [ ] Understands call stack analysis

## 🔄 Next Steps
After mastering basic debugging, move on to Exercise 2 for logging implementation.
' \
"Comprehensive debugging guide with hands-on exercises"

    echo -e "${GREEN}🎉 Exercise 1 template created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Open the project in VS Code or Visual Studio"
    echo "2. Run: ${CYAN}dotnet build${NC}"
    echo "3. Start debugging: ${CYAN}F5${NC} or use the debugger"
    echo "4. Visit: ${CYAN}http://localhost:5000/swagger${NC}"
    echo "5. Follow the DEBUGGING_GUIDE.md for practice exercises"

elif [[ $EXERCISE_NAME == "exercise02" ]]; then
    # Exercise 2: Comprehensive Logging Implementation

    explain_concept "Structured Logging with Serilog" \
"Modern logging requires more than simple text messages:
• Structured data: Log events as structured data, not just strings
• Multiple sinks: Write logs to console, files, databases simultaneously
• Log enrichment: Add contextual information automatically
• Performance: Asynchronous logging for high throughput
• Filtering: Different log levels for different components"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${RED}❌ Exercise 2 requires Exercise 1 to be completed first${NC}"
        echo -e "${YELLOW}Please run: ./launch-exercises.sh exercise01${NC}"
        exit 1
    fi

    echo -e "${CYAN}Cleaning up any existing files...${NC}"
    rm -f Extensions/LoggingExtensions.cs 2>/dev/null
    rm -f Middleware/RequestLoggingMiddleware.cs 2>/dev/null
    rm -f Middleware/PerformanceMiddleware.cs 2>/dev/null
    rm -f Controllers/LoggingTestController.cs 2>/dev/null
    
    echo -e "${CYAN}Adding Serilog packages...${NC}"
    dotnet add package Serilog.AspNetCore --version 8.0.3
    dotnet add package Serilog.Sinks.Console --version 6.0.0
    dotnet add package Serilog.Sinks.File --version 6.0.0
    dotnet add package Serilog.Enrichers.Environment --version 3.0.1
    dotnet add package Serilog.Enrichers.Thread --version 4.0.0
    dotnet add package Serilog.Settings.Configuration --version 8.0.4

    # Update appsettings.json with Serilog configuration
    create_file_interactive "appsettings.json" \
'{
  "Serilog": {
    "MinimumLevel": {
      "Default": "Information",
      "Override": {
        "Microsoft": "Warning",
        "Microsoft.Hosting.Lifetime": "Information",
        "Microsoft.AspNetCore": "Warning"
      }
    },
    "WriteTo": [
      {
        "Name": "Console",
        "Args": {
          "theme": "Serilog.Sinks.SystemConsole.Themes.AnsiConsoleTheme::Code, Serilog.Sinks.Console",
          "outputTemplate": "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj} {Properties:j}{NewLine}{Exception}"
        }
      },
      {
        "Name": "File",
        "Args": {
          "path": "Logs/log-.txt",
          "rollingInterval": "Day",
          "rollOnFileSizeLimit": true,
          "fileSizeLimitBytes": 10485760,
          "retainedFileCountLimit": 30,
          "outputTemplate": "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] ({SourceContext}) {Message:lj} {Properties:j}{NewLine}{Exception}"
        }
      }
    ],
    "Enrich": ["FromLogContext", "WithMachineName", "WithThreadId", "WithProcessId"]
  },
  "AllowedHosts": "*"
}' \
"Serilog configuration with console and file sinks"

    # Update Program.cs with Serilog
    create_file_interactive "Program.cs" \
'using Serilog;
using Serilog.Events;
using Microsoft.AspNetCore.Diagnostics;

// Configure Serilog early
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Information)
    .Enrich.FromLogContext()
    .WriteTo.Console()
    .CreateBootstrapLogger();

try
{
    Log.Information("Starting web application");

    var builder = WebApplication.CreateBuilder(args);

    // Add Serilog
    builder.Host.UseSerilog((context, services, configuration) => configuration
        .ReadFrom.Configuration(context.Configuration)
        .ReadFrom.Services(services)
        .Enrich.FromLogContext()
        .WriteTo.Console(
            outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj} {Properties:j}{NewLine}{Exception}"));

    // Add services to the container
    builder.Services.AddControllers();
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen(c =>
    {
        c.SwaggerDoc("v1", new() { Title = "Debugging Demo API", Version = "v1" });
    });

    // Add CORS for development
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("AllowAll", policy =>
        {
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        });
    });

    // Add HTTP context accessor for logging context
    builder.Services.AddHttpContextAccessor();

    var app = builder.Build();

    // Request logging middleware
    app.UseSerilogRequestLogging(options =>
    {
        // Customize the message template
        options.MessageTemplate = "HTTP {RequestMethod} {RequestPath} responded {StatusCode} in {Elapsed:0.0000} ms";

        // Choose the level based on status code
        options.GetLevel = (httpContext, elapsed, ex) => 
        {
            if (ex != null || httpContext.Response.StatusCode > 499)
                return LogEventLevel.Error;
            if (httpContext.Response.StatusCode > 399)
                return LogEventLevel.Warning;
            if (elapsed > 1000)
                return LogEventLevel.Warning;
            return LogEventLevel.Information;
        };

        // Attach additional properties to the request log
        options.EnrichDiagnosticContext = (diagnosticContext, httpContext) =>
        {
            diagnosticContext.Set("RequestHost", httpContext.Request.Host.Value);
            diagnosticContext.Set("RequestScheme", httpContext.Request.Scheme);
            diagnosticContext.Set("UserAgent", httpContext.Request.Headers["User-Agent"].ToString());
            diagnosticContext.Set("RemoteIP", httpContext.Connection.RemoteIpAddress?.ToString());
        };
    });

    // Configure the HTTP request pipeline
    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI(c =>
        {
            c.SwaggerEndpoint("/swagger/v1/swagger.json", "Debugging Demo API v1");
            c.RoutePrefix = "swagger";
        });

        app.UseDeveloperExceptionPage();
    }
    else
    {
        app.UseExceptionHandler("/Error");
    }

    app.UseCors("AllowAll");
    app.UseHttpsRedirection();
    app.UseAuthorization();
    app.MapControllers();

    // Add a root redirect to swagger
    app.MapGet("/", () => Results.Redirect("/swagger"));

    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}' \
"Program.cs with comprehensive Serilog configuration"

    # Create logging extensions
    create_file_interactive "Extensions/LoggingExtensions.cs" \
'using Serilog;
using System.Diagnostics;

namespace DebuggingDemo.Extensions;

public static class LoggingExtensions
{
    /// <summary>
    /// Logs method entry with parameters
    /// </summary>
    public static IDisposable BeginMethodScope(this Serilog.ILogger logger, string methodName, params object[] parameters)
    {
        logger.Information("Entering {MethodName} with parameters {@Parameters}", methodName, parameters);
        var stopwatch = Stopwatch.StartNew();
        
        return new MethodScope(logger, methodName, stopwatch);
    }

    /// <summary>
    /// Enriches log context with correlation ID
    /// </summary>
    public static void EnrichWithCorrelationId(this IDiagnosticContext diagnosticContext, HttpContext httpContext)
    {
        var correlationId = httpContext.TraceIdentifier;
        diagnosticContext.Set("CorrelationId", correlationId);
    }

    private class MethodScope : IDisposable
    {
        private readonly Serilog.ILogger _logger;
        private readonly string _methodName;
        private readonly Stopwatch _stopwatch;

        public MethodScope(Serilog.ILogger logger, string methodName, Stopwatch stopwatch)
        {
            _logger = logger;
            _methodName = methodName;
            _stopwatch = stopwatch;
        }

        public void Dispose()
        {
            _stopwatch.Stop();
            _logger.Information("Exiting {MethodName} after {ElapsedMilliseconds}ms", 
                _methodName, _stopwatch.ElapsedMilliseconds);
        }
    }
}

/// <summary>
/// Helper class for structured logging
/// </summary>
public static class LogHelper
{
    public static void LogPerformanceWarning(this Serilog.ILogger logger, string operation, long elapsedMs, long thresholdMs = 1000)
    {
        if (elapsedMs > thresholdMs)
        {
            logger.Warning("Slow operation detected: {Operation} took {ElapsedMs}ms (threshold: {ThresholdMs}ms)",
                operation, elapsedMs, thresholdMs);
        }
    }

    public static void LogBusinessEvent(this Serilog.ILogger logger, string eventName, object data)
    {
        logger.Information("Business event: {EventName} with data {@EventData}", eventName, data);
    }

    public static void LogSecurityEvent(this Serilog.ILogger logger, string action, string username, bool success)
    {
        if (success)
        {
            logger.Information("Security: {Action} succeeded for user {Username}", action, username);
        }
        else
        {
            logger.Warning("Security: {Action} failed for user {Username}", action, username);
        }
    }
}' \
"Logging extension methods for structured logging patterns"

    # Create middleware for request/response logging
    create_file_interactive "Middleware/RequestLoggingMiddleware.cs" \
'using System.Diagnostics;
using System.Text;
using Serilog;
using Serilog.Events;

namespace DebuggingDemo.Middleware;

public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly Serilog.ILogger _logger = Log.ForContext<RequestLoggingMiddleware>();

    public RequestLoggingMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Skip logging for certain paths
        if (ShouldSkipLogging(context.Request.Path))
        {
            await _next(context);
            return;
        }

        var stopwatch = Stopwatch.StartNew();
        var originalBodyStream = context.Response.Body;

        try
        {
            // Log request
            await LogRequest(context);

            // Capture response body
            using var responseBody = new MemoryStream();
            context.Response.Body = responseBody;

            await _next(context);

            // Log response
            await LogResponse(context, responseBody, stopwatch.ElapsedMilliseconds);

            // Copy the response body back to the original stream
            await responseBody.CopyToAsync(originalBodyStream);
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            LogError(context, ex, stopwatch.ElapsedMilliseconds);
            throw;
        }
        finally
        {
            context.Response.Body = originalBodyStream;
        }
    }

    private bool ShouldSkipLogging(PathString path)
    {
        var pathValue = path.Value?.ToLower() ?? string.Empty;
        return pathValue.Contains("/swagger") || 
               pathValue.Contains("/health") ||
               pathValue.Contains(".js") ||
               pathValue.Contains(".css");
    }

    private async Task LogRequest(HttpContext context)
    {
        // Enable buffering to allow multiple reads
        context.Request.EnableBuffering();

        var request = context.Request;
        var body = string.Empty;

        if (request.ContentLength > 0 && request.ContentLength < 10000)
        {
            request.Body.Position = 0;
            using var reader = new StreamReader(request.Body, Encoding.UTF8, leaveOpen: true);
            body = await reader.ReadToEndAsync();
            request.Body.Position = 0;
        }

        _logger.Information("HTTP Request: {Method} {Path} {QueryString} Body: {Body}",
            request.Method,
            request.Path,
            request.QueryString,
            body);
    }

    private async Task LogResponse(HttpContext context, MemoryStream responseBody, long elapsedMs)
    {
        responseBody.Position = 0;
        var body = string.Empty;

        if (responseBody.Length > 0 && responseBody.Length < 10000)
        {
            body = await new StreamReader(responseBody).ReadToEndAsync();
        }

        responseBody.Position = 0;

        var level = context.Response.StatusCode >= 400 ? LogEventLevel.Warning : LogEventLevel.Information;

        _logger.Write(level, "HTTP Response: {StatusCode} {ElapsedMs}ms Body: {Body}",
            context.Response.StatusCode,
            elapsedMs,
            body);
    }

    private void LogError(HttpContext context, Exception ex, long elapsedMs)
    {
        _logger.Error(ex, "HTTP Request failed: {Method} {Path} after {ElapsedMs}ms",
            context.Request.Method,
            context.Request.Path,
            elapsedMs);
    }
}

public static class RequestLoggingMiddlewareExtensions
{
    public static IApplicationBuilder UseRequestLogging(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<RequestLoggingMiddleware>();
    }
}' \
"Request/response logging middleware for detailed HTTP logging"

    # Create performance logging middleware
    create_file_interactive "Middleware/PerformanceMiddleware.cs" \
'using System.Diagnostics;
using DebuggingDemo.Extensions;

namespace DebuggingDemo.Middleware;

public class PerformanceMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<PerformanceMiddleware> _logger;
    private readonly int _slowRequestThresholdMs;

    public PerformanceMiddleware(RequestDelegate next, ILogger<PerformanceMiddleware> logger, IConfiguration configuration)
    {
        _next = next;
        _logger = logger;
        _slowRequestThresholdMs = configuration.GetValue<int>("Performance:SlowRequestThresholdMs", 1000);
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();
        var path = context.Request.Path;

        try
        {
            await _next(context);
        }
        finally
        {
            stopwatch.Stop();
            var elapsedMs = stopwatch.ElapsedMilliseconds;

            if (elapsedMs > _slowRequestThresholdMs)
            {
                _logger.LogWarning("Slow request detected: {Method} {Path} took {ElapsedMs}ms (threshold: {ThresholdMs}ms)",
                    context.Request.Method, path, elapsedMs, _slowRequestThresholdMs);
            }

            // Add performance headers
            context.Response.Headers.Add("X-Response-Time-ms", elapsedMs.ToString());
            
            // Log performance metrics
            using (_logger.BeginScope(new Dictionary<string, object>
            {
                ["RequestPath"] = path.Value,
                ["RequestMethod"] = context.Request.Method,
                ["StatusCode"] = context.Response.StatusCode,
                ["ElapsedMilliseconds"] = elapsedMs
            }))
            {
                _logger.LogInformation("Request completed in {ElapsedMilliseconds}ms", elapsedMs);
            }
        }
    }
}

public static class PerformanceMiddlewareExtensions
{
    public static IApplicationBuilder UsePerformanceLogging(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<PerformanceMiddleware>();
    }
}' \
"Performance monitoring middleware to track slow requests"

    # Update the test controller with logging examples
    create_file_interactive "Controllers/LoggingTestController.cs" \
'using Microsoft.AspNetCore.Mvc;
using DebuggingDemo.Models;
using DebuggingDemo.Extensions;
using Serilog;

namespace DebuggingDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class LoggingTestController : ControllerBase
{
    private readonly ILogger<LoggingTestController> _logger;
    private readonly Serilog.ILogger _serilogLogger;
    private readonly IDiagnosticContext _diagnosticContext;

    public LoggingTestController(ILogger<LoggingTestController> logger, IDiagnosticContext diagnosticContext)
    {
        _logger = logger;
        _serilogLogger = Log.ForContext<LoggingTestController>();
        _diagnosticContext = diagnosticContext;
    }

    /// <summary>
    /// Test structured logging with different levels
    /// </summary>
    [HttpGet("test-levels")]
    public IActionResult TestLogLevels()
    {
        _logger.LogTrace("This is a trace message - very detailed");
        _logger.LogDebug("This is a debug message - debugging info");
        _logger.LogInformation("This is an information message - general info");
        _logger.LogWarning("This is a warning message - something to watch");
        _logger.LogError("This is an error message - something went wrong");
        _logger.LogCritical("This is a critical message - system failure");

        return Ok(new { Message = "Check the logs for different log levels" });
    }

    /// <summary>
    /// Test structured logging with parameters
    /// </summary>
    [HttpGet("test-structured/{id}")]
    public IActionResult TestStructuredLogging(int id, [FromQuery] string name)
    {
        // Good: Structured logging
        _logger.LogInformation("Processing request for user {UserId} with name {UserName}", id, name);

        // Add custom properties to the log context
        using (_logger.BeginScope(new Dictionary<string, object>
        {
            ["UserId"] = id,
            ["UserName"] = name,
            ["RequestTime"] = DateTime.UtcNow
        }))
        {
            _logger.LogInformation("User details retrieved successfully");
            _logger.LogInformation("Performing additional operations for user");
        }

        // Use diagnostic context for request-wide properties
        _diagnosticContext.Set("UserId", id);
        _diagnosticContext.Set("UserName", name);

        return Ok(new { UserId = id, UserName = name });
    }

    /// <summary>
    /// Test performance logging
    /// </summary>
    [HttpGet("test-performance")]
    public async Task<IActionResult> TestPerformanceLogging()
    {
        using (var scope = _serilogLogger.BeginMethodScope(nameof(TestPerformanceLogging)))
        {
            _logger.LogInformation("Starting performance test");

            // Simulate some work
            await Task.Delay(500);
            _logger.LogInformation("Phase 1 completed");

            await Task.Delay(800);
            _logger.LogInformation("Phase 2 completed");

            // Log a performance warning if slow
            var totalTime = 1300;
            _serilogLogger.LogPerformanceWarning("TestPerformanceLogging", totalTime);

            return Ok(new { Message = "Performance test completed", ElapsedMs = totalTime });
        }
    }

    /// <summary>
    /// Test exception logging
    /// </summary>
    [HttpGet("test-exception")]
    public IActionResult TestExceptionLogging()
    {
        try
        {
            _logger.LogInformation("Attempting risky operation");
            
            // Simulate an error
            throw new InvalidOperationException("This is a test exception with inner exception",
                new ArgumentException("Inner exception details"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while processing request for {Controller}.{Action}",
                nameof(LoggingTestController), nameof(TestExceptionLogging));

            return StatusCode(500, new { Error = "An error occurred", Details = ex.Message });
        }
    }

    /// <summary>
    /// Test business event logging
    /// </summary>
    [HttpPost("test-business-event")]
    public IActionResult TestBusinessEventLogging([FromBody] Order order)
    {
        // Log business event
        _serilogLogger.LogBusinessEvent("OrderCreated", new
        {
            OrderId = order.Id,
            UserId = order.UserId,
            ItemCount = order.Items.Count,
            Total = order.Total
        });

        // Log with correlation
        using (_logger.BeginScope("OrderProcessing"))
        {
            _logger.LogInformation("Processing order {OrderId}", order.Id);
            _logger.LogInformation("Validating {ItemCount} items", order.Items.Count);
            _logger.LogInformation("Order total: {OrderTotal:C}", order.Total);
        }

        return Ok(new { Message = "Order logged successfully", OrderId = order.Id });
    }

    /// <summary>
    /// Test security event logging
    /// </summary>
    [HttpPost("test-security")]
    public IActionResult TestSecurityLogging([FromBody] LoginRequest request)
    {
        // Simulate authentication
        var success = request.Username == "admin";

        _serilogLogger.LogSecurityEvent("Login", request.Username, success);

        if (!success)
        {
            _logger.LogWarning("Failed login attempt for user {Username} from IP {IPAddress}",
                request.Username, HttpContext.Connection.RemoteIpAddress);
        }

        return success ? Ok(new { Message = "Login successful" }) : Unauthorized();
    }
}

public class LoginRequest
{
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}' \
"Controller demonstrating various logging patterns and best practices"

    # Create logging exercise guide
    create_file_interactive "LOGGING_GUIDE.md" \
'# Exercise 2: Comprehensive Logging Implementation

## 🎯 Objective
Implement multi-provider logging with different log levels, structured logging, and best practices using Serilog.

## ⏱️ Time Allocation
**Total Time**: 30 minutes
- Serilog Setup: 10 minutes
- Structured Logging: 10 minutes
- Advanced Patterns: 10 minutes

## 🚀 Getting Started

### Step 1: Understanding Serilog Configuration
1. Review `appsettings.json` for Serilog settings
2. Note the different sinks (Console, File)
3. Understand log levels and overrides
4. Check enrichers for automatic context

### Step 2: Test Different Log Levels
1. Run the application: `dotnet run`
2. Call: `GET /api/loggingtest/test-levels`
3. Observe console output with different colors
4. Check `Logs/` directory for file output

### Step 3: Structured Logging
1. Call: `GET /api/loggingtest/test-structured/123?name=John`
2. Note how parameters are captured as properties
3. Check JSON structure in logs
4. Compare with string interpolation anti-pattern

### Step 4: Performance Logging
1. Call: `GET /api/loggingtest/test-performance`
2. Observe method entry/exit logging
3. Check performance warnings for slow operations
4. Note the elapsed time tracking

### Step 5: Exception Logging
1. Call: `GET /api/loggingtest/test-exception`
2. See full exception details in logs
3. Note stack trace preservation
4. Check correlation with request context

## 📊 Logging Best Practices

### 1. Use Structured Logging
```csharp
// Good: Structured parameters
_logger.LogInformation("User {UserId} purchased {ProductName} for {Price:C}", 
    userId, productName, price);

// Bad: String concatenation
_logger.LogInformation($"User {userId} purchased {productName} for ${price}");
```

### 2. Choose Appropriate Log Levels
- **Trace**: Method entry/exit, detailed flow
- **Debug**: Detailed debugging information
- **Information**: General informational messages
- **Warning**: Unusual but handled situations
- **Error**: Errors that dont stop the app
- **Critical**: Serious errors requiring immediate attention

### 3. Use Scopes for Context
```csharp
using (_logger.BeginScope(new { UserId = userId, OrderId = orderId }))
{
    // All logs within this scope will include UserId and OrderId
    _logger.LogInformation("Processing order");
    _logger.LogInformation("Order validated");
}
```

### 4. Enrich Logs Automatically
- Request ID / Correlation ID
- User information
- Machine name
- Environment details
- Performance metrics

## 🧪 Logging Exercises

### Exercise A: Analyze Log Output
1. Make several API calls
2. Find specific requests in the log files
3. Trace a request through multiple log entries
4. Use correlation IDs to group related logs

### Exercise B: Add Custom Enrichment
1. Create a custom enricher for user context
2. Add request headers to logs
3. Include custom application metrics
4. Test with different scenarios

### Exercise C: Configure Log Filtering
1. Change log levels in appsettings.json
2. Filter out specific namespaces
3. Create environment-specific configurations
4. Test verbose vs. production logging

### Exercise D: Implement Business Event Logging
1. Create an order: `POST /api/loggingtest/test-business-event`
2. Review the business event structure
3. Add more business events
4. Create a business event dashboard

## 📈 Monitoring and Analysis

### Log File Analysis
1. Navigate to the `Logs/` directory
2. Open the latest log file
3. Search for specific patterns:
   - Errors: `[ERR]`
   - Warnings: `[WRN]`
   - Slow requests: "Slow operation"
   - Exceptions: "Exception"

### Performance Metrics
1. Look for requests over 1000ms
2. Identify frequent warnings
3. Find error patterns
4. Track business events

## ✅ Success Criteria
- [ ] Serilog is properly configured with multiple sinks
- [ ] Structured logging is used throughout
- [ ] Different log levels are appropriately applied
- [ ] Performance metrics are captured
- [ ] Exceptions are logged with full context
- [ ] Business events are tracked
- [ ] Log files are properly formatted and rotated

## 🔄 Next Steps
After mastering logging, proceed to Exercise 3 for exception handling and monitoring.

## 💡 Pro Tips
1. **Avoid over-logging**: Too many logs can hide important information
2. **Be consistent**: Use the same property names across your application
3. **Think about the reader**: Write logs that help diagnose issues
4. **Secure sensitive data**: Never log passwords, tokens, or PII
5. **Use correlation**: Always include request/correlation IDs
6. **Monitor log size**: Implement retention policies
7. **Test your logs**: Ensure they work when you need them most
' \
"Comprehensive logging guide with hands-on exercises and best practices"

    echo -e "${GREEN}🎉 Exercise 2 template created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Run: ${CYAN}dotnet build${NC}"
    echo "2. Run: ${CYAN}dotnet run${NC}"
    echo "3. Visit: ${CYAN}http://localhost:5000/swagger${NC}"
    echo "4. Test the logging endpoints"
    echo "5. Check the ${CYAN}Logs/${NC} directory for file output"
    echo "6. Follow the LOGGING_GUIDE.md for exercises"

elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    # Exercise 3: Exception Handling and Monitoring

    explain_concept "Exception Handling and Monitoring" \
"Production-ready applications need robust error handling:
• Global exception handling: Catch all unhandled exceptions
• Problem Details (RFC 7807): Standardized error responses
• Health checks: Monitor application and dependency health
• Performance monitoring: Track application metrics
• Error tracking: Capture and analyze exceptions"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${RED}❌ Exercise 3 requires Exercise 1 and 2 to be completed first${NC}"
        echo -e "${YELLOW}Please run: ./launch-exercises.sh exercise01 then exercise02${NC}"
        exit 1
    fi

    echo -e "${CYAN}Adding health check and monitoring packages...${NC}"
    dotnet add package Microsoft.AspNetCore.Diagnostics.HealthChecks --version 8.0.11
    dotnet add package AspNetCore.HealthChecks.UI.Client --version 8.0.1
    dotnet add package Microsoft.Extensions.Diagnostics.HealthChecks --version 8.0.11

    # Create exception handling middleware
    create_file_interactive "Middleware/ExceptionHandlingMiddleware.cs" \
'using System.Net;
using System.Text.Json;
using DebuggingDemo.Models;

namespace DebuggingDemo.Middleware;

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;
    private readonly IHostEnvironment _env;

    public ExceptionHandlingMiddleware(
        RequestDelegate next,
        ILogger<ExceptionHandlingMiddleware> logger,
        IHostEnvironment env)
    {
        _next = next;
        _logger = logger;
        _env = env;
    }

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
        // Log the exception with full details
        _logger.LogError(exception, "An unhandled exception occurred. RequestId: {RequestId}",
            context.TraceIdentifier);

        // Set response details
        context.Response.ContentType = "application/problem+json";
        context.Response.StatusCode = GetStatusCode(exception);

        // Create problem details response
        var problemDetails = new ProblemDetails
        {
            Status = context.Response.StatusCode,
            Title = GetTitle(exception),
            Detail = _env.IsDevelopment() ? exception.Message : "An error occurred processing your request",
            Instance = context.Request.Path,
            Type = $"https://httpstatuses.com/{context.Response.StatusCode}",
            Extensions = new Dictionary<string, object?>
            {
                ["requestId"] = context.TraceIdentifier,
                ["timestamp"] = DateTime.UtcNow
            }
        };

        // Add stack trace in development
        if (_env.IsDevelopment())
        {
            problemDetails.Extensions["stackTrace"] = exception.StackTrace;
            if (exception.InnerException != null)
            {
                problemDetails.Extensions["innerException"] = new
                {
                    message = exception.InnerException.Message,
                    stackTrace = exception.InnerException.StackTrace
                };
            }
        }

        var json = JsonSerializer.Serialize(problemDetails, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        });

        await context.Response.WriteAsync(json);
    }

    private static int GetStatusCode(Exception exception) => exception switch
    {
        ArgumentNullException => StatusCodes.Status400BadRequest,
        ArgumentException => StatusCodes.Status400BadRequest,
        InvalidOperationException => StatusCodes.Status400BadRequest,
        UnauthorizedAccessException => StatusCodes.Status401Unauthorized,
        KeyNotFoundException => StatusCodes.Status404NotFound,
        NotImplementedException => StatusCodes.Status501NotImplemented,
        TimeoutException => StatusCodes.Status408RequestTimeout,
        _ => StatusCodes.Status500InternalServerError
    };

    private static string GetTitle(Exception exception) => exception switch
    {
        ArgumentNullException => "Required Parameter Missing",
        ArgumentException => "Invalid Argument",
        InvalidOperationException => "Invalid Operation",
        UnauthorizedAccessException => "Unauthorized Access",
        KeyNotFoundException => "Resource Not Found",
        NotImplementedException => "Not Implemented",
        TimeoutException => "Request Timeout",
        _ => "Internal Server Error"
    };
}

public static class ExceptionHandlingMiddlewareExtensions
{
    public static IApplicationBuilder UseExceptionHandling(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<ExceptionHandlingMiddleware>();
    }
}' \
"Global exception handling middleware with RFC 7807 Problem Details"

    # Create ProblemDetails model
    create_file_interactive "Models/ProblemDetails.cs" \
'using System.Text.Json.Serialization;

namespace DebuggingDemo.Models;

/// <summary>
/// RFC 7807 Problem Details for HTTP APIs
/// </summary>
public class ProblemDetails
{
    /// <summary>
    /// A URI reference [RFC3986] that identifies the problem type
    /// </summary>
    [JsonPropertyName("type")]
    public string? Type { get; set; }

    /// <summary>
    /// A short, human-readable summary of the problem type
    /// </summary>
    [JsonPropertyName("title")]
    public string? Title { get; set; }

    /// <summary>
    /// The HTTP status code
    /// </summary>
    [JsonPropertyName("status")]
    public int? Status { get; set; }

    /// <summary>
    /// A human-readable explanation specific to this occurrence of the problem
    /// </summary>
    [JsonPropertyName("detail")]
    public string? Detail { get; set; }

    /// <summary>
    /// A URI reference that identifies the specific occurrence of the problem
    /// </summary>
    [JsonPropertyName("instance")]
    public string? Instance { get; set; }

    /// <summary>
    /// Additional details about the error
    /// </summary>
    [JsonExtensionData]
    public Dictionary<string, object?> Extensions { get; set; } = new();
}

/// <summary>
/// Standard error response model
/// </summary>
public class ErrorResponse
{
    public string RequestId { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    public string Message { get; set; } = string.Empty;
    public string? Details { get; set; }
    public Dictionary<string, string[]>? ValidationErrors { get; set; }
}' \
"Problem Details and Error Response models for standardized error handling"

    # Create health checks
    create_file_interactive "HealthChecks/DatabaseHealthCheck.cs" \
'using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace DebuggingDemo.HealthChecks;

public class DatabaseHealthCheck : IHealthCheck
{
    private readonly ILogger<DatabaseHealthCheck> _logger;
    private readonly Random _random = new();

    public DatabaseHealthCheck(ILogger<DatabaseHealthCheck> logger)
    {
        _logger = logger;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Checking database health");

            // Simulate database connectivity check
            await Task.Delay(100, cancellationToken);

            // Simulate occasional failures for testing
            if (_random.Next(100) < 10) // 10% chance of failure
            {
                return HealthCheckResult.Unhealthy(
                    "Database connection failed",
                    data: new Dictionary<string, object>
                    {
                        ["connectionString"] = "Server=localhost;Database=DebuggingDemo",
                        ["error"] = "Connection timeout"
                    });
            }

            // Simulate degraded state
            if (_random.Next(100) < 20) // 20% chance of degraded
            {
                return HealthCheckResult.Degraded(
                    "Database response slow",
                    data: new Dictionary<string, object>
                    {
                        ["responseTime"] = "1500ms",
                        ["threshold"] = "1000ms"
                    });
            }

            // Healthy state
            return HealthCheckResult.Healthy(
                "Database connection is healthy",
                data: new Dictionary<string, object>
                {
                    ["responseTime"] = "50ms",
                    ["activeConnections"] = 5
                });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Database health check failed");

            return HealthCheckResult.Unhealthy(
                "Database health check threw an exception",
                exception: ex,
                data: new Dictionary<string, object>
                {
                    ["error"] = ex.Message
                });
        }
    }
}' \
"Database health check implementation"

    create_file_interactive "HealthChecks/ExternalApiHealthCheck.cs" \
'using Microsoft.Extensions.Diagnostics.HealthChecks;
using System.Net.Http;

namespace DebuggingDemo.HealthChecks;

public class ExternalApiHealthCheck : IHealthCheck
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<ExternalApiHealthCheck> _logger;
    private readonly string _apiUrl;

    public ExternalApiHealthCheck(HttpClient httpClient, ILogger<ExternalApiHealthCheck> logger, IConfiguration configuration)
    {
        _httpClient = httpClient;
        _logger = logger;
        _apiUrl = configuration["ExternalApi:HealthCheckUrl"] ?? "https://api.github.com/health";
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Checking external API health: {ApiUrl}", _apiUrl);

            var stopwatch = System.Diagnostics.Stopwatch.StartNew();
            
            // Set a timeout for the health check
            using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
            cts.CancelAfter(TimeSpan.FromSeconds(5));

            var response = await _httpClient.GetAsync(_apiUrl, cts.Token);
            stopwatch.Stop();

            var data = new Dictionary<string, object>
            {
                ["statusCode"] = (int)response.StatusCode,
                ["responseTime"] = $"{stopwatch.ElapsedMilliseconds}ms",
                ["endpoint"] = _apiUrl
            };

            if (response.IsSuccessStatusCode)
            {
                return HealthCheckResult.Healthy(
                    $"External API is healthy (Status: {response.StatusCode})",
                    data);
            }

            if ((int)response.StatusCode >= 500)
            {
                return HealthCheckResult.Unhealthy(
                    $"External API returned server error: {response.StatusCode}",
                    data: data);
            }

            return HealthCheckResult.Degraded(
                $"External API returned non-success status: {response.StatusCode}",
                data: data);
        }
        catch (TaskCanceledException)
        {
            _logger.LogWarning("External API health check timed out");

            return HealthCheckResult.Unhealthy(
                "External API health check timed out",
                data: new Dictionary<string, object>
                {
                    ["timeout"] = "5 seconds",
                    ["endpoint"] = _apiUrl
                });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "External API health check failed");

            return HealthCheckResult.Unhealthy(
                "External API health check threw an exception",
                exception: ex,
                data: new Dictionary<string, object>
                {
                    ["error"] = ex.Message,
                    ["endpoint"] = _apiUrl
                });
        }
    }
}' \
"External API health check implementation"

    create_file_interactive "HealthChecks/CustomHealthCheck.cs" \
'using Microsoft.Extensions.Diagnostics.HealthChecks;
using System.Diagnostics;

namespace DebuggingDemo.HealthChecks;

public class CustomHealthCheck : IHealthCheck
{
    private readonly ILogger<CustomHealthCheck> _logger;
    private static readonly Process CurrentProcess = Process.GetCurrentProcess();

    public CustomHealthCheck(ILogger<CustomHealthCheck> logger)
    {
        _logger = logger;
    }

    public Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        try
        {
            // Refresh process info
            CurrentProcess.Refresh();

            // Check memory usage
            var workingSetMb = CurrentProcess.WorkingSet64 / (1024 * 1024);
            var gcMemoryMb = GC.GetTotalMemory(false) / (1024 * 1024);

            var data = new Dictionary<string, object>
            {
                ["workingSetMB"] = workingSetMb,
                ["gcMemoryMB"] = gcMemoryMb,
                ["threadCount"] = CurrentProcess.Threads.Count,
                ["handleCount"] = CurrentProcess.HandleCount,
                ["uptime"] = DateTime.UtcNow - CurrentProcess.StartTime.ToUniversalTime()
            };

            // Check for high memory usage
            if (workingSetMb > 500)
            {
                return Task.FromResult(HealthCheckResult.Unhealthy(
                    $"High memory usage: {workingSetMb}MB",
                    data: data));
            }

            if (workingSetMb > 300)
            {
                return Task.FromResult(HealthCheckResult.Degraded(
                    $"Elevated memory usage: {workingSetMb}MB",
                    data: data));
            }

            return Task.FromResult(HealthCheckResult.Healthy(
                "Application resources are within normal range",
                data: data));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Custom health check failed");

            return Task.FromResult(HealthCheckResult.Unhealthy(
                "Custom health check threw an exception",
                exception: ex));
        }
    }
}' \
"Custom application health check for resource monitoring"

    # Create health controller
    create_file_interactive "Controllers/HealthController.cs" \
'using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using System.Net;

namespace DebuggingDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HealthController : ControllerBase
{
    private readonly HealthCheckService _healthCheckService;
    private readonly ILogger<HealthController> _logger;

    public HealthController(HealthCheckService healthCheckService, ILogger<HealthController> logger)
    {
        _healthCheckService = healthCheckService;
        _logger = logger;
    }

    /// <summary>
    /// Get overall health status
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetHealth()
    {
        var report = await _healthCheckService.CheckHealthAsync();

        var response = new
        {
            Status = report.Status.ToString(),
            Duration = report.TotalDuration,
            Entries = report.Entries.Select(e => new
            {
                Name = e.Key,
                Status = e.Value.Status.ToString(),
                Duration = e.Value.Duration,
                Description = e.Value.Description,
                Data = e.Value.Data,
                Tags = e.Value.Tags
            })
        };

        return report.Status == HealthStatus.Healthy
            ? Ok(response)
            : StatusCode((int)HttpStatusCode.ServiceUnavailable, response);
    }

    /// <summary>
    /// Get health status for a specific check
    /// </summary>
    [HttpGet("{name}")]
    public async Task<IActionResult> GetHealthByName(string name)
    {
        var report = await _healthCheckService.CheckHealthAsync();

        if (!report.Entries.TryGetValue(name, out var entry))
        {
            return NotFound(new { Message = $"Health check '{name}' not found" });
        }

        var response = new
        {
            Name = name,
            Status = entry.Status.ToString(),
            Duration = entry.Duration,
            Description = entry.Description,
            Data = entry.Data,
            Exception = entry.Exception?.Message
        };

        return entry.Status == HealthStatus.Healthy
            ? Ok(response)
            : StatusCode((int)HttpStatusCode.ServiceUnavailable, response);
    }

    /// <summary>
    /// Simple liveness probe
    /// </summary>
    [HttpGet("live")]
    public IActionResult GetLiveness()
    {
        return Ok(new { Status = "Alive", Timestamp = DateTime.UtcNow });
    }

    /// <summary>
    /// Readiness probe
    /// </summary>
    [HttpGet("ready")]
    public async Task<IActionResult> GetReadiness()
    {
        var report = await _healthCheckService.CheckHealthAsync(
            predicate: check => check.Tags.Contains("ready"));

        return report.Status == HealthStatus.Healthy
            ? Ok(new { Status = "Ready", Timestamp = DateTime.UtcNow })
            : StatusCode((int)HttpStatusCode.ServiceUnavailable, 
                new { Status = "NotReady", Timestamp = DateTime.UtcNow });
    }
}' \
"Health check controller with various health endpoints"

    # Create exception test controller
    create_file_interactive "Controllers/ExceptionTestController.cs" \
'using Microsoft.AspNetCore.Mvc;
using DebuggingDemo.Models;

namespace DebuggingDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ExceptionTestController : ControllerBase
{
    private readonly ILogger<ExceptionTestController> _logger;

    public ExceptionTestController(ILogger<ExceptionTestController> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// Test various exception types
    /// </summary>
    [HttpGet("test/{exceptionType}")]
    public IActionResult TestException(string exceptionType)
    {
        _logger.LogInformation("Testing exception type: {ExceptionType}", exceptionType);

        switch (exceptionType.ToLower())
        {
            case "argument":
                throw new ArgumentException("This is a test argument exception", nameof(exceptionType));

            case "nullreference":
                string? nullString = null;
                _ = nullString.Length; // This will throw NullReferenceException
                break;

            case "invalidoperation":
                throw new InvalidOperationException("This operation is not valid in the current state");

            case "notfound":
                throw new KeyNotFoundException($"Resource with key '{exceptionType}' was not found");

            case "unauthorized":
                throw new UnauthorizedAccessException("You are not authorized to access this resource");

            case "timeout":
                throw new TimeoutException("The operation has timed out after 30 seconds");

            case "notimplemented":
                throw new NotImplementedException("This feature is not yet implemented");

            case "custom":
                throw new CustomException("This is a custom exception with additional data")
                {
                    ErrorCode = "CUSTOM_001",
                    AdditionalData = new Dictionary<string, object>
                    {
                        ["userId"] = 123,
                        ["timestamp"] = DateTime.UtcNow
                    }
                };

            default:
                return Ok(new { Message = $"Unknown exception type: {exceptionType}" });
        }

        return Ok("This should not be reached");
    }

    /// <summary>
    /// Test nested exceptions
    /// </summary>
    [HttpPost("test-nested")]
    public IActionResult TestNestedException()
    {
        try
        {
            try
            {
                throw new InvalidOperationException("Inner operation failed");
            }
            catch (Exception inner)
            {
                throw new ApplicationException("Outer operation failed due to inner exception", inner);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Nested exception test");
            throw; // Let the middleware handle it
        }
    }

    /// <summary>
    /// Test validation errors
    /// </summary>
    [HttpPost("test-validation")]
    public IActionResult TestValidation([FromBody] User? user)
    {
        if (user == null)
        {
            throw new ArgumentNullException(nameof(user), "User object cannot be null");
        }

        var errors = new Dictionary<string, List<string>>();

        if (string.IsNullOrWhiteSpace(user.Name))
        {
            errors.Add(nameof(user.Name), new List<string> { "Name is required", "Name cannot be empty" });
        }

        if (string.IsNullOrWhiteSpace(user.Email) || !user.Email.Contains("@"))
        {
            errors.Add(nameof(user.Email), new List<string> { "Valid email is required" });
        }

        if (errors.Any())
        {
            throw new ValidationException("Validation failed", errors);
        }

        return Ok(new { Message = "Validation passed", User = user });
    }

    /// <summary>
    /// Test performance monitoring
    /// </summary>
    [HttpGet("test-performance/{delay}")]
    public async Task<IActionResult> TestPerformance(int delay)
    {
        if (delay < 0 || delay > 10000)
        {
            throw new ArgumentOutOfRangeException(nameof(delay), "Delay must be between 0 and 10000 ms");
        }

        _logger.LogInformation("Starting performance test with {Delay}ms delay", delay);

        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        await Task.Delay(delay);
        stopwatch.Stop();

        if (stopwatch.ElapsedMilliseconds > 5000)
        {
            _logger.LogWarning("Performance test took too long: {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
        }

        return Ok(new
        {
            RequestedDelay = delay,
            ActualDelay = stopwatch.ElapsedMilliseconds,
            Message = delay > 1000 ? "Slow operation completed" : "Fast operation completed"
        });
    }
}

public class CustomException : Exception
{
    public string ErrorCode { get; set; } = string.Empty;
    public Dictionary<string, object> AdditionalData { get; set; } = new();

    public CustomException(string message) : base(message) { }
    public CustomException(string message, Exception innerException) : base(message, innerException) { }
}

public class ValidationException : Exception
{
    public Dictionary<string, List<string>> Errors { get; }

    public ValidationException(string message, Dictionary<string, List<string>> errors) : base(message)
    {
        Errors = errors;
    }
}' \
"Controller for testing various exception scenarios"

    # Update Program.cs with exception handling and health checks
    create_file_interactive "Program.cs" \
'using Serilog;
using Serilog.Events;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using HealthChecks.UI.Client;
using DebuggingDemo.HealthChecks;
using DebuggingDemo.Middleware;

// Configure Serilog early
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Information)
    .Enrich.FromLogContext()
    .WriteTo.Console()
    .CreateBootstrapLogger();

try
{
    Log.Information("Starting web application");

    var builder = WebApplication.CreateBuilder(args);

    // Add Serilog
    builder.Host.UseSerilog((context, services, configuration) => configuration
        .ReadFrom.Configuration(context.Configuration)
        .ReadFrom.Services(services)
        .Enrich.FromLogContext()
        .WriteTo.Console(
            outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj} {Properties:j}{NewLine}{Exception}"));

    // Add services to the container
    builder.Services.AddControllers();
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen(c =>
    {
        c.SwaggerDoc("v1", new() { Title = "Debugging Demo API", Version = "v1" });
    });

    // Add CORS for development
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("AllowAll", policy =>
        {
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        });
    });

    // Add HTTP context accessor for logging context
    builder.Services.AddHttpContextAccessor();

    // Configure health checks
    builder.Services.AddHealthChecks()
        .AddCheck<DatabaseHealthCheck>("database", tags: new[] { "db", "sql", "ready" })
        .AddCheck<CustomHealthCheck>("resources", tags: new[] { "resources" })
        .AddTypeActivatedCheck<ExternalApiHealthCheck>(
            "external-api",
            tags: new[] { "api", "external", "ready" });

    // Add HttpClient for external API health check
    builder.Services.AddHttpClient<ExternalApiHealthCheck>();

    // Configure health check UI
    builder.Services.AddHealthChecksUI(options =>
    {
        options.SetEvaluationTimeInSeconds(30);
        options.MaximumHistoryEntriesPerEndpoint(50);
    }).AddInMemoryStorage();

    var app = builder.Build();

    // Add exception handling middleware FIRST
    app.UseExceptionHandling();

    // Request logging middleware
    app.UseSerilogRequestLogging(options =>
    {
        // Customize the message template
        options.MessageTemplate = "HTTP {RequestMethod} {RequestPath} responded {StatusCode} in {Elapsed:0.0000} ms";

        // Choose the level based on status code
        options.GetLevel = (httpContext, elapsed, ex) => 
        {
            if (ex != null || httpContext.Response.StatusCode > 499)
                return LogEventLevel.Error;
            if (httpContext.Response.StatusCode > 399)
                return LogEventLevel.Warning;
            if (elapsed > 1000)
                return LogEventLevel.Warning;
            return LogEventLevel.Information;
        };

        // Attach additional properties to the request log
        options.EnrichDiagnosticContext = (diagnosticContext, httpContext) =>
        {
            diagnosticContext.Set("RequestHost", httpContext.Request.Host.Value);
            diagnosticContext.Set("RequestScheme", httpContext.Request.Scheme);
            diagnosticContext.Set("UserAgent", httpContext.Request.Headers["User-Agent"].ToString());
            diagnosticContext.Set("RemoteIP", httpContext.Connection.RemoteIpAddress?.ToString());
        };
    });

    // Configure the HTTP request pipeline
    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI(c =>
        {
            c.SwaggerEndpoint("/swagger/v1/swagger.json", "Debugging Demo API v1");
            c.RoutePrefix = "swagger";
        });
    }

    app.UseCors("AllowAll");
    app.UseHttpsRedirection();
    app.UseAuthorization();

    // Map health check endpoints
    app.MapHealthChecks("/health", new HealthCheckOptions
    {
        Predicate = _ => true,
        ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
    });

    app.MapHealthChecks("/health/ready", new HealthCheckOptions
    {
        Predicate = check => check.Tags.Contains("ready"),
        ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
    });

    app.MapHealthChecks("/health/live", new HealthCheckOptions
    {
        Predicate = _ => false, // No checks, just return 200
        ResponseWriter = async (context, _) =>
        {
            context.Response.ContentType = "application/json";
            await context.Response.WriteAsync("{\\"status\\": \\"Healthy\\", \\"timestamp\\": \\"" + 
                DateTime.UtcNow.ToString("O") + "\\"}");
        }
    });

    // Map health checks UI
    app.MapHealthChecksUI(options => options.UIPath = "/health-ui");

    app.MapControllers();

    // Add a root redirect to swagger
    app.MapGet("/", () => Results.Redirect("/swagger"));

    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}' \
"Complete Program.cs with exception handling, health checks, and monitoring"

    # Update appsettings.json with health check configuration
    create_file_interactive "appsettings.json" \
'{
  "Serilog": {
    "MinimumLevel": {
      "Default": "Information",
      "Override": {
        "Microsoft": "Warning",
        "Microsoft.Hosting.Lifetime": "Information",
        "Microsoft.AspNetCore": "Warning"
      }
    },
    "WriteTo": [
      {
        "Name": "Console",
        "Args": {
          "theme": "Serilog.Sinks.SystemConsole.Themes.AnsiConsoleTheme::Code, Serilog.Sinks.Console",
          "outputTemplate": "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj} {Properties:j}{NewLine}{Exception}"
        }
      },
      {
        "Name": "File",
        "Args": {
          "path": "Logs/log-.txt",
          "rollingInterval": "Day",
          "rollOnFileSizeLimit": true,
          "fileSizeLimitBytes": 10485760,
          "retainedFileCountLimit": 30,
          "outputTemplate": "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] ({SourceContext}) {Message:lj} {Properties:j}{NewLine}{Exception}"
        }
      }
    ],
    "Enrich": ["FromLogContext", "WithMachineName", "WithThreadId", "WithProcessId"]
  },
  "HealthChecksUI": {
    "HealthChecks": [
      {
        "Name": "Debugging Demo API",
        "Uri": "/health"
      }
    ],
    "Webhooks": [],
    "EvaluationTimeInSeconds": 30,
    "MinimumSecondsBetweenFailureNotifications": 60
  },
  "ExternalApi": {
    "HealthCheckUrl": "https://api.github.com/health"
  },
  "Performance": {
    "SlowRequestThresholdMs": 1000
  },
  "AllowedHosts": "*"
}' \
"Updated configuration with health check settings"

    # Create monitoring dashboard
    create_file_interactive "wwwroot/monitoring.html" \
'<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Application Monitoring Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        h1 { color: #333; text-align: center; }
        .dashboard { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
        .card { background: white; border-radius: 8px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .card h2 { margin-top: 0; color: #007bff; font-size: 1.2em; }
        .status { padding: 10px; border-radius: 4px; text-align: center; font-weight: bold; }
        .status.healthy { background-color: #d4edda; color: #155724; }
        .status.degraded { background-color: #fff3cd; color: #856404; }
        .status.unhealthy { background-color: #f8d7da; color: #721c24; }
        .metric { display: flex; justify-content: space-between; margin: 10px 0; }
        .metric-label { color: #666; }
        .metric-value { font-weight: bold; }
        button { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
        button:hover { background: #0056b3; }
        .error-test { margin-top: 20px; }
        .error-test select, .error-test input { padding: 8px; margin: 5px; }
        pre { background: #f8f9fa; padding: 10px; border-radius: 4px; overflow-x: auto; }
        .loading { color: #666; font-style: italic; }
        .error { color: #dc3545; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏥 Application Monitoring Dashboard</h1>
        
        <div class="dashboard">
            <!-- Health Status Card -->
            <div class="card">
                <h2>Health Status</h2>
                <div id="healthStatus" class="loading">Loading...</div>
                <button onclick="checkHealth()">Refresh Health</button>
            </div>

            <!-- Performance Metrics Card -->
            <div class="card">
                <h2>Performance Metrics</h2>
                <div id="performanceMetrics" class="loading">Loading...</div>
                <button onclick="testPerformance()">Run Performance Test</button>
            </div>

            <!-- Exception Testing Card -->
            <div class="card">
                <h2>Exception Testing</h2>
                <div class="error-test">
                    <select id="exceptionType">
                        <option value="argument">Argument Exception</option>
                        <option value="nullreference">Null Reference</option>
                        <option value="invalidoperation">Invalid Operation</option>
                        <option value="notfound">Not Found</option>
                        <option value="unauthorized">Unauthorized</option>
                        <option value="timeout">Timeout</option>
                        <option value="custom">Custom Exception</option>
                    </select>
                    <button onclick="testException()">Trigger Exception</button>
                </div>
                <div id="exceptionResult" style="margin-top: 10px;"></div>
            </div>

            <!-- Health Checks Detail Card -->
            <div class="card">
                <h2>Health Checks Detail</h2>
                <div id="healthDetails" class="loading">Loading...</div>
            </div>

            <!-- Recent Errors Card -->
            <div class="card">
                <h2>Recent Errors</h2>
                <div id="recentErrors">
                    <p>Check the <a href="/health-ui" target="_blank">Health UI</a> for detailed monitoring</p>
                    <p>View <a href="/Logs/" target="_blank">Log Files</a> for error details</p>
                </div>
            </div>

            <!-- System Info Card -->
            <div class="card">
                <h2>System Information</h2>
                <div id="systemInfo" class="loading">Loading...</div>
            </div>
        </div>
    </div>

    <script>
        // Auto-refresh health status
        setInterval(checkHealth, 30000);
        checkHealth();

        async function checkHealth() {
            try {
                const response = await fetch("/health");
                const data = await response.json();
                
                const healthDiv = document.getElementById("healthStatus");
                const status = data.status.toLowerCase();
                
                healthDiv.className = `status ${status}`;
                healthDiv.innerHTML = `
                    <div>Overall Status: ${data.status}</div>
                    <div>Duration: ${data.duration}</div>
                `;

                // Update health details
                const detailsDiv = document.getElementById("healthDetails");
                detailsDiv.innerHTML = data.entries.map(entry => `
                    <div class="metric">
                        <span class="metric-label">${entry.name}</span>
                        <span class="metric-value status ${entry.status.toLowerCase()}">${entry.status}</span>
                    </div>
                    ${entry.description ? `<small>${entry.description}</small>` : ""}
                `).join("");

                // Update system info from resource check
                const resourceCheck = data.entries.find(e => e.name === "resources");
                if (resourceCheck && resourceCheck.data) {
                    updateSystemInfo(resourceCheck.data);
                }
            } catch (error) {
                document.getElementById("healthStatus").innerHTML = 
                    `<div class="error">Error checking health: ${error.message}</div>`;
            }
        }

        function updateSystemInfo(data) {
            const systemDiv = document.getElementById("systemInfo");
            systemDiv.innerHTML = `
                <div class="metric">
                    <span class="metric-label">Working Set</span>
                    <span class="metric-value">${data.workingSetMB} MB</span>
                </div>
                <div class="metric">
                    <span class="metric-label">GC Memory</span>
                    <span class="metric-value">${data.gcMemoryMB} MB</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Threads</span>
                    <span class="metric-value">${data.threadCount}</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Handles</span>
                    <span class="metric-value">${data.handleCount}</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Uptime</span>
                    <span class="metric-value">${formatDuration(data.uptime)}</span>
                </div>
            `;
        }

        function formatDuration(duration) {
            const parts = duration.split(":");
            const hours = parseInt(parts[0]);
            const minutes = parseInt(parts[1]);
            return `${hours}h ${minutes}m`;
        }

        async function testException() {
            const type = document.getElementById("exceptionType").value;
            const resultDiv = document.getElementById("exceptionResult");
            
            try {
                const response = await fetch(`/api/exceptiontest/test/${type}`);
                const data = await response.json();
                
                if (!response.ok) {
                    resultDiv.innerHTML = `
                        <div class="error">
                            <strong>Error ${response.status}:</strong>
                            <pre>${JSON.stringify(data, null, 2)}</pre>
                        </div>
                    `;
                } else {
                    resultDiv.innerHTML = `<div class="status healthy">Success: ${data.message}</div>`;
                }
            } catch (error) {
                resultDiv.innerHTML = `<div class="error">Network error: ${error.message}</div>`;
            }
        }

        async function testPerformance() {
            const metricsDiv = document.getElementById("performanceMetrics");
            metricsDiv.innerHTML = "Running performance test...";
            
            try {
                // Test with different delays
                const delays = [100, 500, 1000, 2000];
                const results = [];
                
                for (const delay of delays) {
                    const start = Date.now();
                    const response = await fetch(`/api/exceptiontest/test-performance/${delay}`);
                    const totalTime = Date.now() - start;
                    const data = await response.json();
                    
                    results.push({
                        requested: delay,
                        actual: data.actualDelay,
                        total: totalTime
                    });
                }
                
                metricsDiv.innerHTML = results.map(r => `
                    <div class="metric">
                        <span class="metric-label">${r.requested}ms test</span>
                        <span class="metric-value">${r.total}ms total</span>
                    </div>
                `).join("");
            } catch (error) {
                metricsDiv.innerHTML = `<div class="error">Performance test failed: ${error.message}</div>`;
            }
        }
    </script>
</body>
</html>' \
"Monitoring dashboard for health checks and exception testing"

    # Create comprehensive exercise guide
    create_file_interactive "EXCEPTION_MONITORING_GUIDE.md" \
'# Exercise 3: Exception Handling and Monitoring

## 🎯 Objective
Create robust exception handling with monitoring capabilities, implement global exception middleware, and establish comprehensive error tracking.

## ⏱️ Time Allocation
**Total Time**: 25 minutes
- Exception Handling Setup: 10 minutes
- Health Checks Implementation: 10 minutes
- Monitoring and Testing: 5 minutes

## 🚀 Getting Started

### Step 1: Understanding Exception Handling
1. Review the `ExceptionHandlingMiddleware` implementation
2. Note RFC 7807 Problem Details compliance
3. Understand error categorization and status codes
4. Check development vs. production error details

### Step 2: Test Exception Handling
1. Run the application: `dotnet run`
2. Visit the monitoring dashboard: `http://localhost:5000/monitoring.html`
3. Test different exception types using the dashboard
4. Observe standardized error responses

### Step 3: Health Checks
1. Check overall health: `GET /health`
2. Check liveness: `GET /health/live`
3. Check readiness: `GET /health/ready`
4. View Health UI: `http://localhost:5000/health-ui`

### Step 4: Exception Testing
Test various exception scenarios:
- `GET /api/exceptiontest/test/argument`
- `GET /api/exceptiontest/test/notfound`
- `GET /api/exceptiontest/test/unauthorized`
- `GET /api/exceptiontest/test/custom`

## 📊 Exception Handling Patterns

### 1. Global Exception Handling
The middleware catches all unhandled exceptions and returns standardized responses:
```json
{
  "type": "https://httpstatuses.com/400",
  "title": "Invalid Argument",
  "status": 400,
  "detail": "Error details here",
  "instance": "/api/endpoint",
  "requestId": "0HMVFE0A0000R:00000001",
  "timestamp": "2024-01-20T10:30:00Z"
}
```

### 2. Exception to Status Code Mapping
- `ArgumentException` → 400 Bad Request
- `UnauthorizedAccessException` → 401 Unauthorized
- `KeyNotFoundException` → 404 Not Found
- `TimeoutException` → 408 Request Timeout
- Others → 500 Internal Server Error

### 3. Development vs Production
- **Development**: Full stack traces and inner exceptions
- **Production**: Generic error messages, no sensitive data

## 🏥 Health Check Implementation

### Database Health Check
- Simulates database connectivity
- Returns Healthy, Degraded, or Unhealthy status
- Includes response time metrics

### External API Health Check
- Checks external service availability
- Implements timeout handling
- Categorizes HTTP status codes

### Custom Resource Health Check
- Monitors application memory usage
- Tracks thread and handle counts
- Reports application uptime

## 🧪 Testing Exercises

### Exercise A: Exception Handling
1. Trigger each exception type via the dashboard
2. Examine the response structure
3. Check logs for exception details
4. Verify appropriate status codes

### Exercise B: Health Monitoring
1. Open the Health UI dashboard
2. Watch health status changes over time
3. Simulate failures (database check has 10% failure rate)
4. Observe degraded states

### Exercise C: Performance Impact
1. Test performance endpoint with various delays
2. Check response headers for timing information
3. Monitor logs for slow request warnings
4. Correlate with health check data

### Exercise D: Custom Exceptions
1. Create a validation error: `POST /api/exceptiontest/test-validation`
2. Send invalid JSON to see parsing errors
3. Test nested exceptions
4. Implement your own custom exception type

## 📈 Monitoring Best Practices

### 1. Health Check Design
- **Liveness**: Is the application running?
- **Readiness**: Is the application ready to serve requests?
- **Deep checks**: Are all dependencies healthy?

### 2. Exception Tracking
- Log all exceptions with context
- Track exception rates and types
- Monitor for exception patterns
- Set up alerts for critical errors

### 3. Performance Monitoring
- Track request duration
- Monitor resource usage
- Identify performance bottlenecks
- Set performance budgets

## 🛠️ Production Considerations

### 1. Security
- Never expose sensitive data in error responses
- Sanitize error messages
- Log security-related exceptions
- Implement rate limiting for error endpoints

### 2. Reliability
- Implement circuit breakers for external services
- Add retry policies with exponential backoff
- Use health checks for load balancer integration
- Implement graceful degradation

### 3. Observability
- Correlation IDs for request tracking
- Structured logging for analysis
- Metrics for monitoring
- Distributed tracing for microservices

## ✅ Success Criteria
- [ ] Global exception handling returns RFC 7807 compliant responses
- [ ] Different exception types map to appropriate status codes
- [ ] Health checks accurately report system status
- [ ] Monitoring dashboard shows real-time health
- [ ] Errors are properly logged with context
- [ ] Performance metrics are tracked
- [ ] Production error responses dont leak sensitive data

## 🔄 Complete Module Checklist
- [ ] Debugging environment is properly configured (Exercise 1)
- [ ] Structured logging captures all relevant data (Exercise 2)
- [ ] Exception handling provides useful error responses (Exercise 3)
- [ ] Health checks monitor critical dependencies
- [ ] Performance is tracked and optimized
- [ ] Monitoring tools are in place

## 💡 Pro Tips
1. **Always log before throwing**: Capture context at the source
2. **Use correlation IDs**: Track requests across services
3. **Monitor trends**: Look for patterns, not just individual errors
4. **Test failure scenarios**: Ensure graceful degradation
5. **Document error codes**: Help users understand and resolve issues
6. **Set up alerts**: Dont wait for users to report problems
7. **Practice chaos engineering**: Test your error handling

## 🎉 Congratulations!
You have completed Module 6 on Debugging and Troubleshooting! You now have:
- A robust debugging environment
- Comprehensive structured logging
- Professional exception handling
- Health monitoring capabilities
- Performance tracking tools

These skills are essential for maintaining production applications and quickly diagnosing issues when they occur.
' \
"Comprehensive guide for exception handling and monitoring exercise"

    echo -e "${GREEN}🎉 Exercise 3 template created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Run: ${CYAN}dotnet build${NC}"
    echo "2. Run: ${CYAN}dotnet run${NC}"
    echo "3. Visit: ${CYAN}http://localhost:5000/monitoring.html${NC} for the monitoring dashboard"
    echo "4. Visit: ${CYAN}http://localhost:5000/health-ui${NC} for health check UI"
    echo "5. Visit: ${CYAN}http://localhost:5000/swagger${NC} for API testing"
    echo "6. Follow the EXCEPTION_MONITORING_GUIDE.md for exercises"

fi

echo ""
echo -e "${GREEN}✅ Module 6 Exercise Setup Complete!${NC}"
echo -e "${CYAN}Happy debugging! 🐛🔍${NC}"
