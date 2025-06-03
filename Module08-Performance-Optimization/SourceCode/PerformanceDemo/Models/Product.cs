namespace PerformanceDemo.Models;

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int Stock { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
    
    public int CategoryId { get; set; }
    public Category? Category { get; set; }
    
    public string SKU { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }
    public decimal Weight { get; set; }
    
    // Navigation properties
    public List<OrderItem> OrderItems { get; set; } = new();
    public List<ProductTag> ProductTags { get; set; } = new();
}

public class Category
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation property
    public List<Product> Products { get; set; } = new();
}

public class Tag
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    
    // Navigation property
    public List<ProductTag> ProductTags { get; set; } = new();
}

public class ProductTag
{
    public int ProductId { get; set; }
    public Product? Product { get; set; }
    
    public int TagId { get; set; }
    public Tag? Tag { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}