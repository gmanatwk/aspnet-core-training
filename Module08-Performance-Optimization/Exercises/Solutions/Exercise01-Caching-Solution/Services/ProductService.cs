using Microsoft.EntityFrameworkCore;
using CachingDemo.Data;
using CachingDemo.Models;
using System.Diagnostics;

namespace CachingDemo.Services;

public interface IProductService
{
    Task<IEnumerable<ProductDto>> GetAllProductsAsync();
    Task<ProductDto?> GetProductByIdAsync(int id);
    Task<IEnumerable<ProductDto>> GetProductsByCategoryAsync(int categoryId);
    Task<ProductDto> CreateProductAsync(CreateProductRequest request);
    Task<ProductDto?> UpdateProductAsync(int id, UpdateProductRequest request);
    Task<bool> DeleteProductAsync(int id);
    Task<IEnumerable<ProductDto>> SearchProductsAsync(string searchTerm);
}

public class ProductService : IProductService
{
    private readonly ApplicationDbContext _context;
    private readonly ICacheService _cache;
    private readonly ILogger<ProductService> _logger;

    // Cache keys
    private const string AllProductsCacheKey = "products:all";
    private const string ProductCacheKeyPrefix = "product:";
    private const string CategoryProductsCacheKeyPrefix = "products:category:";
    private const string SearchCacheKeyPrefix = "products:search:";

    // Cache durations
    private static readonly TimeSpan DefaultCacheDuration = TimeSpan.FromMinutes(30);
    private static readonly TimeSpan SearchCacheDuration = TimeSpan.FromMinutes(15);
    private static readonly TimeSpan ProductCacheDuration = TimeSpan.FromHours(1);

    public ProductService(
        ApplicationDbContext context,
        ICacheService cache,
        ILogger<ProductService> logger)
    {
        _context = context;
        _cache = cache;
        _logger = logger;
    }

    public async Task<IEnumerable<ProductDto>> GetAllProductsAsync()
    {
        using var activity = Activity.Current?.Source.StartActivity("ProductService.GetAllProducts");
        
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            // Try cache first
            var cachedProducts = await _cache.GetAsync<List<ProductDto>>(AllProductsCacheKey);
            if (cachedProducts != null)
            {
                stopwatch.Stop();
                activity?.SetTag("data.source", "cache");
                activity?.SetTag("products.count", cachedProducts.Count);
                
                _logger.LogDebug("Retrieved {Count} products from cache in {Duration}ms", 
                    cachedProducts.Count, stopwatch.ElapsedMilliseconds);
                
                return cachedProducts;
            }

            // Load from database
            var products = await _context.Products
                .AsNoTracking()
                .Include(p => p.Category)
                .Where(p => p.IsActive)
                .OrderBy(p => p.Name)
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Stock = p.Stock,
                    IsActive = p.IsActive,
                    CategoryName = p.Category.Name,
                    CreatedAt = p.CreatedAt
                })
                .ToListAsync();

            // Cache the results
            await _cache.SetAsync(AllProductsCacheKey, products, DefaultCacheDuration);

            stopwatch.Stop();
            activity?.SetTag("data.source", "database");
            activity?.SetTag("products.count", products.Count);
            
            _logger.LogInformation("Retrieved {Count} products from database and cached in {Duration}ms", 
                products.Count, stopwatch.ElapsedMilliseconds);

            return products;
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            activity?.SetTag("error", true);
            
            _logger.LogError(ex, "Failed to retrieve products in {Duration}ms", stopwatch.ElapsedMilliseconds);
            throw;
        }
    }

    public async Task<ProductDto?> GetProductByIdAsync(int id)
    {
        using var activity = Activity.Current?.Source.StartActivity("ProductService.GetProductById");
        activity?.SetTag("product.id", id);
        
        var cacheKey = $"{ProductCacheKeyPrefix}{id}";
        var stopwatch = Stopwatch.StartNew();

        try
        {
            // Try cache first
            var cachedProduct = await _cache.GetAsync<ProductDto>(cacheKey);
            if (cachedProduct != null)
            {
                stopwatch.Stop();
                activity?.SetTag("data.source", "cache");
                
                _logger.LogDebug("Retrieved product {ProductId} from cache in {Duration}ms", 
                    id, stopwatch.ElapsedMilliseconds);
                
                return cachedProduct;
            }

            // Load from database
            var product = await _context.Products
                .AsNoTracking()
                .Include(p => p.Category)
                .Where(p => p.Id == id && p.IsActive)
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Stock = p.Stock,
                    IsActive = p.IsActive,
                    CategoryName = p.Category.Name,
                    CreatedAt = p.CreatedAt
                })
                .FirstOrDefaultAsync();

            if (product != null)
            {
                // Cache the result
                await _cache.SetAsync(cacheKey, product, ProductCacheDuration);
            }

            stopwatch.Stop();
            activity?.SetTag("data.source", "database");
            activity?.SetTag("product.found", product != null);
            
            _logger.LogDebug("Retrieved product {ProductId} from database in {Duration}ms", 
                id, stopwatch.ElapsedMilliseconds);

            return product;
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            activity?.SetTag("error", true);
            
            _logger.LogError(ex, "Failed to retrieve product {ProductId} in {Duration}ms", 
                id, stopwatch.ElapsedMilliseconds);
            throw;
        }
    }

    public async Task<IEnumerable<ProductDto>> SearchProductsAsync(string searchTerm)
    {
        using var activity = Activity.Current?.Source.StartActivity("ProductService.SearchProducts");
        activity?.SetTag("search.term", searchTerm);
        
        if (string.IsNullOrWhiteSpace(searchTerm))
        {
            return Enumerable.Empty<ProductDto>();
        }

        var cacheKey = $"{SearchCacheKeyPrefix}{searchTerm.ToLowerInvariant()}";
        var stopwatch = Stopwatch.StartNew();

        try
        {
            // Try cache first
            var cachedResults = await _cache.GetAsync<List<ProductDto>>(cacheKey);
            if (cachedResults != null)
            {
                stopwatch.Stop();
                activity?.SetTag("data.source", "cache");
                activity?.SetTag("products.count", cachedResults.Count);
                
                return cachedResults;
            }

            // Search in database
            var products = await _context.Products
                .AsNoTracking()
                .Include(p => p.Category)
                .Where(p => p.IsActive && 
                    (p.Name.Contains(searchTerm) || p.Description.Contains(searchTerm)))
                .OrderBy(p => p.Name)
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Stock = p.Stock,
                    IsActive = p.IsActive,
                    CategoryName = p.Category.Name,
                    CreatedAt = p.CreatedAt
                })
                .ToListAsync();

            // Cache the search results
            await _cache.SetAsync(cacheKey, products, SearchCacheDuration);

            stopwatch.Stop();
            activity?.SetTag("data.source", "database");
            activity?.SetTag("products.count", products.Count);
            
            return products;
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            activity?.SetTag("error", true);
            
            _logger.LogError(ex, "Failed to search products with term '{SearchTerm}' in {Duration}ms", 
                searchTerm, stopwatch.ElapsedMilliseconds);
            throw;
        }
    }

    public async Task<IEnumerable<ProductDto>> GetProductsByCategoryAsync(int categoryId)
    {
        using var activity = Activity.Current?.Source.StartActivity("ProductService.GetProductsByCategory");
        activity?.SetTag("category.id", categoryId);
        
        var cacheKey = $"{CategoryProductsCacheKeyPrefix}{categoryId}";
        var stopwatch = Stopwatch.StartNew();

        try
        {
            var cachedProducts = await _cache.GetAsync<List<ProductDto>>(cacheKey);
            if (cachedProducts != null)
            {
                stopwatch.Stop();
                activity?.SetTag("data.source", "cache");
                activity?.SetTag("products.count", cachedProducts.Count);
                
                return cachedProducts;
            }

            var products = await _context.Products
                .AsNoTracking()
                .Include(p => p.Category)
                .Where(p => p.CategoryId == categoryId && p.IsActive)
                .OrderBy(p => p.Name)
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Stock = p.Stock,
                    IsActive = p.IsActive,
                    CategoryName = p.Category.Name,
                    CreatedAt = p.CreatedAt
                })
                .ToListAsync();

            await _cache.SetAsync(cacheKey, products, DefaultCacheDuration);

            stopwatch.Stop();
            activity?.SetTag("data.source", "database");
            activity?.SetTag("products.count", products.Count);
            
            return products;
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            activity?.SetTag("error", true);
            
            _logger.LogError(ex, "Failed to retrieve products for category {CategoryId} in {Duration}ms", 
                categoryId, stopwatch.ElapsedMilliseconds);
            throw;
        }
    }

    public async Task<ProductDto> CreateProductAsync(CreateProductRequest request)
    {
        using var activity = Activity.Current?.Source.StartActivity("ProductService.CreateProduct");
        activity?.SetTag("product.name", request.Name);
        activity?.SetTag("product.category_id", request.CategoryId);
        
        var stopwatch = Stopwatch.StartNew();

        try
        {
            var product = new Product
            {
                Name = request.Name,
                Description = request.Description,
                Price = request.Price,
                Stock = request.Stock,
                IsActive = request.IsActive,
                CategoryId = request.CategoryId,
                CreatedAt = DateTime.UtcNow
            };

            _context.Products.Add(product);
            await _context.SaveChangesAsync();

            var createdProduct = await _context.Products
                .AsNoTracking()
                .Include(p => p.Category)
                .Where(p => p.Id == product.Id)
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Stock = p.Stock,
                    IsActive = p.IsActive,
                    CategoryName = p.Category.Name,
                    CreatedAt = p.CreatedAt
                })
                .FirstAsync();

            await InvalidateProductCaches(product.Id, product.CategoryId);

            stopwatch.Stop();
            activity?.SetTag("product.id", product.Id);
            
            _logger.LogInformation("Created product {ProductId} '{ProductName}' in {Duration}ms", 
                product.Id, product.Name, stopwatch.ElapsedMilliseconds);

            return createdProduct;
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            activity?.SetTag("error", true);
            
            _logger.LogError(ex, "Failed to create product '{ProductName}' in {Duration}ms", 
                request.Name, stopwatch.ElapsedMilliseconds);
            throw;
        }
    }

    public async Task<ProductDto?> UpdateProductAsync(int id, UpdateProductRequest request)
    {
        using var activity = Activity.Current?.Source.StartActivity("ProductService.UpdateProduct");
        activity?.SetTag("product.id", id);
        
        var stopwatch = Stopwatch.StartNew();

        try
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null)
            {
                return null;
            }

            var originalCategoryId = product.CategoryId;

            if (request.Name != null) product.Name = request.Name;
            if (request.Description != null) product.Description = request.Description;
            if (request.Price.HasValue) product.Price = request.Price.Value;
            if (request.Stock.HasValue) product.Stock = request.Stock.Value;
            if (request.IsActive.HasValue) product.IsActive = request.IsActive.Value;
            if (request.CategoryId.HasValue) product.CategoryId = request.CategoryId.Value;

            await _context.SaveChangesAsync();

            var updatedProduct = await _context.Products
                .AsNoTracking()
                .Include(p => p.Category)
                .Where(p => p.Id == id)
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Stock = p.Stock,
                    IsActive = p.IsActive,
                    CategoryName = p.Category.Name,
                    CreatedAt = p.CreatedAt
                })
                .FirstAsync();

            var categoriesToInvalidate = new HashSet<int> { originalCategoryId };
            if (request.CategoryId.HasValue && request.CategoryId.Value != originalCategoryId)
            {
                categoriesToInvalidate.Add(request.CategoryId.Value);
            }

            foreach (var categoryId in categoriesToInvalidate)
            {
                await InvalidateProductCaches(id, categoryId);
            }

            stopwatch.Stop();
            
            _logger.LogInformation("Updated product {ProductId} in {Duration}ms", 
                id, stopwatch.ElapsedMilliseconds);

            return updatedProduct;
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            activity?.SetTag("error", true);
            
            _logger.LogError(ex, "Failed to update product {ProductId} in {Duration}ms", 
                id, stopwatch.ElapsedMilliseconds);
            throw;
        }
    }

    public async Task<bool> DeleteProductAsync(int id)
    {
        using var activity = Activity.Current?.Source.StartActivity("ProductService.DeleteProduct");
        activity?.SetTag("product.id", id);
        
        var stopwatch = Stopwatch.StartNew();

        try
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null)
            {
                return false;
            }

            var categoryId = product.CategoryId;

            _context.Products.Remove(product);
            await _context.SaveChangesAsync();

            await InvalidateProductCaches(id, categoryId);

            stopwatch.Stop();
            
            _logger.LogInformation("Deleted product {ProductId} in {Duration}ms", 
                id, stopwatch.ElapsedMilliseconds);

            return true;
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            activity?.SetTag("error", true);
            
            _logger.LogError(ex, "Failed to delete product {ProductId} in {Duration}ms", 
                id, stopwatch.ElapsedMilliseconds);
            throw;
        }
    }

    private async Task InvalidateProductCaches(int productId, int categoryId)
    {
        var tasks = new List<Task>
        {
            _cache.RemoveAsync($"{ProductCacheKeyPrefix}{productId}"),
            _cache.RemoveAsync(AllProductsCacheKey),
            _cache.RemoveAsync($"{CategoryProductsCacheKeyPrefix}{categoryId}"),
            _cache.RemoveByPatternAsync(SearchCacheKeyPrefix)
        };

        await Task.WhenAll(tasks);
        
        _logger.LogDebug("Invalidated caches for product {ProductId} and category {CategoryId}", 
            productId, categoryId);
    }
}
