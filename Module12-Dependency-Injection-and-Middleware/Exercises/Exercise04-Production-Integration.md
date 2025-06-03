# Exercise 4: Production Integration

## 🎯 **Objective**
Integrate dependency injection and middleware in a realistic production-ready application with comprehensive error handling, monitoring, health checks, and environment-specific configuration.

## ⏱️ **Estimated Time**
35 minutes

## 📋 **Prerequisites**
- Completion of Exercises 1-3
- Understanding of production application concerns
- Basic knowledge of health checks and monitoring
- Familiarity with environment-specific configuration

## 🎓 **Learning Outcomes**
- Build a complete layered application architecture
- Implement comprehensive middleware pipeline for production
- Add health checks and application monitoring
- Configure different environments (Development, Staging, Production)
- Implement performance monitoring and optimization
- Handle configuration validation and service validation

## 📝 **Exercise Tasks**

### **Task 1: Create Layered Application Architecture** (10 minutes)

Build a complete e-commerce order processing system:

```csharp
// Domain/Entities/Order.cs
public class Order
{
    public int Id { get; set; }
    public string CustomerId { get; set; } = string.Empty;
    public DateTime OrderDate { get; set; }
    public OrderStatus Status { get; set; }
    public decimal TotalAmount { get; set; }
    public List<OrderItem> Items { get; set; } = new();
}

public class OrderItem
{
    public int Id { get; set; }
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
    Shipped,
    Delivered,
    Cancelled
}

// Domain/Interfaces/IOrderRepository.cs
public interface IOrderRepository
{
    Task<Order?> GetByIdAsync(int id);
    Task<IEnumerable<Order>> GetByCustomerIdAsync(string customerId);
    Task<Order> CreateAsync(Order order);
    Task UpdateAsync(Order order);
    Task<bool> ExistsAsync(int id);
}

// Domain/Interfaces/IInventoryService.cs
public interface IInventoryService
{
    Task<bool> IsAvailableAsync(int productId, int quantity);
    Task ReserveItemsAsync(int productId, int quantity);
    Task ReleaseItemsAsync(int productId, int quantity);
}

// Domain/Interfaces/IPaymentService.cs
public interface IPaymentService
{
    Task<PaymentResult> ProcessPaymentAsync(decimal amount, string customerId);
}

public class PaymentResult
{
    public bool Success { get; set; }
    public string TransactionId { get; set; } = string.Empty;
    public string ErrorMessage { get; set; } = string.Empty;
}

// Infrastructure/Repositories/OrderRepository.cs
public class OrderRepository : IOrderRepository
{
    private readonly Dictionary<int, Order> _orders = new();
    private readonly ILogger<OrderRepository> _logger;
    private int _nextId = 1;

    public OrderRepository(ILogger<OrderRepository> logger)
    {
        _logger = logger;
    }

    public Task<Order?> GetByIdAsync(int id)
    {
        _logger.LogDebug("Retrieving order {OrderId}", id);
        _orders.TryGetValue(id, out var order);
        return Task.FromResult(order);
    }

    public Task<IEnumerable<Order>> GetByCustomerIdAsync(string customerId)
    {
        _logger.LogDebug("Retrieving orders for customer {CustomerId}", customerId);
        var customerOrders = _orders.Values.Where(o => o.CustomerId == customerId);
        return Task.FromResult(customerOrders);
    }

    public Task<Order> CreateAsync(Order order)
    {
        order.Id = _nextId++;
        order.OrderDate = DateTime.UtcNow;
        _orders[order.Id] = order;
        
        _logger.LogInformation("Created order {OrderId} for customer {CustomerId} with total {Total:C}", 
            order.Id, order.CustomerId, order.TotalAmount);
        
        return Task.FromResult(order);
    }

    public Task UpdateAsync(Order order)
    {
        _orders[order.Id] = order;
        _logger.LogInformation("Updated order {OrderId} status to {Status}", order.Id, order.Status);
        return Task.CompletedTask;
    }

    public Task<bool> ExistsAsync(int id)
    {
        return Task.FromResult(_orders.ContainsKey(id));
    }
}

// Infrastructure/Services/InventoryService.cs
public class InventoryService : IInventoryService
{
    private readonly Dictionary<int, int> _inventory = new()
    {
        { 1, 100 }, { 2, 50 }, { 3, 25 }, { 4, 0 }, { 5, 200 }
    };
    private readonly ILogger<InventoryService> _logger;

    public InventoryService(ILogger<InventoryService> logger)
    {
        _logger = logger;
    }

    public Task<bool> IsAvailableAsync(int productId, int quantity)
    {
        var available = _inventory.GetValueOrDefault(productId, 0) >= quantity;
        _logger.LogDebug("Inventory check for product {ProductId}: requested {Quantity}, available: {Available}", 
            productId, quantity, available);
        return Task.FromResult(available);
    }

    public Task ReserveItemsAsync(int productId, int quantity)
    {
        if (_inventory.ContainsKey(productId))
        {
            _inventory[productId] = Math.Max(0, _inventory[productId] - quantity);
            _logger.LogInformation("Reserved {Quantity} items of product {ProductId}", quantity, productId);
        }
        return Task.CompletedTask;
    }

    public Task ReleaseItemsAsync(int productId, int quantity)
    {
        if (_inventory.ContainsKey(productId))
        {
            _inventory[productId] += quantity;
            _logger.LogInformation("Released {Quantity} items of product {ProductId}", quantity, productId);
        }
        return Task.CompletedTask;
    }
}

// Infrastructure/Services/PaymentService.cs
public class PaymentService : IPaymentService
{
    private readonly ILogger<PaymentService> _logger;
    private readonly Random _random = new();

    public PaymentService(ILogger<PaymentService> logger)
    {
        _logger = logger;
    }

    public async Task<PaymentResult> ProcessPaymentAsync(decimal amount, string customerId)
    {
        _logger.LogInformation("Processing payment of {Amount:C} for customer {CustomerId}", amount, customerId);
        
        // Simulate payment processing delay
        await Task.Delay(500);
        
        // Simulate 90% success rate
        var success = _random.NextDouble() > 0.1;
        
        var result = new PaymentResult
        {
            Success = success,
            TransactionId = success ? Guid.NewGuid().ToString() : string.Empty,
            ErrorMessage = success ? string.Empty : "Payment declined by bank"
        };
        
        if (success)
        {
            _logger.LogInformation("Payment successful: {TransactionId}", result.TransactionId);
        }
        else
        {
            _logger.LogWarning("Payment failed for customer {CustomerId}: {Error}", customerId, result.ErrorMessage);
        }
        
        return result;
    }
}

// Business/Services/OrderService.cs
public interface IOrderService
{
    Task<Order> CreateOrderAsync(CreateOrderRequest request);
    Task<Order?> GetOrderAsync(int orderId);
    Task<IEnumerable<Order>> GetCustomerOrdersAsync(string customerId);
    Task UpdateOrderStatusAsync(int orderId, OrderStatus status);
}

public class CreateOrderRequest
{
    public string CustomerId { get; set; } = string.Empty;
    public List<CreateOrderItemRequest> Items { get; set; } = new();
}

public class CreateOrderItemRequest
{
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
}

public class OrderService : IOrderService
{
    private readonly IOrderRepository _orderRepository;
    private readonly IInventoryService _inventoryService;
    private readonly IPaymentService _paymentService;
    private readonly ILogger<OrderService> _logger;

    public OrderService(
        IOrderRepository orderRepository,
        IInventoryService inventoryService,
        IPaymentService paymentService,
        ILogger<OrderService> logger)
    {
        _orderRepository = orderRepository;
        _inventoryService = inventoryService;
        _paymentService = paymentService;
        _logger = logger;
    }

    public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
    {
        _logger.LogInformation("Creating order for customer {CustomerId} with {ItemCount} items", 
            request.CustomerId, request.Items.Count);

        // Validate inventory availability
        foreach (var item in request.Items)
        {
            var available = await _inventoryService.IsAvailableAsync(item.ProductId, item.Quantity);
            if (!available)
            {
                throw new InvalidOperationException($"Insufficient inventory for product {item.ProductId}");
            }
        }

        // Create order
        var order = new Order
        {
            CustomerId = request.CustomerId,
            Status = OrderStatus.Pending,
            Items = request.Items.Select(i => new OrderItem
            {
                ProductId = i.ProductId,
                ProductName = i.ProductName,
                Quantity = i.Quantity,
                UnitPrice = i.UnitPrice
            }).ToList()
        };

        order.TotalAmount = order.Items.Sum(i => i.TotalPrice);

        // Process payment
        var paymentResult = await _paymentService.ProcessPaymentAsync(order.TotalAmount, order.CustomerId);
        
        if (!paymentResult.Success)
        {
            _logger.LogWarning("Payment failed for order: {Error}", paymentResult.ErrorMessage);
            throw new InvalidOperationException($"Payment failed: {paymentResult.ErrorMessage}");
        }

        // Reserve inventory
        foreach (var item in order.Items)
        {
            await _inventoryService.ReserveItemsAsync(item.ProductId, item.Quantity);
        }

        // Create order
        order.Status = OrderStatus.Processing;
        var createdOrder = await _orderRepository.CreateAsync(order);

        _logger.LogInformation("Order {OrderId} created successfully for customer {CustomerId}", 
            createdOrder.Id, createdOrder.CustomerId);

        return createdOrder;
    }

    public async Task<Order?> GetOrderAsync(int orderId)
    {
        return await _orderRepository.GetByIdAsync(orderId);
    }

    public async Task<IEnumerable<Order>> GetCustomerOrdersAsync(string customerId)
    {
        return await _orderRepository.GetByCustomerIdAsync(customerId);
    }

    public async Task UpdateOrderStatusAsync(int orderId, OrderStatus status)
    {
        var order = await _orderRepository.GetByIdAsync(orderId);
        if (order == null)
        {
            throw new ArgumentException($"Order {orderId} not found");
        }

        order.Status = status;
        await _orderRepository.UpdateAsync(order);
        
        _logger.LogInformation("Order {OrderId} status updated to {Status}", orderId, status);
    }
}
```

### **Task 2: Implement Production Middleware Pipeline** (10 minutes)

Create a comprehensive middleware pipeline for production:

```csharp
// Middleware/ApplicationMetricsMiddleware.cs
public class ApplicationMetricsMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ApplicationMetricsMiddleware> _logger;
    private static readonly Dictionary<string, int> _requestCounts = new();
    private static readonly Dictionary<string, List<double>> _responseTimes = new();

    public ApplicationMetricsMiddleware(RequestDelegate next, ILogger<ApplicationMetricsMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        var endpoint = GetEndpoint(context);

        try
        {
            await _next(context);
        }
        finally
        {
            stopwatch.Stop();
            
            // Track metrics
            lock (_requestCounts)
            {
                _requestCounts[endpoint] = _requestCounts.GetValueOrDefault(endpoint, 0) + 1;
                
                if (!_responseTimes.ContainsKey(endpoint))
                    _responseTimes[endpoint] = new List<double>();
                
                _responseTimes[endpoint].Add(stopwatch.ElapsedMilliseconds);
                
                // Keep only last 100 response times
                if (_responseTimes[endpoint].Count > 100)
                {
                    _responseTimes[endpoint].RemoveAt(0);
                }
            }

            // Log slow requests
            if (stopwatch.ElapsedMilliseconds > 1000)
            {
                _logger.LogWarning("Slow request detected: {Endpoint} took {Duration}ms", 
                    endpoint, stopwatch.ElapsedMilliseconds);
            }
        }
    }

    private string GetEndpoint(HttpContext context)
    {
        return $"{context.Request.Method} {context.Request.Path}";
    }

    public static Dictionary<string, object> GetMetrics()
    {
        lock (_requestCounts)
        {
            var metrics = new Dictionary<string, object>();
            
            foreach (var kvp in _requestCounts)
            {
                var responseTimes = _responseTimes.GetValueOrDefault(kvp.Key, new List<double>());
                metrics[kvp.Key] = new
                {
                    RequestCount = kvp.Value,
                    AverageResponseTime = responseTimes.Any() ? responseTimes.Average() : 0,
                    MaxResponseTime = responseTimes.Any() ? responseTimes.Max() : 0,
                    MinResponseTime = responseTimes.Any() ? responseTimes.Min() : 0
                };
            }
            
            return metrics;
        }
    }
}

// Middleware/SecurityHeadersMiddleware.cs
public class SecurityHeadersMiddleware
{
    private readonly RequestDelegate _next;

    public SecurityHeadersMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Add security headers
        context.Response.Headers.Add("X-Frame-Options", "DENY");
        context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
        context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
        context.Response.Headers.Add("Referrer-Policy", "strict-origin-when-cross-origin");
        context.Response.Headers.Add("Content-Security-Policy", 
            "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'");

        await _next(context);
    }
}

// Health/OrderSystemHealthCheck.cs
public class OrderSystemHealthCheck : IHealthCheck
{
    private readonly IOrderRepository _orderRepository;
    private readonly IInventoryService _inventoryService;
    private readonly IPaymentService _paymentService;
    private readonly ILogger<OrderSystemHealthCheck> _logger;

    public OrderSystemHealthCheck(
        IOrderRepository orderRepository,
        IInventoryService inventoryService,
        IPaymentService paymentService,
        ILogger<OrderSystemHealthCheck> logger)
    {
        _orderRepository = orderRepository;
        _inventoryService = inventoryService;
        _paymentService = paymentService;
        _logger = logger;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context, 
        CancellationToken cancellationToken = default)
    {
        try
        {
            var checks = new List<Task<bool>>
            {
                CheckOrderRepository(),
                CheckInventoryService(),
                CheckPaymentService()
            };

            var results = await Task.WhenAll(checks);
            var allHealthy = results.All(r => r);

            if (allHealthy)
            {
                return HealthCheckResult.Healthy("All order system components are healthy");
            }
            else
            {
                return HealthCheckResult.Degraded("Some order system components are not healthy");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Health check failed");
            return HealthCheckResult.Unhealthy("Order system health check failed", ex);
        }
    }

    private async Task<bool> CheckOrderRepository()
    {
        try
        {
            // Test basic repository functionality
            await _orderRepository.ExistsAsync(-1); // This should not throw
            return true;
        }
        catch
        {
            return false;
        }
    }

    private async Task<bool> CheckInventoryService()
    {
        try
        {
            await _inventoryService.IsAvailableAsync(1, 1);
            return true;
        }
        catch
        {
            return false;
        }
    }

    private async Task<bool> CheckPaymentService()
    {
        try
        {
            // Don't actually process a payment, just check if service is responsive
            // In a real scenario, you might call a health endpoint on the payment service
            await Task.Delay(1); // Placeholder for actual health check
            return true;
        }
        catch
        {
            return false;
        }
    }
}
```

### **Task 3: Environment-Specific Configuration** (8 minutes)

Configure different environments with appropriate settings:

```csharp
// Configuration/ApplicationSettings.cs
public class ApplicationSettings
{
    public DatabaseSettings Database { get; set; } = new();
    public LoggingSettings Logging { get; set; } = new();
    public SecuritySettings Security { get; set; } = new();
    public PerformanceSettings Performance { get; set; } = new();
    public HealthCheckSettings HealthChecks { get; set; } = new();
}

public class DatabaseSettings
{
    public string ConnectionString { get; set; } = string.Empty;
    public int CommandTimeout { get; set; } = 30;
    public bool EnableRetry { get; set; } = true;
    public int MaxRetryAttempts { get; set; } = 3;
}

public class LoggingSettings
{
    public string MinimumLevel { get; set; } = "Information";
    public bool EnableStructuredLogging { get; set; } = true;
    public bool EnableFileLogging { get; set; } = false;
    public string FilePath { get; set; } = "logs/app.log";
}

public class SecuritySettings
{
    public bool RequireHttps { get; set; } = false;
    public bool EnableSecurityHeaders { get; set; } = true;
    public string[] AllowedOrigins { get; set; } = Array.Empty<string>();
}

public class PerformanceSettings
{
    public bool EnableResponseCaching { get; set; } = false;
    public bool EnableCompression { get; set; } = true;
    public int RequestTimeoutSeconds { get; set; } = 30;
    public bool EnableMetrics { get; set; } = true;
}

public class HealthCheckSettings
{
    public bool Enabled { get; set; } = true;
    public int TimeoutSeconds { get; set; } = 10;
    public string[] Tags { get; set; } = Array.Empty<string>();
}
```

### **Task 4: Complete Application Setup** (7 minutes)

Wire everything together in Program.cs:

```csharp
// Program.cs
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

// Configuration
var appSettings = builder.Configuration.GetSection("Application").Get<ApplicationSettings>() 
                  ?? new ApplicationSettings();

// Register configuration
builder.Services.AddSingleton(appSettings);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register application services
builder.Services.AddScoped<IOrderRepository, OrderRepository>();
builder.Services.AddScoped<IInventoryService, InventoryService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();
builder.Services.AddScoped<IOrderService, OrderService>();

// Add health checks
if (appSettings.HealthChecks.Enabled)
{
    builder.Services.AddHealthChecks()
        .AddCheck<OrderSystemHealthCheck>("order-system",
            timeout: TimeSpan.FromSeconds(appSettings.HealthChecks.TimeoutSeconds),
            tags: appSettings.HealthChecks.Tags);
}

// Add HTTP context accessor for accessing request context in services
builder.Services.AddHttpContextAccessor();

var app = builder.Build();

// Configure middleware pipeline based on environment and settings
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
else
{
    // Production error handling
    app.UseExceptionHandler("/error");
}

// Security headers (configurable)
if (appSettings.Security.EnableSecurityHeaders)
{
    app.UseMiddleware<SecurityHeadersMiddleware>();
}

// HTTPS redirection (configurable)
if (appSettings.Security.RequireHttps)
{
    app.UseHttpsRedirection();
}

// Performance monitoring (configurable)
if (appSettings.Performance.EnableMetrics)
{
    app.UseMiddleware<ApplicationMetricsMiddleware>();
}

// Standard middleware
app.UseRouting();
app.UseAuthorization();

// Health checks endpoint
if (appSettings.HealthChecks.Enabled)
{
    app.MapHealthChecks("/health", new HealthCheckOptions
    {
        ResponseWriter = async (context, report) =>
        {
            context.Response.ContentType = "application/json";
            var response = new
            {
                status = report.Status.ToString(),
                checks = report.Entries.Select(x => new
                {
                    name = x.Key,
                    status = x.Value.Status.ToString(),
                    description = x.Value.Description,
                    duration = x.Value.Duration.ToString()
                }),
                totalDuration = report.TotalDuration.ToString()
            };
            await context.Response.WriteAsync(JsonSerializer.Serialize(response));
        }
    });

    // Detailed health check for operations team
    app.MapHealthChecks("/health/detailed", new HealthCheckOptions
    {
        Predicate = _ => true,
        ResponseWriter = async (context, report) =>
        {
            context.Response.ContentType = "application/json";
            var response = new
            {
                status = report.Status.ToString(),
                timestamp = DateTime.UtcNow,
                checks = report.Entries.Select(x => new
                {
                    name = x.Key,
                    status = x.Value.Status.ToString(),
                    description = x.Value.Description,
                    duration = x.Value.Duration.ToString(),
                    exception = x.Value.Exception?.Message,
                    data = x.Value.Data
                }),
                totalDuration = report.TotalDuration.ToString(),
                environment = app.Environment.EnvironmentName,
                version = "1.0.0" // In real app, get from assembly
            };
            await context.Response.WriteAsync(JsonSerializer.Serialize(response));
        }
    });
}

// Metrics endpoint
app.MapGet("/metrics", () =>
{
    var metrics = ApplicationMetricsMiddleware.GetMetrics();
    return Results.Ok(new
    {
        timestamp = DateTime.UtcNow,
        environment = app.Environment.EnvironmentName,
        metrics = metrics
    });
});

// Controllers
app.MapControllers();

// Error handling endpoint for production
app.Map("/error", () => Results.Problem("An error occurred processing your request."));

app.Run();
```

### **Complete Controller Implementation**:

```csharp
// Controllers/OrdersController.cs
[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly IOrderService _orderService;
    private readonly ILogger<OrdersController> _logger;

    public OrdersController(IOrderService orderService, ILogger<OrdersController> logger)
    {
        _orderService = orderService;
        _logger = logger;
    }

    [HttpPost]
    public async Task<ActionResult<Order>> CreateOrder([FromBody] CreateOrderRequest request)
    {
        try
        {
            _logger.LogInformation("Creating order for customer {CustomerId}", request.CustomerId);
            
            var order = await _orderService.CreateOrderAsync(request);
            
            return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning("Order creation failed: {Error}", ex.Message);
            return BadRequest(new { error = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error creating order");
            return StatusCode(500, new { error = "An unexpected error occurred" });
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Order>> GetOrder(int id)
    {
        var order = await _orderService.GetOrderAsync(id);
        
        if (order == null)
        {
            return NotFound(new { error = $"Order {id} not found" });
        }
        
        return Ok(order);
    }

    [HttpGet("customer/{customerId}")]
    public async Task<ActionResult<IEnumerable<Order>>> GetCustomerOrders(string customerId)
    {
        var orders = await _orderService.GetCustomerOrdersAsync(customerId);
        return Ok(orders);
    }

    [HttpPut("{id}/status")]
    public async Task<IActionResult> UpdateOrderStatus(int id, [FromBody] UpdateOrderStatusRequest request)
    {
        try
        {
            await _orderService.UpdateOrderStatusAsync(id, request.Status);
            return NoContent();
        }
        catch (ArgumentException ex)
        {
            return NotFound(new { error = ex.Message });
        }
    }
}

public class UpdateOrderStatusRequest
{
    public OrderStatus Status { get; set; }
}

// Controllers/SystemController.cs
[ApiController]
[Route("api/[controller]")]
public class SystemController : ControllerBase
{
    private readonly ApplicationSettings _settings;
    private readonly IWebHostEnvironment _environment;
    private readonly ILogger<SystemController> _logger;

    public SystemController(
        ApplicationSettings settings, 
        IWebHostEnvironment environment,
        ILogger<SystemController> logger)
    {
        _settings = settings;
        _environment = environment;
        _logger = logger;
    }

    [HttpGet("info")]
    public IActionResult GetSystemInfo()
    {
        return Ok(new
        {
            environment = _environment.EnvironmentName,
            version = "1.0.0",
            timestamp = DateTime.UtcNow,
            features = new
            {
                healthChecks = _settings.HealthChecks.Enabled,
                metrics = _settings.Performance.EnableMetrics,
                securityHeaders = _settings.Security.EnableSecurityHeaders,
                httpsRequired = _settings.Security.RequireHttps
            }
        });
    }

    [HttpGet("config")]
    public IActionResult GetConfiguration()
    {
        // Only show configuration in development
        if (!_environment.IsDevelopment())
        {
            return Forbid();
        }

        return Ok(new
        {
            database = new
            {
                timeout = _settings.Database.CommandTimeout,
                retryEnabled = _settings.Database.EnableRetry,
                maxRetries = _settings.Database.MaxRetryAttempts
            },
            performance = _settings.Performance,
            security = new
            {
                httpsRequired = _settings.Security.RequireHttps,
                securityHeaders = _settings.Security.EnableSecurityHeaders,
                allowedOrigins = _settings.Security.AllowedOrigins
            },
            healthChecks = _settings.HealthChecks
        });
    }
}
```

## 🔍 **Expected Results**

### **Application Architecture**:
- ✅ Clean separation of concerns with layered architecture
- ✅ Proper dependency injection throughout all layers
- ✅ Repository pattern with clean interfaces
- ✅ Business logic encapsulated in services
- ✅ Comprehensive error handling and logging

### **Production Middleware Pipeline**:
- ✅ Security headers added to all responses
- ✅ Application metrics collected automatically
- ✅ Performance monitoring with slow request detection
- ✅ Health checks for all critical dependencies
- ✅ Environment-specific behavior

### **Configuration Management**:
- ✅ Different settings for different environments
- ✅ Type-safe configuration binding
- ✅ Feature toggles based on configuration
- ✅ Secure configuration handling

### **Monitoring and Observability**:
- ✅ Health check endpoints with detailed information
- ✅ Application metrics endpoint
- ✅ Structured logging throughout the application
- ✅ Performance monitoring and alerting

## 🧪 **Testing Scenarios**

### **Test 1: Order Creation Flow**
```bash
# Create a successful order
curl -X POST "http://localhost:5000/api/orders" \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": "customer123",
    "items": [
      {
        "productId": 1,
        "productName": "Laptop",
        "quantity": 1,
        "unitPrice": 999.99
      }
    ]
  }'

# Try to create an order with insufficient inventory
curl -X POST "http://localhost:5000/api/orders" \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": "customer123",
    "items": [
      {
        "productId": 4,
        "productName": "Out of Stock Item",
        "quantity": 1,
        "unitPrice": 50.00
      }
    ]
  }'
```

### **Test 2: Health Checks**
```bash
# Basic health check
curl -X GET "http://localhost:5000/health"

# Detailed health check
curl -X GET "http://localhost:5000/health/detailed"
```

### **Test 3: Metrics and Monitoring**
```bash
# Get application metrics
curl -X GET "http://localhost:5000/metrics"

# Get system information
curl -X GET "http://localhost:5000/api/system/info"

# Get configuration (development only)
curl -X GET "http://localhost:5000/api/system/config"
```

### **Test 4: Performance Testing**
```bash
# Generate load to test metrics collection
for i in {1..50}; do
  curl -X GET "http://localhost:5000/api/orders/1" &
done
wait

# Check metrics after load
curl -X GET "http://localhost:5000/metrics"
```

## 🎯 **Success Criteria**

**You've successfully completed this exercise when you can**:
- ✅ Demonstrate clean architectural separation with proper DI
- ✅ Show environment-specific configuration working correctly
- ✅ Prove health checks are monitoring all dependencies
- ✅ Display application metrics and performance data
- ✅ Handle errors gracefully with proper logging
- ✅ Configure security headers and HTTPS redirection
- ✅ Switch between development and production behaviors

## 📊 **Production Readiness Checklist**

### **Architecture & Design**:
- ✅ Layered architecture with clear separation
- ✅ Dependency injection configured properly
- ✅ Repository pattern implemented
- ✅ Service layer encapsulates business logic
- ✅ Error handling strategy implemented

### **Security**:
- ✅ Security headers configured
- ✅ HTTPS redirection in production
- ✅ Input validation on all endpoints
- ✅ Secure configuration management
- ✅ No sensitive data in logs

### **Monitoring & Observability**:
- ✅ Health checks for all dependencies
- ✅ Application metrics collection
- ✅ Structured logging throughout
- ✅ Performance monitoring
- ✅ Error tracking and alerting

### **Performance**:
- ✅ Response time monitoring
- ✅ Slow query detection
- ✅ Resource usage tracking
- ✅ Caching strategy (where applicable)
- ✅ Connection pooling configured

### **Configuration & Deployment**:
- ✅ Environment-specific settings
- ✅ Feature flags implemented
- ✅ Configuration validation
- ✅ Deployment health checks
- ✅ Graceful shutdown handling

## 🎯 **Module Completion**

**Congratulations!** You've successfully completed Module 12 by:

✅ **Mastering Dependency Injection**: Understanding service lifetimes, advanced patterns, and best practices

✅ **Building Production Middleware**: Creating comprehensive middleware pipelines for cross-cutting concerns

✅ **Implementing Advanced Patterns**: Factory, decorator, and repository patterns with DI

✅ **Production Integration**: Combining all concepts in a realistic, production-ready application

### **Key Achievements**:
- Built a complete layered architecture
- Implemented comprehensive monitoring and health checks
- Created environment-specific configurations
- Established production-ready error handling
- Demonstrated scalable and maintainable design patterns

### **Ready for Next Steps**:
- **Module 13**: Building Microservices (applying these patterns at scale)
- **Advanced Architecture**: Event-driven systems, CQRS, Domain-Driven Design
- **Cloud Native Development**: Kubernetes, service mesh, observability
- **Performance Engineering**: Advanced optimization and scaling techniques

---

**🚀 You now have the foundation to build enterprise-grade ASP.NET Core applications!**