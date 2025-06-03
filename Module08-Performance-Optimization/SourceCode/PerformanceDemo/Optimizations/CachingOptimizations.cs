using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Caching.Distributed;
using System.Text.Json;

namespace PerformanceDemo.Optimizations;

/// <summary>
/// Demonstrates various caching optimization techniques
/// </summary>
public class CachingOptimizations
{
    private readonly IMemoryCache _memoryCache;
    private readonly IDistributedCache _distributedCache;

    public CachingOptimizations(IMemoryCache memoryCache, IDistributedCache distributedCache)
    {
        _memoryCache = memoryCache;
        _distributedCache = distributedCache;
    }

    /// <summary>
    /// Basic memory caching with expiration
    /// </summary>
    public async Task<T> GetOrSetMemoryCacheAsync<T>(
        string key, 
        Func<Task<T>> getItem, 
        TimeSpan? slidingExpiration = null)
    {
        if (_memoryCache.TryGetValue(key, out T cachedValue))
        {
            return cachedValue;
        }

        var item = await getItem();
        
        var cacheEntryOptions = new MemoryCacheEntryOptions
        {
            SlidingExpiration = slidingExpiration ?? TimeSpan.FromMinutes(30),
            Priority = CacheItemPriority.Normal,
            Size = 1
        };

        _memoryCache.Set(key, item, cacheEntryOptions);
        return item;
    }

    /// <summary>
    /// Distributed caching with JSON serialization
    /// </summary>
    public async Task<T> GetOrSetDistributedCacheAsync<T>(
        string key, 
        Func<Task<T>> getItem, 
        TimeSpan? absoluteExpiration = null)
    {
        var cachedValue = await _distributedCache.GetStringAsync(key);
        if (cachedValue != null)
        {
            return JsonSerializer.Deserialize<T>(cachedValue);
        }

        var item = await getItem();
        var serializedItem = JsonSerializer.Serialize(item);
        
        var options = new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = absoluteExpiration ?? TimeSpan.FromHours(1)
        };

        await _distributedCache.SetStringAsync(key, serializedItem, options);
        return item;
    }

    /// <summary>
    /// Cache-aside pattern with fallback
    /// </summary>
    public async Task<T> GetWithCacheAsideAsync<T>(
        string key,
        Func<Task<T>> getFromSource,
        TimeSpan? memoryExpiration = null,
        TimeSpan? distributedExpiration = null)
    {
        // Try memory cache first (fastest)
        if (_memoryCache.TryGetValue(key, out T memoryValue))
        {
            return memoryValue;
        }

        // Try distributed cache second
        var distributedValue = await _distributedCache.GetStringAsync(key);
        if (distributedValue != null)
        {
            var deserializedValue = JsonSerializer.Deserialize<T>(distributedValue);
            
            // Populate memory cache from distributed cache
            _memoryCache.Set(key, deserializedValue, memoryExpiration ?? TimeSpan.FromMinutes(5));
            
            return deserializedValue;
        }

        // Finally, get from source
        var sourceValue = await getFromSource();
        
        // Store in both caches
        var serializedValue = JsonSerializer.Serialize(sourceValue);
        await _distributedCache.SetStringAsync(key, serializedValue, new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = distributedExpiration ?? TimeSpan.FromHours(1)
        });
        
        _memoryCache.Set(key, sourceValue, memoryExpiration ?? TimeSpan.FromMinutes(5));
        
        return sourceValue;
    }

    /// <summary>
    /// Bulk cache warming for frequently accessed data
    /// </summary>
    public async Task WarmCacheAsync<T>(
        Dictionary<string, Func<Task<T>>> dataProviders,
        TimeSpan? expiration = null)
    {
        var tasks = dataProviders.Select(async kvp =>
        {
            try
            {
                var data = await kvp.Value();
                _memoryCache.Set(kvp.Key, data, expiration ?? TimeSpan.FromMinutes(30));
            }
            catch (Exception ex)
            {
                // Log error but don't fail the entire warming process
                Console.WriteLine($"Failed to warm cache for key {kvp.Key}: {ex.Message}");
            }
        });

        await Task.WhenAll(tasks);
    }

    /// <summary>
    /// Invalidate cache entries by pattern
    /// </summary>
    public async Task InvalidateCacheByPatternAsync(string pattern)
    {
        // Note: This is a simplified example. In production, you'd need a more sophisticated
        // cache invalidation strategy, possibly using cache tags or a cache manager
        
        // For memory cache, you'd need to track keys or use a cache manager
        // For distributed cache (Redis), you could use SCAN with pattern matching
        
        // Example for Redis:
        // var server = _database.Multiplexer.GetServer(endpoint);
        // var keys = server.Keys(pattern: $"*{pattern}*");
        // await _distributedCache.RemoveAsync(keys);
        
        await Task.CompletedTask; // Placeholder
    }
}

/// <summary>
/// Advanced caching decorators for service methods
/// </summary>
public class CachingServiceDecorator<TService> where TService : class
{
    private readonly TService _service;
    private readonly IMemoryCache _cache;

    public CachingServiceDecorator(TService service, IMemoryCache cache)
    {
        _service = service;
        _cache = cache;
    }

    /// <summary>
    /// Generic method caching using reflection and expression trees
    /// </summary>
    public async Task<TResult> CacheMethodAsync<TResult>(
        string methodName,
        object[] parameters,
        TimeSpan? expiration = null)
    {
        var cacheKey = GenerateCacheKey(methodName, parameters);
        
        if (_cache.TryGetValue(cacheKey, out TResult cachedResult))
        {
            return cachedResult;
        }

        var method = typeof(TService).GetMethod(methodName);
        if (method == null)
        {
            throw new InvalidOperationException($"Method {methodName} not found on {typeof(TService).Name}");
        }

        var result = await (Task<TResult>)method.Invoke(_service, parameters);
        
        _cache.Set(cacheKey, result, expiration ?? TimeSpan.FromMinutes(15));
        
        return result;
    }

    private static string GenerateCacheKey(string methodName, object[] parameters)
    {
        var paramString = string.Join("_", parameters?.Select(p => p?.ToString() ?? "null") ?? Array.Empty<string>());
        return $"{typeof(TService).Name}_{methodName}_{paramString}";
    }
}
