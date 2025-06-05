using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.DTOs
{
    /// <summary>
    /// Product data transfer object
    /// </summary>
    public record ProductDto
    {
        /// <summary>
        /// Unique identifier for the product
        /// </summary>
        public int Id { get; init; }

        /// <summary>
        /// Product name
        /// </summary>
        public string Name { get; init; } = string.Empty;

        /// <summary>
        /// Product description
        /// </summary>
        public string Description { get; init; } = string.Empty;

        /// <summary>
        /// Product price in USD
        /// </summary>
        public decimal Price { get; init; }

        /// <summary>
        /// Product category
        /// </summary>
        public string Category { get; init; } = string.Empty;

        /// <summary>
        /// Available stock quantity
        /// </summary>
        public int StockQuantity { get; init; }

        /// <summary>
        /// Product SKU (Stock Keeping Unit)
        /// </summary>
        public string Sku { get; init; } = string.Empty;

        /// <summary>
        /// Indicates if the product is currently active
        /// </summary>
        public bool IsActive { get; init; }

        /// <summary>
        /// Indicates if the product is available for sale
        /// </summary>
        public bool IsAvailable { get; init; }

        /// <summary>
        /// Product creation timestamp
        /// </summary>
        public DateTime CreatedAt { get; init; }

        /// <summary>
        /// Product last update timestamp
        /// </summary>
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
        /// Initial stock quantity
        /// </summary>
        [Range(0, int.MaxValue, ErrorMessage = "Stock quantity cannot be negative")]
        public int StockQuantity { get; init; }

        /// <summary>
        /// Product SKU (Stock Keeping Unit)
        /// </summary>
        [Required(ErrorMessage = "SKU is required")]
        [StringLength(50, MinimumLength = 1, ErrorMessage = "SKU must be between 1 and 50 characters")]
        [RegularExpression(@"^[A-Z0-9\-]+$", ErrorMessage = "SKU must contain only uppercase letters, numbers, and hyphens")]
        public string Sku { get; init; } = string.Empty;

        /// <summary>
        /// Indicates if the product is active
        /// </summary>
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

     public record ProductDtoV2 : ProductDto 
     {
        /// <summary>
        /// Unique identifier for the product
        /// </summary>
        public int Id { get; init; }

        /// <summary>
        /// Product name
        /// </summary>
        public string Name { get; init; } = string.Empty;

        /// <summary>
        /// Product description
        /// </summary>
        public string Description { get; init; } = string.Empty;

        /// <summary>
        /// Product price in USD
        /// </summary>
        public decimal Price { get; init; }

        /// <summary>
        /// Product category
        /// </summary>
        public string Category { get; init; } = string.Empty;

        /// <summary>
        /// Available stock quantity
        /// </summary>
        public int StockQuantity { get; init; }

        /// <summary>
        /// Product SKU (Stock Keeping Unit)
        /// </summary>
        public string Sku { get; init; } = string.Empty;

        /// <summary>
        /// Indicates if the product is currently active
        /// </summary>
        public bool IsActive { get; init; }

        /// <summary>
        /// Indicates if the product is available for sale
        /// </summary>
        public bool IsAvailable { get; init; }

        /// <summary>
        /// Product creation timestamp
        /// </summary>
        public DateTime CreatedAt { get; init; }

        /// <summary>
        /// Product last update timestamp
        /// </summary>
        public DateTime? UpdatedAt { get; init; }
     }
}