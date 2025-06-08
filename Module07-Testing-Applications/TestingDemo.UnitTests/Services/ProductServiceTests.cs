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
