using EFCoreDemo.Data;
using EFCoreDemo.DTOs;
using EFCoreDemo.Models;
using Microsoft.EntityFrameworkCore;

namespace EFCoreDemo.Repositories;

/// <summary>
/// Product-specific repository interface
/// </summary>
public interface IProductRepository : IRepository<Product>
{
    Task<IEnumerable<Product>> GetProductsWithCategoriesAsync();
    Task<Product?> GetProductWithCategoriesAsync(int id);
    Task<IEnumerable<Product>> GetProductsByCategoryAsync(int categoryId);
    Task<IEnumerable<Product>> SearchProductsAsync(string searchTerm);
    Task<PagedResultDto<Product>> GetProductsPagedAsync(ProductSearchDto searchDto);
    Task<decimal> GetAveragePriceAsync();
    Task<IEnumerable<Product>> GetLowStockProductsAsync(int threshold = 10);
    Task<IEnumerable<Product>> GetProductsByPriceRangeAsync(decimal minPrice, decimal maxPrice);
    Task<bool> UpdateStockAsync(int productId, int newStock);
    Task<bool> SKUExistsAsync(string sku, int? excludeProductId = null);
}

/// <summary>
/// Product repository implementation with advanced queries
/// </summary>
public class ProductRepository : Repository<Product>, IProductRepository
{
    public ProductRepository(ProductCatalogContext context) : base(context)
    {
    }

    public async Task<IEnumerable<Product>> GetProductsWithCategoriesAsync()
    {
        return await _context.Products
            .Include(p => p.ProductCategories)
            .ThenInclude(pc => pc.Category)
            .Where(p => p.IsActive)
            .OrderBy(p => p.Name)
            .ToListAsync();
    }

    public async Task<Product?> GetProductWithCategoriesAsync(int id)
    {
        return await _context.Products
            .Include(p => p.ProductCategories)
            .ThenInclude(pc => pc.Category)
            .FirstOrDefaultAsync(p => p.Id == id);
    }

    public async Task<IEnumerable<Product>> GetProductsByCategoryAsync(int categoryId)
    {
        return await _context.Products
            .Include(p => p.ProductCategories)
            .ThenInclude(pc => pc.Category)
            .Where(p => p.ProductCategories.Any(pc => pc.CategoryId == categoryId) && p.IsActive)
            .OrderBy(p => p.Name)
            .ToListAsync();
    }

    public async Task<IEnumerable<Product>> SearchProductsAsync(string searchTerm)
    {
        var term = searchTerm.ToLower();
        return await _context.Products
            .Include(p => p.ProductCategories)
            .ThenInclude(pc => pc.Category)
            .Where(p => p.IsActive && 
                       (p.Name.ToLower().Contains(term) || 
                        p.Description!.ToLower().Contains(term) ||
                        p.SKU.ToLower().Contains(term)))
            .OrderBy(p => p.Name)
            .ToListAsync();
    }

    public async Task<PagedResultDto<Product>> GetProductsPagedAsync(ProductSearchDto searchDto)
    {
        var query = _context.Products
            .Include(p => p.ProductCategories)
            .ThenInclude(pc => pc.Category)
            .AsQueryable();

        // Apply filters
        if (!string.IsNullOrEmpty(searchDto.SearchTerm))
        {
            var term = searchDto.SearchTerm.ToLower();
            query = query.Where(p => p.Name.ToLower().Contains(term) || 
                                    p.Description!.ToLower().Contains(term) ||
                                    p.SKU.ToLower().Contains(term));
        }

        if (searchDto.CategoryId.HasValue)
        {
            query = query.Where(p => p.ProductCategories.Any(pc => pc.CategoryId == searchDto.CategoryId.Value));
        }

        if (searchDto.MinPrice.HasValue)
        {
            query = query.Where(p => p.Price >= searchDto.MinPrice.Value);
        }

        if (searchDto.MaxPrice.HasValue)
        {
            query = query.Where(p => p.Price <= searchDto.MaxPrice.Value);
        }

        if (searchDto.IsActive.HasValue)
        {
            query = query.Where(p => p.IsActive == searchDto.IsActive.Value);
        }

        // Apply sorting
        query = searchDto.SortBy.ToLower() switch
        {
            "name" => searchDto.SortDirection.ToLower() == "desc" 
                ? query.OrderByDescending(p => p.Name) 
                : query.OrderBy(p => p.Name),
            "price" => searchDto.SortDirection.ToLower() == "desc" 
                ? query.OrderByDescending(p => p.Price) 
                : query.OrderBy(p => p.Price),
            "stock" => searchDto.SortDirection.ToLower() == "desc" 
                ? query.OrderByDescending(p => p.StockQuantity) 
                : query.OrderBy(p => p.StockQuantity),
            "created" => searchDto.SortDirection.ToLower() == "desc" 
                ? query.OrderByDescending(p => p.CreatedAt) 
                : query.OrderBy(p => p.CreatedAt),
            _ => query.OrderBy(p => p.Name)
        };

        var totalCount = await query.CountAsync();

        var products = await query
            .Skip((searchDto.Page - 1) * searchDto.PageSize)
            .Take(searchDto.PageSize)
            .ToListAsync();

        return new PagedResultDto<Product>
        {
            Data = products,
            TotalCount = totalCount,
            Page = searchDto.Page,
            PageSize = searchDto.PageSize
        };
    }

    public async Task<decimal> GetAveragePriceAsync()
    {
        return await _context.Products
            .Where(p => p.IsActive)
            .AverageAsync(p => p.Price);
    }

    public async Task<IEnumerable<Product>> GetLowStockProductsAsync(int threshold = 10)
    {
        return await _context.Products
            .Where(p => p.IsActive && p.StockQuantity <= threshold)
            .OrderBy(p => p.StockQuantity)
            .ToListAsync();
    }

    public async Task<IEnumerable<Product>> GetProductsByPriceRangeAsync(decimal minPrice, decimal maxPrice)
    {
        return await _context.Products
            .Where(p => p.IsActive && p.Price >= minPrice && p.Price <= maxPrice)
            .OrderBy(p => p.Price)
            .ToListAsync();
    }

    public async Task<bool> UpdateStockAsync(int productId, int newStock)
    {
        var product = await _context.Products.FindAsync(productId);
        if (product == null)
            return false;

        product.StockQuantity = newStock;
        product.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> SKUExistsAsync(string sku, int? excludeProductId = null)
    {
        var query = _context.Products.Where(p => p.SKU == sku);
        
        if (excludeProductId.HasValue)
        {
            query = query.Where(p => p.Id != excludeProductId.Value);
        }

        return await query.AnyAsync();
    }

    public override async Task<Product?> GetByIdAsync(int id)
    {
        return await _context.Products
            .Include(p => p.ProductCategories)
            .ThenInclude(pc => pc.Category)
            .FirstOrDefaultAsync(p => p.Id == id);
    }
}
