using AsyncDemo.Models;

namespace AsyncDemo.Data;

public interface IAsyncDataService
{
    Task<List<User>> GetAllUsersAsync();
    Task<User?> GetUserByIdAsync(int id);
    Task<User> CreateUserAsync(string name, string email);
    Task<object> GetExternalUserDataAsync(int userId);
}
