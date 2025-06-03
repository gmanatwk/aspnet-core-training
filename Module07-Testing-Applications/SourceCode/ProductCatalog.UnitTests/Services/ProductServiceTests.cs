using AutoFixture;
using Bogus;
using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Moq;
using ProductCatalog.API.Data;
using ProductCatalog.API.DTOs;
using ProductCatalog.API.Models;
using ProductCatalog.API.Services;
using Xunit;

namespace ProductCatalog.UnitTests.Services;

/// <summary>
/// Unit tests for ProductService class
/// Demonstrates comprehensive testing patterns including:
/// - Arrange-Act-Assert pattern
/// - Mocking dependencies
/// - Testing business logic
/// - Exception handling
/// - Edge cases
/// </summary>
public class ProductServiceTests : IDisposable
{
    private readonly ProductCatalogContext _context;
    private readonly Mock<ILogger<ProductService>> _mockLogger;
    private readonly ProductService _productService;
    private readonly Fixture _fixture;
    private readonly Faker<Product> _productFaker;
    private readonly Faker<Category> _categoryFaker;

    public ProductServiceTests()
    {
        // Setup InMemory database for testing
        var options = new DbContextOptionsBuilder<ProductCatalogContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new ProductCatalogContext(options);
        _mockLogger = new Mock<ILogger<ProductService>>();
        _productService = new ProductService(_context, _mockLogger.Object);
        
        // Setup AutoFixture for test data generation
        _fixture = new Fixture();
        _fixture.Behaviors.OfType<ThrowingRecursionBehavior>().ToList()
            .ForEach(b => _fixture.Behaviors.Remove(b));
        _fixture.Behaviors.Add(new OmitOnRecursionBehavior());

        // Setup Bogus fakers for realistic test data
        _categoryFaker = new Faker<Category>()
            .RuleFor(c => c.Id, f => f.Random.Int(1, 1000))
            .RuleFor(c => c.Name, f => f.Commerce.Categories(1).First())
            .RuleFor(c => c.Description, f => f.Lorem.Sentence())
            .RuleFor(c => c.IsActive, f => true)
            .RuleFor(c => c.CreatedAt, f => f.Date.Recent());

        _productFaker = new Faker<Product>()
            .RuleFor(p => p.Id, f => f.Random.Int(1, 1000))
            .RuleFor(p => p.Name, f => f.Commerce.Product())
            .RuleFor(p => p.Description, f => f.Lorem.Paragraph())
            .RuleFor(p => p.Price, f => f.Random.Decimal(1, 1000))
            .RuleFor(p => p.Stock, f => f.Random.Int(0, 100))
            .RuleFor(p => p.CategoryId, f => f.Random.Int(1, 10))
            .RuleFor(p => p.SKU, f => f.Commerce.Ean13())
            .RuleFor(p => p.Weight, f => f.Random.Decimal(0.1M, 10M))
            .RuleFor(p => p.IsActive, f => true)
            .RuleFor(p => p.CreatedAt, f => f.Date.Recent())
            .RuleFor(p => p.ImageUrl, f => f.Image.PicsumUrl());
    }

    [Fact]
    public async Task GetProductByIdAsync_ExistingProduct_ReturnsProductDto()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        var product = _productFaker.Generate();
        product.CategoryId = category.Id;
        product.Category = category;

        _context.Categories.Add(category);
        _context.Products.Add(product);
        await _context.SaveChangesAsync();

        // Act
        var result = await _productService.GetProductByIdAsync(product.Id);

        // Assert
        result.Should().NotBeNull();
        result!.Id.Should().Be(product.Id);
        result.Name.Should().Be(product.Name);
        result.Description.Should().Be(product.Description);
        result.Price.Should().Be(product.Price);
        result.Stock.Should().Be(product.Stock);
        result.CategoryName.Should().Be(category.Name);
    }

    [Fact]
    public async Task GetProductByIdAsync_NonExistentProduct_ReturnsNull()
    {
        // Arrange
        var nonExistentId = 999;

        // Act
        var result = await _productService.GetProductByIdAsync(nonExistentId);

        // Assert
        result.Should().BeNull();
    }

    [Fact]
    public async Task GetProductByIdAsync_InactiveProduct_ReturnsNull()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        var product = _productFaker.Generate();
        product.CategoryId = category.Id;
        product.Category = category;
        product.IsActive = false; // Set product as inactive

        _context.Categories.Add(category);
        _context.Products.Add(product);
        await _context.SaveChangesAsync();

        // Act
        var result = await _productService.GetProductByIdAsync(product.Id);

        // Assert
        result.Should().BeNull();
    }

    [Theory]
    [InlineData("laptop", 1)]
    [InlineData("book", 2)]
    [InlineData("nonexistent", 0)]
    public async Task GetProductsAsync_WithSearchTerm_ReturnsFilteredResults(string searchTerm, int expectedCount)
    {
        // Arrange
        var category = _categoryFaker.Generate();
        _context.Categories.Add(category);

        var products = new List<Product>
        {
            _productFaker.Clone().RuleFor(p => p.Name, "Gaming Laptop").Generate(),
            _productFaker.Clone().RuleFor(p => p.Name, "Programming Book").Generate(),
            _productFaker.Clone().RuleFor(p => p.Name, "Coffee Mug").Generate()
        };

        foreach (var product in products)
        {
            product.CategoryId = category.Id;
            product.Category = category;
        }

        _context.Products.AddRange(products);
        await _context.SaveChangesAsync();

        var searchDto = new ProductSearchDto
        {
            SearchTerm = searchTerm,
            PageNumber = 1,
            PageSize = 10
        };

        // Act
        var result = await _productService.GetProductsAsync(searchDto);

        // Assert
        result.Should().NotBeNull();
        result.Data.Should().HaveCount(expectedCount);
        result.TotalRecords.Should().Be(expectedCount);
    }

    [Fact]
    public async Task CreateProductAsync_ValidProduct_ReturnsCreatedProduct()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        _context.Categories.Add(category);
        await _context.SaveChangesAsync();

        var createDto = new CreateProductDto
        {
            Name = "Test Product",
            Description = "Test Description",
            Price = 99.99M,
            Stock = 10,
            CategoryId = category.Id,
            SKU = "TEST-001"
        };

        // Act
        var result = await _productService.CreateProductAsync(createDto);

        // Assert
        result.Should().NotBeNull();
        result.Name.Should().Be(createDto.Name);
        result.Description.Should().Be(createDto.Description);
        result.Price.Should().Be(createDto.Price);
        result.Stock.Should().Be(createDto.Stock);
        result.CategoryId.Should().Be(createDto.CategoryId);
        result.SKU.Should().Be(createDto.SKU);

        // Verify product was saved to database
        var savedProduct = await _context.Products.FindAsync(result.Id);
        savedProduct.Should().NotBeNull();
    }

    [Fact]
    public async Task CreateProductAsync_InvalidCategory_ThrowsArgumentException()
    {
        // Arrange
        var createDto = new CreateProductDto
        {
            Name = "Test Product",
            Description = "Test Description",
            Price = 99.99M,
            Stock = 10,
            CategoryId = 999, // Non-existent category
            SKU = "TEST-001"
        };

        // Act & Assert
        var exception = await Assert.ThrowsAsync<ArgumentException>(() => 
            _productService.CreateProductAsync(createDto));
        
        exception.Message.Should().Contain("Category with ID 999 does not exist");
    }

    [Fact]
    public async Task CreateProductAsync_DuplicateSKU_ThrowsArgumentException()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        var existingProduct = _productFaker.Generate();
        existingProduct.CategoryId = category.Id;
        existingProduct.Category = category;
        existingProduct.SKU = "DUPLICATE-SKU";

        _context.Categories.Add(category);
        _context.Products.Add(existingProduct);
        await _context.SaveChangesAsync();

        var createDto = new CreateProductDto
        {
            Name = "New Product",
            Description = "New Description",
            Price = 99.99M,
            Stock = 10,
            CategoryId = category.Id,
            SKU = "DUPLICATE-SKU" // Same SKU as existing product
        };

        // Act & Assert
        var exception = await Assert.ThrowsAsync<ArgumentException>(() => 
            _productService.CreateProductAsync(createDto));
        
        exception.Message.Should().Contain("Product with SKU 'DUPLICATE-SKU' already exists");
    }

    [Fact]
    public async Task UpdateProductAsync_ValidUpdate_ReturnsUpdatedProduct()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        var product = _productFaker.Generate();
        product.CategoryId = category.Id;
        product.Category = category;

        _context.Categories.Add(category);
        _context.Products.Add(product);
        await _context.SaveChangesAsync();

        var updateDto = new UpdateProductDto
        {
            Name = "Updated Product Name",
            Price = 199.99M,
            Stock = 20
        };

        // Act
        var result = await _productService.UpdateProductAsync(product.Id, updateDto);

        // Assert
        result.Should().NotBeNull();
        result!.Name.Should().Be(updateDto.Name);
        result.Price.Should().Be(updateDto.Price!.Value);
        result.Stock.Should().Be(updateDto.Stock!.Value);
        result.UpdatedAt.Should().NotBeNull();

        // Verify changes were saved to database
        var updatedProduct = await _context.Products.FindAsync(product.Id);
        updatedProduct!.Name.Should().Be(updateDto.Name);
        updatedProduct.UpdatedAt.Should().NotBeNull();
    }

    [Fact]
    public async Task UpdateProductAsync_NonExistentProduct_ReturnsNull()
    {
        // Arrange
        var updateDto = new UpdateProductDto
        {
            Name = "Updated Product Name"
        };

        // Act
        var result = await _productService.UpdateProductAsync(999, updateDto);

        // Assert
        result.Should().BeNull();
    }

    [Fact]
    public async Task DeleteProductAsync_ExistingProduct_ReturnsTrue()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        var product = _productFaker.Generate();
        product.CategoryId = category.Id;
        product.Category = category;

        _context.Categories.Add(category);
        _context.Products.Add(product);
        await _context.SaveChangesAsync();

        // Act
        var result = await _productService.DeleteProductAsync(product.Id);

        // Assert
        result.Should().BeTrue();

        // Verify product was soft deleted (IsActive = false)
        var deletedProduct = await _context.Products.FindAsync(product.Id);
        deletedProduct.Should().NotBeNull();
        deletedProduct!.IsActive.Should().BeFalse();
        deletedProduct.UpdatedAt.Should().NotBeNull();
    }

    [Fact]
    public async Task DeleteProductAsync_NonExistentProduct_ReturnsFalse()
    {
        // Act
        var result = await _productService.DeleteProductAsync(999);

        // Assert
        result.Should().BeFalse();
    }

    [Fact]
    public async Task UpdateStockAsync_ValidUpdate_ReturnsTrue()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        var product = _productFaker.Generate();
        product.CategoryId = category.Id;
        product.Category = category;
        product.Stock = 10;

        _context.Categories.Add(category);
        _context.Products.Add(product);
        await _context.SaveChangesAsync();

        var newStock = 25;

        // Act
        var result = await _productService.UpdateStockAsync(product.Id, newStock);

        // Assert
        result.Should().BeTrue();

        // Verify stock was updated
        var updatedProduct = await _context.Products.FindAsync(product.Id);
        updatedProduct!.Stock.Should().Be(newStock);
        updatedProduct.UpdatedAt.Should().NotBeNull();
    }

    [Fact]
    public async Task UpdateStockAsync_NegativeStock_ThrowsArgumentException()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        var product = _productFaker.Generate();
        product.CategoryId = category.Id;
        product.Category = category;

        _context.Categories.Add(category);
        _context.Products.Add(product);
        await _context.SaveChangesAsync();

        // Act & Assert
        var exception = await Assert.ThrowsAsync<ArgumentException>(() => 
            _productService.UpdateStockAsync(product.Id, -5));
        
        exception.Message.Should().Contain("Stock cannot be negative");
    }

    [Fact]
    public async Task GetLowStockProductsAsync_ReturnsProductsBelowThreshold()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        _context.Categories.Add(category);

        var products = new List<Product>
        {
            _productFaker.Clone().RuleFor(p => p.Stock, 5).Generate(),  // Low stock
            _productFaker.Clone().RuleFor(p => p.Stock, 8).Generate(),  // Low stock
            _productFaker.Clone().RuleFor(p => p.Stock, 15).Generate(), // Normal stock
            _productFaker.Clone().RuleFor(p => p.Stock, 0).Generate()   // Out of stock (should not be included)
        };

        foreach (var product in products)
        {
            product.CategoryId = category.Id;
            product.Category = category;
        }

        _context.Products.AddRange(products);
        await _context.SaveChangesAsync();

        var threshold = 10;

        // Act
        var result = await _productService.GetLowStockProductsAsync(threshold);

        // Assert
        result.Should().HaveCount(2); // Only products with stock 5 and 8
        result.All(p => p.Stock > 0 && p.Stock <= threshold).Should().BeTrue();
        result.Should().BeInAscendingOrder(p => p.Stock);
    }

    [Fact]
    public async Task IsSkuUniqueAsync_UniqueSku_ReturnsTrue()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        var product = _productFaker.Generate();
        product.CategoryId = category.Id;
        product.Category = category;
        product.SKU = "EXISTING-SKU";

        _context.Categories.Add(category);
        _context.Products.Add(product);
        await _context.SaveChangesAsync();

        // Act
        var result = await _productService.IsSkuUniqueAsync("NEW-UNIQUE-SKU");

        // Assert
        result.Should().BeTrue();
    }

    [Fact]
    public async Task IsSkuUniqueAsync_DuplicateSku_ReturnsFalse()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        var product = _productFaker.Generate();
        product.CategoryId = category.Id;
        product.Category = category;
        product.SKU = "EXISTING-SKU";

        _context.Categories.Add(category);
        _context.Products.Add(product);
        await _context.SaveChangesAsync();

        // Act
        var result = await _productService.IsSkuUniqueAsync("EXISTING-SKU");

        // Assert
        result.Should().BeFalse();
    }

    [Fact]
    public async Task IsSkuUniqueAsync_ExcludeCurrentProduct_ReturnsTrue()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        var product = _productFaker.Generate();
        product.CategoryId = category.Id;
        product.Category = category;
        product.SKU = "EXISTING-SKU";

        _context.Categories.Add(category);
        _context.Products.Add(product);
        await _context.SaveChangesAsync();

        // Act - Check if SKU is unique excluding the current product
        var result = await _productService.IsSkuUniqueAsync("EXISTING-SKU", product.Id);

        // Assert
        result.Should().BeTrue();
    }

    [Theory]
    [InlineData(1, 10, 1, 10)] // First page
    [InlineData(2, 5, 6, 10)]  // Second page with 5 items per page
    [InlineData(3, 5, 0, 0)]   // Third page (no items)
    public async Task GetProductsAsync_Pagination_ReturnsCorrectPage(
        int pageNumber, int pageSize, int expectedSkip, int expectedTotalRecords)
    {
        // Arrange
        var category = _categoryFaker.Generate();
        _context.Categories.Add(category);

        var products = _productFaker.Generate(10);
        foreach (var product in products)
        {
            product.CategoryId = category.Id;
            product.Category = category;
        }

        _context.Products.AddRange(products);
        await _context.SaveChangesAsync();

        var searchDto = new ProductSearchDto
        {
            PageNumber = pageNumber,
            PageSize = pageSize
        };

        // Act
        var result = await _productService.GetProductsAsync(searchDto);

        // Assert
        result.Should().NotBeNull();
        result.PageNumber.Should().Be(pageNumber);
        result.PageSize.Should().Be(pageSize);
        result.TotalRecords.Should().Be(10);
        
        if (pageNumber <= 2)
        {
            result.Data.Should().HaveCount(pageSize);
        }
        else
        {
            result.Data.Should().BeEmpty();
        }
    }

    public void Dispose()
    {
        _context.Dispose();
    }
}

/// <summary>
/// Test class demonstrating custom test attributes and data-driven tests
/// </summary>
public class ProductServiceDataDrivenTests
{
    [Theory]
    [MemberData(nameof(GetProductSearchTestData))]
    public async Task GetProductsAsync_VariousFilters_ReturnsExpectedResults(
        ProductSearchDto searchDto, 
        List<Product> seedProducts, 
        int expectedCount)
    {
        // Arrange
        var options = new DbContextOptionsBuilder<ProductCatalogContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        using var context = new ProductCatalogContext(options);
        var mockLogger = new Mock<ILogger<ProductService>>();
        var productService = new ProductService(context, mockLogger.Object);

        // Add test data
        context.Products.AddRange(seedProducts);
        await context.SaveChangesAsync();

        // Act
        var result = await productService.GetProductsAsync(searchDto);

        // Assert
        result.Data.Should().HaveCount(expectedCount);
    }

    public static IEnumerable<object[]> GetProductSearchTestData()
    {
        var faker = new Faker<Product>()
            .RuleFor(p => p.Id, f => f.Random.Int(1, 1000))
            .RuleFor(p => p.Name, f => f.Commerce.Product())
            .RuleFor(p => p.Price, f => f.Random.Decimal(10, 500))
            .RuleFor(p => p.Stock, f => f.Random.Int(1, 100))
            .RuleFor(p => p.CategoryId, f => 1)
            .RuleFor(p => p.IsActive, f => true);

        var products = faker.Generate(5);

        yield return new object[]
        {
            new ProductSearchDto { MinPrice = 100, MaxPrice = 300 },
            products,
            products.Count(p => p.Price >= 100 && p.Price <= 300)
        };

        yield return new object[]
        {
            new ProductSearchDto { InStockOnly = true },
            products,
            products.Count(p => p.Stock > 0)
        };
    }
}
