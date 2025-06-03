using AutoMapper;
using EFCoreDemo.DTOs;
using EFCoreDemo.Models;
using EFCoreDemo.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace EFCoreDemo.Controllers;

/// <summary>
/// Products API Controller demonstrating EF Core operations
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductRepository _productRepository;
    private readonly ICategoryRepository _categoryRepository;
    private readonly IMapper _mapper;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(
        IProductRepository productRepository,
        ICategoryRepository categoryRepository,
        IMapper mapper,
        ILogger<ProductsController> logger)
    {
        _productRepository = productRepository;
        _categoryRepository = categoryRepository;
        _mapper = mapper;
        _logger = logger;
    }

    /// <summary>
    /// Get all products with pagination and filtering
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<PagedResultDto<ProductDto>>> GetProducts([FromQuery] ProductSearchDto searchDto)
    {
        try
        {
            var pagedResult = await _productRepository.GetProductsPagedAsync(searchDto);
            var productDtos = _mapper.Map<IEnumerable<ProductDto>>(pagedResult.Data);

            return Ok(new PagedResultDto<ProductDto>
            {
                Data = productDtos,
                TotalCount = pagedResult.TotalCount,
                Page = pagedResult.Page,
                PageSize = pagedResult.PageSize
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving products");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get product by ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<ProductDto>> GetProduct(int id)
    {
        try
        {
            var product = await _productRepository.GetProductWithCategoriesAsync(id);
            
            if (product == null)
            {
                return NotFound($"Product with ID {id} not found");
            }

            var productDto = _mapper.Map<ProductDto>(product);
            return Ok(productDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving product {ProductId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Create a new product
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<ProductDto>> CreateProduct(CreateProductDto createProductDto)
    {
        try
        {
            // Validate SKU uniqueness
            if (await _productRepository.SKUExistsAsync(createProductDto.SKU))
            {
                return Conflict($"Product with SKU '{createProductDto.SKU}' already exists");
            }

            // Validate categories exist
            foreach (var categoryId in createProductDto.CategoryIds)
            {
                if (!await _categoryRepository.ExistsAsync(categoryId))
                {
                    return BadRequest($"Category with ID {categoryId} does not exist");
                }
            }

            var product = _mapper.Map<Product>(createProductDto);
            
            // Add category relationships
            foreach (var categoryId in createProductDto.CategoryIds)
            {
                product.ProductCategories.Add(new ProductCategory
                {
                    CategoryId = categoryId,
                    AssignedAt = DateTime.UtcNow
                });
            }

            var createdProduct = await _productRepository.AddAsync(product);
            var productDto = _mapper.Map<ProductDto>(createdProduct);

            return CreatedAtAction(nameof(GetProduct), new { id = createdProduct.Id }, productDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating product");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Update an existing product
    /// </summary>
    [HttpPut("{id}")]
    public async Task<ActionResult<ProductDto>> UpdateProduct(int id, UpdateProductDto updateProductDto)
    {
        try
        {
            var existingProduct = await _productRepository.GetProductWithCategoriesAsync(id);
            
            if (existingProduct == null)
            {
                return NotFound($"Product with ID {id} not found");
            }

            // Validate SKU uniqueness (excluding current product)
            if (await _productRepository.SKUExistsAsync(existingProduct.SKU, id))
            {
                return Conflict($"Another product with SKU '{existingProduct.SKU}' already exists");
            }

            // Update product properties
            _mapper.Map(updateProductDto, existingProduct);
            existingProduct.UpdatedAt = DateTime.UtcNow;

            // Update category relationships
            existingProduct.ProductCategories.Clear();
            foreach (var categoryId in updateProductDto.CategoryIds)
            {
                if (!await _categoryRepository.ExistsAsync(categoryId))
                {
                    return BadRequest($"Category with ID {categoryId} does not exist");
                }

                existingProduct.ProductCategories.Add(new ProductCategory
                {
                    ProductId = id,
                    CategoryId = categoryId,
                    AssignedAt = DateTime.UtcNow
                });
            }

            var updatedProduct = await _productRepository.UpdateAsync(existingProduct);
            var productDto = _mapper.Map<ProductDto>(updatedProduct);

            return Ok(productDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating product {ProductId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Delete a product
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteProduct(int id)
    {
        try
        {
            var deleted = await _productRepository.DeleteAsync(id);
            
            if (!deleted)
            {
                return NotFound($"Product with ID {id} not found");
            }

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting product {ProductId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Search products by term
    /// </summary>
    [HttpGet("search")]
    public async Task<ActionResult<IEnumerable<ProductDto>>> SearchProducts([FromQuery] string searchTerm)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
            {
                return BadRequest("Search term is required");
            }

            var products = await _productRepository.SearchProductsAsync(searchTerm);
            var productDtos = _mapper.Map<IEnumerable<ProductDto>>(products);

            return Ok(productDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error searching products with term: {SearchTerm}", searchTerm);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get products by category
    /// </summary>
    [HttpGet("category/{categoryId}")]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetProductsByCategory(int categoryId)
    {
        try
        {
            if (!await _categoryRepository.ExistsAsync(categoryId))
            {
                return NotFound($"Category with ID {categoryId} not found");
            }

            var products = await _productRepository.GetProductsByCategoryAsync(categoryId);
            var productDtos = _mapper.Map<IEnumerable<ProductDto>>(products);

            return Ok(productDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving products for category {CategoryId}", categoryId);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get low stock products
    /// </summary>
    [HttpGet("low-stock")]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetLowStockProducts([FromQuery] int threshold = 10)
    {
        try
        {
            var products = await _productRepository.GetLowStockProductsAsync(threshold);
            var productDtos = _mapper.Map<IEnumerable<ProductDto>>(products);

            return Ok(productDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving low stock products");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Update product stock
    /// </summary>
    [HttpPatch("{id}/stock")]
    public async Task<IActionResult> UpdateStock(int id, [FromBody] int newStock)
    {
        try
        {
            if (newStock < 0)
            {
                return BadRequest("Stock quantity cannot be negative");
            }

            var updated = await _productRepository.UpdateStockAsync(id, newStock);
            
            if (!updated)
            {
                return NotFound($"Product with ID {id} not found");
            }

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating stock for product {ProductId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get product statistics
    /// </summary>
    [HttpGet("statistics")]
    public async Task<ActionResult<object>> GetProductStatistics()
    {
        try
        {
            var totalCount = await _productRepository.CountAsync();
            var activeCount = await _productRepository.CountAsync(p => p.IsActive);
            var averagePrice = await _productRepository.GetAveragePriceAsync();

            var statistics = new
            {
                TotalProducts = totalCount,
                ActiveProducts = activeCount,
                InactiveProducts = totalCount - activeCount,
                AveragePrice = Math.Round(averagePrice, 2)
            };

            return Ok(statistics);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving product statistics");
            return StatusCode(500, "Internal server error");
        }
    }
}
