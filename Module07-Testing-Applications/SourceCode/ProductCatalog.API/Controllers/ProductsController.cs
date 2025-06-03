using Microsoft.AspNetCore.Mvc;
using ProductCatalog.API.DTOs;
using ProductCatalog.API.Services;

namespace ProductCatalog.API.Controllers;

/// <summary>
/// Controller for managing products
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(IProductService productService, ILogger<ProductsController> logger)
    {
        _productService = productService;
        _logger = logger;
    }

    /// <summary>
    /// Get products with search and pagination
    /// </summary>
    /// <param name="searchDto">Search parameters</param>
    /// <returns>Paginated list of products</returns>
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<PagedResponse<ProductResponseDto>>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<ActionResult<ApiResponse<PagedResponse<ProductResponseDto>>>> GetProducts([FromQuery] ProductSearchDto searchDto)
    {
        try
        {
            _logger.LogInformation("Getting products with search criteria");

            var result = await _productService.GetProductsAsync(searchDto);

            return Ok(new ApiResponse<PagedResponse<ProductResponseDto>>
            {
                Success = true,
                Message = "Products retrieved successfully",
                Data = result
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting products");
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Error retrieving products",
                Errors = new List<string> { ex.Message }
            });
        }
    }

    /// <summary>
    /// Get product by ID
    /// </summary>
    /// <param name="id">Product ID</param>
    /// <returns>Product details</returns>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<ProductResponseDto>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 404)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<ActionResult<ApiResponse<ProductResponseDto>>> GetProduct(int id)
    {
        try
        {
            _logger.LogInformation("Getting product by ID: {ProductId}", id);

            if (id <= 0)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid product ID",
                    Errors = new List<string> { "Product ID must be greater than 0" }
                });
            }

            var product = await _productService.GetProductByIdAsync(id);

            if (product == null)
            {
                return NotFound(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Product not found",
                    Errors = new List<string> { $"Product with ID {id} was not found" }
                });
            }

            return Ok(new ApiResponse<ProductResponseDto>
            {
                Success = true,
                Message = "Product retrieved successfully",
                Data = product
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting product by ID: {ProductId}", id);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Error retrieving product",
                Errors = new List<string> { ex.Message }
            });
        }
    }

    /// <summary>
    /// Create a new product
    /// </summary>
    /// <param name="createDto">Product creation data</param>
    /// <returns>Created product</returns>
    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<ProductResponseDto>), 201)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<ActionResult<ApiResponse<ProductResponseDto>>> CreateProduct([FromBody] CreateProductDto createDto)
    {
        try
        {
            _logger.LogInformation("Creating new product: {ProductName}", createDto.Name);

            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values
                    .SelectMany(v => v.Errors)
                    .Select(e => e.ErrorMessage)
                    .ToList();

                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Validation failed",
                    Errors = errors
                });
            }

            var product = await _productService.CreateProductAsync(createDto);

            return CreatedAtAction(
                nameof(GetProduct),
                new { id = product.Id },
                new ApiResponse<ProductResponseDto>
                {
                    Success = true,
                    Message = "Product created successfully",
                    Data = product
                });
        }
        catch (ArgumentException ex)
        {
            _logger.LogWarning(ex, "Validation error creating product: {ProductName}", createDto.Name);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Validation error",
                Errors = new List<string> { ex.Message }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating product: {ProductName}", createDto.Name);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Error creating product",
                Errors = new List<string> { ex.Message }
            });
        }
    }

    /// <summary>
    /// Update an existing product
    /// </summary>
    /// <param name="id">Product ID</param>
    /// <param name="updateDto">Product update data</param>
    /// <returns>Updated product</returns>
    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<ProductResponseDto>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 404)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<ActionResult<ApiResponse<ProductResponseDto>>> UpdateProduct(int id, [FromBody] UpdateProductDto updateDto)
    {
        try
        {
            _logger.LogInformation("Updating product: {ProductId}", id);

            if (id <= 0)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid product ID",
                    Errors = new List<string> { "Product ID must be greater than 0" }
                });
            }

            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values
                    .SelectMany(v => v.Errors)
                    .Select(e => e.ErrorMessage)
                    .ToList();

                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Validation failed",
                    Errors = errors
                });
            }

            var product = await _productService.UpdateProductAsync(id, updateDto);

            if (product == null)
            {
                return NotFound(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Product not found",
                    Errors = new List<string> { $"Product with ID {id} was not found" }
                });
            }

            return Ok(new ApiResponse<ProductResponseDto>
            {
                Success = true,
                Message = "Product updated successfully",
                Data = product
            });
        }
        catch (ArgumentException ex)
        {
            _logger.LogWarning(ex, "Validation error updating product: {ProductId}", id);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Validation error",
                Errors = new List<string> { ex.Message }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating product: {ProductId}", id);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Error updating product",
                Errors = new List<string> { ex.Message }
            });
        }
    }

    /// <summary>
    /// Delete a product (soft delete)
    /// </summary>
    /// <param name="id">Product ID</param>
    /// <returns>Success confirmation</returns>
    [HttpDelete("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<object>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 404)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<ActionResult<ApiResponse<object>>> DeleteProduct(int id)
    {
        try
        {
            _logger.LogInformation("Deleting product: {ProductId}", id);

            if (id <= 0)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid product ID",
                    Errors = new List<string> { "Product ID must be greater than 0" }
                });
            }

            var success = await _productService.DeleteProductAsync(id);

            if (!success)
            {
                return NotFound(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Product not found",
                    Errors = new List<string> { $"Product with ID {id} was not found" }
                });
            }

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Product deleted successfully",
                Data = null
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting product: {ProductId}", id);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Error deleting product",
                Errors = new List<string> { ex.Message }
            });
        }
    }

    /// <summary>
    /// Update product stock
    /// </summary>
    /// <param name="id">Product ID</param>
    /// <param name="newStock">New stock quantity</param>
    /// <returns>Success confirmation</returns>
    [HttpPatch("{id:int}/stock")]
    [ProducesResponseType(typeof(ApiResponse<object>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 404)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<ActionResult<ApiResponse<object>>> UpdateStock(int id, [FromBody] int newStock)
    {
        try
        {
            _logger.LogInformation("Updating stock for product {ProductId} to {NewStock}", id, newStock);

            if (id <= 0)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid product ID",
                    Errors = new List<string> { "Product ID must be greater than 0" }
                });
            }

            if (newStock < 0)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid stock quantity",
                    Errors = new List<string> { "Stock cannot be negative" }
                });
            }

            var success = await _productService.UpdateStockAsync(id, newStock);

            if (!success)
            {
                return NotFound(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Product not found",
                    Errors = new List<string> { $"Product with ID {id} was not found" }
                });
            }

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Stock updated successfully",
                Data = new { ProductId = id, NewStock = newStock }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating stock for product: {ProductId}", id);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Error updating stock",
                Errors = new List<string> { ex.Message }
            });
        }
    }

    /// <summary>
    /// Get products by category
    /// </summary>
    /// <param name="categoryId">Category ID</param>
    /// <returns>List of products in the category</returns>
    [HttpGet("category/{categoryId:int}")]
    [ProducesResponseType(typeof(ApiResponse<List<ProductResponseDto>>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<ActionResult<ApiResponse<List<ProductResponseDto>>>> GetProductsByCategory(int categoryId)
    {
        try
        {
            _logger.LogInformation("Getting products by category: {CategoryId}", categoryId);

            if (categoryId <= 0)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid category ID",
                    Errors = new List<string> { "Category ID must be greater than 0" }
                });
            }

            var products = await _productService.GetProductsByCategoryAsync(categoryId);

            return Ok(new ApiResponse<List<ProductResponseDto>>
            {
                Success = true,
                Message = "Products retrieved successfully",
                Data = products
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting products by category: {CategoryId}", categoryId);
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Error retrieving products",
                Errors = new List<string> { ex.Message }
            });
        }
    }

    /// <summary>
    /// Get low stock products
    /// </summary>
    /// <param name="threshold">Stock threshold (default: 10)</param>
    /// <returns>List of low stock products</returns>
    [HttpGet("low-stock")]
    [ProducesResponseType(typeof(ApiResponse<List<ProductResponseDto>>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<ActionResult<ApiResponse<List<ProductResponseDto>>>> GetLowStockProducts([FromQuery] int threshold = 10)
    {
        try
        {
            _logger.LogInformation("Getting low stock products with threshold: {Threshold}", threshold);

            if (threshold < 0)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid threshold",
                    Errors = new List<string> { "Threshold cannot be negative" }
                });
            }

            var products = await _productService.GetLowStockProductsAsync(threshold);

            return Ok(new ApiResponse<List<ProductResponseDto>>
            {
                Success = true,
                Message = "Low stock products retrieved successfully",
                Data = products
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting low stock products");
            return BadRequest(new ApiResponse<object>
            {
                Success = false,
                Message = "Error retrieving low stock products",
                Errors = new List<string> { ex.Message }
            });
        }
    }

    /// <summary>
    /// Check if product exists
    /// </summary>
    /// <param name="id">Product ID</param>
    /// <returns>Existence confirmation</returns>
    [HttpHead("{id:int}")]
    [ProducesResponseType(200)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> ProductExists(int id)
    {
        try
        {
            var exists = await _productService.ProductExistsAsync(id);
            return exists ? Ok() : NotFound();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking if product exists: {ProductId}", id);
            return BadRequest();
        }
    }
}
