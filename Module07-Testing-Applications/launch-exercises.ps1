#!/usr/bin/env pwsh

# Module 7: Testing Applications - Interactive Exercise Launcher
# This script provides guided, hands-on exercises for testing ASP.NET Core applications

param(
    [Parameter(Position=0)]
    [string]$ExerciseName,
    
    [switch]$List,
    [switch]$Auto,
    [switch]$Preview
)

# Configuration
$ProjectName = "TestingDemo"
$InteractiveMode = -not $Auto

# Function to display colored output
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Blue }
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }

# Function to explain testing concepts
function Explain-Concept {
    param($Concept, $Explanation)
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "🧪 TESTING CONCEPT: $Concept" -ForegroundColor Cyan
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
    param([string]$Exercise)

    Write-Host "🎯 Learning Objectives for ${Exercise}:" -ForegroundColor Blue

    switch ($Exercise) {
        "exercise01" {
            Write-Host "• Understand unit testing fundamentals with xUnit"
            Write-Host "• Write tests for services and controllers"
            Write-Host "• Use Moq for mocking dependencies"
            Write-Host "• Apply the AAA (Arrange-Act-Assert) pattern"
            Write-Host "• Use FluentAssertions for readable assertions"
        }
        "exercise02" {
            Write-Host "• Create integration tests with TestServer"
            Write-Host "• Use WebApplicationFactory for test setup"
            Write-Host "• Test API endpoints end-to-end"
            Write-Host "• Manage test databases with EF Core"
            Write-Host "• Test authentication and authorization"
        }
        "exercise03" {
            Write-Host "• Mock external HTTP services with HttpClient"
            Write-Host "• Use WireMock for API simulation"
            Write-Host "• Test resilience patterns (retry, circuit breaker)"
            Write-Host "• Mock database operations effectively"
            Write-Host "• Test error handling scenarios"
        }
        "exercise04" {
            Write-Host "• Implement performance benchmarks with BenchmarkDotNet"
            Write-Host "• Create load tests for API endpoints"
            Write-Host "• Measure and optimize memory usage"
            Write-Host "• Profile database query performance"
            Write-Host "• Generate performance reports"
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
    Write-Host "Module 7 - Testing Applications" -ForegroundColor Cyan
    Write-Host "Available Exercises:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  - exercise01: Unit Testing Basics"
    Write-Host "  - exercise02: Integration Testing"
    Write-Host "  - exercise03: Mocking External Services"
    Write-Host "  - exercise04: Performance Testing"
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
Write-Host "🚀 Module 7: Testing Applications" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Show learning objectives
Show-LearningObjectives -Exercise $ExerciseName

if ($Preview) {
    Write-Info "Preview mode - no files will be created"
    Write-Host ""
}

# Check prerequisites
Write-Info "Checking prerequisites..."

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

# Exercise implementations
switch ($ExerciseName) {
    "exercise01" {
        # Exercise 1: Unit Testing Basics

        Explain-Concept "Unit Testing Fundamentals" @"
Unit tests verify individual components in isolation:
• Test a single unit of work (method, class)
• Fast execution (milliseconds)
• No external dependencies (database, network, file system)
• Repeatable and deterministic
• Follow the AAA pattern: Arrange, Act, Assert
"@

        if (-not $SkipProjectCreation) {
            Write-Info "🏗️ Creating testing project structure..."

            # Create project directory
            New-Item -ItemType Directory -Name $ProjectName -Force
            Set-Location $ProjectName

            # Create solution
            dotnet new sln -n TestingDemo

            # Create main project
            Write-Info "Creating API project..."
            dotnet new webapi -n ProductCatalog.API --framework net8.0
            dotnet sln add ProductCatalog.API/ProductCatalog.API.csproj

            # Create unit test project
            Write-Info "Creating unit test project..."
            dotnet new xunit -n ProductCatalog.UnitTests --framework net8.0
            dotnet sln add ProductCatalog.UnitTests/ProductCatalog.UnitTests.csproj

            # Add references
            Set-Location ProductCatalog.UnitTests
            dotnet add reference ../ProductCatalog.API/ProductCatalog.API.csproj
            dotnet add package Moq
            dotnet add package FluentAssertions
            dotnet add package Microsoft.Extensions.Logging.Abstractions
            Set-Location ..
        }

        Explain-Concept "Mocking with Moq" @"
Moq allows you to create test doubles for dependencies:
• Mock: Full control over behavior
• Setup: Define expected behavior
• Verify: Assert interactions occurred
• It.IsAny<T>(): Match any parameter value
• Returns(): Specify return values
"@

        # Create models
        Create-FileInteractive "ProductCatalog.API/Models/Product.cs" @'
namespace ProductCatalog.API.Models;

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class ProductDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
}
'@ "Domain models for product catalog"

        # Create repository interface
        Create-FileInteractive "ProductCatalog.API/Repositories/IProductRepository.cs" @'
using ProductCatalog.API.Models;

namespace ProductCatalog.API.Repositories;

public interface IProductRepository
{
    Task<Product?> GetByIdAsync(int id);
    Task<IEnumerable<Product>> GetAllAsync();
    Task<Product> AddAsync(Product product);
    Task<Product> UpdateAsync(Product product);
    Task<bool> DeleteAsync(int id);
    Task<bool> ExistsAsync(int id);
}
'@ "Repository interface for data access abstraction"

        # Create service with business logic
        Create-FileInteractive "ProductCatalog.API/Services/ProductService.cs" @'
using ProductCatalog.API.Models;
using ProductCatalog.API.Repositories;

namespace ProductCatalog.API.Services;

public interface IProductService
{
    Task<ProductDto?> GetProductByIdAsync(int id);
    Task<IEnumerable<ProductDto>> GetAllProductsAsync();
    Task<ProductDto> CreateProductAsync(ProductDto productDto);
    Task<ProductDto> UpdateProductAsync(int id, ProductDto productDto);
    Task<bool> DeleteProductAsync(int id);
    Task<decimal> CalculateDiscountedPriceAsync(int productId, decimal discountPercentage);
}

public class ProductService : IProductService
{
    private readonly IProductRepository _repository;
    private readonly ILogger<ProductService> _logger;

    public ProductService(IProductRepository repository, ILogger<ProductService> logger)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ProductDto?> GetProductByIdAsync(int id)
    {
        if (id <= 0)
        {
            throw new ArgumentException("Product ID must be greater than zero", nameof(id));
        }

        var product = await _repository.GetByIdAsync(id);
        
        if (product == null)
        {
            _logger.LogWarning("Product with ID {ProductId} not found", id);
            return null;
        }

        return MapToDto(product);
    }

    public async Task<IEnumerable<ProductDto>> GetAllProductsAsync()
    {
        var products = await _repository.GetAllAsync();
        return products.Select(MapToDto);
    }

    public async Task<ProductDto> CreateProductAsync(ProductDto productDto)
    {
        if (productDto == null)
        {
            throw new ArgumentNullException(nameof(productDto));
        }

        if (string.IsNullOrWhiteSpace(productDto.Name))
        {
            throw new ArgumentException("Product name is required", nameof(productDto));
        }

        if (productDto.Price <= 0)
        {
            throw new ArgumentException("Product price must be greater than zero", nameof(productDto));
        }

        var product = new Product
        {
            Name = productDto.Name,
            Description = productDto.Name, // Default description
            Price = productDto.Price,
            StockQuantity = productDto.StockQuantity,
            CreatedAt = DateTime.UtcNow
        };

        var createdProduct = await _repository.AddAsync(product);
        _logger.LogInformation("Created product with ID {ProductId}", createdProduct.Id);

        return MapToDto(createdProduct);
    }

    public async Task<ProductDto> UpdateProductAsync(int id, ProductDto productDto)
    {
        if (id <= 0)
        {
            throw new ArgumentException("Product ID must be greater than zero", nameof(id));
        }

        if (productDto == null)
        {
            throw new ArgumentNullException(nameof(productDto));
        }

        var existingProduct = await _repository.GetByIdAsync(id);
        if (existingProduct == null)
        {
            throw new InvalidOperationException($"Product with ID {id} not found");
        }

        existingProduct.Name = productDto.Name;
        existingProduct.Price = productDto.Price;
        existingProduct.StockQuantity = productDto.StockQuantity;
        existingProduct.UpdatedAt = DateTime.UtcNow;

        var updatedProduct = await _repository.UpdateAsync(existingProduct);
        _logger.LogInformation("Updated product with ID {ProductId}", id);

        return MapToDto(updatedProduct);
    }

    public async Task<bool> DeleteProductAsync(int id)
    {
        if (id <= 0)
        {
            throw new ArgumentException("Product ID must be greater than zero", nameof(id));
        }

        var result = await _repository.DeleteAsync(id);
        
        if (result)
        {
            _logger.LogInformation("Deleted product with ID {ProductId}", id);
        }
        else
        {
            _logger.LogWarning("Failed to delete product with ID {ProductId}", id);
        }

        return result;
    }

    public async Task<decimal> CalculateDiscountedPriceAsync(int productId, decimal discountPercentage)
    {
        if (discountPercentage < 0 || discountPercentage > 100)
        {
            throw new ArgumentException("Discount percentage must be between 0 and 100", nameof(discountPercentage));
        }

        var product = await _repository.GetByIdAsync(productId);
        if (product == null)
        {
            throw new InvalidOperationException($"Product with ID {productId} not found");
        }

        var discountAmount = product.Price * (discountPercentage / 100);
        return product.Price - discountAmount;
    }

    private static ProductDto MapToDto(Product product)
    {
        return new ProductDto
        {
            Id = product.Id,
            Name = product.Name,
            Price = product.Price,
            StockQuantity = product.StockQuantity
        };
    }
}
'@ "Service layer with business logic to test"

        # Create first unit test
        Create-FileInteractive "ProductCatalog.UnitTests/Services/ProductServiceTests.cs" @'
using Xunit;
using Moq;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using ProductCatalog.API.Models;
using ProductCatalog.API.Repositories;
using ProductCatalog.API.Services;

namespace ProductCatalog.UnitTests.Services;

public class ProductServiceTests
{
    private readonly Mock<IProductRepository> _mockRepository;
    private readonly Mock<ILogger<ProductService>> _mockLogger;
    private readonly ProductService _productService;

    public ProductServiceTests()
    {
        _mockRepository = new Mock<IProductRepository>();
        _mockLogger = new Mock<ILogger<ProductService>>();
        _productService = new ProductService(_mockRepository.Object, _mockLogger.Object);
    }

    [Fact]
    public async Task GetProductByIdAsync_WithValidId_ReturnsProduct()
    {
        // Arrange
        var productId = 1;
        var expectedProduct = new Product
        {
            Id = productId,
            Name = "Test Product",
            Price = 99.99m,
            StockQuantity = 10
        };

        _mockRepository.Setup(repo => repo.GetByIdAsync(productId))
            .ReturnsAsync(expectedProduct);

        // Act
        var result = await _productService.GetProductByIdAsync(productId);

        // Assert
        result.Should().NotBeNull();
        result!.Id.Should().Be(productId);
        result.Name.Should().Be("Test Product");
        result.Price.Should().Be(99.99m);
        
        _mockRepository.Verify(repo => repo.GetByIdAsync(productId), Times.Once);
    }

    [Fact]
    public async Task GetProductByIdAsync_WithInvalidId_ThrowsArgumentException()
    {
        // Arrange
        var invalidId = -1;

        // Act
        var action = async () => await _productService.GetProductByIdAsync(invalidId);

        // Assert
        await action.Should().ThrowAsync<ArgumentException>()
            .WithMessage("*must be greater than zero*")
            .WithParameterName("id");
        
        _mockRepository.Verify(repo => repo.GetByIdAsync(It.IsAny<int>()), Times.Never);
    }

    [Fact]
    public async Task GetProductByIdAsync_WhenProductNotFound_ReturnsNull()
    {
        // Arrange
        var productId = 999;
        _mockRepository.Setup(repo => repo.GetByIdAsync(productId))
            .ReturnsAsync((Product?)null);

        // Act
        var result = await _productService.GetProductByIdAsync(productId);

        // Assert
        result.Should().BeNull();
        
        // Verify warning was logged
        _mockLogger.Verify(
            logger => logger.Log(
                LogLevel.Warning,
                It.IsAny<EventId>(),
                It.Is<It.IsAnyType>((v, t) => v.ToString()!.Contains($"Product with ID {productId} not found")),
                It.IsAny<Exception>(),
                It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
            Times.Once);
    }

    [Theory]
    [InlineData(100, 10, 90)]     // 10% discount
    [InlineData(50, 20, 40)]      // 20% discount
    [InlineData(200, 0, 200)]     // No discount
    [InlineData(150, 100, 0)]     // 100% discount
    public async Task CalculateDiscountedPriceAsync_WithValidInputs_ReturnsCorrectPrice(
        decimal originalPrice, decimal discountPercentage, decimal expectedPrice)
    {
        // Arrange
        var productId = 1;
        var product = new Product
        {
            Id = productId,
            Name = "Test Product",
            Price = originalPrice
        };

        _mockRepository.Setup(repo => repo.GetByIdAsync(productId))
            .ReturnsAsync(product);

        // Act
        var result = await _productService.CalculateDiscountedPriceAsync(productId, discountPercentage);

        // Assert
        result.Should().Be(expectedPrice);
    }

    [Theory]
    [InlineData(-1)]
    [InlineData(101)]
    [InlineData(150)]
    public async Task CalculateDiscountedPriceAsync_WithInvalidDiscount_ThrowsArgumentException(decimal invalidDiscount)
    {
        // Arrange
        var productId = 1;

        // Act
        var action = async () => await _productService.CalculateDiscountedPriceAsync(productId, invalidDiscount);

        // Assert
        await action.Should().ThrowAsync<ArgumentException>()
            .WithMessage("*must be between 0 and 100*")
            .WithParameterName("discountPercentage");
    }

    [Fact]
    public async Task CreateProductAsync_WithValidProduct_ReturnsCreatedProduct()
    {
        // Arrange
        var productDto = new ProductDto
        {
            Name = "New Product",
            Price = 49.99m,
            StockQuantity = 100
        };

        var expectedProduct = new Product
        {
            Id = 1,
            Name = productDto.Name,
            Price = productDto.Price,
            StockQuantity = productDto.StockQuantity,
            CreatedAt = DateTime.UtcNow
        };

        _mockRepository.Setup(repo => repo.AddAsync(It.IsAny<Product>()))
            .ReturnsAsync(expectedProduct);

        // Act
        var result = await _productService.CreateProductAsync(productDto);

        // Assert
        result.Should().NotBeNull();
        result.Id.Should().Be(1);
        result.Name.Should().Be(productDto.Name);
        result.Price.Should().Be(productDto.Price);
        
        _mockRepository.Verify(repo => repo.AddAsync(It.Is<Product>(p => 
            p.Name == productDto.Name && 
            p.Price == productDto.Price)), Times.Once);
    }

    [Fact]
    public async Task CreateProductAsync_WithNullProduct_ThrowsArgumentNullException()
    {
        // Act
        var action = async () => await _productService.CreateProductAsync(null!);

        // Assert
        await action.Should().ThrowAsync<ArgumentNullException>()
            .WithParameterName("productDto");
    }

    [Fact]
    public async Task CreateProductAsync_WithEmptyName_ThrowsArgumentException()
    {
        // Arrange
        var productDto = new ProductDto
        {
            Name = "",
            Price = 49.99m
        };

        // Act
        var action = async () => await _productService.CreateProductAsync(productDto);

        // Assert
        await action.Should().ThrowAsync<ArgumentException>()
            .WithMessage("*name is required*");
    }

    [Fact]
    public async Task CreateProductAsync_WithInvalidPrice_ThrowsArgumentException()
    {
        // Arrange
        var productDto = new ProductDto
        {
            Name = "Test Product",
            Price = -10
        };

        // Act
        var action = async () => await _productService.CreateProductAsync(productDto);

        // Assert
        await action.Should().ThrowAsync<ArgumentException>()
            .WithMessage("*price must be greater than zero*");
    }
}
'@ "Comprehensive unit tests demonstrating various testing patterns"

        # Create test helpers
        Create-FileInteractive "ProductCatalog.UnitTests/Helpers/TestDataBuilder.cs" @'
using ProductCatalog.API.Models;

namespace ProductCatalog.UnitTests.Helpers;

public class TestDataBuilder
{
    public static Product CreateProduct(int id = 1, string name = "Test Product", decimal price = 99.99m)
    {
        return new Product
        {
            Id = id,
            Name = name,
            Description = $"{name} Description",
            Price = price,
            StockQuantity = 100,
            CreatedAt = DateTime.UtcNow.AddDays(-30),
            UpdatedAt = DateTime.UtcNow
        };
    }

    public static ProductDto CreateProductDto(int id = 1, string name = "Test Product", decimal price = 99.99m)
    {
        return new ProductDto
        {
            Id = id,
            Name = name,
            Price = price,
            StockQuantity = 100
        };
    }

    public static List<Product> CreateProductList(int count = 5)
    {
        var products = new List<Product>();
        for (int i = 1; i <= count; i++)
        {
            products.Add(CreateProduct(i, $"Product {i}", i * 10.99m));
        }
        return products;
    }
}
'@ "Test data builder for creating test objects"

        # Create README for unit testing
        Create-FileInteractive "ProductCatalog.UnitTests/README.md" @'
# Unit Testing Guide

## Running Tests

```bash
# Run all tests
dotnet test

# Run with coverage
dotnet test --collect:"XPlat Code Coverage"

# Run specific test
dotnet test --filter "FullyQualifiedName~ProductServiceTests"

# Run tests in watch mode
dotnet watch test
```

## Test Patterns Used

### 1. AAA Pattern (Arrange-Act-Assert)
- **Arrange**: Set up test data and mocks
- **Act**: Execute the method under test
- **Assert**: Verify the expected outcome

### 2. Mock Setup
```csharp
_mockRepository.Setup(repo => repo.GetByIdAsync(It.IsAny<int>()))
    .ReturnsAsync(expectedProduct);
```

### 3. Exception Testing
```csharp
var action = async () => await _service.MethodThatThrows();
await action.Should().ThrowAsync<ExpectedException>();
```

### 4. Theory Tests (Data-Driven)
```csharp
[Theory]
[InlineData(input1, expected1)]
[InlineData(input2, expected2)]
public void TestMethod(int input, int expected) { }
```

## Best Practices

1. **One Assert Per Test**: Each test should verify one behavior
2. **Descriptive Names**: Test names should describe what they test
3. **Independent Tests**: Tests should not depend on each other
4. **Fast Execution**: Unit tests should run in milliseconds
5. **No External Dependencies**: Mock all external dependencies

## Common Assertions with FluentAssertions

```csharp
// Basic assertions
result.Should().Be(expected);
result.Should().NotBeNull();
result.Should().BeOfType<ProductDto>();

// Collection assertions
collection.Should().HaveCount(5);
collection.Should().Contain(item);
collection.Should().BeEquivalentTo(expectedCollection);

// Exception assertions
action.Should().Throw<ArgumentException>()
    .WithMessage("*expected message*");

// Numeric assertions
value.Should().BeGreaterThan(0);
value.Should().BeInRange(1, 100);
```
'@ "Unit testing guide and best practices"

        Write-Success "Unit testing project created!"
        Write-Host ""
        Write-Info "Next steps:"
        Write-Host "1. Run the tests: " -NoNewline
        Write-Host "dotnet test" -ForegroundColor Cyan
        Write-Host "2. Run with coverage: " -NoNewline
        Write-Host "dotnet test --collect:'XPlat Code Coverage'" -ForegroundColor Cyan
        Write-Host "3. Add more test cases to achieve 80%+ coverage"
        Write-Host "4. Try test-driven development (TDD) for new features"
    }

    "exercise02" {
        # Exercise 2: Integration Testing

        Explain-Concept "Integration Testing" @"
Integration tests verify that different parts of the application work together:
• Test the full request/response pipeline
• Use TestServer and WebApplicationFactory
• Include real database operations (often in-memory)
• Test middleware, filters, and authentication
• Slower than unit tests but more comprehensive
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 2 requires Exercise 1 to be completed first!"
            Write-Info "Please run: .\launch-exercises.ps1 exercise01"
            exit 1
        }

        Write-Info "Adding integration test project..."

        # Create integration test project
        dotnet new xunit -n ProductCatalog.IntegrationTests --framework net8.0
        dotnet sln add ProductCatalog.IntegrationTests/ProductCatalog.IntegrationTests.csproj

        # Add references and packages
        Set-Location ProductCatalog.IntegrationTests
        dotnet add reference ../ProductCatalog.API/ProductCatalog.API.csproj
        dotnet add package Microsoft.AspNetCore.Mvc.Testing
        dotnet add package Microsoft.EntityFrameworkCore.InMemory
        dotnet add package FluentAssertions
        dotnet add package Respawn
        Set-Location ..

        Explain-Concept "WebApplicationFactory" @"
WebApplicationFactory provides a test server for integration testing:
• Creates an in-memory test server
• Allows service replacement for testing
• Provides HttpClient for making requests
• Supports custom configuration
• Enables database seeding and cleanup
"@

        # Create DbContext and entities
        Create-FileInteractive "ProductCatalog.API/Data/ProductCatalogContext.cs" @'
using Microsoft.EntityFrameworkCore;
using ProductCatalog.API.Models;

namespace ProductCatalog.API.Data;

public class ProductCatalogContext : DbContext
{
    public ProductCatalogContext(DbContextOptions<ProductCatalogContext> options)
        : base(options)
    {
    }

    public DbSet<Product> Products { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Price).HasPrecision(18, 2);
            entity.HasIndex(e => e.Name);
        });

        // Seed data for testing
        modelBuilder.Entity<Product>().HasData(
            new Product 
            { 
                Id = 1, 
                Name = "Laptop", 
                Description = "High-performance laptop",
                Price = 999.99m, 
                StockQuantity = 50,
                CreatedAt = DateTime.UtcNow
            },
            new Product 
            { 
                Id = 2, 
                Name = "Mouse", 
                Description = "Wireless mouse",
                Price = 29.99m, 
                StockQuantity = 200,
                CreatedAt = DateTime.UtcNow
            }
        );
    }
}
'@ "Entity Framework Core context for data access"

        # Create repository implementation
        Create-FileInteractive "ProductCatalog.API/Repositories/ProductRepository.cs" @'
using Microsoft.EntityFrameworkCore;
using ProductCatalog.API.Data;
using ProductCatalog.API.Models;

namespace ProductCatalog.API.Repositories;

public class ProductRepository : IProductRepository
{
    private readonly ProductCatalogContext _context;

    public ProductRepository(ProductCatalogContext context)
    {
        _context = context;
    }

    public async Task<Product?> GetByIdAsync(int id)
    {
        return await _context.Products.FindAsync(id);
    }

    public async Task<IEnumerable<Product>> GetAllAsync()
    {
        return await _context.Products.ToListAsync();
    }

    public async Task<Product> AddAsync(Product product)
    {
        _context.Products.Add(product);
        await _context.SaveChangesAsync();
        return product;
    }

    public async Task<Product> UpdateAsync(Product product)
    {
        _context.Products.Update(product);
        await _context.SaveChangesAsync();
        return product;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var product = await _context.Products.FindAsync(id);
        if (product == null) return false;

        _context.Products.Remove(product);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> ExistsAsync(int id)
    {
        return await _context.Products.AnyAsync(p => p.Id == id);
    }
}
'@ "Repository implementation with Entity Framework Core"

        # Create controller
        Create-FileInteractive "ProductCatalog.API/Controllers/ProductsController.cs" @'
using Microsoft.AspNetCore.Mvc;
using ProductCatalog.API.Models;
using ProductCatalog.API.Services;

namespace ProductCatalog.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(IProductService productService, ILogger<ProductsController> logger)
    {
        _productService = productService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetAll()
    {
        var products = await _productService.GetAllProductsAsync();
        return Ok(products);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ProductDto>> GetById(int id)
    {
        var product = await _productService.GetProductByIdAsync(id);
        
        if (product == null)
        {
            return NotFound(new { message = $"Product with ID {id} not found" });
        }

        return Ok(product);
    }

    [HttpPost]
    public async Task<ActionResult<ProductDto>> Create([FromBody] ProductDto productDto)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        try
        {
            var createdProduct = await _productService.CreateProductAsync(productDto);
            return CreatedAtAction(nameof(GetById), new { id = createdProduct.Id }, createdProduct);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<ProductDto>> Update(int id, [FromBody] ProductDto productDto)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        try
        {
            var updatedProduct = await _productService.UpdateProductAsync(id, productDto);
            return Ok(updatedProduct);
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _productService.DeleteProductAsync(id);
        
        if (!result)
        {
            return NotFound(new { message = $"Product with ID {id} not found" });
        }

        return NoContent();
    }

    [HttpGet("{id}/discount/{percentage}")]
    public async Task<ActionResult<decimal>> CalculateDiscount(int id, decimal percentage)
    {
        try
        {
            var discountedPrice = await _productService.CalculateDiscountedPriceAsync(id, percentage);
            return Ok(new { productId = id, discountPercentage = percentage, discountedPrice });
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
'@ "API controller for product operations"

        # Update Program.cs
        Create-FileInteractive "ProductCatalog.API/Program.cs" @'
using Microsoft.EntityFrameworkCore;
using ProductCatalog.API.Data;
using ProductCatalog.API.Repositories;
using ProductCatalog.API.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add Entity Framework
builder.Services.AddDbContext<ProductCatalogContext>(options =>
{
    if (builder.Environment.IsEnvironment("Testing"))
    {
        options.UseInMemoryDatabase("TestDb");
    }
    else
    {
        options.UseInMemoryDatabase("ProductCatalog");
    }
});

// Register services
builder.Services.AddScoped<IProductRepository, ProductRepository>();
builder.Services.AddScoped<IProductService, ProductService>();

// Add health checks
builder.Services.AddHealthChecks()
    .AddDbContextCheck<ProductCatalogContext>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.MapHealthChecks("/health");

// Ensure database is created
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ProductCatalogContext>();
    context.Database.EnsureCreated();
}

app.Run();

// Make Program class accessible to tests
public partial class Program { }
'@ "Updated Program.cs with dependency injection and EF Core"

        # Create WebApplicationFactory
        Create-FileInteractive "ProductCatalog.IntegrationTests/CustomWebApplicationFactory.cs" @'
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using ProductCatalog.API.Data;

namespace ProductCatalog.IntegrationTests;

public class CustomWebApplicationFactory<TProgram> : WebApplicationFactory<TProgram> where TProgram : class
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // Remove the existing DbContext registration
            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<ProductCatalogContext>));

            if (descriptor != null)
            {
                services.Remove(descriptor);
            }

            // Add DbContext using in-memory database for testing
            services.AddDbContext<ProductCatalogContext>(options =>
            {
                options.UseInMemoryDatabase("IntegrationTestDb");
            });

            // Build the service provider
            var serviceProvider = services.BuildServiceProvider();

            // Create a scope to obtain a reference to the database
            using (var scope = serviceProvider.CreateScope())
            {
                var scopedServices = scope.ServiceProvider;
                var context = scopedServices.GetRequiredService<ProductCatalogContext>();

                // Ensure the database is created
                context.Database.EnsureCreated();

                // Seed the database with test data
                SeedDatabase(context);
            }
        });

        builder.UseEnvironment("Testing");
    }

    private static void SeedDatabase(ProductCatalogContext context)
    {
        // Clear existing data
        context.Products.RemoveRange(context.Products);
        context.SaveChanges();

        // Add test data
        context.Products.AddRange(
            new API.Models.Product
            {
                Id = 1,
                Name = "Test Product 1",
                Description = "Description 1",
                Price = 100.00m,
                StockQuantity = 10,
                CreatedAt = DateTime.UtcNow
            },
            new API.Models.Product
            {
                Id = 2,
                Name = "Test Product 2",
                Description = "Description 2",
                Price = 200.00m,
                StockQuantity = 20,
                CreatedAt = DateTime.UtcNow
            }
        );

        context.SaveChanges();
    }
}
'@ "Custom WebApplicationFactory for integration testing"

        # Create integration tests
        Create-FileInteractive "ProductCatalog.IntegrationTests/Controllers/ProductsControllerTests.cs" @'
using System.Net;
using System.Net.Http.Json;
using Xunit;
using FluentAssertions;
using ProductCatalog.API.Models;
using Microsoft.AspNetCore.Mvc.Testing;

namespace ProductCatalog.IntegrationTests.Controllers;

public class ProductsControllerTests : IClassFixture<CustomWebApplicationFactory<Program>>
{
    private readonly HttpClient _client;
    private readonly CustomWebApplicationFactory<Program> _factory;

    public ProductsControllerTests(CustomWebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = _factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = false
        });
    }

    [Fact]
    public async Task GetAll_ReturnsSuccessAndCorrectContentType()
    {
        // Act
        var response = await _client.GetAsync("/api/products");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        response.Content.Headers.ContentType!.ToString().Should().Be("application/json; charset=utf-8");

        var products = await response.Content.ReadFromJsonAsync<List<ProductDto>>();
        products.Should().NotBeNull();
        products!.Count.Should().Be(2);
    }

    [Fact]
    public async Task GetById_WithValidId_ReturnsProduct()
    {
        // Act
        var response = await _client.GetAsync("/api/products/1");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);

        var product = await response.Content.ReadFromJsonAsync<ProductDto>();
        product.Should().NotBeNull();
        product!.Id.Should().Be(1);
        product.Name.Should().Be("Test Product 1");
    }

    [Fact]
    public async Task GetById_WithInvalidId_ReturnsNotFound()
    {
        // Act
        var response = await _client.GetAsync("/api/products/999");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Create_WithValidProduct_ReturnsCreatedProduct()
    {
        // Arrange
        var newProduct = new ProductDto
        {
            Name = "New Product",
            Price = 49.99m,
            StockQuantity = 100
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/products", newProduct);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        response.Headers.Location.Should().NotBeNull();

        var createdProduct = await response.Content.ReadFromJsonAsync<ProductDto>();
        createdProduct.Should().NotBeNull();
        createdProduct!.Name.Should().Be(newProduct.Name);
        createdProduct.Price.Should().Be(newProduct.Price);
    }

    [Fact]
    public async Task Create_WithInvalidProduct_ReturnsBadRequest()
    {
        // Arrange
        var invalidProduct = new ProductDto
        {
            Name = "", // Invalid: empty name
            Price = -10 // Invalid: negative price
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/products", invalidProduct);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task Update_WithValidData_ReturnsUpdatedProduct()
    {
        // Arrange
        var updateDto = new ProductDto
        {
            Name = "Updated Product",
            Price = 150.00m,
            StockQuantity = 15
        };

        // Act
        var response = await _client.PutAsJsonAsync("/api/products/1", updateDto);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);

        var updatedProduct = await response.Content.ReadFromJsonAsync<ProductDto>();
        updatedProduct.Should().NotBeNull();
        updatedProduct!.Name.Should().Be(updateDto.Name);
        updatedProduct.Price.Should().Be(updateDto.Price);
    }

    [Fact]
    public async Task Delete_WithValidId_ReturnsNoContent()
    {
        // Act
        var response = await _client.DeleteAsync("/api/products/2");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NoContent);

        // Verify deletion
        var getResponse = await _client.GetAsync("/api/products/2");
        getResponse.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task CalculateDiscount_WithValidInputs_ReturnsDiscountedPrice()
    {
        // Act
        var response = await _client.GetAsync("/api/products/1/discount/20");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);

        var result = await response.Content.ReadFromJsonAsync<dynamic>();
        ((decimal)result!.discountedPrice).Should().Be(80.00m); // 100 - 20% = 80
    }

    [Fact]
    public async Task HealthCheck_ReturnsHealthy()
    {
        // Act
        var response = await _client.GetAsync("/health");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var content = await response.Content.ReadAsStringAsync();
        content.Should().Contain("Healthy");
    }
}
'@ "Integration tests for ProductsController"

        # Create test utilities
        Create-FileInteractive "ProductCatalog.IntegrationTests/Utilities/IntegrationTestBase.cs" @'
using System.Net.Http.Headers;
using Microsoft.Extensions.DependencyInjection;
using ProductCatalog.API.Data;

namespace ProductCatalog.IntegrationTests.Utilities;

public abstract class IntegrationTestBase : IClassFixture<CustomWebApplicationFactory<Program>>
{
    protected readonly HttpClient Client;
    protected readonly CustomWebApplicationFactory<Program> Factory;

    protected IntegrationTestBase(CustomWebApplicationFactory<Program> factory)
    {
        Factory = factory;
        Client = factory.CreateClient();
    }

    protected async Task<T?> GetFromJsonAsync<T>(string uri)
    {
        var response = await Client.GetAsync(uri);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<T>();
    }

    protected async Task ResetDatabaseAsync()
    {
        using var scope = Factory.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ProductCatalogContext>();
        
        context.Products.RemoveRange(context.Products);
        await context.SaveChangesAsync();
    }

    protected void SetAuthorizationHeader(string token)
    {
        Client.DefaultRequestHeaders.Authorization = 
            new AuthenticationHeaderValue("Bearer", token);
    }
}
'@ "Base class for integration tests with helper methods"

        Write-Success "Integration testing project created!"
        Write-Host ""
        Write-Info "Integration tests created! Run them with:"
        Write-Host "dotnet test ProductCatalog.IntegrationTests" -ForegroundColor Cyan
    }

    "exercise03" {
        # Exercise 3: Mocking External Services

        Explain-Concept "Mocking External Services" @"
Testing with external dependencies requires careful mocking:
• HTTP Services: Use HttpClient mocking or WireMock
• Message Queues: Mock message broker interfaces
• Databases: Use in-memory providers or mocks
• File Systems: Use abstraction and mocks
• Third-party APIs: Create fake implementations
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 3 requires Exercises 1 and 2 to be completed first!"
            Write-Info "Please run exercises in order"
            exit 1
        }

        Write-Info "Adding external service mocking examples..."

        # Add packages for HTTP mocking
        Set-Location ProductCatalog.API
        dotnet add package Polly
        dotnet add package Microsoft.Extensions.Http.Polly
        Set-Location ..

        Set-Location ProductCatalog.UnitTests
        dotnet add package WireMock.Net
        dotnet add package Moq.Contrib.HttpClient
        Set-Location ..

        # Create external service interfaces
        Create-FileInteractive "ProductCatalog.API/Services/IInventoryService.cs" @'
namespace ProductCatalog.API.Services;

public interface IInventoryService
{
    Task<InventoryStatus> CheckInventoryAsync(int productId);
    Task<bool> ReserveStockAsync(int productId, int quantity);
    Task<bool> ReleaseStockAsync(int productId, int quantity);
}

public class InventoryStatus
{
    public int ProductId { get; set; }
    public int AvailableQuantity { get; set; }
    public int ReservedQuantity { get; set; }
    public bool InStock => AvailableQuantity > 0;
    public DateTime LastUpdated { get; set; }
}
'@ "External inventory service interface"

        # Create HTTP-based service implementation
        Create-FileInteractive "ProductCatalog.API/Services/HttpInventoryService.cs" @'
using System.Net.Http.Json;
using Polly;
using Polly.Extensions.Http;

namespace ProductCatalog.API.Services;

public class HttpInventoryService : IInventoryService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<HttpInventoryService> _logger;
    private readonly IAsyncPolicy<HttpResponseMessage> _retryPolicy;

    public HttpInventoryService(HttpClient httpClient, ILogger<HttpInventoryService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
        
        // Configure retry policy with exponential backoff
        _retryPolicy = HttpPolicyExtensions
            .HandleTransientHttpError()
            .OrResult(msg => !msg.IsSuccessStatusCode)
            .WaitAndRetryAsync(
                3,
                retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)),
                onRetry: (outcome, timespan, retryCount, context) =>
                {
                    _logger.LogWarning("Retry {RetryCount} after {Delay}ms", retryCount, timespan.TotalMilliseconds);
                });
    }

    public async Task<InventoryStatus> CheckInventoryAsync(int productId)
    {
        try
        {
            var response = await _retryPolicy.ExecuteAsync(async () =>
                await _httpClient.GetAsync($"api/inventory/{productId}"));

            if (response.IsSuccessStatusCode)
            {
                var inventory = await response.Content.ReadFromJsonAsync<InventoryStatus>();
                return inventory ?? new InventoryStatus { ProductId = productId, AvailableQuantity = 0 };
            }

            _logger.LogError("Failed to check inventory for product {ProductId}. Status: {StatusCode}", 
                productId, response.StatusCode);
            
            throw new HttpRequestException($"Inventory service returned {response.StatusCode}");
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "Error checking inventory for product {ProductId}", productId);
            throw new InvalidOperationException("Unable to check inventory", ex);
        }
        catch (TaskCanceledException ex)
        {
            _logger.LogError(ex, "Timeout checking inventory for product {ProductId}", productId);
            throw new InvalidOperationException("Inventory service timeout", ex);
        }
    }

    public async Task<bool> ReserveStockAsync(int productId, int quantity)
    {
        try
        {
            var request = new { productId, quantity };
            var response = await _retryPolicy.ExecuteAsync(async () =>
                await _httpClient.PostAsJsonAsync("api/inventory/reserve", request));

            if (response.IsSuccessStatusCode)
            {
                _logger.LogInformation("Reserved {Quantity} units of product {ProductId}", quantity, productId);
                return true;
            }

            _logger.LogWarning("Failed to reserve stock for product {ProductId}", productId);
            return false;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error reserving stock for product {ProductId}", productId);
            return false;
        }
    }

    public async Task<bool> ReleaseStockAsync(int productId, int quantity)
    {
        try
        {
            var request = new { productId, quantity };
            var response = await _httpClient.PostAsJsonAsync("api/inventory/release", request);
            
            return response.IsSuccessStatusCode;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error releasing stock for product {ProductId}", productId);
            return false;
        }
    }
}
'@ "HTTP client implementation with Polly retry policies"

        # Create order service that uses external services
        Create-FileInteractive "ProductCatalog.API/Services/OrderService.cs" @'
using ProductCatalog.API.Models;

namespace ProductCatalog.API.Services;

public interface IOrderService
{
    Task<OrderResult> CreateOrderAsync(int productId, int quantity, string customerEmail);
    Task<bool> CancelOrderAsync(int orderId);
}

public class OrderService : IOrderService
{
    private readonly IProductService _productService;
    private readonly IInventoryService _inventoryService;
    private readonly IEmailService _emailService;
    private readonly ILogger<OrderService> _logger;

    public OrderService(
        IProductService productService,
        IInventoryService inventoryService,
        IEmailService emailService,
        ILogger<OrderService> logger)
    {
        _productService = productService;
        _inventoryService = inventoryService;
        _emailService = emailService;
        _logger = logger;
    }

    public async Task<OrderResult> CreateOrderAsync(int productId, int quantity, string customerEmail)
    {
        try
        {
            // Check if product exists
            var product = await _productService.GetProductByIdAsync(productId);
            if (product == null)
            {
                return new OrderResult { Success = false, Message = "Product not found" };
            }

            // Check inventory
            var inventory = await _inventoryService.CheckInventoryAsync(productId);
            if (!inventory.InStock || inventory.AvailableQuantity < quantity)
            {
                return new OrderResult { Success = false, Message = "Insufficient stock" };
            }

            // Reserve stock
            var reserved = await _inventoryService.ReserveStockAsync(productId, quantity);
            if (!reserved)
            {
                return new OrderResult { Success = false, Message = "Failed to reserve stock" };
            }

            // Calculate total
            var total = product.Price * quantity;

            // Create order (simplified - normally would save to database)
            var orderId = Random.Shared.Next(1000, 9999);

            // Send confirmation email
            var emailSent = await _emailService.SendOrderConfirmationAsync(
                customerEmail, 
                orderId, 
                product.Name, 
                quantity, 
                total);

            if (!emailSent)
            {
                _logger.LogWarning("Failed to send confirmation email for order {OrderId}", orderId);
            }

            _logger.LogInformation("Created order {OrderId} for {Quantity} x {ProductName}", 
                orderId, quantity, product.Name);

            return new OrderResult
            {
                Success = true,
                OrderId = orderId,
                Total = total,
                Message = "Order created successfully"
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating order for product {ProductId}", productId);
            return new OrderResult { Success = false, Message = "An error occurred creating the order" };
        }
    }

    public async Task<bool> CancelOrderAsync(int orderId)
    {
        // Simplified implementation
        await Task.Delay(100); // Simulate async operation
        return true;
    }
}

public class OrderResult
{
    public bool Success { get; set; }
    public int OrderId { get; set; }
    public decimal Total { get; set; }
    public string Message { get; set; } = string.Empty;
}

public interface IEmailService
{
    Task<bool> SendOrderConfirmationAsync(string email, int orderId, string productName, int quantity, decimal total);
}
'@ "Order service that orchestrates multiple external services"

        # Create unit tests with mocked external services
        Create-FileInteractive "ProductCatalog.UnitTests/Services/OrderServiceTests.cs" @'
using Xunit;
using Moq;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using ProductCatalog.API.Models;
using ProductCatalog.API.Services;

namespace ProductCatalog.UnitTests.Services;

public class OrderServiceTests
{
    private readonly Mock<IProductService> _mockProductService;
    private readonly Mock<IInventoryService> _mockInventoryService;
    private readonly Mock<IEmailService> _mockEmailService;
    private readonly Mock<ILogger<OrderService>> _mockLogger;
    private readonly OrderService _orderService;

    public OrderServiceTests()
    {
        _mockProductService = new Mock<IProductService>();
        _mockInventoryService = new Mock<IInventoryService>();
        _mockEmailService = new Mock<IEmailService>();
        _mockLogger = new Mock<ILogger<OrderService>>();
        
        _orderService = new OrderService(
            _mockProductService.Object,
            _mockInventoryService.Object,
            _mockEmailService.Object,
            _mockLogger.Object);
    }

    [Fact]
    public async Task CreateOrderAsync_WithValidInputs_ReturnsSuccessfulOrder()
    {
        // Arrange
        var productId = 1;
        var quantity = 2;
        var customerEmail = "test@example.com";
        
        var product = new ProductDto { Id = productId, Name = "Test Product", Price = 50.00m };
        var inventory = new InventoryStatus 
        { 
            ProductId = productId, 
            AvailableQuantity = 10, 
            LastUpdated = DateTime.UtcNow 
        };

        _mockProductService.Setup(s => s.GetProductByIdAsync(productId))
            .ReturnsAsync(product);
        
        _mockInventoryService.Setup(s => s.CheckInventoryAsync(productId))
            .ReturnsAsync(inventory);
        
        _mockInventoryService.Setup(s => s.ReserveStockAsync(productId, quantity))
            .ReturnsAsync(true);
        
        _mockEmailService.Setup(s => s.SendOrderConfirmationAsync(
                It.IsAny<string>(), It.IsAny<int>(), It.IsAny<string>(), 
                It.IsAny<int>(), It.IsAny<decimal>()))
            .ReturnsAsync(true);

        // Act
        var result = await _orderService.CreateOrderAsync(productId, quantity, customerEmail);

        // Assert
        result.Should().NotBeNull();
        result.Success.Should().BeTrue();
        result.OrderId.Should().BeGreaterThan(0);
        result.Total.Should().Be(100.00m); // 2 * 50
        result.Message.Should().Be("Order created successfully");

        // Verify all services were called
        _mockProductService.Verify(s => s.GetProductByIdAsync(productId), Times.Once);
        _mockInventoryService.Verify(s => s.CheckInventoryAsync(productId), Times.Once);
        _mockInventoryService.Verify(s => s.ReserveStockAsync(productId, quantity), Times.Once);
        _mockEmailService.Verify(s => s.SendOrderConfirmationAsync(
            customerEmail, It.IsAny<int>(), product.Name, quantity, 100.00m), Times.Once);
    }

    [Fact]
    public async Task CreateOrderAsync_WhenProductNotFound_ReturnsFailure()
    {
        // Arrange
        var productId = 999;
        
        _mockProductService.Setup(s => s.GetProductByIdAsync(productId))
            .ReturnsAsync((ProductDto?)null);

        // Act
        var result = await _orderService.CreateOrderAsync(productId, 1, "test@example.com");

        // Assert
        result.Success.Should().BeFalse();
        result.Message.Should().Be("Product not found");
        
        // Verify inventory service was not called
        _mockInventoryService.Verify(s => s.CheckInventoryAsync(It.IsAny<int>()), Times.Never);
    }

    [Fact]
    public async Task CreateOrderAsync_WhenInsufficientStock_ReturnsFailure()
    {
        // Arrange
        var productId = 1;
        var quantity = 10;
        
        _mockProductService.Setup(s => s.GetProductByIdAsync(productId))
            .ReturnsAsync(new ProductDto { Id = productId, Name = "Test", Price = 10m });
        
        _mockInventoryService.Setup(s => s.CheckInventoryAsync(productId))
            .ReturnsAsync(new InventoryStatus { ProductId = productId, AvailableQuantity = 5 });

        // Act
        var result = await _orderService.CreateOrderAsync(productId, quantity, "test@example.com");

        // Assert
        result.Success.Should().BeFalse();
        result.Message.Should().Be("Insufficient stock");
        
        // Verify stock was not reserved
        _mockInventoryService.Verify(s => s.ReserveStockAsync(It.IsAny<int>(), It.IsAny<int>()), Times.Never);
    }

    [Fact]
    public async Task CreateOrderAsync_WhenEmailFails_StillReturnsSuccess()
    {
        // Arrange
        var productId = 1;
        var quantity = 1;
        
        _mockProductService.Setup(s => s.GetProductByIdAsync(productId))
            .ReturnsAsync(new ProductDto { Id = productId, Name = "Test", Price = 10m });
        
        _mockInventoryService.Setup(s => s.CheckInventoryAsync(productId))
            .ReturnsAsync(new InventoryStatus { ProductId = productId, AvailableQuantity = 10 });
        
        _mockInventoryService.Setup(s => s.ReserveStockAsync(productId, quantity))
            .ReturnsAsync(true);
        
        _mockEmailService.Setup(s => s.SendOrderConfirmationAsync(
                It.IsAny<string>(), It.IsAny<int>(), It.IsAny<string>(), 
                It.IsAny<int>(), It.IsAny<decimal>()))
            .ReturnsAsync(false); // Email fails

        // Act
        var result = await _orderService.CreateOrderAsync(productId, quantity, "test@example.com");

        // Assert
        result.Success.Should().BeTrue(); // Order still succeeds
        
        // Verify warning was logged
        _mockLogger.Verify(
            logger => logger.Log(
                LogLevel.Warning,
                It.IsAny<EventId>(),
                It.Is<It.IsAnyType>((v, t) => v.ToString()!.Contains("Failed to send confirmation email")),
                It.IsAny<Exception>(),
                It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
            Times.Once);
    }

    [Fact]
    public async Task CreateOrderAsync_WhenInventoryServiceThrows_ReturnsFailure()
    {
        // Arrange
        var productId = 1;
        
        _mockProductService.Setup(s => s.GetProductByIdAsync(productId))
            .ReturnsAsync(new ProductDto { Id = productId, Name = "Test", Price = 10m });
        
        _mockInventoryService.Setup(s => s.CheckInventoryAsync(productId))
            .ThrowsAsync(new InvalidOperationException("Inventory service unavailable"));

        // Act
        var result = await _orderService.CreateOrderAsync(productId, 1, "test@example.com");

        // Assert
        result.Success.Should().BeFalse();
        result.Message.Should().Be("An error occurred creating the order");
        
        // Verify error was logged
        _mockLogger.Verify(
            logger => logger.Log(
                LogLevel.Error,
                It.IsAny<EventId>(),
                It.Is<It.IsAnyType>((v, t) => v.ToString()!.Contains("Error creating order")),
                It.IsAny<Exception>(),
                It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
            Times.Once);
    }
}
'@ "Unit tests demonstrating mocking of external services"

        # Create HTTP client tests
        Create-FileInteractive "ProductCatalog.UnitTests/Services/HttpInventoryServiceTests.cs" @'
using System.Net;
using System.Net.Http.Json;
using Xunit;
using Moq;
using Moq.Contrib.HttpClient;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using ProductCatalog.API.Services;

namespace ProductCatalog.UnitTests.Services;

public class HttpInventoryServiceTests
{
    private readonly Mock<HttpMessageHandler> _mockHandler;
    private readonly Mock<ILogger<HttpInventoryService>> _mockLogger;
    private readonly HttpClient _httpClient;
    private readonly HttpInventoryService _service;

    public HttpInventoryServiceTests()
    {
        _mockHandler = new Mock<HttpMessageHandler>();
        _mockLogger = new Mock<ILogger<HttpInventoryService>>();
        _httpClient = _mockHandler.CreateClient();
        _httpClient.BaseAddress = new Uri("https://inventory.example.com/");
        _service = new HttpInventoryService(_httpClient, _mockLogger.Object);
    }

    [Fact]
    public async Task CheckInventoryAsync_WithSuccessResponse_ReturnsInventoryStatus()
    {
        // Arrange
        var productId = 1;
        var expectedInventory = new InventoryStatus
        {
            ProductId = productId,
            AvailableQuantity = 50,
            ReservedQuantity = 10,
            LastUpdated = DateTime.UtcNow
        };

        _mockHandler.SetupRequest(HttpMethod.Get, $"https://inventory.example.com/api/inventory/{productId}")
            .ReturnsJsonResponse(expectedInventory);

        // Act
        var result = await _service.CheckInventoryAsync(productId);

        // Assert
        result.Should().NotBeNull();
        result.ProductId.Should().Be(productId);
        result.AvailableQuantity.Should().Be(50);
        result.InStock.Should().BeTrue();
    }

    [Fact]
    public async Task CheckInventoryAsync_WithFailedResponse_RetriesAndThrows()
    {
        // Arrange
        var productId = 1;
        var responses = new Queue<HttpResponseMessage>(new[]
        {
            new HttpResponseMessage(HttpStatusCode.InternalServerError),
            new HttpResponseMessage(HttpStatusCode.InternalServerError),
            new HttpResponseMessage(HttpStatusCode.InternalServerError)
        });

        _mockHandler.SetupRequest(HttpMethod.Get, $"https://inventory.example.com/api/inventory/{productId}")
            .Returns(() => Task.FromResult(responses.Dequeue()));

        // Act
        var action = async () => await _service.CheckInventoryAsync(productId);

        // Assert
        await action.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("Unable to check inventory");

        // Verify retries occurred (3 attempts total)
        _mockHandler.VerifyRequest(HttpMethod.Get, 
            $"https://inventory.example.com/api/inventory/{productId}", 
            Times.Exactly(3));
    }

    [Fact]
    public async Task CheckInventoryAsync_WithTimeout_ThrowsTimeoutException()
    {
        // Arrange
        var productId = 1;
        
        _mockHandler.SetupRequest(HttpMethod.Get, $"https://inventory.example.com/api/inventory/{productId}")
            .Throws<TaskCanceledException>();

        // Act
        var action = async () => await _service.CheckInventoryAsync(productId);

        // Assert
        await action.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("Inventory service timeout");
    }

    [Fact]
    public async Task ReserveStockAsync_WithSuccessResponse_ReturnsTrue()
    {
        // Arrange
        var productId = 1;
        var quantity = 5;

        _mockHandler.SetupRequest(HttpMethod.Post, "https://inventory.example.com/api/inventory/reserve")
            .ReturnsResponse(HttpStatusCode.OK);

        // Act
        var result = await _service.ReserveStockAsync(productId, quantity);

        // Assert
        result.Should().BeTrue();
        
        _mockLogger.Verify(
            logger => logger.Log(
                LogLevel.Information,
                It.IsAny<EventId>(),
                It.Is<It.IsAnyType>((v, t) => v.ToString()!.Contains($"Reserved {quantity} units")),
                It.IsAny<Exception>(),
                It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
            Times.Once);
    }

    [Fact]
    public async Task ReserveStockAsync_WithRetrySuccess_ReturnsTrue()
    {
        // Arrange
        var productId = 1;
        var quantity = 5;
        var responses = new Queue<HttpResponseMessage>(new[]
        {
            new HttpResponseMessage(HttpStatusCode.InternalServerError),
            new HttpResponseMessage(HttpStatusCode.OK) // Success on retry
        });

        _mockHandler.SetupRequest(HttpMethod.Post, "https://inventory.example.com/api/inventory/reserve")
            .Returns(() => Task.FromResult(responses.Dequeue()));

        // Act
        var result = await _service.ReserveStockAsync(productId, quantity);

        // Assert
        result.Should().BeTrue();
        
        // Verify retry occurred
        _mockHandler.VerifyRequest(HttpMethod.Post, 
            "https://inventory.example.com/api/inventory/reserve", 
            Times.Exactly(2));
    }
}

// Extension methods for easier HTTP mocking
public static class HttpMessageHandlerExtensions
{
    public static void ReturnsJsonResponse<T>(this ISetupSequentialResult<Task<HttpResponseMessage>> setup, T content)
    {
        var response = new HttpResponseMessage(HttpStatusCode.OK)
        {
            Content = JsonContent.Create(content)
        };
        setup.Returns(Task.FromResult(response));
    }
}
'@ "Unit tests for HTTP client with mocked responses"

        # Create WireMock integration test
        Create-FileInteractive "ProductCatalog.IntegrationTests/ExternalServices/WireMockTests.cs" @'
using System.Net;
using System.Net.Http.Json;
using Xunit;
using FluentAssertions;
using WireMock.Server;
using WireMock.RequestBuilders;
using WireMock.ResponseBuilders;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using ProductCatalog.API.Services;

namespace ProductCatalog.IntegrationTests.ExternalServices;

public class WireMockTests : IDisposable
{
    private readonly WireMockServer _mockServer;
    private readonly HttpClient _httpClient;
    private readonly HttpInventoryService _inventoryService;

    public WireMockTests()
    {
        // Start WireMock server
        _mockServer = WireMockServer.Start();
        
        // Create HTTP client pointing to mock server
        _httpClient = new HttpClient
        {
            BaseAddress = new Uri(_mockServer.Urls[0])
        };
        
        // Create service with mocked HTTP client
        var logger = new LoggerFactory().CreateLogger<HttpInventoryService>();
        _inventoryService = new HttpInventoryService(_httpClient, logger);
    }

    [Fact]
    public async Task CheckInventoryAsync_WithMockedResponse_ReturnsExpectedData()
    {
        // Arrange
        var productId = 123;
        var expectedResponse = new
        {
            productId = productId,
            availableQuantity = 100,
            reservedQuantity = 20,
            lastUpdated = DateTime.UtcNow
        };

        _mockServer
            .Given(Request.Create()
                .WithPath($"/api/inventory/{productId}")
                .UsingGet())
            .RespondWith(Response.Create()
                .WithStatusCode(200)
                .WithHeader("Content-Type", "application/json")
                .WithBodyAsJson(expectedResponse));

        // Act
        var result = await _inventoryService.CheckInventoryAsync(productId);

        // Assert
        result.Should().NotBeNull();
        result.ProductId.Should().Be(productId);
        result.AvailableQuantity.Should().Be(100);
        result.ReservedQuantity.Should().Be(20);
    }

    [Fact]
    public async Task CheckInventoryAsync_WithServerError_HandlesRetryCorrectly()
    {
        // Arrange
        var productId = 456;
        var callCount = 0;

        _mockServer
            .Given(Request.Create()
                .WithPath($"/api/inventory/{productId}")
                .UsingGet())
            .RespondWith(_ =>
            {
                callCount++;
                if (callCount < 3)
                {
                    return Response.Create().WithStatusCode(500);
                }
                return Response.Create()
                    .WithStatusCode(200)
                    .WithBodyAsJson(new { productId, availableQuantity = 50 });
            });

        // Act
        var result = await _inventoryService.CheckInventoryAsync(productId);

        // Assert
        result.Should().NotBeNull();
        result.AvailableQuantity.Should().Be(50);
        callCount.Should().Be(3); // Initial + 2 retries
    }

    [Fact]
    public async Task ReserveStockAsync_WithDelayedResponse_CompletesSuccessfully()
    {
        // Arrange
        var productId = 789;
        var quantity = 10;

        _mockServer
            .Given(Request.Create()
                .WithPath("/api/inventory/reserve")
                .UsingPost()
                .WithBody(body => body.Contains($"\"productId\":{productId}")))
            .RespondWith(Response.Create()
                .WithStatusCode(200)
                .WithDelay(TimeSpan.FromMilliseconds(500))); // Simulate network delay

        // Act
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        var result = await _inventoryService.ReserveStockAsync(productId, quantity);
        stopwatch.Stop();

        // Assert
        result.Should().BeTrue();
        stopwatch.ElapsedMilliseconds.Should().BeGreaterThan(500);
    }

    [Fact]
    public async Task Multiple_Concurrent_Requests_HandledCorrectly()
    {
        // Arrange
        _mockServer
            .Given(Request.Create()
                .WithPath("/api/inventory/*")
                .UsingGet())
            .RespondWith(Response.Create()
                .WithStatusCode(200)
                .WithBodyAsJson(new { productId = 1, availableQuantity = 100 }));

        // Act
        var tasks = Enumerable.Range(1, 10)
            .Select(i => _inventoryService.CheckInventoryAsync(i))
            .ToList();

        var results = await Task.WhenAll(tasks);

        // Assert
        results.Should().HaveCount(10);
        results.Should().AllSatisfy(r => r.Should().NotBeNull());
        
        // Verify all requests were made
        var requests = _mockServer.LogEntries.Select(l => l.RequestMessage).ToList();
        requests.Should().HaveCount(10);
    }

    public void Dispose()
    {
        _httpClient?.Dispose();
        _mockServer?.Stop();
        _mockServer?.Dispose();
    }
}
'@ "Integration tests using WireMock to simulate external services"

        Write-Success "External service mocking examples created!"
        Write-Host ""
        Write-Info "Key concepts demonstrated:"
        Write-Host "• HTTP client mocking with Moq.Contrib.HttpClient"
        Write-Host "• Retry policies with Polly"
        Write-Host "• WireMock for integration testing"
        Write-Host "• Service orchestration testing"
    }

    "exercise04" {
        # Exercise 4: Performance Testing

        Explain-Concept "Performance Testing" @"
Performance testing ensures your application meets speed and efficiency requirements:
• Benchmarking: Measure method execution time
• Load Testing: Simulate concurrent users
• Memory Profiling: Detect memory leaks
• Database Performance: Query optimization
• API Throughput: Requests per second
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 4 requires previous exercises to be completed!"
            Write-Info "Please run exercises in order"
            exit 1
        }

        Write-Info "Creating performance testing project..."

        # Create performance test project
        dotnet new console -n ProductCatalog.PerformanceTests --framework net8.0
        dotnet sln add ProductCatalog.PerformanceTests/ProductCatalog.PerformanceTests.csproj

        # Add references and packages
        Set-Location ProductCatalog.PerformanceTests
        dotnet add reference ../ProductCatalog.API/ProductCatalog.API.csproj
        dotnet add package BenchmarkDotNet
        dotnet add package NBomber
        dotnet add package NBomber.Http
        Set-Location ..

        # Create benchmark tests
        Create-FileInteractive "ProductCatalog.PerformanceTests/Benchmarks/ProductServiceBenchmarks.cs" @'
using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Order;
using Microsoft.Extensions.Logging.Abstractions;
using ProductCatalog.API.Models;
using ProductCatalog.API.Repositories;
using ProductCatalog.API.Services;
using Moq;

namespace ProductCatalog.PerformanceTests.Benchmarks;

[MemoryDiagnoser]
[Orderer(SummaryOrderPolicy.FastestToSlowest)]
[RankColumn]
public class ProductServiceBenchmarks
{
    private ProductService _productService = null!;
    private List<Product> _products = null!;
    private Mock<IProductRepository> _mockRepository = null!;

    [GlobalSetup]
    public void Setup()
    {
        _mockRepository = new Mock<IProductRepository>();
        _productService = new ProductService(_mockRepository.Object, NullLogger<ProductService>.Instance);
        
        // Create test data
        _products = new List<Product>();
        for (int i = 1; i <= 1000; i++)
        {
            _products.Add(new Product
            {
                Id = i,
                Name = $"Product {i}",
                Description = $"Description for product {i}",
                Price = i * 10.99m,
                StockQuantity = i * 2,
                CreatedAt = DateTime.UtcNow.AddDays(-i)
            });
        }

        _mockRepository.Setup(r => r.GetAllAsync()).ReturnsAsync(_products);
        _mockRepository.Setup(r => r.GetByIdAsync(It.IsAny<int>()))
            .ReturnsAsync((int id) => _products.FirstOrDefault(p => p.Id == id));
    }

    [Benchmark]
    public async Task GetSingleProduct()
    {
        await _productService.GetProductByIdAsync(500);
    }

    [Benchmark]
    public async Task GetAllProducts()
    {
        await _productService.GetAllProductsAsync();
    }

    [Benchmark]
    [Arguments(10, 10)]
    [Arguments(100, 20)]
    [Arguments(500, 50)]
    public async Task CalculateDiscountForMultipleProducts(int productCount, decimal discountPercentage)
    {
        var tasks = new List<Task<decimal>>();
        
        for (int i = 1; i <= productCount; i++)
        {
            tasks.Add(_productService.CalculateDiscountedPriceAsync(i, discountPercentage));
        }

        await Task.WhenAll(tasks);
    }

    [Benchmark]
    public async Task CreateProduct()
    {
        var productDto = new ProductDto
        {
            Name = "Benchmark Product",
            Price = 99.99m,
            StockQuantity = 100
        };

        await _productService.CreateProductAsync(productDto);
    }
}
'@ "BenchmarkDotNet performance tests"

        # Create load tests
        Create-FileInteractive "ProductCatalog.PerformanceTests/LoadTests/ApiLoadTests.cs" @'
using NBomber.CSharp;
using NBomber.Http.CSharp;
using NBomber.Plugins.Http.CSharp;
using NBomber.Plugins.Network.Ping;

namespace ProductCatalog.PerformanceTests.LoadTests;

public class ApiLoadTests
{
    public static void RunLoadTest()
    {
        var httpClient = new HttpClient();
        
        var scenario = Scenario.Create("product_api_load_test", async context =>
        {
            var productId = Random.Shared.Next(1, 100);
            
            var request = Http.CreateRequest("GET", $"https://localhost:5001/api/products/{productId}")
                .WithHeader("Accept", "application/json");

            var response = await Http.Send(httpClient, request);

            return response;
        })
        .WithLoadSimulations(
            Simulation.InjectPerSec(rate: 10, during: TimeSpan.FromSeconds(30)),
            Simulation.KeepConstant(copies: 20, during: TimeSpan.FromSeconds(30)),
            Simulation.RampConstant(copies: 0, to: 50, during: TimeSpan.FromSeconds(30))
        );

        NBomberRunner
            .RegisterScenarios(scenario)
            .WithWorkerPlugins(
                new PingPlugin(new PingPluginConfig { Hosts = new[] { "localhost" } }),
                new HttpMetricsPlugin(new[] { HttpVersion.Version1 }))
            .Run();
    }

    public static void RunConcurrentUserTest()
    {
        var httpClient = new HttpClient();
        
        var getProductScenario = Scenario.Create("get_product", async context =>
        {
            var productId = Random.Shared.Next(1, 10);
            var request = Http.CreateRequest("GET", $"https://localhost:5001/api/products/{productId}")
                .WithHeader("Accept", "application/json");

            return await Http.Send(httpClient, request);
        })
        .WithWeight(70); // 70% of requests

        var createProductScenario = Scenario.Create("create_product", async context =>
        {
            var product = new
            {
                name = $"Product {context.InvocationNumber}",
                price = Random.Shared.Next(10, 1000),
                stockQuantity = Random.Shared.Next(1, 100)
            };

            var request = Http.CreateRequest("POST", "https://localhost:5001/api/products")
                .WithHeader("Accept", "application/json")
                .WithHeader("Content-Type", "application/json")
                .WithBody(System.Text.Json.JsonSerializer.Serialize(product));

            return await Http.Send(httpClient, request);
        })
        .WithWeight(20); // 20% of requests

        var searchProductScenario = Scenario.Create("get_all_products", async context =>
        {
            var request = Http.CreateRequest("GET", "https://localhost:5001/api/products")
                .WithHeader("Accept", "application/json");

            return await Http.Send(httpClient, request);
        })
        .WithWeight(10); // 10% of requests

        NBomberRunner
            .RegisterScenarios(getProductScenario, createProductScenario, searchProductScenario)
            .WithLoadSimulations(
                Simulation.InjectPerSec(rate: 100, during: TimeSpan.FromSeconds(60))
            )
            .Run();
    }
}
'@ "NBomber load tests for API endpoints"

        # Create memory profiling tests
        Create-FileInteractive "ProductCatalog.PerformanceTests/Benchmarks/MemoryBenchmarks.cs" @'
using System.Runtime.CompilerServices;
using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Columns;
using BenchmarkDotNet.Configs;
using BenchmarkDotNet.Jobs;
using ProductCatalog.API.Models;

namespace ProductCatalog.PerformanceTests.Benchmarks;

[Config(typeof(MemoryConfig))]
[MemoryDiagnoser]
[ThreadingDiagnoser]
public class MemoryBenchmarks
{
    private class MemoryConfig : ManualConfig
    {
        public MemoryConfig()
        {
            AddColumn(StatisticColumn.Max);
            AddColumn(RankColumn.Arabic);
            AddDiagnoser(BenchmarkDotNet.Diagnosers.MemoryDiagnoser.Default);
            AddJob(Job.ShortRun);
        }
    }

    [Params(100, 1000, 10000)]
    public int ItemCount { get; set; }

    [Benchmark(Baseline = true)]
    public List<ProductDto> CreateProductsList()
    {
        var products = new List<ProductDto>(ItemCount);
        
        for (int i = 0; i < ItemCount; i++)
        {
            products.Add(new ProductDto
            {
                Id = i,
                Name = $"Product {i}",
                Price = i * 10.99m,
                StockQuantity = i % 100
            });
        }

        return products;
    }

    [Benchmark]
    public ProductDto[] CreateProductsArray()
    {
        var products = new ProductDto[ItemCount];
        
        for (int i = 0; i < ItemCount; i++)
        {
            products[i] = new ProductDto
            {
                Id = i,
                Name = $"Product {i}",
                Price = i * 10.99m,
                StockQuantity = i % 100
            };
        }

        return products;
    }

    [Benchmark]
    public IEnumerable<ProductDto> CreateProductsYield()
    {
        return GenerateProducts(ItemCount);
    }

    private IEnumerable<ProductDto> GenerateProducts(int count)
    {
        for (int i = 0; i < count; i++)
        {
            yield return new ProductDto
            {
                Id = i,
                Name = $"Product {i}",
                Price = i * 10.99m,
                StockQuantity = i % 100
            };
        }
    }

    [Benchmark]
    public async Task<List<ProductDto>> ProcessProductsAsync()
    {
        var products = new List<ProductDto>(ItemCount);
        var tasks = new List<Task<ProductDto>>();

        for (int i = 0; i < ItemCount; i++)
        {
            int index = i; // Capture for closure
            tasks.Add(Task.Run(() => new ProductDto
            {
                Id = index,
                Name = $"Product {index}",
                Price = index * 10.99m,
                StockQuantity = index % 100
            }));
        }

        var results = await Task.WhenAll(tasks);
        products.AddRange(results);

        return products;
    }

    [Benchmark]
    public string StringConcatenation()
    {
        string result = "";
        for (int i = 0; i < ItemCount; i++)
        {
            result += $"Product{i},";
        }
        return result;
    }

    [Benchmark]
    public string StringBuilderConcatenation()
    {
        var sb = new System.Text.StringBuilder();
        for (int i = 0; i < ItemCount; i++)
        {
            sb.Append($"Product{i},");
        }
        return sb.ToString();
    }
}
'@ "Memory allocation and efficiency benchmarks"

        # Create performance test runner
        Create-FileInteractive "ProductCatalog.PerformanceTests/Program.cs" @'
using BenchmarkDotNet.Running;
using ProductCatalog.PerformanceTests.Benchmarks;
using ProductCatalog.PerformanceTests.LoadTests;

class Program
{
    static void Main(string[] args)
    {
        Console.WriteLine("Performance Testing Suite");
        Console.WriteLine("========================");
        Console.WriteLine("1. Run Benchmarks");
        Console.WriteLine("2. Run Load Tests");
        Console.WriteLine("3. Run Memory Benchmarks");
        Console.WriteLine("4. Run All Tests");
        Console.WriteLine("5. Exit");
        Console.Write("\nSelect option: ");

        var choice = Console.ReadLine();

        switch (choice)
        {
            case "1":
                RunBenchmarks();
                break;
            case "2":
                RunLoadTests();
                break;
            case "3":
                RunMemoryBenchmarks();
                break;
            case "4":
                RunAllTests();
                break;
            case "5":
                return;
            default:
                Console.WriteLine("Invalid option");
                break;
        }
    }

    static void RunBenchmarks()
    {
        Console.WriteLine("\nRunning Performance Benchmarks...");
        var summary = BenchmarkRunner.Run<ProductServiceBenchmarks>();
        Console.WriteLine("\nBenchmark completed. Results saved to BenchmarkDotNet.Artifacts folder.");
    }

    static void RunLoadTests()
    {
        Console.WriteLine("\nRunning Load Tests...");
        Console.WriteLine("Make sure the API is running on https://localhost:5001");
        Console.WriteLine("Press any key to start...");
        Console.ReadKey();

        ApiLoadTests.RunLoadTest();
        Console.WriteLine("\nLoad test completed. Check the reports folder for results.");
    }

    static void RunMemoryBenchmarks()
    {
        Console.WriteLine("\nRunning Memory Benchmarks...");
        var summary = BenchmarkRunner.Run<MemoryBenchmarks>();
        Console.WriteLine("\nMemory benchmark completed.");
    }

    static void RunAllTests()
    {
        RunBenchmarks();
        RunMemoryBenchmarks();
        Console.WriteLine("\nAll benchmarks completed.");
        Console.WriteLine("Run load tests separately when the API is running.");
    }
}
'@ "Performance test runner application"

        # Create performance testing guide
        Create-FileInteractive "ProductCatalog.PerformanceTests/README.md" @'
# Performance Testing Guide

## Overview
This project contains performance tests using:
- **BenchmarkDotNet**: Micro-benchmarks for method performance
- **NBomber**: Load testing for API endpoints
- **Memory Diagnostics**: Memory allocation analysis

## Running Performance Tests

### 1. Benchmarks
```bash
cd ProductCatalog.PerformanceTests
dotnet run -c Release
# Select option 1 or 3
```

### 2. Load Tests
First, start the API:
```bash
cd ../ProductCatalog.API
dotnet run
```

Then run load tests:
```bash
cd ../ProductCatalog.PerformanceTests
dotnet run -c Release
# Select option 2
```

## Understanding Results

### BenchmarkDotNet Results
- **Mean**: Average execution time
- **Error**: Half of 99.9% confidence interval
- **StdDev**: Standard deviation
- **Median**: Middle value
- **Allocated**: Memory allocated per operation

### NBomber Results
- **RPS**: Requests per second
- **Latency**: Response time percentiles (50%, 75%, 95%, 99%)
- **Data Transfer**: Bytes sent/received
- **Errors**: Failed requests count

## Performance Optimization Tips

### 1. Async/Await Best Practices
```csharp
// Bad - Creates unnecessary state machine
public async Task<string> GetDataAsync()
{
    return await Task.FromResult("data");
}

// Good - Direct return
public Task<string> GetDataAsync()
{
    return Task.FromResult("data");
}
```

### 2. Collection Performance
```csharp
// Specify capacity when known
var list = new List<Product>(1000);

// Use array when size is fixed
var array = new Product[1000];

// Use yield for large sequences
foreach (var item in GetLargeSequence())
{
    // Process without loading all into memory
}
```

### 3. String Operations
```csharp
// Bad for loops
string result = "";
for (int i = 0; i < 1000; i++)
    result += i.ToString();

// Good - Use StringBuilder
var sb = new StringBuilder();
for (int i = 0; i < 1000; i++)
    sb.Append(i);
```

### 4. Database Queries
```csharp
// Bad - N+1 queries
var orders = await context.Orders.ToListAsync();
foreach (var order in orders)
{
    var customer = await context.Customers.FindAsync(order.CustomerId);
}

// Good - Include related data
var orders = await context.Orders
    .Include(o => o.Customer)
    .ToListAsync();
```

## Common Performance Issues

1. **Memory Leaks**
   - Not disposing IDisposable objects
   - Event handler references
   - Static collections growing unbounded

2. **Inefficient Queries**
   - Loading unnecessary data
   - Missing indexes
   - N+1 query problems

3. **Blocking Async Code**
   - Using .Result or .Wait()
   - Synchronous I/O in async methods

4. **Over-allocation**
   - Creating too many temporary objects
   - Large object heap fragmentation
   - String concatenation in loops

## Continuous Performance Testing

Integrate performance tests into CI/CD:

```yaml
# In GitHub Actions or Azure DevOps
- name: Run Performance Tests
  run: |
    dotnet run -c Release --project ProductCatalog.PerformanceTests -- --filter "*" --exporters json
    
- name: Compare Results
  run: |
    # Compare with baseline
    dotnet tool install -g BenchmarkDotNet.Tool
    dotnet benchmark compare baseline.json results.json
```
'@ "Comprehensive performance testing guide"

        Write-Success "Performance testing project created!"
        Write-Host ""
        Write-Info "Performance tests created! To run:"
        Write-Host "1. Benchmarks: " -NoNewline
        Write-Host "dotnet run -c Release" -ForegroundColor Cyan
        Write-Host "2. Start API first for load tests: " -NoNewline
        Write-Host "dotnet run --project ProductCatalog.API" -ForegroundColor Cyan
        Write-Host "3. Memory profiling included in benchmarks"
    }
}

Write-Host ""
Write-Success "🎉 $ExerciseName setup completed successfully!"
Write-Host ""
Write-Info "📋 Next steps:"

switch ($ExerciseName) {
    "exercise01" {
        Write-Host "1. Explore the created unit tests in ProductCatalog.UnitTests"
        Write-Host "2. Run tests: " -NoNewline
        Write-Host "dotnet test" -ForegroundColor Cyan
        Write-Host "3. Try writing additional test cases"
        Write-Host "4. Aim for 80%+ code coverage"
    }
    "exercise02" {
        Write-Host "1. Review the integration tests in ProductCatalog.IntegrationTests"
        Write-Host "2. Run integration tests: " -NoNewline
        Write-Host "dotnet test ProductCatalog.IntegrationTests" -ForegroundColor Cyan
        Write-Host "3. Experiment with WebApplicationFactory customization"
    }
    "exercise03" {
        Write-Host "1. Study the external service mocking patterns"
        Write-Host "2. Run tests with mocked services"
        Write-Host "3. Try WireMock for more complex scenarios"
        Write-Host "4. Implement retry policies with Polly"
    }
    "exercise04" {
        Write-Host "1. Run performance benchmarks in Release mode"
        Write-Host "2. Analyze memory allocation results"
        Write-Host "3. Conduct load tests with NBomber"
        Write-Host "4. Identify and optimize bottlenecks"
    }
}

Write-Host ""
Write-Info "📚 For detailed instructions, refer to the exercise guide files in the Exercises directory."
Write-Info "🔗 Additional testing resources available in the Resources directory."