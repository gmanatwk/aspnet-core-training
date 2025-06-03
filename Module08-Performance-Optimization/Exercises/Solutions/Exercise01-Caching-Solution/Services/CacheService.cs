using System.Text.Json;
using Microsoft.Extensions.Caching.Distributed;

namespace CachingDemo.Services;

public interface ICacheService
{
    Task<T?> GetAsync<T>(string key) where T : class;
    Task SetAsync<T>(string key, T value, TimeSpan? expiry = null) where T : class;
    Task RemoveAsync(string key);
    Task RemoveByPatternAsync(string pattern);
}

public class RedisCacheService : ICacheService
{
    private readonly IDistributedCache _cache;
    private readonly ILogger<RedisCacheService> _logger;
    
    public RedisCacheService(
        IDistributedCache cache,
        ILogger<RedisCacheService> logger)
    {
        _cache = cache;
        _logger = logger;
    }
    
    public async Task<T?> GetAsync<T>(string key) where T : class
    {
        try
        {
            var cachedValue = await _cache.GetStringAsync(key);
            
            if (string.IsNullOrEmpty(cachedValue))
            {
                _logger.LogDebug("Cache miss for key: {Key}", key);
                return null;
            }
            
            _logger.LogDebug("Cache hit for key: {Key}", key);
            return JsonSerializer.Deserialize<T>(cachedValue);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting cache value for key: {Key}", key);
            return null;
        }
    }
    
    public async Task SetAsync<T>(string key, T value, TimeSpan? expiry = null) where T : class
    {
        try
        {
            var serializedValue = JsonSerializer.Serialize(value);
            
            var options = new DistributedCacheEntryOptions();
            
            if (expiry.HasValue)
            {
                options.AbsoluteExpirationRelativeToNow = expiry;
            }
            else
            {
                // Default expiration
                options.SlidingExpiration = TimeSpan.FromMinutes(15);
                options.AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1);
            }
            
            await _cache.SetStringAsync(key, serializedValue, options);
            _logger.LogDebug("Cache set for key: {Key}", key);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error setting cache value for key: {Key}", key);
        }
    }
    
    public async Task RemoveAsync(string key)
    {
        try
        {
            await _cache.RemoveAsync(key);
            _logger.LogDebug("Cache removed for key: {Key}", key);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error removing cache value for key: {Key}", key);
        }
    }
    
    public async Task RemoveByPatternAsync(string pattern)
    {
        // Note: This is a simplified implementation
        // In a real Redis implementation, you would use Redis SCAN with pattern matching
        _logger.LogWarning("RemoveByPatternAsync not fully implemented for distributed cache");
        await Task.CompletedTask;
    }
}

// Fallback implementation when Redis is not available
public class MemoryCacheService : ICacheService
{
    private readonly IMemoryCache _cache;
    private readonly ILogger<MemoryCacheService> _logger;
    
    public MemoryCacheService(
        IMemoryCache cache,
        ILogger<MemoryCacheService> logger)
    {
        _cache = cache;
        _logger = logger;
    }
    
    public Task<T?> GetAsync<T>(string key) where T : class
    {
        if (_cache.TryGetValue(key, out T? value))
        {
            _logger.LogDebug("Memory cache hit for key: {Key}", key);
            return Task.FromResult(value);
        }
        
        _logger.LogDebug("Memory cache miss for key: {Key}", key);
        return Task.FromResult<T?>(null);
    }
    
    public Task SetAsync<T>(string key, T value, TimeSpan? expiry = null) where T : class
    {
        var options = new MemoryCacheEntryOptions();
        
        if (expiry.HasValue)
        {
            options.AbsoluteExpirationRelativeToNow = expiry;
        }
        else
        {
            options.SlidingExpiration = TimeSpan.FromMinutes(15);
            options.AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1);
        }
        
        _cache.Set(key, value, options);
        _logger.LogDebug("Memory cache set for key: {Key}", key);
        
        return Task.CompletedTask;
    }
    
    public Task RemoveAsync(string key)
    {
        _cache.Remove(key);
        _logger.LogDebug("Memory cache removed for key: {Key}", key);
        return Task.CompletedTask;
    }
    
    public Task RemoveByPatternAsync(string pattern)
    {
        // Note: Memory cache doesn't support pattern-based removal easily
        _logger.LogWarning("RemoveByPatternAsync not implemented for memory cache");
        return Task.CompletedTask;
    }
}
