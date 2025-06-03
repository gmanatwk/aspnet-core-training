using System.ComponentModel.DataAnnotations;

namespace InputValidation.Models
{
    public class ProductModel
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Product name is required")]
        [StringLength(100, MinimumLength = 3, ErrorMessage = "Product name must be between 3 and 100 characters")]
        [RegularExpression(@"^[a-zA-Z0-9\s\-\.]+$", ErrorMessage = "Product name contains invalid characters")]
        public string Name { get; set; }

        [StringLength(500, ErrorMessage = "Description cannot exceed 500 characters")]
        public string Description { get; set; }

        [Required(ErrorMessage = "Price is required")]
        [Range(0.01, 999999.99, ErrorMessage = "Price must be between 0.01 and 999,999.99")]
        [RegularExpression(@"^\d+(\.\d{1,2})?$", ErrorMessage = "Price must be a valid decimal with up to 2 decimal places")]
        public decimal Price { get; set; }

        [Required(ErrorMessage = "Stock quantity is required")]
        [Range(0, int.MaxValue, ErrorMessage = "Stock quantity must be non-negative")]
        public int StockQuantity { get; set; }

        [Required(ErrorMessage = "Category is required")]
        [StringLength(50, ErrorMessage = "Category cannot exceed 50 characters")]
        public string Category { get; set; }

        [Url(ErrorMessage = "Invalid URL format")]
        [StringLength(200, ErrorMessage = "Image URL cannot exceed 200 characters")]
        public string ImageUrl { get; set; }

        [RegularExpression(@"^[A-Z0-9\-]+$", ErrorMessage = "SKU must contain only uppercase letters, numbers, and hyphens")]
        [StringLength(20, ErrorMessage = "SKU cannot exceed 20 characters")]
        public string Sku { get; set; }

        [Required(ErrorMessage = "Product status is required")]
        [RegularExpression(@"^(Active|Inactive|Discontinued)$", ErrorMessage = "Invalid product status")]
        public string Status { get; set; }

        public DateTime CreatedDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
    }
}