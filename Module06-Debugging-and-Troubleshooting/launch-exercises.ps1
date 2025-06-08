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
        # Exercise 2: Comprehensive Logging Implementation

        Show-Concept -ConceptName "Structured Logging with Serilog" -Explanation @"
Modern logging requires more than simple text messages:
• Structured data: Log events as structured data, not just strings
• Multiple sinks: Write logs to console, files, databases simultaneously
• Log enrichment: Add contextual information automatically
• Performance: Asynchronous logging for high throughput
• Filtering: Different log levels for different components
"@

        if (-not $SkipProjectCreation) {
            Write-Host "[ERROR] Exercise 2 requires Exercise 1 to be completed first" -ForegroundColor Red
            Write-Host "[INFO] Please run: .\launch-exercises.ps1 exercise01" -ForegroundColor Yellow
            exit 1
        }

        Write-Host "[CLEAN] Cleaning up any existing files..." -ForegroundColor Cyan
        Remove-Item -Path "Extensions/LoggingExtensions.cs" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "Middleware/RequestLoggingMiddleware.cs" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "Middleware/PerformanceMiddleware.cs" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "Controllers/LoggingTestController.cs" -Force -ErrorAction SilentlyContinue

        Write-Host "[PACKAGE] Adding Serilog packages..." -ForegroundColor Cyan
        dotnet add package Serilog.AspNetCore --version 8.0.3
        dotnet add package Serilog.Sinks.Console --version 6.0.0
        dotnet add package Serilog.Sinks.File --version 6.0.0
        dotnet add package Serilog.Enrichers.Environment --version 3.0.1
        dotnet add package Serilog.Enrichers.Thread --version 4.0.0
        dotnet add package Serilog.Settings.Configuration --version 8.0.4

        # Update appsettings.json with Serilog configuration
        New-FileInteractive -FilePath "appsettings.json" -Description "Serilog configuration with console and file sinks" -Content @'
{
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
}
'@

        # Update Program.cs with Serilog
        New-FileInteractive -FilePath "Program.cs" -Description "Program.cs with comprehensive Serilog configuration" -Content @'
using Serilog;
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
}
'@

        # Create logging extensions
        New-FileInteractive -FilePath "Extensions/LoggingExtensions.cs" -Description "Logging extension methods for structured logging patterns" -Content @'
using Serilog;
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
}
'@

        # Create middleware for request/response logging
        New-FileInteractive -FilePath "Middleware/RequestLoggingMiddleware.cs" -Description "Request/response logging middleware for detailed HTTP logging" -Content @'
using System.Diagnostics;
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
}
'@

        # Create performance logging middleware
        New-FileInteractive -FilePath "Middleware/PerformanceMiddleware.cs" -Description "Performance monitoring middleware to track slow requests" -Content @'
using System.Diagnostics;
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
}
'@

        # Create logging test controller
        New-FileInteractive -FilePath "Controllers/LoggingTestController.cs" -Description "Controller demonstrating various logging patterns and best practices" -Content @'
using Microsoft.AspNetCore.Mvc;
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
}
'@

        Write-Host "[OK] Exercise 2 template created successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "[NEXT] Next steps:" -ForegroundColor Yellow
        Write-Host "1. Build the project: dotnet build" -ForegroundColor Cyan
        Write-Host "2. Run the application: dotnet run" -ForegroundColor Cyan
        Write-Host "3. Visit: http://localhost:5000/swagger" -ForegroundColor Cyan
        Write-Host "4. Check the Logs/ directory for log files" -ForegroundColor Cyan
        Write-Host "5. Test different log levels and structured logging" -ForegroundColor Cyan
    }

    "exercise03" {
        # Exercise 3: Exception Handling and Monitoring

        Show-Concept -ConceptName "Production-Ready Exception Handling" -Explanation @"
Production applications need robust error handling:
• Global exception middleware: Catch all unhandled exceptions
• Structured error responses: Consistent error format (RFC 7807)
• Health checks: Monitor application and dependency health
• Performance monitoring: Track application metrics
• Diagnostic endpoints: Custom troubleshooting tools
"@

        if (-not $SkipProjectCreation) {
            Write-Host "[ERROR] Exercise 3 requires previous exercises to be completed first" -ForegroundColor Red
            Write-Host "[INFO] Please run exercises 1 and 2 first" -ForegroundColor Yellow
            exit 1
        }

        Write-Host "[CLEAN] Cleaning up any existing files..." -ForegroundColor Cyan
        Remove-Item -Path "Middleware/ExceptionHandlingMiddleware.cs" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "Services/HealthChecks" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "Models/ErrorResponse.cs" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "Controllers/HealthController.cs" -Force -ErrorAction SilentlyContinue

        Write-Host "[PACKAGE] Adding health check packages..." -ForegroundColor Cyan
        dotnet add package Microsoft.AspNetCore.Diagnostics.HealthChecks --version 2.2.0
        dotnet add package Microsoft.Extensions.Diagnostics.HealthChecks --version 8.0.11

        # Create global exception handling middleware
        New-FileInteractive -FilePath "Middleware/ExceptionHandlingMiddleware.cs" -Description "Global exception handling middleware with structured error responses" -Content @'
using System.Net;
using System.Text.Json;
using DebuggingDemo.Models;

namespace DebuggingDemo.Middleware;

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;
    private readonly IWebHostEnvironment _environment;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger, IWebHostEnvironment environment)
    {
        _next = next;
        _logger = logger;
        _environment = environment;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An unhandled exception occurred. RequestId: {RequestId}", context.TraceIdentifier);
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/json";

        var errorResponse = new ErrorResponse
        {
            RequestId = context.TraceIdentifier,
            Timestamp = DateTime.UtcNow
        };

        switch (exception)
        {
            case ArgumentException argEx:
                context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                errorResponse.Title = "Bad Request";
                errorResponse.Detail = argEx.Message;
                errorResponse.Type = "https://tools.ietf.org/html/rfc7231#section-6.5.1";
                break;

            case UnauthorizedAccessException:
                context.Response.StatusCode = (int)HttpStatusCode.Unauthorized;
                errorResponse.Title = "Unauthorized";
                errorResponse.Detail = "Access denied";
                errorResponse.Type = "https://tools.ietf.org/html/rfc7235#section-3.1";
                break;

            case KeyNotFoundException:
                context.Response.StatusCode = (int)HttpStatusCode.NotFound;
                errorResponse.Title = "Not Found";
                errorResponse.Detail = exception.Message;
                errorResponse.Type = "https://tools.ietf.org/html/rfc7231#section-6.5.4";
                break;

            default:
                context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                errorResponse.Title = "Internal Server Error";
                errorResponse.Detail = _environment.IsDevelopment() ? exception.Message : "An error occurred while processing your request";
                errorResponse.Type = "https://tools.ietf.org/html/rfc7231#section-6.6.1";
                break;
        }

        errorResponse.Status = context.Response.StatusCode;

        // Add stack trace in development
        if (_environment.IsDevelopment())
        {
            errorResponse.Extensions = new Dictionary<string, object>
            {
                ["stackTrace"] = exception.StackTrace ?? string.Empty,
                ["innerException"] = exception.InnerException?.Message ?? string.Empty
            };
        }

        var jsonResponse = JsonSerializer.Serialize(errorResponse, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        });

        await context.Response.WriteAsync(jsonResponse);
    }
}

public static class ExceptionHandlingMiddlewareExtensions
{
    public static IApplicationBuilder UseGlobalExceptionHandling(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<ExceptionHandlingMiddleware>();
    }
}
'@

        # Create error response model
        New-FileInteractive -FilePath "Models/ErrorResponse.cs" -Description "RFC 7807 compliant error response model" -Content @'
namespace DebuggingDemo.Models;

/// <summary>
/// RFC 7807 Problem Details for HTTP APIs
/// </summary>
public class ErrorResponse
{
    /// <summary>
    /// A URI reference that identifies the problem type
    /// </summary>
    public string Type { get; set; } = string.Empty;

    /// <summary>
    /// A short, human-readable summary of the problem type
    /// </summary>
    public string Title { get; set; } = string.Empty;

    /// <summary>
    /// The HTTP status code
    /// </summary>
    public int Status { get; set; }

    /// <summary>
    /// A human-readable explanation specific to this occurrence of the problem
    /// </summary>
    public string Detail { get; set; } = string.Empty;

    /// <summary>
    /// A URI reference that identifies the specific occurrence of the problem
    /// </summary>
    public string Instance { get; set; } = string.Empty;

    /// <summary>
    /// Unique request identifier for tracking
    /// </summary>
    public string RequestId { get; set; } = string.Empty;

    /// <summary>
    /// Timestamp when the error occurred
    /// </summary>
    public DateTime Timestamp { get; set; }

    /// <summary>
    /// Additional properties for debugging (development only)
    /// </summary>
    public Dictionary<string, object>? Extensions { get; set; }
}
'@

        # Create database health check
        New-FileInteractive -FilePath "Services/HealthChecks/DatabaseHealthCheck.cs" -Description "Database connectivity health check" -Content @'
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace DebuggingDemo.Services.HealthChecks;

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

            // In a real application, you would check actual database connectivity
            // Example: await _context.Database.CanConnectAsync(cancellationToken);

            var isHealthy = DateTime.UtcNow.Second % 10 != 0; // Simulate occasional failure

            if (isHealthy)
            {
                _logger.LogInformation("Database health check passed");
                return HealthCheckResult.Healthy("Database connection is healthy", new Dictionary<string, object>
                {
                    ["server"] = "localhost",
                    ["database"] = "DebuggingDemo",
                    ["responseTime"] = "100ms"
                });
            }
            else
            {
                _logger.LogWarning("Database health check failed");
                return HealthCheckResult.Unhealthy("Database connection failed", null, new Dictionary<string, object>
                {
                    ["server"] = "localhost",
                    ["database"] = "DebuggingDemo",
                    ["error"] = "Connection timeout"
                });
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Database health check threw an exception");
            return HealthCheckResult.Unhealthy("Database health check failed with exception", ex);
        }
    }
}
'@

        # Create external API health check
        New-FileInteractive -FilePath "Services/HealthChecks/ExternalApiHealthCheck.cs" -Description "External API dependency health check" -Content @'
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace DebuggingDemo.Services.HealthChecks;

public class ExternalApiHealthCheck : IHealthCheck
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<ExternalApiHealthCheck> _logger;
    private readonly string _apiUrl;

    public ExternalApiHealthCheck(HttpClient httpClient, ILogger<ExternalApiHealthCheck> logger, IConfiguration configuration)
    {
        _httpClient = httpClient;
        _logger = logger;
        _apiUrl = configuration.GetValue<string>("ExternalApi:HealthCheckUrl") ?? "https://httpbin.org/status/200";
    }

    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Checking external API health at {ApiUrl}", _apiUrl);

            var stopwatch = System.Diagnostics.Stopwatch.StartNew();
            var response = await _httpClient.GetAsync(_apiUrl, cancellationToken);
            stopwatch.Stop();

            if (response.IsSuccessStatusCode)
            {
                _logger.LogInformation("External API health check passed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
                return HealthCheckResult.Healthy("External API is responding", new Dictionary<string, object>
                {
                    ["url"] = _apiUrl,
                    ["statusCode"] = (int)response.StatusCode,
                    ["responseTime"] = $"{stopwatch.ElapsedMilliseconds}ms"
                });
            }
            else
            {
                _logger.LogWarning("External API health check failed with status {StatusCode}", response.StatusCode);
                return HealthCheckResult.Unhealthy($"External API returned {response.StatusCode}", null, new Dictionary<string, object>
                {
                    ["url"] = _apiUrl,
                    ["statusCode"] = (int)response.StatusCode,
                    ["responseTime"] = $"{stopwatch.ElapsedMilliseconds}ms"
                });
            }
        }
        catch (TaskCanceledException)
        {
            _logger.LogWarning("External API health check timed out");
            return HealthCheckResult.Unhealthy("External API health check timed out");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "External API health check failed with exception");
            return HealthCheckResult.Unhealthy("External API health check failed", ex);
        }
    }
}
'@

        # Create custom health check
        New-FileInteractive -FilePath "Services/HealthChecks/CustomHealthCheck.cs" -Description "Custom application health check for resource monitoring" -Content @'
using Microsoft.Extensions.Diagnostics.HealthChecks;
using System.Diagnostics;

namespace DebuggingDemo.Services.HealthChecks;

public class CustomHealthCheck : IHealthCheck
{
    private readonly ILogger<CustomHealthCheck> _logger;
    private static readonly Process CurrentProcess = Process.GetCurrentProcess();

    public CustomHealthCheck(ILogger<CustomHealthCheck> logger)
    {
        _logger = logger;
    }

    public Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
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
}
'@

        # Create health controller
        New-FileInteractive -FilePath "Controllers/HealthController.cs" -Description "Health check endpoints for monitoring" -Content @'
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Diagnostics.HealthChecks;

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
        var healthReport = await _healthCheckService.CheckHealthAsync();

        var response = new
        {
            Status = healthReport.Status.ToString(),
            TotalDuration = healthReport.TotalDuration.TotalMilliseconds,
            Entries = healthReport.Entries.Select(entry => new
            {
                Name = entry.Key,
                Status = entry.Value.Status.ToString(),
                Duration = entry.Value.Duration.TotalMilliseconds,
                Description = entry.Value.Description,
                Data = entry.Value.Data,
                Exception = entry.Value.Exception?.Message
            })
        };

        var statusCode = healthReport.Status == HealthStatus.Healthy ? 200 : 503;
        return StatusCode(statusCode, response);
    }

    /// <summary>
    /// Get detailed health information
    /// </summary>
    [HttpGet("detailed")]
    public async Task<IActionResult> GetDetailedHealth()
    {
        var healthReport = await _healthCheckService.CheckHealthAsync();

        _logger.LogInformation("Health check requested - Overall status: {Status}", healthReport.Status);

        var response = new
        {
            Status = healthReport.Status.ToString(),
            TotalDuration = $"{healthReport.TotalDuration.TotalMilliseconds}ms",
            Timestamp = DateTime.UtcNow,
            Entries = healthReport.Entries.ToDictionary(
                entry => entry.Key,
                entry => new
                {
                    Status = entry.Value.Status.ToString(),
                    Duration = $"{entry.Value.Duration.TotalMilliseconds}ms",
                    Description = entry.Value.Description,
                    Data = entry.Value.Data,
                    Exception = entry.Value.Exception?.Message,
                    StackTrace = entry.Value.Exception?.StackTrace
                })
        };

        var statusCode = healthReport.Status == HealthStatus.Healthy ? 200 : 503;
        return StatusCode(statusCode, response);
    }
}
'@

        Write-Host "[OK] Exercise 3 template created successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "[NEXT] Next steps:" -ForegroundColor Yellow
        Write-Host "1. Update Program.cs to register health checks and exception middleware" -ForegroundColor Cyan
        Write-Host "2. Build the project: dotnet build" -ForegroundColor Cyan
        Write-Host "3. Run the application: dotnet run" -ForegroundColor Cyan
        Write-Host "4. Visit: http://localhost:5000/swagger" -ForegroundColor Cyan
        Write-Host "5. Test health endpoints: /api/health and /api/health/detailed" -ForegroundColor Cyan
        Write-Host "6. Test exception handling by triggering errors" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "[TIP] Add these to Program.cs:" -ForegroundColor Blue
        Write-Host "  builder.Services.AddHealthChecks()" -ForegroundColor White
        Write-Host "    .AddCheck<DatabaseHealthCheck>(\"database\")" -ForegroundColor White
        Write-Host "    .AddCheck<ExternalApiHealthCheck>(\"external-api\")" -ForegroundColor White
        Write-Host "    .AddCheck<CustomHealthCheck>(\"resources\");" -ForegroundColor White
        Write-Host "  app.UseGlobalExceptionHandling();" -ForegroundColor White
        Write-Host "  app.MapHealthChecks(\"/health\");" -ForegroundColor White
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
