using System.Net;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using FluentAssertions;
using Microsoft.AspNetCore.JsonPatch;
using Microsoft.AspNetCore.Mvc.Testing;
using RestfulAPI.DTOs;
using RestfulAPI.Tests.Fixtures;
using RestfulAPI.Tests.Helpers;
using Xunit;

namespace RestfulAPI.Tests.IntegrationTests;

public class ProductsControllerTests : IClassFixture<CustomWebApplicationFactory<Program>>
{
    private readonly CustomWebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;
    private readonly JsonSerializerOptions _jsonOptions;

    public ProductsControllerTests(CustomWebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = _factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = false
        });
        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };
    }

    [Fact]
    public async Task GetProducts_ReturnsSuccessAndCorrectContentType()
    {
        // Act
        var response = await _client.GetAsync("/api/v1/products");

        // Assert
        response.EnsureSuccessStatusCode();
        response.Content.Headers.ContentType?.ToString().Should().Be("application/json; charset=utf-8");
    }

    [Fact]
    public async Task GetProducts_ReturnsPagedResponse()
    {
        // Act
        var response = await _client.GetAsync("/api/v1/products?pageNumber=1&pageSize=2");

        // Assert
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        var pagedResponse = JsonSerializer.Deserialize<PagedResponse<ProductDto>>(content, _jsonOptions);

        pagedResponse.Should().NotBeNull();
        pagedResponse!.PageNumber.Should().Be(1);
        pagedResponse.PageSize.Should().Be(2);
        pagedResponse.Data.Should().HaveCount(2);
        pagedResponse.TotalRecords.Should().Be(3);
    }

    [Fact]
    public async Task GetProducts_WithCategoryFilter_ReturnsFilteredProducts()
    {
        // Act
        var response = await _client.GetAsync("/api/v1/products?category=Electronics");

        // Assert
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        var pagedResponse = JsonSerializer.Deserialize<PagedResponse<ProductDto>>(content, _jsonOptions);

        pagedResponse.Should().NotBeNull();
        pagedResponse!.Data.Should().HaveCount(2);
        pagedResponse.Data.Should().OnlyContain(p => p.Category == "Electronics");
    }

    [Fact]
    public async Task GetProducts_WithPriceFilter_ReturnsFilteredProducts()
    {
        // Act
        var response = await _client.GetAsync("/api/v1/products?minPrice=10&maxPrice=30");

        // Assert
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        var pagedResponse = JsonSerializer.Deserialize<PagedResponse<ProductDto>>(content, _jsonOptions);

        pagedResponse.Should().NotBeNull();
        pagedResponse!.Data.Should().HaveCount(2);
        pagedResponse.Data.Should().OnlyContain(p => p.Price >= 10 && p.Price <= 30);
    }

    [Fact]
    public async Task GetProductById_ExistingProduct_ReturnsProduct()
    {
        // Act
        var response = await _client.GetAsync("/api/v1/products/1");

        // Assert
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        var product = JsonSerializer.Deserialize<ProductDto>(content, _jsonOptions);

        product.Should().NotBeNull();
        product!.Id.Should().Be(1);
        product.Name.Should().Be("Test Product 1");
    }

    [Fact]
    public async Task GetProductById_NonExistingProduct_ReturnsNotFound()
    {
        // Act
        var response = await _client.GetAsync("/api/v1/products/999");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task CreateProduct_ValidProduct_ReturnsCreatedProduct()
    {
        // Arrange
        var newProduct = new CreateProductDto
        {
            Name = "New Test Product",
            Description = "New Test Description",
            Price = 99.99M,
            Category = "Test Category",
            StockQuantity = 10,
            Sku = "NEW-TEST-001",
            IsActive = true
        };

        var json = JsonSerializer.Serialize(newProduct);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/v1/products", content);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        response.Headers.Location.Should().NotBeNull();
        
        var responseContent = await response.Content.ReadAsStringAsync();
        var createdProduct = JsonSerializer.Deserialize<ProductDto>(responseContent, _jsonOptions);
        
        createdProduct.Should().NotBeNull();
        createdProduct!.Name.Should().Be(newProduct.Name);
        createdProduct.Price.Should().Be(newProduct.Price);
    }

    [Fact]
    public async Task CreateProduct_InvalidProduct_ReturnsBadRequest()
    {
        // Arrange
        var invalidProduct = new CreateProductDto
        {
            Name = "", // Invalid: empty name
            Price = -10, // Invalid: negative price
            StockQuantity = -5 // Invalid: negative stock
        };

        var json = JsonSerializer.Serialize(invalidProduct);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/v1/products", content);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task UpdateProduct_ExistingProduct_ReturnsUpdatedProduct()
    {
        // Arrange
        var updateProduct = new UpdateProductDto
        {
            Name = "Updated Product",
            Description = "Updated Description",
            Price = 15.99M,
            Category = "Updated Category",
            StockQuantity = 20,
            IsAvailable = true,
            Sku = "UPDATED-001",
            IsActive = true
        };

        var json = JsonSerializer.Serialize(updateProduct);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PutAsync("/api/v1/products/1", content);

        // Assert
        response.EnsureSuccessStatusCode();
        var responseContent = await response.Content.ReadAsStringAsync();
        var updatedProduct = JsonSerializer.Deserialize<ProductDto>(responseContent, _jsonOptions);

        updatedProduct.Should().NotBeNull();
        updatedProduct!.Name.Should().Be(updateProduct.Name);
        updatedProduct.Price.Should().Be(updateProduct.Price);
    }

    [Fact]
    public async Task UpdateProduct_NonExistingProduct_ReturnsNotFound()
    {
        // Arrange
        var updateProduct = new UpdateProductDto
        {
            Name = "Updated Product",
            Description = "Updated Description",
            Price = 15.99M,
            Category = "Updated Category",
            StockQuantity = 20
        };

        var json = JsonSerializer.Serialize(updateProduct);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PutAsync("/api/v1/products/999", content);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task PatchProduct_ExistingProduct_ReturnsUpdatedProduct()
    {
        // Arrange
        var patchDoc = new JsonPatchDocument<UpdateProductDto>();
        patchDoc.Replace(p => p.Price, 19.99M);
        patchDoc.Replace(p => p.StockQuantity, 150);

        var json = JsonSerializer.Serialize(patchDoc.Operations);
        var content = new StringContent(json, Encoding.UTF8, "application/json-patch+json");

        // Act
        var response = await _client.PatchAsync("/api/v1/products/1", content);

        // Assert
        response.EnsureSuccessStatusCode();
        var responseContent = await response.Content.ReadAsStringAsync();
        var updatedProduct = JsonSerializer.Deserialize<ProductDto>(responseContent, _jsonOptions);

        updatedProduct.Should().NotBeNull();
        updatedProduct!.Price.Should().Be(19.99M);
        updatedProduct.StockQuantity.Should().Be(150);
    }

    [Fact]
    public async Task DeleteProduct_ExistingProduct_ReturnsNoContent()
    {
        // Act
        var response = await _client.DeleteAsync("/api/v1/products/2");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NoContent);

        // Verify product is deleted
        var getResponse = await _client.GetAsync("/api/v1/products/2");
        getResponse.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task DeleteProduct_NonExistingProduct_ReturnsNotFound()
    {
        // Act
        var response = await _client.DeleteAsync("/api/v1/products/999");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task GetCategories_ReturnsDistinctCategories()
    {
        // Act
        var response = await _client.GetAsync("/api/v1/products/categories");

        // Assert
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        var categories = JsonSerializer.Deserialize<List<string>>(content, _jsonOptions);

        categories.Should().NotBeNull();
        categories.Should().Contain(new[] { "Electronics", "Books" });
        categories.Should().HaveCount(2);
    }

    [Fact]
    public async Task GetSecureProducts_WithoutAuth_ReturnsUnauthorized()
    {
        // Act
        var response = await _client.GetAsync("/api/v1/products/secure");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task GetSecureProducts_WithAdminAuth_ReturnsProducts()
    {
        // Arrange
        await TestAuthHelper.GetAuthenticatedClient(_client, "admin@test.com", "Admin123!");

        // Act
        var response = await _client.GetAsync("/api/v1/products/secure");

        // Assert
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        var products = JsonSerializer.Deserialize<List<ProductDto>>(content, _jsonOptions);

        products.Should().NotBeNull();
        products.Should().NotBeEmpty();
    }

    [Fact]
    public async Task GetSecureProducts_WithManagerAuth_ReturnsProducts()
    {
        // Arrange
        await TestAuthHelper.GetAuthenticatedClient(_client, "manager@test.com", "Manager123!");

        // Act
        var response = await _client.GetAsync("/api/v1/products/secure");

        // Assert
        response.EnsureSuccessStatusCode();
    }

    [Fact]
    public async Task GetSecureProducts_WithRegularUserAuth_ReturnsForbidden()
    {
        // Arrange
        await TestAuthHelper.GetAuthenticatedClient(_client, "user@test.com", "User123!");

        // Act
        var response = await _client.GetAsync("/api/v1/products/secure");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task SearchProducts_WithValidQuery_ReturnsMatchingProducts()
    {
        // Act
        var response = await _client.GetAsync("/api/v1/products/search?query=Test");

        // Assert
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        var pagedResponse = JsonSerializer.Deserialize<PagedResponse<ProductDto>>(content, _jsonOptions);

        pagedResponse.Should().NotBeNull();
        pagedResponse!.Data.Should().NotBeEmpty();
        pagedResponse.Data.Should().OnlyContain(p => 
            p.Name.Contains("Test", StringComparison.OrdinalIgnoreCase) || 
            p.Description.Contains("Test", StringComparison.OrdinalIgnoreCase));
    }

    [Fact]
    public async Task SearchProducts_WithEmptyQuery_ReturnsBadRequest()
    {
        // Act
        var response = await _client.GetAsync("/api/v1/products/search?query=");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }
}