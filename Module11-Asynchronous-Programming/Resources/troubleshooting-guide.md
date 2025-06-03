# Troubleshooting Async Code Guide

## Overview
This comprehensive guide helps you identify, diagnose, and fix common issues in asynchronous code. It covers deadlocks, performance problems, exception handling issues, and debugging techniques.

## Common Problems and Solutions

### 1. Deadlocks

#### Problem: Classic Async Deadlock
```csharp
// This code will deadlock in certain contexts
public void DeadlockExample()
{
    var result = GetDataAsync().Result; // DEADLOCK!
}

public async Task<string> GetDataAsync()
{
    await Task.Delay(1000);
    return "Data";
}
```

#### Root Cause:
- The calling thread blocks waiting for the async operation
- The async operation tries to resume on the original synchronization context
- The original thread is blocked, creating a deadlock

#### Solutions:

**✅ Solution 1: Use async all the way**
```csharp
public async Task CorrectAsyncExample()
{
    var result = await GetDataAsync(); // No deadlock
}
```

**✅ Solution 2: Use ConfigureAwait(false)**
```csharp
public async Task<string> GetDataAsync()
{
    await Task.Delay(1000).ConfigureAwait(false);
    return "Data";
}

// Now this is safer (but still not recommended)
public void SyncCaller()
{
    var result = GetDataAsync().Result;
}
```

**✅ Solution 3: Use Task.Run for CPU-bound work**
```csharp
public void SyncCaller()
{
    var result = Task.Run(async () => await GetDataAsync()).Result;
}
```

### 2. Exception Handling Issues

#### Problem: Unobserved Task Exceptions
```csharp
public void FireAndForgetProblem()
{
    DoWorkAsync(); // Exception will be unobserved!
}

public async Task DoWorkAsync()
{
    await Task.Delay(100);
    throw new InvalidOperationException("Something went wrong");
}
```

#### Solutions:

**✅ Solution 1: Proper fire-and-forget**
```csharp
public void SafeFireAndForget()
{
    _ = DoWorkSafelyAsync();
}

private async Task DoWorkSafelyAsync()
{
    try
    {
        await DoWorkAsync();
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Background work failed");
        // Handle or ignore as appropriate
    }
}
```

**✅ Solution 2: Use background service for long-running tasks**
```csharp
public class BackgroundWorkService : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await DoWorkAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Background work iteration failed");
                await Task.Delay(5000, stoppingToken); // Wait before retry
            }
        }
    }
}
```

#### Problem: Task.WhenAll Exception Handling
```csharp
public async Task ProblematicBatchProcessing()
{
    var tasks = items.Select(ProcessItemAsync);
    
    try
    {
        await Task.WhenAll(tasks); // Only gets first exception
    }
    catch (Exception ex)
    {
        // Only handles the first exception, others are lost
        _logger.LogError(ex, "Batch processing failed");
    }
}
```

**✅ Solution: Handle all exceptions**
```csharp
public async Task<BatchResult> SafeBatchProcessing<T>(IEnumerable<T> items)
{
    var tasks = items.Select(ProcessItemWithResultAsync).ToArray();
    
    await Task.WhenAll(tasks.Select(async task =>
    {
        try
        {
            await task;
        }
        catch
        {
            // Exceptions are handled in ProcessItemWithResultAsync
        }
    }));
    
    var results = tasks.Select(t => t.Result).ToList();
    return new BatchResult
    {
        SuccessCount = results.Count(r => r.Success),
        FailureCount = results.Count(r => !r.Success),
        Results = results
    };
}

private async Task<ProcessingResult> ProcessItemWithResultAsync<T>(T item)
{
    try
    {
        var result = await ProcessItemAsync(item);
        return ProcessingResult.Success(result);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Failed to process item {Item}", item);
        return ProcessingResult.Failure(ex.Message);
    }
}
```

### 3. Performance Issues

#### Problem: Thread Pool Starvation
```csharp
// This can cause thread pool starvation
public async Task BadConcurrentProcessing()
{
    var tasks = Enumerable.Range(0, 10000)
        .Select(i => Task.Run(() => CpuIntensiveWork(i))); // Too many tasks!
    
    await Task.WhenAll(tasks);
}
```

**✅ Solution: Controlled concurrency**
```csharp
public async Task BetterConcurrentProcessing()
{
    const int maxConcurrency = Environment.ProcessorCount;
    using var semaphore = new SemaphoreSlim(maxConcurrency);
    
    var tasks = Enumerable.Range(0, 10000).Select(async i =>
    {
        await semaphore.WaitAsync();
        try
        {
            return await Task.Run(() => CpuIntensiveWork(i));
        }
        finally
        {
            semaphore.Release();
        }
    });
    
    await Task.WhenAll(tasks);
}
```

#### Problem: Excessive Async Overhead
```csharp
// Unnecessary async overhead for simple operations
public async Task<int> AddAsync(int a, int b)
{
    return await Task.FromResult(a + b); // Wasteful!
}
```

**✅ Solution: Use sync for simple operations**
```csharp
public int Add(int a, int b)
{
    return a + b; // Keep it simple
}

// Or use ValueTask if you sometimes need async
public ValueTask<int> AddAsync(int a, int b, bool useCache = false)
{
    if (useCache && _cache.TryGetValue((a, b), out var cached))
        return ValueTask.FromResult(cached);
    
    return new ValueTask<int>(ComputeAndCacheAsync(a, b));
}
```

### 4. Memory Leaks and Resource Issues

#### Problem: Not Disposing Resources
```csharp
public async Task ProblematicHttpCall()
{
    var client = new HttpClient(); // Not disposed!
    var response = await client.GetStringAsync("https://api.example.com");
    return response;
}
```

**✅ Solution: Proper resource management**
```csharp
// Option 1: Dependency injection (recommended)
public class ApiService
{
    private readonly HttpClient _httpClient;
    
    public ApiService(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }
    
    public async Task<string> GetDataAsync()
    {
        return await _httpClient.GetStringAsync("https://api.example.com");
    }
}

// Option 2: Using statement
public async Task<string> GetDataWithUsingAsync()
{
    using var client = new HttpClient();
    return await client.GetStringAsync("https://api.example.com");
}
```

#### Problem: CancellationToken Not Disposed
```csharp
public async Task ProblematicCancellation()
{
    var cts = new CancellationTokenSource(TimeSpan.FromSeconds(30));
    
    try
    {
        await LongRunningOperationAsync(cts.Token);
    }
    catch (OperationCanceledException)
    {
        // Handle cancellation
    }
    // CancellationTokenSource not disposed!
}
```

**✅ Solution: Always dispose CancellationTokenSource**
```csharp
public async Task ProperCancellation()
{
    using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(30));
    
    try
    {
        await LongRunningOperationAsync(cts.Token);
    }
    catch (OperationCanceledException)
    {
        // Handle cancellation
    }
}
```

### 5. Debugging Techniques

#### Visual Studio Debugging

**Enable async debugging:**
1. Go to Debug → Windows → Parallel Stacks
2. Enable "Show Async Call Stacks" in Call Stack window
3. Use "Tasks" window to view active tasks

**Debugging tips:**
```csharp
public async Task DebuggableAsyncMethod()
{
    _logger.LogDebug("Starting async operation");
    
    try
    {
        var result = await SomeAsyncOperation();
        _logger.LogDebug("Async operation completed successfully");
        return result;
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Async operation failed");
        throw; // Re-throw to preserve stack trace
    }
}
```

#### Custom Async Debugging Helper

```csharp
public static class AsyncDebugHelper
{
    private static readonly AsyncLocal<string> _correlationId = new();
    
    public static string CorrelationId
    {
        get => _correlationId.Value ?? GenerateId();
        set => _correlationId.Value = value;
    }
    
    public static IDisposable BeginScope(string operationName)
    {
        var originalId = CorrelationId;
        CorrelationId = $"{originalId}>{operationName}";
        
        return new DisposableAction(() => CorrelationId = originalId);
    }
    
    public static async Task<T> TraceAsync<T>(Func<Task<T>> operation, string operationName)
    {
        using var scope = BeginScope(operationName);
        var sw = Stopwatch.StartNew();
        
        try
        {
            Console.WriteLine($"[{CorrelationId}] Starting {operationName}");
            var result = await operation();
            Console.WriteLine($"[{CorrelationId}] Completed {operationName} in {sw.ElapsedMilliseconds}ms");
            return result;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[{CorrelationId}] Failed {operationName} after {sw.ElapsedMilliseconds}ms: {ex.Message}");
            throw;
        }
    }
    
    private static string GenerateId() => Guid.NewGuid().ToString("N")[..8];
}

// Usage
public async Task<string> TracedOperation()
{
    return await AsyncDebugHelper.TraceAsync(async () =>
    {
        await Task.Delay(1000);
        return "Result";
    }, "TracedOperation");
}
```

### 6. Performance Profiling

#### Built-in Diagnostics
```csharp
public class AsyncPerformanceTracker
{
    private static readonly ActivitySource ActivitySource = new("MyApp.AsyncOperations");
    
    public static async Task<T> TrackAsync<T>(Func<Task<T>> operation, string operationName)
    {
        using var activity = ActivitySource.StartActivity(operationName);
        var sw = Stopwatch.StartNew();
        
        try
        {
            var result = await operation();
            activity?.SetTag("success", "true");
            activity?.SetTag("duration_ms", sw.ElapsedMilliseconds);
            return result;
        }
        catch (Exception ex)
        {
            activity?.SetTag("success", "false");
            activity?.SetTag("error", ex.GetType().Name);
            activity?.SetTag("duration_ms", sw.ElapsedMilliseconds);
            throw;
        }
    }
}
```

#### Memory Diagnostics
```csharp
public class MemoryTracker
{
    public static async Task<T> TrackMemoryAsync<T>(Func<Task<T>> operation, string operationName)
    {
        var beforeGC = GC.CollectionCount(0) + GC.CollectionCount(1) + GC.CollectionCount(2);
        var beforeMemory = GC.GetTotalMemory(false);
        
        var result = await operation();
        
        var afterGC = GC.CollectionCount(0) + GC.CollectionCount(1) + GC.CollectionCount(2);
        var afterMemory = GC.GetTotalMemory(false);
        
        if (afterGC > beforeGC)
        {
            Console.WriteLine($"[MEMORY] {operationName} triggered {afterGC - beforeGC} GC collections");
        }
        
        if (afterMemory > beforeMemory + 1024 * 1024) // > 1MB
        {
            Console.WriteLine($"[MEMORY] {operationName} allocated {(afterMemory - beforeMemory) / 1024.0 / 1024.0:F2} MB");
        }
        
        return result;
    }
}
```

### 7. Testing Async Code

#### Testing Timeouts
```csharp
[Fact]
public async Task AsyncOperation_ShouldTimeout_WhenTakingTooLong()
{
    using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(1));
    
    await Assert.ThrowsAsync<OperationCanceledException>(async () =>
    {
        await LongRunningOperationAsync(cts.Token);
    });
}
```

#### Testing Concurrent Operations
```csharp
[Fact]
public async Task ConcurrentOperations_ShouldNotCauseRaceConditions()
{
    const int concurrentTasks = 100;
    var counter = 0;
    var lockObject = new object();
    
    var tasks = Enumerable.Range(0, concurrentTasks).Select(async _ =>
    {
        await Task.Delay(Random.Shared.Next(1, 10));
        lock (lockObject)
        {
            counter++;
        }
    });
    
    await Task.WhenAll(tasks);
    
    Assert.Equal(concurrentTasks, counter);
}
```

#### Mock Async Dependencies
```csharp
[Fact]
public async Task Service_ShouldHandleAsyncDependencyFailure()
{
    var mockRepository = new Mock<IDataRepository>();
    mockRepository.Setup(r => r.GetDataAsync(It.IsAny<int>()))
              .ThrowsAsync(new InvalidOperationException("Database error"));
    
    var service = new DataService(mockRepository.Object);
    
    var result = await service.GetDataSafelyAsync(1);
    
    Assert.False(result.Success);
    Assert.Contains("Database error", result.ErrorMessage);
}
```

## Diagnostic Tools

### 1. .NET Diagnostic Tools

**dotnet-counters** - Monitor performance counters:
```bash
dotnet-counters monitor --process-id <PID> --counters System.Runtime,Microsoft.AspNetCore.Hosting
```

**dotnet-trace** - Collect execution traces:
```bash
dotnet-trace collect --process-id <PID> --duration 00:00:30
```

**dotnet-dump** - Capture memory dumps:
```bash
dotnet-dump collect --process-id <PID>
```

### 2. Custom Health Checks

```csharp
public class AsyncOperationHealthCheck : IHealthCheck
{
    private readonly IAsyncService _asyncService;
    
    public AsyncOperationHealthCheck(IAsyncService asyncService)
    {
        _asyncService = asyncService;
    }
    
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context, 
        CancellationToken cancellationToken = default)
    {
        try
        {
            using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
            cts.CancelAfter(TimeSpan.FromSeconds(5));
            
            await _asyncService.HealthCheckAsync(cts.Token);
            
            return HealthCheckResult.Healthy("Async service is responsive");
        }
        catch (OperationCanceledException)
        {
            return HealthCheckResult.Unhealthy("Async service timed out");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy($"Async service failed: {ex.Message}");
        }
    }
}
```

## Common Symptoms and Quick Fixes

| Symptom | Likely Cause | Quick Fix |
|---------|--------------|-----------|
| Application hangs | Deadlock from blocking on async | Use async all the way down |
| High memory usage | Task leaks or not disposing resources | Check for proper disposal and cancellation |
| Poor performance | Excessive async overhead | Use sync for simple operations |
| Unhandled exceptions | Fire-and-forget async calls | Wrap in try-catch or use background service |
| Thread pool starvation | Too many concurrent Task.Run calls | Use SemaphoreSlim to limit concurrency |
| Slow response times | Sequential async operations | Use Task.WhenAll for concurrent operations |
| Timeout errors | No cancellation token support | Add CancellationToken parameters |

## Emergency Debugging Checklist

When async code is behaving unexpectedly:

1. ✅ **Check for deadlocks**: Look for .Result or .Wait() calls
2. ✅ **Verify exception handling**: Ensure all async calls are in try-catch
3. ✅ **Monitor thread pool**: Check if thread pool is starved
4. ✅ **Check resource disposal**: Verify using statements or DI lifetime
5. ✅ **Validate cancellation**: Ensure CancellationTokens are passed through
6. ✅ **Review concurrency**: Look for race conditions in shared state
7. ✅ **Check async/await usage**: Verify proper async patterns
8. ✅ **Monitor memory**: Look for memory leaks or excessive allocations

This troubleshooting guide should help you quickly identify and resolve the most common async programming issues!