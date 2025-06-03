# Exercise 1: Service Lifetime Exploration

## 🎯 **Objective**
Master ASP.NET Core dependency injection service lifetimes by creating practical examples that demonstrate the behavior of Singleton, Scoped, and Transient services.

## ⏱️ **Estimated Time**
30 minutes

## 📋 **Prerequisites**
- Basic understanding of dependency injection concepts
- Familiarity with ASP.NET Core controllers
- Understanding of interfaces and classes in C#

## 🎓 **Learning Outcomes**
- Understand when to use each service lifetime
- Observe actual service instance creation and disposal
- Learn proper resource management with IDisposable
- Understand thread safety implications
- See how lifetimes behave with concurrent requests

## 📝 **Exercise Tasks**

### **Task 1: Create Service Interfaces and Implementations** (5 minutes)

Create three service interfaces and their implementations to demonstrate different lifetimes:

```csharp
// ICounterService.cs
public interface ICounterService
{
    int GetCurrentCount();
    void Increment();
    string ServiceId { get; }
    DateTime CreatedAt { get; }
}

// SingletonCounterService.cs
public class SingletonCounterService : ICounterService, IDisposable
{
    private int _count = 0;
    public string ServiceId { get; } = Guid.NewGuid().ToString("N")[..8];
    public DateTime CreatedAt { get; } = DateTime.UtcNow;
    
    public int GetCurrentCount() => _count;
    
    public void Increment() => Interlocked.Increment(ref _count);
    
    public void Dispose()
    {
        Console.WriteLine($"SingletonCounterService {ServiceId} disposed at {DateTime.UtcNow}");
    }
}

// ScopedCounterService.cs
public class ScopedCounterService : ICounterService, IDisposable
{
    private int _count = 0;
    public string ServiceId { get; } = Guid.NewGuid().ToString("N")[..8];
    public DateTime CreatedAt { get; } = DateTime.UtcNow;
    
    public int GetCurrentCount() => _count;
    
    public void Increment() => _count++;
    
    public void Dispose()
    {
        Console.WriteLine($"ScopedCounterService {ServiceId} disposed at {DateTime.UtcNow}");
    }
}

// TransientCounterService.cs
public class TransientCounterService : ICounterService, IDisposable
{
    private int _count = 0;
    public string ServiceId { get; } = Guid.NewGuid().ToString("N")[..8];
    public DateTime CreatedAt { get; } = DateTime.UtcNow;
    
    public int GetCurrentCount() => _count;
    
    public void Increment() => _count++;
    
    public void Dispose()
    {
        Console.WriteLine($"TransientCounterService {ServiceId} disposed at {DateTime.UtcNow}");
    }
}
```

### **Task 2: Register Services with Different Lifetimes** (5 minutes)

In your `Program.cs`, register the services with different lifetimes:

```csharp
// Register services with different lifetimes
builder.Services.AddSingleton<SingletonCounterService>();
builder.Services.AddScoped<ScopedCounterService>();
builder.Services.AddTransient<TransientCounterService>();

// Also register a composite service that depends on all three
builder.Services.AddScoped<ILifetimeComparisionService, LifetimeComparisonService>();
```

### **Task 3: Create a Controller to Test Service Lifetimes** (10 minutes)

```csharp
[ApiController]
[Route("api/[controller]")]
public class LifetimeController : ControllerBase
{
    private readonly SingletonCounterService _singleton1;
    private readonly SingletonCounterService _singleton2;
    private readonly ScopedCounterService _scoped1;
    private readonly ScopedCounterService _scoped2;
    private readonly TransientCounterService _transient1;
    private readonly TransientCounterService _transient2;

    public LifetimeController(
        SingletonCounterService singleton1,
        SingletonCounterService singleton2,
        ScopedCounterService scoped1,
        ScopedCounterService scoped2,
        TransientCounterService transient1,
        TransientCounterService transient2)
    {
        _singleton1 = singleton1;
        _singleton2 = singleton2;
        _scoped1 = scoped1;
        _scoped2 = scoped2;
        _transient1 = transient1;
        _transient2 = transient2;
    }

    [HttpGet("test-lifetimes")]
    public IActionResult TestLifetimes()
    {
        // Increment all counters
        _singleton1.Increment();
        _scoped1.Increment();
        _transient1.Increment();

        var result = new
        {
            RequestId = HttpContext.TraceIdentifier,
            Timestamp = DateTime.UtcNow,
            Singleton = new
            {
                Instance1_Id = _singleton1.ServiceId,
                Instance1_Count = _singleton1.GetCurrentCount(),
                Instance1_Created = _singleton1.CreatedAt,
                Instance2_Id = _singleton2.ServiceId,
                Instance2_Count = _singleton2.GetCurrentCount(),
                Instance2_Created = _singleton2.CreatedAt,
                AreSameInstance = ReferenceEquals(_singleton1, _singleton2)
            },
            Scoped = new
            {
                Instance1_Id = _scoped1.ServiceId,
                Instance1_Count = _scoped1.GetCurrentCount(),
                Instance1_Created = _scoped1.CreatedAt,
                Instance2_Id = _scoped2.ServiceId,
                Instance2_Count = _scoped2.GetCurrentCount(),
                Instance2_Created = _scoped2.CreatedAt,
                AreSameInstance = ReferenceEquals(_scoped1, _scoped2)
            },
            Transient = new
            {
                Instance1_Id = _transient1.ServiceId,
                Instance1_Count = _transient1.GetCurrentCount(),
                Instance1_Created = _transient1.CreatedAt,
                Instance2_Id = _transient2.ServiceId,
                Instance2_Count = _transient2.GetCurrentCount(),
                Instance2_Created = _transient2.CreatedAt,
                AreSameInstance = ReferenceEquals(_transient1, _transient2)
            }
        };

        return Ok(result);
    }
}
```

### **Task 4: Create a Composite Service for Advanced Testing** (5 minutes)

```csharp
public interface ILifetimeComparisonService
{
    object GetLifetimeComparison();
}

public class LifetimeComparisonService : ILifetimeComparisonService
{
    private readonly SingletonCounterService _singleton;
    private readonly ScopedCounterService _scoped;
    private readonly TransientCounterService _transient;

    public LifetimeComparisonService(
        SingletonCounterService singleton,
        ScopedCounterService scoped,
        TransientCounterService transient)
    {
        _singleton = singleton;
        _scoped = scoped;
        _transient = transient;
    }

    public object GetLifetimeComparison()
    {
        _singleton.Increment();
        _scoped.Increment();
        _transient.Increment();

        return new
        {
            ServiceCreatedAt = DateTime.UtcNow,
            Singleton = new
            {
                _singleton.ServiceId,
                Count = _singleton.GetCurrentCount(),
                _singleton.CreatedAt
            },
            Scoped = new
            {
                _scoped.ServiceId,
                Count = _scoped.GetCurrentCount(),
                _scoped.CreatedAt
            },
            Transient = new
            {
                _transient.ServiceId,
                Count = _transient.GetCurrentCount(),
                _transient.CreatedAt
            }
        };
    }
}
```

### **Task 5: Testing and Observation** (5 minutes)

1. **Run the application** and make multiple requests to `/api/lifetime/test-lifetimes`

2. **Observe the behavior**:
   - **Singleton**: Same ServiceId across all requests and injections
   - **Scoped**: Same ServiceId within a request, different across requests
   - **Transient**: Different ServiceId for every injection

3. **Test concurrent requests** using tools like Postman or curl:
   ```bash
   # Make multiple concurrent requests
   curl -X GET "http://localhost:5000/api/lifetime/test-lifetimes" &
   curl -X GET "http://localhost:5000/api/lifetime/test-lifetimes" &
   curl -X GET "http://localhost:5000/api/lifetime/test-lifetimes" &
   wait
   ```

4. **Check console output** for disposal messages when the application stops

## 🔍 **Expected Results**

### **Singleton Services**:
- ✅ Same instance across all requests and injections
- ✅ Counter value persists and increments across requests
- ✅ Same ServiceId and CreatedAt timestamp
- ✅ Thread-safe operations (using Interlocked)

### **Scoped Services**:
- ✅ Same instance within a single request
- ✅ Different instances for different requests
- ✅ Counter resets to 0 for each new request
- ✅ Disposed at the end of each request

### **Transient Services**:
- ✅ New instance for every injection
- ✅ Different ServiceId for each injection even within the same request
- ✅ Counter always shows the incremented value (1) since it's a new instance
- ✅ Multiple disposal messages per request

## 🤔 **Discussion Questions**

1. **When would you use each lifetime?**
   - Singleton: Database connections, configuration, caching
   - Scoped: Request-specific data, user context, database context
   - Transient: Stateless services, lightweight operations

2. **What are the thread safety implications?**
   - Singleton services must be thread-safe
   - Scoped and Transient don't need thread safety within their scope

3. **What about memory usage?**
   - Singletons live for the application lifetime
   - Scoped services are disposed after each request
   - Transient services are disposed when their scope ends

## 🎯 **Success Criteria**

**You've successfully completed this exercise when you can**:
- ✅ Explain the behavior differences between service lifetimes
- ✅ Predict which instances will be the same vs different
- ✅ Understand when disposal occurs for each lifetime
- ✅ Choose appropriate lifetimes for different scenarios

## 🚀 **Bonus Challenges**

1. **Add logging** to track service creation and disposal
2. **Create a memory usage test** to see the impact of different lifetimes
3. **Implement a service** that depends on multiple other services with different lifetimes
4. **Test with async operations** to see how scope is maintained

## 📚 **Next Steps**

After mastering service lifetimes, you'll be ready for:
- Exercise 2: Custom Middleware Development
- Advanced DI patterns and factories
- Service validation and health checks