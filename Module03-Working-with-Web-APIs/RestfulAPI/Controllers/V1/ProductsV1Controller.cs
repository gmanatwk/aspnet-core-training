using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;
using RestfulAPI.Models;
using RestfulAPI.DTOs;
using RestfulAPI.Data;
using Microsoft.EntityFrameworkCore;

namespace RestfulAPI.Controllers.V1
{
    [ApiVersion("1.0")]
    [ApiController]
    [Route("api/v{version:apiVersion}/products")]
    [Produces("application/json")]
    public class ProductsV1Controller : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<ProductsV1Controller> _logger;

        public ProductsV1Controller(ApplicationDbContext context, ILogger<ProductsV1Controller> logger)
        {
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// Get all products (V1 - basic filtering)
        /// </summary>
        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<ProductDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<ProductDto>>> GetProducts(
            [FromQuery] string? category = null,
            [FromQuery] string? name = null)
        {
            _logger.LogInformation("V1 API: Getting products with basic filters");

            var query = _context.Products.AsQueryable();

            if (!string.IsNullOrWhiteSpace(category))
            {
                query = query.Where(p => p.Category.Contains(category));
            }

            if (!string.IsNullOrWhiteSpace(name))
            {
                query = query.Where(p => p.Name.Contains(name));
            }

            var products = await query
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
