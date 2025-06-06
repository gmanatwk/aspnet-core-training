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
    echo -e "${CYAN}Exercise 2 implementation would be added here...${NC}"
    echo -e "${YELLOW}This exercise adds comprehensive logging with Serilog${NC}"

elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    echo -e "${CYAN}Exercise 3 implementation would be added here...${NC}"
    echo -e "${YELLOW}This exercise implements exception handling and monitoring${NC}"

fi

echo ""
echo -e "${GREEN}✅ Module 6 Exercise Setup Complete!${NC}"
echo -e "${CYAN}Happy debugging! 🐛🔍${NC}"
