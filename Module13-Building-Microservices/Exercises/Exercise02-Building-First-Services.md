# Exercise 2: Building Your First Microservices

## Duration: 45 minutes

## Learning Objectives
- Create two independent ASP.NET Core services
- Containerize services with Docker
- Run multiple services with Docker Compose
- Test service endpoints independently

## Prerequisites
- Docker Desktop installed and running
- .NET 8 SDK installed
- Basic knowledge of ASP.NET Core Web API

## Part 1: Create the Product Service (15 minutes)

### Step 1: Create Product Service Project
```bash
cd Module13-Building-Microservices/SourceCode/SimpleECommerce
mkdir ProductService
cd ProductService
dotnet new webapi -n ProductService
cd ProductService
```

### Step 2: Add Product Model
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
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
```

### Step 3: Add Database Context
Install Entity Framework:
```bash
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Design
```

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
        // Seed some data
        modelBuilder.Entity<Product>().HasData(
            new Product 
            { 
                Id = 1, 
                Name = "Laptop", 
                Description = "High-performance laptop", 
                Price = 999.99m, 
                StockQuantity = 10,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            },
            new Product 
            { 
                Id = 2, 
                Name = "Mouse", 
                Description = "Wireless mouse", 
                Price = 29.99m, 
                StockQuantity = 50,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            }
        );
    }
}
```

### Step 4: Create Product Controller
Replace `Controllers/WeatherForecastController.cs` with `Controllers/ProductsController.cs`:
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
    public async Task<ActionResult<IEnumerable<Product>>> GetProducts()
    {
        _logger.LogInformation("Getting all products");
        return await _context.Products.ToListAsync();
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Product>> GetProduct(int id)
    {
        var product = await _context.Products.FindAsync(id);
        if (product == null)
        {
            _logger.LogWarning($"Product with id {id} not found");
            return NotFound();
        }
        return product;
    }

    [HttpPost]
    public async Task<ActionResult<Product>> CreateProduct(Product product)
    {
        product.CreatedAt = DateTime.UtcNow;
        product.UpdatedAt = DateTime.UtcNow;
        
        _context.Products.Add(product);
        await _context.SaveChangesAsync();
        
        _logger.LogInformation($"Created product: {product.Name}");
        return CreatedAtAction(nameof(GetProduct), new { id = product.Id }, product);
    }

    [HttpPut("{id}/inventory")]
    public async Task<IActionResult> UpdateInventory(int id, [FromBody] int quantity)
    {
        var product = await _context.Products.FindAsync(id);
        if (product == null)
        {
            return NotFound();
        }

        product.StockQuantity = quantity;
        product.UpdatedAt = DateTime.UtcNow;
        
        await _context.SaveChangesAsync();
        
        _logger.LogInformation($"Updated inventory for {product.Name}: {quantity}");
        return NoContent();
    }

    [HttpPost("{id}/reserve")]
    public async Task<ActionResult<bool>> ReserveProduct(int id, [FromBody] int quantity)
    {
        var product = await _context.Products.FindAsync(id);
        if (product == null)
        {
            return NotFound();
        }

        if (product.StockQuantity >= quantity)
        {
            product.StockQuantity -= quantity;
            product.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            
            _logger.LogInformation($"Reserved {quantity} of {product.Name}");
            return Ok(true);
        }

        _logger.LogWarning($"Insufficient stock for {product.Name}");
        return Ok(false);
    }
}
```

### Step 5: Update Program.cs
```csharp
using Microsoft.EntityFrameworkCore;
using ProductService.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add database
builder.Services.AddDbContext<ProductDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

var app = builder.Build();

// Configure pipeline
app.UseSwagger();
app.UseSwaggerUI();

app.UseAuthorization();
app.MapControllers();

// Ensure database is created
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ProductDbContext>();
    context.Database.EnsureCreated();
}

app.Run();
```

### Step 6: Create Dockerfile
Create `Dockerfile` in ProductService folder:
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ProductService.csproj", "./"]
RUN dotnet restore "ProductService.csproj"
COPY . .
RUN dotnet build "ProductService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ProductService.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ProductService.dll"]
```

## Part 2: Create the Order Service (15 minutes)

### Step 1: Create Order Service Project
```bash
cd ../../
mkdir OrderService
cd OrderService
dotnet new webapi -n OrderService
cd OrderService
```

### Step 2: Add Models
Create `Models/Order.cs`:
```csharp
namespace OrderService.Models;

public class Order
{
    public int Id { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public List<OrderItem> Items { get; set; } = new();
    public decimal TotalAmount { get; set; }
    public string Status { get; set; } = "Pending";
    public DateTime CreatedAt { get; set; }
}

public class OrderItem
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal Price { get; set; }
}

public class CreateOrderRequest
{
    public string CustomerName { get; set; } = string.Empty;
    public List<OrderItemRequest> Items { get; set; } = new();
}

public class OrderItemRequest
{
    public int ProductId { get; set; }
    public int Quantity { get; set; }
}
```

### Step 3: Add Product Service Client
Create `Services/ProductServiceClient.cs`:
```csharp
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

    public async Task<ProductDto?> GetProductAsync(int productId)
    {
        try
        {
            var response = await _httpClient.GetAsync($"api/products/{productId}");
            if (response.IsSuccessStatusCode)
            {
                return await response.Content.ReadFromJsonAsync<ProductDto>();
            }
            _logger.LogWarning($"Product {productId} not found");
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error getting product {productId}");
            return null;
        }
    }

    public async Task<bool> ReserveProductAsync(int productId, int quantity)
    {
        try
        {
            var response = await _httpClient.PostAsJsonAsync(
                $"api/products/{productId}/reserve", 
                quantity);
            
            if (response.IsSuccessStatusCode)
            {
                return await response.Content.ReadFromJsonAsync<bool>();
            }
            return false;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error reserving product {productId}");
            return false;
        }
    }
}

public class ProductDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
}
```

### Step 4: Create Order Controller
Replace the default controller with `Controllers/OrdersController.cs`:
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
    private readonly ILogger<OrdersController> _logger;

    public OrdersController(
        OrderDbContext context, 
        ProductServiceClient productService,
        ILogger<OrdersController> logger)
    {
        _context = context;
        _productService = productService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Order>>> GetOrders()
    {
        return await _context.Orders
            .Include(o => o.Items)
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
        var order = new Order
        {
            CustomerName = request.CustomerName,
            CreatedAt = DateTime.UtcNow,
            Status = "Pending"
        };

        // Validate and reserve products
        foreach (var item in request.Items)
        {
            // Get product details from Product Service
            var product = await _productService.GetProductAsync(item.ProductId);
            if (product == null)
            {
                return BadRequest($"Product {item.ProductId} not found");
            }

            // Try to reserve the product
            var reserved = await _productService.ReserveProductAsync(
                item.ProductId, 
                item.Quantity);
            
            if (!reserved)
            {
                return BadRequest($"Insufficient stock for product {product.Name}");
            }

            order.Items.Add(new OrderItem
            {
                ProductId = product.Id,
                ProductName = product.Name,
                Quantity = item.Quantity,
                Price = product.Price
            });
        }

        // Calculate total
        order.TotalAmount = order.Items.Sum(i => i.Price * i.Quantity);
        order.Status = "Confirmed";

        _context.Orders.Add(order);
        await _context.SaveChangesAsync();

        _logger.LogInformation($"Created order {order.Id} for {order.CustomerName}");
        return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
    }
}
```

### Step 5: Add Database Context
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
}
```

### Step 6: Update Program.cs
```csharp
using Microsoft.EntityFrameworkCore;
using OrderService.Data;
using OrderService.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add database
builder.Services.AddDbContext<OrderDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add Product Service client
builder.Services.AddHttpClient<ProductServiceClient>(client =>
{
    client.BaseAddress = new Uri(builder.Configuration["Services:ProductService"] 
        ?? "http://localhost:5001");
});

var app = builder.Build();

// Configure pipeline
app.UseSwagger();
app.UseSwaggerUI();

app.UseAuthorization();
app.MapControllers();

// Ensure database is created
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<OrderDbContext>();
    context.Database.EnsureCreated();
}

app.Run();
```

### Step 7: Create Dockerfile
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["OrderService.csproj", "./"]
RUN dotnet restore "OrderService.csproj"
COPY . .
RUN dotnet build "OrderService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "OrderService.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "OrderService.dll"]
```

## Part 3: Run with Docker Compose (15 minutes)

### Step 1: Verify docker-compose.yml
The docker-compose.yml file should already exist in the SimpleECommerce folder. It orchestrates:
- Product Service
- Order Service  
- SQL Server database

### Step 2: Build and Run
```bash
cd ../..  # Go to SimpleECommerce folder
docker-compose up --build
```

### Step 3: Test the Services

1. **Test Product Service**:
   - Open http://localhost:5001/swagger
   - Try GET /api/products to see seeded products
   - Create a new product with POST /api/products

2. **Test Order Service**:
   - Open http://localhost:5002/swagger
   - Create an order with POST /api/orders:
   ```json
   {
     "customerName": "John Doe",
     "items": [
       {
         "productId": 1,
         "quantity": 2
       }
     ]
   }
   ```

3. **Verify Communication**:
   - Check Product Service logs for reservation calls
   - Try to order more items than in stock
   - See how the Order Service handles Product Service errors

## Troubleshooting

### Common Issues:
1. **Port already in use**: Change ports in docker-compose.yml
2. **Database connection failed**: Wait a few seconds for SQL Server to start
3. **Service communication fails**: Check service names in configuration

### Useful Commands:
```bash
# View logs
docker-compose logs product-service
docker-compose logs order-service

# Restart services
docker-compose restart

# Clean up
docker-compose down -v
```

## Key Takeaways

✅ **What You've Learned**:
1. Each service is independent with its own database
2. Services communicate via HTTP/REST
3. Docker Compose orchestrates multiple services
4. Services can fail independently

❓ **Think About**:
1. What happens if Product Service is down?
2. How would you handle partial failures?
3. How would you add a third service?

## Next Steps
In Exercise 3, we'll improve service communication and add error handling!