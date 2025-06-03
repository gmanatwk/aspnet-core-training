using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using ProductCatalog.API.Controllers;
using ProductCatalog.API.DTOs;
using ProductCatalog.API.Models;
using ProductCatalog.API.Services;
using System.Collections.Generic;
using System.Threading.Tasks;
using Xunit;
using FluentAssertions;

namespace ProductCatalog.UnitTests.Controllers;

/// <summary>
/// Unit tests for ProductsController
/// Demonstrates testing controller actions, status codes, and responses
/// </summary>
public class ProductsControllerTests
{
    private readonly Mock<IProductService> _mockProductService;
    private readonly Mock<ILogger<ProductsController>> _mockLogger;
    private readonly ProductsController _controller;

    public ProductsControllerTests()
    {
        _mockProductService = new Mock<IProductService>();
        _mockLogger = new Mock<ILogger<ProductsController>>();
        _controller = new ProductsController(_mockProductService.Object, _mockLogger.Object);
    }

    [Fact]
    public async Task GetProducts_ReturnsOkResult_WithProductsList()
    {
        // Arrange
        var searchDto = new ProductSearchDto();
        var expectedResponse = new PagedResponse<ProductResponseDto>
        {
            Data = new List<ProductResponseDto>
            {
                new ProductResponseDto { Id = 1, Name = "Test Product 1" },
                new ProductResponseDto { Id = 2, Name = "Test Product 2" }
            },
            PageNumber = 1,
            PageSize = 10,
            TotalRecords = 2,
            TotalPages = 1
        };

        _mockProductService.Setup(s => s.GetProductsAsync(It.IsAny<ProductSearchDto>()))
            .ReturnsAsync(expectedResponse);

        // Act
        var result = await _controller.GetProducts(searchDto);

        // Assert
        var okResult = result.Result as OkObjectResult;
        okResult.Should().NotBeNull();
        okResult!.StatusCode.Should().Be(200);

        var response = okResult.Value as ApiResponse<PagedResponse<ProductResponseDto>>;
        response.Should().NotBeNull();
        response!.Success.Should().BeTrue();
        response.Data.Should().NotBeNull();
        response.Data.Data.Should().HaveCount(2);
    }

    [Fact]
    public async Task GetProduct_WithValidId_ReturnsOkResult_WithProduct()
    {
        // Arrange
        var productId = 1;
        var expectedProduct = new ProductResponseDto
        {
            Id = productId,
            Name = "Test Product",
            Description = "Test Description",
            Price = 99.99M
        };

        _mockProductService.Setup(s => s.GetProductByIdAsync(productId))
            .ReturnsAsync(expectedProduct);

        // Act
        var result = await _controller.GetProduct(productId);

        // Assert
        var okResult = result.Result as OkObjectResult;
        okResult.Should().NotBeNull();
        okResult!.StatusCode.Should().Be(200);

        var response = okResult.Value as ApiResponse<ProductResponseDto>;
        response.Should().NotBeNull();
        response!.Success.Should().BeTrue();
        response.Data.Should().NotBeNull();
        response.Data.Id.Should().Be(productId);
        response.Data.Name.Should().Be("Test Product");
    }

    [Fact]
    public async Task GetProduct_WithInvalidId_ReturnsBadRequest()
    {
        // Arrange
        var invalidProductId = 0;

        // Act
        var result = await _controller.GetProduct(invalidProductId);

        // Assert
        var badRequestResult = result.Result as BadRequestObjectResult;
        badRequestResult.Should().NotBeNull();
        badRequestResult!.StatusCode.Should().Be(400);

        var response = badRequestResult.Value as ApiResponse<object>;
        response.Should().NotBeNull();
        response!.Success.Should().BeFalse();
        response.Errors.Should().NotBeEmpty();
    }

    [Fact]
    public async Task GetProduct_WithNonExistentId_ReturnsNotFound()
    {
        // Arrange
        var nonExistentId = 999;
        _mockProductService.Setup(s => s.GetProductByIdAsync(nonExistentId))
            .ReturnsAsync((ProductResponseDto)null);

        // Act
        var result = await _controller.GetProduct(nonExistentId);

        // Assert
        var notFoundResult = result.Result as NotFoundObjectResult;
        notFoundResult.Should().NotBeNull();
        notFoundResult!.StatusCode.Should().Be(404);

        var response = notFoundResult.Value as ApiResponse<object>;
        response.Should().NotBeNull();
        response!.Success.Should().BeFalse();
        response.Errors.Should().NotBeEmpty();
    }

    [Fact]
    public async Task CreateProduct_WithValidDto_ReturnsCreatedAtActionResult()
    {
        // Arrange
        var createDto = new CreateProductDto
        {
            Name = "New Product",
            Description = "Product Description",
            Price = 49.99M,
            CategoryId = 1,
            Stock = 100
        };

        var createdProduct = new ProductResponseDto
        {
            Id = 1,
            Name = createDto.Name,
            Description = createDto.Description,
            Price = createDto.Price,
            CategoryId = createDto.CategoryId,
            Stock = createDto.Stock
        };

        _mockProductService.Setup(s => s.CreateProductAsync(It.IsAny<CreateProductDto>()))
            .ReturnsAsync(createdProduct);

        // Act
        var result = await _controller.CreateProduct(createDto);

        // Assert
        var createdAtActionResult = result.Result as CreatedAtActionResult;
        createdAtActionResult.Should().NotBeNull();
        createdAtActionResult!.StatusCode.Should().Be(201);
        createdAtActionResult.ActionName.Should().Be(nameof(ProductsController.GetProduct));
        createdAtActionResult.RouteValues["id"].Should().Be(createdProduct.Id);

        var response = createdAtActionResult.Value as ApiResponse<ProductResponseDto>;
        response.Should().NotBeNull();
        response!.Success.Should().BeTrue();
        response.Data.Should().NotBeNull();
        response.Data.Name.Should().Be(createDto.Name);
    }

    [Fact]
    public async Task CreateProduct_WithInvalidModel_ReturnsBadRequest()
    {
        // Arrange
        var createDto = new CreateProductDto(); // Empty DTO will fail validation
        _controller.ModelState.AddModelError("Name", "Name is required");

        // Act
        var result = await _controller.CreateProduct(createDto);

        // Assert
        var badRequestResult = result.Result as BadRequestObjectResult;
        badRequestResult.Should().NotBeNull();
        badRequestResult!.StatusCode.Should().Be(400);

        var response = badRequestResult.Value as ApiResponse<object>;
        response.Should().NotBeNull();
        response!.Success.Should().BeFalse();
        response.Errors.Should().NotBeEmpty();
    }

    [Fact]
    public async Task UpdateProduct_WithValidDto_ReturnsOkResult()
    {
        // Arrange
        var productId = 1;
        var updateDto = new UpdateProductDto
        {
            Name = "Updated Product Name",
            Price = 79.99M
        };

        var updatedProduct = new ProductResponseDto
        {
            Id = productId,
            Name = updateDto.Name,
            Price = updateDto.Price!.Value
        };

        _mockProductService.Setup(s => s.UpdateProductAsync(productId, It.IsAny<UpdateProductDto>()))
            .ReturnsAsync(updatedProduct);

        // Act
        var result = await _controller.UpdateProduct(productId, updateDto);

        // Assert
        var okResult = result.Result as OkObjectResult;
        okResult.Should().NotBeNull();
        okResult!.StatusCode.Should().Be(200);

        var response = okResult.Value as ApiResponse<ProductResponseDto>;
        response.Should().NotBeNull();
        response!.Success.Should().BeTrue();
        response.Data.Should().NotBeNull();
        response.Data.Id.Should().Be(productId);
        response.Data.Name.Should().Be(updateDto.Name);
    }

    [Fact]
    public async Task DeleteProduct_WithValidId_ReturnsOkResult()
    {
        // Arrange
        var productId = 1;
        _mockProductService.Setup(s => s.DeleteProductAsync(productId))
            .ReturnsAsync(true);

        // Act
        var result = await _controller.DeleteProduct(productId);

        // Assert
        var okResult = result.Result as OkObjectResult;
        okResult.Should().NotBeNull();
        okResult!.StatusCode.Should().Be(200);

        var response = okResult.Value as ApiResponse<object>;
        response.Should().NotBeNull();
        response!.Success.Should().BeTrue();
    }

    [Fact]
    public async Task GetLowStockProducts_ReturnsOkResult_WithLowStockProducts()
    {
        // Arrange
        var threshold = 5;
        var expectedProducts = new List<ProductResponseDto>
        {
            new ProductResponseDto { Id = 1, Name = "Low Stock Product 1", Stock = 3 },
            new ProductResponseDto { Id = 2, Name = "Low Stock Product 2", Stock = 4 }
        };

        _mockProductService.Setup(s => s.GetLowStockProductsAsync(threshold))
            .ReturnsAsync(expectedProducts);

        // Act
        var result = await _controller.GetLowStockProducts(threshold);

        // Assert
        var okResult = result.Result as OkObjectResult;
        okResult.Should().NotBeNull();
        okResult!.StatusCode.Should().Be(200);

        var response = okResult.Value as ApiResponse<List<ProductResponseDto>>;
        response.Should().NotBeNull();
        response!.Success.Should().BeTrue();
        response.Data.Should().HaveCount(2);
    }

    [Fact]
    public async Task UpdateStock_WithValidData_ReturnsOkResult()
    {
        // Arrange
        var productId = 1;
        var newStock = 50;
        _mockProductService.Setup(s => s.UpdateStockAsync(productId, newStock))
            .ReturnsAsync(true);

        // Act
        var result = await _controller.UpdateStock(productId, newStock);

        // Assert
        var okResult = result.Result as OkObjectResult;
        okResult.Should().NotBeNull();
        okResult!.StatusCode.Should().Be(200);

        var response = okResult.Value as ApiResponse<object>;
        response.Should().NotBeNull();
        response!.Success.Should().BeTrue();
        
        var data = response.Data as dynamic;
        ((int)data.ProductId).Should().Be(productId);
        ((int)data.NewStock).Should().Be(newStock);
    }
}