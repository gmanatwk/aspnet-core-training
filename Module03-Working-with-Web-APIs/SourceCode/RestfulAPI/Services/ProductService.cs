using Microsoft.AspNetCore.JsonPatch;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Data;
using RestfulAPI.DTOs;
using RestfulAPI.Models;

namespace RestfulAPI.Services;

/// <summary>
/// Product service implementation with business logic
/// </summary>
public class ProductService : IProductService
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<ProductService> _logger;

    public ProductService(ApplicationDbContext context, ILogger<ProductService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<PagedResponse<ProductDto>> GetProductsAsync(string? category, decimal? minPrice,
        decimal? maxPrice, int pageNumber, int pageSize)
    {
        try
        {
            var query = _context.Products.Where(p => !p.IsDeleted);

            // Apply filters
            if (!string.IsNullOrWhiteSpace(category))
            {
                query = query.Where(p => p.Category.ToLower() == category.ToLower());
            }

            if (minPrice.HasValue)
            {
                query = query.Where(p => p.Price >= minPrice.Value);
            }

            if (maxPrice.HasValue)
            {
                query = query.Where(p => p.Price <= maxPrice.Value);
            }

            // Get total count before pagination
            var totalRecords = await query.CountAsync();

            // Apply pagination
            var products = await query
                .OrderBy(p => p.Name)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .Select(p => MapToDto(p))
                .ToListAsync();

            return new PagedResponse<ProductDto>(products, pageNumber, pageSize, totalRecords);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving products");
            throw;
        }
    }

    public async Task<ProductDto?> GetProductByIdAsync(int id)
    {
        var product = await _context.Products
            .FirstOrDefaultAsync(p => p.Id == id && !p.IsDeleted);

        return product != null ? MapToDto(product) : null;
    }

    public async Task<ProductDto> CreateProductAsync(CreateProductDto createProductDto)
    {
        var product = new Product
        {
            Name = createProductDto.Name,
            Description = createProductDto.Description,
            Price = createProductDto.Price,
            Category = createProductDto.Category,
            StockQuantity = createProductDto.StockQuantity,
            Sku = createProductDto.Sku,
            IsAvailable = createProductDto.StockQuantity > 0,
            CreatedAt = DateTime.UtcNow
        };

        _context.Products.Add(product);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Product created with ID: {ProductId}", product.Id);

        return MapToDto(product);
    }

    public async Task<ProductDto?> UpdateProductAsync(int id, UpdateProductDto updateProductDto)
    {
        var product = await _context.Products
            .FirstOrDefaultAsync(p => p.Id == id && !p.IsDeleted);

        if (product == null)
        {
            return null;
        }

        product.Name = updateProductDto.Name;
        product.Description = updateProductDto.Description;
        product.Price = updateProductDto.Price;
        product.Category = updateProductDto.Category;
        product.StockQuantity = updateProductDto.StockQuantity;
        product.IsAvailable = updateProductDto.IsAvailable ?? product.IsAvailable;
        product.IsActive = updateProductDto.IsActive ?? product.IsActive;
        product.UpdatedAt = DateTime.UtcNow;

        try
        {
            await _context.SaveChangesAsync();
            _logger.LogInformation("Product updated with ID: {ProductId}", product.Id);
            return MapToDto(product);
        }
        catch (DbUpdateConcurrencyException)
        {
            _logger.LogWarning("Concurrency conflict updating product with ID: {ProductId}", id);
            throw;
        }
    }

    public async Task<ProductDto?> PatchProductAsync(int id, JsonPatchDocument<UpdateProductDto> patchDocument,
        ModelStateDictionary modelState)
    {
        var product = await _context.Products
            .FirstOrDefaultAsync(p => p.Id == id && !p.IsDeleted);

        if (product == null)
        {
            return null;
        }

        var productToPatch = new UpdateProductDto
        {
            Name = product.Name,
            Description = product.Description,
            Price = product.Price,
            Category = product.Category,
            StockQuantity = product.StockQuantity,
            Sku = product.Sku,
            IsActive = product.IsActive,
            IsAvailable = product.IsAvailable
        };

        patchDocument.ApplyTo(productToPatch, error =>
        {
            modelState.AddModelError(string.Empty, error.ErrorMessage);
        });

        if (!modelState.IsValid)
        {
            return MapToDto(product);
        }

        product.Name = productToPatch.Name;
        product.Description = productToPatch.Description;
        product.Price = productToPatch.Price;
        product.Category = productToPatch.Category;
        product.StockQuantity = productToPatch.StockQuantity;
        product.IsAvailable = productToPatch.IsAvailable ?? product.IsAvailable;
        product.IsActive = productToPatch.IsActive ?? product.IsActive;
        product.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        _logger.LogInformation("Product patched with ID: {ProductId}", product.Id);

        return MapToDto(product);
    }

    public async Task<bool> DeleteProductAsync(int id)
    {
        var product = await _context.Products
            .FirstOrDefaultAsync(p => p.Id == id && !p.IsDeleted);

        if (product == null)
        {
            return false;
        }

        // Soft delete
        product.IsDeleted = true;
        product.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        _logger.LogInformation("Product soft deleted with ID: {ProductId}", product.Id);

        return true;
    }

    public async Task<IEnumerable<string>> GetCategoriesAsync()
    {
        return await _context.Products
            .Where(p => !p.IsDeleted)
            .Select(p => p.Category)
            .Distinct()
            .OrderBy(c => c)
            .ToListAsync();
    }

    public async Task<PagedResponse<ProductDto>> SearchProductsAsync(string query, int pageNumber, int pageSize)
    {
        var searchQuery = _context.Products
            .Where(p => !p.IsDeleted && 
                (p.Name.Contains(query) || p.Description.Contains(query)));

        var totalRecords = await searchQuery.CountAsync();

        var products = await searchQuery
            .OrderBy(p => p.Name)
            .Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
            .Select(p => MapToDto(p))
            .ToListAsync();

        return new PagedResponse<ProductDto>(products, pageNumber, pageSize, totalRecords);
    }

    public async Task<bool> ProductExistsAsync(int id)
    {
        return await _context.Products.AnyAsync(p => p.Id == id && !p.IsDeleted);
    }

    public async Task<int> GetProductCountAsync()
    {
        return await _context.Products.CountAsync(p => !p.IsDeleted);
    }

    private static ProductDto MapToDto(Product product)
    {
        return new ProductDto
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
    }
}