using EFCoreDemo.Data;
using EFCoreDemo.Models;
using Microsoft.EntityFrameworkCore;

namespace EFCoreDemo.Repositories;

/// <summary>
/// Category-specific repository interface
/// </summary>
public interface ICategoryRepository : IRepository<Category>
{
    Task<IEnumerable<Category>> GetCategoriesWithProductCountAsync();
    Task<Category?> GetCategoryWithProductsAsync(int id);
    Task<IEnumerable<Category>> GetActiveCategoriesAsync();
    Task<bool> SlugExistsAsync(string slug, int? excludeCategoryId = null);
    Task<int> GetProductCountByCategoryAsync(int categoryId);
}

/// <summary>
/// Category repository implementation
/// </summary>
public class CategoryRepository : Repository<Category>, ICategoryRepository
{
    public CategoryRepository(ProductCatalogContext context) : base(context)
    {
    }

    public async Task<IEnumerable<Category>> GetCategoriesWithProductCountAsync()
    {
        return await _context.Categories
            .Include(c => c.ProductCategories)
            .Where(c => c.IsActive)
            .OrderBy(c => c.Name)
            .ToListAsync();
    }

    public async Task<Category?> GetCategoryWithProductsAsync(int id)
    {
        return await _context.Categories
            .Include(c => c.ProductCategories)
            .ThenInclude(pc => pc.Product)
            .FirstOrDefaultAsync(c => c.Id == id);
    }

    public async Task<IEnumerable<Category>> GetActiveCategoriesAsync()
    {
        return await _context.Categories
            .Where(c => c.IsActive)
            .OrderBy(c => c.Name)
            .ToListAsync();
    }

    public async Task<bool> SlugExistsAsync(string slug, int? excludeCategoryId = null)
    {
        var query = _context.Categories.Where(c => c.Slug == slug);
        
        if (excludeCategoryId.HasValue)
        {
            query = query.Where(c => c.Id != excludeCategoryId.Value);
        }

        return await query.AnyAsync();
    }

    public async Task<int> GetProductCountByCategoryAsync(int categoryId)
    {
        return await _context.ProductCategories
            .Where(pc => pc.CategoryId == categoryId)
            .CountAsync();
    }

    public override async Task<Category?> GetByIdAsync(int id)
    {
        return await _context.Categories
            .Include(c => c.ProductCategories)
            .FirstOrDefaultAsync(c => c.Id == id);
    }
}
