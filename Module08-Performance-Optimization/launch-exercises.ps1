# Module 8 Interactive Exercise Launcher - PowerShell Version
# Performance Optimization

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
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "📄 Will create: $FilePath" -ForegroundColor Blue
    Write-Host "📝 Purpose: $Description" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
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
                Write-Host "⏭️  Skipped: $FilePath" -ForegroundColor Red
                return
            }
            "s" {
                $script:InteractiveMode = $false
                Write-Host "📌 Switching to automatic mode..." -ForegroundColor Cyan
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
    Write-Host "✅ Created: $FilePath" -ForegroundColor Green
    Write-Host ""
}

# Function to show learning objectives
function Show-LearningObjectives {
    param([string]$Exercise)
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Write-Host "🎯 Learning Objectives" -ForegroundColor Magenta
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    
    switch ($Exercise) {
        "exercise01" {
            Write-Host "In this exercise, you will learn:" -ForegroundColor Cyan
            Write-Host "  🚀 1. Implementing in-memory and distributed caching strategies" -ForegroundColor White
            Write-Host "  🚀 2. Response caching and output caching techniques" -ForegroundColor White
            Write-Host "  🚀 3. Cache invalidation and expiration policies" -ForegroundColor White
            Write-Host "  🚀 4. Redis integration for distributed scenarios" -ForegroundColor White
            Write-Host ""
            Write-Host "Key caching concepts:" -ForegroundColor Yellow
            Write-Host "  • Memory cache vs distributed cache" -ForegroundColor White
            Write-Host "  • Cache-aside and write-through patterns" -ForegroundColor White
            Write-Host "  • Cache key design and naming strategies" -ForegroundColor White
            Write-Host "  • Performance monitoring and metrics" -ForegroundColor White
        }
        "exercise02" {
            Write-Host "Building on Exercise 1, you will add:" -ForegroundColor Cyan
            Write-Host "  📊 1. Database query optimization techniques" -ForegroundColor White
            Write-Host "  📊 2. Entity Framework performance tuning" -ForegroundColor White
            Write-Host "  📊 3. Connection pooling and query batching" -ForegroundColor White
            Write-Host "  📊 4. Database indexing strategies" -ForegroundColor White
            Write-Host ""
            Write-Host "Database optimization:" -ForegroundColor Yellow
            Write-Host "  • Query execution plan analysis" -ForegroundColor White
            Write-Host "  • N+1 query problem solutions" -ForegroundColor White
            Write-Host "  • Lazy vs eager loading strategies" -ForegroundColor White
            Write-Host "  • Database connection management" -ForegroundColor White
        }
        "exercise03" {
            Write-Host "Advanced performance patterns:" -ForegroundColor Cyan
            Write-Host "  ⚡ 1. Asynchronous programming best practices" -ForegroundColor White
            Write-Host "  ⚡ 2. Memory management and garbage collection" -ForegroundColor White
            Write-Host "  ⚡ 3. CPU-bound vs I/O-bound optimization" -ForegroundColor White
            Write-Host "  ⚡ 4. Parallel processing and Task optimization" -ForegroundColor White
            Write-Host ""
            Write-Host "Performance concepts:" -ForegroundColor Yellow
            Write-Host "  • Thread pool optimization" -ForegroundColor White
            Write-Host "  • Memory allocation patterns" -ForegroundColor White
            Write-Host "  • Async/await performance implications" -ForegroundColor White
            Write-Host "  • Resource pooling strategies" -ForegroundColor White
        }
        "exercise04" {
            Write-Host "Monitoring and profiling:" -ForegroundColor Cyan
            Write-Host "  📈 1. Application performance monitoring (APM)" -ForegroundColor White
            Write-Host "  📈 2. Custom metrics and telemetry" -ForegroundColor White
            Write-Host "  📈 3. Performance profiling tools" -ForegroundColor White
            Write-Host "  📈 4. Load testing and capacity planning" -ForegroundColor White
            Write-Host ""
            Write-Host "Monitoring tools:" -ForegroundColor Yellow
            Write-Host "  • Built-in .NET performance counters" -ForegroundColor White
            Write-Host "  • Custom metrics with EventCounters" -ForegroundColor White
            Write-Host "  • Memory and CPU profiling" -ForegroundColor White
            Write-Host "  • Distributed tracing patterns" -ForegroundColor White
        }
    }
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Wait-ForUser
}

# Function to show what will be created overview
function Show-CreationOverview {
    param([string]$Exercise)
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "📋 Overview: What will be created" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    switch ($Exercise) {
        "exercise01" {
            Write-Host "🎯 Exercise 01: Caching Implementation" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 What you'll build:" -ForegroundColor Yellow
            Write-Host "  ✅ High-performance API with multiple caching layers" -ForegroundColor White
            Write-Host "  ✅ In-memory caching with IMemoryCache" -ForegroundColor White
            Write-Host "  ✅ Distributed caching with Redis" -ForegroundColor White
            Write-Host "  ✅ Response caching and output caching" -ForegroundColor White
            Write-Host ""
            Write-Host "🚀 RECOMMENDED: Use the Complete Working Example" -ForegroundColor Blue
            Write-Host "  Set-Location SourceCode\PerformanceDemo; dotnet run" -ForegroundColor Cyan
            Write-Host "  Then visit: http://localhost:5000 for performance testing" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "📁 Template Structure:" -ForegroundColor Green
            Write-Host "  PerformanceDemo/" -ForegroundColor White
            Write-Host "  ├── Controllers/" -ForegroundColor White
            Write-Host "  │   ├── ProductsController.cs   # Cached API endpoints" -ForegroundColor Yellow
            Write-Host "  │   └── CacheController.cs      # Cache management" -ForegroundColor Yellow
            Write-Host "  ├── Services/" -ForegroundColor White
            Write-Host "  │   ├── CacheService.cs         # Caching abstraction" -ForegroundColor Yellow
            Write-Host "  │   └── ProductService.cs       # Business logic" -ForegroundColor Yellow
            Write-Host "  ├── Middleware/" -ForegroundColor White
            Write-Host "  │   └── ResponseCacheMiddleware.cs # Custom caching" -ForegroundColor Yellow
            Write-Host "  └── docker-compose.yml          # Redis setup" -ForegroundColor Yellow
        }
        "exercise02" {
            Write-Host "🎯 Exercise 02: Database Optimization" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 Building on Exercise 1:" -ForegroundColor Yellow
            Write-Host "  ✅ Entity Framework performance tuning" -ForegroundColor White
            Write-Host "  ✅ Query optimization and indexing" -ForegroundColor White
            Write-Host "  ✅ Connection pooling configuration" -ForegroundColor White
            Write-Host "  ✅ Database performance monitoring" -ForegroundColor White
        }
        "exercise03" {
            Write-Host "🎯 Exercise 03: Async and Memory Optimization" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 Advanced performance patterns:" -ForegroundColor Yellow
            Write-Host "  ✅ Asynchronous programming optimization" -ForegroundColor White
            Write-Host "  ✅ Memory management and pooling" -ForegroundColor White
            Write-Host "  ✅ CPU-bound task optimization" -ForegroundColor White
            Write-Host "  ✅ Resource pooling implementations" -ForegroundColor White
        }
        "exercise04" {
            Write-Host "🎯 Exercise 04: Monitoring and Profiling" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 Performance monitoring tools:" -ForegroundColor Yellow
            Write-Host "  ✅ Application Performance Monitoring (APM)" -ForegroundColor White
            Write-Host "  ✅ Custom metrics and telemetry" -ForegroundColor White
            Write-Host "  ✅ Performance profiling integration" -ForegroundColor White
            Write-Host "  ✅ Load testing and benchmarking" -ForegroundColor White
        }
    }
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Wait-ForUser
}

# Function to explain a concept
function Show-Concept {
    param(
        [string]$ConceptName,
        [string]$Explanation
    )
    
    Write-Host "💡 Concept: $ConceptName" -ForegroundColor Magenta
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host $Explanation -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Wait-ForUser
}

# Function to show available exercises
function Show-Exercises {
    Write-Host "Module 8 - Performance Optimization" -ForegroundColor Cyan
    Write-Host "Available Exercises:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  - exercise01: Caching Implementation" -ForegroundColor White
    Write-Host "  - exercise02: Database Optimization" -ForegroundColor White
    Write-Host "  - exercise03: Async and Memory Optimization" -ForegroundColor White
    Write-Host "  - exercise04: Monitoring and Profiling" -ForegroundColor White
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
    Write-Host "❌ Usage: .\launch-exercises.ps1 <exercise-name> [options]" -ForegroundColor Red
    Write-Host ""
    Show-Exercises
    exit 1
}

$ProjectName = "PerformanceDemo"

# Validate exercise name
$ValidExercises = @("exercise01", "exercise02", "exercise03", "exercise04")
if ($ExerciseName -notin $ValidExercises) {
    Write-Host "❌ Unknown exercise: $ExerciseName" -ForegroundColor Red
    Write-Host ""
    Show-Exercises
    exit 1
}

# Welcome screen
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
Write-Host "🚀 Module 8: Performance Optimization" -ForegroundColor Magenta
Write-Host "Exercise: $ExerciseName" -ForegroundColor Magenta
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
Write-Host ""

# Show the recommended approach
Write-Host "🎯 RECOMMENDED APPROACH:" -ForegroundColor Green
Write-Host "For the best learning experience, use the complete working implementation:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Use the working source code:" -ForegroundColor Yellow
Write-Host "   Set-Location SourceCode\PerformanceDemo" -ForegroundColor Cyan
Write-Host "   dotnet run" -ForegroundColor Cyan
Write-Host "   # Visit: http://localhost:5000 for performance testing" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Or use Docker for complete setup with Redis:" -ForegroundColor Yellow
Write-Host "   Set-Location SourceCode" -ForegroundColor Cyan
Write-Host "   docker-compose up --build" -ForegroundColor Cyan
Write-Host "   # Includes Redis, monitoring, and load testing tools" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  The template created by this script is basic and may not match" -ForegroundColor Yellow
Write-Host "   all exercise requirements. The SourceCode version is complete!" -ForegroundColor Yellow
Write-Host ""

if ($InteractiveMode) {
    Write-Host "🎮 Interactive Mode: ON" -ForegroundColor Yellow
    Write-Host "You'll see what each file does before it's created" -ForegroundColor Cyan
} else {
    Write-Host "⚡ Automatic Mode: ON" -ForegroundColor Yellow
}

Write-Host ""
$Response = Read-Host "Continue with template creation? (y/N)"
if ($Response -notmatch "^[Yy]$") {
    Write-Host "💡 Great choice! Use the SourceCode version for the best experience." -ForegroundColor Cyan
    exit 0
}
