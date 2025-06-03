using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Order;
using Bogus;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Moq;
using ProductCatalog.API.Data;
using ProductCatalog.API.DTOs;
using ProductCatalog.API.Models;
using ProductCatalog.API.Services;

namespace ProductCatalog.PerformanceTests.Benchmarks;

/// <summary>
/// Performance benchmarks for ProductService operations
/// </summary>
[MemoryDiagnoser]
[Orderer(SummaryOrderPolicy.FastestToSlowest)]
[RankColumn]
public class ProductServiceBenchmarks
{
    private ProductCatalogContext _context = null!;
    private ProductService _service = null!;
    private List<Product> _products = null!;
    private List<Category> _categories = null!;
    private ProductSearchDto _searchDto = null!;
    
    [GlobalSetup]
    public void Setup()
    {
        // Setup database context with in-memory database
        var options = new DbContextOptionsBuilder<ProductCatalogContext>()
            .UseInMemoryDatabase(databaseName: $"ProductCatalog_Benchmark_{Guid.NewGuid()}")
            .Options;
            
        _context = new ProductCatalogContext(options);
        
        // Setup mock logger
        var mockLogger = new Mock<ILogger<ProductService>>();
        
        // Create service
        _service = new ProductService(_context, mockLogger.Object);
        
        // Generate test data
        GenerateTestData();
        
        // Setup search DTO
        _searchDto = new ProductSearchDto
        {
            PageNumber = 1,
            PageSize = 10
        };
    }
    
    [GlobalCleanup]
    public void Cleanup()
    {
        _context.Dispose();
    }
    
    private void GenerateTestData()
    {
        // Generate categories
        var categoryFaker = new Faker<Category>()
            .RuleFor(c => c.Name, f => f.Commerce.Categories(1).First())
            .RuleFor(c => c.Description, f => f.Lorem.Sentence())
            .RuleFor(c => c.IsActive, f => true)
            .RuleFor(c => c.CreatedAt, f => f.Date.Past());
            
        _categories = categoryFaker.Generate(5);
        
        for (int i = 0; i < _categories.Count; i++)
        {
            _categories[i].Id = i + 1;
        }
        
        _context.Categories.AddRange(_categories);
        _context.SaveChanges();
        
        // Generate products
        var productFaker = new Faker<Product>()
            .RuleFor(p => p.Name, f => f.Commerce.ProductName())
            .RuleFor(p => p.Description, f => f.Commerce.ProductDescription())
            .RuleFor(p => p.Price, f => f.Random.Decimal(10, 1000))
            .RuleFor(p => p.Stock, f => f.Random.Int(0, 100))
            .RuleFor(p => p.CategoryId, f => f.PickRandom(_categories).Id)
            .RuleFor(p => p.IsActive, f => true)
            .RuleFor(p => p.CreatedAt, f => f.Date.Past())
            .RuleFor(p => p.SKU, f => f.Commerce.Ean13())
            .RuleFor(p => p.Weight, f => f.Random.Decimal(0.1M, 10M))
            .RuleFor(p => p.ImageUrl, f => f.Image.PicsumUrl());
            
        _products = productFaker.Generate(1000);
        
        for (int i = 0; i < _products.Count; i++)
        {
            _products[i].Id = i + 1;
        }
        
        _context.Products.AddRange(_products);
        _context.SaveChanges();
        
        // Generate tags
        var tags = new List<Tag>
        {
            new Tag { Id = 1, Name = "New" },
            new Tag { Id = 2, Name = "Sale" },
            new Tag { Id = 3, Name = "Featured" }
        };
        
        _context.Tags.AddRange(tags);
        _context.SaveChanges();
        
        // Generate product tags (randomly assign tags to products)
        var random = new Random();
        var productTags = new List<ProductTag>();
        
        foreach (var product in _products)
        {
            var tagCount = random.Next(0, 3);
            var tagIds = Enumerable.Range(1, 3).OrderBy(x => random.Next()).Take(tagCount).ToList();
            
            foreach (var tagId in tagIds)
            {
                productTags.Add(new ProductTag
                {
                    ProductId = product.Id,
                    TagId = tagId,
                    CreatedAt = DateTime.UtcNow
                });
            }
        }
        
        _context.ProductTags.AddRange(productTags);
        _context.SaveChanges();
    }
    
    [Benchmark]
    public async Task GetProducts_Default()
    {
        var result = await _service.GetProductsAsync(_searchDto);
        return;
    }
    
    [Benchmark]
    public async Task GetProducts_WithSearch()
    {
        var searchDto = new ProductSearchDto
        {
            SearchTerm = "a", // Common letter to ensure some matches
            PageNumber = 1,
            PageSize = 10
        };
        
        var result = await _service.GetProductsAsync(searchDto);
        return;
    }
    
    [Benchmark]
    public async Task GetProducts_WithCategoryFilter()
    {
        var searchDto = new ProductSearchDto
        {
            CategoryId = 1,
            PageNumber = 1,
            PageSize = 10
        };
        
        var result = await _service.GetProductsAsync(searchDto);
        return;
    }
    
    [Benchmark]
    public async Task GetProducts_WithPriceFilter()
    {
        var searchDto = new ProductSearchDto
        {
            MinPrice = 50,
            MaxPrice = 500,
            PageNumber = 1,
            PageSize = 10
        };
        
        var result = await _service.GetProductsAsync(searchDto);
        return;
    }
    
    [Benchmark]
    public async Task GetProducts_WithMultipleFilters()
    {
        var searchDto = new ProductSearchDto
        {
            SearchTerm = "a",
            CategoryId = 1,
            MinPrice = 50,
            MaxPrice = 500,
            InStockOnly = true,
            PageNumber = 1,
            PageSize = 10
        };
        
        var result = await _service.GetProductsAsync(searchDto);
        return;
    }
    
    [Benchmark]
    public async Task GetProductById()
    {
        var productId = 1;
        var result = await _service.GetProductByIdAsync(productId);
        return;
    }
    
    [Benchmark]
    public async Task GetLowStockProducts()
    {
        var result = await _service.GetLowStockProductsAsync(10);
        return;
    }
    
    [Benchmark]
    public async Task CreateProduct()
    {
        var createDto = new CreateProductDto
        {
            Name = "Benchmark Test Product",
            Description = "Product created during benchmarking",
            Price = 99.99M,
            Stock = 100,
            CategoryId = 1,
            SKU = $"BENCH-{Guid.NewGuid().ToString().Substring(0, 8)}",
            TagIds = new List<int> { 1 }
        };
        
        var result = await _service.CreateProductAsync(createDto);
        return;
    }
}