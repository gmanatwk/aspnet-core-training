using Microsoft.EntityFrameworkCore;
using AsyncDatabase.Models;
using System.Linq;

namespace AsyncDatabase.Services
{
    public interface IProductService
    {
        Task<IEnumerable<Product>> GetAllProductsAsync();
        Task<Product?> GetProductByIdAsync(int id);
        Task<IEnumerable<Product>> GetProductsByCategoryAsync(string category);
        Task<Product> CreateProductAsync(Product product);
        Task<Product?> UpdateProductAsync(int id, Product product);
        Task<bool> DeleteProductAsync(int id);
        Task<IEnumerable<Product>> SearchProductsAsync(string searchTerm);
        Task<int> GetProductCountByCategoryAsync(string category);
        Task<decimal> GetAveragePriceByCategoryAsync(string category);
        Task<IEnumerable<Product>> GetExpensiveProductsAsync(decimal minPrice);
        Task BulkUpdatePricesAsync(string category, decimal percentage);
    }

    public class ProductService : IProductService
    {
        private readonly ProductContext _context;
        private readonly ILogger<ProductService> _logger;

        public ProductService(ProductContext context, ILogger<ProductService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<IEnumerable<Product>> GetAllProductsAsync()
        {
            _logger.LogInformation("Fetching all products");
            
            return await _context.Products
                .Where(p => p.IsActive)
                .OrderBy(p => p.Name)
                .ToListAsync();
        }

        public async Task<Product?> GetProductByIdAsync(int id)
        {
            _logger.LogInformation("Fetching product with ID: {ProductId}", id);
            
            return await _context.Products
                .FirstOrDefaultAsync(p => p.Id == id && p.IsActive);
        }

        public async Task<IEnumerable<Product>> GetProductsByCategoryAsync(string category)
        {
            _logger.LogInformation("Fetching products in category: {Category}", category);
            
            return await _context.Products
                .Where(p => p.Category.ToLower() == category.ToLower() && p.IsActive)
                .OrderBy(p => p.Price)
                .ToListAsync();
        }

        public async Task<Product> CreateProductAsync(Product product)
        {
            _logger.LogInformation("Creating new product: {ProductName}", product.Name);
            
            product.CreatedAt = DateTime.UtcNow;
            product.UpdatedAt = DateTime.UtcNow;
            
            _context.Products.Add(product);
            await _context.SaveChangesAsync();
            
            return product;
        }

        public async Task<Product?> UpdateProductAsync(int id, Product product)
        {
            _logger.LogInformation("Updating product with ID: {ProductId}", id);
            
            var existingProduct = await _context.Products.FindAsync(id);
            if (existingProduct == null || !existingProduct.IsActive)
            {
                return null;
            }

            existingProduct.Name = product.Name;
            existingProduct.Description = product.Description;
            existingProduct.Price = product.Price;
            existingProduct.Category = product.Category;
            existingProduct.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return existingProduct;
        }

        public async Task<bool> DeleteProductAsync(int id)
        {
            _logger.LogInformation("Deleting product with ID: {ProductId}", id);
            
            var product = await _context.Products.FindAsync(id);
            if (product == null || !product.IsActive)
            {
                return false;
            }

            // Soft delete
            product.IsActive = false;
            product.UpdatedAt = DateTime.UtcNow;
            
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<IEnumerable<Product>> SearchProductsAsync(string searchTerm)
        {
            _logger.LogInformation("Searching products with term: {SearchTerm}", searchTerm);
            
            return await _context.Products
                .Where(p => p.IsActive && 
                           (p.Name.Contains(searchTerm) || 
                            p.Description.Contains(searchTerm)))
                .OrderBy(p => p.Name)
                .ToListAsync();
        }

        public async Task<int> GetProductCountByCategoryAsync(string category)
        {
            _logger.LogInformation("Counting products in category: {Category}", category);
            
            return await _context.Products
                .CountAsync(p => p.Category.ToLower() == category.ToLower() && p.IsActive);
        }

        public async Task<decimal> GetAveragePriceByCategoryAsync(string category)
        {
            _logger.LogInformation("Calculating average price for category: {Category}", category);
            
            return await _context.Products
                .Where(p => p.Category.ToLower() == category.ToLower() && p.IsActive)
                .AverageAsync(p => p.Price);
        }

        public async Task<IEnumerable<Product>> GetExpensiveProductsAsync(decimal minPrice)
        {
            _logger.LogInformation("Fetching products with minimum price: {MinPrice}", minPrice);
            
            return await _context.Products
                .Where(p => p.Price >= minPrice && p.IsActive)
                .OrderByDescending(p => p.Price)
                .ToListAsync();
        }

        public async Task BulkUpdatePricesAsync(string category, decimal percentage)
        {
            _logger.LogInformation("Bulk updating prices for category {Category} by {Percentage}%", category, percentage);
            
            var products = await _context.Products
                .Where(p => p.Category.ToLower() == category.ToLower() && p.IsActive)
                .ToListAsync();

            foreach (var product in products)
            {
                product.Price = product.Price * (1 + percentage / 100);
                product.UpdatedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();
            
            _logger.LogInformation("Updated {Count} products", products.Count);
        }
    }
}