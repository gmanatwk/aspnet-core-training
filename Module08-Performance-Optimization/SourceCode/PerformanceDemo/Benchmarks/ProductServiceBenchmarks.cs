using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Order;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using PerformanceDemo.Data;
using PerformanceDemo.Models;
using PerformanceDemo.Services;

namespace PerformanceDemo.Benchmarks;

[MemoryDiagnoser]
[Orderer(SummaryOrderPolicy.FastestToSlowest)]
[RankColumn]
public class ProductServiceBenchmarks
{
    private ApplicationDbContext _context = null!;
    private IMemoryCache _cache = null!;
    private ProductService _standardService = null!;
    private OptimizedProductService _optimizedService = null!;
    private int _categoryId;
    private string _searchTerm = null!;
    
    [GlobalSetup]
    public void Setup()
    {
        // Create in-memory database
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: $"BenchmarkDb_{Guid.NewGuid()}")
            .Options;
            
        _context = new ApplicationDbContext(options);
        
        // Create memory cache
        var memoryCacheOptions = new MemoryCacheOptions();
        _cache = new MemoryCache(memoryCacheOptions);
        
        // Create mock logger
        var loggerFactory = LoggerFactory.Create(builder => builder.AddConsole());
        var standardLogger = loggerFactory.CreateLogger<ProductService>();
        var optimizedLogger = loggerFactory.CreateLogger<OptimizedProductService>();
        
        // Create services
        _standardService = new ProductService(_context, _cache, standardLogger);
        _optimizedService = new OptimizedProductService(_context, _cache, optimizedLogger);
        
        // Seed test data
        SeedTestData();
        
        // Set benchmark parameters
        _categoryId = 1; // First category ID
        _searchTerm = "product"; // Common term in product names
    }
    
    [GlobalCleanup]
    public void Cleanup()
    {
        _context.Dispose();
        (_cache as MemoryCache)?.Dispose();
    }
    
    private void SeedTestData()
    {
        // Add categories
        var categories = new List<Category>();
        for (int i = 1; i <= 5; i++)
        {
            categories.Add(new Category
            {
                Id = i,
                Name = $"Category {i}",
                Description = $"Description for category {i}"
            });
        }
        
        _context.Categories.AddRange(categories);
        _context.SaveChanges();
        
        // Add products
        var random = new Random(42); // Use fixed seed for reproducibility
        
        for (int i = 1; i <= 1000; i++)
        {
            var product = new Product
            {
                Name = $"Test Product {i}",
                Description = $"Description for product {i}",
                Price = (decimal)(random.NextDouble() * 1000),
                Stock = random.Next(0, 100),
                CategoryId = random.Next(1, 6),
                SKU = $"SKU-{i.ToString("D6")}",
                IsActive = random.NextDouble() > 0.1, // 90% active
                CreatedAt = DateTime.UtcNow.AddDays(-random.Next(1, 365))
            };
            
            _context.Products.Add(product);
        }
        
        _context.SaveChanges();
    }
    
    [Benchmark(Baseline = true)]
    public async Task<IEnumerable<Product>> GetProductsByCategoryAsync_Standard()
    {
        return await _standardService.GetProductsByCategoryAsync(_categoryId);
    }
    
    [Benchmark]
    public async Task<IEnumerable<Product>> GetProductsByCategoryAsync_Optimized()
    {
        return await _optimizedService.GetProductsByCategoryAsync(_categoryId);
    }
    
    [Benchmark]
    public async Task<IEnumerable<Product>> GetProductsByCategoryAsync_Optimized_CachedSecondCall()
    {
        // First call will cache the results
        await _optimizedService.GetProductsByCategoryAsync(_categoryId);
        
        // Second call should use the cache
        return await _optimizedService.GetProductsByCategoryAsync(_categoryId);
    }
    
    [Benchmark]
    public async Task<IEnumerable<Product>> SearchProductsAsync_Standard()
    {
        return await _standardService.SearchProductsAsync(_searchTerm);
    }
    
    [Benchmark]
    public async Task<IEnumerable<Product>> SearchProductsAsync_Optimized()
    {
        return await _optimizedService.SearchProductsAsync(_searchTerm);
    }
    
    [Benchmark]
    public async Task<IEnumerable<Product>> GetAllProductsAsync_Standard()
    {
        return await _standardService.GetAllProductsAsync();
    }
    
    [Benchmark]
    public async Task<IEnumerable<Product>> GetAllProductsAsync_Optimized()
    {
        return await _optimizedService.GetAllProductsAsync();
    }
    
    [Benchmark]
    public async Task<IEnumerable<Product>> GetAllProductsAsync_Optimized_CachedSecondCall()
    {
        // First call will cache the results
        await _optimizedService.GetAllProductsAsync();
        
        // Second call should use the cache
        return await _optimizedService.GetAllProductsAsync();
    }
    
    [Benchmark]
    public async Task DeleteAndUpdateProduct_Standard()
    {
        var product = new Product
        {
            Name = "Test Product",
            Description = "Test Description",
            Price = 99.99M,
            Stock = 10,
            CategoryId = 1,
            SKU = $"TEST-{Guid.NewGuid()}"
        };
        
        // Create a product
        var createdProduct = await _standardService.CreateProductAsync(product);
        
        // Update the product
        product.Price = 199.99M;
        await _standardService.UpdateProductAsync(createdProduct.Id, product);
        
        // Delete the product
        await _standardService.DeleteProductAsync(createdProduct.Id);
    }
    
    [Benchmark]
    public async Task DeleteAndUpdateProduct_Optimized()
    {
        var product = new Product
        {
            Name = "Test Product",
            Description = "Test Description",
            Price = 99.99M,
            Stock = 10,
            CategoryId = 1,
            SKU = $"TEST-{Guid.NewGuid()}"
        };
        
        // Create a product
        var createdProduct = await _optimizedService.CreateProductAsync(product);
        
        // Update the product
        product.Price = 199.99M;
        await _optimizedService.UpdateProductAsync(createdProduct.Id, product);
        
        // Delete the product
        await _optimizedService.DeleteProductAsync(createdProduct.Id);
    }
}