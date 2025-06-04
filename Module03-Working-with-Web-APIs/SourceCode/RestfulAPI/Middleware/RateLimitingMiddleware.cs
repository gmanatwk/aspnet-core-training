using System.Net;
using Microsoft.Extensions.Caching.Memory;

namespace RestfulAPI.Middleware;

/// <summary>
/// Simple rate limiting middleware
/// </summary>
public class RateLimitingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IMemoryCache _cache;
    private readonly ILogger<RateLimitingMiddleware> _logger;

    // Configuration
    private const int RateLimit = 100; // requests per window
    private const int TimeWindowInSeconds = 60; // 1 minute

    public RateLimitingMiddleware(RequestDelegate next, IMemoryCache cache, 
        ILogger<RateLimitingMiddleware> logger)
    {
        _next = next;
        _cache = cache;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var endpoint = context.GetEndpoint();
        var rateLimitAttribute = endpoint?.Metadata.GetMetadata<EnableRateLimitingAttribute>();
        
        if (rateLimitAttribute == null)
        {
            await _next(context);
            return;
        }

        var key = GenerateClientKey(context);
        var requestCount = await UpdateRequestCount(key);

        if (requestCount > RateLimit)
        {
            _logger.LogWarning("Rate limit exceeded for client: {ClientKey}", key);
            
            context.Response.StatusCode = (int)HttpStatusCode.TooManyRequests;
            context.Response.Headers["X-RateLimit-Limit"] = RateLimit.ToString();
            context.Response.Headers["X-RateLimit-Remaining"] = "0";
            context.Response.Headers["X-RateLimit-Reset"] = GetResetTime().ToString();
            
            await context.Response.WriteAsync("Rate limit exceeded. Please try again later.");
            return;
        }

        context.Response.Headers["X-RateLimit-Limit"] = RateLimit.ToString();
        context.Response.Headers["X-RateLimit-Remaining"] = (RateLimit - requestCount).ToString();
        context.Response.Headers["X-RateLimit-Reset"] = GetResetTime().ToString();

        await _next(context);
    }

    private string GenerateClientKey(HttpContext context)
    {
        // Use IP address as key (in production, consider using authenticated user ID)
        var ipAddress = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        return $"rate_limit_{ipAddress}";
    }

    private async Task<int> UpdateRequestCount(string key)
    {
        var count = 1;
        
        if (_cache.TryGetValue(key, out int currentCount))
        {
            count = currentCount + 1;
        }

        var cacheEntryOptions = new MemoryCacheEntryOptions()
            .SetAbsoluteExpiration(TimeSpan.FromSeconds(TimeWindowInSeconds));

        _cache.Set(key, count, cacheEntryOptions);

        return count;
    }

    private long GetResetTime()
    {
        return DateTimeOffset.UtcNow.AddSeconds(TimeWindowInSeconds).ToUnixTimeSeconds();
    }
}

/// <summary>
/// Attribute to enable rate limiting on specific endpoints
/// </summary>
[AttributeUsage(AttributeTargets.Method | AttributeTargets.Class)]
public class EnableRateLimitingAttribute : Attribute
{
}