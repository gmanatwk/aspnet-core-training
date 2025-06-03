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
/// Unit tests for OrderService class
/// Demonstrates testing complex business logic, transactions, and external dependencies
/// </summary>
public class OrderServiceTests : IDisposable
{
    private readonly ProductCatalogContext _context;
    private readonly Mock<ILogger<OrderService>> _mockLogger;
    private readonly Mock<IProductService> _mockProductService;
    private readonly OrderService _orderService;
    private readonly Fixture _fixture;
    private readonly Faker<Product> _productFaker;
    private readonly Faker<Category> _categoryFaker;

    public OrderServiceTests()
    {
        // Setup InMemory database for testing
        var options = new DbContextOptionsBuilder<ProductCatalogContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new ProductCatalogContext(options);
        _mockLogger = new Mock<ILogger<OrderService>>();
        _mockProductService = new Mock<IProductService>();
        _orderService = new OrderService(_context, _mockLogger.Object, _mockProductService.Object);
        
        // Setup AutoFixture
        _fixture = new Fixture();
        _fixture.Behaviors.OfType<ThrowingRecursionBehavior>().ToList()
            .ForEach(b => _fixture.Behaviors.Remove(b));
        _fixture.Behaviors.Add(new OmitOnRecursionBehavior());

        // Setup Bogus fakers
        _categoryFaker = new Faker<Category>()
            .RuleFor(c => c.Id, f => f.Random.Int(1, 100))
            .RuleFor(c => c.Name, f => f.Commerce.Categories(1).First())
            .RuleFor(c => c.Description, f => f.Lorem.Sentence())
            .RuleFor(c => c.IsActive, f => true)
            .RuleFor(c => c.CreatedAt, f => f.Date.Recent());

        _productFaker = new Faker<Product>()
            .RuleFor(p => p.Id, f => f.Random.Int(1, 100))
            .RuleFor(p => p.Name, f => f.Commerce.Product())
            .RuleFor(p => p.Description, f => f.Lorem.Paragraph())
            .RuleFor(p => p.Price, f => f.Random.Decimal(10, 500))
            .RuleFor(p => p.Stock, f => f.Random.Int(10, 100))
            .RuleFor(p => p.CategoryId, f => f.Random.Int(1, 10))
            .RuleFor(p => p.SKU, f => f.Commerce.Ean13())
            .RuleFor(p => p.IsActive, f => true)
            .RuleFor(p => p.CreatedAt, f => f.Date.Recent());
    }

    [Fact]
    public async Task CreateOrderAsync_ValidOrder_ReturnsCreatedOrder()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        var products = _productFaker.Generate(2);
        products[0].CategoryId = category.Id;
        products[1].CategoryId = category.Id;

        _context.Categories.Add(category);
        _context.Products.AddRange(products);
        await _context.SaveChangesAsync();

        var createDto = new CreateOrderDto
        {
            CustomerName = "John Doe",
            CustomerEmail = "john.doe@example.com",
            Notes = "Test order",
            Items = new List<CreateOrderItemDto>
            {
                new() { ProductId = products[0].Id, Quantity = 2 },
                new() { ProductId = products[1].Id, Quantity = 1 }
            }
        };

        var expectedTotal = (products[0].Price * 2) + (products[1].Price * 1);

        // Act
        var result = await _orderService.CreateOrderAsync(createDto);

        // Assert
        result.Should().NotBeNull();
        result.CustomerName.Should().Be(createDto.CustomerName);
        result.CustomerEmail.Should().Be(createDto.CustomerEmail);
        result.Status.Should().Be(OrderStatus.Pending);
        result.TotalAmount.Should().Be(expectedTotal);
        result.Items.Should().HaveCount(2);

        // Verify order was saved to database
        var savedOrder = await _context.Orders
            .Include(o => o.OrderItems)
            .FirstOrDefaultAsync(o => o.Id == result.Id);
        
        savedOrder.Should().NotBeNull();
        savedOrder!.OrderItems.Should().HaveCount(2);

        // Verify stock was decremented
        var updatedProducts = await _context.Products.Where(p => products.Select(pr => pr.Id).Contains(p.Id)).ToListAsync();
        updatedProducts[0].Stock.Should().Be(products[0].Stock - 2);
        updatedProducts[1].Stock.Should().Be(products[1].Stock - 1);
    }

    [Fact]
    public async Task CreateOrderAsync_InsufficientStock_ThrowsInvalidOperationException()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        var product = _productFaker.Generate();
        product.CategoryId = category.Id;
        product.Stock = 5; // Low stock

        _context.Categories.Add(category);
        _context.Products.Add(product);
        await _context.SaveChangesAsync();

        var createDto = new CreateOrderDto
        {
            CustomerName = "John Doe",
            CustomerEmail = "john.doe@example.com",
            Items = new List<CreateOrderItemDto>
            {
                new() { ProductId = product.Id, Quantity = 10 } // More than available stock
            }
        };

        // Act & Assert
        var exception = await Assert.ThrowsAsync<InvalidOperationException>(() => 
            _orderService.CreateOrderAsync(createDto));
        
        exception.Message.Should().Contain("Insufficient stock");
        exception.Message.Should().Contain(product.Name);
    }

    [Fact]
    public async Task CreateOrderAsync_NonExistentProduct_ThrowsArgumentException()
    {
        // Arrange
        var createDto = new CreateOrderDto
        {
            CustomerName = "John Doe",
            CustomerEmail = "john.doe@example.com",
            Items = new List<CreateOrderItemDto>
            {
                new() { ProductId = 999, Quantity = 1 } // Non-existent product
            }
        };

        // Act & Assert
        var exception = await Assert.ThrowsAsync<ArgumentException>(() => 
            _orderService.CreateOrderAsync(createDto));
        
        exception.Message.Should().Contain("Product with ID 999 does not exist");
    }

    [Fact]
    public async Task GetOrderByIdAsync_ExistingOrder_ReturnsOrder()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        var product = _productFaker.Generate();
        product.CategoryId = category.Id;

        _context.Categories.Add(category);
        _context.Products.Add(product);

        var order = new Order
        {
            CustomerName = "John Doe",
            CustomerEmail = "john.doe@example.com",
            OrderDate = DateTime.UtcNow,
            Status = OrderStatus.Pending,
            TotalAmount = 100.00M,
            OrderItems = new List<OrderItem>
            {
                new()
                {
                    ProductId = product.Id,
                    Quantity = 2,
                    UnitPrice = 50.00M
                }
            }
        };

        _context.Orders.Add(order);
        await _context.SaveChangesAsync();

        // Act
        var result = await _orderService.GetOrderByIdAsync(order.Id);

        // Assert
        result.Should().NotBeNull();
        result!.Id.Should().Be(order.Id);
        result.CustomerName.Should().Be(order.CustomerName);
        result.CustomerEmail.Should().Be(order.CustomerEmail);
        result.Status.Should().Be(order.Status);
        result.TotalAmount.Should().Be(order.TotalAmount);
        result.Items.Should().HaveCount(1);
        result.Items.First().ProductName.Should().Be(product.Name);
    }

    [Fact]
    public async Task GetOrderByIdAsync_NonExistentOrder_ReturnsNull()
    {
        // Act
        var result = await _orderService.GetOrderByIdAsync(999);

        // Assert
        result.Should().BeNull();
    }

    [Theory]
    [InlineData(OrderStatus.Pending, OrderStatus.Processing, true)]
    [InlineData(OrderStatus.Pending, OrderStatus.Cancelled, true)]
    [InlineData(OrderStatus.Processing, OrderStatus.Shipped, true)]
    [InlineData(OrderStatus.Shipped, OrderStatus.Delivered, true)]
    [InlineData(OrderStatus.Delivered, OrderStatus.Refunded, true)]
    [InlineData(OrderStatus.Cancelled, OrderStatus.Processing, false)]
    [InlineData(OrderStatus.Delivered, OrderStatus.Pending, false)]
    public async Task UpdateOrderStatusAsync_VariousTransitions_ReturnsExpectedResult(
        OrderStatus currentStatus, OrderStatus newStatus, bool shouldSucceed)
    {
        // Arrange
        var order = new Order
        {
            CustomerName = "John Doe",
            CustomerEmail = "john.doe@example.com",
            OrderDate = DateTime.UtcNow,
            Status = currentStatus,
            TotalAmount = 100.00M
        };

        _context.Orders.Add(order);
        await _context.SaveChangesAsync();

        // Act & Assert
        if (shouldSucceed)
        {
            var result = await _orderService.UpdateOrderStatusAsync(order.Id, newStatus);
            result.Should().BeTrue();

            // Verify status was updated
            var updatedOrder = await _context.Orders.FindAsync(order.Id);
            updatedOrder!.Status.Should().Be(newStatus);
        }
        else
        {
            await Assert.ThrowsAsync<InvalidOperationException>(() => 
                _orderService.UpdateOrderStatusAsync(order.Id, newStatus));
        }
    }

    [Fact]
    public async Task CancelOrderAsync_PendingOrder_CancelsAndRestoresStock()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        var product = _productFaker.Generate();
        product.CategoryId = category.Id;
        product.Stock = 10;

        _context.Categories.Add(category);
        _context.Products.Add(product);

        var order = new Order
        {
            CustomerName = "John Doe",
            CustomerEmail = "john.doe@example.com",
            OrderDate = DateTime.UtcNow,
            Status = OrderStatus.Pending,
            TotalAmount = 100.00M,
            OrderItems = new List<OrderItem>
            {
                new()
                {
                    ProductId = product.Id,
                    Quantity = 3,
                    UnitPrice = 50.00M
                }
            }
        };

        _context.Orders.Add(order);
        await _context.SaveChangesAsync();

        // Simulate stock being decremented when order was created
        product.Stock = 7; // 10 - 3
        await _context.SaveChangesAsync();

        // Act
        var result = await _orderService.CancelOrderAsync(order.Id);

        // Assert
        result.Should().BeTrue();

        // Verify order status was updated
        var cancelledOrder = await _context.Orders.FindAsync(order.Id);
        cancelledOrder!.Status.Should().Be(OrderStatus.Cancelled);

        // Verify stock was restored
        var restoredProduct = await _context.Products.FindAsync(product.Id);
        restoredProduct!.Stock.Should().Be(10); // 7 + 3
    }

    [Fact]
    public async Task CancelOrderAsync_DeliveredOrder_ThrowsInvalidOperationException()
    {
        // Arrange
        var order = new Order
        {
            CustomerName = "John Doe",
            CustomerEmail = "john.doe@example.com",
            OrderDate = DateTime.UtcNow,
            Status = OrderStatus.Delivered, // Cannot cancel delivered orders
            TotalAmount = 100.00M
        };

        _context.Orders.Add(order);
        await _context.SaveChangesAsync();

        // Act & Assert
        var exception = await Assert.ThrowsAsync<InvalidOperationException>(() => 
            _orderService.CancelOrderAsync(order.Id));
        
        exception.Message.Should().Contain("Cannot cancel order with status: Delivered");
    }

    [Fact]
    public async Task GetOrdersByCustomerEmailAsync_ExistingCustomer_ReturnsCustomerOrders()
    {
        // Arrange
        var customerEmail = "john.doe@example.com";
        var otherCustomerEmail = "jane.doe@example.com";

        var orders = new List<Order>
        {
            new()
            {
                CustomerName = "John Doe",
                CustomerEmail = customerEmail,
                OrderDate = DateTime.UtcNow.AddDays(-2),
                Status = OrderStatus.Delivered,
                TotalAmount = 100.00M
            },
            new()
            {
                CustomerName = "John Doe",
                CustomerEmail = customerEmail,
                OrderDate = DateTime.UtcNow.AddDays(-1),
                Status = OrderStatus.Pending,
                TotalAmount = 150.00M
            },
            new()
            {
                CustomerName = "Jane Doe",
                CustomerEmail = otherCustomerEmail,
                OrderDate = DateTime.UtcNow,
                Status = OrderStatus.Processing,
                TotalAmount = 200.00M
            }
        };

        _context.Orders.AddRange(orders);
        await _context.SaveChangesAsync();

        // Act
        var result = await _orderService.GetOrdersByCustomerEmailAsync(customerEmail);

        // Assert
        result.Should().HaveCount(2);
        result.All(o => o.CustomerEmail == customerEmail).Should().BeTrue();
        result.Should().BeInDescendingOrder(o => o.OrderDate);
    }

    [Fact]
    public async Task CalculateOrderTotalAsync_ValidItems_ReturnsCorrectTotal()
    {
        // Arrange
        var category = _categoryFaker.Generate();
        var products = _productFaker.Generate(3);
        foreach (var product in products)
        {
            product.CategoryId = category.Id;
        }

        products[0].Price = 10.00M;
        products[1].Price = 25.50M;
        products[2].Price = 15.75M;

        _context.Categories.Add(category);
        _context.Products.AddRange(products);
        await _context.SaveChangesAsync();

        var items = new List<CreateOrderItemDto>
        {
            new() { ProductId = products[0].Id, Quantity = 2 }, // 10.00 * 2 = 20.00
            new() { ProductId = products[1].Id, Quantity = 1 }, // 25.50 * 1 = 25.50
            new() { ProductId = products[2].Id, Quantity = 3 }  // 15.75 * 3 = 47.25
        };

        var expectedTotal = 20.00M + 25.50M + 47.25M; // 92.75

        // Act
        var result = await _orderService.CalculateOrderTotalAsync(items);

        // Assert
        result.Should().Be(expectedTotal);
    }

    [Fact]
    public async Task CalculateOrderTotalAsync_NonExistentProduct_ThrowsArgumentException()
    {
        // Arrange
        var items = new List<CreateOrderItemDto>
        {
            new() { ProductId = 999, Quantity = 1 }
        };

        // Act & Assert
        var exception = await Assert.ThrowsAsync<ArgumentException>(() => 
            _orderService.CalculateOrderTotalAsync(items));
        
        exception.Message.Should().Contain("Product with ID 999 does not exist");
    }

    [Fact]
    public async Task GetOrdersAsync_WithPagination_ReturnsCorrectPage()
    {
        // Arrange
        var orders = new List<Order>();
        for (int i = 1; i <= 15; i++)
        {
            orders.Add(new Order
            {
                CustomerName = $"Customer {i}",
                CustomerEmail = $"customer{i}@example.com",
                OrderDate = DateTime.UtcNow.AddDays(-i),
                Status = OrderStatus.Pending,
                TotalAmount = i * 10.00M
            });
        }

        _context.Orders.AddRange(orders);
        await _context.SaveChangesAsync();

        // Act
        var result = await _orderService.GetOrdersAsync(pageNumber: 2, pageSize: 5);

        // Assert
        result.Should().NotBeNull();
        result.Data.Should().HaveCount(5);
        result.PageNumber.Should().Be(2);
        result.PageSize.Should().Be(5);
        result.TotalRecords.Should().Be(15);
        result.TotalPages.Should().Be(3);
        result.HasNextPage.Should().BeTrue();
        result.HasPreviousPage.Should().BeTrue();

        // Verify orders are sorted by date descending (most recent first)
        var orderedDates = result.Data.Select(o => o.OrderDate).ToList();
        orderedDates.Should().BeInDescendingOrder();
    }

    public void Dispose()
    {
        _context.Dispose();
    }
}

/// <summary>
/// Test class for demonstrating testing with different mocking frameworks
/// </summary>
public class OrderServiceMockingTests
{
    [Fact]
    public async Task CreateOrderAsync_MockExample_WithMoq()
    {
        // Arrange
        var options = new DbContextOptionsBuilder<ProductCatalogContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        using var context = new ProductCatalogContext(options);
        
        var mockLogger = new Mock<ILogger<OrderService>>();
        var mockProductService = new Mock<IProductService>();
        
        // Setup mock expectations
        mockProductService.Setup(x => x.ProductExistsAsync(It.IsAny<int>()))
                         .ReturnsAsync(true);

        var orderService = new OrderService(context, mockLogger.Object, mockProductService.Object);

        // Add test data
        var product = new Product
        {
            Id = 1,
            Name = "Test Product",
            Price = 50.00M,
            Stock = 10,
            CategoryId = 1,
            IsActive = true
        };

        context.Products.Add(product);
        await context.SaveChangesAsync();

        var createDto = new CreateOrderDto
        {
            CustomerName = "Test Customer",
            CustomerEmail = "test@example.com",
            Items = new List<CreateOrderItemDto>
            {
                new() { ProductId = 1, Quantity = 2 }
            }
        };

        // Act
        var result = await orderService.CreateOrderAsync(createDto);

        // Assert
        result.Should().NotBeNull();
        result.TotalAmount.Should().Be(100.00M);

        // Verify mock was called
        mockProductService.Verify(x => x.ProductExistsAsync(It.IsAny<int>()), Times.Never);
        // Note: In this case, we're not using the mock since we have real data
    }
}
