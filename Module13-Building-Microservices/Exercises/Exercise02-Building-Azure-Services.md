# Exercise 2: Building Azure-Ready Services

## Duration: 45 minutes

## Learning Objectives
- Create microservices designed for Azure Container Apps
- Configure services for cloud deployment
- Use Azure SQL Database
- Integrate Application Insights
- Prepare for containerization

## Prerequisites
- Completed Exercise 1
- .NET 8 SDK installed
- Visual Studio 2022 or VS Code
- Azure configuration from Exercise 1

## Part 1: Create Product Service (20 minutes)

### Step 1: Create the Project
```bash
# Navigate to module directory
cd Module13-Building-Microservices/SourceCode
mkdir AzureECommerce
cd AzureECommerce

# Create Product Service
dotnet new webapi -n ProductService
cd ProductService
```

### Step 2: Add Required NuGet Packages
```bash
# Azure and cloud-native packages
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Azure.Identity
dotnet add package Microsoft.ApplicationInsights.AspNetCore
dotnet add package Microsoft.Extensions.Diagnostics.HealthChecks.EntityFrameworkCore
```

### Step 3: Create Product Model
Create `Models/Product.cs`:
```csharp
namespace ProductService.Models;

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
    public string Category { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}

public class ProductDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
    public string Category { get; set; } = string.Empty;
}

public class UpdateInventoryRequest
{
    public int Quantity { get; set; }
}

public class ReserveProductRequest
{
    public int Quantity { get; set; }
}
```

### Step 4: Create Database Context
Create `Data/ProductDbContext.cs`:
```csharp
using Microsoft.EntityFrameworkCore;
using ProductService.Models;

namespace ProductService.Data;

public class ProductDbContext : DbContext
{
    public ProductDbContext(DbContextOptions<ProductDbContext> options)
        : base(options)
    {
    }

    public DbSet<Product> Products { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure entity
        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Price).HasColumnType("decimal(18,2)");
            entity.HasIndex(e => e.Category);
        });

        // Seed data
        modelBuilder.Entity<Product>().HasData(
            new Product 
            { 
                Id = 1, 
                Name = "Surface Laptop", 
                Description = "High-performance laptop for professionals", 
                Price = 1299.99m, 
                StockQuantity = 50,
                Category = "Electronics"
            },
            new Product 
            { 
                Id = 2, 
                Name = "Wireless Mouse", 
                Description = "Ergonomic wireless mouse", 
                Price = 49.99m, 
                StockQuantity = 200,
                Category = "Accessories"
            },
            new Product 
            { 
                Id = 3, 
                Name = "USB-C Hub", 
                Description = "7-in-1 USB-C hub", 
                Price = 79.99m, 
                StockQuantity = 150,
                Category = "Accessories"
            }
        );
    }
}
```

### Step 5: Create Product Controller
Create `Controllers/ProductsController.cs`:
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProductService.Data;
using ProductService.Models;

namespace ProductService.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly ProductDbContext _context;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(ProductDbContext context, ILogger<ProductsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetProducts([FromQuery] string? category = null)
    {
        _logger.LogInformation("Getting products. Category filter: {Category}", category);
        
        var query = _context.Products.Where(p => p.IsActive);
        
        if (!string.IsNullOrEmpty(category))
        {
            query = query.Where(p => p.Category == category);
        }

        var products = await query
            .Select(p => new ProductDto
            {
                Id = p.Id,
                Name = p.Name,
                Price = p.Price,
                StockQuantity = p.StockQuantity,
                Category = p.Category
            })
            .ToListAsync();

        return Ok(products);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Product>> GetProduct(int id)
    {
        var product = await _context.Products.FindAsync(id);
        
        if (product == null || !product.IsActive)
        {
            _logger.LogWarning("Product {ProductId} not found", id);
            return NotFound();
        }

        return Ok(product);
    }

    [HttpPost]
    public async Task<ActionResult<Product>> CreateProduct(Product product)
    {
        _logger.LogInformation("Creating new product: {ProductName}", product.Name);
        
        product.CreatedAt = DateTime.UtcNow;
        product.UpdatedAt = DateTime.UtcNow;
        
        _context.Products.Add(product);
        await _context.SaveChangesAsync();
        
        return CreatedAtAction(nameof(GetProduct), new { id = product.Id }, product);
    }

    [HttpPut("{id}/inventory")]
    public async Task<IActionResult> UpdateInventory(int id, [FromBody] UpdateInventoryRequest request)
    {
        var product = await _context.Products.FindAsync(id);
        
        if (product == null)
        {
            return NotFound();
        }

        _logger.LogInformation("Updating inventory for product {ProductId}: {OldQuantity} -> {NewQuantity}", 
            id, product.StockQuantity, request.Quantity);

        product.StockQuantity = request.Quantity;
        product.UpdatedAt = DateTime.UtcNow;
        
        await _context.SaveChangesAsync();
        
        return NoContent();
    }

    [HttpPost("{id}/reserve")]
    public async Task<ActionResult<bool>> ReserveProduct(int id, [FromBody] ReserveProductRequest request)
    {
        var product = await _context.Products.FindAsync(id);
        
        if (product == null || !product.IsActive)
        {
            return NotFound();
        }

        if (product.StockQuantity >= request.Quantity)
        {
            _logger.LogInformation("Reserving {Quantity} units of product {ProductId}", 
                request.Quantity, id);
            
            product.StockQuantity -= request.Quantity;
            product.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            
            return Ok(new { success = true, remainingStock = product.StockQuantity });
        }

        _logger.LogWarning("Insufficient stock for product {ProductId}. Requested: {Requested}, Available: {Available}", 
            id, request.Quantity, product.StockQuantity);
        
        return Ok(new { success = false, remainingStock = product.StockQuantity });
    }

    [HttpGet("health")]
    public IActionResult Health()
    {
        return Ok(new { status = "Healthy", service = "ProductService", timestamp = DateTime.UtcNow });
    }
}
```

### Step 6: Update Program.cs for Azure
Replace `Program.cs`:
```csharp
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.EntityFrameworkCore;
using ProductService.Data;

var builder = WebApplication.CreateBuilder(args);

// Add Azure Application Insights
builder.Services.AddApplicationInsightsTelemetry();

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "Product Service API", Version = "v1" });
});

// Configure database
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<ProductDbContext>(options =>
{
    options.UseSqlServer(connectionString, sqlOptions =>
    {
        sqlOptions.EnableRetryOnFailure(
            maxRetryCount: 5,
            maxRetryDelay: TimeSpan.FromSeconds(30),
            errorNumbersToAdd: null);
    });
});

// Add health checks
builder.Services.AddHealthChecks()
    .AddDbContextCheck<ProductDbContext>("database");

// Configure CORS for Azure
builder.Services.AddCors(options =>
{
    options.AddPolicy("AzurePolicy", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "Product Service API v1");
    c.RoutePrefix = string.Empty;
});

app.UseCors("AzurePolicy");
app.UseAuthorization();
app.MapControllers();
app.MapHealthChecks("/health");

// Ensure database is created and migrated
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ProductDbContext>();
    try
    {
        context.Database.EnsureCreated();
        app.Logger.LogInformation("Database initialized successfully");
    }
    catch (Exception ex)
    {
        app.Logger.LogError(ex, "Error initializing database");
    }
}

app.Logger.LogInformation("Product Service starting on port {Port}", 
    app.Configuration["ASPNETCORE_URLS"] ?? "80");

app.Run();
```

### Step 7: Create appsettings files
Update `appsettings.json`:
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Server=tcp:localhost,1433;Database=ProductDb;User Id=sa;Password=YourStrongPassword!;Encrypt=False;"
  },
  "ApplicationInsights": {
    "ConnectionString": ""
  }
}
```

Create `appsettings.Production.json`:
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Warning",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": ""
  },
  "ApplicationInsights": {
    "ConnectionString": ""
  }
}
```

### Step 8: Create Dockerfile
Create `Dockerfile`:
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ProductService.csproj", "./"]
RUN dotnet restore "ProductService.csproj"
COPY . .
RUN dotnet build "ProductService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ProductService.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create non-root user
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

ENTRYPOINT ["dotnet", "ProductService.dll"]
```

## Part 2: Create Order Service (20 minutes)

### Step 1: Create Order Service Project
```bash
cd ../..
dotnet new webapi -n OrderService
cd OrderService
```

### Step 2: Add NuGet Packages
```bash
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Azure.Identity
dotnet add package Azure.Messaging.ServiceBus
dotnet add package Microsoft.ApplicationInsights.AspNetCore
dotnet add package Microsoft.Extensions.Http.Polly
```

### Step 3: Create Models
Create `Models/Order.cs`:
```csharp
namespace OrderService.Models;

public class Order
{
    public int Id { get; set; }
    public string OrderNumber { get; set; } = string.Empty;
    public string CustomerEmail { get; set; } = string.Empty;
    public List<OrderItem> Items { get; set; } = new();
    public decimal TotalAmount { get; set; }
    public OrderStatus Status { get; set; } = OrderStatus.Pending;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}

public class OrderItem
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal TotalPrice => Quantity * UnitPrice;
}

public enum OrderStatus
{
    Pending,
    Processing,
    Confirmed,
    Shipped,
    Delivered,
    Cancelled
}

public class CreateOrderRequest
{
    public string CustomerEmail { get; set; } = string.Empty;
    public List<OrderItemRequest> Items { get; set; } = new();
}

public class OrderItemRequest
{
    public int ProductId { get; set; }
    public int Quantity { get; set; }
}

public class OrderCreatedEvent
{
    public int OrderId { get; set; }
    public string OrderNumber { get; set; } = string.Empty;
    public string CustomerEmail { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public DateTime CreatedAt { get; set; }
}
```

### Step 4: Create Services
Create `Services/ProductServiceClient.cs`:
```csharp
using System.Text.Json;
using Polly;
using Polly.CircuitBreaker;

namespace OrderService.Services;

public class ProductServiceClient
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<ProductServiceClient> _logger;

    public ProductServiceClient(HttpClient httpClient, ILogger<ProductServiceClient> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<ProductInfo?> GetProductAsync(int productId)
    {
        try
        {
            _logger.LogInformation("Fetching product {ProductId} from Product Service", productId);
            
            var response = await _httpClient.GetAsync($"api/products/{productId}");
            
            if (response.IsSuccessStatusCode)
            {
                var content = await response.Content.ReadAsStringAsync();
                return JsonSerializer.Deserialize<ProductInfo>(content, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
            }
            
            _logger.LogWarning("Product {ProductId} not found. Status: {StatusCode}", 
                productId, response.StatusCode);
            return null;
        }
        catch (BrokenCircuitException ex)
        {
            _logger.LogError(ex, "Circuit breaker open for Product Service");
            throw new ServiceUnavailableException("Product Service is currently unavailable");
        }
        catch (TaskCanceledException ex)
        {
            _logger.LogError(ex, "Timeout calling Product Service for product {ProductId}", productId);
            throw new ServiceUnavailableException("Product Service request timed out");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error calling Product Service for product {ProductId}", productId);
            throw;
        }
    }

    public async Task<ReserveProductResponse?> ReserveProductAsync(int productId, int quantity)
    {
        try
        {
            var request = new { quantity };
            var response = await _httpClient.PostAsJsonAsync($"api/products/{productId}/reserve", request);
            
            if (response.IsSuccessStatusCode)
            {
                var content = await response.Content.ReadAsStringAsync();
                return JsonSerializer.Deserialize<ReserveProductResponse>(content, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
            }
            
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error reserving product {ProductId}", productId);
            throw;
        }
    }
}

public class ProductInfo
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
}

public class ReserveProductResponse
{
    public bool Success { get; set; }
    public int RemainingStock { get; set; }
}

public class ServiceUnavailableException : Exception
{
    public ServiceUnavailableException(string message) : base(message) { }
}
```

Create `Services/MessagePublisher.cs`:
```csharp
using Azure.Messaging.ServiceBus;
using System.Text.Json;
using OrderService.Models;

namespace OrderService.Services;

public class MessagePublisher
{
    private readonly ServiceBusClient _client;
    private readonly ServiceBusSender _sender;
    private readonly ILogger<MessagePublisher> _logger;
    private readonly IConfiguration _configuration;

    public MessagePublisher(IConfiguration configuration, ILogger<MessagePublisher> logger)
    {
        _configuration = configuration;
        _logger = logger;
        
        var connectionString = _configuration["ServiceBus:ConnectionString"];
        if (!string.IsNullOrEmpty(connectionString))
        {
            _client = new ServiceBusClient(connectionString);
            _sender = _client.CreateSender("order-events");
        }
    }

    public async Task PublishOrderCreatedAsync(OrderCreatedEvent orderEvent)
    {
        if (_sender == null)
        {
            _logger.LogWarning("Service Bus not configured, skipping message publish");
            return;
        }

        try
        {
            var messageBody = JsonSerializer.Serialize(orderEvent);
            var message = new ServiceBusMessage(messageBody)
            {
                ContentType = "application/json",
                Subject = "OrderCreated"
            };

            await _sender.SendMessageAsync(message);
            _logger.LogInformation("Published OrderCreated event for order {OrderId}", orderEvent.OrderId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error publishing order event");
            // Don't throw - we don't want messaging failures to break order creation
        }
    }
}
```

### Step 5: Create Order Controller
Create `Controllers/OrdersController.cs`:
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OrderService.Data;
using OrderService.Models;
using OrderService.Services;

namespace OrderService.Controllers;

[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly OrderDbContext _context;
    private readonly ProductServiceClient _productService;
    private readonly MessagePublisher _messagePublisher;
    private readonly ILogger<OrdersController> _logger;

    public OrdersController(
        OrderDbContext context,
        ProductServiceClient productService,
        MessagePublisher messagePublisher,
        ILogger<OrdersController> logger)
    {
        _context = context;
        _productService = productService;
        _messagePublisher = messagePublisher;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Order>>> GetOrders()
    {
        return await _context.Orders
            .Include(o => o.Items)
            .OrderByDescending(o => o.CreatedAt)
            .Take(50)
            .ToListAsync();
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Order>> GetOrder(int id)
    {
        var order = await _context.Orders
            .Include(o => o.Items)
            .FirstOrDefaultAsync(o => o.Id == id);

        if (order == null)
        {
            return NotFound();
        }

        return order;
    }

    [HttpPost]
    public async Task<ActionResult<Order>> CreateOrder(CreateOrderRequest request)
    {
        using var transaction = await _context.Database.BeginTransactionAsync();
        
        try
        {
            var order = new Order
            {
                OrderNumber = $"ORD-{DateTime.UtcNow:yyyyMMdd}-{Guid.NewGuid().ToString()[..8].ToUpper()}",
                CustomerEmail = request.CustomerEmail,
                Status = OrderStatus.Pending
            };

            // Validate and reserve products
            foreach (var item in request.Items)
            {
                // Get product details
                var product = await _productService.GetProductAsync(item.ProductId);
                if (product == null)
                {
                    return BadRequest(new { error = $"Product {item.ProductId} not found" });
                }

                // Reserve inventory
                var reserveResult = await _productService.ReserveProductAsync(item.ProductId, item.Quantity);
                if (reserveResult == null || !reserveResult.Success)
                {
                    return BadRequest(new 
                    { 
                        error = $"Insufficient stock for {product.Name}",
                        availableStock = reserveResult?.RemainingStock ?? 0
                    });
                }

                order.Items.Add(new OrderItem
                {
                    ProductId = product.Id,
                    ProductName = product.Name,
                    Quantity = item.Quantity,
                    UnitPrice = product.Price
                });
            }

            // Calculate total and save
            order.TotalAmount = order.Items.Sum(i => i.TotalPrice);
            order.Status = OrderStatus.Confirmed;

            _context.Orders.Add(order);
            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            _logger.LogInformation("Created order {OrderNumber} for {CustomerEmail}", 
                order.OrderNumber, order.CustomerEmail);

            // Publish event (fire and forget)
            _ = _messagePublisher.PublishOrderCreatedAsync(new OrderCreatedEvent
            {
                OrderId = order.Id,
                OrderNumber = order.OrderNumber,
                CustomerEmail = order.CustomerEmail,
                TotalAmount = order.TotalAmount,
                CreatedAt = order.CreatedAt
            });

            return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
        }
        catch (ServiceUnavailableException ex)
        {
            await transaction.RollbackAsync();
            return StatusCode(503, new { error = ex.Message });
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync();
            _logger.LogError(ex, "Error creating order");
            return StatusCode(500, new { error = "An error occurred while creating the order" });
        }
    }

    [HttpPut("{id}/status")]
    public async Task<IActionResult> UpdateOrderStatus(int id, [FromBody] OrderStatus status)
    {
        var order = await _context.Orders.FindAsync(id);
        if (order == null)
        {
            return NotFound();
        }

        order.Status = status;
        order.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        _logger.LogInformation("Updated order {OrderId} status to {Status}", id, status);
        return NoContent();
    }

    [HttpGet("health")]
    public IActionResult Health()
    {
        return Ok(new { status = "Healthy", service = "OrderService", timestamp = DateTime.UtcNow });
    }
}
```

### Step 6: Create Database Context
Create `Data/OrderDbContext.cs`:
```csharp
using Microsoft.EntityFrameworkCore;
using OrderService.Models;

namespace OrderService.Data;

public class OrderDbContext : DbContext
{
    public OrderDbContext(DbContextOptions<OrderDbContext> options)
        : base(options)
    {
    }

    public DbSet<Order> Orders { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Order>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.OrderNumber).IsRequired().HasMaxLength(50);
            entity.Property(e => e.CustomerEmail).IsRequired().HasMaxLength(200);
            entity.Property(e => e.TotalAmount).HasColumnType("decimal(18,2)");
            entity.HasIndex(e => e.OrderNumber).IsUnique();
            entity.HasIndex(e => e.CustomerEmail);
        });

        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.UnitPrice).HasColumnType("decimal(18,2)");
            entity.HasOne<Order>()
                .WithMany(o => o.Items)
                .HasForeignKey(e => e.OrderId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
```

### Step 7: Update Program.cs
Replace `Program.cs`:
```csharp
using Microsoft.EntityFrameworkCore;
using OrderService.Data;
using OrderService.Services;
using Polly;
using Polly.Extensions.Http;

var builder = WebApplication.CreateBuilder(args);

// Add Application Insights
builder.Services.AddApplicationInsightsTelemetry();

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "Order Service API", Version = "v1" });
});

// Configure database
builder.Services.AddDbContext<OrderDbContext>(options =>
{
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"),
        sqlOptions =>
        {
            sqlOptions.EnableRetryOnFailure(
                maxRetryCount: 5,
                maxRetryDelay: TimeSpan.FromSeconds(30),
                errorNumbersToAdd: null);
        });
});

// Configure HTTP client for Product Service
builder.Services.AddHttpClient<ProductServiceClient>(client =>
{
    var baseUrl = builder.Configuration["Services:ProductService"] ?? "http://product-service";
    client.BaseAddress = new Uri(baseUrl);
    client.Timeout = TimeSpan.FromSeconds(10);
})
.AddPolicyHandler(GetRetryPolicy())
.AddPolicyHandler(GetCircuitBreakerPolicy());

// Add message publisher
builder.Services.AddSingleton<MessagePublisher>();

// Add health checks
builder.Services.AddHealthChecks()
    .AddDbContextCheck<OrderDbContext>("database");

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AzurePolicy", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure pipeline
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "Order Service API v1");
    c.RoutePrefix = string.Empty;
});

app.UseCors("AzurePolicy");
app.UseAuthorization();
app.MapControllers();
app.MapHealthChecks("/health");

// Initialize database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<OrderDbContext>();
    try
    {
        context.Database.EnsureCreated();
        app.Logger.LogInformation("Database initialized successfully");
    }
    catch (Exception ex)
    {
        app.Logger.LogError(ex, "Error initializing database");
    }
}

app.Run();

// Resilience policies
static IAsyncPolicy<HttpResponseMessage> GetRetryPolicy()
{
    return HttpPolicyExtensions
        .HandleTransientHttpError()
        .OrResult(msg => !msg.IsSuccessStatusCode)
        .WaitAndRetryAsync(
            3,
            retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)),
            onRetry: (outcome, timespan, retryCount, context) =>
            {
                Console.WriteLine($"Retry {retryCount} after {timespan} seconds");
            });
}

static IAsyncPolicy<HttpResponseMessage> GetCircuitBreakerPolicy()
{
    return HttpPolicyExtensions
        .HandleTransientHttpError()
        .CircuitBreakerAsync(
            5,
            TimeSpan.FromSeconds(30));
}
```

### Step 8: Create Dockerfile for Order Service
Create `Dockerfile`:
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["OrderService.csproj", "./"]
RUN dotnet restore "OrderService.csproj"
COPY . .
RUN dotnet build "OrderService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "OrderService.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create non-root user
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

ENTRYPOINT ["dotnet", "OrderService.dll"]
```

## Part 3: Test Locally (5 minutes)

### Option 1: Using SQL Server in Docker (if you have Docker)
```bash
# Run SQL Server locally for testing
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourStrongPassword!" -p 1433:1433 -d mcr.microsoft.com/mssql/server:2022-latest
```

### Option 2: Use LocalDB (Windows only)
Update connection strings to use LocalDB:
```json
"ConnectionStrings": {
  "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=ProductDb;Trusted_Connection=True;"
}
```

### Test the services:
```bash
# Terminal 1 - Run Product Service
cd ProductService
dotnet run

# Terminal 2 - Run Order Service  
cd OrderService
dotnet run
```

Visit:
- Product Service: https://localhost:5001
- Order Service: https://localhost:5002

## Summary

You've now created two microservices that are:
- ✅ Designed for Azure Container Apps
- ✅ Using Azure SQL Database (connection string configured)
- ✅ Integrated with Application Insights
- ✅ Implementing resilience patterns
- ✅ Ready for containerization

## Next Steps
In Exercise 3, we'll deploy these services to Azure Container Apps!