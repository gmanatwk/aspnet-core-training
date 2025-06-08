using System.Diagnostics;

namespace AsyncDemo.Services;

public interface IAsyncBasicsService
{
    Task<string> GetDataAsync();
    Task<List<string>> GetMultipleDataAsync();
    Task<string> GetDataWithDelayAsync(int delayMs);
    Task<string> GetDataWithTimeoutAsync(int timeoutMs);
    Task<T> GetGenericDataAsync<T>(T data);
    ValueTask<int> GetCachedValueAsync(string key);
}

public class AsyncBasicsService : IAsyncBasicsService
{
    private readonly ILogger<AsyncBasicsService> _logger;
    private readonly HttpClient _httpClient;
    private readonly Dictionary<string, int> _cache = new();

    public AsyncBasicsService(ILogger<AsyncBasicsService> logger, HttpClient httpClient)
    {
        _logger = logger;
        _httpClient = httpClient;
    }

    /// <summary>
    /// Basic async method returning Task<string>
    /// </summary>
    public async Task<string> GetDataAsync()
    {
        _logger.LogInformation("Starting async data retrieval");

        // Simulate async work
        await Task.Delay(100);

        var result = $"Data retrieved at {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC";
        _logger.LogInformation("Async data retrieval completed");

        return result;
    }

    /// <summary>
    /// Async method with multiple concurrent operations
    /// </summary>
    public async Task<List<string>> GetMultipleDataAsync()
    {
        _logger.LogInformation("Starting multiple async operations");

        var tasks = new List<Task<string>>();

        // Create multiple async tasks
        for (int i = 0; i < 5; i++)
        {
            int index = i; // Capture loop variable
            tasks.Add(GetDataWithDelayAsync(100 + (index * 50)));
        }

        // Wait for all tasks to complete
        var results = await Task.WhenAll(tasks);

        _logger.LogInformation("All async operations completed");
        return results.ToList();
    }

    /// <summary>
    /// Async method with configurable delay
    /// </summary>
    public async Task<string> GetDataWithDelayAsync(int delayMs)
    {
        _logger.LogInformation("Starting async operation with {Delay}ms delay", delayMs);

        var stopwatch = Stopwatch.StartNew();

        // Use ConfigureAwait(false) for library code
        await Task.Delay(delayMs).ConfigureAwait(false);

        stopwatch.Stop();

        var result = $"Operation completed in {stopwatch.ElapsedMilliseconds}ms";
        _logger.LogInformation("Async operation with delay completed");

        return result;
    }

    /// <summary>
    /// Async method with timeout handling
    /// </summary>
    public async Task<string> GetDataWithTimeoutAsync(int timeoutMs)
    {
        _logger.LogInformation("Starting async operation with {Timeout}ms timeout", timeoutMs);

        using var cts = new CancellationTokenSource(TimeSpan.FromMilliseconds(timeoutMs));

        try
        {
            // Simulate work that might take longer than timeout
            await Task.Delay(timeoutMs + 100, cts.Token).ConfigureAwait(false);
            return "Operation completed successfully";
        }
        catch (OperationCanceledException)
        {
            _logger.LogWarning("Operation timed out after {Timeout}ms", timeoutMs);
            throw new TimeoutException($"Operation timed out after {timeoutMs}ms");
        }
    }

    /// <summary>
    /// Generic async method
    /// </summary>
    public async Task<T> GetGenericDataAsync<T>(T data)
    {
        _logger.LogInformation("Processing generic data of type {Type}", typeof(T).Name);

        // Simulate async processing
        await Task.Delay(50).ConfigureAwait(false);

        return data;
    }

    /// <summary>
    /// ValueTask example for performance optimization
    /// </summary>
    public ValueTask<int> GetCachedValueAsync(string key)
    {
        // If value is cached, return synchronously
        if (_cache.TryGetValue(key, out var cachedValue))
        {
            _logger.LogDebug("Cache hit for key: {Key}", key);
            return ValueTask.FromResult(cachedValue);
        }

        // Cache miss: compute asynchronously
        return ComputeAndCacheAsync(key);
    }

    private async ValueTask<int> ComputeAndCacheAsync(string key)
    {
        _logger.LogInformation("Cache miss - computing value for key: {Key}", key);

        // Simulate expensive computation
        await Task.Delay(200).ConfigureAwait(false);

        var value = key.GetHashCode() & 0x7FFFFFFF; // Simple hash-based value
        _cache[key] = value;

        return value;
    }
}
