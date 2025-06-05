using Microsoft.AspNetCore.JsonPatch;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using RestfulAPI.DTOs;

namespace RestfulAPI.Services;

/// <summary>
/// Product service interface defining business operations
/// </summary>
public interface IProductService
{
    Task<PagedResponse<ProductDto>> GetProductsAsync(string? category, decimal? minPrice, 
        decimal? maxPrice, int pageNumber, int pageSize);
    
    Task<ProductDto?> GetProductByIdAsync(int id);
    
    Task<ProductDto> CreateProductAsync(CreateProductDto createProductDto);
    
    Task<ProductDto?> UpdateProductAsync(int id, UpdateProductDto updateProductDto);
    
    Task<ProductDto?> PatchProductAsync(int id, JsonPatchDocument<UpdateProductDto> patchDocument, 
        ModelStateDictionary modelState);
    
    Task<bool> DeleteProductAsync(int id);
    
    Task<IEnumerable<string>> GetCategoriesAsync();
    
    Task<PagedResponse<ProductDto>> SearchProductsAsync(string query, int pageNumber, int pageSize);
    
    Task<bool> ProductExistsAsync(int id);
    
    Task<int> GetProductCountAsync();
}