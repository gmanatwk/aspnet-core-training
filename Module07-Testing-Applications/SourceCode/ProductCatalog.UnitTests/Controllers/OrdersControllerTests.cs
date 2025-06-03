using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using ProductCatalog.API.Controllers;
using ProductCatalog.API.DTOs;
using ProductCatalog.API.Models;
using ProductCatalog.API.Services;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Xunit;
using FluentAssertions;

namespace ProductCatalog.UnitTests.Controllers;

/// <summary>
/// Unit tests for OrdersController
/// Demonstrates testing controller actions, mocking dependencies, and testing error handling
/// </summary>
public class OrdersControllerTests
{
    private readonly Mock<IOrderService> _mockOrderService;
    private readonly Mock<INotificationService> _mockNotificationService;
    private readonly Mock<ILogger<OrdersController>> _mockLogger;
    private readonly OrdersController _controller;

    public OrdersControllerTests()
    {
        _mockOrderService = new Mock<IOrderService>();
        _mockNotificationService = new Mock<INotificationService>();
        _mockLogger = new Mock<ILogger<OrdersController>>();
        _controller = new OrdersController(
            _mockOrderService.Object,
            _mockNotificationService.Object,
            _mockLogger.Object);
    }

    [Fact]
    public async Task CreateOrder_WithValidData_ReturnsCreatedAtActionResult()
    {
        // Arrange
        var createDto = new CreateOrderDto
        {
            CustomerName = "John Doe",
            CustomerEmail = "john.doe@example.com",
            Items = new List<CreateOrderItemDto>
            {
                new CreateOrderItemDto { ProductId = 1, Quantity = 2 }
            }
        };

        var createdOrder = new OrderResponseDto
        {
            Id = 1,
            CustomerName = createDto.CustomerName,
            CustomerEmail = createDto.CustomerEmail,
            Status = OrderStatus.Pending,
            TotalAmount = 199.98M,
            Items = new List<OrderItemResponseDto>
            {
                new OrderItemResponseDto { ProductId = 1, Quantity = 2, UnitPrice = 99.99M }
            }
        };

        _mockNotificationService.Setup(n => n.IsEmailValidAsync(createDto.CustomerEmail))
            .ReturnsAsync(true);

        _mockOrderService.Setup(s => s.CreateOrderAsync(It.IsAny<CreateOrderDto>()))
            .ReturnsAsync(createdOrder);

        _mockNotificationService.Setup(n => n.SendEmailAsync(
                It.IsAny<string>(), 
                It.IsAny<string>(), 
                It.IsAny<string>()))
            .Returns(Task.CompletedTask);

        // Act
        var result = await _controller.CreateOrder(createDto);

        // Assert
        var createdAtActionResult = result.Result as CreatedAtActionResult;
        createdAtActionResult.Should().NotBeNull();
        createdAtActionResult!.StatusCode.Should().Be(201);
        createdAtActionResult.ActionName.Should().Be(nameof(OrdersController.GetOrder));
        createdAtActionResult.RouteValues["id"].Should().Be(createdOrder.Id);

        var response = createdAtActionResult.Value as ApiResponse<OrderResponseDto>;
        response.Should().NotBeNull();
        response!.Success.Should().BeTrue();
        response.Data.Should().NotBeNull();
        response.Data.CustomerName.Should().Be(createDto.CustomerName);
        response.Data.CustomerEmail.Should().Be(createDto.CustomerEmail);
    }

    [Fact]
    public async Task CreateOrder_WithInvalidEmail_ReturnsBadRequest()
    {
        // Arrange
        var createDto = new CreateOrderDto
        {
            CustomerName = "John Doe",
            CustomerEmail = "invalid-email",
            Items = new List<CreateOrderItemDto>
            {
                new CreateOrderItemDto { ProductId = 1, Quantity = 2 }
            }
        };

        _mockNotificationService.Setup(n => n.IsEmailValidAsync(createDto.CustomerEmail))
            .ReturnsAsync(false);

        // Act
        var result = await _controller.CreateOrder(createDto);

        // Assert
        var badRequestResult = result.Result as BadRequestObjectResult;
        badRequestResult.Should().NotBeNull();
        badRequestResult!.StatusCode.Should().Be(400);

        var response = badRequestResult.Value as ApiResponse<object>;
        response.Should().NotBeNull();
        response!.Success.Should().BeFalse();
        response.Errors.Should().NotBeEmpty();
        response.Errors.Should().Contain("Please provide a valid email address");
    }

    [Fact]
    public async Task CreateOrder_WithInvalidModel_ReturnsBadRequest()
    {
        // Arrange
        var createDto = new CreateOrderDto(); // Empty DTO will fail validation
        _controller.ModelState.AddModelError("CustomerName", "Customer name is required");

        // Act
        var result = await _controller.CreateOrder(createDto);

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
    public async Task CreateOrder_WithInsufficientStock_ReturnsBadRequest()
    {
        // Arrange
        var createDto = new CreateOrderDto
        {
            CustomerName = "John Doe",
            CustomerEmail = "john.doe@example.com",
            Items = new List<CreateOrderItemDto>
            {
                new CreateOrderItemDto { ProductId = 1, Quantity = 100 }
            }
        };

        _mockNotificationService.Setup(n => n.IsEmailValidAsync(createDto.CustomerEmail))
            .ReturnsAsync(true);

        _mockOrderService.Setup(s => s.CreateOrderAsync(It.IsAny<CreateOrderDto>()))
            .ThrowsAsync(new InvalidOperationException("Insufficient stock for product 'Test Product'"));

        // Act
        var result = await _controller.CreateOrder(createDto);

        // Assert
        var badRequestResult = result.Result as BadRequestObjectResult;
        badRequestResult.Should().NotBeNull();
        badRequestResult!.StatusCode.Should().Be(400);

        var response = badRequestResult.Value as ApiResponse<object>;
        response.Should().NotBeNull();
        response!.Success.Should().BeFalse();
        response.Errors.Should().NotBeEmpty();
        response.Errors.Should().Contain("Insufficient stock for product 'Test Product'");
    }

    [Fact]
    public async Task GetOrder_WithValidId_ReturnsOkResult()
    {
        // Arrange
        var orderId = 1;
        var expectedOrder = new OrderResponseDto
        {
            Id = orderId,
            CustomerName = "John Doe",
            CustomerEmail = "john.doe@example.com",
            Status = OrderStatus.Pending,
            TotalAmount = 199.98M
        };

        _mockOrderService.Setup(s => s.GetOrderByIdAsync(orderId))
            .ReturnsAsync(expectedOrder);

        // Act
        var result = await _controller.GetOrder(orderId);

        // Assert
        var okResult = result.Result as OkObjectResult;
        okResult.Should().NotBeNull();
        okResult!.StatusCode.Should().Be(200);

        var response = okResult.Value as ApiResponse<OrderResponseDto>;
        response.Should().NotBeNull();
        response!.Success.Should().BeTrue();
        response.Data.Should().NotBeNull();
        response.Data.Id.Should().Be(orderId);
    }

    [Fact]
    public async Task GetOrder_WithNonExistentId_ReturnsNotFound()
    {
        // Arrange
        var nonExistentId = 999;
        _mockOrderService.Setup(s => s.GetOrderByIdAsync(nonExistentId))
            .ReturnsAsync((OrderResponseDto)null);

        // Act
        var result = await _controller.GetOrder(nonExistentId);

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
    public async Task GetOrders_ReturnsOkResult_WithPagedOrders()
    {
        // Arrange
        var pageNumber = 1;
        var pageSize = 10;
        var expectedResponse = new PagedResponse<OrderResponseDto>
        {
            Data = new List<OrderResponseDto>
            {
                new OrderResponseDto { Id = 1, CustomerName = "John Doe" },
                new OrderResponseDto { Id = 2, CustomerName = "Jane Doe" }
            },
            PageNumber = pageNumber,
            PageSize = pageSize,
            TotalRecords = 2,
            TotalPages = 1
        };

        _mockOrderService.Setup(s => s.GetOrdersAsync(pageNumber, pageSize))
            .ReturnsAsync(expectedResponse);

        // Act
        var result = await _controller.GetOrders(pageNumber, pageSize);

        // Assert
        var okResult = result.Result as OkObjectResult;
        okResult.Should().NotBeNull();
        okResult!.StatusCode.Should().Be(200);

        var response = okResult.Value as ApiResponse<PagedResponse<OrderResponseDto>>;
        response.Should().NotBeNull();
        response!.Success.Should().BeTrue();
        response.Data.Should().NotBeNull();
        response.Data.Data.Should().HaveCount(2);
    }

    [Fact]
    public async Task GetOrdersByCustomer_WithValidEmail_ReturnsOkResult()
    {
        // Arrange
        var customerEmail = "john.doe@example.com";
        var expectedOrders = new List<OrderResponseDto>
        {
            new OrderResponseDto { Id = 1, CustomerEmail = customerEmail },
            new OrderResponseDto { Id = 2, CustomerEmail = customerEmail }
        };

        _mockOrderService.Setup(s => s.GetOrdersByCustomerEmailAsync(customerEmail))
            .ReturnsAsync(expectedOrders);

        // Act
        var result = await _controller.GetOrdersByCustomer(customerEmail);

        // Assert
        var okResult = result.Result as OkObjectResult;
        okResult.Should().NotBeNull();
        okResult!.StatusCode.Should().Be(200);

        var response = okResult.Value as ApiResponse<List<OrderResponseDto>>;
        response.Should().NotBeNull();
        response!.Success.Should().BeTrue();
        response.Data.Should().HaveCount(2);
    }

    [Fact]
    public async Task UpdateOrderStatus_WithValidStatus_ReturnsOkResult()
    {
        // Arrange
        var orderId = 1;
        var newStatus = OrderStatus.Processing;
        _mockOrderService.Setup(s => s.UpdateOrderStatusAsync(orderId, newStatus))
            .ReturnsAsync(true);

        // Act
        var result = await _controller.UpdateOrderStatus(orderId, newStatus);

        // Assert
        var okResult = result.Result as OkObjectResult;
        okResult.Should().NotBeNull();
        okResult!.StatusCode.Should().Be(200);

        var response = okResult.Value as ApiResponse<object>;
        response.Should().NotBeNull();
        response!.Success.Should().BeTrue();
        
        var data = response.Data as dynamic;
        ((int)data.OrderId).Should().Be(orderId);
        ((string)data.NewStatus).Should().Be(newStatus.ToString());
    }

    [Fact]
    public async Task UpdateOrderStatus_WithInvalidTransition_ReturnsBadRequest()
    {
        // Arrange
        var orderId = 1;
        var invalidNewStatus = OrderStatus.Delivered; // Invalid transition from Pending to Delivered
        _mockOrderService.Setup(s => s.UpdateOrderStatusAsync(orderId, invalidNewStatus))
            .ThrowsAsync(new InvalidOperationException("Invalid status transition"));

        // Act
        var result = await _controller.UpdateOrderStatus(orderId, invalidNewStatus);

        // Assert
        var badRequestResult = result.Result as BadRequestObjectResult;
        badRequestResult.Should().NotBeNull();
        badRequestResult!.StatusCode.Should().Be(400);

        var response = badRequestResult.Value as ApiResponse<object>;
        response.Should().NotBeNull();
        response!.Success.Should().BeFalse();
        response.Errors.Should().NotBeEmpty();
        response.Errors.Should().Contain("Invalid status transition");
    }

    [Fact]
    public async Task CancelOrder_WithValidId_ReturnsOkResult()
    {
        // Arrange
        var orderId = 1;
        _mockOrderService.Setup(s => s.CancelOrderAsync(orderId))
            .ReturnsAsync(true);

        // Act
        var result = await _controller.CancelOrder(orderId);

        // Assert
        var okResult = result.Result as OkObjectResult;
        okResult.Should().NotBeNull();
        okResult!.StatusCode.Should().Be(200);

        var response = okResult.Value as ApiResponse<object>;
        response.Should().NotBeNull();
        response!.Success.Should().BeTrue();
        
        var data = response.Data as dynamic;
        ((int)data.OrderId).Should().Be(orderId);
        ((string)data.Status).Should().Be("Cancelled");
    }

    [Fact]
    public async Task CancelOrder_WithDeliveredOrder_ReturnsBadRequest()
    {
        // Arrange
        var orderId = 1;
        _mockOrderService.Setup(s => s.CancelOrderAsync(orderId))
            .ThrowsAsync(new InvalidOperationException("Cannot cancel order with status: Delivered"));

        // Act
        var result = await _controller.CancelOrder(orderId);

        // Assert
        var badRequestResult = result.Result as BadRequestObjectResult;
        badRequestResult.Should().NotBeNull();
        badRequestResult!.StatusCode.Should().Be(400);

        var response = badRequestResult.Value as ApiResponse<object>;
        response.Should().NotBeNull();
        response!.Success.Should().BeFalse();
        response.Errors.Should().NotBeEmpty();
        response.Errors.Should().Contain("Cannot cancel order with status: Delivered");
    }

    [Fact]
    public async Task CalculateOrderTotal_WithValidItems_ReturnsOkResult()
    {
        // Arrange
        var items = new List<CreateOrderItemDto>
        {
            new CreateOrderItemDto { ProductId = 1, Quantity = 2 },
            new CreateOrderItemDto { ProductId = 2, Quantity = 1 }
        };

        var expectedTotal = 249.97M;
        _mockOrderService.Setup(s => s.CalculateOrderTotalAsync(It.IsAny<List<CreateOrderItemDto>>()))
            .ReturnsAsync(expectedTotal);

        // Act
        var result = await _controller.CalculateOrderTotal(items);

        // Assert
        var okResult = result.Result as OkObjectResult;
        okResult.Should().NotBeNull();
        okResult!.StatusCode.Should().Be(200);

        var response = okResult.Value as ApiResponse<decimal>;
        response.Should().NotBeNull();
        response!.Success.Should().BeTrue();
        response.Data.Should().Be(expectedTotal);
    }
}