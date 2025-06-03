# Entity Framework Core Optimization Patterns

## Overview

This guide provides comprehensive patterns and techniques for optimizing Entity Framework Core performance in ASP.NET Core applications. These patterns are based on real-world scenarios and measurable performance improvements.

## Performance Optimization Patterns

### 1. Query Optimization Patterns

#### Pattern: Use AsNoTracking for Read-Only Queries
**When to use:** Read-only operations where you don't need change tracking

```csharp
// ❌ BAD - Unnecessary change tracking overhead
public async Task<List<ProductDto>> GetProductsForDisplayAsync()
{
    return await _context.Products
        .Include(p => p.Category)
        .Select(p => new ProductDto
        {
            Id = p.Id,
            Name = p.Name,
            Price = p.Price,
            CategoryName = p.Category.Name
        })
        .ToListAsync();
}

// ✅ GOOD - No tracking for read-only data
public async Task<List<ProductDto>> GetProductsForDisplayAsync()
{
    return await _context.Products
        .AsNoTracking()
        .Include(p => p.Category)
        .Select(p => new ProductDto
        {
            Id = p.Id,
            Name = p.Name,
            Price = p.Price,
            CategoryName = p.Category.Name
        })
        .ToListAsync();
}

// 🚀 BEST - Projection eliminates the need for Include
public async Task<List<ProductDto>> GetProductsForDisplayOptimizedAsync()
{
    return await _context.Products
        .Select(p => new ProductDto
        {
            Id = p.Id,
            Name = p.Name,
            Price = p.Price,
            CategoryName = p.Category.Name // EF Core will join automatically
        })
        .ToListAsync();
}
```

**Performance Impact:** 30-50% improvement in memory usage and query speed

#### Pattern: Projection Over Include
**When to use:** When you need only specific fields from related entities

```csharp
// ❌ BAD - Loads entire entities
public async Task<List<OrderSummaryDto>> GetOrderSummariesAsync()
{
    return await _context.Orders
        .Include(o => o.Customer)
        .Include(o => o.OrderItems)
            .ThenInclude(oi => oi.Product)
        .Select(o => new OrderSummaryDto
        {
            Id = o.Id,
            CustomerName = o.Customer.Name,
            OrderDate = o.OrderDate,
            TotalAmount = o.TotalAmount,
            ItemCount = o.OrderItems.Count
        })
        .ToListAsync();
}

// ✅ GOOD - Direct projection, no unnecessary data loading
public async Task<List<OrderSummaryDto>> GetOrderSummariesOptimizedAsync()
{
    return await _context.Orders
        .Select(o => new OrderSummaryDto
        {
            Id = o.Id,
            CustomerName = o.Customer.Name,
            OrderDate = o.OrderDate,
            TotalAmount = o.TotalAmount,
            ItemCount = o.OrderItems.Count()
        })
        .ToListAsync();
}
```

**Performance Impact:** 60-80% reduction in data transfer and memory usage

#### Pattern: Compiled Queries for Repetitive Operations
**When to use:** Frequently executed queries with parameters

```csharp
public class ProductRepository
{
    // Compiled query for frequently used operation
    private static readonly Func<AppDbContext, int, Task<Product?>> GetProductByIdQuery =
        EF.CompileAsyncQuery((AppDbContext context, int id) =>
            context.Products
                .Include(p => p.Category)
                .FirstOrDefault(p => p.Id == id));

    private static readonly Func<AppDbContext, string, IAsyncEnumerable<Product>> GetProductsByNameQuery =
        EF.CompileAsyncQuery((AppDbContext context, string name) =>
            context.Products
                .Where(p => p.Name.Contains(name))
                .AsNoTracking());

    private static readonly Func<AppDbContext, int, int, IAsyncEnumerable<Product>> GetProductsPageQuery =
        EF.CompileAsyncQuery((AppDbContext context, int skip, int take) =>
            context.Products
                .AsNoTracking()
                .OrderBy(p => p.Name)
                .Skip(skip)
                .Take(take));

    public async Task<Product?> GetByIdAsync(int id)
    {
        return await GetProductByIdQuery(_context, id);
    }

    public IAsyncEnumerable<Product> GetByNameAsync(string name)
    {
        return GetProductsByNameQuery(_context, name);
    }

    public IAsyncEnumerable<Product> GetPageAsync(int pageNumber, int pageSize)
    {
        return GetProductsPageQuery(_context, (pageNumber - 1) * pageSize, pageSize);
    }
}
```

**Performance Impact:** 20-40% improvement in query execution time

### 2. N+1 Query Problem Solutions

#### Pattern: Solving N+1 with Include
```csharp
// ❌ BAD - N+1 Query Problem
public async Task<List<OrderDto>> GetOrdersWithCustomersAsync()
{
    var orders = await _context.Orders.ToListAsync();
    
    var orderDtos = new List<OrderDto>();
    foreach (var order in orders)
    {
        // This executes N additional queries!
        var customer = await _context.Customers.FindAsync(order.CustomerId);
        orderDtos.Add(new OrderDto
        {
            Id = order.Id,
            CustomerName = customer.Name,
            OrderDate = order.OrderDate
        });
    }
    
    return orderDtos;
}

// ✅ GOOD - Single query with Include
public async Task<List<OrderDto>> GetOrdersWithCustomersOptimizedAsync()
{
    return await _context.Orders
        .Include(o => o.Customer)
        .Select(o => new OrderDto
        {
            Id = o.Id,
            CustomerName = o.Customer.Name,
            OrderDate = o.OrderDate
        })
        .ToListAsync();
}
```

#### Pattern: Batch Loading for Complex Scenarios
```csharp
// ✅ GOOD - Batch loading approach
public async Task<List<ProductWithReviewsDto>> GetProductsWithRecentReviewsAsync()
{
    // Load products first
    var products = await _context.Products
        .AsNoTracking()
        .ToListAsync();

    var productIds = products.Select(p => p.Id).ToList();

    // Batch load reviews
    var reviewsLookup = await _context.Reviews
        .AsNoTracking()
        .Where(r => productIds.Contains(r.ProductId))
        .Where(r => r.CreatedDate >= DateTime.UtcNow.AddDays(-30))
        .ToLookup(r => r.ProductId);

    return products.Select(p => new ProductWithReviewsDto
    {
        Id = p.Id,
        Name = p.Name,
        RecentReviews = reviewsLookup[p.Id].Select(r => new ReviewDto
        {
            Rating = r.Rating,
            Comment = r.Comment,
            CreatedDate = r.CreatedDate
        }).ToList()
    }).ToList();
}
```

### 3. Query Splitting Patterns

#### Pattern: Splitting Complex Queries
**When to use:** Complex queries with multiple includes that generate cartesian products

```csharp
// ❌ BAD - Cartesian product in single query
public async Task<List<ProductDetailDto>> GetProductsWithAllDetailsAsync()
{
    return await _context.Products
        .Include(p => p.Category)
        .Include(p => p.Reviews)
        .Include(p => p.OrderItems)
            .ThenInclude(oi => oi.Order)
        .Include(p => p.ProductTags)
            .ThenInclude(pt => pt.Tag)
        .Select(p => new ProductDetailDto
        {
            Id = p.Id,
            Name = p.Name,
            CategoryName = p.Category.Name,
            ReviewCount = p.Reviews.Count,
            OrderCount = p.OrderItems.Select(oi => oi.Order).Distinct().Count(),
            Tags = p.ProductTags.Select(pt => pt.Tag.Name).ToList()
        })
        .ToListAsync();
}

// ✅ GOOD - Split into multiple queries
public async Task<List<ProductDetailDto>> GetProductsWithAllDetailsSplitAsync()
{
    return await _context.Products
        .AsSplitQuery()
        .Include(p => p.Category)
        .Include(p => p.Reviews)
        .Include(p => p.OrderItems)
            .ThenInclude(oi => oi.Order)
        .Include(p => p.ProductTags)
            .ThenInclude(pt => pt.Tag)
        .Select(p => new ProductDetailDto
        {
            Id = p.Id,
            Name = p.Name,
            CategoryName = p.Category.Name,
            ReviewCount = p.Reviews.Count,
            OrderCount = p.OrderItems.Select(oi => oi.Order).Distinct().Count(),
            Tags = p.ProductTags.Select(pt => pt.Tag.Name).ToList()
        })
        .ToListAsync();
}

// 🚀 BEST - Manual splitting with projections
public async Task<List<ProductDetailDto>> GetProductsWithAllDetailsManualSplitAsync()
{
    var products = await _context.Products
        .AsNoTracking()
        .Select(p => new
        {
            p.Id,
            p.Name,
            CategoryName = p.Category.Name
        })
        .ToListAsync();

    var productIds = products.Select(p => p.Id).ToList();

    var reviewCounts = await _context.Reviews
        .Where(r => productIds.Contains(r.ProductId))
        .GroupBy(r => r.ProductId)
        .Select(g => new { ProductId = g.Key, Count = g.Count() })
        .ToDictionaryAsync(x => x.ProductId, x => x.Count);

    var orderCounts = await _context.OrderItems
        .Where(oi => productIds.Contains(oi.ProductId))
        .GroupBy(oi => oi.ProductId)
        .Select(g => new { ProductId = g.Key, Count = g.Select(oi => oi.OrderId).Distinct().Count() })
        .ToDictionaryAsync(x => x.ProductId, x => x.Count);

    var productTags = await _context.ProductTags
        .Where(pt => productIds.Contains(pt.ProductId))
        .Select(pt => new { pt.ProductId, TagName = pt.Tag.Name })
        .ToLookup(pt => pt.ProductId, pt => pt.TagName);

    return products.Select(p => new ProductDetailDto
    {
        Id = p.Id,
        Name = p.Name,
        CategoryName = p.CategoryName,
        ReviewCount = reviewCounts.GetValueOrDefault(p.Id, 0),
        OrderCount = orderCounts.GetValueOrDefault(p.Id, 0),
        Tags = productTags[p.Id].ToList()
    }).ToList();
}
```

### 4. Bulk Operations Patterns

#### Pattern: Efficient Bulk Insert
```csharp
// ❌ BAD - Individual inserts
public async Task AddProductsAsync(List<Product> products)
{
    foreach (var product in products)
    {
        _context.Products.Add(product);
        await _context.SaveChangesAsync(); // N database round trips
    }
}

// ✅ GOOD - Batch insert
public async Task AddProductsBatchAsync(List<Product> products)
{
    _context.Products.AddRange(products);
    await _context.SaveChangesAsync(); // Single database round trip
}

// 🚀 BEST - Chunked batch insert for large datasets
public async Task AddProductsChunkedAsync(List<Product> products)
{
    const int chunkSize = 1000;
    
    for (int i = 0; i < products.Count; i += chunkSize)
    {
        var chunk = products.Skip(i).Take(chunkSize);
        _context.Products.AddRange(chunk);
        await _context.SaveChangesAsync();
        _context.ChangeTracker.Clear(); // Clear tracking to free memory
    }
}
```

#### Pattern: Bulk Update and Delete (EF Core 7+)
```csharp
// ✅ Efficient bulk update
public async Task UpdateProductPricesAsync(decimal percentage)
{
    await _context.Products
        .Where(p => p.IsActive)
        .ExecuteUpdateAsync(setters => setters
            .SetProperty(p => p.Price, p => p.Price * (1 + percentage / 100))
            .SetProperty(p => p.UpdatedAt, DateTime.UtcNow));
}

// ✅ Efficient bulk delete
public async Task DeleteInactiveProductsAsync(DateTime cutoffDate)
{
    await _context.Products
        .Where(p => !p.IsActive && p.CreatedAt < cutoffDate)
        .ExecuteDeleteAsync();
}
```

### 5. Advanced Querying Patterns

#### Pattern: Efficient Pagination
```csharp
// ❌ BAD - Count query every time
public async Task<PagedResult<ProductDto>> GetProductsPageBadAsync(int pageNumber, int pageSize)
{
    var totalCount = await _context.Products.CountAsync();
    var products = await _context.Products
        .Skip((pageNumber - 1) * pageSize)
        .Take(pageSize)
        .Select(p => new ProductDto { Id = p.Id, Name = p.Name })
        .ToListAsync();

    return new PagedResult<ProductDto>
    {
        Items = products,
        TotalCount = totalCount,
        PageNumber = pageNumber,
        PageSize = pageSize
    };
}

// ✅ GOOD - Cached count for better performance
public async Task<PagedResult<ProductDto>> GetProductsPageOptimizedAsync(int pageNumber, int pageSize, bool includeCount = false)
{
    var query = _context.Products.AsNoTracking();
    
    var products = await query
        .Skip((pageNumber - 1) * pageSize)
        .Take(pageSize)
        .Select(p => new ProductDto { Id = p.Id, Name = p.Name })
        .ToListAsync();

    int? totalCount = null;
    if (includeCount)
    {
        totalCount = await _cache.GetOrCreateAsync("products_total_count", async entry =>
        {
            entry.SetAbsoluteExpiration(TimeSpan.FromMinutes(10));
            return await query.CountAsync();
        });
    }

    return new PagedResult<ProductDto>
    {
        Items = products,
        TotalCount = totalCount,
        PageNumber = pageNumber,
        PageSize = pageSize
    };
}

// 🚀 BEST - Cursor-based pagination for large datasets
public async Task<CursorPagedResult<ProductDto>> GetProductsCursorPagedAsync(int? lastId, int pageSize)
{
    var query = _context.Products.AsNoTracking();
    
    if (lastId.HasValue)
    {
        query = query.Where(p => p.Id > lastId.Value);
    }
    
    var products = await query
        .OrderBy(p => p.Id)
        .Take(pageSize + 1) // Take one extra to determine if there are more pages
        .Select(p => new ProductDto { Id = p.Id, Name = p.Name })
        .ToListAsync();
    
    var hasNextPage = products.Count > pageSize;
    if (hasNextPage)
    {
        products.RemoveAt(products.Count - 1);
    }
    
    return new CursorPagedResult<ProductDto>
    {
        Items = products,
        HasNextPage = hasNextPage,
        NextCursor = products.LastOrDefault()?.Id
    };
}
```

#### Pattern: Filtered and Sorted Queries
```csharp
public class ProductQueryParameters
{
    public string? SearchTerm { get; set; }
    public int? CategoryId { get; set; }
    public decimal? MinPrice { get; set; }
    public decimal? MaxPrice { get; set; }
    public bool? IsActive { get; set; }
    public string SortBy { get; set; } = "Name";
    public bool SortDescending { get; set; }
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}

public async Task<PagedResult<ProductDto>> GetProductsAsync(ProductQueryParameters parameters)
{
    var query = _context.Products.AsNoTracking();

    // Apply filters
    if (!string.IsNullOrEmpty(parameters.SearchTerm))
    {
        query = query.Where(p => p.Name.Contains(parameters.SearchTerm) 
                              || p.Description.Contains(parameters.SearchTerm));
    }

    if (parameters.CategoryId.HasValue)
    {
        query = query.Where(p => p.CategoryId == parameters.CategoryId.Value);
    }

    if (parameters.MinPrice.HasValue)
    {
        query = query.Where(p => p.Price >= parameters.MinPrice.Value);
    }

    if (parameters.MaxPrice.HasValue)
    {
        query = query.Where(p => p.Price <= parameters.MaxPrice.Value);
    }

    if (parameters.IsActive.HasValue)
    {
        query = query.Where(p => p.IsActive == parameters.IsActive.Value);
    }

    // Apply sorting
    query = parameters.SortBy.ToLower() switch
    {
        "name" => parameters.SortDescending ? query.OrderByDescending(p => p.Name) : query.OrderBy(p => p.Name),
        "price" => parameters.SortDescending ? query.OrderByDescending(p => p.Price) : query.OrderBy(p => p.Price),
        "createdat" => parameters.SortDescending ? query.OrderByDescending(p => p.CreatedAt) : query.OrderBy(p => p.CreatedAt),
        _ => query.OrderBy(p => p.Name)
    };

    // Get total count for pagination
    var totalCount = await query.CountAsync();

    // Apply pagination
    var products = await query
        .Skip((parameters.PageNumber - 1) * parameters.PageSize)
        .Take(parameters.PageSize)
        .Select(p => new ProductDto
        {
            Id = p.Id,
            Name = p.Name,
            Price = p.Price,
            CategoryName = p.Category.Name,
            IsActive = p.IsActive
        })
        .ToListAsync();

    return new PagedResult<ProductDto>
    {
        Items = products,
        TotalCount = totalCount,
        PageNumber = parameters.PageNumber,
        PageSize = parameters.PageSize
    };
}
```

### 6. Connection and Context Management

#### Pattern: DbContext Factory for Better Concurrency
```csharp
// Register DbContext Factory
services.AddDbContextFactory<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

// Use in services
public class ProductService
{
    private readonly IDbContextFactory<AppDbContext> _contextFactory;

    public ProductService(IDbContextFactory<AppDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public async Task<Product?> GetProductAsync(int id)
    {
        using var context = _contextFactory.CreateDbContext();
        return await context.Products.FindAsync(id);
    }

    public async Task<List<Product>> ProcessProductsInParallelAsync(List<int> productIds)
    {
        var tasks = productIds.Select(async id =>
        {
            using var context = _contextFactory.CreateDbContext();
            return await context.Products
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.Id == id);
        });

        var results = await Task.WhenAll(tasks);
        return results.Where(p => p != null).ToList()!;
    }
}
```

#### Pattern: Connection Pooling Optimization
```csharp
// Configure connection pool
services.AddDbContext<AppDbContext>(options =>
{
    options.UseSqlServer(connectionString, sqlOptions =>
    {
        sqlOptions.CommandTimeout(30); // Command timeout
        sqlOptions.EnableRetryOnFailure(3); // Retry logic
    });
}, ServiceLifetime.Scoped);

// Configure connection pool settings in connection string
var connectionString = "Server=server;Database=db;Integrated Security=true;" +
                      "Max Pool Size=100;" +
                      "Min Pool Size=5;" +
                      "Connection Lifetime=300;" +
                      "Connection Timeout=30;";
```

### 7. Raw SQL and Stored Procedures

#### Pattern: Raw SQL for Complex Queries
```csharp
public async Task<List<SalesReportDto>> GetSalesReportAsync(DateTime startDate, DateTime endDate)
{
    // Complex aggregation better suited for raw SQL
    var sql = @"
        SELECT 
            p.CategoryId,
            c.Name as CategoryName,
            COUNT(DISTINCT o.Id) as OrderCount,
            SUM(oi.Quantity * oi.UnitPrice) as TotalSales,
            AVG(oi.UnitPrice) as AveragePrice
        FROM Orders o
        INNER JOIN OrderItems oi ON o.Id = oi.OrderId
        INNER JOIN Products p ON oi.ProductId = p.Id
        INNER JOIN Categories c ON p.CategoryId = c.Id
        WHERE o.OrderDate >= @startDate AND o.OrderDate < @endDate
        GROUP BY p.CategoryId, c.Name
        ORDER BY TotalSales DESC";

    return await _context.Database
        .SqlQueryRaw<SalesReportDto>(sql, 
            new SqlParameter("@startDate", startDate),
            new SqlParameter("@endDate", endDate))
        .ToListAsync();
}
```

#### Pattern: Calling Stored Procedures
```csharp
public async Task<List<ProductRecommendationDto>> GetProductRecommendationsAsync(int customerId, int count)
{
    var customerIdParam = new SqlParameter("@CustomerId", customerId);
    var countParam = new SqlParameter("@Count", count);

    return await _context.Set<ProductRecommendationDto>()
        .FromSqlRaw("EXEC GetProductRecommendations @CustomerId, @Count", customerIdParam, countParam)
        .ToListAsync();
}

// Configure keyless entity for stored procedure results
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<ProductRecommendationDto>().HasNoKey();
}
```

### 8. Monitoring and Diagnostics

#### Pattern: Query Logging and Analysis
```csharp
// Configure detailed logging in development
services.AddDbContext<AppDbContext>(options =>
{
    options.UseSqlServer(connectionString);
    
    if (environment.IsDevelopment())
    {
        options.EnableSensitiveDataLogging();
        options.LogTo(Console.WriteLine, LogLevel.Information);
    }
});

// Use MiniProfiler for query analysis
services.AddMiniProfiler(options =>
{
    options.RouteBasePath = "/profiler";
}).AddEntityFramework();

// Custom interceptor for performance monitoring
public class QueryPerformanceInterceptor : DbCommandInterceptor
{
    private readonly ILogger<QueryPerformanceInterceptor> _logger;

    public QueryPerformanceInterceptor(ILogger<QueryPerformanceInterceptor> logger)
    {
        _logger = logger;
    }

    public override async ValueTask<DbDataReader> ReaderExecutedAsync(DbCommand command, CommandExecutedEventData eventData, DbDataReader result, CancellationToken cancellationToken = default)
    {
        if (eventData.Duration.TotalMilliseconds > 1000) // Log slow queries
        {
            _logger.LogWarning("Slow query detected: {Duration}ms - {CommandText}", 
                eventData.Duration.TotalMilliseconds, command.CommandText);
        }

        return await base.ReaderExecutedAsync(command, eventData, result, cancellationToken);
    }
}
```

### 9. Testing Patterns

#### Pattern: Performance Testing for Queries
```csharp
[MemoryDiagnoser]
[SimpleJob(RuntimeMoniker.Net80)]
public class ProductQueryBenchmarks
{
    private AppDbContext _context;
    private List<Product> _testProducts;

    [GlobalSetup]
    public void Setup()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlServer("your-test-connection-string")
            .Options;
        
        _context = new AppDbContext(options);
        
        // Seed test data
        SeedTestData();
    }

    [Benchmark(Baseline = true)]
    public async Task<List<ProductDto>> GetProducts_WithInclude()
    {
        return await _context.Products
            .Include(p => p.Category)
            .Select(p => new ProductDto
            {
                Id = p.Id,
                Name = p.Name,
                CategoryName = p.Category.Name
            })
            .ToListAsync();
    }

    [Benchmark]
    public async Task<List<ProductDto>> GetProducts_WithProjection()
    {
        return await _context.Products
            .Select(p => new ProductDto
            {
                Id = p.Id,
                Name = p.Name,
                CategoryName = p.Category.Name
            })
            .ToListAsync();
    }

    [Benchmark]
    public async Task<List<ProductDto>> GetProducts_CompiledQuery()
    {
        return await CompiledQueries.GetProductsWithCategory(_context);
    }
}

public static class CompiledQueries
{
    public static readonly Func<AppDbContext, Task<List<ProductDto>>> GetProductsWithCategory =
        EF.CompileAsyncQuery((AppDbContext context) =>
            context.Products
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    CategoryName = p.Category.Name
                })
                .ToList());
}
```

## Performance Measurement Tools

### SQL Profiler Integration
```csharp
// Extension method for query analysis
public static class QueryAnalysisExtensions
{
    public static IQueryable<T> WithQueryAnalysis<T>(this IQueryable<T> query, ILogger logger)
    {
        if (logger.IsEnabled(LogLevel.Debug))
        {
            var expression = query.Expression.ToString();
            logger.LogDebug("Executing query: {Expression}", expression);
        }
        
        return query;
    }
}

// Usage
var products = await _context.Products
    .WithQueryAnalysis(_logger)
    .Where(p => p.IsActive)
    .ToListAsync();
```

### Custom Performance Metrics
```csharp
public class EfCoreMetricsCollector
{
    private readonly IMetrics _metrics;
    private readonly Counter<int> _queryCounter;
    private readonly Histogram<double> _queryDuration;

    public EfCoreMetricsCollector(IMeterFactory meterFactory)
    {
        var meter = meterFactory.Create("EfCore.Performance");
        _queryCounter = meter.CreateCounter<int>("ef_queries_total");
        _queryDuration = meter.CreateHistogram<double>("ef_query_duration");
    }

    public void RecordQuery(string operation, double durationMs)
    {
        _queryCounter.Add(1, new TagList { ["operation"] = operation });
        _queryDuration.Record(durationMs, new TagList { ["operation"] = operation });
    }
}
```

## Common Anti-Patterns to Avoid

### ❌ N+1 Query Problems
```csharp
// BAD
foreach (var order in orders)
{
    var customer = await _context.Customers.FindAsync(order.CustomerId);
}

// GOOD
var orders = await _context.Orders.Include(o => o.Customer).ToListAsync();
```

### ❌ Unnecessary Change Tracking
```csharp
// BAD for read-only operations
var products = await _context.Products.ToListAsync();

// GOOD
var products = await _context.Products.AsNoTracking().ToListAsync();
```

### ❌ Loading Entire Entities When Projecting
```csharp
// BAD
var dtos = await _context.Products
    .Include(p => p.Category)
    .Select(p => new ProductDto { Name = p.Name, CategoryName = p.Category.Name })
    .ToListAsync();

// GOOD
var dtos = await _context.Products
    .Select(p => new ProductDto { Name = p.Name, CategoryName = p.Category.Name })
    .ToListAsync();
```

### ❌ Synchronous Operations in Async Context
```csharp
// BAD
var product = _context.Products.First(p => p.Id == id);

// GOOD
var product = await _context.Products.FirstAsync(p => p.Id == id);
```

## Summary

These EF Core optimization patterns can provide significant performance improvements:

1. **Query Optimization**: 30-80% improvement with proper projections and no-tracking
2. **N+1 Elimination**: 90%+ improvement by fixing query patterns
3. **Bulk Operations**: 95%+ improvement for large data sets
4. **Compiled Queries**: 20-40% improvement for frequently executed queries
5. **Proper Pagination**: 80%+ improvement for large result sets

**Remember**: Always measure performance before and after optimizations to validate improvements.
