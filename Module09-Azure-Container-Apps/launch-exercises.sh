#!/bin/bash

# Module 9: Azure Container Apps - Interactive Exercise Launcher
# This script provides guided, hands-on exercises for containerization and Azure deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="ContainerAppsDemo"
INTERACTIVE_MODE=true
SKIP_PROJECT_CREATION=false

# Function to display colored output
echo_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
echo_success() { echo -e "${GREEN}✅ $1${NC}"; }
echo_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
echo_error() { echo -e "${RED}❌ $1${NC}"; }

# Function to explain concepts interactively
explain_concept() {
    local concept=$1
    local explanation=$2
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📚 CONCEPT: $concept${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}$explanation${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -n "Press Enter to continue..."
        read -r
        echo ""
    fi
}

# Function to show learning objectives
show_learning_objectives() {
    local exercise=$1
    
    echo -e "${BLUE}🎯 Learning Objectives for $exercise:${NC}"
    
    case $exercise in
        "Exercise 1")
            echo "• Understand Docker containerization for ASP.NET Core"
            echo "• Create optimized Dockerfile with multi-stage builds"
            echo "• Implement health checks and graceful shutdown"
            echo "• Run and test containers locally"
            ;;
        "Exercise 2")
            echo "• Deploy applications to Azure Container Apps"
            echo "• Configure Azure Container Registry"
            echo "• Set up environment variables and secrets"
            echo "• Configure scaling and ingress"
            ;;
        "Exercise 3")
            echo "• Implement CI/CD with GitHub Actions"
            echo "• Automate container building and deployment"
            echo "• Configure environment-specific deployments"
            echo "• Set up deployment approvals"
            ;;
        "Exercise 4")
            echo "• Configure Application Insights monitoring"
            echo "• Set up custom domains and SSL"
            echo "• Implement service-to-service communication"
            echo "• Configure network security"
            ;;
    esac
    echo ""
}

# Function to show what will be created
show_creation_overview() {
    local exercise=$1
    
    echo -e "${CYAN}📋 What will be created in $exercise:${NC}"
    
    case $exercise in
        "exercise01")
            echo "• ASP.NET Core Web API project"
            echo "• Optimized Dockerfile with multi-stage build"
            echo "• Health check endpoints"
            echo "• Docker Compose for local testing"
            echo "• Container optimization examples"
            ;;
        "exercise02")
            echo "• Azure CLI deployment scripts"
            echo "• Container registry configuration"
            echo "• Environment variable setup"
            echo "• Scaling configuration examples"
            echo "• Monitoring and logging setup"
            ;;
        "exercise03")
            echo "• GitHub Actions workflow files"
            echo "• Automated build and test pipeline"
            echo "• Multi-environment deployment"
            echo "• Security scanning integration"
            echo "• Deployment approval workflows"
            ;;
        "exercise04")
            echo "• Application Insights configuration"
            echo "• Custom domain setup scripts"
            echo "• Service mesh configuration"
            echo "• Network security policies"
            echo "• Advanced monitoring dashboards"
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
    echo -e "${CYAN}Module 9 - Azure Container Apps${NC}"
    echo -e "${CYAN}Available Exercises:${NC}"
    echo ""
    echo "  - exercise01: Basic Containerization"
    echo "  - exercise02: Azure Deployment"
    echo "  - exercise03: CI/CD Pipeline"
    echo "  - exercise04: Advanced Configuration"
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
echo -e "${CYAN}🚀 Module 9: Azure Container Apps${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show learning objectives
case $EXERCISE_NAME in
    "exercise01") show_learning_objectives "Exercise 1" ;;
    "exercise02") show_learning_objectives "Exercise 2" ;;
    "exercise03") show_learning_objectives "Exercise 3" ;;
    "exercise04") show_learning_objectives "Exercise 4" ;;
esac

# Show what will be created
show_creation_overview $EXERCISE_NAME

if [ "$PREVIEW_ONLY" = true ]; then
    echo_info "Preview mode - no files will be created"
    echo ""
fi

# Check prerequisites
echo_info "Checking prerequisites..."

# Check Docker
if ! command -v docker &> /dev/null; then
    echo_error "Docker is not installed. Please install Docker Desktop."
    exit 1
fi

# Check Azure CLI
if ! command -v az &> /dev/null; then
    echo_warning "Azure CLI is not installed. Some exercises may require it."
fi

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
    # Exercise 1: Basic Containerization

    explain_concept "Docker Containerization" \
"Docker Containerization for ASP.NET Core:
• Multi-stage Builds: Separate build and runtime environments
• Image Optimization: Minimize image size and attack surface
• Health Checks: Monitor container health and readiness
• Graceful Shutdown: Handle SIGTERM signals properly
• Security: Run as non-root user and minimize privileges"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_info "Creating new ASP.NET Core Web API project..."
        dotnet new webapi -n "$PROJECT_NAME" --framework net8.0
        cd "$PROJECT_NAME"
    fi

    # Create optimized Dockerfile
    create_file_interactive "Dockerfile" \
'# Multi-stage Dockerfile for ASP.NET Core
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ["ContainerAppsDemo.csproj", "./"]
RUN dotnet restore "ContainerAppsDemo.csproj"

# Copy source code and build
COPY . .
RUN dotnet build "ContainerAppsDemo.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "ContainerAppsDemo.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Create non-root user for security
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
RUN chown -R appuser:appgroup /app
USER appuser

# Copy published application
COPY --from=publish /app/publish .

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:8080/health || exit 1

# Entry point
ENTRYPOINT ["dotnet", "ContainerAppsDemo.dll"]' \
"Optimized multi-stage Dockerfile with security best practices"

    # Create health check endpoint
    create_file_interactive "Controllers/HealthController.cs" \
'using Microsoft.AspNetCore.Mvc;

namespace ContainerAppsDemo.Controllers;

[ApiController]
[Route("[controller]")]
public class HealthController : ControllerBase
{
    private readonly ILogger<HealthController> _logger;

    public HealthController(ILogger<HealthController> logger)
    {
        _logger = logger;
    }

    [HttpGet]
    public IActionResult Get()
    {
        _logger.LogInformation("Health check requested");

        var healthStatus = new
        {
            Status = "Healthy",
            Timestamp = DateTime.UtcNow,
            Version = "1.0.0",
            Environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Production"
        };

        return Ok(healthStatus);
    }

    [HttpGet("ready")]
    public IActionResult Ready()
    {
        // Add readiness checks here (database connectivity, external services, etc.)
        _logger.LogInformation("Readiness check requested");

        var readinessStatus = new
        {
            Status = "Ready",
            Timestamp = DateTime.UtcNow,
            Checks = new
            {
                Database = "Connected",
                ExternalServices = "Available"
            }
        };

        return Ok(readinessStatus);
    }

    [HttpGet("live")]
    public IActionResult Live()
    {
        _logger.LogInformation("Liveness check requested");

        var livenessStatus = new
        {
            Status = "Alive",
            Timestamp = DateTime.UtcNow,
            Uptime = Environment.TickCount64
        };

        return Ok(livenessStatus);
    }
}' \
"Health check endpoints for container monitoring"

    # Create Docker Compose for local testing
    create_file_interactive "docker-compose.yml" \
'version: "3.8"

services:
  containerappsdemo:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:8080
    healthcheck:
      test: ["CMD", "curl", "--fail", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    restart: unless-stopped

  # Optional: Add a reverse proxy
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - containerappsdemo
    restart: unless-stopped' \
"Docker Compose configuration for local development and testing"

    # Create nginx configuration
    create_file_interactive "nginx.conf" \
'events {
    worker_connections 1024;
}

http {
    upstream app {
        server containerappsdemo:8080;
    }

    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /health {
            proxy_pass http://app/health;
            access_log off;
        }
    }
}' \
"Nginx reverse proxy configuration"

elif [[ $EXERCISE_NAME == "exercise02" ]]; then
    # Exercise 2: Azure Deployment

    explain_concept "Azure Container Apps Deployment" \
"Azure Container Apps Deployment:
• Serverless Containers: Focus on application, not infrastructure
• Built-in Autoscaling: Scale to zero and beyond based on demand
• Container Registry: Secure image storage and management
• Environment Variables: Configuration without rebuilding images
• Ingress Configuration: External and internal traffic routing"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 2 requires Exercise 1 to be completed first!"
        echo_info "Please run: ./launch-exercises.sh exercise01"
        exit 1
    fi

    # Create Azure deployment script
    create_file_interactive "deploy-to-azure.sh" \
'#!/bin/bash

# Azure Container Apps Deployment Script
set -e

# Configuration variables
RESOURCE_GROUP="rg-containerapp-demo"
LOCATION="eastus"
ENVIRONMENT="env-containerapp-demo"
CONTAINER_APP_NAME="containerappsdemo"
ACR_NAME="acrcontainerappsdemo$(date +%s)"

echo "🚀 Starting Azure Container Apps deployment..."

# Check if Azure CLI is logged in
if ! az account show &> /dev/null; then
    echo "❌ Please login to Azure CLI first: az login"
    exit 1
fi

# Install Container Apps extension
echo "📦 Installing Azure Container Apps extension..."
az extension add --name containerapp --upgrade

# Register required providers
echo "🔧 Registering Azure providers..."
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights

# Create resource group
echo "🏗️  Creating resource group..."
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION

# Create Container Apps environment
echo "🌍 Creating Container Apps environment..."
az containerapp env create \
    --name $ENVIRONMENT \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION

# Create Azure Container Registry
echo "📦 Creating Azure Container Registry..."
az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME \
    --sku Basic \
    --admin-enabled true

# Build and push image to ACR
echo "🔨 Building and pushing container image..."
az acr build \
    --registry $ACR_NAME \
    --image containerappsdemo:v1.0 \
    .

# Get ACR credentials
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value --output tsv)

# Deploy container app
echo "🚀 Deploying container app..."
az containerapp create \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --environment $ENVIRONMENT \
    --image $ACR_LOGIN_SERVER/containerappsdemo:v1.0 \
    --registry-server $ACR_LOGIN_SERVER \
    --registry-username $ACR_USERNAME \
    --registry-password $ACR_PASSWORD \
    --target-port 8080 \
    --ingress external \
    --cpu 0.25 \
    --memory 0.5Gi \
    --min-replicas 1 \
    --max-replicas 3 \
    --env-vars ASPNETCORE_ENVIRONMENT=Production

# Get the application URL
APP_URL=$(az containerapp show \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --query properties.configuration.ingress.fqdn \
    --output tsv)

echo "✅ Deployment completed successfully!"
echo "🌐 Application URL: https://$APP_URL"
echo "🏥 Health check: https://$APP_URL/health"
echo "📊 Swagger UI: https://$APP_URL/swagger"

# Save deployment info
cat > deployment-info.txt << EOF
Deployment Information
=====================
Resource Group: $RESOURCE_GROUP
Container App: $CONTAINER_APP_NAME
Container Registry: $ACR_NAME
Application URL: https://$APP_URL
Health Check: https://$APP_URL/health

Useful Commands:
- View logs: az containerapp logs show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --follow
- Update app: az containerapp update --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --image $ACR_LOGIN_SERVER/containerappsdemo:v2.0
- Scale app: az containerapp update --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --min-replicas 2 --max-replicas 5
EOF

echo "📄 Deployment information saved to deployment-info.txt"' \
"Complete Azure deployment script with Container Registry and Container Apps"

elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    # Exercise 3: CI/CD Pipeline

    explain_concept "CI/CD with GitHub Actions" \
"CI/CD Pipeline for Container Apps:
• Automated Building: Build container images on code changes
• Security Scanning: Scan images for vulnerabilities
• Multi-Environment: Deploy to dev, staging, and production
• Approval Workflows: Manual approval for production deployments
• Rollback Strategies: Quick rollback on deployment failures"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 3 requires Exercises 1 and 2 to be completed first!"
        echo_info "Please run exercises in order: exercise01, exercise02, exercise03"
        exit 1
    fi

    # Create GitHub Actions workflow directory
    mkdir -p .github/workflows

    # Create main CI/CD workflow
    create_file_interactive ".github/workflows/deploy-container-app.yml" \
'name: Deploy to Azure Container Apps

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  AZURE_CONTAINER_REGISTRY: acrcontainerappsdemo
  CONTAINER_APP_NAME: containerappsdemo
  RESOURCE_GROUP: rg-containerapp-demo
  CONTAINER_APP_ENVIRONMENT: env-containerapp-demo

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: 8.0.x

    - name: Restore dependencies
      run: dotnet restore

    - name: Build application
      run: dotnet build --no-restore --configuration Release

    - name: Run tests
      run: dotnet test --no-build --configuration Release --verbosity normal

    - name: Publish application
      run: dotnet publish --no-build --configuration Release --output ./publish

    - name: Upload build artifacts
      uses: actions/upload-artifact@v3
      with:
        name: published-app
        path: ./publish

  security-scan:
    runs-on: ubuntu-latest
    needs: build-and-test

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: fs
        scan-ref: .
        format: sarif
        output: trivy-results.sarif

    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: trivy-results.sarif

  deploy-dev:
    runs-on: ubuntu-latest
    needs: [build-and-test, security-scan]
    if: github.ref == '"'"'refs/heads/develop'"'"'
    environment: development

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Build and push to ACR
      run: |
        az acr build \
          --registry ${{ env.AZURE_CONTAINER_REGISTRY }} \
          --image ${{ env.CONTAINER_APP_NAME }}:dev-${{ github.sha }} \
          .

    - name: Deploy to Container Apps (Dev)
      run: |
        az containerapp update \
          --name ${{ env.CONTAINER_APP_NAME }}-dev \
          --resource-group ${{ env.RESOURCE_GROUP }} \
          --image ${{ env.AZURE_CONTAINER_REGISTRY }}.azurecr.io/${{ env.CONTAINER_APP_NAME }}:dev-${{ github.sha }}

  deploy-staging:
    runs-on: ubuntu-latest
    needs: [build-and-test, security-scan]
    if: github.ref == '"'"'refs/heads/main'"'"'
    environment: staging

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Build and push to ACR
      run: |
        az acr build \
          --registry ${{ env.AZURE_CONTAINER_REGISTRY }} \
          --image ${{ env.CONTAINER_APP_NAME }}:staging-${{ github.sha }} \
          .

    - name: Deploy to Container Apps (Staging)
      run: |
        az containerapp update \
          --name ${{ env.CONTAINER_APP_NAME }}-staging \
          --resource-group ${{ env.RESOURCE_GROUP }} \
          --image ${{ env.AZURE_CONTAINER_REGISTRY }}.azurecr.io/${{ env.CONTAINER_APP_NAME }}:staging-${{ github.sha }}

  deploy-production:
    runs-on: ubuntu-latest
    needs: deploy-staging
    if: github.ref == '"'"'refs/heads/main'"'"'
    environment: production

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Build and push to ACR
      run: |
        az acr build \
          --registry ${{ env.AZURE_CONTAINER_REGISTRY }} \
          --image ${{ env.CONTAINER_APP_NAME }}:prod-${{ github.sha }} \
          .

    - name: Deploy to Container Apps (Production)
      run: |
        az containerapp update \
          --name ${{ env.CONTAINER_APP_NAME }} \
          --resource-group ${{ env.RESOURCE_GROUP }} \
          --image ${{ env.AZURE_CONTAINER_REGISTRY }}.azurecr.io/${{ env.CONTAINER_APP_NAME }}:prod-${{ github.sha }}

    - name: Create GitHub Release
      uses: actions/create-release@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        tag_name: v${{ github.run_number }}
        release_name: Release v${{ github.run_number }}
        body: |
          Automated release from commit ${{ github.sha }}

          Deployed to production: ${{ env.CONTAINER_APP_NAME }}
        draft: false
        prerelease: false' \
"Complete CI/CD pipeline with multi-environment deployment and security scanning"

elif [[ $EXERCISE_NAME == "exercise04" ]]; then
    # Exercise 4: Advanced Configuration

    explain_concept "Advanced Container Apps Configuration" \
"Advanced Configuration Topics:
• Application Insights: Deep application monitoring and telemetry
• Custom Domains: SSL certificates and domain configuration
• Service Communication: Service-to-service authentication
• Network Security: Virtual networks and private endpoints
• Advanced Scaling: Custom scaling rules and metrics"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 4 requires Exercises 1, 2, and 3 to be completed first!"
        echo_info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04"
        exit 1
    fi

    # Create Application Insights configuration
    create_file_interactive "Program.cs" \
'using Microsoft.ApplicationInsights.Extensibility;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add Application Insights
builder.Services.AddApplicationInsightsTelemetry(options =>
{
    options.ConnectionString = builder.Configuration.GetConnectionString("ApplicationInsights");
});

// Add health checks
builder.Services.AddHealthChecks()
    .AddCheck("self", () => Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckResult.Healthy());

// Configure logging
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddApplicationInsights();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();

// Map health checks
app.MapHealthChecks("/health");
app.MapHealthChecks("/health/ready");
app.MapHealthChecks("/health/live");

app.MapControllers();

// Graceful shutdown
var lifetime = app.Services.GetRequiredService<IHostApplicationLifetime>();
lifetime.ApplicationStopping.Register(() =>
{
    app.Logger.LogInformation("Application is shutting down gracefully...");
});

app.Run();' \
"Enhanced Program.cs with Application Insights and health checks"

    # Create advanced scaling configuration
    create_file_interactive "scaling-config.bicep" \
'param containerAppName string
param location string = resourceGroup().location
param environmentId string

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: containerAppName
  location: location
  properties: {
    environmentId: environmentId
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
        allowInsecure: false
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
      }
      secrets: [
        {
          name: 'app-insights-connection-string'
          value: 'InstrumentationKey=your-key-here'
        }
      ]
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              secretRef: 'app-insights-connection-string'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
        rules: [
          {
            name: 'http-scaling'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
          {
            name: 'cpu-scaling'
            custom: {
              type: 'cpu'
              metadata: {
                type: 'Utilization'
                value: '70'
              }
            }
          }
        ]
      }
    }
  }
}' \
"Advanced scaling configuration with Bicep template"

    # Create exercise completion guide
    create_file_interactive "EXERCISE_04_GUIDE.md" \
'# Exercise 4: Advanced Configuration

## 🎯 Objective
Configure advanced features including monitoring, custom domains, and service communication.

## ⏱️ Time Allocation
**Total Time**: 30 minutes
- Application Insights Setup: 10 minutes
- Custom Domain Configuration: 10 minutes
- Service Communication: 10 minutes

## 🚀 Getting Started

### Step 1: Configure Application Insights
```bash
# Create Application Insights resource
az monitor app-insights component create \
  --app containerappsdemo-insights \
  --location eastus \
  --resource-group rg-containerapp-demo

# Get connection string
az monitor app-insights component show \
  --app containerappsdemo-insights \
  --resource-group rg-containerapp-demo \
  --query connectionString
```

### Step 2: Set up Custom Domain
```bash
# Add custom domain
az containerapp hostname add \
  --hostname yourdomain.com \
  --name containerappsdemo \
  --resource-group rg-containerapp-demo

# Bind SSL certificate
az containerapp ssl upload \
  --certificate-file cert.pfx \
  --certificate-password password \
  --hostname yourdomain.com \
  --name containerappsdemo \
  --resource-group rg-containerapp-demo
```

### Step 3: Configure Service Communication
```bash
# Enable service-to-service communication
az containerapp update \
  --name containerappsdemo \
  --resource-group rg-containerapp-demo \
  --set-env-vars SERVICE_ENDPOINT=https://api.internal
```

## ✅ Success Criteria
- [ ] Application Insights is collecting telemetry
- [ ] Custom domain is configured with SSL
- [ ] Service communication is working
- [ ] Advanced scaling rules are active
- [ ] Monitoring dashboards are set up

## 🧪 Testing Your Implementation
1. Check Application Insights for telemetry data
2. Verify custom domain resolves correctly
3. Test service-to-service communication
4. Monitor scaling behavior under load
5. Review security configurations

## 🎯 Learning Outcomes
After completing this exercise, you should understand:
- Application Insights integration and configuration
- Custom domain and SSL certificate management
- Service mesh and communication patterns
- Advanced scaling strategies
- Production monitoring and alerting
' \
"Complete exercise guide for Advanced Configuration"

fi

# Final completion message
echo ""
echo_success "🎉 $EXERCISE_NAME template created successfully!"
echo ""
echo_info "📋 Next steps:"

case $EXERCISE_NAME in
    "exercise01")
        echo "1. Build the container: ${CYAN}docker build -t containerappsdemo .${NC}"
        echo "2. Run locally: ${CYAN}docker run -p 8080:8080 containerappsdemo${NC}"
        echo "3. Test health check: ${CYAN}curl http://localhost:8080/health${NC}"
        echo "4. Use Docker Compose: ${CYAN}docker-compose up${NC}"
        ;;
    "exercise02")
        echo "1. Make the script executable: ${CYAN}chmod +x deploy-to-azure.sh${NC}"
        echo "2. Login to Azure: ${CYAN}az login${NC}"
        echo "3. Run deployment: ${CYAN}./deploy-to-azure.sh${NC}"
        echo "4. Check deployment-info.txt for URLs and commands"
        ;;
    "exercise03")
        echo "1. Commit and push to GitHub repository"
        echo "2. Set up Azure service principal for GitHub Actions"
        echo "3. Configure repository secrets (AZURE_CREDENTIALS)"
        echo "4. Create environment protection rules"
        echo "5. Monitor workflow runs in GitHub Actions"
        ;;
    "exercise04")
        echo "1. Deploy the enhanced application with monitoring"
        echo "2. Configure Application Insights connection string"
        echo "3. Set up custom domain and SSL certificate"
        echo "4. Test advanced scaling rules"
        echo "5. Monitor application performance and health"
        ;;
esac

echo ""
echo_info "📚 For detailed instructions, refer to the exercise guide files created."
echo_info "🔗 Additional resources available in the Resources/ directory."

# Make scripts executable
if [ -f "deploy-to-azure.sh" ]; then
    chmod +x deploy-to-azure.sh
fi
