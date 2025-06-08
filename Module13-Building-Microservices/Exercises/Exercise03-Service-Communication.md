# Exercise 3: Service Communication and Resilience

## Duration: 45 minutes

## Learning Objectives
- Implement resilient service communication
- Handle service failures gracefully
- Add retry logic and circuit breakers
- Implement health checks
- Add basic logging and monitoring

## Prerequisites
- Completed Exercise 2
- Services running with Docker Compose
- Basic understanding of HTTP communication

## Part 1: Understanding Service Communication Challenges (10 minutes)

### Common Issues in Microservices Communication
1. **Network Failures**: Services may be temporarily unreachable
2. **Service Downtime**: Services may be updating or crashed
3. **Timeouts**: Slow responses can block operations
4. **Cascading Failures**: One service failure affects others

### Resilience Patterns We'll Implement
- **Retry**: Try again if a request fails
- **Circuit Breaker**: Stop calling a failing service
- **Timeout**: Don't wait forever for a response
- **Fallback**: Provide alternative responses

## Part 2: Add Resilience to Order Service (20 minutes)

### Step 1: Install Polly for Resilience
Navigate to the Order Service and add Polly:
```bash
cd OrderService/OrderService
dotnet add package Microsoft.Extensions.Http.Polly
```

### Step 2: Update ProductServiceClient with Resilience
Update `Services/ProductServiceClient.cs`:
```csharp
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

    public async Task<ProductDto?> GetProductAsync(int productId)
    {
        try
        {
            _logger.LogInformation($"Getting product {productId} from Product Service");
            
            var response = await _httpClient.GetAsync($"api/products/{productId}");
            
            if (response.IsSuccessStatusCode)
            {
                var product = await response.Content.ReadFromJsonAsync<ProductDto>();
                _logger.LogInformation($"Successfully retrieved product {productId}");
                return product;
            }
            
            _logger.LogWarning($"Product {productId} not found. Status: {response.StatusCode}");
            return null;
        }
        catch (BrokenCircuitException ex)
        {
            _logger.LogError(ex, "Circuit breaker is open for Product Service");
            throw new ServiceUnavailableException("Product Service is currently unavailable");
        }
        catch (TaskCanceledException ex)
        {
            _logger.LogError(ex, $"Timeout getting product {productId}");
            throw new ServiceUnavailableException("Product Service request timed out");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error getting product {productId}");
            throw new ServiceUnavailableException("Error communicating with Product Service");
        }
    }

    public async Task<bool> ReserveProductAsync(int productId, int quantity)
    {
        try
        {
            _logger.LogInformation($"Reserving {quantity} units of product {productId}");
            
            var response = await _httpClient.PostAsJsonAsync(
                $"api/products/{productId}/reserve", 
                quantity);
            
            if (response.IsSuccessStatusCode)
            {
                var result = await response.Content.ReadFromJsonAsync<bool>();
                _logger.LogInformation($"Reservation result for product {productId}: {result}");
                return result;
            }
            
            _logger.LogWarning($"Failed to reserve product {productId}. Status: {response.StatusCode}");
            return false;
        }
        catch (BrokenCircuitException ex)
        {
            _logger.LogError(ex, "Circuit breaker is open for Product Service");
            throw new ServiceUnavailableException("Product Service is currently unavailable");
        }
        catch (TaskCanceledException ex)
        {
            _logger.LogError(ex, $"Timeout reserving product {productId}");
            throw new ServiceUnavailableException("Product Service request timed out");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error reserving product {productId}");
            throw new ServiceUnavailableException("Error communicating with Product Service");
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

public class ServiceUnavailableException : Exception
{
    public ServiceUnavailableException(string message) : base(message) { }
}
```

### Step 3: Configure Resilience Policies in Program.cs
Update the Order Service `Program.cs`:
```csharp
using Microsoft.EntityFrameworkCore;
using OrderService.Data;
using OrderService.Services;
using Polly;
using Polly.Extensions.Http;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add database
builder.Services.AddDbContext<OrderDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add Product Service client with resilience
builder.Services.AddHttpClient<ProductServiceClient>(client =>
{
    client.BaseAddress = new Uri(builder.Configuration["Services:ProductService"] 
        ?? "http://localhost:5001");
    client.Timeout = TimeSpan.FromSeconds(10); // Overall timeout
})
.AddPolicyHandler(GetRetryPolicy())
.AddPolicyHandler(GetCircuitBreakerPolicy());

// Add health checks
builder.Services.AddHealthChecks()
    .AddDbContextCheck<OrderDbContext>("database")
    .AddUrlGroup(new Uri($"{builder.Configuration["Services:ProductService"]}/health"), 
        "product-service");

var app = builder.Build();

// Configure pipeline
app.UseSwagger();
app.UseSwaggerUI();

app.MapHealthChecks("/health");
app.UseAuthorization();
app.MapControllers();

// Ensure database is created
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<OrderDbContext>();
    context.Database.EnsureCreated();
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
                var logger = context.Values.ContainsKey("logger") 
                    ? context.Values["logger"] as ILogger 
                    : null;
                logger?.LogWarning($"Retry {retryCount} after {timespan} seconds");
            });
}

static IAsyncPolicy<HttpResponseMessage> GetCircuitBreakerPolicy()
{
    return HttpPolicyExtensions
        .HandleTransientHttpError()
        .CircuitBreakerAsync(
            5,
            TimeSpan.FromSeconds(30),
            onBreak: (result, timespan) =>
            {
                Console.WriteLine($"Circuit breaker opened for {timespan}");
            },
            onReset: () =>
            {
                Console.WriteLine("Circuit breaker reset");
            });
}
```

### Step 4: Update Orders Controller with Better Error Handling
Update `Controllers/OrdersController.cs`:
```csharp
[HttpPost]
public async Task<ActionResult<Order>> CreateOrder(CreateOrderRequest request)
{
    try
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
            try
            {
                // Get product details from Product Service
                var product = await _productService.GetProductAsync(item.ProductId);
                if (product == null)
                {
                    return BadRequest(new 
                    { 
                        error = "Product not found",
                        productId = item.ProductId 
                    });
                }

                // Try to reserve the product
                var reserved = await _productService.ReserveProductAsync(
                    item.ProductId, 
                    item.Quantity);
                
                if (!reserved)
                {
                    return BadRequest(new 
                    { 
                        error = "Insufficient stock",
                        product = product.Name,
                        requested = item.Quantity,
                        available = product.StockQuantity
                    });
                }

                order.Items.Add(new OrderItem
                {
                    ProductId = product.Id,
                    ProductName = product.Name,
                    Quantity = item.Quantity,
                    Price = product.Price
                });
            }
            catch (ServiceUnavailableException ex)
            {
                _logger.LogError(ex, "Product Service is unavailable");
                return StatusCode(503, new 
                { 
                    error = "Product Service is currently unavailable",
                    message = "Please try again later"
                });
            }
        }

        // Calculate total
        order.TotalAmount = order.Items.Sum(i => i.Price * i.Quantity);
        order.Status = "Confirmed";

        _context.Orders.Add(order);
        await _context.SaveChangesAsync();

        _logger.LogInformation($"Created order {order.Id} for {order.CustomerName}");
        return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Unexpected error creating order");
        return StatusCode(500, new { error = "An unexpected error occurred" });
    }
}
```

## Part 3: Add Health Checks (10 minutes)

### Step 1: Add Health Check to Product Service
Update Product Service `Program.cs`:
```csharp
// Add this after builder.Services.AddSwaggerGen();
builder.Services.AddHealthChecks()
    .AddDbContextCheck<ProductDbContext>("database");

// Add this after app.UseAuthorization();
app.MapHealthChecks("/health");
```

### Step 2: Create a Simple Health Dashboard
Create `SourceCode/SimpleECommerce/health-check.html`:
```html
<!DOCTYPE html>
<html>
<head>
    <title>Microservices Health Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .service { 
            border: 1px solid #ddd; 
            padding: 10px; 
            margin: 10px 0; 
            border-radius: 5px;
        }
        .healthy { background-color: #d4edda; border-color: #c3e6cb; }
        .unhealthy { background-color: #f8d7da; border-color: #f5c6cb; }
        .status { font-weight: bold; }
    </style>
</head>
<body>
    <h1>Microservices Health Dashboard</h1>
    <div id="services"></div>
    
    <script>
        const services = [
            { name: 'Product Service', url: 'http://localhost:5001/health' },
            { name: 'Order Service', url: 'http://localhost:5002/health' }
        ];

        async function checkHealth() {
            const container = document.getElementById('services');
            container.innerHTML = '';
            
            for (const service of services) {
                const div = document.createElement('div');
                div.className = 'service';
                
                try {
                    const response = await fetch(service.url);
                    const isHealthy = response.ok;
                    
                    div.className += isHealthy ? ' healthy' : ' unhealthy';
                    div.innerHTML = `
                        <h3>${service.name}</h3>
                        <p class="status">Status: ${isHealthy ? 'Healthy' : 'Unhealthy'}</p>
                        <p>Endpoint: ${service.url}</p>
                    `;
                } catch (error) {
                    div.className += ' unhealthy';
                    div.innerHTML = `
                        <h3>${service.name}</h3>
                        <p class="status">Status: Unreachable</p>
                        <p>Error: ${error.message}</p>
                    `;
                }
                
                container.appendChild(div);
            }
        }

        // Check health every 5 seconds
        checkHealth();
        setInterval(checkHealth, 5000);
    </script>
</body>
</html>
```

## Part 4: Testing Resilience (15 minutes)

### Test 1: Normal Operation
1. Ensure all services are running:
   ```bash
   docker-compose up --build
   ```

2. Create a successful order:
   ```bash
   curl -X POST http://localhost:5002/api/orders \
     -H "Content-Type: application/json" \
     -d '{
       "customerName": "Test User",
       "items": [{
         "productId": 1,
         "quantity": 1
       }]
     }'
   ```

### Test 2: Product Service Down
1. Stop the Product Service:
   ```bash
   docker-compose stop product-service
   ```

2. Try to create an order:
   - You should see retry attempts in the logs
   - After retries fail, circuit breaker opens
   - Order Service returns 503 Service Unavailable

3. Start Product Service again:
   ```bash
   docker-compose start product-service
   ```

### Test 3: Slow Product Service
1. Add a delay to Product Service (temporarily modify ProductsController):
   ```csharp
   [HttpGet("{id}")]
   public async Task<ActionResult<Product>> GetProduct(int id)
   {
       // Simulate slow response
       await Task.Delay(15000); // 15 seconds
       
       var product = await _context.Products.FindAsync(id);
       if (product == null)
       {
           return NotFound();
       }
       return product;
   }
   ```

2. Try to create an order - it should timeout after 10 seconds

### Test 4: Health Check Dashboard
1. Open `health-check.html` in a browser
2. Stop/start services and watch the dashboard update

## Key Concepts Demonstrated

✅ **Resilience Patterns**:
- Retry with exponential backoff
- Circuit breaker to prevent cascading failures
- Timeouts to prevent hanging requests
- Health checks for monitoring

✅ **Service Communication**:
- Graceful degradation when services fail
- Clear error messages for different failure types
- Logging for debugging and monitoring

## Exercises for Further Learning

1. **Add Caching**: Cache product information to reduce calls
2. **Implement Fallback**: Return cached data when Product Service is down
3. **Add Metrics**: Count successful/failed requests
4. **Implement Saga**: Handle order cancellation across services

## Summary

You've learned how to:
- Handle service failures gracefully
- Implement retry and circuit breaker patterns
- Add health checks for monitoring
- Test resilience scenarios

These patterns are essential for production microservices!