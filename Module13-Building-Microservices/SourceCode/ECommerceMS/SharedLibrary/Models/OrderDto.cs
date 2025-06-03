using System.ComponentModel.DataAnnotations;

namespace SharedLibrary.Models;

public class OrderDto
{
    public int Id { get; set; }
    
    public int CustomerId { get; set; }
    
    public string OrderNumber { get; set; } = string.Empty;
    
    public DateTime OrderDate { get; set; }
    
    public OrderStatus Status { get; set; }
    
    public decimal TotalAmount { get; set; }
    
    public List<OrderItemDto> Items { get; set; } = new();
    
    public string? ShippingAddress { get; set; }
    
    public DateTime CreatedAt { get; set; }
    
    public DateTime? UpdatedAt { get; set; }
}

public class OrderItemDto
{
    public int Id { get; set; }
    
    public int ProductId { get; set; }
    
    public string ProductName { get; set; } = string.Empty;
    
    public int Quantity { get; set; }
    
    public decimal UnitPrice { get; set; }
    
    public decimal TotalPrice { get; set; }
}

public class CreateOrderDto
{
    [Required]
    public int CustomerId { get; set; }
    
    [Required]
    public List<CreateOrderItemDto> Items { get; set; } = new();
    
    public string? ShippingAddress { get; set; }
}

public class CreateOrderItemDto
{
    [Required]
    public int ProductId { get; set; }
    
    [Required]
    [Range(1, int.MaxValue)]
    public int Quantity { get; set; }
}

public class UpdateOrderStatusDto
{
    [Required]
    public OrderStatus Status { get; set; }
}

public enum OrderStatus
{
    Pending,
    Processing,
    Shipped,
    Delivered,
    Cancelled
}