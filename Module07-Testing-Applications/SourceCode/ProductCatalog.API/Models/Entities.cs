using System.ComponentModel.DataAnnotations;

namespace ProductCatalog.API.Models;

/// <summary>
/// Product entity representing a product in the catalog
/// </summary>
public class Product
{
    public int Id { get; set; }
    
    [Required]
    [StringLength(200)]
    public string Name { get; set; } = string.Empty;
    
    [StringLength(1000)]
    public string Description { get; set; } = string.Empty;
    
    [Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than 0")]
    public decimal Price { get; set; }
    
    [Range(0, int.MaxValue, ErrorMessage = "Stock cannot be negative")]
    public int Stock { get; set; }
    
    public int CategoryId { get; set; }
    public virtual Category Category { get; set; } = null!;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
    public bool IsActive { get; set; } = true;
    
    [StringLength(100)]
    public string? SKU { get; set; }
    
    public decimal? Weight { get; set; }
    
    [StringLength(500)]
    public string? ImageUrl { get; set; }
    
    public virtual ICollection<ProductTag> ProductTags { get; set; } = new List<ProductTag>();
}

/// <summary>
/// Category entity for organizing products
/// </summary>
public class Category
{
    public int Id { get; set; }
    
    [Required]
    [StringLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [StringLength(500)]
    public string Description { get; set; } = string.Empty;
    
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public virtual ICollection<Product> Products { get; set; } = new List<Product>();
}

/// <summary>
/// Tag entity for product labeling
/// </summary>
public class Tag
{
    public int Id { get; set; }
    
    [Required]
    [StringLength(50)]
    public string Name { get; set; } = string.Empty;
    
    [StringLength(200)]
    public string Description { get; set; } = string.Empty;
    
    public virtual ICollection<ProductTag> ProductTags { get; set; } = new List<ProductTag>();
}

/// <summary>
/// Many-to-many relationship between Products and Tags
/// </summary>
public class ProductTag
{
    public int ProductId { get; set; }
    public virtual Product Product { get; set; } = null!;
    
    public int TagId { get; set; }
    public virtual Tag Tag { get; set; } = null!;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

/// <summary>
/// Order entity for testing complex scenarios
/// </summary>
public class Order
{
    public int Id { get; set; }
    
    [Required]
    [StringLength(100)]
    public string CustomerName { get; set; } = string.Empty;
    
    [Required]
    [EmailAddress]
    public string CustomerEmail { get; set; } = string.Empty;
    
    public DateTime OrderDate { get; set; } = DateTime.UtcNow;
    public OrderStatus Status { get; set; } = OrderStatus.Pending;
    public decimal TotalAmount { get; set; }
    
    [StringLength(500)]
    public string? Notes { get; set; }
    
    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}

/// <summary>
/// Order item entity
/// </summary>
public class OrderItem
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public virtual Order Order { get; set; } = null!;
    
    public int ProductId { get; set; }
    public virtual Product Product { get; set; } = null!;
    
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal TotalPrice => Quantity * UnitPrice;
}

/// <summary>
/// Order status enumeration
/// </summary>
public enum OrderStatus
{
    Pending = 0,
    Processing = 1,
    Shipped = 2,
    Delivered = 3,
    Cancelled = 4,
    Refunded = 5
}
