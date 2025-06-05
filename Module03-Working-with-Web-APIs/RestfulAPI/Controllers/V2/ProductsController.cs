using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Data;
using RestfulAPI.DTOs;
using RestfulAPI.Models;
using RestfulAPI.Models.DTOs;
using Asp.Versioning;

namespace RestfulAPI.Controllers.V2
{
    [ApiController]
    [Route("api/v{version:apiVersion}/[controller]")]
    [Produces("application/json")]
    [ApiVersion("2.0")]
    [Authorize]
    public class ProductsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<ProductsController> _logger;

        public ProductsController(ApplicationDbContext context, ILogger<ProductsController> logger)
        {
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// Get all products with pagination and enhanced data
        /// </summary>
        [HttpGet]
        [AllowAnonymous]
        public async Task<ActionResult<PaginatedResponse<ProductDtoV2>>> GetProducts(
            [FromQuery] PaginationParams pagination,
            [FromQuery] string? category = null,
            [FromQuery] string? name = null,
            [FromQuery] decimal? minPrice = null,
            [FromQuery] decimal? maxPrice = null)
        {
            var query = _context.Products.AsQueryable();

            // Apply filters (same as V1)
            if (!string.IsNullOrWhiteSpace(category))
                query = query.Where(p => p.Category.Contains(category));
            
            if (!string.IsNullOrWhiteSpace(name))
                query = query.Where(p => p.Name.Contains(name));
            
            if (minPrice.HasValue)
                query = query.Where(p => p.Price >= minPrice.Value);
            
            if (maxPrice.HasValue)
                query = query.Where(p => p.Price <= maxPrice.Value);

            var totalCount = await query.CountAsync();

            var products = await query
                .Skip((pagination.PageNumber - 1) * pagination.PageSize)
                .Take(pagination.PageSize)
                .Select(p => new ProductDtoV2
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Category = p.Category,
                    StockQuantity = p.StockQuantity,
                    Sku = p.Sku,
                    IsActive = p.IsActive,
                    IsAvailable = p.IsAvailable,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt,
                    // V2 enhanced properties
                    Manufacturer = "Sample Manufacturer",
                    Rating = 4.5m,
                    ReviewCount = 42,
                    Dimensions = "10x10x10 cm",
                    Weight = "1 kg",
                    Tags = new List<string> { p.Category, "Popular" },
                    RelatedProductIds = new List<int> { 1, 2, 3 }
                })
                .ToListAsync();

            return Ok(PaginatedResponse<ProductDtoV2>.Create(
                products, 
                pagination.PageNumber, 
                pagination.PageSize, 
                totalCount));
        }

        /// <summary>
        /// Get a specific product by ID
        /// </summary>
        /// <param name="id">Product ID</param>
        /// <returns>Product details</returns>
        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(ProductDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<ProductDto>> GetProduct(int id)
        {
            _logger.LogInformation("Getting product with ID: {ProductId}", id);

            var product = await _context.Products
                .Where(p => p.Id == id)
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Category = p.Category,
                    StockQuantity = p.StockQuantity,
                    Sku = p.Sku,
                    IsActive = p.IsActive,
                    IsAvailable = p.IsAvailable,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .FirstOrDefaultAsync();

            if (product == null)
            {
                _logger.LogWarning("Product with ID {ProductId} not found", id);
                return NotFound(new { message = $"Product with ID {id} not found" });
            }

            return Ok(product);
        }

        /// <summary>
        /// Create a new product
        /// </summary>
        /// <param name="createProductDto">Product creation data</param>
        /// <returns>Created product</returns>
        [HttpPost]
        [Authorize(Policy = "RequireLibrarianRole")]
        [ProducesResponseType(typeof(BookDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<ActionResult<ProductDto>> CreateProduct([FromBody] CreateProductDto createProductDto)
        {
            _logger.LogInformation("Creating new product: {ProductName}", createProductDto.Name);

            // Check for duplicate SKU
            var skuExists = await _context.Products.AnyAsync(p => p.Sku == createProductDto.Sku);
            if (skuExists)
            {
                return BadRequest(new { message = $"Product with SKU {createProductDto.Sku} already exists" });
            }

            var product = new Product
            {
                Name = createProductDto.Name,
                Description = createProductDto.Description,
                Price = createProductDto.Price,
                Category = createProductDto.Category,
                StockQuantity = createProductDto.StockQuantity,
                Sku = createProductDto.Sku,
                IsActive = createProductDto.IsActive ?? true,
                IsAvailable = true,
                CreatedAt = DateTime.UtcNow
            };

            _context.Products.Add(product);
            await _context.SaveChangesAsync();

            var productDto = new ProductDto
            {
                Id = product.Id,
                Name = product.Name,
                Description = product.Description,
                Price = product.Price,
                Category = product.Category,
                StockQuantity = product.StockQuantity,
                Sku = product.Sku,
                IsActive = product.IsActive,
                IsAvailable = product.IsAvailable,
                CreatedAt = product.CreatedAt,
                UpdatedAt = product.UpdatedAt
            };

            return CreatedAtAction(
                nameof(GetProduct),
                new { id = product.Id },
                productDto);
        }

        /// <summary>
        /// Update an existing product
        /// </summary>
        /// <param name="id">Product ID</param>
        /// <param name="updateProductDto">Updated product data</param>
        /// <returns>No content</returns>
        [HttpPut("{id:int}")]
        [Authorize(Policy = "RequireLibrarianRole")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<IActionResult> UpdateProduct(int id, [FromBody] UpdateProductDto updateProductDto)
        {
            _logger.LogInformation("Updating product with ID: {ProductId}", id);

            var product = await _context.Products.FindAsync(id);
            if (product == null)
            {
                return NotFound(new { message = $"Product with ID {id} not found" });
            }

            // Check for duplicate SKU (if changed)
            if (!string.IsNullOrEmpty(updateProductDto.Sku) && product.Sku != updateProductDto.Sku)
            {
                var skuExists = await _context.Products.AnyAsync(p => p.Sku == updateProductDto.Sku && p.Id != id);
                if (skuExists)
                {
                    return BadRequest(new { message = $"Product with SKU {updateProductDto.Sku} already exists" });
                }
            }

            product.Name = updateProductDto.Name;
            product.Description = updateProductDto.Description;
            product.Price = updateProductDto.Price;
            product.Category = updateProductDto.Category;
            product.StockQuantity = updateProductDto.StockQuantity;

            if (!string.IsNullOrEmpty(updateProductDto.Sku))
            {
                product.Sku = updateProductDto.Sku;
            }

            if (updateProductDto.IsActive.HasValue)
            {
                product.IsActive = updateProductDto.IsActive.Value;
            }

            if (updateProductDto.IsAvailable.HasValue)
            {
                product.IsAvailable = updateProductDto.IsAvailable.Value;
            }

            product.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return NoContent();
        }

        /// <summary>
        /// Delete a product
        /// </summary>
        /// <param name="id">Product ID</param>
        /// <returns>No content</returns>
        [HttpDelete("{id:int}")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<IActionResult> DeleteProduct(int id)
        {
            _logger.LogInformation("Deleting product with ID: {ProductId}", id);

            var product = await _context.Products.FindAsync(id);
            if (product == null)
            {
                return NotFound(new { message = $"Product with ID {id} not found" });
            }

            _context.Products.Remove(product);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        /// <summary>
        /// Get products by category
        /// </summary>
        /// <param name="category">Category name</param>
        /// <returns>List of products in the category</returns>
        [HttpGet("by-category/{category}")]
        [ProducesResponseType(typeof(IEnumerable<ProductDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<ProductDto>>> GetProductsByCategory(string category)
        {
            var products = await _context.Products
                .Where(p => p.Category.Contains(category))
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Category = p.Category,
                    StockQuantity = p.StockQuantity,
                    Sku = p.Sku,
                    IsActive = p.IsActive,
                    IsAvailable = p.IsAvailable,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .ToListAsync();

            return Ok(products);
        }
    }
}