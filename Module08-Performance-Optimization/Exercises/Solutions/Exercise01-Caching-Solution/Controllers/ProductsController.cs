using CachingDemo.Models;
using CachingDemo.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OutputCaching;

namespace CachingDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;
    private readonly ILogger<ProductsController> _logger;
    
    public ProductsController(
        IProductService productService,
        ILogger<ProductsController> logger)
    {
        _productService = productService;
        _logger = logger;
    }
    
    /// <summary>
    /// Get all products without any caching
    /// </summary>
    [HttpGet("no-cache")]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetProductsNoCache()
    {
        var products = await _productService.GetAllProductsAsync();
        return Ok(products);
    }
    
    /// <summary>
    /// Get all products with response caching
    /// </summary>
    [HttpGet("response-cache")]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "*" })]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetProductsResponseCache()
    {
        var products = await _productService.GetAllProductsAsync();
        return Ok(products);
    }
    
    /// <summary>
    /// Get all products with output caching
    /// </summary>
    [HttpGet("output-cache")]
    [OutputCache(PolicyName = "Products")]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetProductsOutputCache()
    {
        var products = await _productService.GetAllProductsAsync();
        return Ok(products);
    }
    
    /// <summary>
    /// Get all products with multi-level caching (memory + distributed)
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetProducts()
    {
        var products = await _productService.GetAllProductsAsync();
        return Ok(products);
    }
    
    /// <summary>
    /// Get product by ID with caching
    /// </summary>
    [HttpGet("{id:int}")]
    [OutputCache(PolicyName = "Products")]
    public async Task<ActionResult<ProductDto>> GetProduct(int id)
    {
        var product = await _productService.GetProductByIdAsync(id);
        if (product == null)
            return NotFound();
            
        return Ok(product);
    }
    
    /// <summary>
    /// Get products by category with caching
    /// </summary>
    [HttpGet("category/{categoryId:int}")]
    [OutputCache(PolicyName = "Products")]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetProductsByCategory(int categoryId)
    {
        var products = await _productService.GetProductsByCategoryAsync(categoryId);
        return Ok(products);
    }
    
    /// <summary>
    /// Create a new product and invalidate relevant caches
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<ProductDto>> CreateProduct([FromBody] Product product)
    {
        var createdProduct = await _productService.CreateProductAsync(product);
        
        // Invalidate output cache tags
        await HttpContext.RequestServices
            .GetRequiredService<IOutputCacheStore>()
            .EvictByTagAsync("products", CancellationToken.None);
        
        return CreatedAtAction(nameof(GetProduct), new { id = createdProduct.Id }, createdProduct);
    }
    
    /// <summary>
    /// Update a product and invalidate relevant caches
    /// </summary>
    [HttpPut("{id:int}")]
    public async Task<ActionResult<ProductDto>> UpdateProduct(int id, [FromBody] Product product)
    {
        var updatedProduct = await _productService.UpdateProductAsync(id, product);
        if (updatedProduct == null)
            return NotFound();
        
        // Invalidate output cache tags
        await HttpContext.RequestServices
            .GetRequiredService<IOutputCacheStore>()
            .EvictByTagAsync("products", CancellationToken.None);
            
        return Ok(updatedProduct);
    }
    
    /// <summary>
    /// Delete a product and invalidate relevant caches
    /// </summary>
    [HttpDelete("{id:int}")]
    public async Task<ActionResult> DeleteProduct(int id)
    {
        var result = await _productService.DeleteProductAsync(id);
        if (!result)
            return NotFound();
        
        // Invalidate output cache tags
        await HttpContext.RequestServices
            .GetRequiredService<IOutputCacheStore>()
            .EvictByTagAsync("products", CancellationToken.None);
            
        return NoContent();
    }
}

[ApiController]
[Route("api/[controller]")]
public class CacheController : ControllerBase
{
    private readonly ICacheService _cacheService;
    private readonly ILogger<CacheController> _logger;
    
    public CacheController(
        ICacheService cacheService,
        ILogger<CacheController> logger)
    {
        _cacheService = cacheService;
        _logger = logger;
    }
    
    /// <summary>
    /// Clear all product-related caches (for testing purposes)
    /// </summary>
    [HttpDelete("clear")]
    public async Task<ActionResult> ClearCache()
    {
        try
        {
            await _cacheService.RemoveAsync("AllProducts");
            await _cacheService.RemoveByPatternAsync("Product_*");
            await _cacheService.RemoveByPatternAsync("CategoryProducts_*");
            
            // Clear output cache
            await HttpContext.RequestServices
                .GetRequiredService<IOutputCacheStore>()
                .EvictByTagAsync("products", CancellationToken.None);
            
            _logger.LogInformation("Cache cleared successfully");
            return Ok(new { message = "Cache cleared successfully" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error clearing cache");
            return StatusCode(500, new { message = "Error clearing cache" });
        }
    }
    
    /// <summary>
    /// Get cache statistics (simplified implementation)
    /// </summary>
    [HttpGet("stats")]
    public ActionResult GetCacheStats()
    {
        // In a real implementation, you would track hit/miss ratios
        return Ok(new
        {
            message = "Cache statistics would be implemented here",
            timestamp = DateTime.UtcNow
        });
    }
}
