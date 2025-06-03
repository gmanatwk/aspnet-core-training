using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using PerformanceDemo.Data;
using PerformanceDemo.Models;

namespace PerformanceDemo.Services;

public class OrderService : IOrderService
{
    private readonly ApplicationDbContext _context;
    private readonly IMemoryCache _cache;
    private readonly ILogger<OrderService> _logger;
    private const string OrdersCacheKeyPrefix = "orders_";

    public OrderService(
        ApplicationDbContext context,
        IMemoryCache cache,
        ILogger<OrderService> logger)
    {
        _context = context;
        _cache = cache;
        _logger = logger;
    }

    public async Task<IEnumerable<Order>> GetAllOrdersAsync()
    {
        var cacheKey = $"{OrdersCacheKeyPrefix}all";
        
        if (_cache.TryGetValue<List<Order>>(cacheKey, out var cachedOrders))
        {
            _logger.LogInformation("Returning cached orders");
            return cachedOrders!;
        }

        var orders = await _context.Orders
            .Include(o => o.OrderItems)
            .ThenInclude(oi => oi.Product)
            .ToListAsync();

        _cache.Set(cacheKey, orders, TimeSpan.FromMinutes(5));
        
        return orders;
    }

    public async Task<Order?> GetOrderByIdAsync(int id)
    {
        var cacheKey = $"{OrdersCacheKeyPrefix}{id}";
        
        if (_cache.TryGetValue<Order>(cacheKey, out var cachedOrder))
        {
            return cachedOrder;
        }

        var order = await _context.Orders
            .Include(o => o.OrderItems)
            .ThenInclude(oi => oi.Product)
            .FirstOrDefaultAsync(o => o.Id == id);

        if (order != null)
        {
            _cache.Set(cacheKey, order, TimeSpan.FromMinutes(10));
        }

        return order;
    }

    public async Task<IEnumerable<Order>> GetOrdersByCustomerAsync(string email)
    {
        return await _context.Orders
            .Where(o => o.CustomerEmail == email)
            .Include(o => o.OrderItems)
            .ThenInclude(oi => oi.Product)
            .OrderByDescending(o => o.OrderDate)
            .ToListAsync();
    }

    public async Task<Order> CreateOrderAsync(Order order, List<OrderItem> items)
    {
        // Add order items
        foreach (var item in items)
        {
            item.OrderId = order.Id;
            order.OrderItems.Add(item);
        }
        
        _context.Orders.Add(order);
        await _context.SaveChangesAsync();
        
        // Invalidate cache
        _cache.Remove($"{OrdersCacheKeyPrefix}all");
        
        return order;
    }

    public async Task<bool> UpdateOrderStatusAsync(int id, OrderStatus status)
    {
        var existingOrder = await _context.Orders.FindAsync(id);
        if (existingOrder == null)
        {
            return false;
        }

        existingOrder.Status = status;

        await _context.SaveChangesAsync();
        
        // Invalidate cache
        _cache.Remove($"{OrdersCacheKeyPrefix}{id}");
        _cache.Remove($"{OrdersCacheKeyPrefix}all");
        
        return true;
    }

}