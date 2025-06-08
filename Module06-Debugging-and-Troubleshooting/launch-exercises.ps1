# Module 6 Interactive Exercise Launcher - PowerShell Version
# Debugging and Troubleshooting

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

# Set error action preference
$ErrorActionPreference = "Stop"

# Interactive mode flag
$InteractiveMode = -not $Auto

# Function to pause and wait for user
function Wait-ForUser {
    if ($InteractiveMode) {
        Write-Host "Press Enter to continue..." -ForegroundColor Yellow
        Read-Host
    }
}

# Function to show what will be created
function Show-FilePreview {
    param(
        [string]$FilePath,
        [string]$Description
    )
    
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "[FILE] Will create: $FilePath" -ForegroundColor Blue
    Write-Host "[PURPOSE] Purpose: $Description" -ForegroundColor Yellow
    Write-Host "============================================================" -ForegroundColor Cyan
}

# Function to create file with preview
function New-FileInteractive {
    param(
        [string]$FilePath,
        [string]$Content,
        [string]$Description
    )
    
    Show-FilePreview -FilePath $FilePath -Description $Description
    
    # Show first 20 lines of content
    Write-Host "Content preview:" -ForegroundColor Green
    $ContentLines = $Content -split "`n"
    $PreviewLines = $ContentLines | Select-Object -First 20
    $PreviewLines | ForEach-Object { Write-Host $_ }
    
    if ($ContentLines.Count -gt 20) {
        Write-Host "... (content truncated for preview)" -ForegroundColor Yellow
    }
    Write-Host ""
    
    if ($InteractiveMode) {
        $Response = Read-Host "Create this file? (Y/n/s to skip all)"
        
        switch ($Response.ToLower()) {
            "n" {
                Write-Host "[SKIP]  Skipped: $FilePath" -ForegroundColor Red
                return
            }
            "s" {
                $script:InteractiveMode = $false
                Write-Host "[PIN] Switching to automatic mode..." -ForegroundColor Cyan
            }
        }
    }
    
    # Create directory if it doesn't exist
    $Directory = Split-Path -Path $FilePath -Parent
    if ($Directory -and -not (Test-Path -Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    
    # Write content to file
    $Content | Out-File -FilePath $FilePath -Encoding UTF8
    Write-Host "[OK] Created: $FilePath" -ForegroundColor Green
    Write-Host ""
}

# Function to show learning objectives
function Show-LearningObjectives {
    param([string]$Exercise)
    
    Write-Host "============================================================" -ForegroundColor Magenta
    Write-Host "[TARGET] Learning Objectives" -ForegroundColor Magenta
    Write-Host "============================================================" -ForegroundColor Magenta
    
    switch ($Exercise) {
        "exercise01" {
            Write-Host "In this exercise, you will learn:" -ForegroundColor Cyan
            Write-Host "  [BUG] 1. Setting up debugging environments in VS Code and Visual Studio" -ForegroundColor White
            Write-Host "  [BUG] 2. Using breakpoints, watch windows, and call stack analysis" -ForegroundColor White
            Write-Host "  [BUG] 3. Hot Reload and Edit and Continue features" -ForegroundColor White
            Write-Host "  [BUG] 4. Debugging ASP.NET Core applications effectively" -ForegroundColor White
            Write-Host ""
            Write-Host "Key debugging skills:" -ForegroundColor Yellow
            Write-Host "  - Conditional and function breakpoints" -ForegroundColor White
            Write-Host "  - Variable inspection and modification" -ForegroundColor White
            Write-Host "  - Step-through debugging techniques" -ForegroundColor White
            Write-Host "  - Exception handling during debugging" -ForegroundColor White
        }
        "exercise02" {
            Write-Host "Building on Exercise 1, you will add:" -ForegroundColor Cyan
            Write-Host "  [CHART] 1. Structured logging with Serilog" -ForegroundColor White
            Write-Host "  [CHART] 2. Multiple logging providers (Console, File, Database)" -ForegroundColor White
            Write-Host "  [CHART] 3. Log levels and filtering strategies" -ForegroundColor White
            Write-Host "  [CHART] 4. Performance logging and monitoring" -ForegroundColor White
            Write-Host ""
            Write-Host "Logging concepts:" -ForegroundColor Yellow
            Write-Host "  - Structured vs unstructured logging" -ForegroundColor White
            Write-Host "  - Log correlation and context" -ForegroundColor White
            Write-Host "  - Log aggregation and analysis" -ForegroundColor White
            Write-Host "  - Production logging best practices" -ForegroundColor White
        }
        "exercise03" {
            Write-Host "Advanced debugging and monitoring:" -ForegroundColor Cyan
            Write-Host "  [ALERT] 1. Global exception handling middleware" -ForegroundColor White
            Write-Host "  [ALERT] 2. Health checks for dependencies" -ForegroundColor White
            Write-Host "  [ALERT] 3. Application performance monitoring" -ForegroundColor White
            Write-Host "  [ALERT] 4. Custom diagnostic middleware" -ForegroundColor White
            Write-Host ""
            Write-Host "Production concepts:" -ForegroundColor Yellow
            Write-Host "  - Exception handling strategies" -ForegroundColor White
            Write-Host "  - Health check patterns" -ForegroundColor White
            Write-Host "  - Performance metrics collection" -ForegroundColor White
            Write-Host "  - Monitoring and alerting" -ForegroundColor White
        }
    }
    
    Write-Host "============================================================" -ForegroundColor Magenta
    Wait-ForUser
}

# Function to show what will be created overview
function Show-CreationOverview {
    param([string]$Exercise)
    
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "[OVERVIEW] Overview: What will be created" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    
    switch ($Exercise) {
        "exercise01" {
            Write-Host "[TARGET] Exercise 01: Debugging Fundamentals" -ForegroundColor Green
            Write-Host ""
            Write-Host "[OVERVIEW] What you'll build:" -ForegroundColor Yellow
            Write-Host "  [OK] Debugging-ready ASP.NET Core application" -ForegroundColor White
            Write-Host "  [OK] Sample controllers with intentional bugs to fix" -ForegroundColor White
            Write-Host "  [OK] Debug configuration and launch settings" -ForegroundColor White
            Write-Host "  [OK] Comprehensive debugging examples" -ForegroundColor White
            Write-Host ""
            Write-Host "[LAUNCH] RECOMMENDED: Use the Complete Working Example" -ForegroundColor Blue
            Write-Host "  Set-Location SourceCode\DebuggingDemo; dotnet run" -ForegroundColor Cyan
            Write-Host "  Then visit: http://localhost:5000 for the debugging interface" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "📁 Template Structure:" -ForegroundColor Green
            Write-Host "  DebuggingDemo/" -ForegroundColor White
            Write-Host "  ├── Controllers/" -ForegroundColor White
            Write-Host "  │   ├── TestController.cs       # Sample controller with bugs" -ForegroundColor Yellow
            Write-Host "  │   └── DiagnosticsController.cs # Debugging utilities" -ForegroundColor Yellow
            Write-Host "  ├── Models/" -ForegroundColor White
            Write-Host "  │   └── DiagnosticModels.cs     # Debug data models" -ForegroundColor Yellow
            Write-Host "  ├── .vscode/" -ForegroundColor White
            Write-Host "  │   └── launch.json             # VS Code debug config" -ForegroundColor Yellow
            Write-Host "  ├── Properties/" -ForegroundColor White
            Write-Host "  │   └── launchSettings.json     # Debug launch settings" -ForegroundColor Yellow
            Write-Host "  └── Program.cs                  # App configuration" -ForegroundColor Yellow
        }
        "exercise02" {
            Write-Host "[TARGET] Exercise 02: Comprehensive Logging Implementation" -ForegroundColor Green
            Write-Host ""
            Write-Host "[OVERVIEW] Building on Exercise 1:" -ForegroundColor Yellow
            Write-Host "  [OK] Serilog integration with multiple sinks" -ForegroundColor White
            Write-Host "  [OK] Structured logging with correlation IDs" -ForegroundColor White
            Write-Host "  [OK] Performance logging middleware" -ForegroundColor White
            Write-Host "  [OK] Log filtering and configuration" -ForegroundColor White
        }
        "exercise03" {
            Write-Host "[TARGET] Exercise 03: Exception Handling and Monitoring" -ForegroundColor Green
            Write-Host ""
            Write-Host "[OVERVIEW] Production-ready features:" -ForegroundColor Yellow
            Write-Host "  [OK] Global exception handling middleware" -ForegroundColor White
            Write-Host "  [OK] Health checks for dependencies" -ForegroundColor White
            Write-Host "  [OK] Custom error responses and monitoring" -ForegroundColor White
            Write-Host "  [OK] Application performance metrics" -ForegroundColor White
        }
    }
    
    Write-Host "============================================================" -ForegroundColor Cyan
    Wait-ForUser
}

# Function to explain a concept
function Show-Concept {
    param(
        [string]$ConceptName,
        [string]$Explanation
    )
    
    Write-Host "[TIP] Concept: $ConceptName" -ForegroundColor Magenta
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host $Explanation -ForegroundColor White
    Write-Host "============================================================" -ForegroundColor Cyan
    Wait-ForUser
}

# Function to show available exercises
function Show-Exercises {
    Write-Host "Module 6 - Debugging and Troubleshooting" -ForegroundColor Cyan
    Write-Host "Available Exercises:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  - exercise01: Debugging Fundamentals" -ForegroundColor White
    Write-Host "  - exercise02: Comprehensive Logging Implementation" -ForegroundColor White
    Write-Host "  - exercise03: Exception Handling and Monitoring" -ForegroundColor White
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor White
    Write-Host "  .\launch-exercises.ps1 <exercise-name> [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  -List           Show all available exercises" -ForegroundColor White
    Write-Host "  -Auto           Skip interactive mode" -ForegroundColor White
    Write-Host "  -Preview        Show what will be created without creating" -ForegroundColor White
}

# Main script logic
if ($List) {
    Show-Exercises
    exit 0
}

if (-not $ExerciseName) {
    Write-Host "[ERROR] Usage: .\launch-exercises.ps1 <exercise-name> [options]" -ForegroundColor Red
    Write-Host ""
    Show-Exercises
    exit 1
}

$ProjectName = "DebuggingDemo"

# Validate exercise name
$ValidExercises = @("exercise01", "exercise02", "exercise03")
if ($ExerciseName -notin $ValidExercises) {
    Write-Host "[ERROR] Unknown exercise: $ExerciseName" -ForegroundColor Red
    Write-Host ""
    Show-Exercises
    exit 1
}

# Welcome screen
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "[LAUNCH] Module 6: Debugging and Troubleshooting" -ForegroundColor Magenta
Write-Host "Exercise: $ExerciseName" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host ""

# Show the recommended approach
Write-Host "[TARGET] RECOMMENDED APPROACH:" -ForegroundColor Green
Write-Host "For the best learning experience, use the complete working implementation:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Use the working source code:" -ForegroundColor Yellow
Write-Host "   Set-Location SourceCode\DebuggingDemo" -ForegroundColor Cyan
Write-Host "   dotnet run" -ForegroundColor Cyan
Write-Host "   # Visit: http://localhost:5000 for the debugging interface" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Or use Docker for complete setup:" -ForegroundColor Yellow
Write-Host "   Set-Location SourceCode" -ForegroundColor Cyan
Write-Host "   docker-compose up --build" -ForegroundColor Cyan
Write-Host "   # Includes logging aggregation and monitoring" -ForegroundColor Cyan
Write-Host ""
Write-Host "[WARNING]  The template created by this script is basic and may not match" -ForegroundColor Yellow
Write-Host "   all exercise requirements. The SourceCode version is complete!" -ForegroundColor Yellow
Write-Host ""

if ($InteractiveMode) {
    Write-Host "[INTERACTIVE] Interactive Mode: ON" -ForegroundColor Yellow
    Write-Host "You'll see what each file does before it's created" -ForegroundColor Cyan
} else {
    Write-Host "[AUTO] Automatic Mode: ON" -ForegroundColor Yellow
}

Write-Host ""
$Response = Read-Host "Continue with template creation? (y/N)"
if ($Response -notmatch "^[Yy]$") {
    Write-Host "[TIP] Great choice! Use the SourceCode version for the best experience." -ForegroundColor Cyan
    exit 0
}

# Show learning objectives
Show-LearningObjectives -Exercise $ExerciseName

# Show creation overview
Show-CreationOverview -Exercise $ExerciseName

if ($Preview) {
    Write-Host "[PREVIEW] Preview mode - no files will be created" -ForegroundColor Yellow
    exit 0
}

# Check if project exists in current directory
$SkipProjectCreation = $false
if (Test-Path $ProjectName) {
    if ($ExerciseName -eq "exercise02" -or $ExerciseName -eq "exercise03") {
        Write-Host "[OK] Found existing $ProjectName from previous exercise" -ForegroundColor Green
        Write-Host "[BUILD] This exercise will build on your existing work" -ForegroundColor Cyan
        Set-Location $ProjectName
        $SkipProjectCreation = $true
    } else {
        Write-Host "[WARNING] Project '$ProjectName' already exists!" -ForegroundColor Yellow
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

# Exercise-specific implementation
switch ($ExerciseName) {
    "exercise01" {
        # Exercise 1: Debugging Fundamentals

        Show-Concept -ConceptName "Debugging in ASP.NET Core" -Explanation @"
Effective debugging is crucial for development:
• Breakpoints: Pause execution to inspect state
• Watch windows: Monitor variable values in real-time
• Call stack: Understand the execution path
• Hot Reload: Make changes without restarting
• Exception handling: Catch and analyze errors
"@

        if (-not $SkipProjectCreation) {
            Write-Host "[CREATE] Creating new Web API project for debugging..." -ForegroundColor Cyan
            dotnet new webapi -n $ProjectName --framework net8.0
            Set-Location $ProjectName
            Remove-Item -Path "WeatherForecast.cs" -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "Controllers/WeatherForecastController.cs" -Force -ErrorAction SilentlyContinue

            # Update Program.cs with debugging-friendly configuration
            New-FileInteractive -FilePath "Program.cs" -Description "Program.cs with debugging-friendly configuration" -Content @'
using Microsoft.AspNetCore.Diagnostics;

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

app.Run();
'@
        }

        Show-Concept -ConceptName "Debugging Models and Test Data" -Explanation @"
Creating models for debugging practice:
• Simple data structures to inspect during debugging
• Properties with different data types
• Methods that can be stepped through
• Intentional bugs to practice fixing
"@

        # Create debugging models
        New-FileInteractive -FilePath "Models/DiagnosticModels.cs" -Description "Diagnostic models with intentional bugs for debugging practice" -Content @'
namespace DebuggingDemo.Models;

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
}
'@

        Show-Concept -ConceptName "Debugging Controllers" -Explanation @"
Controllers with debugging scenarios:
• Breakpoint placement strategies
• Variable inspection techniques
• Exception handling and debugging
• Step-through debugging practice
"@

        # Create test controller with debugging scenarios
        New-FileInteractive -FilePath "Controllers/TestController.cs" -Description "Test controller with various debugging scenarios and intentional bugs" -Content @'
using Microsoft.AspNetCore.Mvc;
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
}
'@

        # Create VS Code debug configuration
        New-FileInteractive -FilePath ".vscode/launch.json" -Description "VS Code debug configuration for ASP.NET Core" -Content @'
{
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
}
'@

        # Create tasks.json for VS Code
        New-FileInteractive -FilePath ".vscode/tasks.json" -Description "VS Code tasks configuration for building and running" -Content @'
{
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
}
'@

        # Create exercise guide
        New-FileInteractive -FilePath "DEBUGGING_GUIDE.md" -Description "Complete debugging exercise guide with step-by-step instructions" -Content @'
# Exercise 1: Debugging Fundamentals

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
4. Examine the exception details in the debugger

### Step 5: Performance Debugging
1. Set breakpoints in `SlowOperation()` method
2. Use the stopwatch to measure execution time
3. Practice stepping through async operations
4. Monitor memory usage during execution

## 🔧 Debugging Techniques to Practice

### Breakpoint Types
- **Line Breakpoints**: Basic pause points
- **Conditional Breakpoints**: Break only when condition is true
- **Function Breakpoints**: Break when entering specific methods
- **Exception Breakpoints**: Break when exceptions are thrown

### Variable Inspection
- **Locals Window**: View local variables
- **Watch Window**: Monitor specific expressions
- **Call Stack**: Understand execution flow
- **Immediate Window**: Execute code during debugging

### Advanced Features
- **Hot Reload**: Make changes without restarting
- **Edit and Continue**: Modify code during debugging
- **Step Into/Over/Out**: Control execution flow
- **Run to Cursor**: Execute until specific line

## 📝 Exercise Tasks

### Task 1: Find the Display Name Bug
1. Set breakpoint in `User.GetDisplayName()`
2. Create a user and call the method
3. Identify why the display format might be incorrect
4. Fix the formatting issue

### Task 2: Debug Order Calculation
1. Set breakpoint in `Order.CalculateTotal()`
2. Create an order with multiple items
3. Step through the calculation loop
4. Verify the total calculation is correct

### Task 3: Exception Handling
1. Try to create a user with null/empty name
2. Debug the exception handling flow
3. Examine the exception details
4. Test the error response

### Task 4: Performance Analysis
1. Debug the slow operation endpoint
2. Measure execution time using the stopwatch
3. Identify potential performance bottlenecks
4. Practice debugging async operations

## 🎯 Learning Outcomes
After completing this exercise, you should be able to:
- Set up debugging environments in VS Code and Visual Studio
- Use various types of breakpoints effectively
- Inspect variables and execution state
- Debug exceptions and error conditions
- Analyze performance issues
- Use advanced debugging features like Hot Reload

## 🚀 Next Steps
- Move to Exercise 2 for logging implementation
- Practice debugging in different scenarios
- Explore production debugging techniques
'@

        Write-Host "[OK] Exercise 1 setup complete!" -ForegroundColor Green
        Write-Host ""
        Write-Host "[NEXT] To run the application:" -ForegroundColor Yellow
        Write-Host "1. dotnet run" -ForegroundColor Cyan
        Write-Host "2. Open browser to: http://localhost:5000/swagger" -ForegroundColor Cyan
        Write-Host "3. Start debugging with F5 in VS Code" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "[TARGET] Available debugging endpoints:" -ForegroundColor Blue
        Write-Host "  GET    /api/test/users       - Get all users" -ForegroundColor White
        Write-Host "  GET    /api/test/users/{id}  - Get user by ID" -ForegroundColor White
        Write-Host "  POST   /api/test/users       - Create new user" -ForegroundColor White
        Write-Host "  POST   /api/test/orders/calculate - Calculate order total" -ForegroundColor White
        Write-Host "  GET    /api/test/slow-operation   - Simulate slow operation" -ForegroundColor White
        Write-Host ""
        Write-Host "[TIP] Check DEBUGGING_GUIDE.md for detailed instructions!" -ForegroundColor Green
    }

    "exercise02" {
        Write-Host "[INFO] Exercise 2: Comprehensive Logging Implementation" -ForegroundColor Green
        Write-Host "[INFO] This exercise builds on Exercise 1" -ForegroundColor Yellow
        Write-Host "[INFO] Please run Exercise 1 first, then use the SourceCode version for complete logging features" -ForegroundColor Cyan
    }

    "exercise03" {
        Write-Host "[INFO] Exercise 3: Exception Handling and Monitoring" -ForegroundColor Green
        Write-Host "[INFO] This exercise builds on previous exercises" -ForegroundColor Yellow
        Write-Host "[INFO] Please run previous exercises first, then use the SourceCode version for complete features" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "[COMPLETE] Module 6 Exercise setup complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "[NEXT] Next Steps:" -ForegroundColor Yellow
Write-Host "1. Review the created files and understand their purpose" -ForegroundColor White
Write-Host "2. Start debugging using the provided configuration" -ForegroundColor White
Write-Host "3. Practice with the debugging scenarios in the controllers" -ForegroundColor White
Write-Host "4. Use the SourceCode version for complete implementations" -ForegroundColor White
Write-Host ""
Write-Host "[TIP] Happy debugging! 🐛" -ForegroundColor Cyan
