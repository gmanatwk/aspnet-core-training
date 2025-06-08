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
$ProjectName = "ECommerceMS"
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
            Write-Host "Service Decomposition & Domain-Driven Design:" -ForegroundColor Cyan
            Write-Host "  🏗️  1. Analyze monolithic applications for service boundaries"
            Write-Host "  🏗️  2. Apply Domain-Driven Design (DDD) principles"
            Write-Host "  🏗️  3. Identify bounded contexts and aggregates"
            Write-Host "  🏗️  4. Design data consistency strategies"
            Write-Host ""
            Write-Host "Microservices concepts:" -ForegroundColor Yellow
            Write-Host "  • Service decomposition strategies"
            Write-Host "  • Bounded context identification"
            Write-Host "  • Data ownership patterns"
            Write-Host "  • Saga pattern design"
        }
        "exercise02" {
            Write-Host "Building Core Microservices:" -ForegroundColor Cyan
            Write-Host "  🏗️  1. Create independent ASP.NET Core services"
            Write-Host "  🏗️  2. Implement service-specific databases"
            Write-Host "  🏗️  3. Design RESTful APIs for inter-service communication"
            Write-Host "  🏗️  4. Set up shared libraries and common patterns"
            Write-Host ""
            Write-Host "Microservices concepts:" -ForegroundColor Yellow
            Write-Host "  • Service independence and autonomy"
            Write-Host "  • Database per service pattern"
            Write-Host "  • API contract design"
            Write-Host "  • Shared library management"
        }
        "exercise03" {
            Write-Host "Inter-Service Communication Patterns:" -ForegroundColor Cyan
            Write-Host "  🏗️  1. Implement synchronous HTTP communication"
            Write-Host "  🏗️  2. Add asynchronous messaging with RabbitMQ"
            Write-Host "  🏗️  3. Handle distributed data consistency"
            Write-Host "  🏗️  4. Implement event-driven architecture"
            Write-Host ""
            Write-Host "Microservices concepts:" -ForegroundColor Yellow
            Write-Host "  • Synchronous vs asynchronous communication"
            Write-Host "  • Message broker integration"
            Write-Host "  • Event sourcing patterns"
            Write-Host "  • Distributed transaction management"
        }
        "exercise04" {
            Write-Host "Production-Ready Deployment:" -ForegroundColor Cyan
            Write-Host "  🏗️  1. Containerize microservices with Docker"
            Write-Host "  🏗️  2. Orchestrate services with Docker Compose"
            Write-Host "  🏗️  3. Implement monitoring and observability"
            Write-Host "  🏗️  4. Add resilience patterns (Circuit Breaker, Retry)"
            Write-Host ""
            Write-Host "Microservices concepts:" -ForegroundColor Yellow
            Write-Host "  • Container orchestration"
            Write-Host "  • Service discovery and load balancing"
            Write-Host "  • Distributed tracing and monitoring"
            Write-Host "  • Fault tolerance and resilience"
        }
        "exercise05" {
            Write-Host "Cloud Deployment Options:" -ForegroundColor Cyan
            Write-Host "  🏗️  1. Deploy to Azure Kubernetes Service (AKS)"
            Write-Host "  🏗️  2. Use Terraform for Infrastructure as Code"
            Write-Host "  🏗️  3. Configure production monitoring and scaling"
            Write-Host "  🏗️  4. Implement CI/CD pipelines"
            Write-Host ""
            Write-Host "Microservices concepts:" -ForegroundColor Yellow
            Write-Host "  • Cloud-native deployment strategies"
            Write-Host "  • Infrastructure as Code (IaC)"
            Write-Host "  • Auto-scaling and load management"
            Write-Host "  • Production monitoring and alerting"
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
    Write-Host "Module 13 - Building Microservices" -ForegroundColor Cyan
    Write-Host "Available Exercises:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  - exercise01: Service Decomposition & Domain-Driven Design"
    Write-Host "  - exercise02: Building Core Microservices"
    Write-Host "  - exercise03: Inter-Service Communication Patterns"
    Write-Host "  - exercise04: Production-Ready Deployment"
    Write-Host "  - exercise05: Cloud Deployment Options"
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
Write-Host "🏗️ Module 13: Building Microservices" -ForegroundColor Magenta
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

# Check Docker
try {
    $dockerVersion = docker --version
    Write-Success "Docker is installed: $dockerVersion"
} catch {
    Write-Warning "Docker is not installed. Some exercises may require it."
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
        # Exercise 1: Service Decomposition & Domain-Driven Design
        
        Write-Concept -Title "Domain-Driven Design for Microservices" -Content @"
Domain-Driven Design (DDD) for Microservices:
• Bounded Contexts: Define clear boundaries around business domains
• Ubiquitous Language: Shared vocabulary within each context
• Aggregates: Consistency boundaries for data operations
• Domain Events: Communication between bounded contexts
• Service Boundaries: Each microservice owns a bounded context
"@
        
        Pause-ForUser
        
        if (-not $SkipProjectCreation) {
            Write-Info "Creating microservices design workspace..."
            New-Item -ItemType Directory -Path $ProjectName -Force | Out-Null
            Set-Location $ProjectName
            New-Item -ItemType Directory -Path "docs", "analysis", "design" -Force | Out-Null
        }
        
        # Create domain analysis template
        New-FileInteractive -FilePath "docs\domain-analysis.md" -Content @'
# E-Commerce Domain Analysis

## Business Capabilities Analysis

### 1. User Management
- **Purpose**: Manage user accounts, authentication, and personal data
- **Key Entities**: User, Profile, Authentication, Preferences, Role
- **Business Rules**:
  - Unique email addresses required
  - Password complexity requirements
  - Data privacy compliance (GDPR)
  - Role-based access control
- **External Dependencies**: Email service, OAuth providers, identity verification

### 2. Product Catalog
- **Purpose**: Manage product information, categories, and inventory
- **Key Entities**: Product, Category, Inventory, SKU, Pricing
- **Business Rules**:
  - Unique SKU per product
  - Category hierarchy management
  - Inventory tracking and alerts
  - Price history and promotions
- **External Dependencies**: Image storage, search indexing, supplier systems

### 3. Shopping Cart
- **Purpose**: Manage customer shopping sessions and cart items
- **Key Entities**: Cart, CartItem, Session, WishList
- **Business Rules**:
  - Cart expiration policies
  - Inventory reservation during checkout
  - Guest vs authenticated cart handling
  - Cart merging on login
- **External Dependencies**: Product catalog, user management

### 4. Order Processing
- **Purpose**: Handle order creation, payment, and fulfillment
- **Key Entities**: Order, OrderItem, Payment, Invoice, Fulfillment
- **Business Rules**:
  - Order state transitions
  - Payment processing workflows
  - Inventory allocation and reservation
  - Order cancellation policies
- **External Dependencies**: Payment gateways, shipping providers, inventory

### 5. Inventory Management
- **Purpose**: Track stock levels, reservations, and replenishment
- **Key Entities**: Stock, Reservation, Replenishment, Warehouse
- **Business Rules**:
  - Real-time stock tracking
  - Reservation timeout handling
  - Low stock alerts
  - Multi-warehouse support
- **External Dependencies**: Supplier systems, warehouse management

### 6. Notifications
- **Purpose**: Send communications to users and administrators
- **Key Entities**: Notification, Template, Channel, Subscription
- **Business Rules**:
  - Multi-channel delivery (email, SMS, push)
  - User preference management
  - Delivery confirmation tracking
  - Template versioning
- **External Dependencies**: Email providers, SMS gateways, push notification services

## Bounded Contexts Identification

### Context 1: Identity & Access Management
- **Ubiquitous Language**: User, Account, Authentication, Authorization, Profile, Role, Permission
- **Entities**: User, Role, Permission, Session, Profile
- **Value Objects**: Email, Password, ProfilePicture, Address
- **Aggregates**: User (with Profile, Preferences, Roles)
- **Services**: AuthenticationService, AuthorizationService, ProfileService
- **Boundaries**: Includes user data and access control, excludes order history and preferences

### Context 2: Product Catalog Management
- **Ubiquitous Language**: Product, Category, SKU, Inventory, Price, Catalog
- **Entities**: Product, Category, InventoryItem, PriceHistory
- **Value Objects**: SKU, Price, ProductImage, ProductAttributes
- **Aggregates**: Product (with Inventory, Pricing), Category (with Products)
- **Services**: CatalogService, InventoryService, PricingService
- **Boundaries**: Includes product data and inventory, excludes order processing

### Context 3: Order Management
- **Ubiquitous Language**: Order, OrderItem, Payment, Fulfillment, Invoice, Shipping
- **Entities**: Order, OrderItem, Payment, Shipment, Invoice
- **Value Objects**: OrderNumber, PaymentMethod, ShippingAddress, OrderStatus
- **Aggregates**: Order (with OrderItems, Payment, Shipment)
- **Services**: OrderService, PaymentService, FulfillmentService
- **Boundaries**: Includes order lifecycle, excludes product catalog and user management

### Context 4: Communication & Notifications
- **Ubiquitous Language**: Notification, Message, Template, Channel, Subscription
- **Entities**: Notification, NotificationTemplate, Subscription
- **Value Objects**: MessageContent, DeliveryChannel, NotificationStatus
- **Aggregates**: Notification (with Template, Delivery)
- **Services**: NotificationService, TemplateService, DeliveryService
- **Boundaries**: Includes all communication, excludes business domain logic

## Service Boundary Recommendations

Based on the bounded context analysis, we recommend the following microservices:

1. **User Management Service** (Identity & Access Management context)
2. **Product Catalog Service** (Product Catalog Management context)
3. **Order Management Service** (Order Management context)
4. **Notification Service** (Communication & Notifications context)
5. **API Gateway** (Cross-cutting concern for routing and security)

Each service will own its data and expose well-defined APIs for inter-service communication.
'@ -Description "Comprehensive domain analysis for e-commerce microservices decomposition"
    }
    
    "exercise02" {
        # Exercise 2: Building Core Microservices
        
        Write-Concept -Title "Microservices Implementation Patterns" -Content @"
Core Microservices Implementation:
• Service Independence: Each service has its own database and deployment
• API-First Design: Well-defined contracts between services
• Shared Libraries: Common models and utilities without tight coupling
• Database per Service: Data ownership and independence
• Service Registration: Discovery and health monitoring
"@
        
        Pause-ForUser
        
        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 2 requires Exercise 1 to be completed first!"
            Write-Info "Please run: .\launch-exercises.ps1 exercise01"
            exit 1
        }
        
        Write-Info "Setting up microservices solution structure..."
        
        # Create solution structure
        dotnet new sln -n ECommerceMS
        
        # Create shared library
        New-Item -ItemType Directory -Path "src\SharedLibraries" -Force | Out-Null
        Set-Location "src\SharedLibraries"
        dotnet new classlib -n ECommerceMS.Shared --framework net8.0
        dotnet add ECommerceMS.Shared package Microsoft.Extensions.Logging
        dotnet add ECommerceMS.Shared package System.ComponentModel.DataAnnotations
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
        
        Write-Success "Microservices solution structure created successfully!"
    }
    
    "exercise03" {
        # Exercise 3: Inter-Service Communication Patterns
        
        Write-Concept -Title "Inter-Service Communication" -Content @"
Microservices Communication Patterns:
• Synchronous Communication: HTTP/REST for immediate responses
• Asynchronous Messaging: Event-driven communication via message brokers
• Service Discovery: Dynamic service location and health checking
• Circuit Breaker: Fault tolerance for service dependencies
• Event Sourcing: Capturing state changes as events
"@
        
        Pause-ForUser
        
        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 3 requires Exercises 1 and 2 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03"
            exit 1
        }
        
        # Add RabbitMQ and HTTP client packages
        Write-Info "Adding communication packages to services..."
        
        # Add to each service
        $services = @("ProductCatalog.Service", "OrderManagement.Service", "UserManagement.Service")
        foreach ($service in $services) {
            if (Test-Path "src\$service") {
                Set-Location "src\$service"
                dotnet add package RabbitMQ.Client
                dotnet add package Microsoft.Extensions.Http
                dotnet add package Polly.Extensions.Http
                Set-Location "..\..\"
            }
        }
        
        # Create message broker configuration
        New-FileInteractive -FilePath "src\SharedLibraries\ECommerceMS.Shared\Messaging\IMessageBroker.cs" -Content @'
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
'@ -Description "Message broker interface and base event definitions"
        
        Write-Success "Communication patterns added to microservices!"
    }
    
    "exercise04" {
        # Exercise 4: Production-Ready Deployment
        
        Write-Concept -Title "Production Deployment Patterns" -Content @"
Production-Ready Microservices:
• Containerization: Docker containers for consistent deployment
• Orchestration: Docker Compose for local development
• Health Checks: Service health monitoring and readiness probes
• Monitoring: Application Insights and distributed tracing
• Resilience: Circuit breakers, retries, and timeout patterns
"@
        
        Pause-ForUser
        
        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 4 requires Exercises 1, 2, and 3 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04"
            exit 1
        }
        
        # Create Docker Compose configuration
        New-FileInteractive -FilePath "docker-compose.yml" -Content @'
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
'@ -Description "Complete Docker Compose configuration for microservices deployment"
        
        # Create Dockerfile template for services
        New-FileInteractive -FilePath "src\Dockerfile.template" -Content @'
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
'@ -Description "Dockerfile template for microservices"
        
        Write-Success "Docker deployment configuration created!"
    }
    
    "exercise05" {
        # Exercise 5: Cloud Deployment Options
        
        Write-Concept -Title "Cloud-Native Deployment" -Content @"
Cloud Deployment Strategies:
• Azure Kubernetes Service (AKS): Managed Kubernetes for Azure
• Infrastructure as Code: Terraform for reproducible deployments
• Generic Kubernetes: Multi-cloud deployment flexibility
• Docker Swarm: Simpler orchestration for smaller deployments
• CI/CD Integration: Automated deployment pipelines
"@
        
        Pause-ForUser
        
        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 5 requires all previous exercises to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04, exercise05"
            exit 1
        }
        
        Write-Info "Setting up cloud deployment configurations..."
        
        # Create Kubernetes deployment manifests
        New-Item -ItemType Directory -Path "k8s" -Force | Out-Null
        
        New-FileInteractive -FilePath "k8s\product-catalog-deployment.yaml" -Content @'
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
'@ -Description "Kubernetes deployment manifest for Product Catalog service"
        
        # Create Docker Swarm deployment script
        New-FileInteractive -FilePath "deploy-docker-swarm.ps1" -Content @'
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
'@ -Description "Docker Swarm deployment script"
        
        # Make the script executable
        if (Test-Path "deploy-docker-swarm.ps1") {
            $scriptPath = Resolve-Path "deploy-docker-swarm.ps1"
            Write-Host "Created deployment script: $scriptPath" -ForegroundColor Green
        }
        
        Write-Success "Cloud deployment configurations created!"
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