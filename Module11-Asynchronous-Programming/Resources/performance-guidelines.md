# Performance Guidelines for Async Programming

## Overview
This guide provides specific performance recommendations for async programming in ASP.NET Core, including benchmarks, optimization techniques, and monitoring strategies.

## Understanding Async Performance

### The Async Advantage
Async programming improves **scalability**, not **speed**:

- **Scalability**: Handle more concurrent requests with fewer threads
- **Responsiveness**: UI remains responsive during I/O operations
- **Resource Efficiency**: Better thread pool utilization

### Performance Metrics to Track

1. **Throughput**: Requests per second
2. **Response Time**: Average and 95th percentile
3. **Thread Pool Usage**: Active threads vs available
4. **Memory Allocation**: GC pressure from async operations
5. **CPU Utilization**: Overall and per-core usage

## ASP.NET Core Specific Optimizations

### 1. Thread Pool Configuration

**Configure thread pool for your workload:**

```csharp
// In Program.cs
var builder = WebApplication.CreateBuilder(args);

// Configure thread pool for I/O intensive workloads
ThreadPool.SetMinThreads(
    workerThreads: Environment.ProcessorCount * 4,
    completionPortThreads: Environment.ProcessorCount * 4);

// For CPU intensive workloads, use default or lower values
ThreadPool.SetMinThreads(
    workerThreads: Environment.ProcessorCount,
    completionPortThreads: Environment.ProcessorCount);
```

### 2. HTTP Client Optimization

**❌ Poor performance:**
```csharp
public async Task<string> GetDataAsync(string url)
{
    using var client = new HttpClient(); // Creates new client each time!
    return await client.GetStringAsync(url);
}
```

**✅ Optimized approach:**
```csharp
public class ApiService
{
    private readonly HttpClient _httpClient;
    
    public ApiService(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }
    
    public async Task<string> GetDataAsync(string url)
    {
        return await _httpClient.GetStringAsync(url);
    }
}

// In Program.cs
builder.Services.AddHttpClient<ApiService>(client =>
{
    client.Timeout = TimeSpan.FromSeconds(30);
    client.DefaultRequestHeaders.Add("User-Agent", "MyApp/1.0");
});
```

### 3. Database Connection Optimization

**✅ Use connection pooling effectively:**
```csharp
// In Program.cs
builder.Services.AddDbContext<MyContext>(options =>
{
    options.UseSqlServer(connectionString, sqlOptions =>
    {
        sqlOptions.CommandTimeout(30);
    });
}, ServiceLifetime.Scoped); // Default, but explicit

// Optimize connection string
var connectionString = "Server=...;Database=...;Connection Timeout=30;Max Pool Size=100;Min Pool Size=10;Pooling=true;";
```

**✅ Efficient async database operations:**
```csharp
public async Task<List<Product>> GetProductsAsync(int categoryId)
{
    return await _context.Products
        .Where(p => p.CategoryId == categoryId)
        .AsNoTracking() // Read-only queries
        .ToListAsync();
}

// Use streaming for large datasets
public async IAsyncEnumerable<Product> StreamProductsAsync(
    [EnumeratorCancellation] CancellationToken cancellationToken = default)
{
    await foreach (var product in _context.Products.AsAsyncEnumerable().WithCancellation(cancellationToken))
    {
        yield return product;
    }
}
```

## Concurrency Optimization

### 4. Optimal Concurrency Levels

**✅ Controlled concurrency with SemaphoreSlim:**
```csharp
private readonly SemaphoreSlim _semaphore = new(maxConcurrency: 10);

public async Task<T> ProcessWithThrottlingAsync<T>(Func<Task<T>> operation)
{
    await _semaphore.WaitAsync();
    try
    {
        return await operation();
    }
    finally
    {
        _semaphore.Release();
    }
}
```

### 5. Batch Processing Optimization

**✅ Efficient batch processing:**
```csharp
public async Task ProcessItemsBatchAsync<T>(IEnumerable<T> items, Func<T, Task> processor, int batchSize = 10)
{
    var batches = items.Chunk(batchSize);
    
    foreach (var batch in batches)
    {
        var tasks = batch.Select(processor);
        await Task.WhenAll(tasks);
    }
}

// Usage
await ProcessItemsBatchAsync(products, async product =>
{
    await ProcessProductAsync(product);
}, batchSize: 20);
```

### 6. Producer-Consumer Optimization

**✅ High-performance producer-consumer with Channels:**
```csharp
public class HighThroughputProcessor<T>
{
    private readonly Channel<T> _channel;
    private readonly ChannelWriter<T> _writer;
    private readonly ChannelReader<T> _reader;

    public HighThroughputProcessor(int capacity = 1000)
    {
        var options = new BoundedChannelOptions(capacity)
        {
            FullMode = BoundedChannelFullMode.Wait,
            SingleReader = false,
            SingleWriter = false
        };
        
        _channel = Channel.CreateBounded<T>(options);
        _writer = _channel.Writer;
        _reader = _channel.Reader;
    }

    public async ValueTask ProduceAsync(T item)
    {
        await _writer.WriteAsync(item);
    }

    public async IAsyncEnumerable<T> ConsumeAsync(
        [EnumeratorCancellation] CancellationToken cancellationToken = default)
    {
        await foreach (var item in _reader.ReadAllAsync(cancellationToken))
        {
            yield return item;
        }
    }
}
```

## Memory Management

### 7. Reduce Allocations

**✅ Use ValueTask for frequently called methods:**
```csharp
private readonly ConcurrentDictionary<string, string> _cache = new();

public ValueTask<string> GetCachedValueAsync(string key)
{
    if (_cache.TryGetValue(key, out var value))
    {
        return ValueTask.FromResult(value); // No allocation
    }
    
    return new ValueTask<string>(FetchValueAsync(key));
}

private async Task<string> FetchValueAsync(string key)
{
    // Actual async work here
    await Task.Delay(100);
    var value = $"Value for {key}";
    _cache.TryAdd(key, value);
    return value;
}
```

**✅ Pool objects to reduce allocations:**
```csharp
public class ObjectPoolService<T> where T : class, new()
{
    private readonly ObjectPool<T> _pool;

    public ObjectPoolService(IServiceProvider serviceProvider)
    {
        var provider = serviceProvider.GetRequiredService<ObjectPoolProvider>();
        _pool = provider.Create<T>();
    }

    public async Task<TResult> UsePooledObjectAsync<TResult>(Func<T, Task<TResult>> operation)
    {
        var obj = _pool.Get();
        try
        {
            return await operation(obj);
        }
        finally
        {
            _pool.Return(obj);
        }
    }
}
```

### 8. Streaming Large Responses

**✅ Stream large responses to reduce memory usage:**
```csharp
[HttpGet("export")]
public async Task ExportDataAsync()
{
    Response.ContentType = "application/json";
    
    await using var writer = new Utf8JsonWriter(Response.Body);
    writer.WriteStartArray();
    
    await foreach (var item in _service.GetDataStreamAsync())
    {
        JsonSerializer.Serialize(writer, item);
        await writer.FlushAsync();
    }
    
    writer.WriteEndArray();
    await writer.FlushAsync();
}
```

## Performance Monitoring

### 9. Built-in Metrics

**✅ Add performance monitoring:**
```csharp
// In Program.cs
builder.Services.AddSingleton<IMetrics, Metrics>();

public class PerformanceMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IMetrics _metrics;

    public PerformanceMiddleware(RequestDelegate next, IMetrics metrics)
    {
        _next = next;
        _metrics = metrics;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var sw = Stopwatch.StartNew();
        
        try
        {
            await _next(context);
        }
        finally
        {
            sw.Stop();
            _metrics.Measure.Timer.Time("request_duration", sw.Elapsed, 
                new MetricTags("endpoint", context.Request.Path));
        }
    }
}
```

### 10. Custom Performance Counters

**✅ Track async-specific metrics:**
```csharp
public class AsyncMetrics
{
    private static readonly Counter<long> _asyncOperationsStarted = 
        Meter.CreateCounter<long>("async_operations_started");
    
    private static readonly Counter<long> _asyncOperationsCompleted = 
        Meter.CreateCounter<long>("async_operations_completed");
    
    private static readonly Histogram<double> _asyncOperationDuration = 
        Meter.CreateHistogram<double>("async_operation_duration_ms");

    public static IDisposable TrackAsyncOperation(string operationName)
    {
        _asyncOperationsStarted.Add(1, new("operation", operationName));
        var sw = Stopwatch.StartNew();
        
        return new DisposableAction(() =>
        {
            sw.Stop();
            _asyncOperationsCompleted.Add(1, new("operation", operationName));
            _asyncOperationDuration.Record(sw.Elapsed.TotalMilliseconds, new("operation", operationName));
        });
    }
}

// Usage
public async Task<T> MonitoredOperationAsync<T>(Func<Task<T>> operation, string operationName)
{
    using var _ = AsyncMetrics.TrackAsyncOperation(operationName);
    return await operation();
}
```

## Benchmarking Async Code

### 11. BenchmarkDotNet Setup

**✅ Benchmark async performance:**
```csharp
[MemoryDiagnoser]
[SimpleJob(RuntimeMoniker.Net80)]
public class AsyncBenchmarks
{
    private const int ItemCount = 1000;
    private readonly HttpClient _httpClient = new();

    [Benchmark(Baseline = true)]
    public async Task SequentialProcessing()
    {
        for (int i = 0; i < ItemCount; i++)
        {
            await ProcessItemAsync(i);
        }
    }

    [Benchmark]
    public async Task ConcurrentProcessing()
    {
        var tasks = Enumerable.Range(0, ItemCount)
            .Select(ProcessItemAsync);
        
        await Task.WhenAll(tasks);
    }

    [Benchmark]
    public async Task BatchedProcessing()
    {
        const int batchSize = 50;
        var batches = Enumerable.Range(0, ItemCount).Chunk(batchSize);
        
        foreach (var batch in batches)
        {
            var tasks = batch.Select(ProcessItemAsync);
            await Task.WhenAll(tasks);
        }
    }

    private async Task ProcessItemAsync(int id)
    {
        await Task.Delay(1); // Simulate async work
    }
}
```

### 12. Performance Testing Framework

**✅ Load testing async endpoints:**
```csharp
public class LoadTest
{
    [Fact]
    public async Task ApiEndpoint_ShouldHandleHighLoad()
    {
        const int concurrentRequests = 100;
        const int totalRequests = 1000;
        
        using var httpClient = new HttpClient();
        var semaphore = new SemaphoreSlim(concurrentRequests);
        var tasks = new List<Task<HttpResponseMessage>>();
        
        var stopwatch = Stopwatch.StartNew();
        
        for (int i = 0; i < totalRequests; i++)
        {
            tasks.Add(MakeRequestWithThrottling(httpClient, semaphore, $"/api/data/{i}"));
        }
        
        var responses = await Task.WhenAll(tasks);
        stopwatch.Stop();
        
        var successfulRequests = responses.Count(r => r.IsSuccessStatusCode);
        var requestsPerSecond = totalRequests / stopwatch.Elapsed.TotalSeconds;
        
        Assert.True(successfulRequests >= totalRequests * 0.95); // 95% success rate
        Assert.True(requestsPerSecond >= 100); // Minimum throughput
    }
    
    private async Task<HttpResponseMessage> MakeRequestWithThrottling(
        HttpClient client, SemaphoreSlim semaphore, string endpoint)
    {
        await semaphore.WaitAsync();
        try
        {
            return await client.GetAsync(endpoint);
        }
        finally
        {
            semaphore.Release();
        }
    }
}
```

## Platform-Specific Optimizations

### 13. .NET 8 Improvements

**✅ Leverage .NET 8 async improvements:**
```csharp
// Use new PeriodicTimer for background services
public class OptimizedBackgroundService : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(TimeSpan.FromMinutes(5));
        
        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            await ProcessDataAsync(stoppingToken);
        }
    }
}

// Use IAsyncEnumerable.ConfigureAwait for better performance
public async IAsyncEnumerable<T> StreamDataAsync<T>(
    [EnumeratorCancellation] CancellationToken cancellationToken = default)
{
    await foreach (var item in GetDataAsync().ConfigureAwait(false).WithCancellation(cancellationToken))
    {
        yield return item;
    }
}
```

### 14. AOT and Trimming Considerations

**✅ Optimize for AOT compilation:**
```csharp
// Avoid reflection in async contexts for AOT
[JsonSerializable(typeof(MyDto))]
public partial class MyJsonContext : JsonSerializerContext { }

public async Task<MyDto> GetDataAsync()
{
    var json = await httpClient.GetStringAsync(url);
    return JsonSerializer.Deserialize<MyDto>(json, MyJsonContext.Default.MyDto)!;
}
```

## Configuration Tuning

### 15. Kestrel Configuration

**✅ Optimize Kestrel for async workloads:**
```csharp
// In Program.cs
builder.WebHost.ConfigureKestrel(options =>
{
    options.Limits.MaxConcurrentConnections = 1000;
    options.Limits.MaxConcurrentUpgradedConnections = 1000;
    options.Limits.MaxRequestBodySize = 10 * 1024 * 1024; // 10 MB
    options.Limits.MinRequestBodyDataRate = new MinDataRate(100, TimeSpan.FromSeconds(10));
    options.Limits.MinResponseDataRate = new MinDataRate(100, TimeSpan.FromSeconds(10));
});
```

### 16. IIS Configuration

**✅ Optimize IIS for async:**
```xml
<!-- In web.config -->
<system.webServer>
  <aspNetCore processPath="dotnet" arguments=".\MyApp.dll" stdoutLogEnabled="false">
    <environmentVariables>
      <environmentVariable name="ASPNETCORE_ENVIRONMENT" value="Production" />
      <environmentVariable name="DOTNET_USE_POLLING_FILE_WATCHER" value="true" />
    </environmentVariables>
  </aspNetCore>
  
  <httpRuntime targetFramework="4.8" maxConcurrentRequestsPerCPU="1000" />
</system.webServer>
```

## Performance Checklist

### Async Code Review Checklist

- ✅ **No blocking calls**: No .Result, .Wait(), or GetAwaiter().GetResult()
- ✅ **Proper cancellation**: CancellationTokens passed and honored
- ✅ **Concurrent operations**: Using Task.WhenAll where appropriate
- ✅ **Resource management**: Using statements for disposable resources
- ✅ **Exception handling**: Proper try-catch around async operations
- ✅ **Timeout handling**: Reasonable timeouts for external calls
- ✅ **Memory efficiency**: ValueTask for hot paths, object pooling where needed
- ✅ **Monitoring**: Performance metrics and logging in place

### Load Testing Checklist

- ✅ **Concurrent users**: Test with expected concurrent load
- ✅ **Memory usage**: Monitor for memory leaks under load
- ✅ **Thread pool**: Monitor thread pool starvation
- ✅ **Response times**: 95th percentile within acceptable limits
- ✅ **Error rates**: Less than 1% error rate under normal load
- ✅ **Resource utilization**: CPU and memory within limits
- ✅ **Graceful degradation**: Performance degrades gracefully under extreme load

## Performance Anti-Patterns

### ❌ Common Performance Killers

```csharp
// 1. Async over sync
public async Task<int> AddAsync(int a, int b)
{
    return await Task.Run(() => a + b); // Don't do this!
}

// 2. Creating unnecessary tasks
public async Task ProcessItemsAsync(List<string> items)
{
    foreach (var item in items)
    {
        await Task.Run(() => ProcessItem(item)); // Bad!
    }
}

// 3. Not using ConfigureAwait in libraries
public async Task<string> LibraryMethodAsync()
{
    return await SomeAsyncOperation(); // Should use ConfigureAwait(false)
}

// 4. Blocking on async code
public void SyncMethod()
{
    var result = AsyncMethod().Result; // Potential deadlock!
}

// 5. Excessive parallelism
public async Task ProcessAllItemsAsync(List<string> items)
{
    var tasks = items.Select(ProcessItemAsync); // Could overwhelm system
    await Task.WhenAll(tasks);
}
```

Following these performance guidelines will help you build high-performing, scalable async applications that can handle real-world load efficiently!