#!/usr/bin/env pwsh

# Module 13: Building Microservices - Interactive Exercise Launcher
# This script provides guided, hands-on exercises for microservices architecture and implementation

param(
    [Parameter(Position=0)]
    [string]$ExerciseName,
    
    [switch]$List,
    [switch]$Auto,
    [switch]$Preview
)

# Enable strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Configuration
$ProjectName = "AzureECommerce"
$InteractiveMode = -not $Auto
$SkipProjectCreation = $false
$PreviewOnly = $Preview

# Colors for output
function Write-Info { 
    Write-Host "ℹ️  $($args[0])" -ForegroundColor Blue 
}

function Write-Success { 
    Write-Host "✅ $($args[0])" -ForegroundColor Green 
}

function Write-Warning { 
    Write-Host "⚠️  $($args[0])" -ForegroundColor Yellow 
}

function Write-Error { 
    Write-Host "❌ $($args[0])" -ForegroundColor Red 
}

function Write-Concept {
    param(
        [string]$Title,
        [string]$Content
    )
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Write-Host "🏗️ MICROSERVICES CONCEPT: $Title" -ForegroundColor Magenta
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Write-Host $Content -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Write-Host ""
}

# Function to pause for user interaction
function Pause-ForUser {
    if ($InteractiveMode) {
        Write-Host -NoNewline "Press Enter to continue..."
        Read-Host
        Write-Host ""
    }
}

# Function to show learning objectives
function Show-LearningObjectives {
    param([string]$Exercise)
    
    Write-Host "🎯 Microservices Learning Objectives for ${Exercise}:" -ForegroundColor Blue
    
    switch ($Exercise) {
        "exercise01" {
            Write-Host "Azure Setup and Microservices Overview:" -ForegroundColor Cyan
            Write-Host "  ☁️  1. Set up Azure Resource Group and services"
            Write-Host "  ☁️  2. Create Azure Container Registry"
            Write-Host "  ☁️  3. Understand Azure Container Apps architecture"
            Write-Host "  ☁️  4. Plan cloud-native microservices deployment"
            Write-Host ""
            Write-Host "Azure concepts:" -ForegroundColor Yellow
            Write-Host "  • Azure Container Apps fundamentals"
            Write-Host "  • Managed services overview"
            Write-Host "  • Cost optimization strategies"
            Write-Host "  • Cloud-native design principles"
        }
        "exercise02" {
            Write-Host "Building Azure-Ready Services:" -ForegroundColor Cyan
            Write-Host "  ☁️  1. Create cloud-native ASP.NET Core services"
            Write-Host "  ☁️  2. Configure for Azure SQL Database"
            Write-Host "  ☁️  3. Integrate Application Insights"
            Write-Host "  ☁️  4. Prepare for container deployment"
            Write-Host ""
            Write-Host "Azure integration concepts:" -ForegroundColor Yellow
            Write-Host "  • Azure SQL Database configuration"
            Write-Host "  • Application Insights telemetry"
            Write-Host "  • Environment-based configuration"
            Write-Host "  • Container-ready applications"
        }
        "exercise03" {
            Write-Host "Deploy to Azure Container Apps:" -ForegroundColor Cyan
            Write-Host "  ☁️  1. Build and push images to Azure Container Registry"
            Write-Host "  ☁️  2. Deploy services to Container Apps"
            Write-Host "  ☁️  3. Configure environment variables and secrets"
            Write-Host "  ☁️  4. Set up Application Insights monitoring"
            Write-Host ""
            Write-Host "Deployment concepts:" -ForegroundColor Yellow
            Write-Host "  • Container Apps deployment"
            Write-Host "  • Environment configuration"
            Write-Host "  • Service discovery in Container Apps"
            Write-Host "  • Azure monitoring setup"
        }
        "exercise04" {
            Write-Host "Azure Service Communication:" -ForegroundColor Cyan
            Write-Host "  ☁️  1. Implement Azure Service Bus messaging"
            Write-Host "  ☁️  2. Configure service-to-service communication"
            Write-Host "  ☁️  3. Add resilience with Polly"
            Write-Host "  ☁️  4. Handle failures gracefully"
            Write-Host ""
            Write-Host "Communication concepts:" -ForegroundColor Yellow
            Write-Host "  • Azure Service Bus integration"
            Write-Host "  • Resilient HTTP communication"
            Write-Host "  • Circuit breaker patterns"
            Write-Host "  • Message-based architecture"
        }
        "exercise05" {
            Write-Host "Production Features:" -ForegroundColor Cyan
            Write-Host "  ☁️  1. Configure auto-scaling rules"
            Write-Host "  ☁️  2. Set up Azure Front Door"
            Write-Host "  ☁️  3. Implement comprehensive health checks"
            Write-Host "  ☁️  4. Review costs and optimize"
            Write-Host ""
            Write-Host "Production concepts:" -ForegroundColor Yellow
            Write-Host "  • Container Apps scaling strategies"
            Write-Host "  • Global load balancing"
            Write-Host "  • Cost optimization techniques"
            Write-Host "  • Production monitoring"
        }
    }
    Write-Host ""
}

# Function to show what will be created
function Show-CreationOverview {
    param([string]$Exercise)
    
    Write-Host "📋 Microservices Components for ${Exercise}:" -ForegroundColor Cyan
    
    switch ($Exercise) {
        "exercise01" {
            Write-Host "• Domain analysis templates and worksheets"
            Write-Host "• Service boundary design documents"
            Write-Host "• Data consistency strategy guides"
            Write-Host "• Technology stack decision templates"
            Write-Host "• Service architecture diagrams"
        }
        "exercise02" {
            Write-Host "• Product Catalog microservice"
            Write-Host "• Order Management microservice"
            Write-Host "• User Management microservice"
            Write-Host "• Shared libraries and common models"
            Write-Host "• API Gateway foundation"
        }
        "exercise03" {
            Write-Host "• HTTP client communication patterns"
            Write-Host "• RabbitMQ message broker integration"
            Write-Host "• Event-driven communication examples"
            Write-Host "• Distributed transaction handling"
            Write-Host "• Saga pattern implementations"
        }
        "exercise04" {
            Write-Host "• Docker containerization for all services"
            Write-Host "• Docker Compose orchestration"
            Write-Host "• Application Insights monitoring"
            Write-Host "• Health checks and diagnostics"
            Write-Host "• Circuit breaker and retry patterns"
        }
        "exercise05" {
            Write-Host "• Azure AKS deployment with Terraform"
            Write-Host "• Generic Kubernetes manifests"
            Write-Host "• Docker Swarm deployment option"
            Write-Host "• Production monitoring dashboards"
            Write-Host "• CI/CD pipeline configurations"
        }
    }
    Write-Host ""
}

# Function to create files interactively
function New-FileInteractive {
    param(
        [string]$FilePath,
        [string]$Content,
        [string]$Description
    )
    
    if ($PreviewOnly) {
        Write-Host "📄 Would create: $FilePath" -ForegroundColor Cyan
        Write-Host "   Description: $Description" -ForegroundColor Yellow
        return
    }
    
    Write-Host "📄 Creating: $FilePath" -ForegroundColor Cyan
    Write-Host "   $Description" -ForegroundColor Yellow
    
    # Create directory if it doesn't exist
    $directory = Split-Path -Parent $FilePath
    if ($directory -and -not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    
    # Write content to file
    Set-Content -Path $FilePath -Value $Content -Encoding UTF8
    
    if ($InteractiveMode) {
        Write-Host -NoNewline "   File created. Press Enter to continue..."
        Read-Host
    }
    Write-Host ""
}

# Function to show available exercises
function Show-Exercises {
    Write-Host "Module 13 - Building Microservices with Azure" -ForegroundColor Cyan
    Write-Host "Available Exercises:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  - exercise01: Azure Setup and Microservices Overview"
    Write-Host "  - exercise02: Building Azure-Ready Services"
    Write-Host "  - exercise03: Deploy to Azure Container Apps"
    Write-Host "  - exercise04: Azure Service Communication"
    Write-Host "  - exercise05: Production Features"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\launch-exercises.ps1 <exercise-name> [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -List          Show all available exercises"
    Write-Host "  -Auto          Skip interactive mode"
    Write-Host "  -Preview       Show what will be created without creating"
}

# Main script starts here
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
if ($ExerciseName -notin @("exercise01", "exercise02", "exercise03", "exercise04", "exercise05")) {
    Write-Error "Unknown exercise: $ExerciseName"
    Write-Host ""
    Show-Exercises
    exit 1
}

# Welcome message
Write-Host "☁️ Module 13: Building Microservices with Azure" -ForegroundColor Magenta
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
Write-Host ""

# Show learning objectives
Show-LearningObjectives $ExerciseName

# Show what will be created
Show-CreationOverview $ExerciseName

if ($PreviewOnly) {
    Write-Info "Preview mode - no files will be created"
    Write-Host ""
}

# Check prerequisites
Write-Info "Checking microservices prerequisites..."

# Check .NET SDK
try {
    $dotnetVersion = dotnet --version
    Write-Success ".NET SDK $dotnetVersion is installed"
} catch {
    Write-Error ".NET SDK is not installed. Please install .NET 8.0 SDK."
    exit 1
}

# Check Azure CLI
try {
    $azVersion = az --version | Select-String "azure-cli" | Select-Object -First 1
    Write-Success "Azure CLI is installed: $azVersion"
} catch {
    Write-Error "Azure CLI is not installed. Please install Azure CLI to continue."
    Write-Info "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
}

Write-Success "Prerequisites check completed"
Write-Host ""

# Check if project exists in current directory
if (Test-Path $ProjectName) {
    if ($ExerciseName -in @("exercise02", "exercise03", "exercise04", "exercise05")) {
        Write-Success "Found existing $ProjectName from previous exercise"
        Write-Info "This exercise will build on your existing work"
        Set-Location $ProjectName
        $SkipProjectCreation = $true
    } else {
        Write-Warning "Project '$ProjectName' already exists!"
        $response = Read-Host "Do you want to overwrite it? (y/N)"
        if ($response -notmatch '^[Yy]$') {
            exit 1
        }
        Remove-Item -Path $ProjectName -Recurse -Force
        $SkipProjectCreation = $false
    }
} else {
    $SkipProjectCreation = $false
}

# Exercise implementations
switch ($ExerciseName) {
    "exercise01" {
        # Exercise 1: Azure Setup and Microservices Overview
        
        Write-Concept -Title "Azure Container Apps for Microservices" -Content @"
Azure Container Apps - Serverless Microservices:
• No Infrastructure Management: Focus on code, not servers
• Auto-scaling: Scale to zero, scale based on demand
• Built-in Features: Load balancing, HTTPS, service discovery
• Cost-Effective: Pay only for what you use
• Integrated Services: Azure SQL, Service Bus, Key Vault
"@
        
        Pause-ForUser
        
        if (-not $SkipProjectCreation) {
            Write-Info "Setting up Azure resources..."
            New-Item -ItemType Directory -Path $ProjectName -Force | Out-Null
            Set-Location $ProjectName
        }
        
        # Create Azure setup script
        New-FileInteractive -FilePath "setup-azure.ps1" -Content @'
# Azure Microservices Setup Script
# This script sets up all required Azure resources

Write-Host "🚀 Setting up Azure resources for microservices..." -ForegroundColor Cyan

# Variables
$RESOURCE_GROUP = "rg-microservices-demo"
$LOCATION = "eastus"
$RANDOM_SUFFIX = Get-Random -Minimum 1000 -Maximum 9999
$ACR_NAME = "acrmicroservices$RANDOM_SUFFIX"
$ENVIRONMENT = "microservices-env"
$SQL_SERVER = "sql-microservices-$RANDOM_SUFFIX"
$SQL_ADMIN = "sqladmin"
$SQL_PASSWORD = "P@ssw0rd$RANDOM_SUFFIX!"
$APP_INSIGHTS = "appi-microservices"

# Check Azure CLI
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI is not installed. Please install it first."
    exit 1
}

# Login check
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Host "Please login to Azure..." -ForegroundColor Yellow
    az login
}

Write-Host "Creating resource group..." -ForegroundColor Yellow
az group create --name $RESOURCE_GROUP --location $LOCATION

Write-Host "Creating Container Registry..." -ForegroundColor Yellow
az acr create `
  --resource-group $RESOURCE_GROUP `
  --name $ACR_NAME `
  --sku Basic `
  --admin-enabled true

Write-Host "Creating Container Apps Environment..." -ForegroundColor Yellow
az containerapp env create `
  --name $ENVIRONMENT `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION

Write-Host "Creating SQL Server..." -ForegroundColor Yellow
az sql server create `
  --name $SQL_SERVER `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION `
  --admin-user $SQL_ADMIN `
  --admin-password $SQL_PASSWORD

az sql server firewall-rule create `
  --resource-group $RESOURCE_GROUP `
  --server $SQL_SERVER `
  --name AllowAzureServices `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 0.0.0.0

Write-Host "Creating databases..." -ForegroundColor Yellow
az sql db create --resource-group $RESOURCE_GROUP --server $SQL_SERVER --name ProductDb --edition Basic
az sql db create --resource-group $RESOURCE_GROUP --server $SQL_SERVER --name OrderDb --edition Basic

Write-Host "Creating Application Insights..." -ForegroundColor Yellow
az monitor app-insights component create `
  --app $APP_INSIGHTS `
  --location $LOCATION `
  --resource-group $RESOURCE_GROUP `
  --application-type web

# Save configuration
$config = @"
# Azure Configuration
`$RESOURCE_GROUP="$RESOURCE_GROUP"
`$ACR_NAME="$ACR_NAME"
`$ENVIRONMENT="$ENVIRONMENT"
`$SQL_SERVER="$SQL_SERVER"
`$SQL_ADMIN="$SQL_ADMIN"
`$SQL_PASSWORD="$SQL_PASSWORD"
`$APP_INSIGHTS="$APP_INSIGHTS"
"@

$config | Out-File -FilePath "azure-config.ps1"

Write-Host "\n✅ Setup complete!" -ForegroundColor Green
Write-Host "Configuration saved to azure-config.ps1" -ForegroundColor Cyan
Write-Host "\nEstimated monthly cost: ~$30 (minimal usage)" -ForegroundColor Yellow
'@ -Description "Azure resource setup script for microservices"
        
        # Create cost estimation
        New-FileInteractive -FilePath "docs\azure-cost-estimation.md" -Content @'
# Azure Cost Estimation

## Monthly Cost Breakdown (Minimal Usage)

| Service | Configuration | Estimated Cost |
|---------|--------------|----------------|
| Container Apps | 2 apps, 0.5 vCPU, 1GB RAM each | ~$10 |
| Azure SQL | Basic tier, 2 databases | ~$10 |
| Container Registry | Basic tier | ~$5 |
| Application Insights | Basic ingestion | ~$5 |
| **Total** | | **~$30/month** |

## Free Tier Benefits
- First 180,000 vCPU-seconds free
- First 360,000 GB-seconds free  
- First 2 million requests free
- 5GB Application Insights data free

## Cost Optimization Tips
1. Scale Container Apps to zero when not in use
2. Use Basic tier for SQL in development
3. Set up cost alerts in Azure Portal
4. Review and optimize regularly
'@ -Description "Azure cost estimation guide"
        
        Write-Host ""
        Write-Success "Exercise 01 setup complete!"
        Write-Host ""
        Write-Host "🚨 IMPORTANT NEXT STEP:" -ForegroundColor Yellow
        Write-Host "You MUST run the setup script to create Azure resources:" -ForegroundColor Red
        Write-Host ""
        Write-Host "  .\setup-azure.ps1" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "This script will:" -ForegroundColor White
        Write-Host "  • Create Azure Resource Group" -ForegroundColor Gray
        Write-Host "  • Create Container Registry" -ForegroundColor Gray
        Write-Host "  • Create Container Apps Environment" -ForegroundColor Gray
        Write-Host "  • Create SQL Server and databases" -ForegroundColor Gray
        Write-Host "  • Create Application Insights" -ForegroundColor Gray
        Write-Host "  • Generate azure-config.ps1 (required for other exercises)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "After running setup-azure.ps1, you can proceed to exercise02." -ForegroundColor Green
    }
    
    "exercise02" {
        # Exercise 2: Building Azure-Ready Services
        
        Write-Concept -Title "Cloud-Native Service Design" -Content @"
Azure-Ready Microservices:
• 12-Factor App Principles: Configuration, logging, stateless
• Azure Integration: SQL Database, Key Vault, App Insights
• Container-Ready: Dockerfile optimization for Azure
• Health Checks: Liveness and readiness probes
• Resilience: Built-in retry and circuit breaker patterns
"@
        
        Pause-ForUser
        
        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 2 requires Exercise 1 to be completed first!"
            Write-Info "Please run: .\launch-exercises.ps1 exercise01"
            exit 1
        }
        
        Write-Info "Creating Azure-ready microservices..."
        
        # Create solution structure
        New-Item -ItemType Directory -Path "SourceCode" -Force | Out-Null
        Set-Location "SourceCode"
        dotnet new sln -n AzureECommerce
        
        # Create shared library
        New-Item -ItemType Directory -Path "src\SharedLibraries" -Force | Out-Null
        Set-Location "src\SharedLibraries"
        dotnet new classlib -n ECommerceMS.Shared --framework net8.0
        dotnet add ECommerceMS.Shared package Microsoft.Extensions.Logging
        Set-Location "..\..\"
        
        # Add shared library to solution
        dotnet sln add src\SharedLibraries\ECommerceMS.Shared\ECommerceMS.Shared.csproj
        
        # Create base entity
        New-FileInteractive -FilePath "src\SharedLibraries\ECommerceMS.Shared\Models\BaseEntity.cs" -Content @'
using System.ComponentModel.DataAnnotations;

namespace ECommerceMS.Shared.Models;

public abstract class BaseEntity
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public string? UpdatedBy { get; set; }
}
'@ -Description "Base entity class for all microservices"
        
        # Create Product Catalog Service
        Write-Info "Creating Product Catalog microservice..."
        New-Item -ItemType Directory -Path "src" -Force | Out-Null
        Set-Location "src"
        dotnet new webapi -n ProductCatalog.Service --framework net8.0
        Set-Location "ProductCatalog.Service"
        
        # Add necessary packages
        dotnet add package Microsoft.EntityFrameworkCore.SqlServer
        dotnet add package Microsoft.EntityFrameworkCore.Tools
        dotnet add package Swashbuckle.AspNetCore
        dotnet add package Microsoft.AspNetCore.Diagnostics.HealthChecks
        dotnet add reference ..\..\src\SharedLibraries\ECommerceMS.Shared\ECommerceMS.Shared.csproj
        
        Set-Location "..\..\"
        dotnet sln add src\ProductCatalog.Service\ProductCatalog.Service.csproj
        
        # Create Order Management Service
        Write-Info "Creating Order Management microservice..."
        Set-Location "src"
        dotnet new webapi -n OrderManagement.Service --framework net8.0
        Set-Location "OrderManagement.Service"
        
        # Add necessary packages
        dotnet add package Microsoft.EntityFrameworkCore.SqlServer
        dotnet add package Microsoft.EntityFrameworkCore.Tools
        dotnet add package Swashbuckle.AspNetCore
        dotnet add package Microsoft.AspNetCore.Diagnostics.HealthChecks
        dotnet add reference ..\..\src\SharedLibraries\ECommerceMS.Shared\ECommerceMS.Shared.csproj
        
        Set-Location "..\..\"
        dotnet sln add src\OrderManagement.Service\OrderManagement.Service.csproj
        
        # Create User Management Service
        Write-Info "Creating User Management microservice..."
        Set-Location "src"
        dotnet new webapi -n UserManagement.Service --framework net8.0
        Set-Location "UserManagement.Service"
        
        # Add necessary packages
        dotnet add package Microsoft.EntityFrameworkCore.SqlServer
        dotnet add package Microsoft.EntityFrameworkCore.Tools
        dotnet add package Swashbuckle.AspNetCore
        dotnet add package Microsoft.AspNetCore.Diagnostics.HealthChecks
        dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore
        dotnet add package System.IdentityModel.Tokens.Jwt
        dotnet add reference ..\..\src\SharedLibraries\ECommerceMS.Shared\ECommerceMS.Shared.csproj
        
        Set-Location "..\..\"
        dotnet sln add src\UserManagement.Service\UserManagement.Service.csproj
        
        # Create API Gateway
        Write-Info "Creating API Gateway..."
        Set-Location "src"
        dotnet new webapi -n ApiGateway --framework net8.0
        Set-Location "ApiGateway"
        
        # Add YARP for reverse proxy
        dotnet add package Yarp.ReverseProxy
        dotnet add package Swashbuckle.AspNetCore
        
        Set-Location "..\..\"
        dotnet sln add src\ApiGateway\ApiGateway.csproj
        
        Write-Success "Azure-ready microservices created successfully!"
        
        # Create deployment helper
        Set-Location ".."
        New-FileInteractive -FilePath "local-test.ps1" -Content @'
# Local Testing Script
# Use this to test services locally before Azure deployment

Write-Host "Starting local SQL Server in Docker..." -ForegroundColor Yellow
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourPassword123!" -p 1433:1433 -d --name sqlserver mcr.microsoft.com/mssql/server:2022-latest

Write-Host "Waiting for SQL Server to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "Starting Product Service..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd SourceCode/ProductService; dotnet run"

Start-Sleep -Seconds 5

Write-Host "Starting Order Service..." -ForegroundColor Green  
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd SourceCode/OrderService; dotnet run"

Write-Host "Services started!" -ForegroundColor Green
Write-Host "Product Service: https://localhost:5001" -ForegroundColor Cyan
Write-Host "Order Service: https://localhost:5002" -ForegroundColor Cyan
'@ -Description "Local testing script for services"
    }
    
    "exercise03" {
        # Exercise 3: Deploy to Azure Container Apps
        
        Write-Concept -Title "Azure Container Apps Deployment" -Content @"
Deploying to Azure Container Apps:
• Container Registry: Push images to Azure Container Registry
• Container Apps: Deploy without managing infrastructure
• Environment Variables: Configure services for Azure
• Service Discovery: Built-in service-to-service communication
• Monitoring: Application Insights integration
"@
        
        Pause-ForUser
        
        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 3 requires Exercises 1 and 2 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03"
            exit 1
        }
        
        # Load Azure configuration
        Write-Info "Loading Azure configuration..."
        if (Test-Path "azure-config.ps1") {
            . .\azure-config.ps1
        } else {
            Write-Error "Azure configuration not found. Please run exercise01 first!"
            exit 1
        }
        
        # Create deployment script
        New-FileInteractive -FilePath "deploy-services.ps1" -Content @'
namespace ECommerceMS.Shared.Messaging;

public interface IMessageBroker
{
    Task PublishAsync<T>(T message, string routingKey) where T : class;
    Task SubscribeAsync<T>(string queueName, Func<T, Task> handler) where T : class;
}

public interface IEvent
{
    Guid Id { get; }
    DateTime OccurredAt { get; }
    string EventType { get; }
}

public abstract class BaseEvent : IEvent
{
    public Guid Id { get; } = Guid.NewGuid();
    public DateTime OccurredAt { get; } = DateTime.UtcNow;
    public abstract string EventType { get; }
}
'@ -Description "Azure deployment script for microservices"
        
        Write-Success "Deployment scripts created! Run .\deploy-services.ps1 to deploy to Azure."
    }
    
    "exercise04" {
        # Exercise 4: Azure Service Communication
        
        Write-Concept -Title "Azure Service Bus & Resilience" -Content @"
Azure Service Communication:
• Service Bus: Reliable message delivery
• HTTP Communication: Service-to-service calls
• Polly Resilience: Retry, circuit breaker, timeout
• Health Checks: Monitor service availability
• Distributed Tracing: Application Insights correlation
"@
        
        Pause-ForUser
        
        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 4 requires Exercises 1, 2, and 3 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04"
            exit 1
        }
        
        # Create Service Bus configuration
        New-FileInteractive -FilePath "configure-servicebus.ps1" -Content @'
version: "3.8"

services:
  # Product Catalog Service
  product-catalog:
    build:
      context: ./src/ProductCatalog.Service
      dockerfile: Dockerfile
    ports:
      - "5001:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Server=sqlserver;Database=ProductCatalogDB;User Id=sa;Password=YourPassword123!;TrustServerCertificate=true
      - RabbitMQ__ConnectionString=amqp://guest:guest@rabbitmq:5672/
    depends_on:
      - sqlserver
      - rabbitmq
    networks:
      - ecommerce-network

  # Order Management Service
  order-management:
    build:
      context: ./src/OrderManagement.Service
      dockerfile: Dockerfile
    ports:
      - "5002:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Server=sqlserver;Database=OrderManagementDB;User Id=sa;Password=YourPassword123!;TrustServerCertificate=true
      - RabbitMQ__ConnectionString=amqp://guest:guest@rabbitmq:5672/
      - Services__ProductCatalog=http://product-catalog:80
    depends_on:
      - sqlserver
      - rabbitmq
      - product-catalog
    networks:
      - ecommerce-network

  # User Management Service
  user-management:
    build:
      context: ./src/UserManagement.Service
      dockerfile: Dockerfile
    ports:
      - "5003:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Server=sqlserver;Database=UserManagementDB;User Id=sa;Password=YourPassword123!;TrustServerCertificate=true
    depends_on:
      - sqlserver
    networks:
      - ecommerce-network

  # API Gateway
  api-gateway:
    build:
      context: ./src/ApiGateway
      dockerfile: Dockerfile
    ports:
      - "5000:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - Services__ProductCatalog=http://product-catalog:80
      - Services__OrderManagement=http://order-management:80
      - Services__UserManagement=http://user-management:80
    depends_on:
      - product-catalog
      - order-management
      - user-management
    networks:
      - ecommerce-network

  # SQL Server Database
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=YourPassword123!
    ports:
      - "1433:1433"
    volumes:
      - sqlserver-data:/var/opt/mssql
    networks:
      - ecommerce-network

  # RabbitMQ Message Broker
  rabbitmq:
    image: rabbitmq:3-management
    environment:
      - RABBITMQ_DEFAULT_USER=guest
      - RABBITMQ_DEFAULT_PASS=guest
    ports:
      - "5672:5672"
      - "15672:15672"
    volumes:
      - rabbitmq-data:/var/lib/rabbitmq
    networks:
      - ecommerce-network

  # Redis Cache
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - ecommerce-network

volumes:
  sqlserver-data:
  rabbitmq-data:
  redis-data:

networks:
  ecommerce-network:
    driver: bridge
'@ -Description "Azure Service Bus configuration script"
        
        # Create communication test script
        New-FileInteractive -FilePath "test-communication.ps1" -Content @'
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["*.csproj", "./"]
RUN dotnet restore
COPY . .
RUN dotnet build -c Release -o /app/build

FROM build AS publish
RUN dotnet publish -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ServiceName.dll"]
'@ -Description "Service communication test script"
        
        Write-Success "Azure communication configuration created!"
    }
    
    "exercise05" {
        # Exercise 5: Production Features
        
        Write-Concept -Title "Production-Ready Features" -Content @"
Production Features for Azure:
• Auto-scaling: CPU and HTTP-based scaling rules
• Azure Front Door: Global load balancing and CDN
• Health Monitoring: Comprehensive health checks
• Cost Management: Monitoring and optimization
• Security: Managed identities and Key Vault
"@
        
        Pause-ForUser
        
        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 5 requires all previous exercises to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04, exercise05"
            exit 1
        }
        
        Write-Info "Configuring production features..."
        
        # Create scaling configuration
        New-FileInteractive -FilePath "configure-scaling.ps1" -Content @'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: product-catalog
  labels:
    app: product-catalog
spec:
  replicas: 2
  selector:
    matchLabels:
      app: product-catalog
  template:
    metadata:
      labels:
        app: product-catalog
    spec:
      containers:
      - name: product-catalog
        image: ecommercems/product-catalog:latest
        ports:
        - containerPort: 80
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: "Production"
        - name: ConnectionStrings__DefaultConnection
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: connection-string
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: product-catalog-service
spec:
  selector:
    app: product-catalog
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
'@ -Description "Auto-scaling configuration for Container Apps"
        
        # Create monitoring dashboard
        New-FileInteractive -FilePath "setup-monitoring.ps1" -Content @'
#!/usr/bin/env pwsh

param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet("init", "deploy", "scale", "update", "status", "cleanup", "all")]
    [string]$Action,
    
    [Parameter(Position=1)]
    [string]$ServiceName,
    
    [Parameter(Position=2)]
    [string]$Value
)

# Enable strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$StackName = "ecommerce"

function Initialize-Swarm {
    Write-Host "Initializing Docker Swarm..." -ForegroundColor Blue
    try {
        docker swarm init
        Write-Host "Docker Swarm initialized successfully!" -ForegroundColor Green
    } catch {
        Write-Host "Swarm might already be initialized or error occurred: $_" -ForegroundColor Yellow
    }
}

function Deploy-Stack {
    Write-Host "Deploying microservices stack..." -ForegroundColor Blue
    
    if (-not (Test-Path "docker-compose-production.yml")) {
        Write-Host "Error: docker-compose-production.yml not found!" -ForegroundColor Red
        exit 1
    }
    
    docker stack deploy -c docker-compose-production.yml $StackName
    
    Write-Host "Stack deployed! Checking services..." -ForegroundColor Green
    Start-Sleep -Seconds 5
    docker service ls
}

function Scale-Service {
    if (-not $ServiceName -or -not $Value) {
        Write-Host "Usage: .\deploy-docker-swarm.ps1 scale <service-name> <replicas>" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Scaling $ServiceName to $Value replicas..." -ForegroundColor Blue
    docker service scale "${StackName}_${ServiceName}=$Value"
}

function Update-Service {
    if (-not $ServiceName -or -not $Value) {
        Write-Host "Usage: .\deploy-docker-swarm.ps1 update <service-name> <image:tag>" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Updating $ServiceName to image $Value..." -ForegroundColor Blue
    docker service update --image $Value "${StackName}_${ServiceName}"
}

function Show-Status {
    Write-Host "Current stack status:" -ForegroundColor Blue
    docker stack ps $StackName
    Write-Host ""
    Write-Host "Services:" -ForegroundColor Blue
    docker service ls
}

function Cleanup-Stack {
    Write-Host "Removing stack..." -ForegroundColor Yellow
    docker stack rm $StackName
    
    Write-Host "Waiting for cleanup..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    Write-Host "Stack removed!" -ForegroundColor Green
}

# Main execution
switch ($Action) {
    "init" { Initialize-Swarm }
    "deploy" { Deploy-Stack }
    "scale" { Scale-Service }
    "update" { Update-Service }
    "status" { Show-Status }
    "cleanup" { Cleanup-Stack }
    "all" {
        Initialize-Swarm
        Deploy-Stack
    }
}
'@ -Description "Azure monitoring setup script"
        
        Write-Success "Production features configured!"
    }
}

# Final completion message
Write-Host ""
Write-Success "🎉 $ExerciseName template created successfully!"
Write-Host ""
Write-Info "📋 Next steps:"

switch ($ExerciseName) {
    "exercise01" {
        Write-Host "1. Complete the domain analysis in: " -NoNewline
        Write-Host "docs\domain-analysis.md" -ForegroundColor Cyan
        Write-Host "2. Design service boundaries and data consistency strategies"
        Write-Host "3. Create service architecture diagrams"
        Write-Host "4. Review with team or instructor before proceeding"
    }
    "exercise02" {
        Write-Host "1. Build and test each microservice independently"
        Write-Host "2. Run: " -NoNewline
        Write-Host "dotnet build" -ForegroundColor Cyan -NoNewline
        Write-Host " in each service directory"
        Write-Host "3. Test APIs using Swagger UI for each service"
        Write-Host "4. Verify database independence and data ownership"
    }
    "exercise03" {
        Write-Host "1. Implement HTTP client communication between services"
        Write-Host "2. Set up RabbitMQ message broker"
        Write-Host "3. Test synchronous and asynchronous communication"
        Write-Host "4. Implement event-driven patterns"
    }
    "exercise04" {
        Write-Host "1. Build Docker images: " -NoNewline
        Write-Host "docker-compose build" -ForegroundColor Cyan
        Write-Host "2. Run the complete system: " -NoNewline
        Write-Host "docker-compose up -d" -ForegroundColor Cyan
        Write-Host "3. Access services via API Gateway: " -NoNewline
        Write-Host "http://localhost:5000" -ForegroundColor Cyan
        Write-Host "4. Monitor health and performance metrics"
    }
    "exercise05" {
        Write-Host "1. Choose deployment option: Azure AKS, Generic K8s, or Docker Swarm"
        Write-Host "2. Configure cloud infrastructure with Terraform (if using Azure)"
        Write-Host "3. Deploy to chosen platform: " -NoNewline
        Write-Host "kubectl apply -f k8s\" -ForegroundColor Cyan
        Write-Host "4. Set up monitoring and scaling policies"
    }
}

Write-Host ""
Write-Info "📚 For detailed instructions, refer to the exercise files in the Exercises\ directory."
Write-Info "🔗 Additional microservices resources available in the Resources\ directory."
Write-Info "💡 Consider using the complete SourceCode implementation as a reference."