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
    if ($ExerciseName -eq "exercise02" -or $ExerciseName -eq "exercise03" -or $ExerciseName -eq "exercise04") {
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
        # Exercise 1: Unit Testing Basics

        Show-Concept -ConceptName "Unit Testing Fundamentals" -Explanation @"
Unit testing is the foundation of a robust testing strategy:
• Test individual components in isolation
• Use mocks to isolate dependencies
• Follow Arrange-Act-Assert pattern
• Write tests that are fast, reliable, and maintainable
• Use descriptive test names that explain the scenario
"@

        if (-not $SkipProjectCreation) {
            Write-Host "[CREATE] Creating solution and projects for testing..." -ForegroundColor Cyan

            # Create project directory
            New-Item -ItemType Directory -Name $ProjectName -Force
            Set-Location $ProjectName

            # Create solution
            dotnet new sln -n $ProjectName

            # Create API project
            dotnet new webapi -n "$ProjectName.API" --framework net8.0
            Set-Location "$ProjectName.API"
            Remove-Item -Path "WeatherForecast.cs" -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "Controllers/WeatherForecastController.cs" -Force -ErrorAction SilentlyContinue
            Set-Location ".."

            # Create Unit Test project
            dotnet new xunit -n "$ProjectName.UnitTests" --framework net8.0

            # Add projects to solution
            dotnet sln add "$ProjectName.API"
            dotnet sln add "$ProjectName.UnitTests"

            # Add project reference
            Set-Location "$ProjectName.UnitTests"
            dotnet add reference "../$ProjectName.API"

            # Install testing packages
            Write-Host "[PACKAGE] Installing testing packages..." -ForegroundColor Cyan
            dotnet add package Moq
            dotnet add package FluentAssertions
            dotnet add package Microsoft.Extensions.Logging.Abstractions

            Set-Location ".."
            Set-Location "$ProjectName.API"

            # Install API packages
            dotnet add package Microsoft.EntityFrameworkCore.InMemory

            Set-Location ".."
        } else {
            # We're already in the project directory from the check above
        }

        Show-Concept -ConceptName "Test-Driven Development Models" -Explanation @"
Creating models and services that are testable:
• Simple POCOs for easy testing
• Interfaces for dependency injection
• Clear separation of concerns
• Minimal external dependencies
"@

        # Create Product model
        New-FileInteractive -FilePath "$ProjectName.API/Models/Product.cs" -Description "Product model with validation attributes for testing" -Content @'
using System.ComponentModel.DataAnnotations;

namespace TestingDemo.API.Models;

public class Product
{
    public int Id { get; set; }

    [Required]
    [StringLength(200)]
    public string Name { get; set; } = string.Empty;

    [StringLength(2000)]
    public string Description { get; set; } = string.Empty;

    [Range(0.01, double.MaxValue)]
    public decimal Price { get; set; }

    [Range(0, int.MaxValue)]
    public int StockQuantity { get; set; }

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
'@

        # Create custom exceptions
        New-FileInteractive -FilePath "$ProjectName.API/Models/Exceptions.cs" -Description "Custom exceptions for testing error scenarios" -Content @'
namespace TestingDemo.API.Models;

public class NotFoundException : Exception
{
    public NotFoundException(string message) : base(message) { }
}

public class ValidationException : Exception
{
    public ValidationException(string message) : base(message) { }
}
'@

        # Create repository interface
        New-FileInteractive -FilePath "$ProjectName.API/Repositories/IProductRepository.cs" -Description "Repository interface for dependency injection and mocking" -Content @'
using TestingDemo.API.Models;

namespace TestingDemo.API.Repositories;

public interface IProductRepository
{
    Task<Product?> GetByIdAsync(int id);
    Task<List<Product>> GetAllAsync();
    Task<Product> AddAsync(Product product);
    Task UpdateAsync(Product product);
    Task DeleteAsync(int id);
}
'@

        # Create ProductService
        New-FileInteractive -FilePath "$ProjectName.API/Services/ProductService.cs" -Description "ProductService with business logic to be tested" -Content @'
using Microsoft.Extensions.Logging;
using TestingDemo.API.Models;
using TestingDemo.API.Repositories;

namespace TestingDemo.API.Services;

public interface IProductService
{
    Task<Product> GetProductByIdAsync(int id);
    Task<List<Product>> GetAllProductsAsync();
    Task<Product> CreateProductAsync(Product product);
    Task UpdateProductAsync(int id, Product product);
    Task DeleteProductAsync(int id);
}

public class ProductService : IProductService
{
    private readonly IProductRepository _repository;
    private readonly ILogger<ProductService> _logger;

    public ProductService(IProductRepository repository, ILogger<ProductService> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    public async Task<Product> GetProductByIdAsync(int id)
    {
        var product = await _repository.GetByIdAsync(id);
        if (product == null)
        {
            _logger.LogWarning("Product with ID {ProductId} not found", id);
            throw new NotFoundException($"Product with ID {id} not found");
        }
        return product;
    }

    public async Task<List<Product>> GetAllProductsAsync()
    {
        return await _repository.GetAllAsync();
    }

    public async Task<Product> CreateProductAsync(Product product)
    {
        if (product == null)
        {
            throw new ArgumentNullException(nameof(product));
        }

        if (string.IsNullOrWhiteSpace(product.Name))
        {
            throw new ValidationException("Product name is required");
        }

        if (product.Price <= 0)
        {
            throw new ValidationException("Product price must be greater than zero");
        }

        return await _repository.AddAsync(product);
    }

    public async Task UpdateProductAsync(int id, Product product)
    {
        if (product == null)
        {
            throw new ArgumentNullException(nameof(product));
        }

        var existingProduct = await _repository.GetByIdAsync(id);
        if (existingProduct == null)
        {
            throw new NotFoundException($"Product with ID {id} not found");
        }

        existingProduct.Name = product.Name;
        existingProduct.Description = product.Description;
        existingProduct.Price = product.Price;
        existingProduct.StockQuantity = product.StockQuantity;

        await _repository.UpdateAsync(existingProduct);
    }

    public async Task DeleteProductAsync(int id)
    {
        var product = await _repository.GetByIdAsync(id);
        if (product == null)
        {
            throw new NotFoundException($"Product with ID {id} not found");
        }

        await _repository.DeleteAsync(id);
    }
}
'@

        Show-Concept -ConceptName "Unit Test Structure" -Explanation @"
Effective unit tests follow clear patterns:
• Arrange: Set up test data and mocks
• Act: Execute the method being tested
• Assert: Verify the expected outcome
• Use descriptive test names that explain the scenario
• Test one thing at a time
"@

        # Create unit tests
        New-FileInteractive -FilePath "$ProjectName.UnitTests/Services/ProductServiceTests.cs" -Description "Comprehensive unit tests with Arrange-Act-Assert pattern and mocking" -Content @'
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;
using TestingDemo.API.Models;
using TestingDemo.API.Repositories;
using TestingDemo.API.Services;

namespace TestingDemo.UnitTests.Services;

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
            Price = 10.99m
        };

        _mockRepository.Setup(r => r.GetByIdAsync(productId))
                      .ReturnsAsync(expectedProduct);

        // Act
        var result = await _productService.GetProductByIdAsync(productId);

        // Assert
        result.Should().NotBeNull();
        result.Should().BeEquivalentTo(expectedProduct);
        _mockRepository.Verify(r => r.GetByIdAsync(productId), Times.Once);
    }

    [Fact]
    public async Task GetProductByIdAsync_WithInvalidId_ThrowsNotFoundException()
    {
        // Arrange
        var productId = 999;
        _mockRepository.Setup(r => r.GetByIdAsync(productId))
                      .ReturnsAsync((Product?)null);

        // Act & Assert
        var exception = await Assert.ThrowsAsync<NotFoundException>(
            () => _productService.GetProductByIdAsync(productId));

        exception.Message.Should().Contain($"Product with ID {productId} not found");
    }

    [Fact]
    public async Task CreateProductAsync_WithValidProduct_ReturnsCreatedProduct()
    {
        // Arrange
        var newProduct = new Product
        {
            Name = "New Product",
            Price = 15.99m,
            StockQuantity = 10
        };

        var createdProduct = new Product
        {
            Id = 1,
            Name = newProduct.Name,
            Price = newProduct.Price,
            StockQuantity = newProduct.StockQuantity
        };

        _mockRepository.Setup(r => r.AddAsync(It.IsAny<Product>()))
                      .ReturnsAsync(createdProduct);

        // Act
        var result = await _productService.CreateProductAsync(newProduct);

        // Assert
        result.Should().NotBeNull();
        result.Id.Should().Be(1);
        result.Name.Should().Be(newProduct.Name);
        _mockRepository.Verify(r => r.AddAsync(It.IsAny<Product>()), Times.Once);
    }

    [Fact]
    public async Task CreateProductAsync_WithNullProduct_ThrowsArgumentNullException()
    {
        // Act & Assert
        await Assert.ThrowsAsync<ArgumentNullException>(
            () => _productService.CreateProductAsync(null!));
    }

    [Theory]
    [InlineData("")]
    [InlineData(" ")]
    [InlineData(null)]
    public async Task CreateProductAsync_WithInvalidName_ThrowsValidationException(string invalidName)
    {
        // Arrange
        var product = new Product
        {
            Name = invalidName,
            Price = 10.99m
        };

        // Act & Assert
        var exception = await Assert.ThrowsAsync<ValidationException>(
            () => _productService.CreateProductAsync(product));

        exception.Message.Should().Contain("Product name is required");
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    [InlineData(-10.50)]
    public async Task CreateProductAsync_WithInvalidPrice_ThrowsValidationException(decimal invalidPrice)
    {
        // Arrange
        var product = new Product
        {
            Name = "Test Product",
            Price = invalidPrice
        };

        // Act & Assert
        var exception = await Assert.ThrowsAsync<ValidationException>(
            () => _productService.CreateProductAsync(product));

        exception.Message.Should().Contain("Product price must be greater than zero");
    }

    // TODO: Add more tests for UpdateProductAsync and DeleteProductAsync
    // TODO: Add tests for GetAllProductsAsync
    // TODO: Add tests for edge cases and error scenarios
}
'@

        # Create test data builders
        New-FileInteractive -FilePath "$ProjectName.UnitTests/TestData/ProductTestDataBuilder.cs" -Description "Test data builder pattern for creating test objects" -Content @'
using TestingDemo.API.Models;

namespace TestingDemo.UnitTests.TestData;

public class ProductTestDataBuilder
{
    private Product _product = new()
    {
        Id = 1,
        Name = "Test Product",
        Description = "Test Description",
        Price = 10.99m,
        StockQuantity = 5,
        IsActive = true,
        CreatedAt = DateTime.UtcNow
    };

    public ProductTestDataBuilder WithId(int id)
    {
        _product.Id = id;
        return this;
    }

    public ProductTestDataBuilder WithName(string name)
    {
        _product.Name = name;
        return this;
    }

    public ProductTestDataBuilder WithPrice(decimal price)
    {
        _product.Price = price;
        return this;
    }

    public ProductTestDataBuilder WithStockQuantity(int quantity)
    {
        _product.StockQuantity = quantity;
        return this;
    }

    public ProductTestDataBuilder WithDescription(string description)
    {
        _product.Description = description;
        return this;
    }

    public ProductTestDataBuilder IsInactive()
    {
        _product.IsActive = false;
        return this;
    }

    public Product Build() => _product;

    public static ProductTestDataBuilder AProduct() => new();
}
'@

        Write-Host "[OK] Exercise 1 template created successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "[NEXT] Next steps:" -ForegroundColor Yellow
        Write-Host "1. Build the solution: dotnet build" -ForegroundColor Cyan
        Write-Host "2. Run the tests: dotnet test" -ForegroundColor Cyan
        Write-Host "3. Explore the test structure and patterns" -ForegroundColor Cyan
        Write-Host "4. Add more tests for complete coverage" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "[TIP] Test files created:" -ForegroundColor Blue
        Write-Host "  - ProductServiceTests.cs (unit tests)" -ForegroundColor White
        Write-Host "  - ProductTestDataBuilder.cs (test data)" -ForegroundColor White
        Write-Host "  - Product.cs (model to test)" -ForegroundColor White
        Write-Host "  - ProductService.cs (service to test)" -ForegroundColor White
    }

    "exercise02" {
        # Exercise 2: Integration Testing with WebApplicationFactory

        Show-Concept -ConceptName "Integration Testing" -Explanation @"
Integration testing verifies that different parts of your application work together:
• Test complete request/response cycles
• Use WebApplicationFactory for in-memory testing
• Test with real HTTP requests and responses
• Verify database interactions and middleware behavior
• Test authentication and authorization flows
"@

        if (-not $SkipProjectCreation) {
            Write-Host "[ERROR] Exercise 2 requires Exercise 1 to be completed first!" -ForegroundColor Red
            Write-Host "[INFO] Please run: .\launch-exercises.ps1 exercise01" -ForegroundColor Yellow
            Write-Host "[DEBUG] Looking for project directory: $ProjectName" -ForegroundColor Yellow
            exit 1
        }

        Write-Host "[PACKAGE] Adding integration testing packages..." -ForegroundColor Cyan
        Set-Location "$ProjectName.UnitTests"
        dotnet add package Microsoft.AspNetCore.Mvc.Testing
        dotnet add package Microsoft.EntityFrameworkCore.InMemory
        Set-Location ".."

        # Create integration test project
        dotnet new xunit -n "$ProjectName.IntegrationTests" --framework net8.0
        dotnet sln add "$ProjectName.IntegrationTests"

        Set-Location "$ProjectName.IntegrationTests"
        dotnet add reference "../$ProjectName.API"
        dotnet add package Microsoft.AspNetCore.Mvc.Testing
        dotnet add package FluentAssertions
        dotnet add package Microsoft.EntityFrameworkCore.InMemory
        Set-Location ".."

        # Create ProductController for testing
        New-FileInteractive -FilePath "$ProjectName.API/Controllers/ProductsController.cs" -Description "Products API controller for integration testing" -Content @'
using Microsoft.AspNetCore.Mvc;
using TestingDemo.API.Models;
using TestingDemo.API.Services;

namespace TestingDemo.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;

    public ProductsController(IProductService productService)
    {
        _productService = productService;
    }

    [HttpGet]
    public async Task<ActionResult<List<Product>>> GetProducts()
    {
        var products = await _productService.GetAllProductsAsync();
        return Ok(products);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Product>> GetProduct(int id)
    {
        try
        {
            var product = await _productService.GetProductByIdAsync(id);
            return Ok(product);
        }
        catch (NotFoundException)
        {
            return NotFound();
        }
    }

    [HttpPost]
    public async Task<ActionResult<Product>> CreateProduct(Product product)
    {
        try
        {
            var createdProduct = await _productService.CreateProductAsync(product);
            return CreatedAtAction(nameof(GetProduct), new { id = createdProduct.Id }, createdProduct);
        }
        catch (ValidationException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateProduct(int id, Product product)
    {
        try
        {
            await _productService.UpdateProductAsync(id, product);
            return NoContent();
        }
        catch (NotFoundException)
        {
            return NotFound();
        }
        catch (ValidationException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteProduct(int id)
    {
        try
        {
            await _productService.DeleteProductAsync(id);
            return NoContent();
        }
        catch (NotFoundException)
        {
            return NotFound();
        }
    }
}
'@

        # Create integration tests
        New-FileInteractive -FilePath "$ProjectName.IntegrationTests/ProductsControllerTests.cs" -Description "Integration tests for Products API using WebApplicationFactory" -Content @'
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using System.Net;
using System.Net.Http.Json;
using TestingDemo.API.Models;
using TestingDemo.API.Repositories;
using TestingDemo.API.Services;

namespace TestingDemo.IntegrationTests;

public class ProductsControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public ProductsControllerTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                // Replace repository with in-memory implementation for testing
                services.AddScoped<IProductRepository, InMemoryProductRepository>();
            });
        });
        _client = _factory.CreateClient();
    }

    [Fact]
    public async Task GetProducts_ReturnsSuccessAndCorrectContentType()
    {
        // Act
        var response = await _client.GetAsync("/api/products");

        // Assert
        response.EnsureSuccessStatusCode();
        response.Content.Headers.ContentType?.ToString().Should().Contain("application/json");
    }

    [Fact]
    public async Task GetProduct_WithValidId_ReturnsProduct()
    {
        // Arrange
        var newProduct = new Product
        {
            Name = "Test Product",
            Price = 10.99m,
            StockQuantity = 5
        };

        var createResponse = await _client.PostAsJsonAsync("/api/products", newProduct);
        var createdProduct = await createResponse.Content.ReadFromJsonAsync<Product>();

        // Act
        var response = await _client.GetAsync($"/api/products/{createdProduct!.Id}");

        // Assert
        response.EnsureSuccessStatusCode();
        var product = await response.Content.ReadFromJsonAsync<Product>();
        product.Should().NotBeNull();
        product!.Name.Should().Be(newProduct.Name);
    }

    [Fact]
    public async Task GetProduct_WithInvalidId_ReturnsNotFound()
    {
        // Act
        var response = await _client.GetAsync("/api/products/999");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task CreateProduct_WithValidProduct_ReturnsCreated()
    {
        // Arrange
        var newProduct = new Product
        {
            Name = "New Product",
            Price = 15.99m,
            StockQuantity = 10
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/products", newProduct);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        var createdProduct = await response.Content.ReadFromJsonAsync<Product>();
        createdProduct.Should().NotBeNull();
        createdProduct!.Name.Should().Be(newProduct.Name);
    }

    [Fact]
    public async Task CreateProduct_WithInvalidProduct_ReturnsBadRequest()
    {
        // Arrange
        var invalidProduct = new Product
        {
            Name = "", // Invalid: empty name
            Price = 10.99m
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/products", invalidProduct);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }
}

// Simple in-memory repository for testing
public class InMemoryProductRepository : IProductRepository
{
    private readonly List<Product> _products = new();
    private int _nextId = 1;

    public Task<Product?> GetByIdAsync(int id)
    {
        var product = _products.FirstOrDefault(p => p.Id == id);
        return Task.FromResult(product);
    }

    public Task<List<Product>> GetAllAsync()
    {
        return Task.FromResult(_products.ToList());
    }

    public Task<Product> AddAsync(Product product)
    {
        product.Id = _nextId++;
        _products.Add(product);
        return Task.FromResult(product);
    }

    public Task UpdateAsync(Product product)
    {
        var existingProduct = _products.FirstOrDefault(p => p.Id == product.Id);
        if (existingProduct != null)
        {
            existingProduct.Name = product.Name;
            existingProduct.Description = product.Description;
            existingProduct.Price = product.Price;
            existingProduct.StockQuantity = product.StockQuantity;
        }
        return Task.CompletedTask;
    }

    public Task DeleteAsync(int id)
    {
        var product = _products.FirstOrDefault(p => p.Id == id);
        if (product != null)
        {
            _products.Remove(product);
        }
        return Task.CompletedTask;
    }
}
'@

        Write-Host "[OK] Exercise 2 template created successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "[NEXT] Next steps:" -ForegroundColor Yellow
        Write-Host "1. Build the solution: dotnet build" -ForegroundColor Cyan
        Write-Host "2. Run integration tests: dotnet test $ProjectName.IntegrationTests" -ForegroundColor Cyan
        Write-Host "3. Test API endpoints with HTTP requests" -ForegroundColor Cyan
        Write-Host "4. Experiment with different test scenarios" -ForegroundColor Cyan
    }

    "exercise03" {
        # Exercise 3: Mocking External Services

        Show-Concept -ConceptName "Mocking External Dependencies" -Explanation @"
Mocking external services is crucial for reliable testing:
• Isolate your code from external dependencies
• Control the behavior of external services
• Test error scenarios and edge cases
• Ensure tests are fast and deterministic
• Use HttpClient mocking for API calls
"@

        if (-not $SkipProjectCreation) {
            Write-Host "[ERROR] Exercise 3 requires Exercises 1 and 2 to be completed first!" -ForegroundColor Red
            Write-Host "[INFO] Please run exercises in order: exercise01, exercise02, exercise03" -ForegroundColor Yellow
            exit 1
        }

        # Create external service interface
        New-FileInteractive -FilePath "$ProjectName.API/Services/IExternalPricingService.cs" -Description "External pricing service interface for mocking" -Content @'
namespace TestingDemo.API.Services;

public interface IExternalPricingService
{
    Task<decimal> GetDiscountedPriceAsync(int productId, decimal originalPrice);
    Task<bool> IsProductOnSaleAsync(int productId);
}

public class ExternalPricingService : IExternalPricingService
{
    private readonly HttpClient _httpClient;

    public ExternalPricingService(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<decimal> GetDiscountedPriceAsync(int productId, decimal originalPrice)
    {
        // Simulate external API call
        var response = await _httpClient.GetAsync($"https://api.pricing.com/discount/{productId}");

        if (response.IsSuccessStatusCode)
        {
            var discountPercentage = await response.Content.ReadAsStringAsync();
            if (decimal.TryParse(discountPercentage, out var discount))
            {
                return originalPrice * (1 - discount / 100);
            }
        }

        return originalPrice; // No discount if API fails
    }

    public async Task<bool> IsProductOnSaleAsync(int productId)
    {
        var response = await _httpClient.GetAsync($"https://api.pricing.com/sale/{productId}");

        if (response.IsSuccessStatusCode)
        {
            var result = await response.Content.ReadAsStringAsync();
            return bool.TryParse(result, out var isOnSale) && isOnSale;
        }

        return false;
    }
}
'@

        # Create enhanced ProductService with external dependency
        New-FileInteractive -FilePath "$ProjectName.API/Services/EnhancedProductService.cs" -Description "Enhanced ProductService with external pricing dependency" -Content @'
using Microsoft.Extensions.Logging;
using TestingDemo.API.Models;
using TestingDemo.API.Repositories;

namespace TestingDemo.API.Services;

public interface IEnhancedProductService
{
    Task<Product> GetProductWithPricingAsync(int id);
    Task<List<Product>> GetProductsOnSaleAsync();
}

public class EnhancedProductService : IEnhancedProductService
{
    private readonly IProductRepository _repository;
    private readonly IExternalPricingService _pricingService;
    private readonly ILogger<EnhancedProductService> _logger;

    public EnhancedProductService(
        IProductRepository repository,
        IExternalPricingService pricingService,
        ILogger<EnhancedProductService> logger)
    {
        _repository = repository;
        _pricingService = pricingService;
        _logger = logger;
    }

    public async Task<Product> GetProductWithPricingAsync(int id)
    {
        var product = await _repository.GetByIdAsync(id);
        if (product == null)
        {
            throw new NotFoundException($"Product with ID {id} not found");
        }

        try
        {
            var discountedPrice = await _pricingService.GetDiscountedPriceAsync(id, product.Price);
            product.Price = discountedPrice;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to get discounted price for product {ProductId}", id);
            // Continue with original price
        }

        return product;
    }

    public async Task<List<Product>> GetProductsOnSaleAsync()
    {
        var allProducts = await _repository.GetAllAsync();
        var productsOnSale = new List<Product>();

        foreach (var product in allProducts)
        {
            try
            {
                var isOnSale = await _pricingService.IsProductOnSaleAsync(product.Id);
                if (isOnSale)
                {
                    productsOnSale.Add(product);
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to check sale status for product {ProductId}", product.Id);
            }
        }

        return productsOnSale;
    }
}
'@

        # Create mocking tests
        New-FileInteractive -FilePath "$ProjectName.UnitTests/Services/EnhancedProductServiceTests.cs" -Description "Tests demonstrating advanced mocking techniques" -Content @'
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;
using TestingDemo.API.Models;
using TestingDemo.API.Repositories;
using TestingDemo.API.Services;

namespace TestingDemo.UnitTests.Services;

public class EnhancedProductServiceTests
{
    private readonly Mock<IProductRepository> _mockRepository;
    private readonly Mock<IExternalPricingService> _mockPricingService;
    private readonly Mock<ILogger<EnhancedProductService>> _mockLogger;
    private readonly EnhancedProductService _service;

    public EnhancedProductServiceTests()
    {
        _mockRepository = new Mock<IProductRepository>();
        _mockPricingService = new Mock<IExternalPricingService>();
        _mockLogger = new Mock<ILogger<EnhancedProductService>>();
        _service = new EnhancedProductService(_mockRepository.Object, _mockPricingService.Object, _mockLogger.Object);
    }

    [Fact]
    public async Task GetProductWithPricingAsync_WithValidId_ReturnsProductWithDiscountedPrice()
    {
        // Arrange
        var productId = 1;
        var originalPrice = 100m;
        var discountedPrice = 80m;

        var product = new Product
        {
            Id = productId,
            Name = "Test Product",
            Price = originalPrice
        };

        _mockRepository.Setup(r => r.GetByIdAsync(productId))
                      .ReturnsAsync(product);

        _mockPricingService.Setup(p => p.GetDiscountedPriceAsync(productId, originalPrice))
                          .ReturnsAsync(discountedPrice);

        // Act
        var result = await _service.GetProductWithPricingAsync(productId);

        // Assert
        result.Should().NotBeNull();
        result.Price.Should().Be(discountedPrice);
        _mockPricingService.Verify(p => p.GetDiscountedPriceAsync(productId, originalPrice), Times.Once);
    }

    [Fact]
    public async Task GetProductWithPricingAsync_WhenPricingServiceFails_ReturnsOriginalPrice()
    {
        // Arrange
        var productId = 1;
        var originalPrice = 100m;

        var product = new Product
        {
            Id = productId,
            Name = "Test Product",
            Price = originalPrice
        };

        _mockRepository.Setup(r => r.GetByIdAsync(productId))
                      .ReturnsAsync(product);

        _mockPricingService.Setup(p => p.GetDiscountedPriceAsync(productId, originalPrice))
                          .ThrowsAsync(new HttpRequestException("Service unavailable"));

        // Act
        var result = await _service.GetProductWithPricingAsync(productId);

        // Assert
        result.Should().NotBeNull();
        result.Price.Should().Be(originalPrice); // Should fallback to original price
    }

    [Fact]
    public async Task GetProductsOnSaleAsync_ReturnsOnlyProductsOnSale()
    {
        // Arrange
        var products = new List<Product>
        {
            new() { Id = 1, Name = "Product 1", Price = 10m },
            new() { Id = 2, Name = "Product 2", Price = 20m },
            new() { Id = 3, Name = "Product 3", Price = 30m }
        };

        _mockRepository.Setup(r => r.GetAllAsync())
                      .ReturnsAsync(products);

        // Setup pricing service to return different sale statuses
        _mockPricingService.Setup(p => p.IsProductOnSaleAsync(1)).ReturnsAsync(true);
        _mockPricingService.Setup(p => p.IsProductOnSaleAsync(2)).ReturnsAsync(false);
        _mockPricingService.Setup(p => p.IsProductOnSaleAsync(3)).ReturnsAsync(true);

        // Act
        var result = await _service.GetProductsOnSaleAsync();

        // Assert
        result.Should().HaveCount(2);
        result.Should().Contain(p => p.Id == 1);
        result.Should().Contain(p => p.Id == 3);
        result.Should().NotContain(p => p.Id == 2);
    }

    [Fact]
    public async Task GetProductsOnSaleAsync_WhenPricingServiceFailsForSomeProducts_ReturnsAvailableResults()
    {
        // Arrange
        var products = new List<Product>
        {
            new() { Id = 1, Name = "Product 1", Price = 10m },
            new() { Id = 2, Name = "Product 2", Price = 20m }
        };

        _mockRepository.Setup(r => r.GetAllAsync())
                      .ReturnsAsync(products);

        _mockPricingService.Setup(p => p.IsProductOnSaleAsync(1)).ReturnsAsync(true);
        _mockPricingService.Setup(p => p.IsProductOnSaleAsync(2))
                          .ThrowsAsync(new HttpRequestException("Service unavailable"));

        // Act
        var result = await _service.GetProductsOnSaleAsync();

        // Assert
        result.Should().HaveCount(1);
        result.Should().Contain(p => p.Id == 1);
    }
}
'@

        Write-Host "[OK] Exercise 3 template created successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "[NEXT] Next steps:" -ForegroundColor Yellow
        Write-Host "1. Build the solution: dotnet build" -ForegroundColor Cyan
        Write-Host "2. Run the mocking tests: dotnet test" -ForegroundColor Cyan
        Write-Host "3. Explore different mocking scenarios" -ForegroundColor Cyan
        Write-Host "4. Practice with different mocking scenarios" -ForegroundColor Cyan
    }

    "exercise04" {
        # Exercise 4: Performance Testing with BenchmarkDotNet

        Show-Concept -ConceptName "Performance Testing" -Explanation @"
Performance testing ensures your application meets performance requirements:
• Benchmark critical code paths
• Measure memory allocations and CPU usage
• Detect performance regressions
• Compare different implementations
• Use BenchmarkDotNet for accurate measurements
"@

        if (-not $SkipProjectCreation) {
            Write-Host "[ERROR] Exercise 4 requires Exercises 1, 2, and 3 to be completed first!" -ForegroundColor Red
            Write-Host "[INFO] Please run exercises in order: exercise01, exercise02, exercise03, exercise04" -ForegroundColor Yellow
            exit 1
        }

        # Create performance test project
        dotnet new console -n "$ProjectName.PerformanceTests" --framework net8.0
        dotnet sln add "$ProjectName.PerformanceTests"

        Set-Location "$ProjectName.PerformanceTests"
        dotnet add reference "../$ProjectName.API"
        dotnet add package BenchmarkDotNet
        Set-Location ".."

        # Create benchmark tests
        New-FileInteractive -FilePath "$ProjectName.PerformanceTests/ProductServiceBenchmarks.cs" -Description "Performance benchmarks for ProductService operations" -Content @'
using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Running;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;
using TestingDemo.API.Models;
using TestingDemo.API.Repositories;
using TestingDemo.API.Services;

namespace TestingDemo.PerformanceTests;

[MemoryDiagnoser]
[SimpleJob]
public class ProductServiceBenchmarks
{
    private ProductService _productService = null!;
    private Mock<IProductRepository> _mockRepository = null!;
    private List<Product> _products = null!;

    [GlobalSetup]
    public void Setup()
    {
        _mockRepository = new Mock<IProductRepository>();
        _productService = new ProductService(_mockRepository.Object, NullLogger<ProductService>.Instance);

        // Create test data
        _products = Enumerable.Range(1, 1000)
            .Select(i => new Product
            {
                Id = i,
                Name = $"Product {i}",
                Price = i * 10m,
                StockQuantity = i % 100
            })
            .ToList();

        _mockRepository.Setup(r => r.GetAllAsync())
                      .ReturnsAsync(_products);
    }

    [Benchmark]
    public async Task GetAllProducts()
    {
        await _productService.GetAllProductsAsync();
    }

    [Benchmark]
    [Arguments(1)]
    [Arguments(500)]
    [Arguments(1000)]
    public async Task GetProductById(int id)
    {
        var product = _products.FirstOrDefault(p => p.Id == id);
        _mockRepository.Setup(r => r.GetByIdAsync(id))
                      .ReturnsAsync(product);

        try
        {
            await _productService.GetProductByIdAsync(id);
        }
        catch (NotFoundException)
        {
            // Expected for non-existent products
        }
    }

    [Benchmark]
    public async Task CreateProduct()
    {
        var newProduct = new Product
        {
            Name = "Benchmark Product",
            Price = 99.99m,
            StockQuantity = 10
        };

        var createdProduct = new Product
        {
            Id = 1001,
            Name = newProduct.Name,
            Price = newProduct.Price,
            StockQuantity = newProduct.StockQuantity
        };

        _mockRepository.Setup(r => r.AddAsync(It.IsAny<Product>()))
                      .ReturnsAsync(createdProduct);

        await _productService.CreateProductAsync(newProduct);
    }
}
'@

        # Create Program.cs for running benchmarks
        New-FileInteractive -FilePath "$ProjectName.PerformanceTests/Program.cs" -Description "Console application to run performance benchmarks" -Content @'
using BenchmarkDotNet.Running;
using TestingDemo.PerformanceTests;

Console.WriteLine("Starting Performance Benchmarks...");
Console.WriteLine("This may take several minutes to complete.");
Console.WriteLine();

var summary = BenchmarkRunner.Run<ProductServiceBenchmarks>();

Console.WriteLine("Benchmarks completed!");
Console.WriteLine($"Results saved to: {summary.ResultsDirectoryPath}");
'@

        # Create simple load test
        New-FileInteractive -FilePath "$ProjectName.PerformanceTests/LoadTests.cs" -Description "Simple load testing scenarios" -Content @'
using System.Diagnostics;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;
using TestingDemo.API.Models;
using TestingDemo.API.Repositories;
using TestingDemo.API.Services;

namespace TestingDemo.PerformanceTests;

public class LoadTests
{
    public static async Task RunConcurrentProductCreation()
    {
        Console.WriteLine("Running concurrent product creation test...");

        var mockRepository = new Mock<IProductRepository>();
        var productService = new ProductService(mockRepository.Object, NullLogger<ProductService>.Instance);

        // Setup mock to simulate database operations
        mockRepository.Setup(r => r.AddAsync(It.IsAny<Product>()))
                      .Returns<Product>(async product =>
                      {
                          await Task.Delay(10); // Simulate database latency
                          product.Id = Random.Shared.Next(1, 10000);
                          return product;
                      });

        var stopwatch = Stopwatch.StartNew();
        var tasks = new List<Task>();

        // Create 100 concurrent product creation tasks
        for (int i = 0; i < 100; i++)
        {
            var product = new Product
            {
                Name = $"Load Test Product {i}",
                Price = Random.Shared.Next(10, 1000),
                StockQuantity = Random.Shared.Next(1, 100)
            };

            tasks.Add(productService.CreateProductAsync(product));
        }

        await Task.WhenAll(tasks);
        stopwatch.Stop();

        Console.WriteLine($"Created 100 products concurrently in {stopwatch.ElapsedMilliseconds}ms");
        Console.WriteLine($"Average time per product: {stopwatch.ElapsedMilliseconds / 100.0:F2}ms");
    }

    public static async Task RunMemoryUsageTest()
    {
        Console.WriteLine("Running memory usage test...");

        var initialMemory = GC.GetTotalMemory(true);

        var products = new List<Product>();

        // Create many products to test memory usage
        for (int i = 0; i < 10000; i++)
        {
            products.Add(new Product
            {
                Id = i,
                Name = $"Memory Test Product {i}",
                Description = $"This is a test product for memory usage testing. Product number {i}.",
                Price = Random.Shared.Next(10, 1000),
                StockQuantity = Random.Shared.Next(1, 100)
            });
        }

        var memoryAfterCreation = GC.GetTotalMemory(false);
        var memoryUsed = memoryAfterCreation - initialMemory;

        Console.WriteLine($"Memory used for 10,000 products: {memoryUsed / 1024.0 / 1024.0:F2} MB");
        Console.WriteLine($"Average memory per product: {memoryUsed / 10000.0:F0} bytes");

        // Clear references and force garbage collection
        products.Clear();
        GC.Collect();
        GC.WaitForPendingFinalizers();
        GC.Collect();

        var memoryAfterCleanup = GC.GetTotalMemory(true);
        Console.WriteLine($"Memory after cleanup: {(memoryAfterCleanup - initialMemory) / 1024.0 / 1024.0:F2} MB");
    }
}
'@

        Write-Host "[OK] Exercise 4 template created successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "[NEXT] Next steps:" -ForegroundColor Yellow
        Write-Host "1. Build the solution: dotnet build" -ForegroundColor Cyan
        Write-Host "2. Run benchmarks: dotnet run --project $ProjectName.PerformanceTests -c Release" -ForegroundColor Cyan
        Write-Host "3. Analyze performance results" -ForegroundColor Cyan
        Write-Host "4. Experiment with different scenarios" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "[TIP] Performance testing files created:" -ForegroundColor Blue
        Write-Host "  - ProductServiceBenchmarks.cs (BenchmarkDotNet tests)" -ForegroundColor White
        Write-Host "  - LoadTests.cs (concurrent and memory tests)" -ForegroundColor White
        Write-Host "  - Program.cs (benchmark runner)" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "[COMPLETE] Module 7 Exercise setup complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "[NEXT] Next Steps:" -ForegroundColor Yellow
Write-Host "1. Review the created files and understand their purpose" -ForegroundColor White
Write-Host "2. Build and run tests to verify everything works" -ForegroundColor White
Write-Host "3. Practice with the testing patterns and techniques" -ForegroundColor White
Write-Host "4. Use the SourceCode version for complete implementations" -ForegroundColor White
Write-Host ""
Write-Host "[TIP] Happy testing! 🧪" -ForegroundColor Cyan
