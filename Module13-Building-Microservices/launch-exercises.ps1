#!/usr/bin/env pwsh

# Module 13: Building Microservices - Interactive Exercise Launcher (PowerShell)
# This script provides guided, hands-on exercises for microservices architecture

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
$ProjectName = "MicroservicesDemo"
$InteractiveMode = -not $Auto

# Function to display colored output
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Blue }
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }

# Function to explain concepts interactively
function Explain-Concept {
    param($Concept, $Explanation)
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host "🏗️ MICROSERVICES CONCEPT: $Concept" -ForegroundColor Blue
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host $Explanation -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
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
    
    Write-Host "🎯 Microservices Objectives for $Exercise:" -ForegroundColor Blue
    
    switch ($Exercise) {
        "exercise01" {
            Write-Host "Service Decomposition & Domain-Driven Design:" -ForegroundColor Cyan
            Write-Host "  🏗️ 1. Domain analysis and bounded context identification"
            Write-Host "  🏗️ 2. Service decomposition strategies"
            Write-Host "  🏗️ 3. Data ownership and consistency patterns"
            Write-Host "  🏗️ 4. Microservices architecture principles"
            Write-Host ""
            Write-Host "DDD concepts:" -ForegroundColor Yellow
            Write-Host "  • Bounded contexts and aggregates"
            Write-Host "  • Domain events and commands"
            Write-Host "  • Service boundaries definition"
            Write-Host "  • Data consistency strategies"
        }
        "exercise02" {
            Write-Host "Building Core Microservices:" -ForegroundColor Cyan
            Write-Host "  🏗️ 1. Individual microservice implementation"
            Write-Host "  🏗️ 2. Service-specific data storage"
            Write-Host "  🏗️ 3. API design and versioning"
            Write-Host "  🏗️ 4. Service configuration and deployment"
            Write-Host ""
            Write-Host "Implementation concepts:" -ForegroundColor Yellow
            Write-Host "  • Service independence"
            Write-Host "  • Database per service"
            Write-Host "  • API gateway patterns"
            Write-Host "  • Service discovery"
        }
        "exercise03" {
            Write-Host "Inter-Service Communication Patterns:" -ForegroundColor Cyan
            Write-Host "  🏗️ 1. Synchronous communication (HTTP/REST)"
            Write-Host "  🏗️ 2. Asynchronous messaging patterns"
            Write-Host "  🏗️ 3. Event-driven architecture"
            Write-Host "  🏗️ 4. Circuit breaker and retry patterns"
            Write-Host ""
            Write-Host "Communication concepts:" -ForegroundColor Yellow
            Write-Host "  • Service-to-service calls"
            Write-Host "  • Message queues and events"
            Write-Host "  • Resilience patterns"
            Write-Host "  • Distributed tracing"
        }
        "exercise04" {
            Write-Host "Production-Ready Deployment:" -ForegroundColor Cyan
            Write-Host "  🏗️ 1. Containerization with Docker"
            Write-Host "  🏗️ 2. Orchestration with Docker Compose/Kubernetes"
            Write-Host "  🏗️ 3. Service mesh implementation"
            Write-Host "  🏗️ 4. Monitoring and observability"
            Write-Host ""
            Write-Host "Deployment concepts:" -ForegroundColor Yellow
            Write-Host "  • Container orchestration"
            Write-Host "  • Service mesh patterns"
            Write-Host "  • Distributed monitoring"
            Write-Host "  • Blue-green deployments"
        }
        "exercise05" {
            Write-Host "Advanced Patterns & Governance:" -ForegroundColor Cyan
            Write-Host "  🏗️ 1. Saga pattern for distributed transactions"
            Write-Host "  🏗️ 2. CQRS and Event Sourcing"
            Write-Host "  🏗️ 3. API versioning and backward compatibility"
            Write-Host "  🏗️ 4. Microservices governance and best practices"
            Write-Host ""
            Write-Host "Advanced concepts:" -ForegroundColor Yellow
            Write-Host "  • Distributed transaction patterns"
            Write-Host "  • Event sourcing architecture"
            Write-Host "  • API evolution strategies"
            Write-Host "  • Organizational patterns"
        }
    }
    Write-Host ""
}

# Function to show what will be created
function Show-CreationOverview {
    param($Exercise)
    
    Write-Host "📋 Microservices Components for $Exercise:" -ForegroundColor Cyan
    
    switch ($Exercise) {
        "exercise01" {
            Write-Host "• Domain analysis templates and worksheets"
            Write-Host "• Bounded context documentation"
            Write-Host "• Service decomposition guidelines"
            Write-Host "• Data ownership mapping"
            Write-Host "• Architecture decision records"
        }
        "exercise02" {
            Write-Host "• Product Catalog microservice"
            Write-Host "• Order Management microservice"
            Write-Host "• User Management microservice"
            Write-Host "• Individual service databases"
            Write-Host "• Service-specific configurations"
        }
        "exercise03" {
            Write-Host "• HTTP client communication patterns"
            Write-Host "• Message queue implementations"
            Write-Host "• Event-driven communication"
            Write-Host "• Circuit breaker implementations"
            Write-Host "• Resilience and retry policies"
        }
        "exercise04" {
            Write-Host "• Docker containerization setup"
            Write-Host "• Docker Compose orchestration"
            Write-Host "• Kubernetes deployment manifests"
            Write-Host "• Service mesh configuration"
            Write-Host "• Monitoring and logging setup"
        }
        "exercise05" {
            Write-Host "• Saga pattern implementations"
            Write-Host "• CQRS and Event Sourcing examples"
            Write-Host "• API versioning strategies"
            Write-Host "• Governance frameworks"
            Write-Host "• Best practices documentation"
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
    Write-Host "Module 13 - Building Microservices" -ForegroundColor Cyan
    Write-Host "Available Exercises:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  - exercise01: Service Decomposition & Domain-Driven Design"
    Write-Host "  - exercise02: Building Core Microservices"
    Write-Host "  - exercise03: Inter-Service Communication Patterns"
    Write-Host "  - exercise04: Production-Ready Deployment"
    Write-Host "  - exercise05: Advanced Patterns & Governance"
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
$ValidExercises = @("exercise01", "exercise02", "exercise03", "exercise04", "exercise05")
if ($ExerciseName -notin $ValidExercises) {
    Write-Error "Unknown exercise: $ExerciseName"
    Write-Host ""
    Show-Exercises
    exit 1
}

# Welcome message
Write-Host "🏗️ Module 13: Building Microservices" -ForegroundColor Blue
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-Host ""

# Show learning objectives
Show-LearningObjectives $ExerciseName

# Show what will be created
Show-CreationOverview $ExerciseName

if ($Preview) {
    Write-Info "Preview mode - no files will be created"
    Write-Host ""
}

# Check prerequisites
Write-Info "Checking microservices prerequisites..."

# Check .NET SDK
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Error ".NET SDK is not installed. Please install .NET 8.0 SDK."
    exit 1
}

# Check Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Warning "Docker is not installed. Some exercises may require Docker."
}

Write-Success "Prerequisites check completed"
Write-Host ""

# Check if project exists in current directory
$SkipProjectCreation = $false
if (Test-Path $ProjectName) {
    if ($ExerciseName -in @("exercise02", "exercise03", "exercise04", "exercise05")) {
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

# Exercise implementations
switch ($ExerciseName) {
    "exercise01" {
        # Exercise 1: Service Decomposition & Domain-Driven Design

        Explain-Concept "Domain-Driven Design and Service Decomposition" @"
Microservices architecture starts with proper domain analysis:
• Bounded Contexts: Define clear boundaries around business capabilities
• Aggregates: Group related entities that change together
• Domain Events: Capture important business events for inter-service communication
• Service Boundaries: Align services with business capabilities, not technical layers
• Data Ownership: Each service owns its data and business logic
"@

        if (-not $SkipProjectCreation) {
            Write-Info "Creating microservices project structure..."
            New-Item -ItemType Directory -Name $ProjectName -Force
            Set-Location $ProjectName
        }

        # Create domain analysis documentation
        Create-FileInteractive "docs/domain-analysis.md" @'
# E-Commerce Domain Analysis

## Business Capabilities

### Product Catalog Management
- **Responsibility**: Manage product information, categories, pricing
- **Data**: Products, Categories, Inventory levels
- **Events**: ProductCreated, ProductUpdated, PriceChanged

### Order Management
- **Responsibility**: Handle order lifecycle, payment processing
- **Data**: Orders, Order Items, Payment information
- **Events**: OrderPlaced, OrderConfirmed, OrderShipped

### User Management
- **Responsibility**: User authentication, profiles, preferences
- **Data**: Users, Profiles, Authentication tokens
- **Events**: UserRegistered, UserProfileUpdated

## Bounded Contexts

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Product       │    │     Order       │    │      User       │
│   Catalog       │    │   Management    │    │   Management    │
│                 │    │                 │    │                 │
│ - Products      │    │ - Orders        │    │ - Users         │
│ - Categories    │    │ - Payments      │    │ - Profiles      │
│ - Inventory     │    │ - Shipping      │    │ - Auth          │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Service Decomposition Strategy

1. **Start with business capabilities**
2. **Identify data that changes together**
3. **Define service boundaries**
4. **Plan for eventual consistency**
5. **Design for failure**
'@ "Domain analysis and service decomposition documentation"

        Write-Success "✅ Exercise 1: Service Decomposition & Domain-Driven Design completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Complete the domain analysis in: docs/domain-analysis.md" -ForegroundColor Cyan
        Write-Host "2. Define service boundaries and responsibilities" -ForegroundColor Cyan
        Write-Host "3. Plan data ownership and consistency strategies" -ForegroundColor Cyan
    }

    "exercise02" {
        # Exercise 2: Building Core Microservices

        Explain-Concept "Building Individual Microservices" @"
Each microservice should be independently deployable and maintainable:
• Single Responsibility: Each service handles one business capability
• Database per Service: Each service owns its data
• API-First Design: Well-defined interfaces for service communication
• Independent Deployment: Services can be deployed without affecting others
• Technology Diversity: Choose the best technology for each service's needs
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 2 requires Exercise 1 to be completed first!"
            Write-Info "Please run: .\launch-exercises.ps1 exercise01"
            exit 1
        }

        # Create Product Catalog microservice
        Write-Info "Creating Product Catalog microservice..."
        dotnet new webapi -n "ProductCatalog.API" --framework net8.0

        Create-FileInteractive "ProductCatalog.API/Models/Product.cs" @'
namespace ProductCatalog.API.Models;

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string Category { get; set; } = string.Empty;
    public int StockQuantity { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
'@ "Product model for the Product Catalog microservice"

        # Create Order Management microservice
        Write-Info "Creating Order Management microservice..."
        dotnet new webapi -n "OrderManagement.API" --framework net8.0

        Create-FileInteractive "OrderManagement.API/Models/Order.cs" @'
namespace OrderManagement.API.Models;

public class Order
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public List<OrderItem> Items { get; set; } = new();
    public decimal TotalAmount { get; set; }
    public OrderStatus Status { get; set; } = OrderStatus.Pending;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}

public class OrderItem
{
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal TotalPrice => Quantity * UnitPrice;
}

public enum OrderStatus
{
    Pending,
    Confirmed,
    Shipped,
    Delivered,
    Cancelled
}
'@ "Order models for the Order Management microservice"

        Write-Success "✅ Exercise 2: Building Core Microservices completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Build and test each microservice independently" -ForegroundColor Cyan
        Write-Host "2. Implement service-specific business logic" -ForegroundColor Cyan
        Write-Host "3. Set up individual databases for each service" -ForegroundColor Cyan
    }

    "exercise03" {
        # Exercise 3: Inter-Service Communication Patterns

        Explain-Concept "Inter-Service Communication" @"
Microservices need to communicate effectively:
• Synchronous Communication: HTTP/REST for immediate responses
• Asynchronous Messaging: Events and message queues for loose coupling
• Circuit Breaker Pattern: Prevent cascade failures
• Retry Policies: Handle transient failures gracefully
• Service Discovery: Locate services dynamically
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 3 requires Exercises 1 and 2 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03"
            exit 1
        }

        # Create HTTP client service
        Create-FileInteractive "Shared/HttpClientService.cs" @'
namespace Shared.Services;

public interface IProductCatalogClient
{
    Task<Product?> GetProductAsync(int productId);
    Task<List<Product>> GetProductsAsync();
}

public class ProductCatalogClient : IProductCatalogClient
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<ProductCatalogClient> _logger;

    public ProductCatalogClient(HttpClient httpClient, ILogger<ProductCatalogClient> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<Product?> GetProductAsync(int productId)
    {
        try
        {
            var response = await _httpClient.GetAsync($"/api/products/{productId}");

            if (response.IsSuccessStatusCode)
            {
                var json = await response.Content.ReadAsStringAsync();
                return System.Text.Json.JsonSerializer.Deserialize<Product>(json);
            }

            _logger.LogWarning("Product {ProductId} not found", productId);
            return null;
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "Failed to get product {ProductId}", productId);
            throw;
        }
    }

    public async Task<List<Product>> GetProductsAsync()
    {
        try
        {
            var response = await _httpClient.GetAsync("/api/products");
            response.EnsureSuccessStatusCode();

            var json = await response.Content.ReadAsStringAsync();
            return System.Text.Json.JsonSerializer.Deserialize<List<Product>>(json) ?? new List<Product>();
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "Failed to get products");
            throw;
        }
    }
}

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
}
'@ "HTTP client for inter-service communication"

        Write-Success "✅ Exercise 3: Inter-Service Communication Patterns completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Implement HTTP client communication between services" -ForegroundColor Cyan
        Write-Host "2. Add circuit breaker and retry policies" -ForegroundColor Cyan
        Write-Host "3. Implement event-driven communication patterns" -ForegroundColor Cyan
    }

    "exercise04" {
        # Exercise 4: Production-Ready Deployment

        Explain-Concept "Microservices Deployment and Orchestration" @"
Production microservices require robust deployment strategies:
• Containerization: Package services with their dependencies
• Orchestration: Manage service lifecycle and scaling
• Service Mesh: Handle service-to-service communication
• Monitoring: Observe distributed system behavior
• Load Balancing: Distribute traffic across service instances
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 4 requires Exercises 1, 2, and 3 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04"
            exit 1
        }

        # Create Docker Compose for orchestration
        Create-FileInteractive "docker-compose.yml" @'
version: '3.8'

services:
  product-catalog:
    build:
      context: ./ProductCatalog.API
      dockerfile: Dockerfile
    container_name: product-catalog
    ports:
      - "5001:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Server=product-db;Database=ProductCatalog;User=sa;Password=YourPassword123;
    depends_on:
      - product-db
    networks:
      - microservices-network

  order-management:
    build:
      context: ./OrderManagement.API
      dockerfile: Dockerfile
    container_name: order-management
    ports:
      - "5002:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Server=order-db;Database=OrderManagement;User=sa;Password=YourPassword123;
      - Services__ProductCatalog=http://product-catalog
    depends_on:
      - order-db
      - product-catalog
    networks:
      - microservices-network

  product-db:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: product-db
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=YourPassword123
    ports:
      - "1433:1433"
    volumes:
      - product-data:/var/opt/mssql
    networks:
      - microservices-network

  order-db:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: order-db
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=YourPassword123
    ports:
      - "1434:1433"
    volumes:
      - order-data:/var/opt/mssql
    networks:
      - microservices-network

  nginx:
    image: nginx:alpine
    container_name: api-gateway
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - product-catalog
      - order-management
    networks:
      - microservices-network

volumes:
  product-data:
  order-data:

networks:
  microservices-network:
    driver: bridge
'@ "Docker Compose configuration for microservices orchestration"

        Write-Success "✅ Exercise 4: Production-Ready Deployment completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Build and deploy with Docker Compose" -ForegroundColor Cyan
        Write-Host "2. Configure service mesh and load balancing" -ForegroundColor Cyan
        Write-Host "3. Set up monitoring and observability" -ForegroundColor Cyan
    }

    "exercise05" {
        # Exercise 5: Advanced Patterns & Governance

        Explain-Concept "Advanced Microservices Patterns" @"
Advanced patterns solve complex distributed system challenges:
• Saga Pattern: Manage distributed transactions across services
• CQRS: Separate read and write operations for better scalability
• Event Sourcing: Store events instead of current state
• API Versioning: Evolve APIs without breaking existing clients
• Service Governance: Establish standards and best practices
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 5 requires all previous exercises to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04, exercise05"
            exit 1
        }

        # Create Saga pattern implementation
        Create-FileInteractive "Shared/Patterns/SagaPattern.cs" @'
namespace Shared.Patterns;

public interface ISagaStep
{
    Task ExecuteAsync();
    Task CompensateAsync();
}

public class OrderSaga
{
    private readonly List<ISagaStep> _steps = new();
    private readonly List<ISagaStep> _executedSteps = new();
    private readonly ILogger<OrderSaga> _logger;

    public OrderSaga(ILogger<OrderSaga> logger)
    {
        _logger = logger;
    }

    public OrderSaga AddStep(ISagaStep step)
    {
        _steps.Add(step);
        return this;
    }

    public async Task<bool> ExecuteAsync()
    {
        try
        {
            foreach (var step in _steps)
            {
                await step.ExecuteAsync();
                _executedSteps.Add(step);
                _logger.LogInformation("Saga step {StepType} executed successfully", step.GetType().Name);
            }

            _logger.LogInformation("Saga completed successfully");
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Saga failed, starting compensation");
            await CompensateAsync();
            return false;
        }
    }

    private async Task CompensateAsync()
    {
        // Execute compensation in reverse order
        for (int i = _executedSteps.Count - 1; i >= 0; i--)
        {
            try
            {
                await _executedSteps[i].CompensateAsync();
                _logger.LogInformation("Compensation for {StepType} executed", _executedSteps[i].GetType().Name);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Compensation failed for {StepType}", _executedSteps[i].GetType().Name);
            }
        }
    }
}
'@ "Saga pattern implementation for distributed transactions"

        Write-Success "✅ Exercise 5: Advanced Patterns & Governance completed!"
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Implement saga pattern for order processing" -ForegroundColor Cyan
        Write-Host "2. Add CQRS and event sourcing patterns" -ForegroundColor Cyan
        Write-Host "3. Establish microservices governance framework" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Success "🎉 $ExerciseName microservices template created successfully!"
Write-Host ""
Write-Info "📚 For detailed microservices guidance, refer to microservices architecture patterns."
Write-Info "🔗 Additional microservices resources available in the Resources/ directory."
