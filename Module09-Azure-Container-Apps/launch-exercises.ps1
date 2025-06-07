#!/usr/bin/env pwsh

# Module 9: Azure Container Apps - Interactive Exercise Launcher (PowerShell)
# This script provides guided, hands-on exercises for containerization and Azure deployment

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

# Configuration
$ProjectName = "ContainerAppsDemo"
$InteractiveMode = -not $Auto

# Function to display colored output
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Blue }
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }

# Function to explain concepts interactively
function Explain-Concept {
    param($Concept, $Explanation)
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "📚 CONCEPT: $Concept" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host $Explanation -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    
    if ($InteractiveMode) {
        Write-Host "Press Enter to continue..." -NoNewline
        Read-Host
        Write-Host ""
    }
}

# Function to show learning objectives
function Show-LearningObjectives {
    param($Exercise)
    
    Write-Host "🎯 Learning Objectives for $Exercise:" -ForegroundColor Blue
    
    switch ($Exercise) {
        "Exercise 1" {
            Write-Host "• Understand Docker containerization for ASP.NET Core"
            Write-Host "• Create optimized Dockerfile with multi-stage builds"
            Write-Host "• Implement health checks and graceful shutdown"
            Write-Host "• Run and test containers locally"
        }
        "Exercise 2" {
            Write-Host "• Deploy applications to Azure Container Apps"
            Write-Host "• Configure Azure Container Registry"
            Write-Host "• Set up environment variables and secrets"
            Write-Host "• Configure scaling and ingress"
        }
        "Exercise 3" {
            Write-Host "• Implement CI/CD with GitHub Actions"
            Write-Host "• Automate container building and deployment"
            Write-Host "• Configure environment-specific deployments"
            Write-Host "• Set up deployment approvals"
        }
        "Exercise 4" {
            Write-Host "• Configure Application Insights monitoring"
            Write-Host "• Set up custom domains and SSL"
            Write-Host "• Implement service-to-service communication"
            Write-Host "• Configure network security"
        }
    }
    Write-Host ""
}

# Function to create files interactively
function Create-FileInteractive {
    param($FilePath, $Content, $Description)
    
    if ($Preview) {
        Write-Host "📄 Would create: $FilePath" -ForegroundColor Cyan
        Write-Host "   Description: $Description" -ForegroundColor Yellow
        return
    }
    
    Write-Host "📄 Creating: $FilePath" -ForegroundColor Cyan
    Write-Host "   $Description" -ForegroundColor Yellow
    
    # Create directory if it doesn't exist
    $Directory = Split-Path $FilePath -Parent
    if ($Directory -and -not (Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    
    # Write content to file
    Set-Content -Path $FilePath -Value $Content -Encoding UTF8
    
    if ($InteractiveMode) {
        Write-Host "   File created. Press Enter to continue..." -NoNewline
        Read-Host
    }
    Write-Host ""
}

# Function to show available exercises
function Show-Exercises {
    Write-Host "Module 9 - Azure Container Apps" -ForegroundColor Cyan
    Write-Host "Available Exercises:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  - exercise01: Basic Containerization"
    Write-Host "  - exercise02: Azure Deployment"
    Write-Host "  - exercise03: CI/CD Pipeline"
    Write-Host "  - exercise04: Advanced Configuration"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\launch-exercises.ps1 <exercise-name> [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -List           Show all available exercises"
    Write-Host "  -Auto           Skip interactive mode"
    Write-Host "  -Preview        Show what will be created without creating"
}

# Main script logic
if ($List) {
    Show-Exercises
    exit 0
}

if (-not $ExerciseName) {
    Write-Error "Usage: .\launch-exercises.ps1 <exercise-name> [options]"
    Write-Host ""
    Show-Exercises
    exit 1
}

# Validate exercise name
$ValidExercises = @("exercise01", "exercise02", "exercise03", "exercise04")
if ($ExerciseName -notin $ValidExercises) {
    Write-Error "Unknown exercise: $ExerciseName"
    Write-Host ""
    Show-Exercises
    exit 1
}

# Welcome message
Write-Host "🚀 Module 9: Azure Container Apps" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Show learning objectives
switch ($ExerciseName) {
    "exercise01" { Show-LearningObjectives "Exercise 1" }
    "exercise02" { Show-LearningObjectives "Exercise 2" }
    "exercise03" { Show-LearningObjectives "Exercise 3" }
    "exercise04" { Show-LearningObjectives "Exercise 4" }
}

if ($Preview) {
    Write-Info "Preview mode - no files will be created"
    Write-Host ""
}

# Check prerequisites
Write-Info "Checking prerequisites..."

# Check Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed. Please install Docker Desktop."
    exit 1
}

# Check Azure CLI
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Warning "Azure CLI is not installed. Some exercises may require it."
}

# Check .NET SDK
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Error ".NET SDK is not installed. Please install .NET 8.0 SDK."
    exit 1
}

Write-Success "Prerequisites check completed"
Write-Host ""

# Check if project exists
$SkipProjectCreation = $false
if (Test-Path $ProjectName) {
    if ($ExerciseName -in @("exercise02", "exercise03", "exercise04")) {
        Write-Success "Found existing $ProjectName from previous exercise"
        Write-Info "This exercise will build on your existing work"
        Set-Location $ProjectName
        $SkipProjectCreation = $true
    } else {
        Write-Warning "Project '$ProjectName' already exists!"
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

# Exercise implementations will be added in the next part...

Write-Host ""
Write-Success "🎉 $ExerciseName template created successfully!"
Write-Host ""
Write-Info "📋 Next steps based on exercise:"

switch ($ExerciseName) {
    "exercise01" {
        Write-Host "1. Build the container: docker build -t containerappsdemo ." -ForegroundColor Cyan
        Write-Host "2. Run locally: docker run -p 8080:8080 containerappsdemo" -ForegroundColor Cyan
        Write-Host "3. Test health check: curl http://localhost:8080/health" -ForegroundColor Cyan
        Write-Host "4. Use Docker Compose: docker-compose up" -ForegroundColor Cyan
    }
    "exercise02" {
        Write-Host "1. Login to Azure: az login" -ForegroundColor Cyan
        Write-Host "2. Run deployment: .\deploy-to-azure.ps1" -ForegroundColor Cyan
        Write-Host "3. Check deployment-info.txt for URLs and commands" -ForegroundColor Cyan
    }
    "exercise03" {
        Write-Host "1. Commit and push to GitHub repository" -ForegroundColor Cyan
        Write-Host "2. Set up Azure service principal for GitHub Actions" -ForegroundColor Cyan
        Write-Host "3. Configure repository secrets (AZURE_CREDENTIALS)" -ForegroundColor Cyan
        Write-Host "4. Monitor workflow runs in GitHub Actions" -ForegroundColor Cyan
    }
    "exercise04" {
        Write-Host "1. Deploy the enhanced application with monitoring" -ForegroundColor Cyan
        Write-Host "2. Configure Application Insights connection string" -ForegroundColor Cyan
        Write-Host "3. Set up custom domain and SSL certificate" -ForegroundColor Cyan
        Write-Host "4. Monitor application performance and health" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Info "📚 For detailed instructions, refer to the exercise guide files created."
Write-Info "🔗 Additional resources available in the Resources/ directory."
