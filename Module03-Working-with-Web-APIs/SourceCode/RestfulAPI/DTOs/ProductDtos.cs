using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.DTOs;

/// <summary>
/// Product data transfer object
/// </summary>
public record ProductDto
{
    /// <summary>
    /// Unique identifier for the product
    /// </summary>
    /// <example>1</example>
    public int Id { get; init; }

    /// <summary>
    /// Product name
    /// </summary>
    /// <example>Laptop Computer</example>
    public string Name { get; init; } = string.Empty;

    /// <summary>
    /// Product description
    /// </summary>
    /// <example>High-performance laptop with 16GB RAM and 512GB SSD</example>
    public string Description { get; init; } = string.Empty;

    /// <summary>
    /// Product price in USD
    /// </summary>
    /// <example>999.99</example>
    public decimal Price { get; init; }

    /// <summary>
    /// Product category
    /// </summary>
    /// <example>Electronics</example>
    public string Category { get; init; } = string.Empty;

    /// <summary>
    /// Available stock quantity
    /// </summary>
    /// <example>50</example>
    public int StockQuantity { get; init; }

    /// <summary>
    /// Product SKU (Stock Keeping Unit)
    /// </summary>
    /// <example>ELEC-LAP-001</example>
    public string Sku { get; init; } = string.Empty;

    /// <summary>
    /// Indicates if the product is currently active
    /// </summary>
    /// <example>true</example>
    public bool IsActive { get; init; }

    /// <summary>
    /// Indicates if the product is available for sale
    /// </summary>
    /// <example>true</example>
    public bool IsAvailable { get; init; }

    /// <summary>
    /// Product creation timestamp
    /// </summary>
    /// <example>2024-01-15T10:30:00Z</example>
    public DateTime CreatedAt { get; init; }

    /// <summary>
    /// Product last update timestamp
    /// </summary>
    /// <example>2024-01-20T15:45:00Z</example>
    public DateTime? UpdatedAt { get; init; }
}

/// <summary>
/// DTO for creating a new product
/// </summary>
public record CreateProductDto
{
    /// <summary>
    /// Product name
    /// </summary>
    /// <example>Wireless Mouse</example>
    [Required(ErrorMessage = "Product name is required")]
    [StringLength(200, MinimumLength = 1, ErrorMessage = "Product name must be between 1 and 200 characters")]
    public string Name { get; init; } = string.Empty;

    /// <summary>
    /// Product description
    /// </summary>
    /// <example>Ergonomic wireless mouse with precision tracking</example>
    [StringLength(2000, ErrorMessage = "Description cannot exceed 2000 characters")]
    public string Description { get; init; } = string.Empty;

    /// <summary>
    /// Product price in USD
    /// </summary>
    /// <example>29.99</example>
    [Required(ErrorMessage = "Price is required")]
    [Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than 0")]
    public decimal Price { get; init; }

    /// <summary>
    /// Product category
    /// </summary>
    /// <example>Accessories</example>
    [Required(ErrorMessage = "Category is required")]
    [StringLength(100, MinimumLength = 1, ErrorMessage = "Category must be between 1 and 100 characters")]
    public string Category { get; init; } = string.Empty;

    /// <summary>
    /// Initial stock quantity
    /// </summary>
    /// <example>100</example>
    [Range(0, int.MaxValue, ErrorMessage = "Stock quantity cannot be negative")]
    public int StockQuantity { get; init; }

    /// <summary>
    /// Product SKU (Stock Keeping Unit)
    /// </summary>
    /// <example>ACC-MOU-002</example>
    [Required(ErrorMessage = "SKU is required")]
    [StringLength(50, MinimumLength = 1, ErrorMessage = "SKU must be between 1 and 50 characters")]
    [RegularExpression(@"^[A-Z0-9\-]+$", ErrorMessage = "SKU must contain only uppercase letters, numbers, and hyphens")]
    public string Sku { get; init; } = string.Empty;

    /// <summary>
    /// Indicates if the product is active
    /// </summary>
    /// <example>true</example>
    public bool? IsActive { get; init; }
}

/// <summary>
/// DTO for updating an existing product
/// </summary>
public record UpdateProductDto
{
    /// <summary>
    /// Product name
    /// </summary>
    [Required(ErrorMessage = "Product name is required")]
    [StringLength(200, MinimumLength = 1, ErrorMessage = "Product name must be between 1 and 200 characters")]
    public string Name { get; init; } = string.Empty;

    /// <summary>
    /// Product description
    /// </summary>
    [StringLength(2000, ErrorMessage = "Description cannot exceed 2000 characters")]
    public string Description { get; init; } = string.Empty;

    /// <summary>
    /// Product price in USD
    /// </summary>
    [Required(ErrorMessage = "Price is required")]
    [Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than 0")]
    public decimal Price { get; init; }

    /// <summary>
    /// Product category
    /// </summary>
    [Required(ErrorMessage = "Category is required")]
    [StringLength(100, MinimumLength = 1, ErrorMessage = "Category must be between 1 and 100 characters")]
    public string Category { get; init; } = string.Empty;

    /// <summary>
    /// Available stock quantity
    /// </summary>
    [Range(0, int.MaxValue, ErrorMessage = "Stock quantity cannot be negative")]
    public int StockQuantity { get; init; }

    /// <summary>
    /// Product SKU (Stock Keeping Unit)
    /// </summary>
    [StringLength(50, MinimumLength = 1, ErrorMessage = "SKU must be between 1 and 50 characters")]
    [RegularExpression(@"^[A-Z0-9\-]+$", ErrorMessage = "SKU must contain only uppercase letters, numbers, and hyphens")]
    public string? Sku { get; init; }

    /// <summary>
    /// Indicates if the product is currently active
    /// </summary>
    public bool? IsActive { get; init; }

    /// <summary>
    /// Indicates if the product is available for sale
    /// </summary>
    public bool? IsAvailable { get; init; }
}

/// <summary>
/// Paginated response wrapper
/// </summary>
/// <typeparam name="T">Type of items in the response</typeparam>
public class PagedResponse<T>
{
    public PagedResponse()
    {
        Data = new List<T>();
    }

    public PagedResponse(IEnumerable<T> data, int pageNumber, int pageSize, int totalRecords)
    {
        Data = data;
        PageNumber = pageNumber;
        PageSize = pageSize;
        TotalRecords = totalRecords;
        TotalPages = (int)Math.Ceiling(totalRecords / (double)pageSize);
    }

    /// <summary>
    /// Collection of items for the current page
    /// </summary>
    public IEnumerable<T> Data { get; set; } = new List<T>();

    /// <summary>
    /// Current page number
    /// </summary>
    /// <example>1</example>
    public int PageNumber { get; set; }

    /// <summary>
    /// Number of items per page
    /// </summary>
    /// <example>10</example>
    public int PageSize { get; set; }

    /// <summary>
    /// Total number of pages
    /// </summary>
    /// <example>5</example>
    public int TotalPages { get; set; }

    /// <summary>
    /// Total number of records
    /// </summary>
    /// <example>50</example>
    public int TotalRecords { get; set; }

    /// <summary>
    /// Indicates if there is a next page
    /// </summary>
    /// <example>true</example>
    public bool HasNextPage => PageNumber < TotalPages;

    /// <summary>
    /// Indicates if there is a previous page
    /// </summary>
    /// <example>false</example>
    public bool HasPreviousPage => PageNumber > 1;

    /// <summary>
    /// URL to the next page (if available)
    /// </summary>
    public string? NextPageUrl { get; set; }

    /// <summary>
    /// URL to the previous page (if available)
    /// </summary>
    public string? PreviousPageUrl { get; set; }
}

/// <summary>
/// Standard API response wrapper
/// </summary>
/// <typeparam name="T">Type of data in the response</typeparam>
public class ApiResponse<T>
{
    /// <summary>
    /// Indicates if the request was successful
    /// </summary>
    public bool Success { get; set; }

    /// <summary>
    /// Response message
    /// </summary>
    public string Message { get; set; } = string.Empty;

    /// <summary>
    /// Response data
    /// </summary>
    public T? Data { get; set; }

    /// <summary>
    /// Collection of errors (if any)
    /// </summary>
    public List<string> Errors { get; set; } = new();

    /// <summary>
    /// Timestamp of the response
    /// </summary>
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// Creates a successful response
    /// </summary>
    public static ApiResponse<T> SuccessResult(T data, string message = "Operation successful")
    {
        return new ApiResponse<T>
        {
            Success = true,
            Message = message,
            Data = data
        };
    }

    /// <summary>
    /// Creates an error response
    /// </summary>
    public static ApiResponse<T> ErrorResult(string message, List<string>? errors = null)
    {
        return new ApiResponse<T>
        {
            Success = false,
            Message = message,
            Errors = errors ?? new List<string>()
        };
    }
}