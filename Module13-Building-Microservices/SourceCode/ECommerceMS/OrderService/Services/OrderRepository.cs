using Microsoft.EntityFrameworkCore;
using OrderService.Data;
using OrderService.Models;
using SharedLibrary.Models;

namespace OrderService.Services;

public class OrderRepository : IOrderRepository
{
    private readonly OrderDbContext _context;
    private readonly ILogger<OrderRepository> _logger;

    public OrderRepository(OrderDbContext context, ILogger<OrderRepository> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<IEnumerable<Order>> GetAllAsync()
    {
        try
        {
            return await _context.Orders
                .Include(o => o.Items)
                .ToListAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving all orders");
            throw;
        }
    }

    public async Task<IEnumerable<Order>> GetByCustomerIdAsync(int customerId)
    {
        try
        {
            return await _context.Orders
                .Include(o => o.Items)
                .Where(o => o.CustomerId == customerId)
                .ToListAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving orders for customer: {CustomerId}", customerId);
            throw;
        }
    }

    public async Task<Order?> GetByIdAsync(int id)
    {
        try
        {
            return await _context.Orders
                .Include(o => o.Items)
                .FirstOrDefaultAsync(o => o.Id == id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving order with ID: {OrderId}", id);
            throw;
        }
    }

    public async Task<Order?> GetByOrderNumberAsync(string orderNumber)
    {
        try
        {
            return await _context.Orders
                .Include(o => o.Items)
                .FirstOrDefaultAsync(o => o.OrderNumber == orderNumber);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving order with number: {OrderNumber}", orderNumber);
            throw;
        }
    }

    public async Task<Order> CreateAsync(Order order)
    {
        try
        {
            order.OrderNumber = GenerateOrderNumber();
            order.OrderDate = DateTime.UtcNow;
            order.CreatedAt = DateTime.UtcNow;
            order.Status = OrderStatus.Pending;
            
            // Calculate total amount
            order.TotalAmount = order.Items.Sum(item => item.TotalPrice);

            _context.Orders.Add(order);
            await _context.SaveChangesAsync();
            
            _logger.LogInformation("Order created with ID: {OrderId}, Number: {OrderNumber}", order.Id, order.OrderNumber);
            return order;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating order");
            throw;
        }
    }

    public async Task<Order?> UpdateStatusAsync(int id, OrderStatus status)
    {
        try
        {
            var order = await _context.Orders.FindAsync(id);
            if (order == null)
            {
                return null;
            }

            order.Status = status;
            order.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            
            _logger.LogInformation("Order status updated. ID: {OrderId}, New Status: {Status}", id, status);
            return order;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating order status. ID: {OrderId}", id);
            throw;
        }
    }

    public async Task<bool> DeleteAsync(int id)
    {
        try
        {
            var order = await _context.Orders.FindAsync(id);
            if (order == null)
            {
                return false;
            }

            _context.Orders.Remove(order);
            await _context.SaveChangesAsync();
            
            _logger.LogInformation("Order deleted with ID: {OrderId}", id);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting order with ID: {OrderId}", id);
            throw;
        }
    }

    public async Task<bool> OrderExistsAsync(int id)
    {
        try
        {
            return await _context.Orders.AnyAsync(o => o.Id == id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking if order exists with ID: {OrderId}", id);
            throw;
        }
    }

    private string GenerateOrderNumber()
    {
        var timestamp = DateTime.UtcNow.ToString("yyyyMMddHHmmss");
        var random = new Random().Next(1000, 9999);
        return $"ORD-{timestamp}-{random}";
    }
}