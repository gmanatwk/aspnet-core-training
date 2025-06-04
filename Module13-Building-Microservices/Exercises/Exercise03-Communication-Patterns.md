# Exercise 3: Communication Patterns

## 🎯 Objective
Implement synchronous and asynchronous communication patterns between microservices, including HTTP APIs, event-driven messaging, and distributed transaction handling using the Saga pattern.

## 📋 Prerequisites
- Completion of Exercise 2 (Building Core Services)
- Understanding of message queues and event-driven architecture
- RabbitMQ or Azure Service Bus knowledge (helpful but not required)
- Basic understanding of distributed systems concepts

## 🏗️ Overview
In this exercise, you'll implement:
1. **Synchronous Communication** - Direct HTTP calls between services
2. **Asynchronous Messaging** - Event-driven communication using RabbitMQ
3. **Saga Pattern** - Distributed transaction management
4. **API Gateway** - Single entry point for client applications

## 🚀 Task 1: Set up Messaging Infrastructure (30 minutes)

### Step 1: Add RabbitMQ to Docker Compose
Update your `docker-compose.yml`:

```yaml
version: '3.8'

services:
  rabbitmq:
    image: rabbitmq:3-management
    container_name: rabbitmq
    ports:
      - "5672:5672"   # AMQP port
      - "15672:15672" # Management UI
    environment:
      RABBITMQ_DEFAULT_USER: admin
      RABBITMQ_DEFAULT_PASS: password
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq

  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      SA_PASSWORD: "YourStrong@Passw0rd"
      ACCEPT_EULA: "Y"
    ports:
      - "1433:1433"
    volumes:
      - sqlserver_data:/var/opt/mssql

  productcatalog:
    build: 
      context: ./src/ProductCatalog.Service
      dockerfile: Dockerfile
    ports:
      - "5001:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Server=sqlserver;Database=ProductCatalogDB;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True
      - RabbitMQ__Host=rabbitmq
      - RabbitMQ__Username=admin
      - RabbitMQ__Password=password
    depends_on:
      - sqlserver
      - rabbitmq

  ordermanagement:
    build: 
      context: ./src/OrderManagement.Service
      dockerfile: Dockerfile
    ports:
      - "5002:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Server=sqlserver;Database=OrderManagementDB;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True
      - RabbitMQ__Host=rabbitmq
      - RabbitMQ__Username=admin
      - RabbitMQ__Password=password
      - ProductCatalogService__BaseUrl=http://productcatalog
    depends_on:
      - sqlserver
      - rabbitmq
      - productcatalog

volumes:
  sqlserver_data:
  rabbitmq_data:
```

### Step 2: Create Messaging Abstractions
Add RabbitMQ client to shared library:

```bash
cd src/SharedLibraries/ECommerceMS.Shared
dotnet add package RabbitMQ.Client
```

**src/SharedLibraries/ECommerceMS.Shared/Messaging/IEventBus.cs:**
```csharp
using ECommerceMS.Shared.Events;

namespace ECommerceMS.Shared.Messaging;

public interface IEventBus
{
    Task PublishAsync<T>(T @event) where T : BaseEvent;
    Task SubscribeAsync<T>(Func<T, Task> handler) where T : BaseEvent;
    Task SubscribeAsync<T, TH>() where T : BaseEvent where TH : class, IEventHandler<T>;
}

public interface IEventHandler<in T> where T : BaseEvent
{
    Task HandleAsync(T @event);
}
```

## 📝 Task 2: Define Domain Events (20 minutes)

Create domain events that will be published when important business actions occur:

**src/SharedLibraries/ECommerceMS.Shared/Events/ProductEvents.cs:**
```csharp
namespace ECommerceMS.Shared.Events;

public class ProductCreatedEvent : BaseEvent
{
    public Guid ProductId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string SKU { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
    public Guid CategoryId { get; set; }

    public ProductCreatedEvent()
    {
        EventType = nameof(ProductCreatedEvent);
    }
}

public class ProductStockChangedEvent : BaseEvent
{
    public Guid ProductId { get; set; }
    public string SKU { get; set; } = string.Empty;
    public int PreviousStock { get; set; }
    public int NewStock { get; set; }
    public string Reason { get; set; } = string.Empty; // "order", "restock", "adjustment"

    public ProductStockChangedEvent()
    {
        EventType = nameof(ProductStockChangedEvent);
    }
}
```

**src/SharedLibraries/ECommerceMS.Shared/Events/OrderEvents.cs:**
```csharp
namespace ECommerceMS.Shared.Events;

public class OrderCreatedEvent : BaseEvent
{
    public Guid OrderId { get; set; }
    public Guid UserId { get; set; }
    public List<OrderItem> Items { get; set; } = new();
    public decimal TotalAmount { get; set; }
    public string Status { get; set; } = string.Empty;

    public OrderCreatedEvent()
    {
        EventType = nameof(OrderCreatedEvent);
    }
}

public class OrderStatusChangedEvent : BaseEvent
{
    public Guid OrderId { get; set; }
    public string PreviousStatus { get; set; } = string.Empty;
    public string NewStatus { get; set; } = string.Empty;
    public string Reason { get; set; } = string.Empty;

    public OrderStatusChangedEvent()
    {
        EventType = nameof(OrderStatusChangedEvent);
    }
}

public class OrderItem
{
    public Guid ProductId { get; set; }
    public string SKU { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
}
```

## 🛒 Task 3: Build Order Management Service (60 minutes)

### Step 1: Create Order Service Structure
```bash
cd src/OrderManagement.Service
dotnet new webapi -n OrderManagement.Service --framework net8.0
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package RabbitMQ.Client
dotnet add package MediatR
dotnet add package AutoMapper.Extensions.Microsoft.DependencyInjection
dotnet add package Polly
dotnet add package Polly.Extensions.Http

# Add references
dotnet add reference ../SharedLibraries/ECommerceMS.Shared/ECommerceMS.Shared.csproj
```

### Step 2: Create Order Domain Models

**Models/Order.cs:**
```csharp
using ECommerceMS.Shared.Models;
using System.ComponentModel.DataAnnotations;

namespace OrderManagement.Service.Models;

public class Order : BaseEntity
{
    [Required]
    public Guid UserId { get; set; }
    
    [Required]
    [StringLength(50)]
    public string OrderNumber { get; set; } = string.Empty;
    
    public DateTime OrderDate { get; set; } = DateTime.UtcNow;
    
    [Required]
    public OrderStatus Status { get; set; } = OrderStatus.Pending;
    
    public decimal TotalAmount { get; set; }
    public decimal ShippingAmount { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal DiscountAmount { get; set; }
    
    [StringLength(500)]
    public string? Notes { get; set; }
    
    // Shipping Address
    [Required]
    [StringLength(200)]
    public string ShippingName { get; set; } = string.Empty;
    
    [Required]
    [StringLength(200)]
    public string ShippingAddress { get; set; } = string.Empty;
    
    [Required]
    [StringLength(100)]
    public string ShippingCity { get; set; } = string.Empty;
    
    [Required]
    [StringLength(50)]
    public string ShippingState { get; set; } = string.Empty;
    
    [Required]
    [StringLength(20)]
    public string ShippingZipCode { get; set; } = string.Empty;
    
    [Required]
    [StringLength(100)]
    public string ShippingCountry { get; set; } = string.Empty;
    
    public ICollection<OrderItem> Items { get; set; } = new List<OrderItem>();
}

public class OrderItem : BaseEntity
{
    [Required]
    public Guid OrderId { get; set; }
    public Order Order { get; set; } = null!;
    
    [Required]
    public Guid ProductId { get; set; }
    
    [Required]
    [StringLength(50)]
    public string SKU { get; set; } = string.Empty;
    
    [Required]
    [StringLength(200)]
    public string ProductName { get; set; } = string.Empty;
    
    [Required]
    public int Quantity { get; set; }
    
    [Required]
    public decimal UnitPrice { get; set; }
    
    public decimal TotalPrice => Quantity * UnitPrice;
}

public enum OrderStatus
{
    Pending = 0,
    Confirmed = 1,
    Processing = 2,
    Shipped = 3,
    Delivered = 4,
    Cancelled = 5,
    Refunded = 6
}
```

### Step 3: Create External Service Clients

**Services/IProductCatalogService.cs:**
```csharp
namespace OrderManagement.Service.Services;

public interface IProductCatalogService
{
    Task<ProductDto?> GetProductAsync(Guid productId);
    Task<bool> CheckStockAvailabilityAsync(Guid productId, int quantity);
    Task<bool> ReserveStockAsync(Guid productId, int quantity);
    Task<bool> ReleaseStockAsync(Guid productId, int quantity);
}

public record ProductDto(
    Guid Id,
    string Name,
    string Description,
    decimal Price,
    string SKU,
    int StockQuantity,
    bool IsActive,
    Guid CategoryId,
    string CategoryName
);
```

**Services/ProductCatalogService.cs:**
```csharp
using Microsoft.Extensions.Options;
using System.Text.Json;
using Polly;
using Polly.Extensions.Http;

namespace OrderManagement.Service.Services;

public class ProductCatalogService : IProductCatalogService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<ProductCatalogService> _logger;
    private readonly ProductCatalogServiceOptions _options;

    public ProductCatalogService(
        HttpClient httpClient, 
        ILogger<ProductCatalogService> logger,
        IOptions<ProductCatalogServiceOptions> options)
    {
        _httpClient = httpClient;
        _logger = logger;
        _options = options.Value;
    }

    public async Task<ProductDto?> GetProductAsync(Guid productId)
    {
        try
        {
            var response = await _httpClient.GetAsync($"/api/products/{productId}");
            
            if (response.IsSuccessStatusCode)
            {
                var content = await response.Content.ReadAsStringAsync();
                return JsonSerializer.Deserialize<ProductDto>(content, new JsonSerializerOptions 
                { 
                    PropertyNameCaseInsensitive = true 
                });
            }
            
            if (response.StatusCode == System.Net.HttpStatusCode.NotFound)
            {
                return null;
            }
            
            _logger.LogWarning("Failed to get product {ProductId}. Status: {StatusCode}", 
                productId, response.StatusCode);
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting product {ProductId}", productId);
            return null;
        }
    }

    public async Task<bool> CheckStockAvailabilityAsync(Guid productId, int quantity)
    {
        var product = await GetProductAsync(productId);
        return product != null && product.IsActive && product.StockQuantity >= quantity;
    }

    public async Task<bool> ReserveStockAsync(Guid productId, int quantity)
    {
        try
        {
            var request = new { ProductId = productId, Quantity = quantity };
            var content = new StringContent(
                JsonSerializer.Serialize(request), 
                System.Text.Encoding.UTF8, 
                "application/json");

            var response = await _httpClient.PostAsync("/api/products/reserve-stock", content);
            return response.IsSuccessStatusCode;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error reserving stock for product {ProductId}", productId);
            return false;
        }
    }

    public async Task<bool> ReleaseStockAsync(Guid productId, int quantity)
    {
        try
        {
            var request = new { ProductId = productId, Quantity = quantity };
            var content = new StringContent(
                JsonSerializer.Serialize(request), 
                System.Text.Encoding.UTF8, 
                "application/json");

            var response = await _httpClient.PostAsync("/api/products/release-stock", content);
            return response.IsSuccessStatusCode;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error releasing stock for product {ProductId}", productId);
            return false;
        }
    }
}

public class ProductCatalogServiceOptions
{
    public string BaseUrl { get; set; } = string.Empty;
}
```

### Step 4: Create Order Processing Saga

**Sagas/OrderProcessingSaga.cs:**
```csharp
using MediatR;
using OrderManagement.Service.Services;
using OrderManagement.Service.Data;
using OrderManagement.Service.Models;
using ECommerceMS.Shared.Events;
using ECommerceMS.Shared.Messaging;
using Microsoft.EntityFrameworkCore;

namespace OrderManagement.Service.Sagas;

public class OrderProcessingSaga : INotificationHandler<OrderCreatedEvent>
{
    private readonly OrderManagementContext _context;
    private readonly IProductCatalogService _productService;
    private readonly IEventBus _eventBus;
    private readonly ILogger<OrderProcessingSaga> _logger;

    public OrderProcessingSaga(
        OrderManagementContext context,
        IProductCatalogService productService,
        IEventBus eventBus,
        ILogger<OrderProcessingSaga> logger)
    {
        _context = context;
        _productService = productService;
        _eventBus = eventBus;
        _logger = logger;
    }

    public async Task Handle(OrderCreatedEvent notification, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Processing order saga for order {OrderId}", notification.OrderId);

        var order = await _context.Orders
            .Include(o => o.Items)
            .FirstOrDefaultAsync(o => o.Id == notification.OrderId, cancellationToken);

        if (order == null)
        {
            _logger.LogError("Order {OrderId} not found", notification.OrderId);
            return;
        }

        try
        {
            // Step 1: Validate and reserve inventory
            var reservationResults = new List<(Guid ProductId, bool Success)>();
            
            foreach (var item in order.Items)
            {
                var stockAvailable = await _productService.CheckStockAvailabilityAsync(item.ProductId, item.Quantity);
                
                if (!stockAvailable)
                {
                    _logger.LogWarning("Insufficient stock for product {ProductId} in order {OrderId}", 
                        item.ProductId, order.Id);
                    
                    await CancelOrderAsync(order, "Insufficient stock");
                    return;
                }

                var reserved = await _productService.ReserveStockAsync(item.ProductId, item.Quantity);
                reservationResults.Add((item.ProductId, reserved));
                
                if (!reserved)
                {
                    _logger.LogWarning("Failed to reserve stock for product {ProductId} in order {OrderId}", 
                        item.ProductId, order.Id);
                    
                    // Rollback previous reservations
                    await RollbackReservationsAsync(reservationResults.Where(r => r.Success).ToList());
                    await CancelOrderAsync(order, "Stock reservation failed");
                    return;
                }
            }

            // Step 2: Confirm order
            await ConfirmOrderAsync(order);
            
            _logger.LogInformation("Order {OrderId} processed successfully", order.Id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing order saga for order {OrderId}", notification.OrderId);
            await CancelOrderAsync(order, "Processing error occurred");
        }
    }

    private async Task ConfirmOrderAsync(Order order)
    {
        var previousStatus = order.Status;
        order.Status = OrderStatus.Confirmed;
        order.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        // Publish order status changed event
        var statusChangedEvent = new OrderStatusChangedEvent
        {
            OrderId = order.Id,
            PreviousStatus = previousStatus.ToString(),
            NewStatus = order.Status.ToString(),
            Reason = "Order confirmed after successful inventory reservation"
        };

        await _eventBus.PublishAsync(statusChangedEvent);
    }

    private async Task CancelOrderAsync(Order order, string reason)
    {
        var previousStatus = order.Status;
        order.Status = OrderStatus.Cancelled;
        order.Notes = $"Cancelled: {reason}";
        order.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        // Publish order cancelled event
        var cancelledEvent = new OrderCancelledEvent
        {
            OrderId = order.Id,
            UserId = order.UserId,
            Items = order.Items.Select(i => new ECommerceMS.Shared.Events.OrderItem
            {
                ProductId = i.ProductId,
                SKU = i.SKU,
                Quantity = i.Quantity,
                UnitPrice = i.UnitPrice
            }).ToList(),
            Reason = reason
        };

        await _eventBus.PublishAsync(cancelledEvent);
    }

    private async Task RollbackReservationsAsync(List<(Guid ProductId, bool Success)> reservations)
    {
        foreach (var (productId, _) in reservations)
        {
            try
            {
                var orderItem = await _context.OrderItems
                    .FirstOrDefaultAsync(oi => oi.ProductId == productId);
                
                if (orderItem != null)
                {
                    await _productService.ReleaseStockAsync(productId, orderItem.Quantity);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to rollback reservation for product {ProductId}", productId);
            }
        }
    }
}
```

### Step 5: Create Order DTOs and Controller

**DTOs/OrderDtos.cs:**
```csharp
namespace OrderManagement.Service.DTOs;

public record OrderDto(
    Guid Id,
    Guid UserId,
    string OrderNumber,
    DateTime OrderDate,
    string Status,
    decimal TotalAmount,
    decimal ShippingAmount,
    decimal TaxAmount,
    decimal DiscountAmount,
    string ShippingName,
    string ShippingAddress,
    string ShippingCity,
    string ShippingState,
    string ShippingZipCode,
    string ShippingCountry,
    List<OrderItemDto> Items
);

public record OrderItemDto(
    Guid Id,
    Guid ProductId,
    string SKU,
    string ProductName,
    int Quantity,
    decimal UnitPrice,
    decimal TotalPrice
);

public record CreateOrderDto(
    Guid UserId,
    List<CreateOrderItemDto> Items,
    decimal ShippingAmount,
    decimal TaxAmount,
    decimal DiscountAmount,
    string ShippingName,
    string ShippingAddress,
    string ShippingCity,
    string ShippingState,
    string ShippingZipCode,
    string ShippingCountry,
    string? Notes
);

public record CreateOrderItemDto(
    Guid ProductId,
    int Quantity
);
```

**Controllers/OrdersController.cs:**
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OrderManagement.Service.Data;
using OrderManagement.Service.DTOs;
using OrderManagement.Service.Models;
using OrderManagement.Service.Services;
using ECommerceMS.Shared.Events;
using ECommerceMS.Shared.Messaging;

namespace OrderManagement.Service.Controllers;

[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly OrderManagementContext _context;
    private readonly IProductCatalogService _productService;
    private readonly IEventBus _eventBus;
    private readonly ILogger<OrdersController> _logger;

    public OrdersController(
        OrderManagementContext context,
        IProductCatalogService productService,
        IEventBus eventBus,
        ILogger<OrdersController> logger)
    {
        _context = context;
        _productService = productService;
        _eventBus = eventBus;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<OrderDto>>> GetOrders(
        [FromQuery] Guid? userId = null,
        [FromQuery] string? status = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10)
    {
        try
        {
            var query = _context.Orders.Include(o => o.Items).AsQueryable();

            if (userId.HasValue)
            {
                query = query.Where(o => o.UserId == userId.Value);
            }

            if (!string.IsNullOrEmpty(status) && Enum.TryParse<OrderStatus>(status, true, out var orderStatus))
            {
                query = query.Where(o => o.Status == orderStatus);
            }

            var orders = await query
                .OrderByDescending(o => o.OrderDate)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var orderDtos = orders.Select(MapToOrderDto);
            return Ok(orderDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving orders");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<OrderDto>> GetOrder(Guid id)
    {
        try
        {
            var order = await _context.Orders
                .Include(o => o.Items)
                .FirstOrDefaultAsync(o => o.Id == id);

            if (order == null)
            {
                return NotFound();
            }

            return Ok(MapToOrderDto(order));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving order {OrderId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPost]
    public async Task<ActionResult<OrderDto>> CreateOrder(CreateOrderDto createOrderDto)
    {
        try
        {
            // Validate products and calculate totals
            var orderItems = new List<OrderItem>();
            decimal itemsTotal = 0;

            foreach (var item in createOrderDto.Items)
            {
                var product = await _productService.GetProductAsync(item.ProductId);
                
                if (product == null)
                {
                    return BadRequest($"Product {item.ProductId} not found");
                }

                if (!product.IsActive)
                {
                    return BadRequest($"Product {product.Name} is not available");
                }

                var orderItem = new OrderItem
                {
                    ProductId = item.ProductId,
                    SKU = product.SKU,
                    ProductName = product.Name,
                    Quantity = item.Quantity,
                    UnitPrice = product.Price
                };

                orderItems.Add(orderItem);
                itemsTotal += orderItem.TotalPrice;
            }

            // Create order
            var order = new Order
            {
                UserId = createOrderDto.UserId,
                OrderNumber = GenerateOrderNumber(),
                Items = orderItems,
                TotalAmount = itemsTotal + createOrderDto.ShippingAmount + createOrderDto.TaxAmount - createOrderDto.DiscountAmount,
                ShippingAmount = createOrderDto.ShippingAmount,
                TaxAmount = createOrderDto.TaxAmount,
                DiscountAmount = createOrderDto.DiscountAmount,
                ShippingName = createOrderDto.ShippingName,
                ShippingAddress = createOrderDto.ShippingAddress,
                ShippingCity = createOrderDto.ShippingCity,
                ShippingState = createOrderDto.ShippingState,
                ShippingZipCode = createOrderDto.ShippingZipCode,
                ShippingCountry = createOrderDto.ShippingCountry,
                Notes = createOrderDto.Notes
            };

            _context.Orders.Add(order);
            await _context.SaveChangesAsync();

            // Publish order created event to trigger saga
            var orderCreatedEvent = new OrderCreatedEvent
            {
                OrderId = order.Id,
                UserId = order.UserId,
                Items = order.Items.Select(i => new ECommerceMS.Shared.Events.OrderItem
                {
                    ProductId = i.ProductId,
                    SKU = i.SKU,
                    Quantity = i.Quantity,
                    UnitPrice = i.UnitPrice
                }).ToList(),
                TotalAmount = order.TotalAmount,
                Status = order.Status.ToString()
            };

            await _eventBus.PublishAsync(orderCreatedEvent);

            _logger.LogInformation("Order {OrderId} created successfully", order.Id);

            return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, MapToOrderDto(order));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating order");
            return StatusCode(500, "Internal server error");
        }
    }

    private static OrderDto MapToOrderDto(Order order)
    {
        return new OrderDto(
            order.Id,
            order.UserId,
            order.OrderNumber,
            order.OrderDate,
            order.Status.ToString(),
            order.TotalAmount,
            order.ShippingAmount,
            order.TaxAmount,
            order.DiscountAmount,
            order.ShippingName,
            order.ShippingAddress,
            order.ShippingCity,
            order.ShippingState,
            order.ShippingZipCode,
            order.ShippingCountry,
            order.Items.Select(i => new OrderItemDto(
                i.Id,
                i.ProductId,
                i.SKU,
                i.ProductName,
                i.Quantity,
                i.UnitPrice,
                i.TotalPrice
            )).ToList()
        );
    }

    private static string GenerateOrderNumber()
    {
        return $"ORD-{DateTime.UtcNow:yyyyMMdd}-{Guid.NewGuid().ToString("N")[..8].ToUpper()}";
    }
}
```

## 🔧 Task 4: Configure Services and Test (30 minutes)

### Step 1: Configure Order Management Service

**Program.cs:**
```csharp
using Microsoft.EntityFrameworkCore;
using OrderManagement.Service.Data;
using OrderManagement.Service.Services;
using OrderManagement.Service.Sagas;
using ECommerceMS.Shared.Messaging;
using RabbitMQ.Client;
using Polly;
using Polly.Extensions.Http;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add Entity Framework
builder.Services.AddDbContext<OrderManagementContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add MediatR
builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(Program).Assembly));

// Configure HTTP clients with Polly retry policy
var retryPolicy = HttpPolicyExtensions
    .HandleTransientHttpError()
    .WaitAndRetryAsync(3, retryAttempt => 
        TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)));

builder.Services.Configure<ProductCatalogServiceOptions>(
    builder.Configuration.GetSection("ProductCatalogService"));

builder.Services.AddHttpClient<IProductCatalogService, ProductCatalogService>(client =>
{
    var baseUrl = builder.Configuration["ProductCatalogService:BaseUrl"];
    client.BaseAddress = new Uri(baseUrl!);
    client.DefaultRequestHeaders.Add("User-Agent", "OrderManagement.Service");
})
.AddPolicyHandler(retryPolicy);

// Add RabbitMQ
builder.Services.AddSingleton<IConnection>(sp =>
{
    var factory = new ConnectionFactory()
    {
        HostName = builder.Configuration["RabbitMQ:Host"],
        UserName = builder.Configuration["RabbitMQ:Username"],
        Password = builder.Configuration["RabbitMQ:Password"]
    };
    return factory.CreateConnection();
});

builder.Services.AddSingleton<IEventBus, RabbitMQEventBus>();

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy => policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});

var app = builder.Build();

// Configure pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");
app.UseHttpsRedirection();
app.MapControllers();

// Ensure database is created and subscribe to events
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<OrderManagementContext>();
    await context.Database.EnsureCreatedAsync();
    
    var eventBus = scope.ServiceProvider.GetRequiredService<IEventBus>();
    await eventBus.SubscribeAsync<OrderCreatedEvent, OrderProcessingSaga>();
}

await app.RunAsync();
```

### Step 2: Add Stock Management to Product Service

Update the Product Catalog Service to handle stock operations:

**ProductCatalog.Service/Controllers/ProductsController.cs - Add these methods:**
```csharp
[HttpPost("reserve-stock")]
public async Task<IActionResult> ReserveStock([FromBody] StockOperationDto request)
{
    try
    {
        var product = await _context.Products.FindAsync(request.ProductId);
        
        if (product == null)
        {
            return NotFound();
        }

        if (product.StockQuantity < request.Quantity)
        {
            return BadRequest("Insufficient stock");
        }

        var previousStock = product.StockQuantity;
        product.StockQuantity -= request.Quantity;
        product.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        // Publish stock changed event
        var stockChangedEvent = new ProductStockChangedEvent
        {
            ProductId = product.Id,
            SKU = product.SKU,
            PreviousStock = previousStock,
            NewStock = product.StockQuantity,
            Reason = "reservation"
        };

        // Note: You'll need to inject IEventBus here
        // await _eventBus.PublishAsync(stockChangedEvent);

        return Ok();
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error reserving stock for product {ProductId}", request.ProductId);
        return StatusCode(500, "Internal server error");
    }
}

[HttpPost("release-stock")]
public async Task<IActionResult> ReleaseStock([FromBody] StockOperationDto request)
{
    try
    {
        var product = await _context.Products.FindAsync(request.ProductId);
        
        if (product == null)
        {
            return NotFound();
        }

        var previousStock = product.StockQuantity;
        product.StockQuantity += request.Quantity;
        product.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        // Publish stock changed event
        var stockChangedEvent = new ProductStockChangedEvent
        {
            ProductId = product.Id,
            SKU = product.SKU,
            PreviousStock = previousStock,
            NewStock = product.StockQuantity,
            Reason = "release"
        };

        // Note: You'll need to inject IEventBus here
        // await _eventBus.PublishAsync(stockChangedEvent);

        return Ok();
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error releasing stock for product {ProductId}", request.ProductId);
        return StatusCode(500, "Internal server error");
    }
}

public record StockOperationDto(Guid ProductId, int Quantity);
```

### Step 3: Test the Communication Patterns

**Test Scenario 1: Successful Order Creation**
```bash
# Create an order
curl -X POST "http://localhost:5002/api/orders" \
-H "Content-Type: application/json" \
-d '{
  "userId": "11111111-1111-1111-1111-111111111111",
  "items": [
    {
      "productId": "33333333-3333-3333-3333-333333333333",
      "quantity": 1
    }
  ],
  "shippingAmount": 10.00,
  "taxAmount": 130.00,
  "discountAmount": 0.00,
  "shippingName": "John Doe",
  "shippingAddress": "123 Main St",
  "shippingCity": "Anytown",
  "shippingState": "CA",
  "shippingZipCode": "12345",
  "shippingCountry": "USA"
}'

# Check order status
curl -X GET "http://localhost:5002/api/orders/{order-id}"

# Check product stock (should be reduced)
curl -X GET "http://localhost:5001/api/products/33333333-3333-3333-3333-333333333333"
```

**Test Scenario 2: Order with Insufficient Stock**
```bash
# Try to order more items than available
curl -X POST "http://localhost:5002/api/orders" \
-H "Content-Type: application/json" \
-d '{
  "userId": "11111111-1111-1111-1111-111111111111",
  "items": [
    {
      "productId": "33333333-3333-3333-3333-333333333333",
      "quantity": 999
    }
  ],
  "shippingAmount": 10.00,
  "taxAmount": 0.00,
  "discountAmount": 0.00,
  "shippingName": "Jane Doe",
  "shippingAddress": "456 Oak Ave",
  "shippingCity": "Somewhere",
  "shippingState": "NY",
  "shippingZipCode": "67890",
  "shippingCountry": "USA"
}'
```

## 📝 Deliverables

1. **Working Order Management Service** with saga pattern implementation
2. **Event-driven communication** between Product and Order services
3. **Stock reservation system** with rollback capabilities
4. **Comprehensive testing** of both success and failure scenarios
5. **Documentation** of the communication patterns implemented

## 🎯 Success Criteria

### **Excellent (90-100%)**
- ✅ Both synchronous and asynchronous communication work correctly
- ✅ Saga pattern handles success and failure scenarios properly
- ✅ Stock reservations and releases work correctly
- ✅ Events are published and consumed successfully
- ✅ Comprehensive error handling and rollback mechanisms
- ✅ Proper logging and monitoring

### **Good (80-89%)**
- ✅ Basic communication patterns work
- ✅ Most saga scenarios handled correctly
- ✅ Stock operations mostly functional
- ✅ Events work in happy path scenarios

### **Satisfactory (70-79%)**
- ✅ Basic order creation works
- ✅ Simple communication between services
- ✅ Limited saga functionality

## 💡 Extension Activities

1. **Add Circuit Breaker**: Implement circuit breaker pattern for external service calls
2. **Add Idempotency**: Ensure operations can be safely retried
3. **Add Monitoring**: Implement health checks and metrics
4. **Add Compensation**: Implement more sophisticated compensation logic
5. **Add Event Store**: Store events for replay and auditing

## ⏭️ Next Steps

- Implement User Management Service
- Create API Gateway for unified access
- Add monitoring and observability
- Proceed to Exercise 4: Production-Ready Deployment

**Excellent work on implementing microservices communication! 🚀**