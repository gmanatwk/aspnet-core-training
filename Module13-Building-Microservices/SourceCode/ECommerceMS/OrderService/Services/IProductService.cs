using SharedLibrary.Models;

namespace OrderService.Services;

public interface IProductService
{
    Task<ProductDto?> GetProductAsync(int productId);
    Task<bool> CheckStockAsync(int productId, int quantity);
    Task<bool> UpdateStockAsync(int productId, int quantity);
}