using System.Net;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using RestfulAPI.DTOs;
using RestfulAPI.Tests.Fixtures;
using RestfulAPI.Tests.Helpers;
using Xunit;

namespace RestfulAPI.Tests.IntegrationTests;

public class MinimalApiTests : IClassFixture<CustomWebApplicationFactory<Program>>
{
    private readonly CustomWebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;
    private readonly JsonSerializerOptions _jsonOptions;

    public MinimalApiTests(CustomWebApplicationFactory<Program> factory)
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
    public async Task MinimalApi_GetProducts_ReturnsPagedResponse()
    {
        // Act
        var response = await _client.GetAsync("/api/minimal/products");

        // Assert
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        var pagedResponse = JsonSerializer.Deserialize<PagedResponse<ProductDto>>(content, _jsonOptions);

        pagedResponse.Should().NotBeNull();
        pagedResponse!.Data.Should().NotBeEmpty();
        pagedResponse.TotalRecords.Should().BeGreaterThan(0);
    }

    [Fact]
    public async Task MinimalApi_GetProductById_ExistingProduct_ReturnsProduct()
    {
        // Act
        var response = await _client.GetAsync("/api/minimal/products/1");

        // Assert
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        var product = JsonSerializer.Deserialize<ProductDto>(content, _jsonOptions);

        product.Should().NotBeNull();
        product!.Id.Should().Be(1);
    }

    [Fact]
    public async Task MinimalApi_GetProductById_NonExistingProduct_ReturnsNotFound()
    {
        // Act
        var response = await _client.GetAsync("/api/minimal/products/999");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task MinimalApi_CreateProduct_ValidProduct_ReturnsCreated()
    {
        // Arrange
        var newProduct = new CreateProductDto
        {
            Name = "Minimal API Test Product",
            Description = "Created via Minimal API",
            Price = 29.99M,
            Category = "Test",
            StockQuantity = 50,
            Sku = "MIN-TEST-001",
            IsActive = true
        };

        var json = JsonSerializer.Serialize(newProduct);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/minimal/products", content);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        response.Headers.Location.Should().NotBeNull();
        
        var responseContent = await response.Content.ReadAsStringAsync();
        var createdProduct = JsonSerializer.Deserialize<ProductDto>(responseContent, _jsonOptions);
        
        createdProduct.Should().NotBeNull();
        createdProduct!.Name.Should().Be(newProduct.Name);
    }

    [Fact]
    public async Task MinimalApi_DeleteProduct_ExistingProduct_ReturnsNoContent()
    {
        // First create a product to delete
        var newProduct = new CreateProductDto
        {
            Name = "Product to Delete",
            Description = "Will be deleted",
            Price = 9.99M,
            Category = "Test",
            StockQuantity = 1
        };

        var json = JsonSerializer.Serialize(newProduct);
        var content = new StringContent(json, Encoding.UTF8, "application/json");
        
        var createResponse = await _client.PostAsync("/api/minimal/products", content);
        createResponse.EnsureSuccessStatusCode();
        
        var createdContent = await createResponse.Content.ReadAsStringAsync();
        var createdProduct = JsonSerializer.Deserialize<ProductDto>(createdContent, _jsonOptions);

        // Act
        var response = await _client.DeleteAsync($"/api/minimal/products/{createdProduct!.Id}");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NoContent);
    }

    [Fact]
    public async Task MinimalApi_DeleteProduct_NonExistingProduct_ReturnsNotFound()
    {
        // Act
        var response = await _client.DeleteAsync("/api/minimal/products/999");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Root_RedirectsToIndex()
    {
        // Act
        var response = await _client.GetAsync("/");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Redirect);
        response.Headers.Location?.ToString().Should().Be("/index.html");
    }

    [Fact]
    public async Task HealthCheck_ReturnsHealthy()
    {
        // Act
        var response = await _client.GetAsync("/health");

        // Assert
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        content.Should().Contain("Healthy");
    }
}