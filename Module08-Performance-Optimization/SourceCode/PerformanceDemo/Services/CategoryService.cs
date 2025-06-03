using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using PerformanceDemo.Data;
using PerformanceDemo.Models;

namespace PerformanceDemo.Services;

public class CategoryService : ICategoryService
{
    private readonly ApplicationDbContext _context;
    private readonly IMemoryCache _cache;
    private readonly ILogger<CategoryService> _logger;
    private const string CategoriesCacheKeyPrefix = "categories_";

    public CategoryService(
        ApplicationDbContext context,
        IMemoryCache cache,
        ILogger<CategoryService> logger)
    {
        _context = context;
        _cache = cache;
        _logger = logger;
    }

    public async Task<IEnumerable<Category>> GetAllCategoriesAsync()
    {
        var cacheKey = $"{CategoriesCacheKeyPrefix}all";
        
        if (_cache.TryGetValue<List<Category>>(cacheKey, out var cachedCategories))
        {
            _logger.LogInformation("Returning cached categories");
            return cachedCategories!;
        }

        var categories = await _context.Categories
            .Include(c => c.Products)
            .ToListAsync();

        _cache.Set(cacheKey, categories, TimeSpan.FromMinutes(30));
        
        return categories;
    }

    public async Task<Category?> GetCategoryByIdAsync(int id)
    {
        var cacheKey = $"{CategoriesCacheKeyPrefix}{id}";
        
        if (_cache.TryGetValue<Category>(cacheKey, out var cachedCategory))
        {
            return cachedCategory;
        }

        var category = await _context.Categories
            .Include(c => c.Products)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (category != null)
        {
            _cache.Set(cacheKey, category, TimeSpan.FromMinutes(30));
        }

        return category;
    }

}