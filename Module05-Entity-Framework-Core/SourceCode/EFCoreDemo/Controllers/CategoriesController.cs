using AutoMapper;
using EFCoreDemo.DTOs;
using EFCoreDemo.Models;
using EFCoreDemo.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace EFCoreDemo.Controllers;

/// <summary>
/// Categories API Controller demonstrating EF Core operations
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class CategoriesController : ControllerBase
{
    private readonly ICategoryRepository _categoryRepository;
    private readonly IMapper _mapper;
    private readonly ILogger<CategoriesController> _logger;

    public CategoriesController(
        ICategoryRepository categoryRepository,
        IMapper mapper,
        ILogger<CategoriesController> logger)
    {
        _categoryRepository = categoryRepository;
        _mapper = mapper;
        _logger = logger;
    }

    /// <summary>
    /// Get all categories
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<CategoryDto>>> GetCategories()
    {
        try
        {
            var categories = await _categoryRepository.GetCategoriesWithProductCountAsync();
            var categoryDtos = categories.Select(c => new CategoryDto
            {
                Id = c.Id,
                Name = c.Name,
                Description = c.Description,
                Slug = c.Slug,
                IsActive = c.IsActive,
                CreatedAt = c.CreatedAt,
                ProductCount = c.ProductCategories.Count
            });

            return Ok(categoryDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving categories");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get category by ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<CategoryDto>> GetCategory(int id)
    {
        try
        {
            var category = await _categoryRepository.GetByIdAsync(id);
            
            if (category == null)
            {
                return NotFound($"Category with ID {id} not found");
            }

            var categoryDto = new CategoryDto
            {
                Id = category.Id,
                Name = category.Name,
                Description = category.Description,
                Slug = category.Slug,
                IsActive = category.IsActive,
                CreatedAt = category.CreatedAt,
                ProductCount = category.ProductCategories.Count
            };

            return Ok(categoryDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving category {CategoryId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Create a new category
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<CategoryDto>> CreateCategory(CreateCategoryDto createCategoryDto)
    {
        try
        {
            // Generate slug if not provided
            var slug = createCategoryDto.Slug ?? GenerateSlug(createCategoryDto.Name);

            // Validate slug uniqueness
            if (await _categoryRepository.SlugExistsAsync(slug))
            {
                return Conflict($"Category with slug '{slug}' already exists");
            }

            var category = new Category
            {
                Name = createCategoryDto.Name,
                Description = createCategoryDto.Description,
                Slug = slug,
                CreatedAt = DateTime.UtcNow
            };

            var createdCategory = await _categoryRepository.AddAsync(category);
            
            var categoryDto = new CategoryDto
            {
                Id = createdCategory.Id,
                Name = createdCategory.Name,
                Description = createdCategory.Description,
                Slug = createdCategory.Slug,
                IsActive = createdCategory.IsActive,
                CreatedAt = createdCategory.CreatedAt,
                ProductCount = 0
            };

            return CreatedAtAction(nameof(GetCategory), new { id = createdCategory.Id }, categoryDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating category");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Update an existing category
    /// </summary>
    [HttpPut("{id}")]
    public async Task<ActionResult<CategoryDto>> UpdateCategory(int id, UpdateCategoryDto updateCategoryDto)
    {
        try
        {
            var existingCategory = await _categoryRepository.GetByIdAsync(id);
            
            if (existingCategory == null)
            {
                return NotFound($"Category with ID {id} not found");
            }

            // Generate slug if not provided
            var slug = updateCategoryDto.Slug ?? GenerateSlug(updateCategoryDto.Name);

            // Validate slug uniqueness (excluding current category)
            if (await _categoryRepository.SlugExistsAsync(slug, id))
            {
                return Conflict($"Another category with slug '{slug}' already exists");
            }

            // Update properties
            existingCategory.Name = updateCategoryDto.Name;
            existingCategory.Description = updateCategoryDto.Description;
            existingCategory.Slug = slug;
            existingCategory.IsActive = updateCategoryDto.IsActive;

            var updatedCategory = await _categoryRepository.UpdateAsync(existingCategory);
            
            var categoryDto = new CategoryDto
            {
                Id = updatedCategory.Id,
                Name = updatedCategory.Name,
                Description = updatedCategory.Description,
                Slug = updatedCategory.Slug,
                IsActive = updatedCategory.IsActive,
                CreatedAt = updatedCategory.CreatedAt,
                ProductCount = updatedCategory.ProductCategories.Count
            };

            return Ok(categoryDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating category {CategoryId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Delete a category
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteCategory(int id)
    {
        try
        {
            var category = await _categoryRepository.GetByIdAsync(id);
            
            if (category == null)
            {
                return NotFound($"Category with ID {id} not found");
            }

            // Check if category has products
            if (category.ProductCategories.Any())
            {
                return BadRequest("Cannot delete category that has associated products");
            }

            var deleted = await _categoryRepository.DeleteAsync(id);
            
            if (!deleted)
            {
                return NotFound($"Category with ID {id} not found");
            }

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting category {CategoryId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get active categories only
    /// </summary>
    [HttpGet("active")]
    public async Task<ActionResult<IEnumerable<CategoryDto>>> GetActiveCategories()
    {
        try
        {
            var categories = await _categoryRepository.GetActiveCategoriesAsync();
            var categoryDtos = categories.Select(c => new CategoryDto
            {
                Id = c.Id,
                Name = c.Name,
                Description = c.Description,
                Slug = c.Slug,
                IsActive = c.IsActive,
                CreatedAt = c.CreatedAt,
                ProductCount = 0 // Not loaded for performance
            });

            return Ok(categoryDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving active categories");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Generate a URL-friendly slug from category name
    /// </summary>
    private static string GenerateSlug(string name)
    {
        return name.ToLowerInvariant()
                   .Replace(" ", "-")
                   .Replace("&", "and")
                   .Replace("'", "")
                   .Replace("\"", "");
    }
}
