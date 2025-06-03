using DatabaseOptimization.Data;
using DatabaseOptimization.Models;
using Microsoft.EntityFrameworkCore;

namespace DatabaseOptimization.Services;

public interface IOptimizedProductService
{
    Task<List<ProductDto>> GetProductsWithCategoryAsync();
    Task<List<OrderSummaryDto>> GetOrdersWithDetailsAsync();
    Task<List<ProductDetailDto>> GetProductsWithAllDetailsSplitAsync();
    Task<List<ProductDto>> GetProductsForDisplayNoTrackingAsync();
    Task<PagedResult<ProductDto>> GetProductsPageEfficient(int pageNumber, int pageSize);
    Task BulkInsertProductsAsync(List<Product> products);
    Task BulkUpdateProductsAsync(List<Product> products);
    Task<Product?> GetProductByIdCompiledAsync(int id);
    Task<List<Product>> GetProductsByCategoryCompiledAsync(int categoryId);
}

/// <summary>
/// Service with optimized database query patterns - demonstrates best practices
/// </summary>
public class OptimizedProductService : IOptimizedProductService
{
    private readonly AppDbContext _context;
    private readonly ILogger<OptimizedProductService> _logger;

    // Compiled queries for frequently executed operations
    private static readonly Func<AppDbContext, int, Task<Product?>> GetProductByIdQuery =
        EF.CompileAsyncQuery((AppDbContext context, int id) =>
            context.Products
                .Include(p => p.Category)
                .FirstOrDefault(p => p.Id == id && p.IsActive));

    private static readonly Func<AppDbContext, int, Task<List<Product>>> GetProductsByCategoryQuery =
        EF.CompileAsyncQuery((AppDbContext context, int categoryId) =>
            context.Products
                .Where(p => p.CategoryId == categoryId && p.IsActive)
                .OrderBy(p => p.Name)
                .ToList());

    public OptimizedProductService(AppDbContext context, ILogger<OptimizedProductService> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Optimized version using projection to avoid N+1 problem
    /// </summary>
    public async Task<List<ProductDto>> GetProductsWithCategoryAsync()
    {
        _logger.LogInformation("Getting products with categories (optimized - single query with projection)");

        // Single query with projection - EF Core automatically includes the join
        return await _context.Products
            .AsNoTracking()
            .Where(p => p.IsActive)
            .Select(p => new ProductDto
            {
                Id = p.Id,
                Name = p.Name,
                Description = p.Description,
                Price = p.Price,
                Stock = p.Stock,
                CategoryName = p.Category!.Name
            })
            .ToListAsync();
    }

    /// <summary>
    /// Optimized version using proper join and projection
    /// </summary>
    public async Task<List<OrderSummaryDto>> GetOrdersWithDetailsAsync()
    {
        _logger.LogInformation("Getting orders with details (optimized - single query with aggregation)");

        // Single query with grouping and aggregation
        return await _context.Orders
            .AsNoTracking()
            .Select(o => new OrderSummaryDto
            {
                Id = o.Id,
                CustomerName = o.CustomerName,
                OrderDate = o.OrderDate,
                TotalAmount = o.TotalAmount,
                ItemCount = o.OrderItems.Count() // EF Core translates this to SQL COUNT
            })
            .OrderByDescending(o => o.OrderDate)
            .ToListAsync();
    }

    /// <summary>
    /// Optimized version using query splitting for complex includes
    /// </summary>
    public async Task<List<ProductDetailDto>> GetProductsWithAllDetailsSplitAsync()
    {
        _logger.LogInformation("Getting products with all details (optimized - split query)");

        // Use split query to avoid Cartesian explosion
        var products = await _context.Products
            .AsNoTracking()
            .AsSplitQuery() // Splits into multiple queries automatically
            .Include(p => p.Category)
            .Include(p => p.ProductTags)
                .ThenInclude(pt => pt.Tag)
            .Where(p => p.IsActive)
            .ToListAsync();

        // Get recent order data separately for better performance
        var productIds = products.Select(p => p.Id).ToList();
        var recentOrderData = await _context.OrderItems
            .AsNoTracking()
            .Include(oi => oi.Order)
            .Where(oi => productIds.Contains(oi.ProductId) && 
                        oi.Order!.OrderDate >= DateTime.UtcNow.AddDays(-30))
            .GroupBy(oi => oi.ProductId)
            .Select(g => new 
            {
                ProductId = g.Key,
                Orders = g.Select(oi => new OrderSummaryDto
                {
                    Id = oi.Order!.Id,
                    CustomerName = oi.Order.CustomerName,
                    OrderDate = oi.Order.OrderDate,
                    TotalAmount = oi.Order.TotalAmount,
                    ItemCount = oi.Order.OrderItems.Count()
                }).ToList()
            })
            .ToListAsync();

        // Combine the data
        return products.Select(p => new ProductDetailDto
        {
            Id = p.Id,
            Name = p.Name,
            Description = p.Description,
            Price = p.Price,
            Stock = p.Stock,
            CategoryName = p.Category?.Name ?? "Unknown",
            Tags = p.ProductTags.Select(pt => pt.Tag?.Name ?? "").ToList(),
            RecentOrders = recentOrderData
                .FirstOrDefault(rod => rod.ProductId == p.Id)?.Orders ?? new List<OrderSummaryDto>()
        }).ToList();
    }

    /// <summary>
    /// Optimized version using no-tracking queries for read-only operations
    /// </summary>
    public async Task<List<ProductDto>> GetProductsForDisplayNoTrackingAsync()
    {
        _logger.LogInformation("Getting products for display (optimized - no tracking + projection)");

        // Use AsNoTracking() for read-only operations and project directly to DTO
        return await _context.Products
            .AsNoTracking()
            .Where(p => p.IsActive)
            .Select(p => new ProductDto
            {
                Id = p.Id,
                Name = p.Name,
                Description = p.Description,
                Price = p.Price,
                Stock = p.Stock,
                CategoryName = p.Category!.Name
            })
            .ToListAsync();
    }

    /// <summary>
    /// Efficient pagination that applies Skip/Take at database level
    /// </summary>
    public async Task<PagedResult<ProductDto>> GetProductsPageEfficient(int pageNumber, int pageSize)
    {
        _logger.LogInformation("Getting products page (optimized - database-level pagination)");

        var query = _context.Products
            .AsNoTracking()
            .Where(p => p.IsActive);

        // Get total count
        var totalRecords = await query.CountAsync();

        // Apply pagination at database level and project to DTO
        var products = await query
            .Select(p => new ProductDto
            {
                Id = p.Id,
                Name = p.Name,
                Description = p.Description,
                Price = p.Price,
                Stock = p.Stock,
                CategoryName = p.Category!.Name
            })
            .Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return new PagedResult<ProductDto>
        {
            Data = products,
            TotalRecords = totalRecords,
            PageNumber = pageNumber,
            PageSize = pageSize
        };
    }

    /// <summary>
    /// Bulk insert operation with optimizations
    /// </summary>
    public async Task BulkInsertProductsAsync(List<Product> products)
    {
        _logger.LogInformation("Bulk inserting {ProductCount} products", products.Count);

        // Disable change tracking for better performance
        _context.ChangeTracker.AutoDetectChangesEnabled = false;

        try
        {
            const int batchSize = 1000;

            // Process in batches to avoid memory issues
            for (int i = 0; i < products.Count; i += batchSize)
            {
                var batch = products.Skip(i).Take(batchSize);
                _context.Products.AddRange(batch);

                await _context.SaveChangesAsync();
                _context.ChangeTracker.Clear(); // Clear tracking to free memory
            }
        }
        finally
        {
            _context.ChangeTracker.AutoDetectChangesEnabled = true;
        }
    }

    /// <summary>
    /// Bulk update operation using ExecuteUpdateAsync (EF Core 7+)
    /// </summary>
    public async Task BulkUpdateProductsAsync(List<Product> products)
    {
        _logger.LogInformation("Bulk updating {ProductCount} products", products.Count);

        // Group updates by type for efficiency
        foreach (var product in products)
        {
            // Use ExecuteUpdateAsync for efficient bulk updates (EF Core 7+)
            await _context.Products
                .Where(p => p.Id == product.Id)
                .ExecuteUpdateAsync(setters => setters
                    .SetProperty(p => p.Name, product.Name)
                    .SetProperty(p => p.Description, product.Description)
                    .SetProperty(p => p.Price, product.Price)
                    .SetProperty(p => p.Stock, product.Stock)
                    .SetProperty(p => p.UpdatedAt, DateTime.UtcNow));
        }
    }

    /// <summary>
    /// Use compiled query for frequently executed operations
    /// </summary>
    public async Task<Product?> GetProductByIdCompiledAsync(int id)
    {
        _logger.LogInformation("Getting product by ID using compiled query: {ProductId}", id);
        return await GetProductByIdQuery(_context, id);
    }

    /// <summary>
    /// Use compiled query for frequently executed operations
    /// </summary>
    public async Task<List<Product>> GetProductsByCategoryCompiledAsync(int categoryId)
    {
        _logger.LogInformation("Getting products by category using compiled query: {CategoryId}", categoryId);
        return await GetProductsByCategoryQuery(_context, categoryId);
    }
}
