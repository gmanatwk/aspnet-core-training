using JwtAuthenticationAPI.Models;

namespace JwtAuthenticationAPI.Services;

public interface IUserService
{
    Task<User?> AuthenticateAsync(string username, string password);
    Task<User?> GetUserByIdAsync(int id);
    Task<User?> RegisterAsync(RegisterRequest request);
    Task<List<User>> GetAllUsersAsync();
}

public class UserService : IUserService
{
    private readonly List<User> _users;
    private readonly ILogger<UserService> _logger;

    public UserService(ILogger<UserService> logger)
    {
        _logger = logger;

        // In a real application, this would be replaced with a database
        _users = new List<User>
        {
            new User
            {
                Id = 1,
                Username = "admin",
                Password = HashPassword("admin123"),
                Email = "admin@example.com",
                Roles = new List<string> { "Admin", "User" }
            },
            new User
            {
                Id = 2,
                Username = "manager",
                Password = HashPassword("manager123"),
                Email = "manager@example.com",
                Roles = new List<string> { "Manager", "User" }
            },
            new User
            {
                Id = 3,
                Username = "user",
                Password = HashPassword("user123"),
                Email = "user@example.com",
                Roles = new List<string> { "User" }
            }
        };
    }

    public async Task<User?> AuthenticateAsync(string username, string password)
    {
        try
        {
            _logger.LogInformation("Attempting to authenticate user: {Username}", username);

            await Task.Delay(100); // Simulate async database call

            var user = _users.FirstOrDefault(x =>
                x.Username.Equals(username, StringComparison.OrdinalIgnoreCase));

            if (user != null && ValidatePassword(password, user.Password))
            {
                _logger.LogInformation("User authenticated successfully: {Username}", username);
                return user;
            }

            _logger.LogWarning("Authentication failed for user: {Username}", username);
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during authentication for user: {Username}", username);
            return null;
        }
    }

    public async Task<User?> GetUserByIdAsync(int id)
    {
        try
        {
            await Task.Delay(50); // Simulate async database call
            return _users.FirstOrDefault(x => x.Id == id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving user by ID: {UserId}", id);
            return null;
        }
    }

    public async Task<User?> RegisterAsync(RegisterRequest request)
    {
        try
        {
            await Task.Delay(100); // Simulate async database call

            // Check if username already exists
            if (_users.Any(u => u.Username.Equals(request.Username, StringComparison.OrdinalIgnoreCase)))
            {
                return null; // Username already exists
            }

            var newUser = new User
            {
                Id = _users.Max(u => u.Id) + 1,
                Username = request.Username,
                Password = HashPassword(request.Password),
                Email = request.Email,
                Roles = new List<string> { "User" }, // Default role
                CreatedAt = DateTime.UtcNow
            };

            _users.Add(newUser);
            _logger.LogInformation("User registered successfully: {Username}", request.Username);

            return newUser;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during registration for user: {Username}", request.Username);
            return null;
        }
    }

    public async Task<List<User>> GetAllUsersAsync()
    {
        await Task.Delay(50); // Simulate async database call
        return _users.ToList();
    }

    private bool ValidatePassword(string password, string hashedPassword)
    {
        return HashPassword(password) == hashedPassword;
    }

    private string HashPassword(string password)
    {
        // In a real application, use BCrypt, Argon2, or ASP.NET Core Identity
        using var sha256 = System.Security.Cryptography.SHA256.Create();
        var hashedBytes = sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password + "salt"));
        return Convert.ToBase64String(hashedBytes);
    }
}
