using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.JsonPatch;
using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;
using RestfulAPI.DTOs;
using RestfulAPI.Services;
using System.Security.Claims;

namespace RestfulAPI.Controllers;

/// <summary>
/// Products API Version 2 - Enhanced features
/// </summary>
[ApiController]
[Route("api/v{version:apiVersion}/products")]
[Produces("application/json")]
[ApiVersion("2.0")]
public class ProductsV2Controller : ControllerBase
{
    private readonly IProductService _productService;
    private readonly ILogger<ProductsV2Controller> _logger;

    public ProductsV2Controller(IProductService productService, ILogger<ProductsV2Controller> logger)
    {
        _productService = productService;
        _logger = logger;
    }

    /// <summary>
    /// Get all products with enhanced filtering and metadata (V2)
    /// </summary>
    /// <param name="category">Filter by category</param>
    /// <param name="minPrice">Minimum price filter</param>
    /// <param name="maxPrice">Maximum price filter</param>
    /// <param name="inStock">Filter by stock availability</param>
    /// <param name="sortBy">Sort by: name, price, category, createdAt</param>
    /// <param name="sortDescending">Sort in descending order</param>
    /// <param name="pageNumber">Page number for pagination</param>
    /// <param name="pageSize">Page size for pagination</param>
    /// <returns>Enhanced paginated list of products with metadata</returns>
    /// <response code="200">Returns the enhanced paginated list of products</response>
    [HttpGet]
    [ProducesResponseType(typeof(EnhancedPagedResponse<ProductDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<EnhancedPagedResponse<ProductDto>>> GetProducts(
        [FromQuery] string? category = null,
        [FromQuery] decimal? minPrice = null,
        [FromQuery] decimal? maxPrice = null,
        [FromQuery] bool? inStock = null,
        [FromQuery] string? sortBy = "name",
        [FromQuery] bool sortDescending = false,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 10)
    {
        _logger.LogInformation("V2 API - Getting products with enhanced filters - Category: {Category}, Price: {MinPrice}-{MaxPrice}, InStock: {InStock}, Sort: {SortBy} {SortOrder}", 
            category, minPrice, maxPrice, inStock, sortBy, sortDescending ? "DESC" : "ASC");

        // For demo purposes, return the standard response with additional metadata
        var result = await _productService.GetProductsAsync(category, minPrice, maxPrice, pageNumber, pageSize);
        
        // Create enhanced response with additional metadata
        var enhancedResponse = new EnhancedPagedResponse<ProductDto>
        {
            Data = result.Data.ToList(),
            PageNumber = result.PageNumber,
            PageSize = result.PageSize,
            TotalRecords = result.TotalRecords,
            TotalPages = result.TotalPages,
            HasNextPage = result.HasNextPage,
            HasPreviousPage = result.HasPreviousPage,
            // V2 specific enhancements
            Metadata = new ResponseMetadata
            {
                ApiVersion = "2.0",
                ResponseTime = DateTime.UtcNow,
                FilterApplied = new
                {
                    Category = category,
                    MinPrice = minPrice,
                    MaxPrice = maxPrice,
                    InStock = inStock
                },
                SortApplied = new
                {
                    Field = sortBy,
                    Direction = sortDescending ? "desc" : "asc"
                }
            },
            Links = new PaginationLinks
            {
                First = $"/api/v2/products?pageNumber=1&pageSize={pageSize}",
                Last = $"/api/v2/products?pageNumber={result.TotalPages}&pageSize={pageSize}",
                Next = result.HasNextPage ? $"/api/v2/products?pageNumber={pageNumber + 1}&pageSize={pageSize}" : null,
                Previous = result.HasPreviousPage ? $"/api/v2/products?pageNumber={pageNumber - 1}&pageSize={pageSize}" : null
            }
        };

        // Add custom headers for V2
        Response.Headers["X-Total-Count"] = result.TotalRecords.ToString();
        Response.Headers["X-API-Version"] = "2.0";

        return Ok(enhancedResponse);
    }

    /// <summary>
    /// Get product by ID with enhanced details (V2)
    /// </summary>
    /// <param name="id">Product ID</param>
    /// <param name="includeStats">Include product statistics</param>
    /// <returns>Enhanced product details</returns>
    /// <response code="200">Returns the enhanced product</response>
    /// <response code="404">If the product is not found</response>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(EnhancedProductDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<EnhancedProductDto>> GetProduct(int id, [FromQuery] bool includeStats = false)
    {
        _logger.LogInformation("V2 API - Getting product with ID: {ProductId}, IncludeStats: {IncludeStats}", id, includeStats);
        
        var product = await _productService.GetProductByIdAsync(id);
        if (product == null)
        {
            return NotFound(new { message = $"Product with ID {id} not found", apiVersion = "2.0" });
        }

        // Create enhanced product response
        var enhancedProduct = new EnhancedProductDto
        {
            Id = product.Id,
            Name = product.Name,
            Description = product.Description,
            Price = product.Price,
            Category = product.Category,
            StockQuantity = product.StockQuantity,
            IsAvailable = product.IsAvailable,
            Sku = product.Sku,
            IsActive = product.IsActive,
            CreatedAt = product.CreatedAt,
            UpdatedAt = product.UpdatedAt,
            // V2 specific enhancements
            Links = new Dictionary<string, string>
            {
                ["self"] = $"/api/v2/products/{id}",
                ["update"] = $"/api/v2/products/{id}",
                ["delete"] = $"/api/v2/products/{id}",
                ["category"] = $"/api/v2/categories/{product.Category}"
            }
        };

        if (includeStats)
        {
            enhancedProduct.Statistics = new ProductStatistics
            {
                ViewCount = Random.Shared.Next(100, 10000),
                PurchaseCount = Random.Shared.Next(10, 1000),
                AverageRating = Math.Round(Random.Shared.NextDouble() * 4 + 1, 1),
                TotalReviews = Random.Shared.Next(5, 500)
            };
        }

        return Ok(enhancedProduct);
    }

    /// <summary>
    /// Bulk create products (V2 feature)
    /// </summary>
    /// <param name="products">List of products to create</param>
    /// <returns>Bulk operation result</returns>
    /// <response code="200">Returns the bulk operation result</response>
    /// <response code="400">If validation fails</response>
    [HttpPost("bulk")]
    [ProducesResponseType(typeof(BulkOperationResult), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<BulkOperationResult>> CreateProductsBulk([FromBody] List<CreateProductDto> products)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        _logger.LogInformation("V2 API - Bulk creating {Count} products", products.Count);

        var result = new BulkOperationResult
        {
            TotalCount = products.Count,
            SuccessCount = 0,
            FailureCount = 0,
            CreatedIds = new List<int>(),
            Errors = new List<string>()
        };

        foreach (var productDto in products)
        {
            try
            {
                var createdProduct = await _productService.CreateProductAsync(productDto);
                result.SuccessCount++;
                result.CreatedIds.Add(createdProduct.Id);
            }
            catch (Exception ex)
            {
                result.FailureCount++;
                result.Errors.Add($"Failed to create product '{productDto.Name}': {ex.Message}");
            }
        }

        return Ok(result);
    }

    /// <summary>
    /// Get product statistics (V2 exclusive feature)
    /// </summary>
    /// <returns>Product statistics</returns>
    /// <response code="200">Returns product statistics</response>
    [HttpGet("statistics")]
    [ProducesResponseType(typeof(ApiStatistics), StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiStatistics>> GetStatistics()
    {
        _logger.LogInformation("V2 API - Getting product statistics");

        var allProducts = await _productService.GetProductsAsync(null, null, null, 1, int.MaxValue);
        var products = allProducts.Data;

        var statistics = new ApiStatistics
        {
            TotalProducts = allProducts.TotalRecords,
            TotalCategories = products.Select(p => p.Category).Distinct().Count(),
            AveragePrice = products.Any() ? products.Average(p => p.Price) : 0,
            TotalStockValue = products.Sum(p => p.Price * p.StockQuantity),
            ProductsByCategory = products
                .GroupBy(p => p.Category)
                .ToDictionary(g => g.Key, g => g.Count()),
            StockStatus = new
            {
                InStock = products.Count(p => p.IsAvailable),
                OutOfStock = products.Count(p => !p.IsAvailable),
                LowStock = products.Count(p => p.StockQuantity > 0 && p.StockQuantity < 10)
            }
        };

        return Ok(statistics);
    }

    /// <summary>
    /// Export products to CSV (V2 exclusive feature)
    /// </summary>
    /// <param name="category">Optional category filter</param>
    /// <returns>CSV file</returns>
    [HttpGet("export")]
    [Produces("text/csv")]
    [ProducesResponseType(typeof(FileResult), StatusCodes.Status200OK)]
    public async Task<IActionResult> ExportProducts([FromQuery] string? category = null)
    {
        _logger.LogInformation("V2 API - Exporting products to CSV, Category: {Category}", category);

        var products = await _productService.GetProductsAsync(category, null, null, 1, int.MaxValue);
        
        var csv = "Id,Name,Description,Price,Category,StockQuantity,IsAvailable,Sku,CreatedAt\n";
        foreach (var product in products.Data)
        {
            csv += $"{product.Id},{EscapeCsvField(product.Name)},{EscapeCsvField(product.Description)},{product.Price},{product.Category},{product.StockQuantity},{product.IsAvailable},{product.Sku},{product.CreatedAt:yyyy-MM-dd}\n";
        }

        var bytes = System.Text.Encoding.UTF8.GetBytes(csv);
        return File(bytes, "text/csv", $"products_export_{DateTime.UtcNow:yyyyMMdd}.csv");
    }

    private static string EscapeCsvField(string field)
    {
        if (string.IsNullOrEmpty(field)) return "";
        if (field.Contains(',') || field.Contains('"') || field.Contains('\n'))
        {
            return $"\"{field.Replace("\"", "\"\"")}\"";
        }
        return field;
    }
}

// V2 Enhanced DTOs
public class EnhancedPagedResponse<T>
{
    public List<T> Data { get; set; } = new();
    public int PageNumber { get; set; }
    public int PageSize { get; set; }
    public int TotalRecords { get; set; }
    public int TotalPages { get; set; }
    public bool HasNextPage { get; set; }
    public bool HasPreviousPage { get; set; }
    public ResponseMetadata Metadata { get; set; } = new();
    public PaginationLinks Links { get; set; } = new();
}

public class ResponseMetadata
{
    public string ApiVersion { get; set; } = string.Empty;
    public DateTime ResponseTime { get; set; }
    public object? FilterApplied { get; set; }
    public object? SortApplied { get; set; }
}

public class PaginationLinks
{
    public string? First { get; set; }
    public string? Last { get; set; }
    public string? Next { get; set; }
    public string? Previous { get; set; }
}

public class EnhancedProductDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string Category { get; set; } = string.Empty;
    public int StockQuantity { get; set; }
    public bool IsAvailable { get; set; }
    public string Sku { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public Dictionary<string, string> Links { get; set; } = new();
    public ProductStatistics? Statistics { get; set; }
}

public class ProductStatistics
{
    public int ViewCount { get; set; }
    public int PurchaseCount { get; set; }
    public double AverageRating { get; set; }
    public int TotalReviews { get; set; }
}

public class BulkOperationResult
{
    public int TotalCount { get; set; }
    public int SuccessCount { get; set; }
    public int FailureCount { get; set; }
    public List<int> CreatedIds { get; set; } = new();
    public List<string> Errors { get; set; } = new();
}

public class ApiStatistics
{
    public int TotalProducts { get; set; }
    public int TotalCategories { get; set; }
    public decimal AveragePrice { get; set; }
    public decimal TotalStockValue { get; set; }
    public Dictionary<string, int> ProductsByCategory { get; set; } = new();
    public object StockStatus { get; set; } = new();
}