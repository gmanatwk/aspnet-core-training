using System.Net.Http.Json;
using SharedLibrary.Models;
using SharedLibrary.Utilities;

namespace OrderService.Services;

public class ProductService : IProductService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<ProductService> _logger;

    public ProductService(HttpClient httpClient, ILogger<ProductService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<ProductDto?> GetProductAsync(int productId)
    {
        try
        {
            var response = await _httpClient.GetFromApiAsync<ProductDto>($"api/products/{productId}");
            return response.Success ? response.Data : null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting product {ProductId} from Product Service", productId);
            return null;
        }
    }

    public async Task<bool> CheckStockAsync(int productId, int quantity)
    {
        try
        {
            var product = await GetProductAsync(productId);
            return product != null && product.StockQuantity >= quantity;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking stock for product {ProductId}", productId);
            return false;
        }
    }

    public async Task<bool> UpdateStockAsync(int productId, int quantity)
    {
        try
        {
            var response = await _httpClient.PatchAsJsonAsync($"api/products/{productId}/stock", quantity);
            return response.IsSuccessStatusCode;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating stock for product {ProductId}", productId);
            return false;
        }
    }
}