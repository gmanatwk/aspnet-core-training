#!/bin/bash

# Module 7 Interactive Exercise Launcher
# Testing Applications

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Interactive mode flag
INTERACTIVE_MODE=true

# Function to pause and wait for user
pause_for_user() {
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -e "${YELLOW}Press Enter to continue...${NC}"
        read -r
    fi
}

# Function to show what will be created
preview_file() {
    local file_path=$1
    local description=$2
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📄 Will create: $file_path${NC}"
    echo -e "${YELLOW}📝 Purpose: $description${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to create file with preview
create_file_interactive() {
    local file_path=$1
    local content=$2
    local description=$3
    
    preview_file "$file_path" "$description"
    
    # Show first 20 lines of content
    echo -e "${GREEN}Content preview:${NC}"
    echo "$content" | head -20
    if [ $(echo "$content" | wc -l) -gt 20 ]; then
        echo -e "${YELLOW}... (content truncated for preview)${NC}"
    fi
    echo ""
    
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -e "${YELLOW}Create this file? (Y/n/s to skip all):${NC} \c"
        read -r response
        
        case $response in
            [nN])
                echo -e "${RED}⏭️  Skipped: $file_path${NC}"
                return
                ;;
            [sS])
                INTERACTIVE_MODE=false
                echo -e "${CYAN}📌 Switching to automatic mode...${NC}"
                ;;
        esac
    fi
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$file_path")"
    
    # Write content to file
    echo "$content" > "$file_path"
    echo -e "${GREEN}✅ Created: $file_path${NC}"
    echo ""
}

# Function to show learning objectives
show_learning_objectives() {
    local exercise=$1
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}🎯 Learning Objectives${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${CYAN}In this exercise, you will learn:${NC}"
            echo "  🧪 1. Setting up xUnit test projects with proper configuration"
            echo "  🧪 2. Writing effective unit tests using Arrange-Act-Assert pattern"
            echo "  🧪 3. Using Moq framework for mocking dependencies"
            echo "  🧪 4. Implementing test fixtures and data-driven tests"
            echo ""
            echo -e "${YELLOW}Key testing concepts:${NC}"
            echo "  • Test isolation and independence"
            echo "  • Mocking external dependencies"
            echo "  • Test naming conventions and organization"
            echo "  • FluentAssertions for readable test assertions"
            ;;
        "exercise02")
            echo -e "${CYAN}Building on Exercise 1, you will add:${NC}"
            echo "  🔗 1. Integration testing with WebApplicationFactory"
            echo "  🔗 2. Testing complete API workflows end-to-end"
            echo "  🔗 3. Database testing with in-memory providers"
            echo "  🔗 4. Authentication and authorization testing"
            echo ""
            echo -e "${YELLOW}Integration concepts:${NC}"
            echo "  • TestServer configuration and setup"
            echo "  • HTTP client testing patterns"
            echo "  • Database seeding for tests"
            echo "  • Testing middleware and filters"
            ;;
        "exercise03")
            echo -e "${CYAN}Advanced testing with external services:${NC}"
            echo "  🎭 1. Mocking external API calls and services"
            echo "  🎭 2. Testing with HttpClient and HttpMessageHandler mocks"
            echo "  🎭 3. Implementing test doubles for complex scenarios"
            echo "  🎭 4. Verifying method calls and behaviors"
            echo ""
            echo -e "${YELLOW}Mocking patterns:${NC}"
            echo "  • Service layer mocking strategies"
            echo "  • HTTP client mocking techniques"
            echo "  • Behavior verification vs state verification"
            echo "  • Test data builders and object mothers"
            ;;
        "exercise04")
            echo -e "${CYAN}Performance and load testing:${NC}"
            echo "  ⚡ 1. Benchmarking with BenchmarkDotNet"
            echo "  ⚡ 2. Load testing strategies and tools"
            echo "  ⚡ 3. Memory leak detection in tests"
            echo "  ⚡ 4. Performance regression testing"
            echo ""
            echo -e "${YELLOW}Performance concepts:${NC}"
            echo "  • Micro-benchmarking best practices"
            echo "  • Load testing patterns"
            echo "  • Performance monitoring in tests"
            echo "  • Continuous performance testing"
            ;;
    esac
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to show what will be created overview
show_creation_overview() {
    local exercise=$1
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📋 Overview: What will be created${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${GREEN}🎯 Exercise 01: Unit Testing Basics${NC}"
            echo ""
            echo -e "${YELLOW}📋 What you'll build:${NC}"
            echo "  ✅ Complete test project with xUnit framework"
            echo "  ✅ ProductService with comprehensive unit tests"
            echo "  ✅ Mocked dependencies using Moq framework"
            echo "  ✅ Test fixtures and data-driven test examples"
            echo ""
            echo -e "${BLUE}🚀 RECOMMENDED: Use the Complete Working Example${NC}"
            echo "  ${CYAN}cd SourceCode/ProductCatalog.UnitTests && dotnet test${NC}"
            echo "  Then explore: ${CYAN}ProductServiceTests.cs${NC} for complete examples"
            echo ""
            echo -e "${GREEN}📁 Template Structure:${NC}"
            echo "  TestingDemo/"
            echo "  ├── TestingDemo.API/            ${YELLOW}# Main API project${NC}"
            echo "  │   ├── Controllers/"
            echo "  │   ├── Services/"
            echo "  │   └── Models/"
            echo "  ├── TestingDemo.UnitTests/      ${YELLOW}# Unit test project${NC}"
            echo "  │   ├── Services/"
            echo "  │   │   └── ProductServiceTests.cs"
            echo "  │   ├── Fixtures/"
            echo "  │   └── TestData/"
            echo "  └── TestingDemo.sln             ${YELLOW}# Solution file${NC}"
            ;;
            
        "exercise02")
            echo -e "${GREEN}🎯 Exercise 02: Integration Testing${NC}"
            echo ""
            echo -e "${YELLOW}📋 Building on Exercise 1:${NC}"
            echo "  ✅ WebApplicationFactory for integration tests"
            echo "  ✅ Complete API endpoint testing"
            echo "  ✅ Database integration with in-memory provider"
            echo "  ✅ Authentication testing scenarios"
            echo ""
            echo -e "${GREEN}📁 New additions:${NC}"
            echo "  TestingDemo/"
            echo "  ├── TestingDemo.IntegrationTests/ ${YELLOW}# Integration test project${NC}"
            echo "  │   ├── Controllers/"
            echo "  │   │   └── ProductsControllerTests.cs"
            echo "  │   ├── Fixtures/"
            echo "  │   │   └── WebApplicationTestFixture.cs"
            echo "  │   └── Helpers/"
            echo "  │       └── TestDataSeeder.cs"
            echo "  └── TestingDemo.API/ (enhanced)   ${YELLOW}# Updated for testing${NC}"
            ;;
            
        "exercise03")
            echo -e "${GREEN}🎯 Exercise 03: Mocking External Services${NC}"
            echo ""
            echo -e "${YELLOW}📋 Advanced mocking scenarios:${NC}"
            echo "  ✅ HttpClient mocking for external API calls"
            echo "  ✅ Service layer mocking with complex behaviors"
            echo "  ✅ Test doubles for various scenarios"
            echo "  ✅ Behavior verification and call tracking"
            echo ""
            echo -e "${GREEN}📁 Mocking structure:${NC}"
            echo "  TestingDemo/"
            echo "  ├── TestingDemo.API/"
            echo "  │   ├── Services/"
            echo "  │   │   ├── ExternalApiService.cs ${YELLOW}# Service to mock${NC}"
            echo "  │   │   └── NotificationService.cs"
            echo "  │   └── HttpClients/"
            echo "  │       └── PaymentApiClient.cs"
            echo "  └── TestingDemo.UnitTests/"
            echo "      ├── Mocks/"
            echo "      │   └── MockHttpMessageHandler.cs"
            echo "      └── Services/"
            echo "          └── ExternalServiceTests.cs"
            ;;
            
        "exercise04")
            echo -e "${GREEN}🎯 Exercise 04: Performance Testing${NC}"
            echo ""
            echo -e "${YELLOW}📋 Performance testing tools:${NC}"
            echo "  ✅ BenchmarkDotNet for micro-benchmarking"
            echo "  ✅ Load testing with custom test harness"
            echo "  ✅ Memory profiling and leak detection"
            echo "  ✅ Performance regression testing"
            echo ""
            echo -e "${GREEN}📁 Performance structure:${NC}"
            echo "  TestingDemo/"
            echo "  ├── TestingDemo.PerformanceTests/ ${YELLOW}# Performance test project${NC}"
            echo "  │   ├── Benchmarks/"
            echo "  │   │   ├── ProductServiceBenchmarks.cs"
            echo "  │   │   └── DatabaseBenchmarks.cs"
            echo "  │   ├── LoadTests/"
            echo "  │   │   └── ApiLoadTests.cs"
            echo "  │   └── MemoryTests/"
            echo "  │       └── MemoryLeakTests.cs"
            echo "  └── BenchmarkDotNet.Artifacts/    ${YELLOW}# Generated reports${NC}"
            ;;
    esac
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to explain a concept
explain_concept() {
    local concept=$1
    local explanation=$2
    
    echo -e "${MAGENTA}💡 Concept: $concept${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "$explanation"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to show available exercises
show_exercises() {
    echo -e "${CYAN}Module 7 - Testing Applications${NC}"
    echo -e "${CYAN}Available Exercises:${NC}"
    echo ""
    echo "  - exercise01: Unit Testing Basics"
    echo "  - exercise02: Integration Testing"
    echo "  - exercise03: Mocking External Services"
    echo "  - exercise04: Performance Testing"
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
    echo -e "${RED}❌ Usage: $0 <exercise-name> [options]${NC}"
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
PROJECT_NAME="TestingDemo"
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
        echo -e "${RED}❌ Unknown exercise: $EXERCISE_NAME${NC}"
        echo ""
        show_exercises
        exit 1
        ;;
esac

# Welcome screen
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}🚀 Module 7: Testing Applications${NC}"
echo -e "${MAGENTA}Exercise: $EXERCISE_NAME${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show the recommended approach
echo -e "${GREEN}🎯 RECOMMENDED APPROACH:${NC}"
echo -e "${CYAN}For the best learning experience, use the complete working implementation:${NC}"
echo ""
echo -e "${YELLOW}1. Use the working source code:${NC}"
echo -e "   ${CYAN}cd SourceCode/ProductCatalog.UnitTests${NC}"
echo -e "   ${CYAN}dotnet test${NC}"
echo -e "   ${CYAN}# Explore comprehensive test examples${NC}"
echo ""
echo -e "${YELLOW}2. Or run all test projects:${NC}"
echo -e "   ${CYAN}cd SourceCode${NC}"
echo -e "   ${CYAN}dotnet test --logger trx --results-directory TestResults${NC}"
echo -e "   ${CYAN}# Includes unit, integration, and performance tests${NC}"
echo ""
echo -e "${YELLOW}⚠️  The template created by this script is basic and may not match${NC}"
echo -e "${YELLOW}   all exercise requirements. The SourceCode version is complete!${NC}"
echo ""

if [ "$INTERACTIVE_MODE" = true ]; then
    echo -e "${YELLOW}🎮 Interactive Mode: ON${NC}"
    echo -e "${CYAN}You'll see what each file does before it's created${NC}"
else
    echo -e "${YELLOW}⚡ Automatic Mode: ON${NC}"
fi

echo ""
echo -n "Continue with template creation? (y/N): "
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}💡 Great choice! Use the SourceCode version for the best experience.${NC}"
    exit 0
fi

# Show learning objectives
show_learning_objectives $EXERCISE_NAME

# Show creation overview
show_creation_overview $EXERCISE_NAME

if [ "$PREVIEW_ONLY" = true ]; then
    echo -e "${YELLOW}Preview mode - no files will be created${NC}"
    exit 0
fi

# Check if project exists in current directory
if [ -d "$PROJECT_NAME" ]; then
    if [[ $EXERCISE_NAME == "exercise02" ]] || [[ $EXERCISE_NAME == "exercise03" ]] || [[ $EXERCISE_NAME == "exercise04" ]]; then
        echo -e "${GREEN}✓ Found existing $PROJECT_NAME from previous exercise${NC}"
        echo -e "${CYAN}This exercise will build on your existing work${NC}"
        cd "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=true
    else
        echo -e "${YELLOW}⚠️  Project '$PROJECT_NAME' already exists!${NC}"
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

# Exercise-specific implementation
if [[ $EXERCISE_NAME == "exercise01" ]]; then
    # Exercise 1: Unit Testing Basics

    explain_concept "Unit Testing Fundamentals" \
"Unit testing is the foundation of a robust testing strategy:
• Test individual components in isolation
• Use mocks to isolate dependencies
• Follow Arrange-Act-Assert pattern
• Write tests that are fast, reliable, and maintainable
• Use descriptive test names that explain the scenario"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${CYAN}Creating solution and projects for testing...${NC}"

        # Create solution
        dotnet new sln -n "$PROJECT_NAME"

        # Create API project
        dotnet new webapi -n "$PROJECT_NAME.API" --framework net8.0
        cd "$PROJECT_NAME.API"
        rm -f WeatherForecast.cs Controllers/WeatherForecastController.cs
        cd ..

        # Create Unit Test project
        dotnet new xunit -n "$PROJECT_NAME.UnitTests" --framework net8.0

        # Add projects to solution
        dotnet sln add "$PROJECT_NAME.API"
        dotnet sln add "$PROJECT_NAME.UnitTests"

        # Add project reference
        cd "$PROJECT_NAME.UnitTests"
        dotnet add reference "../$PROJECT_NAME.API"

        # Install testing packages
        echo -e "${CYAN}Installing testing packages...${NC}"
        dotnet add package Moq
        dotnet add package FluentAssertions
        dotnet add package Microsoft.Extensions.Logging.Abstractions

        cd ..
        cd "$PROJECT_NAME.API"

        # Install API packages
        dotnet add package Microsoft.EntityFrameworkCore.InMemory

        cd ..
    fi

    explain_concept "Test-Driven Development Models" \
"Creating models and services that are testable:
• Simple POCOs for easy testing
• Interfaces for dependency injection
• Clear separation of concerns
• Minimal external dependencies"

    # Create Product model
    create_file_interactive "$PROJECT_NAME.API/Models/Product.cs" \
'using System.ComponentModel.DataAnnotations;

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
}' \
"Product model with validation attributes for testing"

    # Create custom exceptions
    create_file_interactive "$PROJECT_NAME.API/Models/Exceptions.cs" \
'namespace TestingDemo.API.Models;

public class NotFoundException : Exception
{
    public NotFoundException(string message) : base(message) { }
}

public class ValidationException : Exception
{
    public ValidationException(string message) : base(message) { }
}' \
"Custom exceptions for testing error scenarios"

    # Create repository interface
    create_file_interactive "$PROJECT_NAME.API/Repositories/IProductRepository.cs" \
'using TestingDemo.API.Models;

namespace TestingDemo.API.Repositories;

public interface IProductRepository
{
    Task<Product?> GetByIdAsync(int id);
    Task<List<Product>> GetAllAsync();
    Task<Product> AddAsync(Product product);
    Task UpdateAsync(Product product);
    Task DeleteAsync(int id);
}' \
"Repository interface for dependency injection and mocking"

    # Create ProductService
    create_file_interactive "$PROJECT_NAME.API/Services/ProductService.cs" \
'using Microsoft.Extensions.Logging;
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
}' \
"ProductService with business logic to be tested"

    explain_concept "Unit Test Structure" \
"Effective unit tests follow clear patterns:
• Arrange: Set up test data and mocks
• Act: Execute the method being tested
• Assert: Verify the expected outcome
• Use descriptive test names that explain the scenario
• Test one thing at a time"

    # Create unit tests
    create_file_interactive "$PROJECT_NAME.UnitTests/Services/ProductServiceTests.cs" \
'using FluentAssertions;
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
}' \
"Comprehensive unit tests with Arrange-Act-Assert pattern and mocking"

    # Create test data builders
    create_file_interactive "$PROJECT_NAME.UnitTests/TestData/ProductTestDataBuilder.cs" \
'using TestingDemo.API.Models;

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

    public ProductTestDataBuilder WithIsActive(bool isActive)
    {
        _product.IsActive = isActive;
        return this;
    }

    public Product Build() => _product;

    public static ProductTestDataBuilder AProduct() => new();
}' \
"Test data builder pattern for creating test objects"

    # Create exercise guide
    create_file_interactive "TESTING_GUIDE.md" \
'# Exercise 1: Unit Testing Basics

## 🎯 Objective
Master unit testing fundamentals with xUnit, Moq, and FluentAssertions.

## ⏱️ Time Allocation
**Total Time**: 35 minutes
- Project Setup: 5 minutes
- Writing Basic Tests: 15 minutes
- Advanced Testing Patterns: 15 minutes

## 🚀 Getting Started

### Step 1: Build and Test
```bash
dotnet build
dotnet test
```

### Step 2: Run Tests with Detailed Output
```bash
dotnet test --logger "console;verbosity=detailed"
```

### Step 3: Generate Test Coverage Report
```bash
dotnet test --collect:"XPlat Code Coverage"
```

## 🧪 Testing Exercises

### Exercise A: Complete Missing Tests
1. Implement tests for `UpdateProductAsync` method
2. Add tests for `DeleteProductAsync` method
3. Create tests for `GetAllProductsAsync` method

### Exercise B: Test Data Builders
1. Use the `ProductTestDataBuilder` in your tests
2. Create more complex test scenarios
3. Practice the builder pattern for test data

### Exercise C: Mock Verification
1. Verify that repository methods are called correctly
2. Test that logging occurs at appropriate levels
3. Ensure proper exception handling

## 📝 Test Implementation Examples

### Complete UpdateProductAsync Test
```csharp
[Fact]
public async Task UpdateProductAsync_WithValidData_UpdatesProduct()
{
    // Arrange
    var productId = 1;
    var existingProduct = ProductTestDataBuilder.AProduct()
        .WithId(productId)
        .WithName("Old Name")
        .Build();

    var updatedProduct = ProductTestDataBuilder.AProduct()
        .WithName("New Name")
        .WithPrice(25.99m)
        .Build();

    _mockRepository.Setup(r => r.GetByIdAsync(productId))
                  .ReturnsAsync(existingProduct);

    // Act
    await _productService.UpdateProductAsync(productId, updatedProduct);

    // Assert
    _mockRepository.Verify(r => r.UpdateAsync(It.Is<Product>(p =>
        p.Name == "New Name" && p.Price == 25.99m)), Times.Once);
}
```

## ✅ Success Criteria
- [ ] All tests pass successfully
- [ ] Tests follow Arrange-Act-Assert pattern
- [ ] Mocks are properly configured and verified
- [ ] Edge cases and error scenarios are tested
- [ ] Test names clearly describe the scenario
- [ ] FluentAssertions are used for readable assertions

## 🔄 Next Steps
After mastering unit testing, move on to Exercise 2 for integration testing.
' \
"Comprehensive testing guide with practical exercises"

    echo -e "${GREEN}🎉 Exercise 1 template created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Build the solution: ${CYAN}dotnet build${NC}"
    echo "2. Run the tests: ${CYAN}dotnet test${NC}"
    echo "3. Explore the test structure in ${CYAN}$PROJECT_NAME.UnitTests${NC}"
    echo "4. Follow the TESTING_GUIDE.md for implementation exercises"

elif [[ $EXERCISE_NAME == "exercise02" ]]; then
    echo -e "${CYAN}Exercise 2 implementation would be added here...${NC}"
    echo -e "${YELLOW}This exercise adds integration testing with WebApplicationFactory${NC}"

elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    echo -e "${CYAN}Exercise 3 implementation would be added here...${NC}"
    echo -e "${YELLOW}This exercise implements mocking external services${NC}"

elif [[ $EXERCISE_NAME == "exercise04" ]]; then
    echo -e "${CYAN}Exercise 4 implementation would be added here...${NC}"
    echo -e "${YELLOW}This exercise adds performance testing with BenchmarkDotNet${NC}"

fi

echo ""
echo -e "${GREEN}✅ Module 7 Exercise Setup Complete!${NC}"
echo -e "${CYAN}Happy testing! 🧪✨${NC}"
