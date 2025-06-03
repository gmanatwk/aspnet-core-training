using Microsoft.EntityFrameworkCore;
using ProductCatalog.API.Data;
using ProductCatalog.API.DTOs;
using ProductCatalog.API.Models;

namespace ProductCatalog.API.Services;

/// <summary>
/// Interface for order service operations
/// </summary>
public interface IOrderService
{
    Task<OrderResponseDto> CreateOrderAsync(CreateOrderDto createDto);
    Task<OrderResponseDto?> GetOrderByIdAsync(int id);
    Task<PagedResponse<OrderResponseDto>> GetOrdersAsync(int pageNumber = 1, int pageSize = 10);
    Task<List<OrderResponseDto>> GetOrdersByCustomerEmailAsync(string customerEmail);
    Task<bool> UpdateOrderStatusAsync(int orderId, OrderStatus newStatus);
    Task<bool> CancelOrderAsync(int orderId);
    Task<decimal> CalculateOrderTotalAsync(List<CreateOrderItemDto> items);
}

/// <summary>
/// Order service implementation
/// </summary>
public class OrderService : IOrderService
{
    private readonly ProductCatalogContext _context;
    private readonly ILogger<OrderService> _logger;
    private readonly IProductService _productService;

    public OrderService(
        ProductCatalogContext context, 
        ILogger<OrderService> logger,
        IProductService productService)
    {
        _context = context;
        _logger = logger;
        _productService = productService;
    }

    public async Task<OrderResponseDto> CreateOrderAsync(CreateOrderDto createDto)
    {
        using var transaction = await _context.Database.BeginTransactionAsync();
        
        try
        {
            _logger.LogInformation("Creating new order for customer: {CustomerEmail}", createDto.CustomerEmail);

            // Validate products exist and have sufficient stock
            var productValidations = new List<(int ProductId, int RequestedQuantity, Product Product)>();
            
            foreach (var item in createDto.Items)
            {
                var product = await _context.Products.FirstOrDefaultAsync(p => p.Id == item.ProductId && p.IsActive);
                if (product == null)
                {
                    throw new ArgumentException($"Product with ID {item.ProductId} does not exist or is not active");
                }

                if (product.Stock < item.Quantity)
                {
                    throw new InvalidOperationException($"Insufficient stock for product '{product.Name}'. Available: {product.Stock}, Requested: {item.Quantity}");
                }

                productValidations.Add((item.ProductId, item.Quantity, product));
            }

            // Calculate total amount
            var totalAmount = productValidations.Sum(pv => pv.Product.Price * pv.RequestedQuantity);

            // Create order
            var order = new Order
            {
                CustomerName = createDto.CustomerName,
                CustomerEmail = createDto.CustomerEmail,
                OrderDate = DateTime.UtcNow,
                Status = OrderStatus.Pending,
                TotalAmount = totalAmount,
                Notes = createDto.Notes
            };

            _context.Orders.Add(order);
            await _context.SaveChangesAsync();

            // Create order items and update stock
            var orderItems = new List<OrderItem>();
            foreach (var validation in productValidations)
            {
                var orderItem = new OrderItem
                {
                    OrderId = order.Id,
                    ProductId = validation.ProductId,
                    Quantity = validation.RequestedQuantity,
                    UnitPrice = validation.Product.Price
                };

                orderItems.Add(orderItem);

                // Update product stock
                validation.Product.Stock -= validation.RequestedQuantity;
                validation.Product.UpdatedAt = DateTime.UtcNow;
            }

            _context.OrderItems.AddRange(orderItems);
            await _context.SaveChangesAsync();

            await transaction.CommitAsync();

            _logger.LogInformation("Order created successfully: {OrderId}", order.Id);

            return await GetOrderByIdAsync(order.Id) ?? 
                throw new InvalidOperationException("Failed to retrieve created order");
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync();
            _logger.LogError(ex, "Error creating order for customer: {CustomerEmail}", createDto.CustomerEmail);
            throw;
        }
    }

    public async Task<OrderResponseDto?> GetOrderByIdAsync(int id)
    {
        try
        {
            _logger.LogInformation("Getting order by ID: {OrderId}", id);

            var order = await _context.Orders
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
                .FirstOrDefaultAsync(o => o.Id == id);

            if (order == null)
            {
                _logger.LogWarning("Order not found: {OrderId}", id);
                return null;
            }

            return new OrderResponseDto
            {
                Id = order.Id,
                CustomerName = order.CustomerName,
                CustomerEmail = order.CustomerEmail,
                OrderDate = order.OrderDate,
                Status = order.Status,
                TotalAmount = order.TotalAmount,
                Notes = order.Notes,
                Items = order.OrderItems.Select(oi => new OrderItemResponseDto
                {
                    Id = oi.Id,
                    ProductId = oi.ProductId,
                    ProductName = oi.Product.Name,
                    Quantity = oi.Quantity,
                    UnitPrice = oi.UnitPrice,
                    TotalPrice = oi.TotalPrice
                }).ToList()
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting order by ID: {OrderId}", id);
            throw;
        }
    }

    public async Task<PagedResponse<OrderResponseDto>> GetOrdersAsync(int pageNumber = 1, int pageSize = 10)
    {
        try
        {
            _logger.LogInformation("Getting orders - Page: {PageNumber}, Size: {PageSize}", pageNumber, pageSize);

            var totalRecords = await _context.Orders.CountAsync();
            var totalPages = (int)Math.Ceiling(totalRecords / (double)pageSize);

            var orders = await _context.Orders
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
                .OrderByDescending(o => o.OrderDate)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .Select(o => new OrderResponseDto
                {
                    Id = o.Id,
                    CustomerName = o.CustomerName,
                    CustomerEmail = o.CustomerEmail,
                    OrderDate = o.OrderDate,
                    Status = o.Status,
                    TotalAmount = o.TotalAmount,
                    Notes = o.Notes,
                    Items = o.OrderItems.Select(oi => new OrderItemResponseDto
                    {
                        Id = oi.Id,
                        ProductId = oi.ProductId,
                        ProductName = oi.Product.Name,
                        Quantity = oi.Quantity,
                        UnitPrice = oi.UnitPrice,
                        TotalPrice = oi.TotalPrice
                    }).ToList()
                })
                .ToListAsync();

            return new PagedResponse<OrderResponseDto>
            {
                Data = orders,
                PageNumber = pageNumber,
                PageSize = pageSize,
                TotalPages = totalPages,
                TotalRecords = totalRecords
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting orders");
            throw;
        }
    }

    public async Task<List<OrderResponseDto>> GetOrdersByCustomerEmailAsync(string customerEmail)
    {
        try
        {
            _logger.LogInformation("Getting orders for customer: {CustomerEmail}", customerEmail);

            var orders = await _context.Orders
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
                .Where(o => o.CustomerEmail.ToLower() == customerEmail.ToLower())
                .OrderByDescending(o => o.OrderDate)
                .Select(o => new OrderResponseDto
                {
                    Id = o.Id,
                    CustomerName = o.CustomerName,
                    CustomerEmail = o.CustomerEmail,
                    OrderDate = o.OrderDate,
                    Status = o.Status,
                    TotalAmount = o.TotalAmount,
                    Notes = o.Notes,
                    Items = o.OrderItems.Select(oi => new OrderItemResponseDto
                    {
                        Id = oi.Id,
                        ProductId = oi.ProductId,
                        ProductName = oi.Product.Name,
                        Quantity = oi.Quantity,
                        UnitPrice = oi.UnitPrice,
                        TotalPrice = oi.TotalPrice
                    }).ToList()
                })
                .ToListAsync();

            return orders;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting orders for customer: {CustomerEmail}", customerEmail);
            throw;
        }
    }

    public async Task<bool> UpdateOrderStatusAsync(int orderId, OrderStatus newStatus)
    {
        try
        {
            _logger.LogInformation("Updating order status: {OrderId} to {NewStatus}", orderId, newStatus);

            var order = await _context.Orders.FirstOrDefaultAsync(o => o.Id == orderId);
            if (order == null)
            {
                _logger.LogWarning("Order not found for status update: {OrderId}", orderId);
                return false;
            }

            // Validate status transition
            if (!IsValidStatusTransition(order.Status, newStatus))
            {
                throw new InvalidOperationException($"Invalid status transition from {order.Status} to {newStatus}");
            }

            order.Status = newStatus;
            await _context.SaveChangesAsync();

            _logger.LogInformation("Order status updated successfully: {OrderId}", orderId);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating order status: {OrderId}", orderId);
            throw;
        }
    }

    public async Task<bool> CancelOrderAsync(int orderId)
    {
        using var transaction = await _context.Database.BeginTransactionAsync();
        
        try
        {
            _logger.LogInformation("Cancelling order: {OrderId}", orderId);

            var order = await _context.Orders
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
                .FirstOrDefaultAsync(o => o.Id == orderId);

            if (order == null)
            {
                _logger.LogWarning("Order not found for cancellation: {OrderId}", orderId);
                return false;
            }

            if (order.Status == OrderStatus.Delivered || order.Status == OrderStatus.Cancelled)
            {
                throw new InvalidOperationException($"Cannot cancel order with status: {order.Status}");
            }

            // Restore stock for all order items
            foreach (var item in order.OrderItems)
            {
                item.Product.Stock += item.Quantity;
                item.Product.UpdatedAt = DateTime.UtcNow;
            }

            order.Status = OrderStatus.Cancelled;
            await _context.SaveChangesAsync();

            await transaction.CommitAsync();

            _logger.LogInformation("Order cancelled successfully: {OrderId}", orderId);
            return true;
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync();
            _logger.LogError(ex, "Error cancelling order: {OrderId}", orderId);
            throw;
        }
    }

    public async Task<decimal> CalculateOrderTotalAsync(List<CreateOrderItemDto> items)
    {
        try
        {
            _logger.LogInformation("Calculating order total for {ItemCount} items", items.Count);

            decimal total = 0;

            foreach (var item in items)
            {
                var product = await _context.Products.FirstOrDefaultAsync(p => p.Id == item.ProductId && p.IsActive);
                if (product == null)
                {
                    throw new ArgumentException($"Product with ID {item.ProductId} does not exist or is not active");
                }

                total += product.Price * item.Quantity;
            }

            return total;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error calculating order total");
            throw;
        }
    }

    private static bool IsValidStatusTransition(OrderStatus currentStatus, OrderStatus newStatus)
    {
        return currentStatus switch
        {
            OrderStatus.Pending => newStatus is OrderStatus.Processing or OrderStatus.Cancelled,
            OrderStatus.Processing => newStatus is OrderStatus.Shipped or OrderStatus.Cancelled,
            OrderStatus.Shipped => newStatus is OrderStatus.Delivered,
            OrderStatus.Delivered => newStatus is OrderStatus.Refunded,
            OrderStatus.Cancelled => false, // Cannot transition from cancelled
            OrderStatus.Refunded => false, // Cannot transition from refunded
            _ => false
        };
    }
}

/// <summary>
/// Interface for external notification service
/// </summary>
public interface INotificationService
{
    Task SendEmailAsync(string to, string subject, string body);
    Task SendSmsAsync(string phoneNumber, string message);
    Task<bool> IsEmailValidAsync(string email);
}

/// <summary>
/// Mock notification service for testing
/// </summary>
public class NotificationService : INotificationService
{
    private readonly ILogger<NotificationService> _logger;

    public NotificationService(ILogger<NotificationService> logger)
    {
        _logger = logger;
    }

    public async Task SendEmailAsync(string to, string subject, string body)
    {
        _logger.LogInformation("Sending email to {To} with subject: {Subject}", to, subject);
        
        // Simulate email sending delay
        await Task.Delay(100);
        
        // In a real implementation, this would integrate with an email service
        _logger.LogInformation("Email sent successfully to {To}", to);
    }

    public async Task SendSmsAsync(string phoneNumber, string message)
    {
        _logger.LogInformation("Sending SMS to {PhoneNumber}: {Message}", phoneNumber, message);
        
        // Simulate SMS sending delay
        await Task.Delay(50);
        
        // In a real implementation, this would integrate with an SMS service
        _logger.LogInformation("SMS sent successfully to {PhoneNumber}", phoneNumber);
    }

    public async Task<bool> IsEmailValidAsync(string email)
    {
        _logger.LogInformation("Validating email: {Email}", email);
        
        // Simulate external email validation service
        await Task.Delay(25);
        
        // Simple validation - in real implementation would use external service
        return !string.IsNullOrWhiteSpace(email) && 
               email.Contains('@') && 
               email.Contains('.') &&
               !email.StartsWith("invalid");
    }
}
