using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;
using RestfulAPI.Models;
using RestfulAPI.DTOs;
using RestfulAPI.Data;
using Microsoft.EntityFrameworkCore;

namespace RestfulAPI.Controllers.V2
{
    [ApiVersion("2.0")]
    [ApiController]
    [Route("api/v{version:apiVersion}/products")]
    [Produces("application/json")]
    public class ProductsV2Controller : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<ProductsV2Controller> _logger;

        public ProductsV2Controller(ApplicationDbContext context, ILogger<ProductsV2Controller> logger)
        {
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// Get all products with pagination (V2 enhancement)
        /// </summary>
        [HttpGet]
        [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetProducts(
            [FromQuery] string? category = null,
            [FromQuery] string? name = null,
            [FromQuery] decimal? minPrice = null,
            [FromQuery] decimal? maxPrice = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            _logger.LogInformation("V2 API: Getting products with pagination and advanced filters");

            var query = _context.Products.AsQueryable();

            // Apply filters
            if (!string.IsNullOrWhiteSpace(category))
            {
                query = query.Where(p => p.Category.Contains(category));
            }

            if (!string.IsNullOrWhiteSpace(name))
            {
                query = query.Where(p => p.Name.Contains(name));
            }

            if (minPrice.HasValue)
            {
                query = query.Where(p => p.Price >= minPrice.Value);
            }

            if (maxPrice.HasValue)
            {
                query = query.Where(p => p.Price <= maxPrice.Value);
            }

            // Get total count for pagination
            var totalItems = await query.CountAsync();

            // Apply pagination
            var products = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
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

            // V2 returns paginated response with metadata
            return Ok(new
            {
                page = page,
                pageSize = pageSize,
                totalItems = totalItems,
                totalPages = (int)Math.Ceiling(totalItems / (double)pageSize),
                hasNextPage = page < (int)Math.Ceiling(totalItems / (double)pageSize),
                hasPreviousPage = page > 1,
                items = products
            });
        }

        /// <summary>
        /// Get product statistics (V2 exclusive feature)
        /// </summary>
        [HttpGet("statistics")]
        [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetProductStatistics()
        {
            var stats = await _context.Products
                .GroupBy(p => p.Category)
                .Select(g => new
                {
                    Category = g.Key,
                    Count = g.Count(),
                    AveragePrice = g.Average(p => p.Price),
                    TotalStock = g.Sum(p => p.StockQuantity)
                })
                .ToListAsync();

            var totalProducts = await _context.Products.CountAsync();
            var totalValue = await _context.Products.SumAsync(p => p.Price * p.StockQuantity);

            return Ok(new
            {
                TotalProducts = totalProducts,
                TotalInventoryValue = totalValue,
                CategoryBreakdown = stats
            });
        }
    }
}
