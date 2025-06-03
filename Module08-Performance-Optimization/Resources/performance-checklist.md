# ASP.NET Core Performance Optimization Checklist

## Overview

This checklist provides a systematic approach to optimizing ASP.NET Core applications. Use this as a guide to identify and implement performance improvements in your applications.

## 🏃 Quick Wins (Immediate Impact)

### Response Compression
- [ ] Enable response compression middleware
- [ ] Configure Brotli compression for modern browsers
- [ ] Set appropriate compression levels (Fastest for CPU-bound, Optimal for bandwidth-bound)
- [ ] Verify compression is working with browser dev tools

```csharp
// In Program.cs
builder.Services.AddResponseCompression(options =>
{
    options.EnableForHttps = true;
    options.Providers.Add<BrotliCompressionProvider>();
    options.Providers.Add<GzipCompressionProvider>();
});
```

### Static File Optimization
- [ ] Enable static file caching headers
- [ ] Use CDN for static assets
- [ ] Implement proper cache-control headers
- [ ] Minify CSS and JavaScript files

### Basic Caching
- [ ] Implement memory caching for frequently accessed data
- [ ] Add response caching for appropriate endpoints
- [ ] Configure cache profiles for different content types

## 🗄️ Database Optimization

### Entity Framework Core
- [ ] Use `AsNoTracking()` for read-only queries
- [ ] Implement eager loading with `Include()` where appropriate
- [ ] Use `Select()` projections to load only needed columns
- [ ] Implement compiled queries for frequently executed queries
- [ ] Use query splitting for complex queries with multiple includes
- [ ] Add appropriate database indexes

```csharp
// Compiled query example
private static readonly Func<AppDbContext, int, Task<Product?>> GetProductQuery =
    EF.CompileAsyncQuery((AppDbContext context, int id) =>
        context.Products.Include(p => p.Category)
            .FirstOrDefault(p => p.Id == id));
```

### Query Optimization
- [ ] Identify and fix N+1 query problems
- [ ] Use batch operations for bulk inserts/updates
- [ ] Implement efficient pagination patterns
- [ ] Monitor query execution plans
- [ ] Use database-specific optimizations where appropriate

### Connection Management
- [ ] Configure appropriate connection pool sizes
- [ ] Use connection string optimizations
- [ ] Implement proper connection lifetime management
- [ ] Monitor connection pool metrics

## 💾 Memory Optimization

### Allocation Reduction
- [ ] Use `StringBuilder` instead of string concatenation
- [ ] Implement `Span<T>` and `Memory<T>` for buffer operations
- [ ] Use `ArrayPool<T>` for temporary buffers
- [ ] Minimize boxing of value types
- [ ] Use `ValueTask` for frequently called async methods

```csharp
// ArrayPool example
var buffer = ArrayPool<byte>.Shared.Rent(1024);
try
{
    // Use buffer
}
finally
{
    ArrayPool<byte>.Shared.Return(buffer);
}
```

### Object Pooling
- [ ] Implement object pooling for expensive-to-create objects
- [ ] Use `ObjectPool<T>` for frequently allocated objects
- [ ] Pool HTTP clients and database connections
- [ ] Monitor pool effectiveness

### Garbage Collection
- [ ] Monitor GC pressure and frequency
- [ ] Minimize large object heap allocations
- [ ] Use generations appropriately
- [ ] Consider server GC mode for server applications

## 🚀 Advanced Caching Strategies

### Multi-Level Caching
- [ ] Implement L1 (memory) and L2 (distributed) caching
- [ ] Use cache-aside pattern appropriately
- [ ] Implement cache warming strategies
- [ ] Design proper cache invalidation

```csharp
// Multi-level caching pattern
public async Task<T> GetAsync<T>(string key)
{
    // Try L1 cache first
    if (_memoryCache.TryGetValue(key, out T value))
        return value;
    
    // Try L2 cache
    value = await _distributedCache.GetAsync<T>(key);
    if (value != null)
    {
        _memoryCache.Set(key, value, TimeSpan.FromMinutes(5));
        return value;
    }
    
    // Load from source
    // ...
}
```

### Cache Strategies
- [ ] Use appropriate cache expiration policies
- [ ] Implement cache tags for group invalidation
- [ ] Monitor cache hit ratios
- [ ] Use cache compression for large objects
- [ ] Implement cache warming for critical data

### Output Caching
- [ ] Implement output caching for appropriate endpoints
- [ ] Use vary-by headers correctly
- [ ] Configure cache policies appropriately
- [ ] Implement cache invalidation triggers

## ⚡ Asynchronous Programming

### Async Best Practices
- [ ] Use `async`/`await` correctly throughout the application
- [ ] Avoid blocking on async operations (`Result`, `Wait()`)
- [ ] Use `ConfigureAwait(false)` in library code
- [ ] Implement proper cancellation token usage
- [ ] Use `ValueTask` for hot paths

### Concurrency
- [ ] Implement parallel processing where appropriate
- [ ] Use `Parallel.ForEach` for CPU-bound work
- [ ] Implement proper synchronization primitives
- [ ] Avoid oversubscription

```csharp
// Parallel processing example
await Parallel.ForEachAsync(items, 
    new ParallelOptions { MaxDegreeOfParallelism = Environment.ProcessorCount },
    async (item, ct) =>
    {
        await ProcessItemAsync(item, ct);
    });
```

## 🌐 HTTP and Network Optimization

### Request/Response Optimization
- [ ] Implement HTTP/2 and HTTP/3 support
- [ ] Use appropriate HTTP status codes
- [ ] Implement proper ETag handling
- [ ] Use conditional requests (If-Modified-Since, If-None-Match)
- [ ] Minimize request/response sizes

### Connection Management
- [ ] Configure keep-alive appropriately
- [ ] Implement connection pooling for HTTP clients
- [ ] Use `HttpClientFactory` for HTTP clients
- [ ] Monitor connection metrics

### Content Delivery
- [ ] Implement CDN for static content
- [ ] Use appropriate content types and encodings
- [ ] Implement progressive loading for large content
- [ ] Use streaming for large responses

## 📊 Monitoring and Profiling

### Application Metrics
- [ ] Implement custom performance counters
- [ ] Monitor response times and throughput
- [ ] Track error rates and exceptions
- [ ] Monitor resource utilization (CPU, memory, disk, network)

### Profiling Tools
- [ ] Use Application Insights or similar APM tools
- [ ] Implement structured logging for performance events
- [ ] Use dotMemory for memory profiling
- [ ] Use PerfView for ETW tracing
- [ ] Implement custom diagnostics

```csharp
// Performance logging example
using var activity = ActivitySource.StartActivity("ProcessOrder");
activity?.SetTag("order.id", orderId);
activity?.SetTag("customer.id", customerId);

var stopwatch = Stopwatch.StartNew();
try
{
    var result = await ProcessOrderAsync(orderId);
    activity?.SetTag("order.status", "success");
    return result;
}
catch (Exception ex)
{
    activity?.SetTag("order.status", "error");
    activity?.SetTag("error.message", ex.Message);
    throw;
}
finally
{
    _logger.LogInformation("Order processed in {Duration}ms", stopwatch.ElapsedMilliseconds);
}
```

### Benchmarking
- [ ] Implement BenchmarkDotNet for micro-benchmarks
- [ ] Create load tests for critical paths
- [ ] Benchmark before and after optimizations
- [ ] Set up continuous performance testing

## 🏗️ Architecture and Design

### Design Patterns
- [ ] Implement proper separation of concerns
- [ ] Use repository and unit of work patterns appropriately
- [ ] Implement CQRS for read/write separation
- [ ] Use event-driven architecture for decoupling

### Microservices Considerations
- [ ] Implement circuit breaker patterns
- [ ] Use bulkhead isolation
- [ ] Implement proper retry policies
- [ ] Monitor inter-service communication

### Database Design
- [ ] Normalize/denormalize appropriately
- [ ] Design efficient indexes
- [ ] Implement read replicas for scaling
- [ ] Use appropriate partitioning strategies

## 🔧 Configuration and Deployment

### Environment Configuration
- [ ] Configure appropriate thread pool sizes
- [ ] Set optimal garbage collection settings
- [ ] Configure connection pool sizes
- [ ] Optimize JIT compilation settings

```csharp
// GC configuration in .csproj
<PropertyGroup>
    <ServerGarbageCollection>true</ServerGarbageCollection>
    <ConcurrentGarbageCollection>true</ConcurrentGarbageCollection>
    <TieredCompilation>true</TieredCompilation>
</PropertyGroup>
```

### Docker Optimization
- [ ] Use minimal base images
- [ ] Implement multi-stage builds
- [ ] Configure appropriate resource limits
- [ ] Use health checks

### Load Balancing
- [ ] Implement sticky sessions where appropriate
- [ ] Configure proper load balancing algorithms
- [ ] Monitor load balancer metrics
- [ ] Implement graceful shutdown

## 📈 Continuous Improvement

### Performance Testing
- [ ] Implement automated performance tests
- [ ] Set up performance baselines
- [ ] Monitor performance regressions
- [ ] Create performance budgets

### Code Review
- [ ] Include performance considerations in code reviews
- [ ] Review database queries for efficiency
- [ ] Check for common anti-patterns
- [ ] Validate caching strategies

### Documentation
- [ ] Document performance requirements
- [ ] Create runbooks for performance issues
- [ ] Document optimization decisions
- [ ] Maintain performance metrics dashboards

## 🚨 Common Anti-Patterns to Avoid

### Database Anti-Patterns
- [ ] ❌ N+1 queries
- [ ] ❌ Loading entire entities when only specific fields are needed
- [ ] ❌ Using `Include()` unnecessarily
- [ ] ❌ Not using indexes appropriately
- [ ] ❌ Synchronous database calls in async methods

### Memory Anti-Patterns
- [ ] ❌ Excessive string concatenation
- [ ] ❌ Creating unnecessary temporary objects
- [ ] ❌ Not disposing of IDisposable objects
- [ ] ❌ Holding references to large objects
- [ ] ❌ Memory leaks in event handlers

### Async Anti-Patterns
- [ ] ❌ Blocking on async operations (`.Result`, `.Wait()`)
- [ ] ❌ Not using `ConfigureAwait(false)` in libraries
- [ ] ❌ Fire-and-forget async operations without proper error handling
- [ ] ❌ Overuse of `async void`
- [ ] ❌ Creating unnecessary Tasks

### Caching Anti-Patterns
- [ ] ❌ Caching everything without strategy
- [ ] ❌ Not implementing cache invalidation
- [ ] ❌ Using inappropriate cache durations
- [ ] ❌ Caching individual database entities instead of query results
- [ ] ❌ Not monitoring cache effectiveness

## 🎯 Performance Goals and Metrics

### Response Time Targets
- [ ] API endpoints: < 200ms for 95th percentile
- [ ] Database queries: < 100ms for 95th percentile
- [ ] Page load times: < 2 seconds for initial load
- [ ] Cache hit ratio: > 80% for frequently accessed data

### Throughput Targets
- [ ] Requests per second based on expected load
- [ ] Concurrent user capacity
- [ ] Database transactions per second
- [ ] Memory usage within acceptable limits

### Resource Utilization
- [ ] CPU utilization: < 70% average, < 90% peak
- [ ] Memory usage: < 80% of available memory
- [ ] Database connection pool: < 80% utilization
- [ ] Network bandwidth within capacity

## 📚 Tools and Resources

### Profiling Tools
- **JetBrains dotMemory**: Memory profiling
- **JetBrains dotTrace**: Performance profiling
- **PerfView**: ETW-based profiling
- **Application Insights**: APM and monitoring
- **MiniProfiler**: Database query profiling

### Benchmarking Tools
- **BenchmarkDotNet**: Micro-benchmarking
- **NBomber**: Load testing
- **k6**: Modern load testing
- **Artillery**: Simple load testing

### Monitoring Tools
- **Application Insights**: Comprehensive APM
- **Grafana + Prometheus**: Metrics visualization
- **ELK Stack**: Logging and analysis
- **New Relic**: APM and monitoring

## 🏁 Conclusion

Performance optimization is an iterative process. Start with the quick wins, then gradually implement more sophisticated optimizations based on your specific application's needs and bottlenecks.

Remember to:
1. **Measure first** - Don't optimize without data
2. **Focus on bottlenecks** - 80/20 rule applies
3. **Test thoroughly** - Ensure optimizations don't break functionality
4. **Monitor continuously** - Performance can degrade over time
5. **Document decisions** - Help future developers understand the optimizations

Use this checklist regularly during development and as part of your code review process to maintain optimal performance.
