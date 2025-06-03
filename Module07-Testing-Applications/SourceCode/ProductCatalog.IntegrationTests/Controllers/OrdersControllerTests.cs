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
/// Integration tests for the Orders API endpoints
/// </summary>
public class OrdersControllerTests : IClassFixture<CustomWebApplicationFactory<Program>>
{
    private readonly HttpClient _client;
    private readonly JsonSerializerOptions _jsonOptions;

    public OrdersControllerTests(CustomWebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };
    }

    [Fact]
    public async Task GetOrders_ReturnsSuccessAndCorrectContent()
    {
        // Act
        var response = await _client.GetAsync("/api/Orders");
        
        // Assert
        response.EnsureSuccessStatusCode(); // Status code 200-299
        response.Content.Headers.ContentType!.ToString().Should().Contain("application/json");
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<PagedResponse<OrderResponseDto>>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeTrue();
        apiResponse.Data.Should().NotBeNull();
        apiResponse.Data!.Data.Should().NotBeEmpty();
    }

    [Fact]
    public async Task GetOrder_WithValidId_ReturnsOrder()
    {
        // Arrange
        var orderId = 1;
        
        // Act
        var response = await _client.GetAsync($"/api/Orders/{orderId}");
        
        // Assert
        response.EnsureSuccessStatusCode();
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<OrderResponseDto>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeTrue();
        apiResponse.Data.Should().NotBeNull();
        apiResponse.Data!.Id.Should().Be(orderId);
        apiResponse.Data.CustomerName.Should().Be("John Doe");
    }

    [Fact]
    public async Task GetOrder_WithInvalidId_ReturnsNotFound()
    {
        // Arrange
        var nonExistentId = 999;
        
        // Act
        var response = await _client.GetAsync($"/api/Orders/{nonExistentId}");
        
        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<object>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeFalse();
    }

    [Fact]
    public async Task CreateOrder_WithValidData_ReturnsCreatedOrder()
    {
        // Arrange
        var createDto = new CreateOrderDto
        {
            CustomerName = "Test Customer",
            CustomerEmail = "test.customer@example.com",
            Notes = "Integration test order",
            Items = new List<CreateOrderItemDto>
            {
                new CreateOrderItemDto { ProductId = 2, Quantity = 1 },
                new CreateOrderItemDto { ProductId = 3, Quantity = 2 }
            }
        };
        
        var content = new StringContent(
            JsonSerializer.Serialize(createDto),
            Encoding.UTF8,
            "application/json");
        
        // Act
        var response = await _client.PostAsync("/api/Orders", content);
        
        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<OrderResponseDto>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeTrue();
        apiResponse.Data.Should().NotBeNull();
        apiResponse.Data!.CustomerName.Should().Be(createDto.CustomerName);
        apiResponse.Data.CustomerEmail.Should().Be(createDto.CustomerEmail);
        apiResponse.Data.Status.Should().Be(OrderStatus.Pending);
        apiResponse.Data.Items.Should().HaveCount(2);
        
        // Calculate expected total amount
        var expectedTotal = 1299.99M + (19.99M * 2); // 1 laptop + 2 t-shirts
        apiResponse.Data.TotalAmount.Should().Be(expectedTotal);
    }

    [Fact]
    public async Task CreateOrder_WithInvalidEmail_ReturnsBadRequest()
    {
        // Arrange
        var createDto = new CreateOrderDto
        {
            CustomerName = "Test Customer",
            CustomerEmail = "invalid-email",
            Items = new List<CreateOrderItemDto>
            {
                new CreateOrderItemDto { ProductId = 1, Quantity = 1 }
            }
        };
        
        var content = new StringContent(
            JsonSerializer.Serialize(createDto),
            Encoding.UTF8,
            "application/json");
        
        // Act
        var response = await _client.PostAsync("/api/Orders", content);
        
        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<object>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeFalse();
        apiResponse.Errors.Should().NotBeEmpty();
        apiResponse.Errors!.Should().Contain(e => e.Contains("email"));
    }

    [Fact]
    public async Task GetOrdersByCustomer_ReturnsCustomerOrders()
    {
        // Arrange
        var customerEmail = "john.doe@example.com";
        
        // Act
        var response = await _client.GetAsync($"/api/Orders/customer/{customerEmail}");
        
        // Assert
        response.EnsureSuccessStatusCode();
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<List<OrderResponseDto>>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeTrue();
        apiResponse.Data.Should().NotBeNull();
        apiResponse.Data.Should().NotBeEmpty();
        
        // All returned orders should be for the specified customer
        apiResponse.Data!.All(o => o.CustomerEmail == customerEmail).Should().BeTrue();
    }

    [Fact]
    public async Task UpdateOrderStatus_WithValidStatus_ReturnsSuccess()
    {
        // Arrange
        var orderId = 2; // Processing order
        var newStatus = OrderStatus.Shipped;
        
        var content = new StringContent(
            JsonSerializer.Serialize(newStatus),
            Encoding.UTF8,
            "application/json");
        
        // Act
        var response = await _client.PatchAsync($"/api/Orders/{orderId}/status", content);
        
        // Assert
        response.EnsureSuccessStatusCode();
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<object>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeTrue();
        
        // Verify the order status was updated
        var getResponse = await _client.GetAsync($"/api/Orders/{orderId}");
        getResponse.EnsureSuccessStatusCode();
        
        var orderResponse = await getResponse.Content.ReadFromJsonAsync<ApiResponse<OrderResponseDto>>(_jsonOptions);
        orderResponse.Should().NotBeNull();
        orderResponse!.Data.Should().NotBeNull();
        orderResponse.Data!.Status.Should().Be(newStatus);
    }

    [Fact]
    public async Task CancelOrder_WithPendingOrder_ReturnsSuccess()
    {
        // First create a new order to cancel
        var createDto = new CreateOrderDto
        {
            CustomerName = "Cancel Test",
            CustomerEmail = "cancel.test@example.com",
            Items = new List<CreateOrderItemDto>
            {
                new CreateOrderItemDto { ProductId = 1, Quantity = 1 }
            }
        };
        
        var createContent = new StringContent(
            JsonSerializer.Serialize(createDto),
            Encoding.UTF8,
            "application/json");
        
        var createResponse = await _client.PostAsync("/api/Orders", createContent);
        createResponse.EnsureSuccessStatusCode();
        
        var createApiResponse = await createResponse.Content.ReadFromJsonAsync<ApiResponse<OrderResponseDto>>(_jsonOptions);
        var newOrderId = createApiResponse!.Data!.Id;
        
        // Act - Cancel the order
        var response = await _client.PostAsync($"/api/Orders/{newOrderId}/cancel", null);
        
        // Assert
        response.EnsureSuccessStatusCode();
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<object>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeTrue();
        
        // Verify the order status was updated to Cancelled
        var getResponse = await _client.GetAsync($"/api/Orders/{newOrderId}");
        getResponse.EnsureSuccessStatusCode();
        
        var orderResponse = await getResponse.Content.ReadFromJsonAsync<ApiResponse<OrderResponseDto>>(_jsonOptions);
        orderResponse.Should().NotBeNull();
        orderResponse!.Data.Should().NotBeNull();
        orderResponse.Data!.Status.Should().Be(OrderStatus.Cancelled);
    }

    [Fact]
    public async Task CalculateOrderTotal_ReturnsCorrectTotal()
    {
        // Arrange
        var items = new List<CreateOrderItemDto>
        {
            new CreateOrderItemDto { ProductId = 1, Quantity = 2 }, // 2 smartphones
            new CreateOrderItemDto { ProductId = 3, Quantity = 3 }  // 3 t-shirts
        };
        
        var content = new StringContent(
            JsonSerializer.Serialize(items),
            Encoding.UTF8,
            "application/json");
        
        // Act
        var response = await _client.PostAsync("/api/Orders/calculate-total", content);
        
        // Assert
        response.EnsureSuccessStatusCode();
        
        var apiResponse = await response.Content.ReadFromJsonAsync<ApiResponse<decimal>>(_jsonOptions);
        apiResponse.Should().NotBeNull();
        apiResponse!.Success.Should().BeTrue();
        
        // Calculate expected total: (2 * 699.99) + (3 * 19.99)
        var expectedTotal = (2 * 699.99M) + (3 * 19.99M);
        apiResponse.Data.Should().Be(expectedTotal);
    }
}