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
    # Exercise 2: Integration Testing with WebApplicationFactory

    explain_concept "Integration Testing" \
"Integration Testing with ASP.NET Core:
• WebApplicationFactory: Creates test server for full HTTP testing
• TestServer: In-memory server for testing complete request pipeline
• Database Testing: Using InMemory or SQLite for isolated tests
• Authentication Testing: Testing secured endpoints
• End-to-End Scenarios: Testing complete user workflows"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${RED}❌ Exercise 2 requires Exercise 1 to be completed first!${NC}"
        echo -e "${YELLOW}Please run: ./launch-exercises.sh exercise01${NC}"
        exit 1
    fi

    # Create Integration Test Project
    echo -e "${CYAN}Creating integration test project...${NC}"
    dotnet new xunit -n "$PROJECT_NAME.IntegrationTests" --framework net8.0
    cd "$PROJECT_NAME.IntegrationTests"

    # Add required packages for integration testing
    dotnet add package Microsoft.AspNetCore.Mvc.Testing
    dotnet add package Microsoft.EntityFrameworkCore.InMemory
    dotnet add package Microsoft.Extensions.DependencyInjection
    dotnet add package Bogus
    dotnet add package FluentAssertions

    # Add reference to main project
    dotnet add reference "../$PROJECT_NAME/$PROJECT_NAME.csproj"

    # Create Custom WebApplicationFactory
    create_file_interactive "TestWebApplicationFactory.cs" \
'using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using ProductCatalog.Data;

namespace ProductCatalog.IntegrationTests;

/// <summary>
/// Custom WebApplicationFactory for integration testing
/// Configures test-specific services and in-memory database
/// </summary>
public class TestWebApplicationFactory<TStartup> : WebApplicationFactory<TStartup> where TStartup : class
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // Remove the real database context
            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<ProductContext>));
            if (descriptor != null)
            {
                services.Remove(descriptor);
            }

            // Add in-memory database for testing
            services.AddDbContext<ProductContext>(options =>
            {
                options.UseInMemoryDatabase("TestDatabase");
                options.EnableSensitiveDataLogging();
            });

            // Build service provider and seed test data
            var serviceProvider = services.BuildServiceProvider();
            using var scope = serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ProductContext>();

            try
            {
                SeedTestData(context);
            }
            catch (Exception ex)
            {
                var logger = scope.ServiceProvider.GetRequiredService<ILogger<TestWebApplicationFactory<TStartup>>>();
                logger.LogError(ex, "An error occurred seeding test data");
            }
        });

        builder.UseEnvironment("Testing");
    }

    private static void SeedTestData(ProductContext context)
    {
        context.Database.EnsureCreated();

        if (!context.Products.Any())
        {
            context.Products.AddRange(
                new Product { Id = 1, Name = "Test Product 1", Price = 10.99m, Description = "Test Description 1" },
                new Product { Id = 2, Name = "Test Product 2", Price = 20.99m, Description = "Test Description 2" },
                new Product { Id = 3, Name = "Test Product 3", Price = 30.99m, Description = "Test Description 3" }
            );
            context.SaveChanges();
        }
    }
}' \
"Custom WebApplicationFactory for integration testing with in-memory database"

    # Create Integration Tests for Products API
    create_file_interactive "ProductsControllerIntegrationTests.cs" \
'using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using FluentAssertions;
using Microsoft.Extensions.DependencyInjection;
using ProductCatalog.Data;
using ProductCatalog.Models;
using Xunit;

namespace ProductCatalog.IntegrationTests;

/// <summary>
/// Integration tests for ProductsController
/// Tests complete HTTP request/response cycle
/// </summary>
public class ProductsControllerIntegrationTests : IClassFixture<TestWebApplicationFactory<Program>>
{
    private readonly HttpClient _client;
    private readonly TestWebApplicationFactory<Program> _factory;

    public ProductsControllerIntegrationTests(TestWebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetProducts_ReturnsSuccessAndCorrectContentType()
    {
        // Act
        var response = await _client.GetAsync("/api/products");

        // Assert
        response.EnsureSuccessStatusCode();
        response.Content.Headers.ContentType?.ToString()
            .Should().Contain("application/json");
    }

    [Fact]
    public async Task GetProducts_ReturnsExpectedProducts()
    {
        // Act
        var response = await _client.GetAsync("/api/products");
        var products = await response.Content.ReadFromJsonAsync<List<Product>>();

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        products.Should().NotBeNull();
        products.Should().HaveCount(3);
        products.Should().Contain(p => p.Name == "Test Product 1");
    }

    [Fact]
    public async Task GetProduct_WithValidId_ReturnsProduct()
    {
        // Arrange
        const int productId = 1;

        // Act
        var response = await _client.GetAsync($"/api/products/{productId}");
        var product = await response.Content.ReadFromJsonAsync<Product>();

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        product.Should().NotBeNull();
        product!.Id.Should().Be(productId);
        product.Name.Should().Be("Test Product 1");
    }

    [Fact]
    public async Task GetProduct_WithInvalidId_ReturnsNotFound()
    {
        // Arrange
        const int invalidId = 999;

        // Act
        var response = await _client.GetAsync($"/api/products/{invalidId}");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task PostProduct_WithValidProduct_ReturnsCreated()
    {
        // Arrange
        var newProduct = new Product
        {
            Name = "New Test Product",
            Price = 15.99m,
            Description = "New test description"
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/products", newProduct);
        var createdProduct = await response.Content.ReadFromJsonAsync<Product>();

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        createdProduct.Should().NotBeNull();
        createdProduct!.Name.Should().Be(newProduct.Name);
        createdProduct.Price.Should().Be(newProduct.Price);

        // Verify location header
        response.Headers.Location.Should().NotBeNull();
        response.Headers.Location!.ToString().Should().Contain($"/api/products/{createdProduct.Id}");
    }

    [Fact]
    public async Task PostProduct_WithInvalidProduct_ReturnsBadRequest()
    {
        // Arrange - Product with missing required fields
        var invalidProduct = new Product
        {
            Name = "", // Invalid: empty name
            Price = -1  // Invalid: negative price
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/products", invalidProduct);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task PutProduct_WithValidProduct_ReturnsNoContent()
    {
        // Arrange
        const int productId = 1;
        var updatedProduct = new Product
        {
            Id = productId,
            Name = "Updated Product Name",
            Price = 25.99m,
            Description = "Updated description"
        };

        // Act
        var response = await _client.PutAsJsonAsync($"/api/products/{productId}", updatedProduct);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NoContent);

        // Verify the update
        var getResponse = await _client.GetAsync($"/api/products/{productId}");
        var product = await getResponse.Content.ReadFromJsonAsync<Product>();
        product!.Name.Should().Be("Updated Product Name");
        product.Price.Should().Be(25.99m);
    }

    [Fact]
    public async Task DeleteProduct_WithValidId_ReturnsNoContent()
    {
        // Arrange
        const int productId = 2;

        // Act
        var response = await _client.DeleteAsync($"/api/products/{productId}");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NoContent);

        // Verify deletion
        var getResponse = await _client.GetAsync($"/api/products/{productId}");
        getResponse.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task GetProducts_AfterMultipleOperations_MaintainsDataConsistency()
    {
        // Arrange - Create a new product
        var newProduct = new Product
        {
            Name = "Consistency Test Product",
            Price = 99.99m,
            Description = "Testing data consistency"
        };

        // Act & Assert - Create
        var createResponse = await _client.PostAsJsonAsync("/api/products", newProduct);
        createResponse.StatusCode.Should().Be(HttpStatusCode.Created);
        var createdProduct = await createResponse.Content.ReadFromJsonAsync<Product>();

        // Act & Assert - Read
        var getResponse = await _client.GetAsync($"/api/products/{createdProduct!.Id}");
        getResponse.StatusCode.Should().Be(HttpStatusCode.OK);

        // Act & Assert - Update
        createdProduct.Name = "Updated Consistency Test";
        var updateResponse = await _client.PutAsJsonAsync($"/api/products/{createdProduct.Id}", createdProduct);
        updateResponse.StatusCode.Should().Be(HttpStatusCode.NoContent);

        // Act & Assert - Verify update
        var verifyResponse = await _client.GetAsync($"/api/products/{createdProduct.Id}");
        var verifiedProduct = await verifyResponse.Content.ReadFromJsonAsync<Product>();
        verifiedProduct!.Name.Should().Be("Updated Consistency Test");

        // Act & Assert - Delete
        var deleteResponse = await _client.DeleteAsync($"/api/products/{createdProduct.Id}");
        deleteResponse.StatusCode.Should().Be(HttpStatusCode.NoContent);

        // Act & Assert - Verify deletion
        var finalGetResponse = await _client.GetAsync($"/api/products/{createdProduct.Id}");
        finalGetResponse.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }
}' \
"Complete integration tests for Products API with CRUD operations"

    # Create Database Integration Tests
    create_file_interactive "DatabaseIntegrationTests.cs" \
'using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using ProductCatalog.Data;
using ProductCatalog.Models;
using Xunit;

namespace ProductCatalog.IntegrationTests;

/// <summary>
/// Integration tests for database operations
/// Tests Entity Framework context and repository patterns
/// </summary>
public class DatabaseIntegrationTests : IClassFixture<TestWebApplicationFactory<Program>>
{
    private readonly TestWebApplicationFactory<Program> _factory;

    public DatabaseIntegrationTests(TestWebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task ProductContext_CanAddAndRetrieveProducts()
    {
        // Arrange
        using var scope = _factory.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ProductContext>();

        var product = new Product
        {
            Name = "Database Test Product",
            Price = 19.99m,
            Description = "Testing database operations"
        };

        // Act
        context.Products.Add(product);
        await context.SaveChangesAsync();

        // Assert
        var retrievedProduct = await context.Products
            .FirstOrDefaultAsync(p => p.Name == "Database Test Product");

        retrievedProduct.Should().NotBeNull();
        retrievedProduct!.Price.Should().Be(19.99m);
        retrievedProduct.Description.Should().Be("Testing database operations");
    }

    [Fact]
    public async Task ProductContext_CanUpdateProducts()
    {
        // Arrange
        using var scope = _factory.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ProductContext>();

        var product = await context.Products.FirstAsync();
        var originalName = product.Name;

        // Act
        product.Name = "Updated Name";
        await context.SaveChangesAsync();

        // Assert
        var updatedProduct = await context.Products.FindAsync(product.Id);
        updatedProduct!.Name.Should().Be("Updated Name");
        updatedProduct.Name.Should().NotBe(originalName);
    }

    [Fact]
    public async Task ProductContext_CanDeleteProducts()
    {
        // Arrange
        using var scope = _factory.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ProductContext>();

        var product = new Product
        {
            Name = "Product To Delete",
            Price = 5.99m,
            Description = "This will be deleted"
        };

        context.Products.Add(product);
        await context.SaveChangesAsync();
        var productId = product.Id;

        // Act
        context.Products.Remove(product);
        await context.SaveChangesAsync();

        // Assert
        var deletedProduct = await context.Products.FindAsync(productId);
        deletedProduct.Should().BeNull();
    }
}' \
"Database integration tests for Entity Framework operations"

    # Create Exercise Guide for Exercise 2
    create_file_interactive "EXERCISE_02_GUIDE.md" \
'# Exercise 2: Integration Testing with WebApplicationFactory

## 🎯 Objective
Master integration testing techniques using WebApplicationFactory to test complete HTTP request/response cycles and database operations.

## ⏱️ Time Allocation
**Total Time**: 45 minutes
- WebApplicationFactory Setup: 15 minutes
- API Integration Tests: 20 minutes
- Database Integration Tests: 10 minutes

## 🚀 Getting Started

### Step 1: Run Integration Tests
```bash
cd ProductCatalog.IntegrationTests
dotnet test --verbosity normal
```

### Step 2: Understanding WebApplicationFactory
The TestWebApplicationFactory configures:
- In-memory database for isolation
- Test-specific service configurations
- Seeded test data for consistent testing

### Step 3: Key Testing Patterns
```csharp
// Testing HTTP endpoints
var response = await _client.GetAsync("/api/products");
response.EnsureSuccessStatusCode();

// Testing JSON responses
var products = await response.Content.ReadFromJsonAsync<List<Product>>();
products.Should().HaveCount(3);

// Testing database operations
using var scope = _factory.Services.CreateScope();
var context = scope.ServiceProvider.GetRequiredService<ProductContext>();
```

## ✅ Success Criteria
- [ ] All integration tests pass successfully
- [ ] HTTP endpoints are tested for all CRUD operations
- [ ] Database operations are tested in isolation
- [ ] Test data is properly seeded and isolated
- [ ] Error scenarios are covered (404, 400, etc.)

## 🧪 Testing Your Implementation
1. Run: `dotnet test`
2. Verify all tests pass
3. Check test coverage includes happy path and error scenarios
4. Ensure tests are isolated and repeatable

## 🎯 Learning Outcomes
After completing this exercise, you should understand:
- WebApplicationFactory configuration and usage
- Integration testing vs unit testing trade-offs
- In-memory database testing strategies
- HTTP client testing patterns
- Test isolation and data management
' \
"Complete exercise guide for Integration Testing"

    echo -e "${GREEN}🎉 Exercise 2 template created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Run integration tests: ${CYAN}cd $PROJECT_NAME.IntegrationTests && dotnet test${NC}"
    echo "2. Examine test output and coverage"
    echo "3. Follow the EXERCISE_02_GUIDE.md for implementation steps"
    echo "4. Experiment with different test scenarios"

elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    # Exercise 3: Mocking External Services

    explain_concept "Mocking and Test Doubles" \
"Mocking External Dependencies:
• Test Doubles: Mock, Stub, Fake, Spy patterns
• Moq Framework: Creating and configuring mocks
• Dependency Isolation: Testing units in isolation
• Behavior Verification: Verifying method calls and interactions
• External Service Mocking: HTTP clients, databases, file systems"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${RED}❌ Exercise 3 requires Exercises 1 and 2 to be completed first!${NC}"
        echo -e "${YELLOW}Please run exercises in order: exercise01, exercise02, exercise03${NC}"
        exit 1
    fi

    # Navigate to unit tests project to add mocking examples
    cd "$PROJECT_NAME.UnitTests"

    # Add Moq package if not already added
    dotnet add package Moq
    dotnet add package NSubstitute
    dotnet add package Microsoft.Extensions.Logging.Abstractions

    # Create External Service Interface for mocking
    create_file_interactive "Services/IExternalApiService.cs" \
'namespace ProductCatalog.Services;

/// <summary>
/// Interface for external API service - designed for mocking
/// </summary>
public interface IExternalApiService
{
    Task<decimal> GetCurrentExchangeRateAsync(string fromCurrency, string toCurrency);
    Task<bool> ValidateProductCodeAsync(string productCode);
    Task<string> GetProductCategoryAsync(string productName);
    Task SendNotificationAsync(string message, string recipient);
}

/// <summary>
/// External API service implementation
/// </summary>
public class ExternalApiService : IExternalApiService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<ExternalApiService> _logger;

    public ExternalApiService(HttpClient httpClient, ILogger<ExternalApiService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<decimal> GetCurrentExchangeRateAsync(string fromCurrency, string toCurrency)
    {
        // Simulate external API call
        _logger.LogInformation("Getting exchange rate from {From} to {To}", fromCurrency, toCurrency);
        await Task.Delay(100); // Simulate network delay
        return 1.25m; // Mock exchange rate
    }

    public async Task<bool> ValidateProductCodeAsync(string productCode)
    {
        // Simulate external validation service
        _logger.LogInformation("Validating product code: {ProductCode}", productCode);
        await Task.Delay(50);
        return !string.IsNullOrEmpty(productCode) && productCode.Length >= 3;
    }

    public async Task<string> GetProductCategoryAsync(string productName)
    {
        // Simulate external categorization service
        _logger.LogInformation("Getting category for product: {ProductName}", productName);
        await Task.Delay(75);
        return productName.ToLower().Contains("test") ? "Test Category" : "General";
    }

    public async Task SendNotificationAsync(string message, string recipient)
    {
        // Simulate notification service
        _logger.LogInformation("Sending notification to {Recipient}: {Message}", recipient, message);
        await Task.Delay(25);
    }
}' \
"External service interface and implementation for mocking demonstrations"

    # Create Enhanced Product Service with External Dependencies
    create_file_interactive "Services/EnhancedProductService.cs" \
'using Microsoft.Extensions.Logging;
using ProductCatalog.Data;
using ProductCatalog.Models;

namespace ProductCatalog.Services;

/// <summary>
/// Enhanced product service with external dependencies for mocking examples
/// </summary>
public interface IEnhancedProductService
{
    Task<Product> CreateProductWithValidationAsync(Product product);
    Task<decimal> GetProductPriceInCurrencyAsync(int productId, string currency);
    Task<Product> UpdateProductCategoryAsync(int productId);
    Task NotifyProductCreatedAsync(Product product, string adminEmail);
}

public class EnhancedProductService : IEnhancedProductService
{
    private readonly IProductRepository _productRepository;
    private readonly IExternalApiService _externalApiService;
    private readonly ILogger<EnhancedProductService> _logger;

    public EnhancedProductService(
        IProductRepository productRepository,
        IExternalApiService externalApiService,
        ILogger<EnhancedProductService> logger)
    {
        _productRepository = productRepository;
        _externalApiService = externalApiService;
        _logger = logger;
    }

    public async Task<Product> CreateProductWithValidationAsync(Product product)
    {
        _logger.LogInformation("Creating product with validation: {ProductName}", product.Name);

        // Validate product code with external service
        var isValidCode = await _externalApiService.ValidateProductCodeAsync(product.Name);
        if (!isValidCode)
        {
            throw new ArgumentException("Invalid product code", nameof(product));
        }

        // Get category from external service
        var category = await _externalApiService.GetProductCategoryAsync(product.Name);
        product.Description = $"{product.Description} [Category: {category}]";

        // Save product
        var createdProduct = await _productRepository.AddAsync(product);

        _logger.LogInformation("Product created successfully: {ProductId}", createdProduct.Id);
        return createdProduct;
    }

    public async Task<decimal> GetProductPriceInCurrencyAsync(int productId, string currency)
    {
        _logger.LogInformation("Getting product price in currency: {Currency}", currency);

        var product = await _productRepository.GetByIdAsync(productId);
        if (product == null)
        {
            throw new ArgumentException("Product not found", nameof(productId));
        }

        if (currency.Equals("USD", StringComparison.OrdinalIgnoreCase))
        {
            return product.Price;
        }

        // Get exchange rate from external service
        var exchangeRate = await _externalApiService.GetCurrentExchangeRateAsync("USD", currency);
        return product.Price * exchangeRate;
    }

    public async Task<Product> UpdateProductCategoryAsync(int productId)
    {
        _logger.LogInformation("Updating product category: {ProductId}", productId);

        var product = await _productRepository.GetByIdAsync(productId);
        if (product == null)
        {
            throw new ArgumentException("Product not found", nameof(productId));
        }

        // Get updated category from external service
        var newCategory = await _externalApiService.GetProductCategoryAsync(product.Name);
        product.Description = $"{product.Description.Split('[')[0].Trim()} [Category: {newCategory}]";

        await _productRepository.UpdateAsync(product);
        return product;
    }

    public async Task NotifyProductCreatedAsync(Product product, string adminEmail)
    {
        _logger.LogInformation("Sending product creation notification");

        var message = $"New product created: {product.Name} (${product.Price})";
        await _externalApiService.SendNotificationAsync(message, adminEmail);
    }
}' \
"Enhanced product service with external dependencies for mocking examples"

    # Create Comprehensive Mocking Tests with Moq
    create_file_interactive "MockingTests/EnhancedProductServiceMoqTests.cs" \
'using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;
using ProductCatalog.Models;
using ProductCatalog.Services;
using Xunit;

namespace ProductCatalog.UnitTests.MockingTests;

/// <summary>
/// Comprehensive mocking tests using Moq framework
/// Demonstrates various mocking patterns and verification techniques
/// </summary>
public class EnhancedProductServiceMoqTests
{
    private readonly Mock<IProductRepository> _mockRepository;
    private readonly Mock<IExternalApiService> _mockExternalService;
    private readonly Mock<ILogger<EnhancedProductService>> _mockLogger;
    private readonly EnhancedProductService _service;

    public EnhancedProductServiceMoqTests()
    {
        _mockRepository = new Mock<IProductRepository>();
        _mockExternalService = new Mock<IExternalApiService>();
        _mockLogger = new Mock<ILogger<EnhancedProductService>>();

        _service = new EnhancedProductService(
            _mockRepository.Object,
            _mockExternalService.Object,
            _mockLogger.Object);
    }

    [Fact]
    public async Task CreateProductWithValidationAsync_WithValidProduct_ReturnsCreatedProduct()
    {
        // Arrange
        var product = new Product
        {
            Name = "TEST123",
            Price = 19.99m,
            Description = "Test product"
        };

        var expectedProduct = new Product
        {
            Id = 1,
            Name = "TEST123",
            Price = 19.99m,
            Description = "Test product [Category: Test Category]"
        };

        // Setup mocks
        _mockExternalService
            .Setup(x => x.ValidateProductCodeAsync("TEST123"))
            .ReturnsAsync(true);

        _mockExternalService
            .Setup(x => x.GetProductCategoryAsync("TEST123"))
            .ReturnsAsync("Test Category");

        _mockRepository
            .Setup(x => x.AddAsync(It.IsAny<Product>()))
            .ReturnsAsync(expectedProduct);

        // Act
        var result = await _service.CreateProductWithValidationAsync(product);

        // Assert
        result.Should().NotBeNull();
        result.Id.Should().Be(1);
        result.Description.Should().Contain("[Category: Test Category]");

        // Verify all external calls were made
        _mockExternalService.Verify(x => x.ValidateProductCodeAsync("TEST123"), Times.Once);
        _mockExternalService.Verify(x => x.GetProductCategoryAsync("TEST123"), Times.Once);
        _mockRepository.Verify(x => x.AddAsync(It.IsAny<Product>()), Times.Once);
    }

    [Fact]
    public async Task CreateProductWithValidationAsync_WithInvalidProduct_ThrowsException()
    {
        // Arrange
        var product = new Product
        {
            Name = "XX", // Invalid short name
            Price = 19.99m,
            Description = "Test product"
        };

        _mockExternalService
            .Setup(x => x.ValidateProductCodeAsync("XX"))
            .ReturnsAsync(false);

        // Act & Assert
        var exception = await Assert.ThrowsAsync<ArgumentException>(
            () => _service.CreateProductWithValidationAsync(product));

        exception.Message.Should().Contain("Invalid product code");

        // Verify validation was called but repository was not
        _mockExternalService.Verify(x => x.ValidateProductCodeAsync("XX"), Times.Once);
        _mockRepository.Verify(x => x.AddAsync(It.IsAny<Product>()), Times.Never);
    }

    [Fact]
    public async Task GetProductPriceInCurrencyAsync_WithUSD_ReturnsOriginalPrice()
    {
        // Arrange
        const int productId = 1;
        const string currency = "USD";
        var product = new Product { Id = 1, Price = 25.99m };

        _mockRepository
            .Setup(x => x.GetByIdAsync(productId))
            .ReturnsAsync(product);

        // Act
        var result = await _service.GetProductPriceInCurrencyAsync(productId, currency);

        // Assert
        result.Should().Be(25.99m);

        // Verify repository was called but external service was not (USD is base currency)
        _mockRepository.Verify(x => x.GetByIdAsync(productId), Times.Once);
        _mockExternalService.Verify(x => x.GetCurrentExchangeRateAsync(It.IsAny<string>(), It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public async Task GetProductPriceInCurrencyAsync_WithEUR_ReturnsConvertedPrice()
    {
        // Arrange
        const int productId = 1;
        const string currency = "EUR";
        var product = new Product { Id = 1, Price = 25.99m };
        const decimal exchangeRate = 0.85m;

        _mockRepository
            .Setup(x => x.GetByIdAsync(productId))
            .ReturnsAsync(product);

        _mockExternalService
            .Setup(x => x.GetCurrentExchangeRateAsync("USD", "EUR"))
            .ReturnsAsync(exchangeRate);

        // Act
        var result = await _service.GetProductPriceInCurrencyAsync(productId, currency);

        // Assert
        result.Should().Be(25.99m * 0.85m);

        // Verify both calls were made
        _mockRepository.Verify(x => x.GetByIdAsync(productId), Times.Once);
        _mockExternalService.Verify(x => x.GetCurrentExchangeRateAsync("USD", "EUR"), Times.Once);
    }

    [Fact]
    public async Task NotifyProductCreatedAsync_CallsExternalService()
    {
        // Arrange
        var product = new Product { Name = "Test Product", Price = 15.99m };
        const string adminEmail = "admin@test.com";

        _mockExternalService
            .Setup(x => x.SendNotificationAsync(It.IsAny<string>(), adminEmail))
            .Returns(Task.CompletedTask);

        // Act
        await _service.NotifyProductCreatedAsync(product, adminEmail);

        // Assert
        _mockExternalService.Verify(
            x => x.SendNotificationAsync(
                It.Is<string>(msg => msg.Contains("Test Product") && msg.Contains("$15.99")),
                adminEmail),
            Times.Once);
    }

    [Theory]
    [InlineData("")]
    [InlineData(null)]
    [InlineData("A")]
    [InlineData("AB")]
    public async Task CreateProductWithValidationAsync_WithInvalidCodes_ThrowsException(string invalidCode)
    {
        // Arrange
        var product = new Product
        {
            Name = invalidCode,
            Price = 19.99m,
            Description = "Test product"
        };

        _mockExternalService
            .Setup(x => x.ValidateProductCodeAsync(invalidCode))
            .ReturnsAsync(false);

        // Act & Assert
        await Assert.ThrowsAsync<ArgumentException>(
            () => _service.CreateProductWithValidationAsync(product));

        _mockExternalService.Verify(x => x.ValidateProductCodeAsync(invalidCode), Times.Once);
    }

    [Fact]
    public async Task GetProductPriceInCurrencyAsync_WithNonExistentProduct_ThrowsException()
    {
        // Arrange
        const int nonExistentId = 999;

        _mockRepository
            .Setup(x => x.GetByIdAsync(nonExistentId))
            .ReturnsAsync((Product?)null);

        // Act & Assert
        var exception = await Assert.ThrowsAsync<ArgumentException>(
            () => _service.GetProductPriceInCurrencyAsync(nonExistentId, "EUR"));

        exception.Message.Should().Contain("Product not found");
        _mockRepository.Verify(x => x.GetByIdAsync(nonExistentId), Times.Once);
    }
}' \
"Comprehensive Moq-based mocking tests with various patterns and verification"

    # Create NSubstitute Alternative Tests
    create_file_interactive "MockingTests/EnhancedProductServiceNSubstituteTests.cs" \
'using FluentAssertions;
using Microsoft.Extensions.Logging;
using NSubstitute;
using NSubstitute.ExceptionExtensions;
using ProductCatalog.Models;
using ProductCatalog.Services;
using Xunit;

namespace ProductCatalog.UnitTests.MockingTests;

/// <summary>
/// Alternative mocking tests using NSubstitute framework
/// Demonstrates different syntax and approach to mocking
/// </summary>
public class EnhancedProductServiceNSubstituteTests
{
    private readonly IProductRepository _mockRepository;
    private readonly IExternalApiService _mockExternalService;
    private readonly ILogger<EnhancedProductService> _mockLogger;
    private readonly EnhancedProductService _service;

    public EnhancedProductServiceNSubstituteTests()
    {
        _mockRepository = Substitute.For<IProductRepository>();
        _mockExternalService = Substitute.For<IExternalApiService>();
        _mockLogger = Substitute.For<ILogger<EnhancedProductService>>();

        _service = new EnhancedProductService(_mockRepository, _mockExternalService, _mockLogger);
    }

    [Fact]
    public async Task CreateProductWithValidationAsync_WithValidProduct_CallsAllDependencies()
    {
        // Arrange
        var product = new Product { Name = "VALID123", Price = 29.99m, Description = "Valid product" };
        var createdProduct = new Product { Id = 1, Name = "VALID123", Price = 29.99m };

        _mockExternalService.ValidateProductCodeAsync("VALID123").Returns(true);
        _mockExternalService.GetProductCategoryAsync("VALID123").Returns("Electronics");
        _mockRepository.AddAsync(Arg.Any<Product>()).Returns(createdProduct);

        // Act
        var result = await _service.CreateProductWithValidationAsync(product);

        // Assert
        result.Should().NotBeNull();

        // Verify calls with NSubstitute syntax
        await _mockExternalService.Received(1).ValidateProductCodeAsync("VALID123");
        await _mockExternalService.Received(1).GetProductCategoryAsync("VALID123");
        await _mockRepository.Received(1).AddAsync(Arg.Any<Product>());
    }

    [Fact]
    public async Task GetProductPriceInCurrencyAsync_ExternalServiceThrows_PropagatesException()
    {
        // Arrange
        const int productId = 1;
        var product = new Product { Id = 1, Price = 50.00m };

        _mockRepository.GetByIdAsync(productId).Returns(product);
        _mockExternalService.GetCurrentExchangeRateAsync("USD", "GBP")
            .ThrowsAsync(new HttpRequestException("External service unavailable"));

        // Act & Assert
        var exception = await Assert.ThrowsAsync<HttpRequestException>(
            () => _service.GetProductPriceInCurrencyAsync(productId, "GBP"));

        exception.Message.Should().Contain("External service unavailable");

        await _mockRepository.Received(1).GetByIdAsync(productId);
        await _mockExternalService.Received(1).GetCurrentExchangeRateAsync("USD", "GBP");
    }

    [Fact]
    public async Task UpdateProductCategoryAsync_UpdatesProductDescription()
    {
        // Arrange
        const int productId = 1;
        var product = new Product
        {
            Id = 1,
            Name = "Test Product",
            Description = "Original description [Category: Old]"
        };

        _mockRepository.GetByIdAsync(productId).Returns(product);
        _mockExternalService.GetProductCategoryAsync("Test Product").Returns("New Category");

        // Act
        var result = await _service.UpdateProductCategoryAsync(productId);

        // Assert
        result.Description.Should().Contain("[Category: New Category]");

        await _mockRepository.Received(1).GetByIdAsync(productId);
        await _mockRepository.Received(1).UpdateAsync(product);
        await _mockExternalService.Received(1).GetProductCategoryAsync("Test Product");
    }
}' \
"NSubstitute-based mocking tests showing alternative syntax"

    # Create Exercise Guide for Exercise 3
    create_file_interactive "EXERCISE_03_GUIDE.md" \
'# Exercise 3: Mocking External Services

## 🎯 Objective
Master mocking frameworks (Moq and NSubstitute) to isolate units under test and verify interactions with external dependencies.

## ⏱️ Time Allocation
**Total Time**: 40 minutes
- Mocking Concepts: 10 minutes
- Moq Framework Usage: 15 minutes
- NSubstitute Alternative: 10 minutes
- Advanced Mocking Patterns: 5 minutes

## 🚀 Getting Started

### Step 1: Understanding Test Doubles
- **Mock**: Verifies behavior (method calls, parameters)
- **Stub**: Provides predetermined responses
- **Fake**: Working implementation with shortcuts
- **Spy**: Records information about method calls

### Step 2: Moq Framework Patterns
```csharp
// Setup return values
_mockService.Setup(x => x.GetDataAsync(It.IsAny<int>())).ReturnsAsync("test");

// Setup exceptions
_mockService.Setup(x => x.ProcessAsync()).ThrowsAsync(new Exception("test"));

// Verify method calls
_mockService.Verify(x => x.GetDataAsync(123), Times.Once);

// Verify with argument matching
_mockService.Verify(x => x.SaveAsync(It.Is<Product>(p => p.Price > 0)), Times.Once);
```

### Step 3: NSubstitute Syntax
```csharp
// Setup return values
_mockService.GetDataAsync(Arg.Any<int>()).Returns("test");

// Setup exceptions
_mockService.ProcessAsync().ThrowsAsync(new Exception("test"));

// Verify calls
await _mockService.Received(1).GetDataAsync(123);
```

## ✅ Success Criteria
- [ ] All mocking tests pass successfully
- [ ] External dependencies are properly isolated
- [ ] Both Moq and NSubstitute patterns are demonstrated
- [ ] Method call verification is implemented
- [ ] Exception scenarios are tested with mocks

## 🧪 Testing Your Implementation
1. Run: `dotnet test --filter "MockingTests"`
2. Verify all mocking tests pass
3. Examine test output for verification details
4. Experiment with different mock setups

## 🎯 Learning Outcomes
After completing this exercise, you should understand:
- When and how to use mocking frameworks
- Difference between Moq and NSubstitute syntax
- Behavior verification vs state verification
- Testing exception scenarios with mocks
- Isolating external dependencies in unit tests
' \
"Complete exercise guide for Mocking External Services"

    echo -e "${GREEN}🎉 Exercise 3 template created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Run mocking tests: ${CYAN}dotnet test --filter MockingTests${NC}"
    echo "2. Compare Moq vs NSubstitute syntax"
    echo "3. Follow the EXERCISE_03_GUIDE.md for implementation steps"
    echo "4. Practice with different mocking scenarios"

elif [[ $EXERCISE_NAME == "exercise04" ]]; then
    # Exercise 4: Performance Testing with BenchmarkDotNet

    explain_concept "Performance Testing" \
"Performance Testing Strategies:
• BenchmarkDotNet: Accurate micro-benchmarking for .NET
• Load Testing: Testing application under expected load
• Stress Testing: Testing beyond normal capacity
• Memory Profiling: Detecting memory leaks and allocation patterns
• Performance Regression Testing: Ensuring optimizations don't regress"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${RED}❌ Exercise 4 requires Exercises 1, 2, and 3 to be completed first!${NC}"
        echo -e "${YELLOW}Please run exercises in order: exercise01, exercise02, exercise03, exercise04${NC}"
        exit 1
    fi

    # Create Performance Test Project
    echo -e "${CYAN}Creating performance test project...${NC}"
    dotnet new console -n "$PROJECT_NAME.PerformanceTests" --framework net8.0
    cd "$PROJECT_NAME.PerformanceTests"

    # Add BenchmarkDotNet and other performance testing packages
    dotnet add package BenchmarkDotNet
    dotnet add package Microsoft.AspNetCore.Mvc.Testing
    dotnet add package Microsoft.EntityFrameworkCore.InMemory
    dotnet add package NBomber

    # Add reference to main project
    dotnet add reference "../$PROJECT_NAME/$PROJECT_NAME.csproj"

    # Create BenchmarkDotNet Performance Tests
    create_file_interactive "ProductServiceBenchmarks.cs" \
'using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Running;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using ProductCatalog.Data;
using ProductCatalog.Models;
using ProductCatalog.Services;

namespace ProductCatalog.PerformanceTests;

/// <summary>
/// BenchmarkDotNet performance tests for ProductService
/// Measures execution time, memory allocation, and throughput
/// </summary>
[MemoryDiagnoser]
[SimpleJob]
[RankColumn]
public class ProductServiceBenchmarks
{
    private ProductContext _context = null!;
    private IProductService _productService = null!;
    private List<Product> _testProducts = null!;

    [GlobalSetup]
    public void Setup()
    {
        // Setup in-memory database
        var options = new DbContextOptionsBuilder<ProductContext>()
            .UseInMemoryDatabase($"BenchmarkDb_{Guid.NewGuid()}")
            .Options;

        _context = new ProductContext(options);

        // Setup service
        var serviceCollection = new ServiceCollection();
        serviceCollection.AddLogging();
        var serviceProvider = serviceCollection.BuildServiceProvider();
        var logger = serviceProvider.GetRequiredService<ILogger<ProductService>>();

        _productService = new ProductService(_context, logger);

        // Seed test data
        _testProducts = GenerateTestProducts(1000);
        _context.Products.AddRange(_testProducts);
        _context.SaveChanges();
    }

    [GlobalCleanup]
    public void Cleanup()
    {
        _context.Dispose();
    }

    [Benchmark]
    public async Task<List<Product>> GetAllProducts()
    {
        return await _productService.GetAllProductsAsync();
    }

    [Benchmark]
    [Arguments(1)]
    [Arguments(100)]
    [Arguments(500)]
    public async Task<Product?> GetProductById(int id)
    {
        return await _productService.GetProductByIdAsync(id);
    }

    [Benchmark]
    public async Task<Product> CreateProduct()
    {
        var product = new Product
        {
            Name = $"Benchmark Product {Guid.NewGuid()}",
            Price = 19.99m,
            Description = "Performance test product"
        };

        return await _productService.CreateProductAsync(product);
    }

    [Benchmark]
    [Arguments("Test")]
    [Arguments("Product")]
    [Arguments("Benchmark")]
    public async Task<List<Product>> SearchProducts(string searchTerm)
    {
        return await _productService.SearchProductsAsync(searchTerm);
    }

    [Benchmark]
    public async Task BulkCreateProducts()
    {
        var products = GenerateTestProducts(100);

        foreach (var product in products)
        {
            await _productService.CreateProductAsync(product);
        }
    }

    [Benchmark]
    public async Task BulkCreateProductsOptimized()
    {
        var products = GenerateTestProducts(100);

        _context.Products.AddRange(products);
        await _context.SaveChangesAsync();
    }

    private static List<Product> GenerateTestProducts(int count)
    {
        var products = new List<Product>();
        var random = new Random(42); // Fixed seed for consistent results

        for (int i = 0; i < count; i++)
        {
            products.Add(new Product
            {
                Name = $"Product {i}",
                Price = (decimal)(random.NextDouble() * 100),
                Description = $"Description for product {i}"
            });
        }

        return products;
    }
}' \
"BenchmarkDotNet performance tests for ProductService operations"

    # Create Load Testing with NBomber
    create_file_interactive "ApiLoadTests.cs" \
'using NBomber.CSharp;
using NBomber.Http.CSharp;
using System.Text.Json;
using ProductCatalog.Models;

namespace ProductCatalog.PerformanceTests;

/// <summary>
/// Load testing scenarios using NBomber
/// Tests API endpoints under various load conditions
/// </summary>
public class ApiLoadTests
{
    public static void RunLoadTests()
    {
        var httpClient = new HttpClient();
        httpClient.BaseAddress = new Uri("http://localhost:5000");

        // Scenario 1: Get all products
        var getAllProductsScenario = Scenario.Create("get_all_products", async context =>
        {
            var response = await httpClient.GetAsync("/api/products");

            return response.IsSuccessStatusCode ? Response.Ok() : Response.Fail();
        })
        .WithLoadSimulations(
            Simulation.InjectPerSec(rate: 10, during: TimeSpan.FromMinutes(1))
        );

        // Scenario 2: Get specific product
        var getProductScenario = Scenario.Create("get_product_by_id", async context =>
        {
            var productId = Random.Shared.Next(1, 100);
            var response = await httpClient.GetAsync($"/api/products/{productId}");

            return response.IsSuccessStatusCode ? Response.Ok() : Response.Fail();
        })
        .WithLoadSimulations(
            Simulation.InjectPerSec(rate: 20, during: TimeSpan.FromMinutes(1))
        );

        // Scenario 3: Create products
        var createProductScenario = Scenario.Create("create_product", async context =>
        {
            var product = new Product
            {
                Name = $"Load Test Product {context.ScenarioInfo.ThreadId}_{context.InvocationNumber}",
                Price = (decimal)(Random.Shared.NextDouble() * 100),
                Description = "Load test product"
            };

            var json = JsonSerializer.Serialize(product);
            var content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");

            var response = await httpClient.PostAsync("/api/products", content);

            return response.IsSuccessStatusCode ? Response.Ok() : Response.Fail();
        })
        .WithLoadSimulations(
            Simulation.InjectPerSec(rate: 5, during: TimeSpan.FromMinutes(1))
        );

        // Mixed workload scenario
        var mixedWorkloadScenario = Scenario.Create("mixed_workload", async context =>
        {
            var operation = Random.Shared.Next(1, 4);

            HttpResponseMessage response = operation switch
            {
                1 => await httpClient.GetAsync("/api/products"),
                2 => await httpClient.GetAsync($"/api/products/{Random.Shared.Next(1, 100)}"),
                3 => await CreateRandomProduct(httpClient, context),
                _ => await httpClient.GetAsync("/api/products")
            };

            return response.IsSuccessStatusCode ? Response.Ok() : Response.Fail();
        })
        .WithLoadSimulations(
            Simulation.InjectPerSec(rate: 15, during: TimeSpan.FromMinutes(2))
        );

        // Run the load test
        NBomberRunner
            .RegisterScenarios(getAllProductsScenario, getProductScenario, createProductScenario, mixedWorkloadScenario)
            .Run();
    }

    private static async Task<HttpResponseMessage> CreateRandomProduct(HttpClient httpClient, IScenarioContext context)
    {
        var product = new Product
        {
            Name = $"Mixed Load Product {context.ScenarioInfo.ThreadId}_{context.InvocationNumber}",
            Price = (decimal)(Random.Shared.NextDouble() * 50 + 10),
            Description = "Mixed workload test product"
        };

        var json = JsonSerializer.Serialize(product);
        var content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");

        return await httpClient.PostAsync("/api/products", content);
    }
}' \
"NBomber load testing scenarios for API endpoints"

    # Create Program.cs for running benchmarks
    create_file_interactive "Program.cs" \
'using BenchmarkDotNet.Running;
using ProductCatalog.PerformanceTests;

namespace ProductCatalog.PerformanceTests;

/// <summary>
/// Entry point for performance testing
/// Runs BenchmarkDotNet tests and load tests
/// </summary>
class Program
{
    static void Main(string[] args)
    {
        Console.WriteLine("ProductCatalog Performance Testing Suite");
        Console.WriteLine("========================================");
        Console.WriteLine();

        if (args.Length > 0 && args[0] == "benchmark")
        {
            Console.WriteLine("Running BenchmarkDotNet performance tests...");
            BenchmarkRunner.Run<ProductServiceBenchmarks>();
        }
        else if (args.Length > 0 && args[0] == "load")
        {
            Console.WriteLine("Running NBomber load tests...");
            Console.WriteLine("Make sure the API is running on http://localhost:5000");
            Console.WriteLine("Press any key to start load testing...");
            Console.ReadKey();

            ApiLoadTests.RunLoadTests();
        }
        else
        {
            Console.WriteLine("Usage:");
            Console.WriteLine("  dotnet run benchmark  - Run BenchmarkDotNet micro-benchmarks");
            Console.WriteLine("  dotnet run load       - Run NBomber load tests");
            Console.WriteLine();
            Console.WriteLine("For load tests, ensure the API is running:");
            Console.WriteLine("  cd ../ProductCatalog && dotnet run");
        }
    }
}' \
"Program entry point for running performance tests"

    # Create Memory Leak Detection Tests
    create_file_interactive "MemoryLeakTests.cs" \
'using System.Diagnostics;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using ProductCatalog.Data;
using ProductCatalog.Models;
using ProductCatalog.Services;
using Xunit;

namespace ProductCatalog.PerformanceTests;

/// <summary>
/// Memory leak detection tests
/// Monitors memory usage patterns and potential leaks
/// </summary>
public class MemoryLeakTests
{
    [Fact]
    public async Task ProductService_RepeatedOperations_DoesNotLeakMemory()
    {
        // Arrange
        const int iterations = 1000;
        var initialMemory = GC.GetTotalMemory(true);

        // Act - Perform many operations
        for (int i = 0; i < iterations; i++)
        {
            await PerformProductOperations();

            // Force garbage collection every 100 iterations
            if (i % 100 == 0)
            {
                GC.Collect();
                GC.WaitForPendingFinalizers();
                GC.Collect();
            }
        }

        // Final cleanup
        GC.Collect();
        GC.WaitForPendingFinalizers();
        GC.Collect();

        var finalMemory = GC.GetTotalMemory(false);
        var memoryIncrease = finalMemory - initialMemory;

        // Assert - Memory increase should be reasonable (less than 10MB)
        Assert.True(memoryIncrease < 10 * 1024 * 1024,
            $"Memory increased by {memoryIncrease / 1024 / 1024}MB, which may indicate a memory leak");
    }

    private async Task PerformProductOperations()
    {
        var options = new DbContextOptionsBuilder<ProductContext>()
            .UseInMemoryDatabase($"MemoryTest_{Guid.NewGuid()}")
            .Options;

        using var context = new ProductContext(options);

        var serviceCollection = new ServiceCollection();
        serviceCollection.AddLogging();
        var serviceProvider = serviceCollection.BuildServiceProvider();
        var logger = serviceProvider.GetRequiredService<ILogger<ProductService>>();

        var service = new ProductService(context, logger);

        // Create, read, update, delete operations
        var product = new Product
        {
            Name = $"Memory Test Product {Guid.NewGuid()}",
            Price = 15.99m,
            Description = "Memory leak test"
        };

        var created = await service.CreateProductAsync(product);
        var retrieved = await service.GetProductByIdAsync(created.Id);

        if (retrieved != null)
        {
            retrieved.Price = 20.99m;
            await service.UpdateProductAsync(retrieved);
            await service.DeleteProductAsync(retrieved.Id);
        }
    }

    [Fact]
    public void DbContext_ProperDisposal_ReleasesResources()
    {
        // Arrange
        var initialMemory = GC.GetTotalMemory(true);

        // Act - Create and dispose many contexts
        for (int i = 0; i < 100; i++)
        {
            using var context = CreateTestContext();
            context.Products.Add(new Product
            {
                Name = $"Test {i}",
                Price = 10.99m,
                Description = "Test"
            });
            context.SaveChanges();
        }

        GC.Collect();
        GC.WaitForPendingFinalizers();
        GC.Collect();

        var finalMemory = GC.GetTotalMemory(false);
        var memoryIncrease = finalMemory - initialMemory;

        // Assert - Memory should not increase significantly
        Assert.True(memoryIncrease < 5 * 1024 * 1024,
            $"DbContext disposal may not be working properly. Memory increased by {memoryIncrease / 1024 / 1024}MB");
    }

    private ProductContext CreateTestContext()
    {
        var options = new DbContextOptionsBuilder<ProductContext>()
            .UseInMemoryDatabase($"DisposalTest_{Guid.NewGuid()}")
            .Options;

        return new ProductContext(options);
    }
}' \
"Memory leak detection tests for monitoring resource usage"

    # Create Exercise Guide for Exercise 4
    create_file_interactive "EXERCISE_04_GUIDE.md" \
'# Exercise 4: Performance Testing with BenchmarkDotNet

## 🎯 Objective
Implement comprehensive performance testing using BenchmarkDotNet for micro-benchmarks and NBomber for load testing.

## ⏱️ Time Allocation
**Total Time**: 35 minutes
- BenchmarkDotNet Setup: 10 minutes
- Micro-benchmark Implementation: 15 minutes
- Load Testing: 10 minutes

## 🚀 Getting Started

### Step 1: Run Micro-benchmarks
```bash
cd ProductCatalog.PerformanceTests
dotnet run --configuration Release benchmark
```

### Step 2: Run Load Tests
```bash
# Terminal 1: Start the API
cd ../ProductCatalog
dotnet run

# Terminal 2: Run load tests
cd ../ProductCatalog.PerformanceTests
dotnet run load
```

### Step 3: Understanding BenchmarkDotNet Results
- **Mean**: Average execution time
- **Error**: Half of 99.9% confidence interval
- **StdDev**: Standard deviation of all measurements
- **Allocated**: Memory allocated per operation

### Step 4: Analyzing Performance
```csharp
[MemoryDiagnoser]  // Tracks memory allocations
[SimpleJob]        // Single job configuration
[RankColumn]       // Shows performance ranking
```

## ✅ Success Criteria
- [ ] BenchmarkDotNet tests run successfully
- [ ] Load tests complete without errors
- [ ] Memory leak tests pass
- [ ] Performance baselines are established
- [ ] Bottlenecks are identified and documented

## 🧪 Testing Your Implementation
1. Run benchmarks: `dotnet run --configuration Release benchmark`
2. Analyze performance results
3. Run load tests: `dotnet run load`
4. Check memory usage patterns
5. Document performance characteristics

## 🎯 Learning Outcomes
After completing this exercise, you should understand:
- How to use BenchmarkDotNet for accurate performance measurement
- Load testing strategies with NBomber
- Memory leak detection techniques
- Performance optimization identification
- Establishing performance baselines for regression testing
' \
"Complete exercise guide for Performance Testing"

    echo -e "${GREEN}🎉 Exercise 4 template created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Run benchmarks: ${CYAN}cd $PROJECT_NAME.PerformanceTests && dotnet run --configuration Release benchmark${NC}"
    echo "2. Start API and run load tests: ${CYAN}dotnet run load${NC}"
    echo "3. Follow the EXERCISE_04_GUIDE.md for implementation steps"
    echo "4. Analyze performance results and identify optimization opportunities"

fi

echo ""
echo -e "${GREEN}✅ Module 7 Exercise Setup Complete!${NC}"
echo -e "${CYAN}Happy testing! 🧪✨${NC}"
