using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using JwtAuthenticationAPI.Models;
using JwtAuthenticationAPI.Services;
using System.Security.Claims;

namespace JwtAuthenticationAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize] // All endpoints in this controller require authentication
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;
    private readonly ILogger<UsersController> _logger;

    public UsersController(IUserService userService, ILogger<UsersController> logger)
    {
        _userService = userService;
        _logger = logger;
    }

    /// <summary>
    /// Get all users (Admin only)
    /// </summary>
    /// <returns>List of all users</returns>
    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetAllUsers()
    {
        try
        {
            var users = await _userService.GetAllUsersAsync();
            
            var userProfiles = users.Select(u => new UserProfile
            {
                Id = u.Id,
                Username = u.Username,
                Email = u.Email,
                Roles = u.Roles,
                CreatedAt = u.CreatedAt
            }).ToList();

            return Ok(new ApiResponse<List<UserProfile>>
            {
                Success = true,
                Message = "Users retrieved successfully",
                Data = userProfiles
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving all users");
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred while retrieving users"
            });
        }
    }

    /// <summary>
    /// Get user by ID (Admin only or own profile)
    /// </summary>
    /// <param name="id">User ID</param>
    /// <returns>User profile</returns>
    [HttpGet("{id}")]
    public async Task<IActionResult> GetUserById(int id)
    {
        try
        {
            var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var currentUserRoles = User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();
            
            // Allow if user is admin or requesting their own profile
            if (!currentUserRoles.Contains("Admin") && currentUserId != id.ToString())
            {
                return Forbid();
            }

            var user = await _userService.GetUserByIdAsync(id);
            
            if (user == null)
            {
                return NotFound(new ApiResponse<object>
                {
                    Success = false,
                    Message = "User not found"
                });
            }

            var profile = new UserProfile
            {
                Id = user.Id,
                Username = user.Username,
                Email = user.Email,
                Roles = user.Roles,
                CreatedAt = user.CreatedAt
            };

            return Ok(new ApiResponse<UserProfile>
            {
                Success = true,
                Message = "User retrieved successfully",
                Data = profile
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving user by ID: {UserId}", id);
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred while retrieving user"
            });
        }
    }

    /// <summary>
    /// Get current user's information
    /// </summary>
    /// <returns>Current user profile</returns>
    [HttpGet("me")]
    public async Task<IActionResult> GetCurrentUser()
    {
        try
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (string.IsNullOrEmpty(userId) || !int.TryParse(userId, out int id))
            {
                return Unauthorized(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid user token"
                });
            }

            var user = await _userService.GetUserByIdAsync(id);
            
            if (user == null)
            {
                return NotFound(new ApiResponse<object>
                {
                    Success = false,
                    Message = "User not found"
                });
            }

            var profile = new UserProfile
            {
                Id = user.Id,
                Username = user.Username,
                Email = user.Email,
                Roles = user.Roles,
                CreatedAt = user.CreatedAt
            };

            return Ok(new ApiResponse<UserProfile>
            {
                Success = true,
                Message = "Current user retrieved successfully",
                Data = profile
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving current user");
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred while retrieving current user"
            });
        }
    }

    /// <summary>
    /// Get users by role (Admin only)
    /// </summary>
    /// <param name="role">Role name</param>
    /// <returns>List of users with specified role</returns>
    [HttpGet("by-role/{role}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetUsersByRole(string role)
    {
        try
        {
            var allUsers = await _userService.GetAllUsersAsync();
            var usersWithRole = allUsers.Where(u => u.Roles.Contains(role, StringComparer.OrdinalIgnoreCase)).ToList();
            
            var userProfiles = usersWithRole.Select(u => new UserProfile
            {
                Id = u.Id,
                Username = u.Username,
                Email = u.Email,
                Roles = u.Roles,
                CreatedAt = u.CreatedAt
            }).ToList();

            return Ok(new ApiResponse<List<UserProfile>>
            {
                Success = true,
                Message = $"Users with role '{role}' retrieved successfully",
                Data = userProfiles
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving users by role: {Role}", role);
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred while retrieving users by role"
            });
        }
    }
}