using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;
using PerformanceDemo.Data;
using PerformanceDemo.Models;

namespace PerformanceDemo.Optimizations;

/// <summary>
/// Demonstrates database query optimization techniques for Entity Framework Core
/// </summary>
public class DatabaseOptimizations
{
    private readonly ApplicationDbContext _context;

    public DatabaseOptimizations(ApplicationDbContext context)
    {
        _context = context;
    }

    #region Query Optimization Examples

    /// <summary>
    /// BAD: N+1 Query Problem
    /// </summary>
    public async Task<List<OrderSummary>> GetOrderSummariesInefficient()
    {
        var orders = await _context.Orders.ToListAsync();
        var summaries = new List<OrderSummary>();

        foreach (var order in orders)
        {
            // This creates N+1 queries!
            var itemCount = await _context.OrderItems.CountAsync(oi => oi.OrderId == order.Id);
            
            summaries.Add(new OrderSummary
            {
                OrderId = order.Id,
                CustomerName = order.CustomerName,
                ItemCount = itemCount,
                Total = order.TotalAmount
            });
        }

        return summaries;
    }

    /// <summary>
    /// GOOD: Optimized with Include and Projection
    /// </summary>
    public async Task<List<OrderSummary>> GetOrderSummariesOptimized()
    {
        return await _context.Orders
            .Include(o => o.OrderItems)
            .AsNoTracking() // No change tracking needed for read-only operations
            .Select(o => new OrderSummary
            {
                OrderId = o.Id,
                CustomerName = o.CustomerName,
                ItemCount = o.OrderItems.Count,
                Total = o.TotalAmount
            })
            .ToListAsync();
    }

    /// <summary>
    /// GOOD: Using projection to select only needed data
    /// </summary>
    public async Task<List<ProductInfo>> GetProductInfoOptimized()
    {
        return await _context.Products
            .AsNoTracking()
            .Where(p => p.IsActive)
            .Select(p => new ProductInfo
            {
                Id = p.Id,
                Name = p.Name,
                Price = p.Price,
                CategoryName = p.Category.Name // Navigation property in projection
            })
            .ToListAsync();
    }

    /// <summary>
    /// Query splitting for complex includes
    /// </summary>
    public async Task<List<Order>> GetOrdersWithItemsOptimized()
    {
        return await _context.Orders
            .AsSplitQuery() // Splits into multiple queries to avoid cartesian explosion
            .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
            .AsNoTracking()
            .ToListAsync();
    }

    #endregion

    #region Compiled Queries

    // Compiled queries for frequently executed operations
    private static readonly Func<ApplicationDbContext, int, Task<Order?>> CompiledGetOrderById =
        EF.CompileAsyncQuery((ApplicationDbContext context, int orderId) =>
            context.Orders
                .Include(o => o.OrderItems)
                .FirstOrDefault(o => o.Id == orderId));

    private static readonly Func<ApplicationDbContext, DateTime, DateTime, IAsyncEnumerable<Order>> CompiledGetOrdersByDateRange =
        EF.CompileAsyncQuery((ApplicationDbContext context, DateTime startDate, DateTime endDate) =>
            context.Orders
                .Where(o => o.OrderDate >= startDate && o.OrderDate <= endDate)
                .OrderBy(o => o.OrderDate)
                .AsNoTracking());

    /// <summary>
    /// Using compiled query for better performance on repeated executions
    /// </summary>
    public async Task<Order?> GetOrderByIdCompiled(int orderId)
    {
        return await CompiledGetOrderById(_context, orderId);
    }

    /// <summary>
    /// Using compiled query with async enumerable for streaming large results
    /// </summary>
    public async Task ProcessOrdersByDateRange(DateTime startDate, DateTime endDate)
    {
        await foreach (var order in CompiledGetOrdersByDateRange(_context, startDate, endDate))
        {
            // Process each order as it's retrieved, reducing memory usage
            ProcessOrder(order);
        }
    }

    #endregion

    #region Batch Operations

    /// <summary>
    /// Efficient bulk update using ExecuteUpdate (EF Core 7+)
    /// </summary>
    public async Task<int> BulkUpdateProductPrices(decimal percentage)
    {
        return await _context.Products
            .Where(p => p.IsActive)
            .ExecuteUpdateAsync(p => p.SetProperty(x => x.Price, x => x.Price * (1 + percentage / 100)));
    }

    /// <summary>
    /// Efficient bulk delete using ExecuteDelete (EF Core 7+)
    /// </summary>
    public async Task<int> BulkDeleteInactiveProducts()
    {
        return await _context.Products
            .Where(p => !p.IsActive && p.UpdatedAt < DateTime.UtcNow.AddYears(-1))
            .ExecuteDeleteAsync();
    }

    /// <summary>
    /// Batch insert with optimized change tracking
    /// </summary>
    public async Task BulkInsertProducts(IEnumerable<Product> products)
    {
        const int batchSize = 1000;
        var productList = products.ToList();

        for (int i = 0; i < productList.Count; i += batchSize)
        {
            var batch = productList.Skip(i).Take(batchSize);
            
            // Disable change tracking for better performance
            _context.ChangeTracker.AutoDetectChangesEnabled = false;
            
            try
            {
                _context.Products.AddRange(batch);
                await _context.SaveChangesAsync();
            }
            finally
            {
                _context.ChangeTracker.AutoDetectChangesEnabled = true;
                _context.ChangeTracker.Clear(); // Clear tracking to free memory
            }
        }
    }

    #endregion

    #region Raw SQL Optimization

    /// <summary>
    /// Using raw SQL for complex queries that are hard to express in LINQ
    /// </summary>
    public async Task<List<MonthlyRevenue>> GetMonthlyRevenueReport()
    {
        return await _context.Database
            .SqlQuery<MonthlyRevenue>($@"
                SELECT 
                    YEAR(o.OrderDate) as Year,
                    MONTH(o.OrderDate) as Month,
                    SUM(o.Total) as Revenue,
                    COUNT(*) as OrderCount
                FROM Orders o
                WHERE o.OrderDate >= DATEADD(year, -1, GETDATE())
                GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
                ORDER BY Year, Month")
            .ToListAsync();
    }

    /// <summary>
    /// Parameterized raw SQL for security and performance
    /// </summary>
    public async Task<List<CustomerOrderSummary>> GetTopCustomers(int topCount)
    {
        return await _context.Orders
            .GroupBy(o => o.CustomerEmail)
            .Select(g => new CustomerOrderSummary
            {
                CustomerEmail = g.Key,
                CustomerName = g.First().CustomerName,
                OrderCount = g.Count(),
                TotalSpent = g.Sum(o => o.TotalAmount)
            })
            .OrderByDescending(c => c.TotalSpent)
            .Take(topCount)
            .ToListAsync();
    }

    #endregion

    #region Connection and Context Optimization

    /// <summary>
    /// Connection pooling configuration in Program.cs:
    /// services.AddDbContextPool<ApplicationDbContext>(options => 
    ///     options.UseSqlServer(connectionString));
    /// </summary>

    /// <summary>
    /// Using explicit transactions for better control
    /// </summary>
    public async Task ProcessLargeDataset(IEnumerable<DataItem> items)
    {
        using var transaction = await _context.Database.BeginTransactionAsync();
        try
        {
            const int batchSize = 500;
            var batch = new List<DataItem>(batchSize);

            foreach (var item in items)
            {
                batch.Add(item);

                if (batch.Count >= batchSize)
                {
                    await ProcessBatch(batch);
                    batch.Clear();
                }
            }

            // Process remaining items
            if (batch.Count > 0)
            {
                await ProcessBatch(batch);
            }

            await transaction.CommitAsync();
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }

    private async Task ProcessBatch(List<DataItem> batch)
    {
        // For demo purposes, we'll just save the batch without actually adding to context
        // since DataItems is not a real entity in our model
        // In a real scenario, you would add the items to the appropriate DbSet
        await _context.SaveChangesAsync();
        _context.ChangeTracker.Clear(); // Free memory
    }

    #endregion

    #region Query Caching

    /// <summary>
    /// Second-level query caching implementation
    /// </summary>
    public async Task<List<Category>> GetCategoriesWithCaching()
    {
        const string cacheKey = "all_categories";
        
        // This would typically use IMemoryCache or IDistributedCache
        // For demonstration, we'll show the pattern
        
        // Check cache first
        // var cached = await _cache.GetAsync<List<Category>>(cacheKey);
        // if (cached != null) return cached;

        var categories = await _context.Categories
            .AsNoTracking()
            .OrderBy(c => c.Name)
            .ToListAsync();

        // Cache the result
        // await _cache.SetAsync(cacheKey, categories, TimeSpan.FromHours(1));

        return categories;
    }

    #endregion

    private void ProcessOrder(Order order)
    {
        // Process order logic here
    }

    public class DataItem
    {
        public int Id { get; set; }
        public string Data { get; set; } = string.Empty;
    }
}

// DTOs for optimized queries
public class OrderSummary
{
    public int OrderId { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public int ItemCount { get; set; }
    public decimal Total { get; set; }
}

public class ProductInfo
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string CategoryName { get; set; } = string.Empty;
}

public class MonthlyRevenue
{
    public int Year { get; set; }
    public int Month { get; set; }
    public decimal Revenue { get; set; }
    public int OrderCount { get; set; }
}

public class CustomerOrderSummary
{
    public string CustomerEmail { get; set; } = string.Empty;
    public string CustomerName { get; set; } = string.Empty;
    public int OrderCount { get; set; }
    public decimal TotalSpent { get; set; }
}
