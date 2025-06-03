using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using PerformanceDemo.Data;
using PerformanceDemo.Models;
using System.Collections.Concurrent;

namespace PerformanceDemo.Services;

// Standard implementation with potential performance issues
public class ProductService : IProductService
{
    private readonly ApplicationDbContext _context;
    private readonly IMemoryCache _cache;
    private readonly ILogger<ProductService> _logger;
    
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
        _logger.LogInformation("Getting all products");
        
        // Inefficient query - loads all data including related entities
        return await _context.Products
            .Include(p => p.Category)
            .Include(p => p.ProductTags)
                .ThenInclude(pt => pt.Tag)
            .ToListAsync();
    }
    
    public async Task<IEnumerable<Product>> GetProductsByCategoryAsync(int categoryId)
    {
        _logger.LogInformation("Getting products by category: {CategoryId}", categoryId);
        
        // No caching, performs query every time
        return await _context.Products
            .Include(p => p.Category)
            .Where(p => p.CategoryId == categoryId && p.IsActive)
            .ToListAsync();
    }
    
    public async Task<Product?> GetProductByIdAsync(int id)
    {
        _logger.LogInformation("Getting product by ID: {ProductId}", id);
        
        // No caching, inefficient eager loading
        return await _context.Products
            .Include(p => p.Category)
            .Include(p => p.ProductTags)
                .ThenInclude(pt => pt.Tag)
            .FirstOrDefaultAsync(p => p.Id == id && p.IsActive);
    }
    
    public async Task<IEnumerable<Product>> SearchProductsAsync(string searchTerm)
    {
        _logger.LogInformation("Searching products with term: {SearchTerm}", searchTerm);
        
        if (string.IsNullOrWhiteSpace(searchTerm))
            return await GetAllProductsAsync();
            
        // Inefficient search - case sensitive, loads all data first
        var products = await _context.Products
            .Include(p => p.Category)
            .ToListAsync();
            
        return products.Where(p => 
            p.Name.Contains(searchTerm) || 
            p.Description.Contains(searchTerm) ||
            p.Category!.Name.Contains(searchTerm));
    }
    
    public async Task<IEnumerable<Product>> GetLowStockProductsAsync(int threshold = 10)
    {
        _logger.LogInformation("Getting low stock products with threshold: {Threshold}", threshold);
        
        return await _context.Products
            .Include(p => p.Category)
            .Where(p => p.Stock <= threshold && p.Stock > 0 && p.IsActive)
            .OrderBy(p => p.Stock)
            .ToListAsync();
    }
    
    public async Task<Product> CreateProductAsync(Product product)
    {
        _logger.LogInformation("Creating new product: {ProductName}", product.Name);
        
        _context.Products.Add(product);
        await _context.SaveChangesAsync();
        
        return product;
    }
    
    public async Task<Product?> UpdateProductAsync(int id, Product product)
    {
        _logger.LogInformation("Updating product: {ProductId}", id);
        
        var existingProduct = await _context.Products.FindAsync(id);
        if (existingProduct == null)
            return null;
            
        // Inefficient - updates all properties
        _context.Entry(existingProduct).CurrentValues.SetValues(product);
        existingProduct.UpdatedAt = DateTime.UtcNow;
        
        await _context.SaveChangesAsync();
        
        return existingProduct;
    }
    
    public async Task<bool> DeleteProductAsync(int id)
    {
        _logger.LogInformation("Deleting product: {ProductId}", id);
        
        var product = await _context.Products.FindAsync(id);
        if (product == null)
            return false;
            
        // Soft delete - just mark as inactive
        product.IsActive = false;
        product.UpdatedAt = DateTime.UtcNow;
        
        await _context.SaveChangesAsync();
        
        return true;
    }
}

// Optimized implementation with performance improvements
public class OptimizedProductService : IProductService
{
    private readonly ApplicationDbContext _context;
    private readonly IMemoryCache _cache;
    private readonly ILogger<OptimizedProductService> _logger;
    
    // Cache keys
    private const string AllProductsCacheKey = "AllProducts";
    private const string ProductCacheKeyPrefix = "Product_";
    private const string CategoryProductsCacheKeyPrefix = "CategoryProducts_";
    
    // Cache durations
    private static readonly TimeSpan DefaultCacheDuration = TimeSpan.FromMinutes(15);
    
    // Compiled queries for better performance
    private static readonly Func<ApplicationDbContext, int, Task<Product?>> GetProductByIdQuery =
        EF.CompileAsyncQuery((ApplicationDbContext context, int id) =>
            context.Products
                .Include(p => p.Category)
                .FirstOrDefault(p => p.Id == id && p.IsActive));
                
    private static readonly Func<ApplicationDbContext, int, Task<List<Product>>> GetProductsByCategoryQuery =
        EF.CompileAsyncQuery((ApplicationDbContext context, int categoryId) =>
            context.Products
                .Where(p => p.CategoryId == categoryId && p.IsActive)
                .OrderBy(p => p.Name)
                .ToList());
                
    private static readonly Func<ApplicationDbContext, int, Task<List<Product>>> GetLowStockProductsQuery =
        EF.CompileAsyncQuery((ApplicationDbContext context, int threshold) =>
            context.Products
                .Where(p => p.Stock <= threshold && p.Stock > 0 && p.IsActive)
                .OrderBy(p => p.Stock)
                .ToList());
    
    // Object pool for search results
    private readonly ConcurrentBag<List<Product>> _searchResultsPool = new();
    
    public OptimizedProductService(
        ApplicationDbContext context,
        IMemoryCache cache,
        ILogger<OptimizedProductService> logger)
    {
        _context = context;
        _cache = cache;
        _logger = logger;
    }
    
    public async Task<IEnumerable<Product>> GetAllProductsAsync()
    {
        _logger.LogInformation("Getting all products (optimized)");
        
        // Try to get from cache first
        if (_cache.TryGetValue(AllProductsCacheKey, out List<Product>? cachedProducts))
        {
            _logger.LogInformation("Cache hit for all products");
            return cachedProducts!;
        }
        
        // No-tracking query for read-only data
        var products = await _context.Products
            .AsNoTracking()
            .Include(p => p.Category)
            .Where(p => p.IsActive)
            .OrderBy(p => p.Name)
            .ToListAsync();
            
        // Store in cache
        _cache.Set(AllProductsCacheKey, products, DefaultCacheDuration);
        
        return products;
    }
    
    public async Task<IEnumerable<Product>> GetProductsByCategoryAsync(int categoryId)
    {
        _logger.LogInformation("Getting products by category: {CategoryId} (optimized)", categoryId);
        
        var cacheKey = $"{CategoryProductsCacheKeyPrefix}{categoryId}";
        
        // Try to get from cache first
        if (_cache.TryGetValue(cacheKey, out List<Product>? cachedProducts))
        {
            _logger.LogInformation("Cache hit for category products");
            return cachedProducts!;
        }
        
        // Use compiled query
        var products = await GetProductsByCategoryQuery(_context, categoryId);
        
        // Store in cache
        _cache.Set(cacheKey, products, DefaultCacheDuration);
        
        return products;
    }
    
    public async Task<Product?> GetProductByIdAsync(int id)
    {
        _logger.LogInformation("Getting product by ID: {ProductId} (optimized)", id);
        
        var cacheKey = $"{ProductCacheKeyPrefix}{id}";
        
        // Try to get from cache first
        if (_cache.TryGetValue(cacheKey, out Product? cachedProduct))
        {
            _logger.LogInformation("Cache hit for product");
            return cachedProduct;
        }
        
        // Use compiled query
        var product = await GetProductByIdQuery(_context, id);
        
        if (product != null)
        {
            // Store in cache
            _cache.Set(cacheKey, product, DefaultCacheDuration);
        }
        
        return product;
    }
    
    public async Task<IEnumerable<Product>> SearchProductsAsync(string searchTerm)
    {
        _logger.LogInformation("Searching products with term: {SearchTerm} (optimized)", searchTerm);
        
        if (string.IsNullOrWhiteSpace(searchTerm))
            return await GetAllProductsAsync();
            
        // Use case-insensitive search directly in the database
        var normalizedSearchTerm = searchTerm.ToLower();
        
        // Split search into EF Core compatible query
        var products = await _context.Products
            .AsNoTracking()
            .Where(p => p.IsActive &&
                (EF.Functions.Like(p.Name.ToLower(), $"%{normalizedSearchTerm}%") ||
                 EF.Functions.Like(p.Description.ToLower(), $"%{normalizedSearchTerm}%")))
            .Include(p => p.Category)
            .OrderBy(p => p.Name)
            .ToListAsync();
            
        return products;
    }
    
    public async Task<IEnumerable<Product>> GetLowStockProductsAsync(int threshold = 10)
    {
        _logger.LogInformation("Getting low stock products with threshold: {Threshold} (optimized)", threshold);
        
        var cacheKey = $"LowStockProducts_{threshold}";
        
        // Try to get from cache first with a shorter duration for stock data
        if (_cache.TryGetValue(cacheKey, out List<Product>? cachedProducts))
        {
            _logger.LogInformation("Cache hit for low stock products");
            return cachedProducts!;
        }
        
        // Use compiled query
        var products = await GetLowStockProductsQuery(_context, threshold);
        
        // Store in cache with shorter duration
        _cache.Set(cacheKey, products, TimeSpan.FromMinutes(5));
        
        return products;
    }
    
    public async Task<Product> CreateProductAsync(Product product)
    {
        _logger.LogInformation("Creating new product: {ProductName} (optimized)", product.Name);
        
        // Set creation time
        product.CreatedAt = DateTime.UtcNow;
        
        _context.Products.Add(product);
        await _context.SaveChangesAsync();
        
        // Invalidate relevant caches
        InvalidateProductCaches();
        _cache.Remove($"{CategoryProductsCacheKeyPrefix}{product.CategoryId}");
        
        return product;
    }
    
    public async Task<Product?> UpdateProductAsync(int id, Product product)
    {
        _logger.LogInformation("Updating product: {ProductId} (optimized)", id);
        
        // Find product with minimal data loading
        var existingProduct = await _context.Products.FindAsync(id);
        if (existingProduct == null)
            return null;
            
        // Only update specific properties to avoid unnecessary database writes
        existingProduct.Name = product.Name;
        existingProduct.Description = product.Description;
        existingProduct.Price = product.Price;
        existingProduct.Stock = product.Stock;
        existingProduct.UpdatedAt = DateTime.UtcNow;
        
        // Only update CategoryId if it's changing to avoid unnecessary foreign key updates
        if (existingProduct.CategoryId != product.CategoryId)
        {
            var oldCategoryId = existingProduct.CategoryId;
            existingProduct.CategoryId = product.CategoryId;
            
            // Invalidate old category cache
            _cache.Remove($"{CategoryProductsCacheKeyPrefix}{oldCategoryId}");
        }
        
        await _context.SaveChangesAsync();
        
        // Invalidate relevant caches
        _cache.Remove($"{ProductCacheKeyPrefix}{id}");
        _cache.Remove(AllProductsCacheKey);
        _cache.Remove($"{CategoryProductsCacheKeyPrefix}{product.CategoryId}");
        
        return existingProduct;
    }
    
    public async Task<bool> DeleteProductAsync(int id)
    {
        _logger.LogInformation("Deleting product: {ProductId} (optimized)", id);
        
        // Use lightweight query to get just the data we need
        var product = await _context.Products
            .Select(p => new { p.Id, p.CategoryId })
            .FirstOrDefaultAsync(p => p.Id == id);
            
        if (product == null)
            return false;
            
        // Execute direct update command instead of loading and updating the entity
        await _context.Database.ExecuteSqlInterpolatedAsync(
            $"UPDATE Products SET IsActive = 0, UpdatedAt = {DateTime.UtcNow} WHERE Id = {id}");
            
        // Invalidate relevant caches
        _cache.Remove($"{ProductCacheKeyPrefix}{id}");
        _cache.Remove(AllProductsCacheKey);
        _cache.Remove($"{CategoryProductsCacheKeyPrefix}{product.CategoryId}");
        
        return true;
    }
    
    private void InvalidateProductCaches()
    {
        _cache.Remove(AllProductsCacheKey);
        
        // Could use a more granular approach for larger systems
        // by tracking which cache keys exist and only invalidating those
    }
}