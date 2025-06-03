using OrderService.Models;

namespace OrderService.Services;

public interface IOrderRepository
{
    Task<IEnumerable<Order>> GetAllAsync();
    Task<IEnumerable<Order>> GetByCustomerIdAsync(int customerId);
    Task<Order?> GetByIdAsync(int id);
    Task<Order?> GetByOrderNumberAsync(string orderNumber);
    Task<Order> CreateAsync(Order order);
    Task<Order?> UpdateStatusAsync(int id, SharedLibrary.Models.OrderStatus status);
    Task<bool> DeleteAsync(int id);
    Task<bool> OrderExistsAsync(int id);
}