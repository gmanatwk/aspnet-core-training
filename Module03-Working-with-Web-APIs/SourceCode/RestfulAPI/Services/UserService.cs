using System.Security.Cryptography;
using Microsoft.AspNetCore.Cryptography.KeyDerivation;
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Data;
using RestfulAPI.Models;

namespace RestfulAPI.Services;

/// <summary>
/// Interface for user management operations
/// </summary>
public interface IUserService
{
    Task<User?> GetByEmailAsync(string email);
    Task<User?> GetByIdAsync(int id);
    Task<User> CreateAsync(RegisterRequest request);
    Task<bool> ValidatePasswordAsync(User user, string password);
    Task<bool> ChangePasswordAsync(User user, string currentPassword, string newPassword);
    Task<IList<string>> GetUserRolesAsync(User user);
    Task UpdateLastLoginAsync(User user);
}

/// <summary>
/// Service for managing user operations
/// </summary>
public class UserService : IUserService
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<UserService> _logger;

    public UserService(ApplicationDbContext context, ILogger<UserService> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Get user by email
    /// </summary>
    public async Task<User?> GetByEmailAsync(string email)
    {
        return await _context.Users
            .Include(u => u.UserRoles)
            .ThenInclude(ur => ur.Role)
            .FirstOrDefaultAsync(u => u.Email.ToLower() == email.ToLower());
    }

    /// <summary>
    /// Get user by ID
    /// </summary>
    public async Task<User?> GetByIdAsync(int id)
    {
        return await _context.Users
            .Include(u => u.UserRoles)
            .ThenInclude(ur => ur.Role)
            .FirstOrDefaultAsync(u => u.Id == id);
    }

    /// <summary>
    /// Create a new user
    /// </summary>
    public async Task<User> CreateAsync(RegisterRequest request)
    {
        // Check if user already exists
        var existingUser = await GetByEmailAsync(request.Email);
        if (existingUser != null)
        {
            throw new InvalidOperationException("User with this email already exists");
        }

        // Create new user
        var user = new User
        {
            Email = request.Email.ToLower(),
            FullName = request.FullName,
            PasswordHash = HashPassword(request.Password),
            CreatedAt = DateTime.UtcNow,
            IsActive = true
        };

        _context.Users.Add(user);
        
        // Assign default role
        var userRole = await _context.Roles.FirstOrDefaultAsync(r => r.Name == "User");
        if (userRole != null)
        {
            user.UserRoles.Add(new UserRole { User = user, Role = userRole });
        }

        await _context.SaveChangesAsync();
        _logger.LogInformation("New user created: {Email}", user.Email);

        return user;
    }

    /// <summary>
    /// Validate user password
    /// </summary>
    public async Task<bool> ValidatePasswordAsync(User user, string password)
    {
        return await Task.FromResult(VerifyPassword(password, user.PasswordHash));
    }

    /// <summary>
    /// Change user password
    /// </summary>
    public async Task<bool> ChangePasswordAsync(User user, string currentPassword, string newPassword)
    {
        if (!await ValidatePasswordAsync(user, currentPassword))
        {
            return false;
        }

        user.PasswordHash = HashPassword(newPassword);
        await _context.SaveChangesAsync();
        
        _logger.LogInformation("Password changed for user: {Email}", user.Email);
        return true;
    }

    /// <summary>
    /// Get user roles
    /// </summary>
    public async Task<IList<string>> GetUserRolesAsync(User user)
    {
        var roles = user.UserRoles.Select(ur => ur.Role.Name).ToList();
        return await Task.FromResult(roles);
    }

    /// <summary>
    /// Update user's last login time
    /// </summary>
    public async Task UpdateLastLoginAsync(User user)
    {
        user.LastLoginAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
    }

    /// <summary>
    /// Hash a password using PBKDF2
    /// </summary>
    private static string HashPassword(string password)
    {
        // Generate a 128-bit salt using a cryptographically strong random sequence of nonzero values
        byte[] salt = new byte[128 / 8];
        using (var rng = RandomNumberGenerator.Create())
        {
            rng.GetNonZeroBytes(salt);
        }

        // Derive a 256-bit subkey (use HMACSHA256 with 100,000 iterations)
        string hashed = Convert.ToBase64String(KeyDerivation.Pbkdf2(
            password: password,
            salt: salt,
            prf: KeyDerivationPrf.HMACSHA256,
            iterationCount: 100000,
            numBytesRequested: 256 / 8));

        // Combine salt and hash
        byte[] hashBytes = new byte[salt.Length + (256 / 8)];
        Array.Copy(salt, 0, hashBytes, 0, salt.Length);
        Array.Copy(Convert.FromBase64String(hashed), 0, hashBytes, salt.Length, 256 / 8);

        return Convert.ToBase64String(hashBytes);
    }

    /// <summary>
    /// Verify a password against a hash
    /// </summary>
    private static bool VerifyPassword(string password, string hashedPassword)
    {
        try
        {
            byte[] hashBytes = Convert.FromBase64String(hashedPassword);
            
            // Extract salt
            byte[] salt = new byte[128 / 8];
            Array.Copy(hashBytes, 0, salt, 0, salt.Length);

            // Hash the input password with the same salt
            string hashed = Convert.ToBase64String(KeyDerivation.Pbkdf2(
                password: password,
                salt: salt,
                prf: KeyDerivationPrf.HMACSHA256,
                iterationCount: 100000,
                numBytesRequested: 256 / 8));

            // Compare the results
            byte[] hashToCompare = Convert.FromBase64String(hashed);
            for (int i = 0; i < hashToCompare.Length; i++)
            {
                if (hashBytes[i + salt.Length] != hashToCompare[i])
                {
                    return false;
                }
            }

            return true;
        }
        catch
        {
            return false;
        }
    }
}