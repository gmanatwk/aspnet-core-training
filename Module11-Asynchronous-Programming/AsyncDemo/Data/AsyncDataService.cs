using AsyncDemo.Models;
using System.Text.Json;

namespace AsyncDemo.Data;

public class AsyncDataService : IAsyncDataService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<AsyncDataService> _logger;
    private static readonly List<User> _users = new()
    {
        new User { Id = 1, Name = "John Doe", Email = "john@example.com" },
        new User { Id = 2, Name = "Jane Smith", Email = "jane@example.com" }
    };

    public AsyncDataService(HttpClient httpClient, ILogger<AsyncDataService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<List<User>> GetAllUsersAsync()
    {
        _logger.LogInformation("Fetching all users");
        await Task.Delay(100);
        return _users.ToList();
    }

    public async Task<User?> GetUserByIdAsync(int id)
    {
        _logger.LogInformation("Fetching user with ID: {UserId}", id);
        await Task.Delay(50);
        return _users.FirstOrDefault(u => u.Id == id);
    }

    public async Task<User> CreateUserAsync(string name, string email)
    {
        _logger.LogInformation("Creating user: {Name}, {Email}", name, email);
        await Task.Delay(200);

        var user = new User
        {
            Id = _users.Count + 1,
            Name = name,
            Email = email
        };

        _users.Add(user);
        return user;
    }

    public async Task<object> GetExternalUserDataAsync(int userId)
    {
        _logger.LogInformation("Fetching external data for user: {UserId}", userId);

        try
        {
            var response = await _httpClient.GetAsync($"https://jsonplaceholder.typicode.com/users/{userId}");

            if (response.IsSuccessStatusCode)
            {
                var content = await response.Content.ReadAsStringAsync();
                return JsonSerializer.Deserialize<object>(content) ?? new { message = "No data" };
            }

            return new { message = "External service unavailable" };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to fetch external data");
            return new { message = "Error fetching external data" };
        }
    }
}
