# Microservices Design Patterns

## 🎯 Overview
This guide covers essential microservices design patterns that solve common challenges in distributed systems. Understanding these patterns is crucial for building resilient, scalable, and maintainable microservices architectures.

## 🏗️ Decomposition Patterns

### Database per Service
**Problem**: How to define database architecture for microservices?
**Solution**: Each service owns its private database and can only be accessed via the service's API.

**Benefits**:
- Services are loosely coupled
- Each service can use the database technology best suited for its needs
- Data schema can evolve independently

**Drawbacks**:
- Implementing queries that join data from multiple services is complex
- Managing transactions across services requires careful design

**Implementation**:
```csharp
// Product Service - owns product data
public class ProductService
{
    private readonly ProductDbContext _context;
    
    public async Task<Product> GetProductAsync(Guid id)
    {
        return await _context.Products.FindAsync(id);
    }
}

// Order Service - references products by ID only
public class Order
{
    public Guid Id { get; set; }
    public Guid ProductId { get; set; } // Reference, not foreign key
    public string ProductName { get; set; } // Denormalized data
    public decimal ProductPrice { get; set; } // Snapshot at order time
}
```

### Decompose by Business Capability
**Problem**: How to decompose an application into services?
**Solution**: Define services corresponding to business capabilities.

**Example**: E-commerce decomposition
- **Product Catalog** - Product information, categories, inventory
- **Order Management** - Order processing, fulfillment
- **Customer Management** - Customer accounts, profiles
- **Payment Processing** - Payment handling, billing
- **Shipping & Delivery** - Logistics, tracking

### Decompose by Subdomain
**Problem**: How to decompose an application using Domain-Driven Design?
**Solution**: Define services corresponding to DDD subdomains.

**Core Subdomains** (competitive advantage):
- Product recommendation engine
- Pricing optimization
- Fraud detection

**Supporting Subdomains** (necessary but not differentiating):
- User management
- Notification system
- Reporting

**Generic Subdomains** (commodity):
- Authentication
- Payment processing
- Email services

## 🔄 Data Management Patterns

### Saga Pattern
**Problem**: How to maintain data consistency across services without distributed transactions?
**Solution**: Use a sequence of local transactions coordinated by a saga.

#### Orchestration-based Saga
```csharp
public class OrderSaga
{
    public async Task ProcessOrderAsync(Order order)
    {
        try
        {
            // Step 1: Reserve inventory
            await _inventoryService.ReserveItemsAsync(order.Items);
            
            // Step 2: Process payment
            await _paymentService.ProcessPaymentAsync(order.Payment);
            
            // Step 3: Arrange shipping
            await _shippingService.ArrangeShippingAsync(order.Shipping);
            
            // Step 4: Confirm order
            await _orderService.ConfirmOrderAsync(order.Id);
        }
        catch (Exception ex)
        {
            // Compensate in reverse order
            await CompensateAsync(order);
        }
    }
    
    private async Task CompensateAsync(Order order)
    {
        await _shippingService.CancelShippingAsync(order.Id);
        await _paymentService.RefundPaymentAsync(order.Payment);
        await _inventoryService.ReleaseItemsAsync(order.Items);
        await _orderService.CancelOrderAsync(order.Id);
    }
}
```

#### Choreography-based Saga
```csharp
// Order Service publishes event
public async Task CreateOrderAsync(CreateOrderRequest request)
{
    var order = new Order(request);
    await _repository.SaveAsync(order);
    
    await _eventBus.PublishAsync(new OrderCreatedEvent
    {
        OrderId = order.Id,
        Items = order.Items,
        CustomerId = order.CustomerId
    });
}

// Inventory Service reacts to event
public class InventoryEventHandler : IEventHandler<OrderCreatedEvent>
{
    public async Task HandleAsync(OrderCreatedEvent @event)
    {
        try
        {
            await _inventoryService.ReserveItemsAsync(@event.Items);
            
            await _eventBus.PublishAsync(new InventoryReservedEvent
            {
                OrderId = @event.OrderId,
                Items = @event.Items
            });
        }
        catch (InsufficientStockException)
        {
            await _eventBus.PublishAsync(new InventoryReservationFailedEvent
            {
                OrderId = @event.OrderId,
                Reason = "Insufficient stock"
            });
        }
    }
}
```

### Event Sourcing
**Problem**: How to reliably publish events when state changes?
**Solution**: Store events instead of current state, then replay events to rebuild state.

```csharp
public abstract class Event
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    public int Version { get; set; }
}

public class ProductCreatedEvent : Event
{
    public Guid ProductId { get; set; }
    public string Name { get; set; }
    public decimal Price { get; set; }
}

public class ProductAggregate
{
    private readonly List<Event> _events = new();
    
    public Guid Id { get; private set; }
    public string Name { get; private set; }
    public decimal Price { get; private set; }
    public int Version { get; private set; }
    
    public void CreateProduct(string name, decimal price)
    {
        var @event = new ProductCreatedEvent
        {
            ProductId = Guid.NewGuid(),
            Name = name,
            Price = price,
            Version = Version + 1
        };
        
        Apply(@event);
        _events.Add(@event);
    }
    
    public void Apply(ProductCreatedEvent @event)
    {
        Id = @event.ProductId;
        Name = @event.Name;
        Price = @event.Price;
        Version = @event.Version;
    }
    
    public IEnumerable<Event> GetUncommittedEvents() => _events;
    public void MarkEventsAsCommitted() => _events.Clear();
}
```

### CQRS (Command Query Responsibility Segregation)
**Problem**: How to implement queries in an event-sourced application?
**Solution**: Separate command and query models.

```csharp
// Command side - handles writes
public class CreateProductCommand
{
    public string Name { get; set; }
    public decimal Price { get; set; }
    public string Category { get; set; }
}

public class ProductCommandHandler
{
    public async Task HandleAsync(CreateProductCommand command)
    {
        var product = new ProductAggregate();
        product.CreateProduct(command.Name, command.Price);
        
        await _eventStore.SaveEventsAsync(product.Id, product.GetUncommittedEvents());
        product.MarkEventsAsCommitted();
    }
}

// Query side - handles reads
public class ProductQueryModel
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public decimal Price { get; set; }
    public string Category { get; set; }
    public DateTime CreatedDate { get; set; }
}

public class ProductQueryHandler
{
    public async Task<ProductQueryModel> GetProductAsync(Guid id)
    {
        return await _queryDatabase.Products
            .Where(p => p.Id == id)
            .FirstOrDefaultAsync();
    }
}

// Projection - updates query model from events
public class ProductProjection : IEventHandler<ProductCreatedEvent>
{
    public async Task HandleAsync(ProductCreatedEvent @event)
    {
        var queryModel = new ProductQueryModel
        {
            Id = @event.ProductId,
            Name = @event.Name,
            Price = @event.Price,
            CreatedDate = @event.Timestamp
        };
        
        await _queryDatabase.Products.AddAsync(queryModel);
        await _queryDatabase.SaveChangesAsync();
    }
}
```

## 🌐 Communication Patterns

### API Gateway
**Problem**: How do clients access individual services?
**Solution**: Implement a gateway that provides a single entry point for all clients.

**Features**:
- Request routing
- Request/response transformation
- Authentication and authorization
- Rate limiting
- Request/response logging
- Load balancing

```csharp
// YARP configuration
{
  "ReverseProxy": {
    "Routes": {
      "products": {
        "ClusterId": "products",
        "Match": {
          "Path": "/api/products/{**catch-all}"
        },
        "Transforms": [
          {
            "PathPattern": "/api/products/{**catch-all}"
          }
        ]
      }
    },
    "Clusters": {
      "products": {
        "Destinations": {
          "destination1": {
            "Address": "http://product-service:80/"
          }
        }
      }
    }
  }
}
```

### Service Registry and Discovery
**Problem**: How do services find and communicate with each other?
**Solution**: Use a service registry where services register themselves and discover others.

```csharp
public interface IServiceRegistry
{
    Task RegisterAsync(ServiceInstance instance);
    Task DeregisterAsync(string serviceId);
    Task<List<ServiceInstance>> DiscoverAsync(string serviceName);
}

public class ServiceInstance
{
    public string Id { get; set; }
    public string Name { get; set; }
    public string Host { get; set; }
    public int Port { get; set; }
    public Dictionary<string, string> Metadata { get; set; }
}

// Service registration on startup
public class Startup
{
    public void Configure(IApplicationBuilder app, IServiceRegistry registry)
    {
        var instance = new ServiceInstance
        {
            Id = Guid.NewGuid().ToString(),
            Name = "product-service",
            Host = Environment.MachineName,
            Port = 80
        };
        
        registry.RegisterAsync(instance);
        
        // Deregister on shutdown
        var lifetime = app.ApplicationServices.GetService<IHostApplicationLifetime>();
        lifetime.ApplicationStopping.Register(() => 
        {
            registry.DeregisterAsync(instance.Id);
        });
    }
}
```

### Circuit Breaker
**Problem**: How to prevent cascade failures when a service is failing?
**Solution**: Monitor failures and "trip" to prevent calls to failing service.

```csharp
public class CircuitBreakerService<T>
{
    private CircuitBreakerState _state = CircuitBreakerState.Closed;
    private int _failureCount = 0;
    private DateTime _lastFailureTime = DateTime.MinValue;
    private readonly int _failureThreshold = 5;
    private readonly TimeSpan _recoveryTimeout = TimeSpan.FromMinutes(1);

    public async Task<T> ExecuteAsync(Func<Task<T>> operation)
    {
        if (_state == CircuitBreakerState.Open)
        {
            if (DateTime.UtcNow - _lastFailureTime >= _recoveryTimeout)
            {
                _state = CircuitBreakerState.HalfOpen;
            }
            else
            {
                throw new CircuitBreakerOpenException();
            }
        }

        try
        {
            var result = await operation();
            OnSuccess();
            return result;
        }
        catch (Exception ex)
        {
            OnFailure();
            throw;
        }
    }

    private void OnSuccess()
    {
        _failureCount = 0;
        _state = CircuitBreakerState.Closed;
    }

    private void OnFailure()
    {
        _failureCount++;
        _lastFailureTime = DateTime.UtcNow;

        if (_failureCount >= _failureThreshold)
        {
            _state = CircuitBreakerState.Open;
        }
    }
}

public enum CircuitBreakerState
{
    Closed,
    Open,
    HalfOpen
}
```

## 🔒 Security Patterns

### Access Token
**Problem**: How to communicate client identity to services?
**Solution**: Pass access token in requests.

```csharp
public class JwtAuthenticationMiddleware
{
    public async Task InvokeAsync(HttpContext context, RequestDelegate next)
    {
        var token = ExtractToken(context.Request);
        
        if (!string.IsNullOrEmpty(token))
        {
            var principal = ValidateToken(token);
            context.User = principal;
        }
        
        await next(context);
    }
    
    private ClaimsPrincipal ValidateToken(string token)
    {
        var tokenHandler = new JwtSecurityTokenHandler();
        var validationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = _jwtSettings.Issuer,
            ValidAudience = _jwtSettings.Audience,
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(_jwtSettings.SecretKey))
        };
        
        return tokenHandler.ValidateToken(token, validationParameters, out _);
    }
}
```

## 📊 Observability Patterns

### Distributed Tracing
**Problem**: How to trace requests across multiple services?
**Solution**: Assign unique trace ID to each request and propagate it.

```csharp
public class TracingMiddleware
{
    public async Task InvokeAsync(HttpContext context, RequestDelegate next)
    {
        var traceId = context.Request.Headers["X-Trace-ID"].FirstOrDefault() 
                     ?? Guid.NewGuid().ToString();
        
        context.Response.Headers.Add("X-Trace-ID", traceId);
        
        using var activity = Activity.StartActivity("HTTP Request");
        activity?.SetTag("trace.id", traceId);
        activity?.SetTag("http.method", context.Request.Method);
        activity?.SetTag("http.url", context.Request.Path);
        
        await next(context);
        
        activity?.SetTag("http.status_code", context.Response.StatusCode);
    }
}

// Propagate trace ID to downstream services
public class TracingHttpClientHandler : DelegatingHandler
{
    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var activity = Activity.Current;
        if (activity != null)
        {
            request.Headers.Add("X-Trace-ID", activity.GetTagItem("trace.id")?.ToString());
        }
        
        return await base.SendAsync(request, cancellationToken);
    }
}
```

### Health Check API
**Problem**: How to monitor service health?
**Solution**: Implement health check endpoints.

```csharp
public class HealthCheckExtensions
{
    public static IServiceCollection AddCustomHealthChecks(
        this IServiceCollection services, IConfiguration configuration)
    {
        services.AddHealthChecks()
            .AddDbContext<ApplicationDbContext>()
            .AddRabbitMQ(configuration.GetConnectionString("RabbitMQ"))
            .AddUrlGroup(new Uri(configuration["ExternalServices:PaymentService"]), "payment-service")
            .AddCheck<CustomHealthCheck>("custom-check");
            
        return services;
    }
}

public class CustomHealthCheck : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        try
        {
            // Perform custom health check logic
            var isHealthy = await CheckExternalDependencyAsync();
            
            if (isHealthy)
            {
                return HealthCheckResult.Healthy("Service is healthy");
            }
            
            return HealthCheckResult.Degraded("Service is degraded");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy("Service is unhealthy", ex);
        }
    }
}
```

## 🎯 Best Practices

### Pattern Selection Guidelines

1. **Start Simple**: Begin with fewer services and split later
2. **Business Alignment**: Align services with business capabilities
3. **Team Structure**: Services should match team boundaries (Conway's Law)
4. **Data Consistency**: Choose appropriate consistency model for each use case
5. **Failure Handling**: Design for failure from the beginning
6. **Monitoring**: Implement comprehensive observability

### Common Anti-Patterns to Avoid

1. **Distributed Monolith**: Services too tightly coupled
2. **Chatty Interfaces**: Too many service-to-service calls
3. **Shared Database**: Multiple services sharing the same database
4. **Synchronous Communication Everywhere**: Overusing synchronous calls
5. **Missing Circuit Breakers**: No protection against cascade failures
6. **Inadequate Monitoring**: Poor observability into system behavior

### Implementation Order

1. **Domain Modeling**: Identify bounded contexts and services
2. **Data Architecture**: Design database per service
3. **API Design**: Define service contracts
4. **Communication**: Implement sync and async communication
5. **Resilience**: Add circuit breakers, retries, timeouts
6. **Security**: Implement authentication and authorization
7. **Observability**: Add logging, metrics, and tracing
8. **Deployment**: Containerize and orchestrate services

## 🔗 Additional Resources

- [Microservices.io Patterns](https://microservices.io/patterns/)
- [Microsoft .NET Microservices Guide](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/)
- [Building Microservices by Sam Newman](https://samnewman.io/books/building_microservices/)
- [Microservices Patterns by Chris Richardson](https://microservices.io/book)
- [Domain-Driven Design by Eric Evans](https://domainlanguage.com/ddd/)

---

*Remember: Patterns are tools to solve specific problems. Choose the right pattern for your context, not because it's trendy or because other companies use it.*