using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Order;
using Bogus;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Moq;
using ProductCatalog.API.Data;
using ProductCatalog.API.DTOs;
using ProductCatalog.API.Models;
using ProductCatalog.API.Services;

namespace ProductCatalog.PerformanceTests.Benchmarks;

/// <summary>
/// Performance benchmarks for OrderService operations
/// </summary>
[MemoryDiagnoser]
[Orderer(SummaryOrderPolicy.FastestToSlowest)]
[RankColumn]
public class OrderServiceBenchmarks
{
    private ProductCatalogContext _context = null!;
    private OrderService _service = null!;
    private List<Product> _products = null!;
    private List<Category> _categories = null!;
    private List<Order> _orders = null!;
    
    [GlobalSetup]
    public void Setup()
    {
        // Setup database context with in-memory database
        var options = new DbContextOptionsBuilder<ProductCatalogContext>()
            .UseInMemoryDatabase(databaseName: $"OrderCatalog_Benchmark_{Guid.NewGuid()}")
            .Options;
            
        _context = new ProductCatalogContext(options);
        
        // Setup mock loggers and dependencies
        var mockOrderLogger = new Mock<ILogger<OrderService>>();
        var mockProductLogger = new Mock<ILogger<ProductService>>();
        
        // Create product service first
        var productService = new ProductService(_context, mockProductLogger.Object);
        
        // Create order service
        _service = new OrderService(_context, mockOrderLogger.Object, productService);
        
        // Generate test data
        GenerateTestData();
    }
    
    [GlobalCleanup]
    public void Cleanup()
    {
        _context.Dispose();
    }
    
    private void GenerateTestData()
    {
        // Generate categories
        var categoryFaker = new Faker<Category>()
            .RuleFor(c => c.Name, f => f.Commerce.Categories(1).First())
            .RuleFor(c => c.Description, f => f.Lorem.Sentence())
            .RuleFor(c => c.IsActive, f => true)
            .RuleFor(c => c.CreatedAt, f => f.Date.Past());
            
        _categories = categoryFaker.Generate(5);
        
        for (int i = 0; i < _categories.Count; i++)
        {
            _categories[i].Id = i + 1;
        }
        
        _context.Categories.AddRange(_categories);
        _context.SaveChanges();
        
        // Generate products
        var productFaker = new Faker<Product>()
            .RuleFor(p => p.Name, f => f.Commerce.ProductName())
            .RuleFor(p => p.Description, f => f.Commerce.ProductDescription())
            .RuleFor(p => p.Price, f => f.Random.Decimal(10, 1000))
            .RuleFor(p => p.Stock, f => f.Random.Int(10, 100)) // Ensure sufficient stock
            .RuleFor(p => p.CategoryId, f => f.PickRandom(_categories).Id)
            .RuleFor(p => p.IsActive, f => true)
            .RuleFor(p => p.CreatedAt, f => f.Date.Past())
            .RuleFor(p => p.SKU, f => f.Commerce.Ean13());
            
        _products = productFaker.Generate(100);
        
        for (int i = 0; i < _products.Count; i++)
        {
            _products[i].Id = i + 1;
        }
        
        _context.Products.AddRange(_products);
        _context.SaveChanges();
        
        // Generate orders
        var orderFaker = new Faker<Order>()
            .RuleFor(o => o.CustomerName, f => f.Name.FullName())
            .RuleFor(o => o.CustomerEmail, f => f.Internet.Email())
            .RuleFor(o => o.OrderDate, f => f.Date.Past(1))
            .RuleFor(o => o.Status, f => f.PickRandom<OrderStatus>())
            .RuleFor(o => o.Notes, f => f.Lorem.Sentence());
            
        _orders = orderFaker.Generate(500);
        
        for (int i = 0; i < _orders.Count; i++)
        {
            _orders[i].Id = i + 1;
            
            // Generate 1-5 order items for each order
            var itemCount = new Random().Next(1, 6);
            var orderItems = new List<OrderItem>();
            decimal totalAmount = 0;
            
            for (int j = 0; j < itemCount; j++)
            {
                var product = _products[new Random().Next(_products.Count)];
                var quantity = new Random().Next(1, 5);
                var unitPrice = product.Price;
                
                orderItems.Add(new OrderItem
                {
                    OrderId = _orders[i].Id,
                    ProductId = product.Id,
                    Quantity = quantity,
                    UnitPrice = unitPrice
                });
                
                totalAmount += unitPrice * quantity;
            }
            
            _orders[i].TotalAmount = totalAmount;
            _orders[i].OrderItems = orderItems;
        }
        
        _context.Orders.AddRange(_orders);
        _context.SaveChanges();
    }
    
    [Benchmark]
    public async Task GetOrders_Default()
    {
        var result = await _service.GetOrdersAsync(1, 10);
        return;
    }
    
    [Benchmark]
    public async Task GetOrderById()
    {
        var orderId = 1;
        var result = await _service.GetOrderByIdAsync(orderId);
        return;
    }
    
    [Benchmark]
    public async Task GetOrdersByCustomerEmail()
    {
        var customerEmail = _orders[0].CustomerEmail;
        var result = await _service.GetOrdersByCustomerEmailAsync(customerEmail);
        return;
    }
    
    [Benchmark]
    public async Task CreateOrder()
    {
        // Create a new order with 2-3 items
        var random = new Random();
        var itemCount = random.Next(2, 4);
        var items = new List<CreateOrderItemDto>();
        
        for (int i = 0; i < itemCount; i++)
        {
            var productId = random.Next(1, _products.Count);
            items.Add(new CreateOrderItemDto
            {
                ProductId = productId,
                Quantity = random.Next(1, 3)
            });
        }
        
        var createDto = new CreateOrderDto
        {
            CustomerName = $"Benchmark User {Guid.NewGuid().ToString().Substring(0, 8)}",
            CustomerEmail = $"benchmark-{Guid.NewGuid().ToString().Substring(0, 8)}@example.com",
            Notes = "Order created during benchmarking",
            Items = items
        };
        
        var result = await _service.CreateOrderAsync(createDto);
        return;
    }
    
    [Benchmark]
    public async Task CalculateOrderTotal()
    {
        // Calculate total for an order with 3 items
        var items = new List<CreateOrderItemDto>
        {
            new CreateOrderItemDto { ProductId = 1, Quantity = 2 },
            new CreateOrderItemDto { ProductId = 2, Quantity = 1 },
            new CreateOrderItemDto { ProductId = 3, Quantity = 3 }
        };
        
        var result = await _service.CalculateOrderTotalAsync(items);
        return;
    }
    
    [Benchmark]
    public async Task UpdateOrderStatus()
    {
        // Find a pending order
        var pendingOrder = _orders.FirstOrDefault(o => o.Status == OrderStatus.Pending);
        if (pendingOrder != null)
        {
            var result = await _service.UpdateOrderStatusAsync(pendingOrder.Id, OrderStatus.Processing);
        }
        return;
    }
    
    [Benchmark]
    public async Task CancelOrder()
    {
        // Find a processing order
        var processingOrder = _orders.FirstOrDefault(o => o.Status == OrderStatus.Processing);
        if (processingOrder != null)
        {
            var result = await _service.CancelOrderAsync(processingOrder.Id);
        }
        return;
    }
}