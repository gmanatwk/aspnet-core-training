using PerformanceDemo.Models;

namespace PerformanceDemo.Services;

public interface IProductService
{
    Task<IEnumerable<Product>> GetAllProductsAsync();
    Task<IEnumerable<Product>> GetProductsByCategoryAsync(int categoryId);
    Task<Product?> GetProductByIdAsync(int id);
    Task<IEnumerable<Product>> SearchProductsAsync(string searchTerm);
    Task<IEnumerable<Product>> GetLowStockProductsAsync(int threshold = 10);
    Task<Product> CreateProductAsync(Product product);
    Task<Product?> UpdateProductAsync(int id, Product product);
    Task<bool> DeleteProductAsync(int id);
}

public interface ICategoryService
{
    Task<IEnumerable<Category>> GetAllCategoriesAsync();
    Task<Category?> GetCategoryByIdAsync(int id);
}

public interface IOrderService
{
    Task<IEnumerable<Order>> GetAllOrdersAsync();
    Task<Order?> GetOrderByIdAsync(int id);
    Task<IEnumerable<Order>> GetOrdersByCustomerAsync(string email);
    Task<Order> CreateOrderAsync(Order order, List<OrderItem> items);
    Task<bool> UpdateOrderStatusAsync(int id, OrderStatus status);
}

public interface IMemoryEfficientService
{
    string ProcessLargeString(string input);
    byte[] ProcessLargeByteArray(byte[] input);
    ReadOnlySpan<char> ExtractSubstring(ReadOnlySpan<char> input, int start, int length);
    bool TryParseJson<T>(ReadOnlySpan<char> json, out T? result);
    ValueTask<string> ProcessDataAsync(string data);
}