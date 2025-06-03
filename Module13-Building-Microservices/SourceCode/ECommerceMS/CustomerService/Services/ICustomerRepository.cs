using CustomerService.Models;

namespace CustomerService.Services;

public interface ICustomerRepository
{
    Task<IEnumerable<Customer>> GetAllAsync();
    Task<Customer?> GetByIdAsync(int id);
    Task<Customer?> GetByEmailAsync(string email);
    Task<Customer> CreateAsync(Customer customer);
    Task<Customer?> UpdateAsync(int id, Customer customer);
    Task<bool> DeleteAsync(int id);
    Task<bool> CustomerExistsAsync(int id);
    Task<bool> EmailExistsAsync(string email);
}