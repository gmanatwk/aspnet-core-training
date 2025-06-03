# Exercise 3: Advanced DI Patterns

## 🎯 **Objective**
Master advanced dependency injection patterns including factory pattern, decorator pattern, multiple implementations, and configuration-driven service selection.

## ⏱️ **Estimated Time**
30 minutes

## 📋 **Prerequisites**
- Completion of Exercise 1 (Service Lifetimes)
- Understanding of design patterns (Factory, Decorator)
- Familiarity with interfaces and generics in C#
- Basic knowledge of configuration in ASP.NET Core

## 🎓 **Learning Outcomes**
- Implement the Factory pattern with dependency injection
- Use the Decorator pattern to enhance service functionality
- Handle multiple implementations of the same interface
- Create generic services and repositories
- Use configuration to drive service selection
- Resolve circular dependencies

## 📝 **Exercise Tasks**

### **Task 1: Factory Pattern Implementation** (8 minutes)

Create a notification system that can send different types of notifications:

```csharp
// INotificationService.cs
public interface INotificationService
{
    Task SendAsync(string recipient, string subject, string message);
    string NotificationType { get; }
}

// EmailNotificationService.cs
public class EmailNotificationService : INotificationService
{
    private readonly ILogger<EmailNotificationService> _logger;
    
    public EmailNotificationService(ILogger<EmailNotificationService> logger)
    {
        _logger = logger;
    }
    
    public string NotificationType => "Email";

    public async Task SendAsync(string recipient, string subject, string message)
    {
        _logger.LogInformation("Sending email to {Recipient}: {Subject}", recipient, subject);
        
        // Simulate email sending
        await Task.Delay(100);
        
        _logger.LogInformation("Email sent successfully to {Recipient}", recipient);
    }
}

// SmsNotificationService.cs
public class SmsNotificationService : INotificationService
{
    private readonly ILogger<SmsNotificationService> _logger;
    
    public SmsNotificationService(ILogger<SmsNotificationService> logger)
    {
        _logger = logger;
    }
    
    public string NotificationType => "SMS";

    public async Task SendAsync(string recipient, string subject, string message)
    {
        _logger.LogInformation("Sending SMS to {Recipient}: {Message}", recipient, message);
        
        // Simulate SMS sending
        await Task.Delay(50);
        
        _logger.LogInformation("SMS sent successfully to {Recipient}", recipient);
    }
}

// PushNotificationService.cs
public class PushNotificationService : INotificationService
{
    private readonly ILogger<PushNotificationService> _logger;
    
    public PushNotificationService(ILogger<PushNotificationService> logger)
    {
        _logger = logger;
    }
    
    public string NotificationType => "Push";

    public async Task SendAsync(string recipient, string subject, string message)
    {
        _logger.LogInformation("Sending push notification to {Recipient}: {Subject}", recipient, subject);
        
        // Simulate push notification
        await Task.Delay(25);
        
        _logger.LogInformation("Push notification sent successfully to {Recipient}", recipient);
    }
}

// INotificationFactory.cs
public interface INotificationFactory
{
    INotificationService CreateNotificationService(NotificationType type);
    IEnumerable<INotificationService> GetAllNotificationServices();
}

public enum NotificationType
{
    Email,
    SMS,
    Push
}

// NotificationFactory.cs
public class NotificationFactory : INotificationFactory
{
    private readonly IServiceProvider _serviceProvider;

    public NotificationFactory(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public INotificationService CreateNotificationService(NotificationType type)
    {
        return type switch
        {
            NotificationType.Email => _serviceProvider.GetRequiredService<EmailNotificationService>(),
            NotificationType.SMS => _serviceProvider.GetRequiredService<SmsNotificationService>(),
            NotificationType.Push => _serviceProvider.GetRequiredService<PushNotificationService>(),
            _ => throw new ArgumentException($"Unsupported notification type: {type}")
        };
    }

    public IEnumerable<INotificationService> GetAllNotificationServices()
    {
        yield return _serviceProvider.GetRequiredService<EmailNotificationService>();
        yield return _serviceProvider.GetRequiredService<SmsNotificationService>();
        yield return _serviceProvider.GetRequiredService<PushNotificationService>();
    }
}
```

### **Task 2: Decorator Pattern Implementation** (8 minutes)

Add logging and retry functionality to notification services using decorators:

```csharp
// LoggingNotificationDecorator.cs
public class LoggingNotificationDecorator : INotificationService
{
    private readonly INotificationService _inner;
    private readonly ILogger<LoggingNotificationDecorator> _logger;

    public LoggingNotificationDecorator(
        INotificationService inner, 
        ILogger<LoggingNotificationDecorator> logger)
    {
        _inner = inner;
        _logger = logger;
    }

    public string NotificationType => $"Logged{_inner.NotificationType}";

    public async Task SendAsync(string recipient, string subject, string message)
    {
        var startTime = DateTime.UtcNow;
        _logger.LogInformation("Starting notification send: {Type} to {Recipient} at {StartTime}", 
            _inner.NotificationType, recipient, startTime);

        try
        {
            await _inner.SendAsync(recipient, subject, message);
            
            var duration = DateTime.UtcNow - startTime;
            _logger.LogInformation("Notification send completed: {Type} to {Recipient} in {Duration}ms", 
                _inner.NotificationType, recipient, duration.TotalMilliseconds);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Notification send failed: {Type} to {Recipient}", 
                _inner.NotificationType, recipient);
            throw;
        }
    }
}

// RetryNotificationDecorator.cs
public class RetryNotificationDecorator : INotificationService
{
    private readonly INotificationService _inner;
    private readonly ILogger<RetryNotificationDecorator> _logger;
    private readonly int _maxRetries;

    public RetryNotificationDecorator(
        INotificationService inner, 
        ILogger<RetryNotificationDecorator> logger,
        int maxRetries = 3)
    {
        _inner = inner;
        _logger = logger;
        _maxRetries = maxRetries;
    }

    public string NotificationType => $"Retry{_inner.NotificationType}";

    public async Task SendAsync(string recipient, string subject, string message)
    {
        var attempts = 0;
        Exception lastException = null;

        while (attempts < _maxRetries)
        {
            try
            {
                attempts++;
                await _inner.SendAsync(recipient, subject, message);
                
                if (attempts > 1)
                {
                    _logger.LogInformation("Notification sent successfully on attempt {Attempt} for {Type} to {Recipient}", 
                        attempts, _inner.NotificationType, recipient);
                }
                
                return; // Success
            }
            catch (Exception ex)
            {
                lastException = ex;
                _logger.LogWarning("Notification attempt {Attempt} failed for {Type} to {Recipient}: {Error}", 
                    attempts, _inner.NotificationType, recipient, ex.Message);

                if (attempts < _maxRetries)
                {
                    var delay = TimeSpan.FromMilliseconds(Math.Pow(2, attempts) * 100); // Exponential backoff
                    await Task.Delay(delay);
                }
            }
        }

        _logger.LogError("All notification attempts failed for {Type} to {Recipient}", 
            _inner.NotificationType, recipient);
        throw lastException ?? new InvalidOperationException("All retry attempts failed");
    }
}

// Enhanced factory with decorators
public class DecoratedNotificationFactory : INotificationFactory
{
    private readonly IServiceProvider _serviceProvider;

    public DecoratedNotificationFactory(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public INotificationService CreateNotificationService(NotificationType type)
    {
        var baseService = type switch
        {
            NotificationType.Email => _serviceProvider.GetRequiredService<EmailNotificationService>(),
            NotificationType.SMS => _serviceProvider.GetRequiredService<SmsNotificationService>(),
            NotificationType.Push => _serviceProvider.GetRequiredService<PushNotificationService>(),
            _ => throw new ArgumentException($"Unsupported notification type: {type}")
        };

        // Apply decorators: Retry -> Logging -> Base Service
        var retryDecorator = new RetryNotificationDecorator(
            baseService, 
            _serviceProvider.GetRequiredService<ILogger<RetryNotificationDecorator>>());
            
        var loggingDecorator = new LoggingNotificationDecorator(
            retryDecorator, 
            _serviceProvider.GetRequiredService<ILogger<LoggingNotificationDecorator>>());

        return loggingDecorator;
    }

    public IEnumerable<INotificationService> GetAllNotificationServices()
    {
        return Enum.GetValues<NotificationType>()
            .Select(CreateNotificationService);
    }
}
```

### **Task 3: Generic Repository Pattern** (7 minutes)

Create a generic repository pattern with multiple implementations:

```csharp
// IRepository.cs
public interface IRepository<T> where T : class
{
    Task<T?> GetByIdAsync(int id);
    Task<IEnumerable<T>> GetAllAsync();
    Task<T> AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(int id);
}

// InMemoryRepository.cs
public class InMemoryRepository<T> : IRepository<T> where T : class
{
    private readonly Dictionary<int, T> _data = new();
    private readonly ILogger<InMemoryRepository<T>> _logger;
    private int _nextId = 1;

    public InMemoryRepository(ILogger<InMemoryRepository<T>> logger)
    {
        _logger = logger;
    }

    public Task<T?> GetByIdAsync(int id)
    {
        _logger.LogDebug("Getting {EntityType} with ID {Id} from memory", typeof(T).Name, id);
        _data.TryGetValue(id, out var entity);
        return Task.FromResult(entity);
    }

    public Task<IEnumerable<T>> GetAllAsync()
    {
        _logger.LogDebug("Getting all {EntityType} from memory", typeof(T).Name);
        return Task.FromResult<IEnumerable<T>>(_data.Values.ToList());
    }

    public Task<T> AddAsync(T entity)
    {
        var id = _nextId++;
        
        // Use reflection to set ID property if it exists
        var idProperty = typeof(T).GetProperty("Id");
        idProperty?.SetValue(entity, id);
        
        _data[id] = entity;
        _logger.LogDebug("Added {EntityType} with ID {Id} to memory", typeof(T).Name, id);
        
        return Task.FromResult(entity);
    }

    public Task UpdateAsync(T entity)
    {
        var idProperty = typeof(T).GetProperty("Id");
        if (idProperty?.GetValue(entity) is int id)
        {
            _data[id] = entity;
            _logger.LogDebug("Updated {EntityType} with ID {Id} in memory", typeof(T).Name, id);
        }
        
        return Task.CompletedTask;
    }

    public Task DeleteAsync(int id)
    {
        _data.Remove(id);
        _logger.LogDebug("Deleted {EntityType} with ID {Id} from memory", typeof(T).Name, id);
        return Task.CompletedTask;
    }
}

// DatabaseRepository.cs (simulated)
public class DatabaseRepository<T> : IRepository<T> where T : class
{
    private readonly ILogger<DatabaseRepository<T>> _logger;

    public DatabaseRepository(ILogger<DatabaseRepository<T>> logger)
    {
        _logger = logger;
    }

    public async Task<T?> GetByIdAsync(int id)
    {
        _logger.LogDebug("Getting {EntityType} with ID {Id} from database", typeof(T).Name, id);
        
        // Simulate database delay
        await Task.Delay(10);
        
        // For demo purposes, return null (no database implementation)
        return null;
    }

    public async Task<IEnumerable<T>> GetAllAsync()
    {
        _logger.LogDebug("Getting all {EntityType} from database", typeof(T).Name);
        
        // Simulate database delay
        await Task.Delay(50);
        
        // For demo purposes, return empty list
        return new List<T>();
    }

    public async Task<T> AddAsync(T entity)
    {
        _logger.LogDebug("Adding {EntityType} to database", typeof(T).Name);
        
        // Simulate database delay
        await Task.Delay(20);
        
        return entity;
    }

    public async Task UpdateAsync(T entity)
    {
        _logger.LogDebug("Updating {EntityType} in database", typeof(T).Name);
        
        // Simulate database delay
        await Task.Delay(15);
    }

    public async Task DeleteAsync(int id)
    {
        _logger.LogDebug("Deleting {EntityType} with ID {Id} from database", typeof(T).Name, id);
        
        // Simulate database delay
        await Task.Delay(10);
    }
}

// Sample entities
public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int CategoryId { get; set; }
}

public class Category
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
}
```

### **Task 4: Configuration-Driven Service Selection** (7 minutes)

Use configuration to determine which services to use:

```csharp
// ServiceConfiguration.cs
public class ServiceConfiguration
{
    public string NotificationProvider { get; set; } = "Email";
    public string RepositoryType { get; set; } = "InMemory";
    public bool EnableLogging { get; set; } = true;
    public bool EnableRetry { get; set; } = true;
    public int MaxRetryAttempts { get; set; } = 3;
}

// ServiceRegistrationExtensions.cs
public static class ServiceRegistrationExtensions
{
    public static IServiceCollection AddConfigurableServices(
        this IServiceCollection services, 
        IConfiguration configuration)
    {
        var serviceConfig = configuration.GetSection("Services").Get<ServiceConfiguration>() 
                           ?? new ServiceConfiguration();

        // Register base notification services
        services.AddTransient<EmailNotificationService>();
        services.AddTransient<SmsNotificationService>();
        services.AddTransient<PushNotificationService>();

        // Register repositories based on configuration
        if (serviceConfig.RepositoryType.Equals("Database", StringComparison.OrdinalIgnoreCase))
        {
            services.AddScoped(typeof(IRepository<>), typeof(DatabaseRepository<>));
        }
        else
        {
            services.AddSingleton(typeof(IRepository<>), typeof(InMemoryRepository<>));
        }

        // Register notification factory based on configuration
        if (serviceConfig.EnableLogging || serviceConfig.EnableRetry)
        {
            services.AddTransient<INotificationFactory, DecoratedNotificationFactory>();
        }
        else
        {
            services.AddTransient<INotificationFactory, NotificationFactory>();
        }

        // Register configuration as a service
        services.AddSingleton(serviceConfig);

        return services;
    }
}

// Enhanced notification service that uses configuration
public interface INotificationManager
{
    Task SendNotificationAsync(string recipient, string subject, string message);
    Task SendBulkNotificationAsync(IEnumerable<string> recipients, string subject, string message);
}

public class NotificationManager : INotificationManager
{
    private readonly INotificationFactory _factory;
    private readonly ServiceConfiguration _config;
    private readonly ILogger<NotificationManager> _logger;

    public NotificationManager(
        INotificationFactory factory, 
        ServiceConfiguration config,
        ILogger<NotificationManager> logger)
    {
        _factory = factory;
        _config = config;
        _logger = logger;
    }

    public async Task SendNotificationAsync(string recipient, string subject, string message)
    {
        if (Enum.TryParse<NotificationType>(_config.NotificationProvider, out var notificationType))
        {
            var service = _factory.CreateNotificationService(notificationType);
            await service.SendAsync(recipient, subject, message);
        }
        else
        {
            _logger.LogWarning("Unknown notification provider: {Provider}", _config.NotificationProvider);
            throw new InvalidOperationException($"Unknown notification provider: {_config.NotificationProvider}");
        }
    }

    public async Task SendBulkNotificationAsync(IEnumerable<string> recipients, string subject, string message)
    {
        var tasks = recipients.Select(recipient => SendNotificationAsync(recipient, subject, message));
        await Task.WhenAll(tasks);
    }
}
```

## 🧪 **Registration and Testing**

### **Service Registration in Program.cs**:

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);

// Add configuration
builder.Configuration.AddJsonFile("appsettings.json");

// Add services
builder.Services.AddControllers();
builder.Services.AddLogging();

// Register configurable services
builder.Services.AddConfigurableServices(builder.Configuration);

// Register notification manager
builder.Services.AddScoped<INotificationManager, NotificationManager>();

var app = builder.Build();

app.UseRouting();
app.MapControllers();

app.Run();
```

### **Configuration in appsettings.json**:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "Services": {
    "NotificationProvider": "Email",
    "RepositoryType": "InMemory",
    "EnableLogging": true,
    "EnableRetry": true,
    "MaxRetryAttempts": 3
  }
}
```

### **Test Controller**:

```csharp
[ApiController]
[Route("api/[controller]")]
public class AdvancedDIController : ControllerBase
{
    private readonly INotificationManager _notificationManager;
    private readonly IRepository<Product> _productRepository;
    private readonly IRepository<Category> _categoryRepository;

    public AdvancedDIController(
        INotificationManager notificationManager,
        IRepository<Product> productRepository,
        IRepository<Category> categoryRepository)
    {
        _notificationManager = notificationManager;
        _productRepository = productRepository;
        _categoryRepository = categoryRepository;
    }

    [HttpPost("send-notification")]
    public async Task<IActionResult> SendNotification([FromBody] NotificationRequest request)
    {
        await _notificationManager.SendNotificationAsync(request.Recipient, request.Subject, request.Message);
        return Ok(new { Success = true, Message = "Notification sent successfully" });
    }

    [HttpPost("products")]
    public async Task<IActionResult> CreateProduct([FromBody] Product product)
    {
        var created = await _productRepository.AddAsync(product);
        return Ok(created);
    }

    [HttpGet("products")]
    public async Task<IActionResult> GetProducts()
    {
        var products = await _productRepository.GetAllAsync();
        return Ok(products);
    }
}

public class NotificationRequest
{
    public string Recipient { get; set; } = string.Empty;
    public string Subject { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
}
```

## 🔍 **Expected Results**

### **Factory Pattern**:
- ✅ Different notification services created based on type
- ✅ All services resolved with their dependencies
- ✅ Factory can enumerate all available services
- ✅ Service provider properly resolves concrete implementations

### **Decorator Pattern**:
- ✅ Logging decorator captures start/end times and errors
- ✅ Retry decorator implements exponential backoff
- ✅ Decorators can be chained in any order
- ✅ Original service functionality preserved

### **Generic Repository**:
- ✅ Same interface works for different entity types
- ✅ Repository type selected based on configuration
- ✅ Type-safe operations for all entities
- ✅ Proper logging for each repository operation

### **Configuration-Driven Selection**:
- ✅ Services selected based on appsettings.json
- ✅ Configuration changes affect service behavior
- ✅ Fallback to defaults when configuration is missing
- ✅ Type-safe configuration binding

## 🧪 **Testing Scenarios**

### **Test 1: Factory Pattern**
```bash
# Test different notification types
curl -X POST "http://localhost:5000/api/advanceddi/send-notification" \
  -H "Content-Type: application/json" \
  -d '{
    "recipient": "test@yourdomain.com",
    "subject": "Test Email",
    "message": "This is a test message"
  }'
```

### **Test 2: Repository Pattern**
```bash
# Create a product
curl -X POST "http://localhost:5000/api/advanceddi/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Product",
    "price": 29.99,
    "categoryId": 1
  }'

# Get all products
curl -X GET "http://localhost:5000/api/advanceddi/products"
```

### **Test 3: Configuration Changes**
Modify `appsettings.json` and restart the application:
```json
{
  "Services": {
    "NotificationProvider": "SMS",
    "RepositoryType": "Database",
    "EnableLogging": false,
    "EnableRetry": false
  }
}
```

## 🤔 **Discussion Questions**

1. **When would you use the Factory pattern vs direct dependency injection?**
   - Factory: When you need to create services dynamically based on runtime conditions
   - Direct DI: When the service type is known at registration time

2. **What are the benefits and drawbacks of the Decorator pattern?**
   - Benefits: Separation of concerns, composable functionality, open/closed principle
   - Drawbacks: Increased complexity, potential performance overhead

3. **How do you handle circular dependencies in complex DI scenarios?**
   - Use interfaces to break circular references
   - Consider if the circular dependency indicates a design problem
   - Use lazy initialization or factory patterns

4. **What are the performance implications of different DI patterns?**
   - Factory pattern: Slight overhead for service creation
   - Decorator pattern: Stack of method calls
   - Generic services: No significant performance impact

## 🎯 **Success Criteria**

**You've successfully completed this exercise when you can**:
- ✅ Implement factory pattern with dependency injection
- ✅ Create composable decorators that enhance service functionality
- ✅ Use generic services effectively with multiple entity types
- ✅ Configure services based on application settings
- ✅ Understand when to use each pattern in real-world scenarios

## 🐛 **Common Issues and Solutions**

### **Issue 1: Circular Dependencies**
```csharp
// Problem: Service A depends on Service B, which depends on Service A
public class ServiceA
{
    public ServiceA(ServiceB serviceB) { } // Circular dependency!
}

public class ServiceB
{
    public ServiceB(ServiceA serviceA) { } // Circular dependency!
}

// Solution: Use interfaces and/or factory pattern
public class ServiceA
{
    private readonly Func<IServiceB> _serviceBFactory;
    
    public ServiceA(Func<IServiceB> serviceBFactory)
    {
        _serviceBFactory = serviceBFactory;
    }
}
```

### **Issue 2: Generic Service Registration**
```csharp
// Problem: Registering generic services incorrectly
services.AddScoped<IRepository<Product>, InMemoryRepository<Product>>(); // Wrong!

// Solution: Use open generic registration
services.AddScoped(typeof(IRepository<>), typeof(InMemoryRepository<>)); // Correct!
```

### **Issue 3: Decorator Ordering**
```csharp
// Problem: Decorators applied in wrong order
var service = new LoggingDecorator(new RetryDecorator(baseService)); // Logs retries

// Better: Retry wraps logging so we don't log retry attempts
var service = new RetryDecorator(new LoggingDecorator(baseService)); // Logs final result
```

## 🚀 **Bonus Challenges**

1. **Implement a Composite Pattern**: Create a notification service that sends to multiple providers simultaneously

2. **Add Validation Decorator**: Create a decorator that validates input before calling the wrapped service

3. **Implement Keyed Services**: Use .NET 8's keyed services feature to register multiple implementations

4. **Create a Circuit Breaker Decorator**: Implement a decorator that stops calling a failing service temporarily

5. **Build a Caching Decorator**: Add caching functionality to repository operations

## 📚 **Advanced Topics to Explore**

1. **Microsoft.Extensions.DependencyInjection.Abstractions**:
   - Service descriptors
   - Service scope factories
   - Service provider validation

2. **Third-Party DI Containers**:
   - Autofac integration
   - Castle Windsor
   - Unity Container

3. **Performance Optimization**:
   - Service resolution benchmarking
   - Avoiding service locator anti-pattern
   - Singleton vs scoped performance

4. **Testing with DI**:
   - Mock services in unit tests
   - Integration testing with test containers
   - Service replacement in tests

## 📞 **Troubleshooting Guide**

### **Service Resolution Errors**:
- Check service registration order
- Verify interface implementations
- Ensure all dependencies are registered

### **Performance Issues**:
- Avoid resolving services in tight loops
- Use appropriate service lifetimes
- Consider factory patterns for expensive services

### **Configuration Problems**:
- Validate configuration binding
- Check for null configuration sections
- Use options pattern for complex configuration

## 🎓 **Next Steps**

After mastering advanced DI patterns, you'll be ready for:
- **Exercise 4**: Production Integration (combining DI and middleware)
- **Module 13**: Building Microservices (DI across service boundaries)
- **Advanced Architecture**: CQRS, Event Sourcing, Domain-Driven Design
- **Performance Tuning**: Optimizing DI container performance

---

**🎯 Congratulations!** You've now mastered advanced dependency injection patterns that are essential for building maintainable, testable, and flexible enterprise applications. These patterns form the foundation of modern software architecture.