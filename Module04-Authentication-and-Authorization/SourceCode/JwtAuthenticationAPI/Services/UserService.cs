using JwtAuthenticationAPI.Models;

namespace JwtAuthenticationAPI.Services;

public interface IUserService
{
    Task<User?> AuthenticateAsync(string username, string password);
    Task<User?> GetUserByUsernameAsync(string username);
    Task<User?> GetUserByIdAsync(int id);
    Task<bool> RegisterUserAsync(RegisterRequest request);
    Task<List<User>> GetAllUsersAsync();
    bool ValidatePassword(string password, string hashedPassword);
    string HashPassword(string password);
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
            // Exercise 01 & 02 users
            new User
            {
                Id = 1,
                Username = "admin",
                Password = HashPassword("admin123"),
                Email = "admin@example.com",
                Roles = new List<string> { "Admin", "Editor", "User", "Employee" }
            },
            new User
            {
                Id = 2,
                Username = "user",
                Password = HashPassword("user123"),
                Email = "user@example.com",
                Roles = new List<string> { "User" }
            },
            new User
            {
                Id = 3,
                Username = "editor",
                Password = HashPassword("editor123"),
                Email = "editor@example.com",
                Roles = new List<string> { "Editor", "User" }
            },
            // Exercise 03 users - for custom policies
            new User
            {
                Id = 4,
                Username = "senior_dev",
                Password = HashPassword("senior123"),
                Email = "senior.dev@example.com",
                Roles = new List<string> { "Employee", "Developer" }
            },
            new User
            {
                Id = 5,
                Username = "junior_dev",
                Password = HashPassword("junior123"),
                Email = "junior.dev@example.com",
                Roles = new List<string> { "Employee", "Developer" }
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

    public async Task<User?> GetUserByUsernameAsync(string username)
    {
        try
        {
            await Task.Delay(50); // Simulate async database call
            
            var user = _users.FirstOrDefault(x => 
                x.Username.Equals(username, StringComparison.OrdinalIgnoreCase));
            
            return user;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving user by username: {Username}", username);
            return null;
        }
    }

    public async Task<User?> GetUserByIdAsync(int id)
    {
        try
        {
            await Task.Delay(50); // Simulate async database call
            
            var user = _users.FirstOrDefault(x => x.Id == id);
            
            return user;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving user by ID: {UserId}", id);
            return null;
        }
    }

    public async Task<bool> RegisterUserAsync(RegisterRequest request)
    {
        try
        {
            _logger.LogInformation("Attempting to register new user: {Username}", request.Username);
            
            await Task.Delay(100); // Simulate async database call
            
            // Check if user already exists
            if (_users.Any(x => x.Username.Equals(request.Username, StringComparison.OrdinalIgnoreCase) ||
                               x.Email.Equals(request.Email, StringComparison.OrdinalIgnoreCase)))
            {
                _logger.LogWarning("User registration failed - user already exists: {Username}", request.Username);
                return false;
            }
            
            var newUser = new User
            {
                Id = _users.Max(x => x.Id) + 1,
                Username = request.Username,
                Email = request.Email,
                Password = HashPassword(request.Password),
                Roles = new List<string> { "User" }, // Default role
                CreatedAt = DateTime.UtcNow
            };
            
            _users.Add(newUser);
            
            _logger.LogInformation("User registered successfully: {Username}", request.Username);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during user registration: {Username}", request.Username);
            return false;
        }
    }

    public async Task<List<User>> GetAllUsersAsync()
    {
        try
        {
            await Task.Delay(50); // Simulate async database call
            
            return _users.ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving all users");
            return new List<User>();
        }
    }

    public bool ValidatePassword(string password, string hashedPassword)
    {
        // In a real application, use proper password hashing like BCrypt
        // For demo purposes, we're using simple comparison
        return HashPassword(password) == hashedPassword;
    }

    public string HashPassword(string password)
    {
        // In a real application, use BCrypt, Argon2, or ASP.NET Core Identity
        // For demo purposes, using simple hash
        using var sha256 = System.Security.Cryptography.SHA256.Create();
        var hashedBytes = sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password + "salt"));
        return Convert.ToBase64String(hashedBytes);
    }
}