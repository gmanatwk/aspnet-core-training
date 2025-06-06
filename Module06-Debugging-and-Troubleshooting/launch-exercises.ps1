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
