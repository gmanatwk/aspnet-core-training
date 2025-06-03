using Microsoft.AspNetCore.Mvc;
using AsyncDatabase.Models;
using AsyncDatabase.Services;

namespace AsyncDatabase.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductsController : ControllerBase
    {
        private readonly IProductService _productService;
        private readonly ILogger<ProductsController> _logger;

        public ProductsController(IProductService productService, ILogger<ProductsController> logger)
        {
            _productService = productService;
            _logger = logger;
        }

        // GET: api/products
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Product>>> GetProducts()
        {
            try
            {
                var products = await _productService.GetAllProductsAsync();
                return Ok(products);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching products");
                return StatusCode(500, "Internal server error");
            }
        }

        // GET: api/products/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Product>> GetProduct(int id)
        {
            try
            {
                var product = await _productService.GetProductByIdAsync(id);
                
                if (product == null)
                {
                    return NotFound();
                }

                return Ok(product);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching product {ProductId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        // GET: api/products/category/electronics
        [HttpGet("category/{category}")]
        public async Task<ActionResult<IEnumerable<Product>>> GetProductsByCategory(string category)
        {
            try
            {
                var products = await _productService.GetProductsByCategoryAsync(category);
                return Ok(products);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching products for category {Category}", category);
                return StatusCode(500, "Internal server error");
            }
        }

        // GET: api/products/search?term=laptop
        [HttpGet("search")]
        public async Task<ActionResult<IEnumerable<Product>>> SearchProducts([FromQuery] string term)
        {
            if (string.IsNullOrWhiteSpace(term))
            {
                return BadRequest("Search term cannot be empty");
            }

            try
            {
                var products = await _productService.SearchProductsAsync(term);
                return Ok(products);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching products with term {SearchTerm}", term);
                return StatusCode(500, "Internal server error");
            }
        }

        // GET: api/products/expensive?minPrice=100
        [HttpGet("expensive")]
        public async Task<ActionResult<IEnumerable<Product>>> GetExpensiveProducts([FromQuery] decimal minPrice = 100)
        {
            try
            {
                var products = await _productService.GetExpensiveProductsAsync(minPrice);
                return Ok(products);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching expensive products with minimum price {MinPrice}", minPrice);
                return StatusCode(500, "Internal server error");
            }
        }

        // GET: api/products/stats/electronics
        [HttpGet("stats/{category}")]
        public async Task<ActionResult> GetCategoryStats(string category)
        {
            try
            {
                // Execute multiple async operations concurrently
                var countTask = _productService.GetProductCountByCategoryAsync(category);
                var avgPriceTask = _productService.GetAveragePriceByCategoryAsync(category);
                var productsTask = _productService.GetProductsByCategoryAsync(category);

                // Wait for all operations to complete
                await Task.WhenAll(countTask, avgPriceTask, productsTask);

                var count = await countTask;
                var avgPrice = await avgPriceTask;
                var products = await productsTask;

                return Ok(new
                {
                    Category = category,
                    ProductCount = count,
                    AveragePrice = avgPrice,
                    MinPrice = products.Any() ? products.Min(p => p.Price) : 0,
                    MaxPrice = products.Any() ? products.Max(p => p.Price) : 0,
                    Products = products.Take(5) // Return first 5 products as sample
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching stats for category {Category}", category);
                return StatusCode(500, "Internal server error");
            }
        }

        // POST: api/products
        [HttpPost]
        public async Task<ActionResult<Product>> CreateProduct(CreateProductRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var product = new Product
                {
                    Name = request.Name,
                    Description = request.Description,
                    Price = request.Price,
                    Category = request.Category
                };

                var createdProduct = await _productService.CreateProductAsync(product);
                
                return CreatedAtAction(
                    nameof(GetProduct), 
                    new { id = createdProduct.Id }, 
                    createdProduct);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating product");
                return StatusCode(500, "Internal server error");
            }
        }

        // PUT: api/products/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateProduct(int id, UpdateProductRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var product = new Product
                {
                    Name = request.Name,
                    Description = request.Description,
                    Price = request.Price,
                    Category = request.Category
                };

                var updatedProduct = await _productService.UpdateProductAsync(id, product);
                
                if (updatedProduct == null)
                {
                    return NotFound();
                }

                return Ok(updatedProduct);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating product {ProductId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        // DELETE: api/products/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteProduct(int id)
        {
            try
            {
                var result = await _productService.DeleteProductAsync(id);
                
                if (!result)
                {
                    return NotFound();
                }

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting product {ProductId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        // POST: api/products/bulk-update-prices
        [HttpPost("bulk-update-prices")]
        public async Task<IActionResult> BulkUpdatePrices(BulkUpdateRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                await _productService.BulkUpdatePricesAsync(request.Category, request.Percentage);
                return Ok(new { Message = "Prices updated successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error bulk updating prices for category {Category}", request.Category);
                return StatusCode(500, "Internal server error");
            }
        }
    }

    // Request/Response DTOs
    public class CreateProductRequest
    {
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public string Category { get; set; } = string.Empty;
    }

    public class UpdateProductRequest
    {
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public string Category { get; set; } = string.Empty;
    }

    public class BulkUpdateRequest
    {
        public string Category { get; set; } = string.Empty;
        public decimal Percentage { get; set; }
    }
}