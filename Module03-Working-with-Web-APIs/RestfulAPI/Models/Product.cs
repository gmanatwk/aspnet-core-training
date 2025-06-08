using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.Models
{
    /// <summary>
    /// Product entity model
    /// </summary>
    public class Product
    {
        /// <summary>
        /// Unique identifier
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Product name
        /// </summary>
        [Required]
        [StringLength(200)]
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// Product description
        /// </summary>
        [StringLength(2000)]
        public string Description { get; set; } = string.Empty;

        /// <summary>
        /// Product price
        /// </summary>
        [Range(0.01, double.MaxValue)]
        public decimal Price { get; set; }

        /// <summary>
        /// Product category
        /// </summary>
        [Required]
        [StringLength(100)]
        public string Category { get; set; } = string.Empty;

        /// <summary>
        /// Stock quantity
        /// </summary>
        [Range(0, int.MaxValue)]
        public int StockQuantity { get; set; }

        /// <summary>
        /// Stock keeping unit
        /// </summary>
        [Required]
        [StringLength(50)]
        public string Sku { get; set; } = string.Empty;

        /// <summary>
        /// Indicates if the product is active
        /// </summary>
        public bool IsActive { get; set; } = true;

        /// <summary>
        /// Indicates if the product is available for sale
        /// </summary>
        public bool IsAvailable { get; set; } = true;

        /// <summary>
        /// Creation timestamp
        /// </summary>
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Last update timestamp
        /// </summary>
        public DateTime? UpdatedAt { get; set; }

        /// <summary>
        /// Soft delete flag
        /// </summary>
        public bool IsDeleted { get; set; } = false;
    }
}
