# Module 7 Interactive Exercise Launcher - PowerShell Version
# Testing Applications

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
            Write-Host "  [TEST] 1. Setting up xUnit test projects with proper configuration" -ForegroundColor White
            Write-Host "  [TEST] 2. Writing effective unit tests using Arrange-Act-Assert pattern" -ForegroundColor White
            Write-Host "  [TEST] 3. Using Moq framework for mocking dependencies" -ForegroundColor White
            Write-Host "  [TEST] 4. Implementing test fixtures and data-driven tests" -ForegroundColor White
            Write-Host ""
            Write-Host "Key testing concepts:" -ForegroundColor Yellow
            Write-Host "  - Test isolation and independence" -ForegroundColor White
            Write-Host "  - Mocking external dependencies" -ForegroundColor White
            Write-Host "  - Test naming conventions and organization" -ForegroundColor White
            Write-Host "  - FluentAssertions for readable test assertions" -ForegroundColor White
        }
        "exercise02" {
            Write-Host "Building on Exercise 1, you will add:" -ForegroundColor Cyan
            Write-Host "  [LINK] 1. Integration testing with WebApplicationFactory" -ForegroundColor White
            Write-Host "  [LINK] 2. Testing complete API workflows end-to-end" -ForegroundColor White
            Write-Host "  [LINK] 3. Database testing with in-memory providers" -ForegroundColor White
            Write-Host "  [LINK] 4. Authentication and authorization testing" -ForegroundColor White
            Write-Host ""
            Write-Host "Integration concepts:" -ForegroundColor Yellow
            Write-Host "  - TestServer configuration and setup" -ForegroundColor White
            Write-Host "  - HTTP client testing patterns" -ForegroundColor White
            Write-Host "  - Database seeding for tests" -ForegroundColor White
            Write-Host "  - Testing middleware and filters" -ForegroundColor White
        }
        "exercise03" {
            Write-Host "Advanced testing with external services:" -ForegroundColor Cyan
            Write-Host "  [MOCK] 1. Mocking external API calls and services" -ForegroundColor White
            Write-Host "  [MOCK] 2. Testing with HttpClient and HttpMessageHandler mocks" -ForegroundColor White
            Write-Host "  [MOCK] 3. Implementing test doubles for complex scenarios" -ForegroundColor White
            Write-Host "  [MOCK] 4. Verifying method calls and behaviors" -ForegroundColor White
            Write-Host ""
            Write-Host "Mocking patterns:" -ForegroundColor Yellow
            Write-Host "  - Service layer mocking strategies" -ForegroundColor White
            Write-Host "  - HTTP client mocking techniques" -ForegroundColor White
            Write-Host "  - Behavior verification vs state verification" -ForegroundColor White
            Write-Host "  - Test data builders and object mothers" -ForegroundColor White
        }
        "exercise04" {
            Write-Host "Performance and load testing:" -ForegroundColor Cyan
            Write-Host "  [AUTO] 1. Benchmarking with BenchmarkDotNet" -ForegroundColor White
            Write-Host "  [AUTO] 2. Load testing strategies and tools" -ForegroundColor White
            Write-Host "  [AUTO] 3. Memory leak detection in tests" -ForegroundColor White
            Write-Host "  [AUTO] 4. Performance regression testing" -ForegroundColor White
            Write-Host ""
            Write-Host "Performance concepts:" -ForegroundColor Yellow
            Write-Host "  - Micro-benchmarking best practices" -ForegroundColor White
            Write-Host "  - Load testing patterns" -ForegroundColor White
            Write-Host "  - Performance monitoring in tests" -ForegroundColor White
            Write-Host "  - Continuous performance testing" -ForegroundColor White
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
            Write-Host "[TARGET] Exercise 01: Unit Testing Basics" -ForegroundColor Green
            Write-Host ""
            Write-Host "[OVERVIEW] What you'll build:" -ForegroundColor Yellow
            Write-Host "  [OK] Complete test project with xUnit framework" -ForegroundColor White
            Write-Host "  [OK] ProductService with comprehensive unit tests" -ForegroundColor White
            Write-Host "  [OK] Mocked dependencies using Moq framework" -ForegroundColor White
            Write-Host "  [OK] Test fixtures and data-driven test examples" -ForegroundColor White
            Write-Host ""
            Write-Host "[LAUNCH] RECOMMENDED: Use the Complete Working Example" -ForegroundColor Blue
            Write-Host "  Set-Location SourceCode\ProductCatalog.UnitTests; dotnet test" -ForegroundColor Cyan
            Write-Host "  Then explore: ProductServiceTests.cs for complete examples" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "📁 Template Structure:" -ForegroundColor Green
            Write-Host "  TestingDemo/" -ForegroundColor White
            Write-Host "  ├── TestingDemo.API/            # Main API project" -ForegroundColor Yellow
            Write-Host "  │   ├── Controllers/" -ForegroundColor White
            Write-Host "  │   ├── Services/" -ForegroundColor White
            Write-Host "  │   └── Models/" -ForegroundColor White
            Write-Host "  ├── TestingDemo.UnitTests/      # Unit test project" -ForegroundColor Yellow
            Write-Host "  │   ├── Services/" -ForegroundColor White
            Write-Host "  │   │   └── ProductServiceTests.cs" -ForegroundColor White
            Write-Host "  │   ├── Fixtures/" -ForegroundColor White
            Write-Host "  │   └── TestData/" -ForegroundColor White
            Write-Host "  └── TestingDemo.sln             # Solution file" -ForegroundColor Yellow
        }
        "exercise02" {
            Write-Host "[TARGET] Exercise 02: Integration Testing" -ForegroundColor Green
            Write-Host ""
            Write-Host "[OVERVIEW] Building on Exercise 1:" -ForegroundColor Yellow
            Write-Host "  [OK] WebApplicationFactory for integration tests" -ForegroundColor White
            Write-Host "  [OK] Complete API endpoint testing" -ForegroundColor White
            Write-Host "  [OK] Database integration with in-memory provider" -ForegroundColor White
            Write-Host "  [OK] Authentication testing scenarios" -ForegroundColor White
        }
        "exercise03" {
            Write-Host "[TARGET] Exercise 03: Mocking External Services" -ForegroundColor Green
            Write-Host ""
            Write-Host "[OVERVIEW] Advanced mocking scenarios:" -ForegroundColor Yellow
            Write-Host "  [OK] HttpClient mocking for external API calls" -ForegroundColor White
            Write-Host "  [OK] Service layer mocking with complex behaviors" -ForegroundColor White
            Write-Host "  [OK] Test doubles for various scenarios" -ForegroundColor White
            Write-Host "  [OK] Behavior verification and call tracking" -ForegroundColor White
        }
        "exercise04" {
            Write-Host "[TARGET] Exercise 04: Performance Testing" -ForegroundColor Green
            Write-Host ""
            Write-Host "[OVERVIEW] Performance testing tools:" -ForegroundColor Yellow
            Write-Host "  [OK] BenchmarkDotNet for micro-benchmarking" -ForegroundColor White
            Write-Host "  [OK] Load testing with custom test harness" -ForegroundColor White
            Write-Host "  [OK] Memory profiling and leak detection" -ForegroundColor White
            Write-Host "  [OK] Performance regression testing" -ForegroundColor White
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
    Write-Host "Module 7 - Testing Applications" -ForegroundColor Cyan
    Write-Host "Available Exercises:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  - exercise01: Unit Testing Basics" -ForegroundColor White
    Write-Host "  - exercise02: Integration Testing" -ForegroundColor White
    Write-Host "  - exercise03: Mocking External Services" -ForegroundColor White
    Write-Host "  - exercise04: Performance Testing" -ForegroundColor White
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

$ProjectName = "TestingDemo"

# Validate exercise name
$ValidExercises = @("exercise01", "exercise02", "exercise03", "exercise04")
if ($ExerciseName -notin $ValidExercises) {
    Write-Host "[ERROR] Unknown exercise: $ExerciseName" -ForegroundColor Red
    Write-Host ""
    Show-Exercises
    exit 1
}

# Welcome screen
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "[LAUNCH] Module 7: Testing Applications" -ForegroundColor Magenta
Write-Host "Exercise: $ExerciseName" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host ""

# Show the recommended approach
Write-Host "[TARGET] RECOMMENDED APPROACH:" -ForegroundColor Green
Write-Host "For the best learning experience, use the complete working implementation:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Use the working source code:" -ForegroundColor Yellow
Write-Host "   Set-Location SourceCode\ProductCatalog.UnitTests" -ForegroundColor Cyan
Write-Host "   dotnet test" -ForegroundColor Cyan
Write-Host "   # Explore comprehensive test examples" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Or run all test projects:" -ForegroundColor Yellow
Write-Host "   Set-Location SourceCode" -ForegroundColor Cyan
Write-Host "   dotnet test --logger trx --results-directory TestResults" -ForegroundColor Cyan
Write-Host "   # Includes unit, integration, and performance tests" -ForegroundColor Cyan
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
