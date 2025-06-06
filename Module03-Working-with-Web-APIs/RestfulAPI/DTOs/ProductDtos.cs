using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.DTOs
{
    /// <summary>
    /// Product data transfer object
    /// </summary>
    public record ProductDto
    {
        public int Id { get; init; }
        public string Name { get; init; } = string.Empty;
        public string Description { get; init; } = string.Empty;
        public decimal Price { get; init; }
        public string Category { get; init; } = string.Empty;
        public int StockQuantity { get; init; }
        public string Sku { get; init; } = string.Empty;
        public bool IsActive { get; init; }
        public bool IsAvailable { get; init; }
        public DateTime CreatedAt { get; init; }
        public DateTime? UpdatedAt { get; init; }
    }

    /// <summary>
    /// DTO for creating a new product
    /// </summary>
    public record CreateProductDto
    {
        [Required(ErrorMessage = "Product name is required")]
        [StringLength(200, MinimumLength = 1)]
        public string Name { get; init; } = string.Empty;

        [StringLength(2000)]
        public string Description { get; init; } = string.Empty;

        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than 0")]
        public decimal Price { get; init; }

        [Required]
        [StringLength(100, MinimumLength = 1)]
        public string Category { get; init; } = string.Empty;

        [Range(0, int.MaxValue)]
        public int StockQuantity { get; init; }

        [Required]
        [StringLength(50, MinimumLength = 1)]
        public string Sku { get; init; } = string.Empty;

        public bool? IsActive { get; init; }
    }

    /// <summary>
    /// DTO for updating an existing product
    /// </summary>
    public record UpdateProductDto
    {
        [Required]
        [StringLength(200, MinimumLength = 1)]
        public string Name { get; init; } = string.Empty;

        [StringLength(2000)]
        public string Description { get; init; } = string.Empty;

        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal Price { get; init; }

        [Required]
        [StringLength(100, MinimumLength = 1)]
        public string Category { get; init; } = string.Empty;

        [Range(0, int.MaxValue)]
        public int StockQuantity { get; init; }

        [Required]
        [StringLength(50, MinimumLength = 1)]
        public string Sku { get; init; } = string.Empty;

        public bool? IsActive { get; init; }
        public bool? IsAvailable { get; init; }
    }
}
