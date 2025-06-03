using Microsoft.EntityFrameworkCore;
using ProductCatalog.API.Data;
using ProductCatalog.API.DTOs;
using ProductCatalog.API.Models;

namespace ProductCatalog.API.Services;

/// <summary>
/// Interface for product service operations
/// </summary>
public interface IProductService
{
    Task<PagedResponse<ProductResponseDto>> GetProductsAsync(ProductSearchDto searchDto);
    Task<ProductResponseDto?> GetProductByIdAsync(int id);
    Task<ProductResponseDto> CreateProductAsync(CreateProductDto createDto);
    Task<ProductResponseDto?> UpdateProductAsync(int id, UpdateProductDto updateDto);
    Task<bool> DeleteProductAsync(int id);
    Task<bool> UpdateStockAsync(int productId, int newStock);
    Task<List<ProductResponseDto>> GetProductsByCategoryAsync(int categoryId);
    Task<List<ProductResponseDto>> GetLowStockProductsAsync(int threshold = 10);
    Task<bool> ProductExistsAsync(int id);
    Task<bool> IsSkuUniqueAsync(string sku, int? excludeProductId = null);
}

/// <summary>
/// Product service implementation
/// </summary>
public class ProductService : IProductService
{
    private readonly ProductCatalogContext _context;
    private readonly ILogger<ProductService> _logger;

    public ProductService(ProductCatalogContext context, ILogger<ProductService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<PagedResponse<ProductResponseDto>> GetProductsAsync(ProductSearchDto searchDto)
    {
        try
        {
            _logger.LogInformation("Getting products with search criteria: {SearchTerm}", searchDto.SearchTerm);

            var query = _context.Products
                .Include(p => p.Category)
                .Include(p => p.ProductTags)
                .ThenInclude(pt => pt.Tag)
                .Where(p => p.IsActive);

            // Apply filters
            if (!string.IsNullOrWhiteSpace(searchDto.SearchTerm))
            {
                var searchTerm = searchDto.SearchTerm.ToLower();
                query = query.Where(p => p.Name.ToLower().Contains(searchTerm) || 
                                        p.Description.ToLower().Contains(searchTerm));
            }

            if (searchDto.CategoryId.HasValue)
            {
                query = query.Where(p => p.CategoryId == searchDto.CategoryId.Value);
            }

            if (searchDto.MinPrice.HasValue)
            {
                query = query.Where(p => p.Price >= searchDto.MinPrice.Value);
            }

            if (searchDto.MaxPrice.HasValue)
            {
                query = query.Where(p => p.Price <= searchDto.MaxPrice.Value);
            }

            if (searchDto.InStockOnly == true)
            {
                query = query.Where(p => p.Stock > 0);
            }

            if (searchDto.TagIds?.Any() == true)
            {
                query = query.Where(p => p.ProductTags.Any(pt => searchDto.TagIds.Contains(pt.TagId)));
            }

            // Apply sorting
            query = searchDto.SortBy.ToLower() switch
            {
                "price" => searchDto.SortDescending ? query.OrderByDescending(p => p.Price) : query.OrderBy(p => p.Price),
                "createdat" => searchDto.SortDescending ? query.OrderByDescending(p => p.CreatedAt) : query.OrderBy(p => p.CreatedAt),
                "stock" => searchDto.SortDescending ? query.OrderByDescending(p => p.Stock) : query.OrderBy(p => p.Stock),
                _ => searchDto.SortDescending ? query.OrderByDescending(p => p.Name) : query.OrderBy(p => p.Name)
            };

            var totalRecords = await query.CountAsync();
            var totalPages = (int)Math.Ceiling(totalRecords / (double)searchDto.PageSize);

            var products = await query
                .Skip((searchDto.PageNumber - 1) * searchDto.PageSize)
                .Take(searchDto.PageSize)
                .Select(p => new ProductResponseDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Stock = p.Stock,
                    CategoryId = p.CategoryId,
                    CategoryName = p.Category.Name,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt,
                    IsActive = p.IsActive,
                    SKU = p.SKU,
                    Weight = p.Weight,
                    ImageUrl = p.ImageUrl,
                    Tags = p.ProductTags.Select(pt => pt.Tag.Name).ToList()
                })
                .ToListAsync();

            return new PagedResponse<ProductResponseDto>
            {
                Data = products,
                PageNumber = searchDto.PageNumber,
                PageSize = searchDto.PageSize,
                TotalPages = totalPages,
                TotalRecords = totalRecords
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting products");
            throw;
        }
    }

    public async Task<ProductResponseDto?> GetProductByIdAsync(int id)
    {
        try
        {
            _logger.LogInformation("Getting product by ID: {ProductId}", id);

            var product = await _context.Products
                .Include(p => p.Category)
                .Include(p => p.ProductTags)
                .ThenInclude(pt => pt.Tag)
                .FirstOrDefaultAsync(p => p.Id == id && p.IsActive);

            if (product == null)
            {
                _logger.LogWarning("Product not found: {ProductId}", id);
                return null;
            }

            return new ProductResponseDto
            {
                Id = product.Id,
                Name = product.Name,
                Description = product.Description,
                Price = product.Price,
                Stock = product.Stock,
                CategoryId = product.CategoryId,
                CategoryName = product.Category.Name,
                CreatedAt = product.CreatedAt,
                UpdatedAt = product.UpdatedAt,
                IsActive = product.IsActive,
                SKU = product.SKU,
                Weight = product.Weight,
                ImageUrl = product.ImageUrl,
                Tags = product.ProductTags.Select(pt => pt.Tag.Name).ToList()
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting product by ID: {ProductId}", id);
            throw;
        }
    }

    public async Task<ProductResponseDto> CreateProductAsync(CreateProductDto createDto)
    {
        try
        {
            _logger.LogInformation("Creating new product: {ProductName}", createDto.Name);

            // Validate category exists
            var categoryExists = await _context.Categories.AnyAsync(c => c.Id == createDto.CategoryId && c.IsActive);
            if (!categoryExists)
            {
                throw new ArgumentException($"Category with ID {createDto.CategoryId} does not exist or is not active");
            }

            // Validate SKU uniqueness if provided
            if (!string.IsNullOrWhiteSpace(createDto.SKU))
            {
                var skuExists = await _context.Products.AnyAsync(p => p.SKU == createDto.SKU);
                if (skuExists)
                {
                    throw new ArgumentException($"Product with SKU '{createDto.SKU}' already exists");
                }
            }

            // Validate tags exist
            if (createDto.TagIds.Any())
            {
                var existingTagIds = await _context.Tags.Where(t => createDto.TagIds.Contains(t.Id)).Select(t => t.Id).ToListAsync();
                var invalidTagIds = createDto.TagIds.Except(existingTagIds).ToList();
                if (invalidTagIds.Any())
                {
                    throw new ArgumentException($"Invalid tag IDs: {string.Join(", ", invalidTagIds)}");
                }
            }

            var product = new Product
            {
                Name = createDto.Name,
                Description = createDto.Description,
                Price = createDto.Price,
                Stock = createDto.Stock,
                CategoryId = createDto.CategoryId,
                SKU = createDto.SKU,
                Weight = createDto.Weight,
                ImageUrl = createDto.ImageUrl,
                CreatedAt = DateTime.UtcNow,
                IsActive = true
            };

            _context.Products.Add(product);
            await _context.SaveChangesAsync();

            // Add product tags
            if (createDto.TagIds.Any())
            {
                var productTags = createDto.TagIds.Select(tagId => new ProductTag
                {
                    ProductId = product.Id,
                    TagId = tagId,
                    CreatedAt = DateTime.UtcNow
                }).ToList();

                _context.ProductTags.AddRange(productTags);
                await _context.SaveChangesAsync();
            }

            _logger.LogInformation("Product created successfully: {ProductId}", product.Id);

            // Return the created product
            return await GetProductByIdAsync(product.Id) ?? throw new InvalidOperationException("Failed to retrieve created product");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating product: {ProductName}", createDto.Name);
            throw;
        }
    }

    public async Task<ProductResponseDto?> UpdateProductAsync(int id, UpdateProductDto updateDto)
    {
        try
        {
            _logger.LogInformation("Updating product: {ProductId}", id);

            var product = await _context.Products
                .Include(p => p.ProductTags)
                .FirstOrDefaultAsync(p => p.Id == id && p.IsActive);

            if (product == null)
            {
                _logger.LogWarning("Product not found for update: {ProductId}", id);
                return null;
            }

            // Update fields if provided
            if (!string.IsNullOrWhiteSpace(updateDto.Name))
                product.Name = updateDto.Name;

            if (updateDto.Description != null)
                product.Description = updateDto.Description;

            if (updateDto.Price.HasValue)
                product.Price = updateDto.Price.Value;

            if (updateDto.Stock.HasValue)
                product.Stock = updateDto.Stock.Value;

            if (updateDto.CategoryId.HasValue)
            {
                var categoryExists = await _context.Categories.AnyAsync(c => c.Id == updateDto.CategoryId.Value && c.IsActive);
                if (!categoryExists)
                {
                    throw new ArgumentException($"Category with ID {updateDto.CategoryId.Value} does not exist or is not active");
                }
                product.CategoryId = updateDto.CategoryId.Value;
            }

            if (!string.IsNullOrWhiteSpace(updateDto.SKU))
            {
                var skuExists = await _context.Products.AnyAsync(p => p.SKU == updateDto.SKU && p.Id != id);
                if (skuExists)
                {
                    throw new ArgumentException($"Product with SKU '{updateDto.SKU}' already exists");
                }
                product.SKU = updateDto.SKU;
            }

            if (updateDto.Weight.HasValue)
                product.Weight = updateDto.Weight.Value;

            if (updateDto.ImageUrl != null)
                product.ImageUrl = updateDto.ImageUrl;

            if (updateDto.IsActive.HasValue)
                product.IsActive = updateDto.IsActive.Value;

            product.UpdatedAt = DateTime.UtcNow;

            // Update tags if provided
            if (updateDto.TagIds != null)
            {
                // Validate tags exist
                if (updateDto.TagIds.Any())
                {
                    var existingTagIds = await _context.Tags.Where(t => updateDto.TagIds.Contains(t.Id)).Select(t => t.Id).ToListAsync();
                    var invalidTagIds = updateDto.TagIds.Except(existingTagIds).ToList();
                    if (invalidTagIds.Any())
                    {
                        throw new ArgumentException($"Invalid tag IDs: {string.Join(", ", invalidTagIds)}");
                    }
                }

                // Remove existing tags
                _context.ProductTags.RemoveRange(product.ProductTags);

                // Add new tags
                if (updateDto.TagIds.Any())
                {
                    var newProductTags = updateDto.TagIds.Select(tagId => new ProductTag
                    {
                        ProductId = product.Id,
                        TagId = tagId,
                        CreatedAt = DateTime.UtcNow
                    }).ToList();

                    _context.ProductTags.AddRange(newProductTags);
                }
            }

            await _context.SaveChangesAsync();

            _logger.LogInformation("Product updated successfully: {ProductId}", id);

            return await GetProductByIdAsync(id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating product: {ProductId}", id);
            throw;
        }
    }

    public async Task<bool> DeleteProductAsync(int id)
    {
        try
        {
            _logger.LogInformation("Deleting product: {ProductId}", id);

            var product = await _context.Products.FirstOrDefaultAsync(p => p.Id == id);
            if (product == null)
            {
                _logger.LogWarning("Product not found for deletion: {ProductId}", id);
                return false;
            }

            // Soft delete by setting IsActive to false
            product.IsActive = false;
            product.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            _logger.LogInformation("Product deleted successfully: {ProductId}", id);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting product: {ProductId}", id);
            throw;
        }
    }

    public async Task<bool> UpdateStockAsync(int productId, int newStock)
    {
        try
        {
            _logger.LogInformation("Updating stock for product {ProductId} to {NewStock}", productId, newStock);

            var product = await _context.Products.FirstOrDefaultAsync(p => p.Id == productId && p.IsActive);
            if (product == null)
            {
                _logger.LogWarning("Product not found for stock update: {ProductId}", productId);
                return false;
            }

            if (newStock < 0)
            {
                throw new ArgumentException("Stock cannot be negative");
            }

            product.Stock = newStock;
            product.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            _logger.LogInformation("Stock updated successfully for product: {ProductId}", productId);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating stock for product: {ProductId}", productId);
            throw;
        }
    }

    public async Task<List<ProductResponseDto>> GetProductsByCategoryAsync(int categoryId)
    {
        try
        {
            _logger.LogInformation("Getting products by category: {CategoryId}", categoryId);

            var products = await _context.Products
                .Include(p => p.Category)
                .Include(p => p.ProductTags)
                .ThenInclude(pt => pt.Tag)
                .Where(p => p.CategoryId == categoryId && p.IsActive)
                .Select(p => new ProductResponseDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Stock = p.Stock,
                    CategoryId = p.CategoryId,
                    CategoryName = p.Category.Name,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt,
                    IsActive = p.IsActive,
                    SKU = p.SKU,
                    Weight = p.Weight,
                    ImageUrl = p.ImageUrl,
                    Tags = p.ProductTags.Select(pt => pt.Tag.Name).ToList()
                })
                .ToListAsync();

            return products;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting products by category: {CategoryId}", categoryId);
            throw;
        }
    }

    public async Task<List<ProductResponseDto>> GetLowStockProductsAsync(int threshold = 10)
    {
        try
        {
            _logger.LogInformation("Getting low stock products with threshold: {Threshold}", threshold);

            var products = await _context.Products
                .Include(p => p.Category)
                .Include(p => p.ProductTags)
                .ThenInclude(pt => pt.Tag)
                .Where(p => p.Stock <= threshold && p.Stock > 0 && p.IsActive)
                .Select(p => new ProductResponseDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Stock = p.Stock,
                    CategoryId = p.CategoryId,
                    CategoryName = p.Category.Name,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt,
                    IsActive = p.IsActive,
                    SKU = p.SKU,
                    Weight = p.Weight,
                    ImageUrl = p.ImageUrl,
                    Tags = p.ProductTags.Select(pt => pt.Tag.Name).ToList()
                })
                .OrderBy(p => p.Stock)
                .ToListAsync();

            return products;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting low stock products");
            throw;
        }
    }

    public async Task<bool> ProductExistsAsync(int id)
    {
        try
        {
            return await _context.Products.AnyAsync(p => p.Id == id && p.IsActive);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking if product exists: {ProductId}", id);
            throw;
        }
    }

    public async Task<bool> IsSkuUniqueAsync(string sku, int? excludeProductId = null)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(sku))
                return true;

            var query = _context.Products.Where(p => p.SKU == sku);
            
            if (excludeProductId.HasValue)
            {
                query = query.Where(p => p.Id != excludeProductId.Value);
            }

            return !await query.AnyAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking SKU uniqueness: {SKU}", sku);
            throw;
        }
    }
}
