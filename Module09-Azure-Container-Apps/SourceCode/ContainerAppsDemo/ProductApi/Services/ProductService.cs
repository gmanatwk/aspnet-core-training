using ProductApi.Models;

namespace ProductApi.Services;

public interface IProductService
{
    Task<IEnumerable<Product>> GetAllProductsAsync();
    Task<Product?> GetProductByIdAsync(int id);
    Task<Product> CreateProductAsync(CreateProductRequest request);
    Task<Product?> UpdateProductAsync(int id, CreateProductRequest request);
    Task<bool> DeleteProductAsync(int id);
}

public class ProductService : IProductService
{
    private static readonly List<Product> _products = new()
    {
        new Product
        {
            Id = 1,
            Name = "Laptop",
            Description = "High-performance laptop for development",
            Price = 1299.99m,
            Category = "Electronics",
            IsActive = true,
            CreatedAt = DateTime.UtcNow.AddDays(-10),
            UpdatedAt = DateTime.UtcNow.AddDays(-2)
        },
        new Product
        {
            Id = 2,
            Name = "Wireless Mouse",
            Description = "Ergonomic wireless mouse",
            Price = 49.99m,
            Category = "Electronics",
            IsActive = true,
            CreatedAt = DateTime.UtcNow.AddDays(-8),
            UpdatedAt = DateTime.UtcNow.AddDays(-1)
        },
        new Product
        {
            Id = 3,
            Name = "Coffee Mug",
            Description = "Insulated coffee mug for developers",
            Price = 19.99m,
            Category = "Office",
            IsActive = true,
            CreatedAt = DateTime.UtcNow.AddDays(-5),
            UpdatedAt = DateTime.UtcNow.AddDays(-1)
        },
        new Product
        {
            Id = 4,
            Name = "Mechanical Keyboard",
            Description = "RGB mechanical keyboard with blue switches",
            Price = 149.99m,
            Category = "Electronics",
            IsActive = true,
            CreatedAt = DateTime.UtcNow.AddDays(-3),
            UpdatedAt = DateTime.UtcNow
        },
        new Product
        {
            Id = 5,
            Name = "Standing Desk",
            Description = "Adjustable height standing desk",
            Price = 399.99m,
            Category = "Furniture",
            IsActive = false,
            CreatedAt = DateTime.UtcNow.AddDays(-15),
            UpdatedAt = DateTime.UtcNow.AddDays(-5)
        }
    };

    private static int _nextId = 6;
    private readonly ILogger<ProductService> _logger;

    public ProductService(ILogger<ProductService> logger)
    {
        _logger = logger;
    }

    public async Task<IEnumerable<Product>> GetAllProductsAsync()
    {
        _logger.LogInformation("Retrieving all products");
        
        // Simulate async database call
        await Task.Delay(Random.Shared.Next(50, 200));
        
        var activeProducts = _products.Where(p => p.IsActive).ToList();
        
        _logger.LogInformation("Retrieved {ProductCount} active products", activeProducts.Count);
        
        return activeProducts;
    }

    public async Task<Product?> GetProductByIdAsync(int id)
    {
        _logger.LogInformation("Retrieving product with ID {ProductId}", id);
        
        // Simulate async database call
        await Task.Delay(Random.Shared.Next(25, 100));
        
        var product = _products.FirstOrDefault(p => p.Id == id && p.IsActive);
        
        if (product == null)
        {
            _logger.LogWarning("Product with ID {ProductId} not found or inactive", id);
        }
        else
        {
            _logger.LogInformation("Found product: {ProductName}", product.Name);
        }
        
        return product;
    }

    public async Task<Product> CreateProductAsync(CreateProductRequest request)
    {
        _logger.LogInformation("Creating product: {ProductName}", request.Name);
        
        // Simulate async database call
        await Task.Delay(Random.Shared.Next(100, 300));
        
        var product = new Product
        {
            Id = _nextId++,
            Name = request.Name,
            Description = request.Description,
            Price = request.Price,
            Category = request.Category,
            IsActive = request.IsActive,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        
        _products.Add(product);
        
        _logger.LogInformation("Created product with ID {ProductId}", product.Id);
        
        return product;
    }

    public async Task<Product?> UpdateProductAsync(int id, CreateProductRequest request)
    {
        _logger.LogInformation("Updating product with ID {ProductId}", id);
        
        // Simulate async database call
        await Task.Delay(Random.Shared.Next(75, 200));
        
        var product = _products.FirstOrDefault(p => p.Id == id);
        
        if (product == null)
        {
            _logger.LogWarning("Product with ID {ProductId} not found for update", id);
            return null;
        }
        
        product.Name = request.Name;
        product.Description = request.Description;
        product.Price = request.Price;
        product.Category = request.Category;
        product.IsActive = request.IsActive;
        product.UpdatedAt = DateTime.UtcNow;
        
        _logger.LogInformation("Updated product with ID {ProductId}", id);
        
        return product;
    }

    public async Task<bool> DeleteProductAsync(int id)
    {
        _logger.LogInformation("Deleting product with ID {ProductId}", id);
        
        // Simulate async database call
        await Task.Delay(Random.Shared.Next(50, 150));
        
        var product = _products.FirstOrDefault(p => p.Id == id);
        
        if (product == null)
        {
            _logger.LogWarning("Product with ID {ProductId} not found for deletion", id);
            return false;
        }
        
        // Soft delete by marking as inactive
        product.IsActive = false;
        product.UpdatedAt = DateTime.UtcNow;
        
        _logger.LogInformation("Soft deleted product with ID {ProductId}", id);
        
        return true;
    }
}
