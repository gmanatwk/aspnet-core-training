using System.Net;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using FluentAssertions;
using ProductCatalog.API.DTOs;
using ProductCatalog.API.Models;
using ProductCatalog.API;
using Xunit;

namespace ProductCatalog.IntegrationTests.Controllers;

/// <summary>
/// Integration tests for the Products API endpoints
/// </summary>
public class ProductsControllerTests : IClassFixture<CustomWebApplicationFactory<Program>>
{
    private readonly HttpClient _client;
    private readonly JsonSerializerOptions _jsonOptions;

    public ProductsControllerTests(CustomWebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };
    }

    [Fact]
    public async Task GetProducts_ReturnsSuccessAndCorrectContent()
    {
        // Act
        var response = await _client.GetAsync("/api/Products");
        
        // Assert
        response.EnsureSuccessStatusCode(); // Status code 200-299
        response.Content.Headers.ContentType!.ToString().Should().Contain("application/json");
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<PagedResponse<ProductResponseDto>>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeTrue();
        apiResponse.Data.Should().NotBeNull();
        apiResponse.Data!.Data.Should().NotBeEmpty();
    }

    [Fact]
    public async Task GetProduct_WithValidId_ReturnsProduct()
    {
        // Arrange
        var productId = 1;
        
        // Act
        var response = await _client.GetAsync($"/api/Products/{productId}");
        
        // Assert
        response.EnsureSuccessStatusCode();
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<ProductResponseDto>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeTrue();
        apiResponse.Data.Should().NotBeNull();
        apiResponse.Data!.Id.Should().Be(productId);
        apiResponse.Data.Name.Should().Be("Smartphone");
    }

    [Fact]
    public async Task GetProduct_WithInvalidId_ReturnsNotFound()
    {
        // Arrange
        var nonExistentId = 999;
        
        // Act
        var response = await _client.GetAsync($"/api/Products/{nonExistentId}");
        
        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<object>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeFalse();
    }

    [Fact]
    public async Task CreateProduct_WithValidData_ReturnsCreatedProduct()
    {
        // Arrange
        var createDto = new CreateProductDto
        {
            Name = "Test Product",
            Description = "Integration test product",
            Price = 99.99M,
            Stock = 50,
            CategoryId = 1,
            SKU = "TEST-1001",
            TagIds = new List<int> { 1, 2 }
        };
        
        var content = new StringContent(
            JsonSerializer.Serialize(createDto),
            Encoding.UTF8,
            "application/json");
        
        // Act
        var response = await _client.PostAsync("/api/Products", content);
        
        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<ProductResponseDto>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeTrue();
        apiResponse.Data.Should().NotBeNull();
        apiResponse.Data!.Name.Should().Be(createDto.Name);
        apiResponse.Data.Price.Should().Be(createDto.Price);
        apiResponse.Data.CategoryId.Should().Be(createDto.CategoryId);
        apiResponse.Data.Tags.Should().HaveCount(2);
    }

    [Fact]
    public async Task UpdateProduct_WithValidData_ReturnsUpdatedProduct()
    {
        // Arrange
        var productId = 3; // T-Shirt
        var updateDto = new UpdateProductDto
        {
            Name = "Premium T-Shirt",
            Price = 24.99M
        };
        
        var content = new StringContent(
            JsonSerializer.Serialize(updateDto),
            Encoding.UTF8,
            "application/json");
        
        // Act
        var response = await _client.PutAsync($"/api/Products/{productId}", content);
        
        // Assert
        response.EnsureSuccessStatusCode();
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<ProductResponseDto>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeTrue();
        apiResponse.Data.Should().NotBeNull();
        apiResponse.Data!.Id.Should().Be(productId);
        apiResponse.Data.Name.Should().Be(updateDto.Name);
        apiResponse.Data.Price.Should().Be(updateDto.Price!.Value);
    }

    [Fact]
    public async Task DeleteProduct_WithValidId_ReturnsSuccess()
    {
        // Arrange - using a product ID that won't affect other tests
        var productId = 4; // Jeans
        
        // Act
        var response = await _client.DeleteAsync($"/api/Products/{productId}");
        
        // Assert
        response.EnsureSuccessStatusCode();
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<object>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeTrue();
        
        // Verify the product is now inactive
        var getResponse = await _client.GetAsync($"/api/Products/{productId}");
        getResponse.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task GetLowStockProducts_ReturnsLowStockItems()
    {
        // Act
        var response = await _client.GetAsync("/api/Products/low-stock?threshold=30");
        
        // Assert
        response.EnsureSuccessStatusCode();
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<List<ProductResponseDto>>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeTrue();
        apiResponse.Data.Should().NotBeNull();
        
        // All returned products should have stock <= 30
        apiResponse.Data!.All(p => p.Stock <= 30).Should().BeTrue();
    }

    [Fact]
    public async Task GetProductsByCategory_ReturnsProductsInCategory()
    {
        // Arrange
        var categoryId = 1; // Electronics
        
        // Act
        var response = await _client.GetAsync($"/api/Products/category/{categoryId}");
        
        // Assert
        response.EnsureSuccessStatusCode();
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<List<ProductResponseDto>>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeTrue();
        apiResponse.Data.Should().NotBeNull();
        
        // All returned products should be in the specified category
        apiResponse.Data!.All(p => p.CategoryId == categoryId).Should().BeTrue();
        apiResponse.Data.Any(p => p.Name == "Smartphone").Should().BeTrue();
        apiResponse.Data.Any(p => p.Name == "Laptop").Should().BeTrue();
    }
}