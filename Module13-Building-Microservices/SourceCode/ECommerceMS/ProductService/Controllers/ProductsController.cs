using Microsoft.AspNetCore.Mvc;
using ProductService.Models;
using ProductService.Services;
using SharedLibrary.Models;

namespace ProductService.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductRepository _repository;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(IProductRepository repository, ILogger<ProductsController> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<IEnumerable<ProductDto>>>> GetAll()
    {
        try
        {
            var products = await _repository.GetAllAsync();
            var productDtos = products.Select(p => MapToDto(p));
            return Ok(ApiResponse<IEnumerable<ProductDto>>.SuccessResponse(productDtos));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving products");
            return StatusCode(500, ApiResponse<IEnumerable<ProductDto>>.ErrorResponse("Error retrieving products"));
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ApiResponse<ProductDto>>> GetById(int id)
    {
        try
        {
            var product = await _repository.GetByIdAsync(id);
            if (product == null)
            {
                return NotFound(ApiResponse<ProductDto>.ErrorResponse($"Product with ID {id} not found"));
            }

            return Ok(ApiResponse<ProductDto>.SuccessResponse(MapToDto(product)));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving product {ProductId}", id);
            return StatusCode(500, ApiResponse<ProductDto>.ErrorResponse("Error retrieving product"));
        }
    }

    [HttpGet("category/{category}")]
    public async Task<ActionResult<ApiResponse<IEnumerable<ProductDto>>>> GetByCategory(string category)
    {
        try
        {
            var products = await _repository.GetByCategoryAsync(category);
            var productDtos = products.Select(p => MapToDto(p));
            return Ok(ApiResponse<IEnumerable<ProductDto>>.SuccessResponse(productDtos));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving products by category {Category}", category);
            return StatusCode(500, ApiResponse<IEnumerable<ProductDto>>.ErrorResponse("Error retrieving products"));
        }
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<ProductDto>>> Create(CreateProductDto createDto)
    {
        try
        {
            var product = new Product
            {
                Name = createDto.Name,
                Description = createDto.Description,
                Price = createDto.Price,
                StockQuantity = createDto.StockQuantity,
                Category = createDto.Category
            };

            var created = await _repository.CreateAsync(product);
            var dto = MapToDto(created);
            
            return CreatedAtAction(
                nameof(GetById), 
                new { id = created.Id }, 
                ApiResponse<ProductDto>.SuccessResponse(dto, "Product created successfully"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating product");
            return StatusCode(500, ApiResponse<ProductDto>.ErrorResponse("Error creating product"));
        }
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<ApiResponse<ProductDto>>> Update(int id, UpdateProductDto updateDto)
    {
        try
        {
            var existing = await _repository.GetByIdAsync(id);
            if (existing == null)
            {
                return NotFound(ApiResponse<ProductDto>.ErrorResponse($"Product with ID {id} not found"));
            }

            existing.Name = updateDto.Name ?? existing.Name;
            existing.Description = updateDto.Description ?? existing.Description;
            existing.Price = updateDto.Price ?? existing.Price;
            existing.StockQuantity = updateDto.StockQuantity ?? existing.StockQuantity;
            existing.Category = updateDto.Category ?? existing.Category;

            var updated = await _repository.UpdateAsync(id, existing);
            if (updated == null)
            {
                return NotFound(ApiResponse<ProductDto>.ErrorResponse($"Product with ID {id} not found"));
            }

            return Ok(ApiResponse<ProductDto>.SuccessResponse(MapToDto(updated), "Product updated successfully"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating product {ProductId}", id);
            return StatusCode(500, ApiResponse<ProductDto>.ErrorResponse("Error updating product"));
        }
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult<ApiResponse<bool>>> Delete(int id)
    {
        try
        {
            var deleted = await _repository.DeleteAsync(id);
            if (!deleted)
            {
                return NotFound(ApiResponse<bool>.ErrorResponse($"Product with ID {id} not found"));
            }

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Product deleted successfully"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting product {ProductId}", id);
            return StatusCode(500, ApiResponse<bool>.ErrorResponse("Error deleting product"));
        }
    }

    [HttpPatch("{id}/stock")]
    public async Task<ActionResult<ApiResponse<bool>>> UpdateStock(int id, [FromBody] int quantity)
    {
        try
        {
            var updated = await _repository.UpdateStockAsync(id, quantity);
            if (!updated)
            {
                return NotFound(ApiResponse<bool>.ErrorResponse($"Product with ID {id} not found"));
            }

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Stock updated successfully"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating stock for product {ProductId}", id);
            return StatusCode(500, ApiResponse<bool>.ErrorResponse("Error updating stock"));
        }
    }

    private static ProductDto MapToDto(Product product)
    {
        return new ProductDto
        {
            Id = product.Id,
            Name = product.Name,
            Description = product.Description,
            Price = product.Price,
            StockQuantity = product.StockQuantity,
            Category = product.Category,
            CreatedAt = product.CreatedAt,
            UpdatedAt = product.UpdatedAt
        };
    }
}