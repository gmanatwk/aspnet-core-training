# Exercise 1: Caching Implementation

## Objective
Implement different caching strategies in an ASP.NET Core application to improve response times and reduce database load.

## Prerequisites
- Visual Studio or Visual Studio Code
- .NET 8 SDK
- SQL Server or SQLite (for local database)
- Basic understanding of caching concepts

## Exercise Description

In this exercise, you will implement different caching mechanisms in an ASP.NET Core Web API project to optimize performance.

## Tasks

### 1. Setup the Project

1. Create a new ASP.NET Core Web API project:
   ```
   dotnet new webapi -n CachingDemo
   ```

2. Add the required NuGet packages:
   ```
   dotnet add package Microsoft.Extensions.Caching.Memory
   dotnet add package Microsoft.Extensions.Caching.StackExchangeRedis
   dotnet add package Microsoft.EntityFrameworkCore.SqlServer
   ```

3. Set up a basic product catalog API with controllers for:
   - Products
   - Categories
   - Orders

### 2. Implement In-Memory Caching

1. Configure in-memory caching in `Program.cs`:
   ```csharp
   builder.Services.AddMemoryCache();
   ```

2. Implement caching in the `ProductService`:
   ```csharp
   public class ProductService : IProductService
   {
       private readonly ApplicationDbContext _context;
       private readonly IMemoryCache _cache;
       private readonly ILogger<ProductService> _logger;
       
       // Cache keys
       private const string AllProductsCacheKey = "AllProducts";
       private const string ProductCacheKeyPrefix = "Product_";
       
       public ProductService(
           ApplicationDbContext context,
           IMemoryCache cache,
           ILogger<ProductService> logger)
       {
           _context = context;
           _cache = cache;
           _logger = logger;
       }
       
       public async Task<IEnumerable<Product>> GetAllProductsAsync()
       {
           // TODO: Implement caching logic here
           // 1. Try to get from cache first
           // 2. If not in cache, get from database
           // 3. Store in cache and return
       }
       
       public async Task<Product> GetProductByIdAsync(int id)
       {
           // TODO: Implement caching logic here with a cache key based on the ID
       }
       
       // Implement methods to invalidate cache when data changes
       private void InvalidateProductCache(int id)
       {
           _cache.Remove($"{ProductCacheKeyPrefix}{id}");
           _cache.Remove(AllProductsCacheKey);
       }
   }
   ```

3. Add cache expiration policies:
   ```csharp
   // Add to your GetAllProductsAsync method
   var cacheEntryOptions = new MemoryCacheEntryOptions()
       .SetSlidingExpiration(TimeSpan.FromMinutes(5))
       .SetAbsoluteExpiration(TimeSpan.FromHours(1));
       
   _cache.Set(AllProductsCacheKey, products, cacheEntryOptions);
   ```

### 3. Implement Distributed Caching with Redis

1. Configure Redis in `Program.cs` (use the Redis connection string from your configuration):
   ```csharp
   builder.Services.AddStackExchangeRedisCache(options =>
   {
       options.Configuration = builder.Configuration.GetConnectionString("RedisConnection");
       options.InstanceName = "CachingDemo:";
   });
   ```

2. Create a `DistributedCacheService` to abstract caching operations:
   ```csharp
   public interface ICacheService
   {
       Task<T?> GetAsync<T>(string key);
       Task SetAsync<T>(string key, T value, TimeSpan? expiry = null);
       Task RemoveAsync(string key);
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
       
       public async Task<T?> GetAsync<T>(string key)
       {
           // TODO: Implement Redis Get operation with serialization/deserialization
       }
       
       public async Task SetAsync<T>(string key, T value, TimeSpan? expiry = null)
       {
           // TODO: Implement Redis Set operation with serialization
       }
       
       public async Task RemoveAsync(string key)
       {
           // TODO: Implement Redis Remove operation
       }
   }
   ```

3. Update your services to use the new cache service.

### 4. Implement Response Caching

1. Configure response caching middleware in `Program.cs`:
   ```csharp
   builder.Services.AddResponseCaching();
   
   // Add to the middleware pipeline
   app.UseResponseCaching();
   ```

2. Add cache headers to your controller actions:
   ```csharp
   [HttpGet]
   [ResponseCache(Duration = 60, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "*" })]
   public async Task<ActionResult<IEnumerable<Product>>> GetProducts()
   {
       return Ok(await _productService.GetAllProductsAsync());
   }
   ```

### 5. Implement Output Caching (New in .NET 8)

1. Configure output caching in `Program.cs`:
   ```csharp
   builder.Services.AddOutputCache(options =>
   {
       // Configure default policy
       options.AddBasePolicy(builder => builder.Cache());
       
       // Add custom policy for products
       options.AddPolicy("Products", builder => 
           builder.Tag("products").Expire(TimeSpan.FromMinutes(10)));
   });
   
   // Add to the middleware pipeline
   app.UseOutputCache();
   ```

2. Apply output caching to your controllers:
   ```csharp
   [HttpGet]
   [OutputCache(PolicyName = "Products")]
   public async Task<ActionResult<IEnumerable<Product>>> GetProducts()
   {
       return Ok(await _productService.GetAllProductsAsync());
   }
   ```

3. Implement cache tag invalidation:
   ```csharp
   [HttpPost]
   public async Task<ActionResult<Product>> CreateProduct([FromBody] Product product)
   {
       var createdProduct = await _productService.CreateProductAsync(product);
       
       // Invalidate cache tags
       await _outputCacheStore.EvictByTagAsync("products", default);
       
       return CreatedAtAction(nameof(GetProduct), new { id = createdProduct.Id }, createdProduct);
   }
   ```

### 6. Benchmark Different Caching Strategies

1. Create a benchmark project using BenchmarkDotNet:
   ```
   dotnet new console -n CachingBenchmarks
   cd CachingBenchmarks
   dotnet add package BenchmarkDotNet
   ```

2. Create benchmark tests for different caching strategies:
   ```csharp
   [MemoryDiagnoser]
   [Orderer(SummaryOrderPolicy.FastestToSlowest)]
   [RankColumn]
   public class CachingBenchmarks
   {
       // TODO: Implement benchmarks to compare:
       // 1. No caching
       // 2. Memory caching
       // 3. Distributed caching
       // 4. Response caching
   }
   ```

## Expected Output

1. All caching implementations should be working correctly.
2. Benchmark results should show significant performance improvements with caching enabled.
3. The application should handle cache invalidation properly when data changes.

## Bonus Tasks

1. Implement cache serialization using different formats (JSON, MessagePack, etc.) and benchmark them.
2. Implement tiered caching (L1/L2 cache with both memory and Redis).
3. Add cache monitoring and metrics to track cache hit/miss rates.
4. Implement background cache warming for frequently accessed data.

## Submission

Submit your project with implementations of all caching strategies, including benchmark results.

## Evaluation Criteria

- Proper implementation of different caching strategies
- Correct cache invalidation logic
- Proper error handling and logging
- Benchmark results showing performance improvements
- Code quality and organization