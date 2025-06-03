using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OutputCaching;
using PerformanceDemo.Models;
using PerformanceDemo.Services;

namespace PerformanceDemo.Controllers;

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
    
    // Standard implementation without caching
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Product>>> GetProducts()
    {
        return Ok(await _productService.GetAllProductsAsync());
    }
    
    // Optimized implementation with output caching
    [HttpGet("cached")]
    [OutputCache(PolicyName = "Products")]
    public async Task<ActionResult<IEnumerable<Product>>> GetProductsCached()
    {
        return Ok(await _productService.GetAllProductsAsync());
    }
    
    // Standard implementation for getting product by ID
    [HttpGet("{id:int}")]
    public async Task<ActionResult<Product>> GetProduct(int id)
    {
        var product = await _productService.GetProductByIdAsync(id);
        if (product == null)
            return NotFound();
            
        return Ok(product);
    }
    
    // Optimized implementation with output caching and cache tag invalidation
    [HttpGet("cached/{id:int}")]
    [OutputCache(PolicyName = "Products")]
    public async Task<ActionResult<Product>> GetProductCached(int id)
    {
        var product = await _productService.GetProductByIdAsync(id);
        if (product == null)
            return NotFound();
            
        return Ok(product);
    }
    
    // Standard implementation for category products
    [HttpGet("category/{categoryId:int}")]
    public async Task<ActionResult<IEnumerable<Product>>> GetProductsByCategory(int categoryId)
    {
        return Ok(await _productService.GetProductsByCategoryAsync(categoryId));
    }
    
    // Optimized implementation with output caching
    [HttpGet("cached/category/{categoryId:int}")]
    [OutputCache(PolicyName = "Products")]
    public async Task<ActionResult<IEnumerable<Product>>> GetProductsByCategoryCached(int categoryId)
    {
        return Ok(await _productService.GetProductsByCategoryAsync(categoryId));
    }
    
    // Standard implementation for searching products
    [HttpGet("search")]
    public async Task<ActionResult<IEnumerable<Product>>> SearchProducts([FromQuery] string term)
    {
        if (string.IsNullOrWhiteSpace(term))
            return BadRequest("Search term is required");
            
        return Ok(await _productService.SearchProductsAsync(term));
    }
    
    // Implementation for creating a product
    [HttpPost]
    public async Task<ActionResult<Product>> CreateProduct([FromBody] Product product)
    {
        var createdProduct = await _productService.CreateProductAsync(product);
        
        return CreatedAtAction(nameof(GetProduct), new { id = createdProduct.Id }, createdProduct);
    }
    
    // Implementation for updating a product
    [HttpPut("{id:int}")]
    public async Task<ActionResult<Product>> UpdateProduct(int id, [FromBody] Product product)
    {
        var updatedProduct = await _productService.UpdateProductAsync(id, product);
        if (updatedProduct == null)
            return NotFound();
            
        return Ok(updatedProduct);
    }
    
    // Implementation for deleting a product
    [HttpDelete("{id:int}")]
    public async Task<ActionResult> DeleteProduct(int id)
    {
        var result = await _productService.DeleteProductAsync(id);
        if (!result)
            return NotFound();
            
        return NoContent();
    }
    
    // Implementation for getting low stock products with longer cache duration
    [HttpGet("low-stock")]
    [OutputCache(PolicyName = "LongCache")]
    public async Task<ActionResult<IEnumerable<Product>>> GetLowStockProducts([FromQuery] int threshold = 10)
    {
        return Ok(await _productService.GetLowStockProductsAsync(threshold));
    }
}