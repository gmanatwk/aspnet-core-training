# Async/Await Best Practices

## Overview
This guide provides comprehensive best practices for using async/await in ASP.NET Core applications. Following these guidelines will help you write efficient, maintainable, and scalable asynchronous code.

## Core Principles

### 1. Async All the Way Down ⬇️

**✅ DO:**
```csharp
public async Task<IActionResult> GetDataAsync()
{
    var data = await _service.GetDataAsync();
    var result = await ProcessDataAsync(data);
    return Ok(result);
}
```

**❌ DON'T:**
```csharp
public async Task<IActionResult> GetDataAsync()
{
    var data = _service.GetDataAsync().Result; // Blocking!
    var result = await ProcessDataAsync(data);
    return Ok(result);
}
```

### 2. Never Block on Async Code

**❌ Avoid these blocking patterns:**
```csharp
// .Result blocks the calling thread
var result = SomeAsyncMethod().Result;

// .Wait() blocks the calling thread
SomeAsyncMethod().Wait();

// .GetAwaiter().GetResult() also blocks
var result = SomeAsyncMethod().GetAwaiter().GetResult();
```

**✅ Use these async patterns:**
```csharp
// Proper async/await
var result = await SomeAsyncMethod();

// Multiple concurrent operations
var results = await Task.WhenAll(task1, task2, task3);
```

### 3. Avoid Async Void

**❌ DON'T use async void (except for event handlers):**
```csharp
public async void ProcessData() // Bad!
{
    await SomeAsyncOperation();
}
```

**✅ Use async Task instead:**
```csharp
public async Task ProcessDataAsync()
{
    await SomeAsyncOperation();
}

// For event handlers, async void is acceptable
private async void Button_Click(object sender, EventArgs e)
{
    await ProcessDataAsync();
}
```

## Configuration and Performance

### 4. ConfigureAwait Usage

**Library Code:**
```csharp
public async Task<string> GetDataAsync()
{
    // Use ConfigureAwait(false) in library code
    var response = await httpClient.GetAsync(url).ConfigureAwait(false);
    var content = await response.Content.ReadAsStringAsync().ConfigureAwait(false);
    return content;
}
```

**Application Code (ASP.NET Core):**
```csharp
public async Task<IActionResult> GetData()
{
    // No need for ConfigureAwait(false) in ASP.NET Core
    var data = await _service.GetDataAsync();
    return Ok(data);
}
```

### 5. Task vs Task<T> Return Types

**Use appropriate return types:**
```csharp
// No return value
public async Task SendEmailAsync(string to, string subject, string body)
{
    await _emailService.SendAsync(to, subject, body);
}

// With return value
public async Task<User> GetUserAsync(int id)
{
    return await _userRepository.GetByIdAsync(id);
}

// Consider ValueTask for frequently called methods
public async ValueTask<string> GetCachedDataAsync(string key)
{
    if (_cache.TryGetValue(key, out string? value))
        return value; // Synchronous completion
    
    return await FetchDataAsync(key);
}
```

## Concurrency Patterns

### 6. Concurrent Operations with Task.WhenAll

**✅ Good - Process items concurrently:**
```csharp
public async Task<List<UserProfile>> GetUserProfilesAsync(int[] userIds)
{
    var tasks = userIds.Select(id => GetUserProfileAsync(id));
    var profiles = await Task.WhenAll(tasks);
    return profiles.ToList();
}
```

**❌ Bad - Sequential processing:**
```csharp
public async Task<List<UserProfile>> GetUserProfilesAsync(int[] userIds)
{
    var profiles = new List<UserProfile>();
    foreach (var id in userIds)
    {
        var profile = await GetUserProfileAsync(id); // Sequential!
        profiles.Add(profile);
    }
    return profiles;
}
```

### 7. Handling Task.WhenAll Exceptions

**✅ Proper exception handling:**
```csharp
public async Task<List<string>> ProcessItemsAsync(string[] items)
{
    var tasks = items.Select(ProcessItemAsync);
    
    try
    {
        var results = await Task.WhenAll(tasks);
        return results.ToList();
    }
    catch
    {
        // Check individual task results
        var results = new List<string>();
        foreach (var task in tasks)
        {
            if (task.IsCompletedSuccessfully)
                results.Add(task.Result);
            else
                _logger.LogError(task.Exception, "Task failed");
        }
        return results;
    }
}
```

### 8. Task.WhenAny for First Completion

**Racing multiple operations:**
```csharp
public async Task<string> GetFastestResponseAsync(string[] urls)
{
    var tasks = urls.Select(url => httpClient.GetStringAsync(url));
    var completedTask = await Task.WhenAny(tasks);
    return await completedTask;
}
```

## Cancellation and Timeouts

### 9. Always Use CancellationTokens

**✅ Proper cancellation support:**
```csharp
public async Task<string> ProcessDataAsync(string data, CancellationToken cancellationToken = default)
{
    cancellationToken.ThrowIfCancellationRequested();
    
    var result = await LongRunningOperationAsync(data, cancellationToken);
    
    cancellationToken.ThrowIfCancellationRequested();
    
    return result;
}
```

**✅ Timeout with CancellationTokenSource:**
```csharp
public async Task<string> GetDataWithTimeoutAsync(string url)
{
    using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(30));
    
    try
    {
        return await httpClient.GetStringAsync(url, cts.Token);
    }
    catch (OperationCanceledException) when (cts.Token.IsCancellationRequested)
    {
        throw new TimeoutException("Request timed out after 30 seconds");
    }
}
```

### 10. Combining Cancellation Tokens

**✅ Combine multiple cancellation sources:**
```csharp
public async Task<string> ProcessWithMultipleCancellationAsync(
    string data, 
    CancellationToken requestToken,
    CancellationToken appShutdownToken)
{
    using var cts = CancellationTokenSource.CreateLinkedTokenSource(
        requestToken, 
        appShutdownToken);
    
    return await ProcessDataAsync(data, cts.Token);
}
```

## ASP.NET Core Specific

### 11. Controller Action Patterns

**✅ Async controller actions:**
```csharp
[HttpGet("{id}")]
public async Task<ActionResult<User>> GetUser(int id, CancellationToken cancellationToken)
{
    var user = await _userService.GetUserAsync(id, cancellationToken);
    
    if (user == null)
        return NotFound();
    
    return Ok(user);
}
```

### 12. Async Enumerable for Streaming

**✅ Stream large datasets:**
```csharp
[HttpGet("stream")]
public async IAsyncEnumerable<UserDto> StreamUsers(
    [EnumeratorCancellation] CancellationToken cancellationToken = default)
{
    await foreach (var user in _userService.GetUsersAsync(cancellationToken))
    {
        yield return MapToDto(user);
    }
}
```

### 13. Background Services

**✅ Proper background service implementation:**
```csharp
public class DataProcessingService : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessDataBatchAsync(stoppingToken);
                await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
            }
            catch (OperationCanceledException)
            {
                // Expected when cancellation is requested
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in background processing");
                await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
            }
        }
    }
}
```

## Error Handling

### 14. Exception Handling Best Practices

**✅ Proper async exception handling:**
```csharp
public async Task<Result<T>> SafeOperationAsync<T>(Func<Task<T>> operation)
{
    try
    {
        var result = await operation();
        return Result<T>.Success(result);
    }
    catch (ArgumentException ex)
    {
        _logger.LogWarning(ex, "Invalid argument in operation");
        return Result<T>.Failure("Invalid input provided");
    }
    catch (HttpRequestException ex)
    {
        _logger.LogError(ex, "HTTP request failed");
        return Result<T>.Failure("External service unavailable");
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Unexpected error in operation");
        return Result<T>.Failure("An unexpected error occurred");
    }
}
```

### 15. Retry Patterns

**✅ Async retry with exponential backoff:**
```csharp
public async Task<T> RetryAsync<T>(
    Func<Task<T>> operation,
    int maxAttempts = 3,
    TimeSpan? baseDelay = null)
{
    var delay = baseDelay ?? TimeSpan.FromSeconds(1);
    
    for (int attempt = 1; attempt <= maxAttempts; attempt++)
    {
        try
        {
            return await operation();
        }
        catch (Exception ex) when (attempt < maxAttempts && IsRetriableException(ex))
        {
            _logger.LogWarning("Attempt {Attempt} failed, retrying in {Delay}ms", 
                attempt, delay.TotalMilliseconds);
            
            await Task.Delay(delay);
            delay = TimeSpan.FromMilliseconds(delay.TotalMilliseconds * 2); // Exponential backoff
        }
    }
    
    // Final attempt without catching exceptions
    return await operation();
}
```

## Testing Async Code

### 16. Unit Testing Async Methods

**✅ Test async methods properly:**
```csharp
[Fact]
public async Task GetUserAsync_WhenUserExists_ReturnsUser()
{
    // Arrange
    var userId = 1;
    var expectedUser = new User { Id = userId, Name = "John" };
    _mockRepository.Setup(r => r.GetByIdAsync(userId))
                   .ReturnsAsync(expectedUser);
    
    // Act
    var result = await _userService.GetUserAsync(userId);
    
    // Assert
    Assert.Equal(expectedUser, result);
}

[Fact]
public async Task GetUserAsync_WhenCancelled_ThrowsOperationCanceledException()
{
    // Arrange
    using var cts = new CancellationTokenSource();
    cts.Cancel();
    
    // Act & Assert
    await Assert.ThrowsAsync<OperationCanceledException>(
        () => _userService.GetUserAsync(1, cts.Token));
}
```

## Performance Considerations

### 17. Memory and Performance

**✅ Efficient async patterns:**
```csharp
// Use ValueTask for frequently called methods that often complete synchronously
public ValueTask<string> GetCachedValueAsync(string key)
{
    if (_cache.TryGetValue(key, out var value))
        return ValueTask.FromResult(value);
    
    return new ValueTask<string>(FetchValueAsync(key));
}

// Use async enumerable for large datasets
public async IAsyncEnumerable<T> GetLargeDatasetAsync<T>(
    [EnumeratorCancellation] CancellationToken cancellationToken = default)
{
    await foreach (var item in _repository.StreamDataAsync(cancellationToken))
    {
        yield return item;
    }
}
```

### 18. Avoid Creating Unnecessary Tasks

**❌ Don't wrap synchronous operations in Task.Run:**
```csharp
public async Task<int> CalculateAsync(int value)
{
    // Bad - unnecessary Task.Run
    return await Task.Run(() => value * 2);
}
```

**✅ Use Task.FromResult for synchronous returns:**
```csharp
public Task<int> CalculateAsync(int value)
{
    var result = value * 2;
    return Task.FromResult(result);
}

// Or even better, make it synchronous if no async work is needed
public int Calculate(int value)
{
    return value * 2;
}
```

## Monitoring and Debugging

### 19. Logging Async Operations

**✅ Structured logging with correlation:**
```csharp
public async Task<User> GetUserAsync(int userId)
{
    using var scope = _logger.BeginScope("GetUser for {UserId}", userId);
    
    _logger.LogDebug("Starting user retrieval");
    
    try
    {
        var user = await _repository.GetUserAsync(userId);
        
        _logger.LogInformation("Successfully retrieved user {UserId}", userId);
        return user;
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Failed to retrieve user {UserId}", userId);
        throw;
    }
}
```

### 20. Async Debugging Tips

**✅ Use meaningful async method names:**
```csharp
// Good naming
public async Task<Order> ProcessOrderAsync(int orderId)
public async Task SendWelcomeEmailAsync(string email)
public async Task<List<Product>> SearchProductsAsync(string query)

// Avoid generic names
public async Task DoWorkAsync() // Too generic
public async Task ProcessAsync() // What is being processed?
```

## Common Anti-Patterns to Avoid

### ❌ Sync Over Async
```csharp
// Never do this!
public string GetData()
{
    return GetDataAsync().Result; // Deadlock risk!
}
```

### ❌ Async Over Sync
```csharp
// Don't wrap sync operations unnecessarily
public async Task<int> AddNumbers(int a, int b)
{
    return await Task.Run(() => a + b); // Unnecessary overhead
}
```

### ❌ Fire and Forget Without Error Handling
```csharp
// Dangerous - exceptions are lost
public void StartBackgroundWork()
{
    _ = DoBackgroundWorkAsync(); // Fire and forget - bad!
}

// Better approach
public void StartBackgroundWork()
{
    _ = Task.Run(async () =>
    {
        try
        {
            await DoBackgroundWorkAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Background work failed");
        }
    });
}
```

## Quick Reference Checklist

- ✅ Use async/await consistently throughout the call stack
- ✅ Never block on async code with .Result or .Wait()
- ✅ Avoid async void except for event handlers
- ✅ Use ConfigureAwait(false) in library code
- ✅ Always accept and honor CancellationTokens
- ✅ Use Task.WhenAll for concurrent operations
- ✅ Handle exceptions properly in async methods
- ✅ Use ValueTask for high-frequency methods
- ✅ Log async operations with correlation IDs
- ✅ Test async code thoroughly with various scenarios

Following these best practices will help you write robust, performant, and maintainable asynchronous code in your ASP.NET Core applications!