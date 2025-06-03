using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using JwtAuthenticationAPI.Models;
using JwtAuthenticationAPI.Services;
using System.Security.Claims;

namespace JwtAuthenticationAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IUserService _userService;
    private readonly ILogger<AuthController> _logger;

    public AuthController(
        IJwtTokenService jwtTokenService, 
        IUserService userService,
        ILogger<AuthController> logger)
    {
        _jwtTokenService = jwtTokenService;
        _userService = userService;
        _logger = logger;
    }

    /// <summary>
    /// Authenticate user and return JWT token
    /// </summary>
    /// <param name="request">Login credentials</param>
    /// <returns>JWT token if authentication successful</returns>
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid request data",
                    Errors = ModelState.Values.SelectMany(v => v.Errors.Select(e => e.ErrorMessage)).ToList()
                });
            }

            var user = await _userService.AuthenticateAsync(request.Username, request.Password);
            
            if (user == null)
            {
                _logger.LogWarning("Login attempt failed for username: {Username}", request.Username);
                return Unauthorized(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid username or password"
                });
            }

            var token = _jwtTokenService.GenerateToken(user);
            var response = new LoginResponse
            {
                Token = token,
                Expiration = DateTime.UtcNow.AddMinutes(60), // Should match JWT config
                Username = user.Username,
                Roles = user.Roles
            };

            _logger.LogInformation("User logged in successfully: {Username}", request.Username);

            return Ok(new ApiResponse<LoginResponse>
            {
                Success = true,
                Message = "Login successful",
                Data = response
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during login for username: {Username}", request.Username);
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred during login"
            });
        }
    }

    /// <summary>
    /// Register a new user
    /// </summary>
    /// <param name="request">Registration details</param>
    /// <returns>Success response if registration successful</returns>
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid request data",
                    Errors = ModelState.Values.SelectMany(v => v.Errors.Select(e => e.ErrorMessage)).ToList()
                });
            }

            var registrationSuccessful = await _userService.RegisterUserAsync(request);
            
            if (!registrationSuccessful)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Username or email already exists"
                });
            }

            _logger.LogInformation("User registered successfully: {Username}", request.Username);

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "User registered successfully"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during registration for username: {Username}", request.Username);
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred during registration"
            });
        }
    }

    /// <summary>
    /// Get current user profile (requires authentication)
    /// </summary>
    /// <returns>Current user's profile information</returns>
    [HttpGet("profile")]
    [Authorize]
    public async Task<IActionResult> GetProfile()
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
                Message = "Profile retrieved successfully",
                Data = profile
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving user profile");
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred while retrieving profile"
            });
        }
    }

    /// <summary>
    /// Test endpoint to verify JWT authentication
    /// </summary>
    /// <returns>Success message if authenticated</returns>
    [HttpGet("protected")]
    [Authorize]
    public IActionResult Protected()
    {
        var username = User.FindFirst(ClaimTypes.Name)?.Value;
        var roles = User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();
        
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = $"Hello {username}! You have successfully accessed a protected endpoint.",
            Data = new { Username = username, Roles = roles }
        });
    }

    /// <summary>
    /// Admin-only endpoint (requires Admin role)
    /// </summary>
    /// <returns>Admin data if user has Admin role</returns>
    [HttpGet("admin-only")]
    [Authorize(Roles = "Admin")]
    public IActionResult AdminOnly()
    {
        var username = User.FindFirst(ClaimTypes.Name)?.Value;
        
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = $"Hello Admin {username}! This is admin-only content.",
            Data = new { Message = "You have administrative privileges", AccessLevel = "Admin" }
        });
    }

    /// <summary>
    /// User or Admin endpoint (requires User or Admin role)
    /// </summary>
    /// <returns>User data if user has User or Admin role</returns>
    [HttpGet("user-area")]
    [Authorize(Policy = "UserOrAdmin")]
    public IActionResult UserArea()
    {
        var username = User.FindFirst(ClaimTypes.Name)?.Value;
        var roles = User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();
        
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = $"Welcome to the user area, {username}!",
            Data = new { Username = username, Roles = roles, AccessLevel = "User" }
        });
    }

    /// <summary>
    /// Refresh JWT token (requires valid token)
    /// </summary>
    /// <returns>New JWT token</returns>
    [HttpPost("refresh")]
    [Authorize]
    public async Task<IActionResult> RefreshToken()
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

            var newToken = _jwtTokenService.GenerateToken(user);
            var response = new LoginResponse
            {
                Token = newToken,
                Expiration = DateTime.UtcNow.AddMinutes(60),
                Username = user.Username,
                Roles = user.Roles
            };

            return Ok(new ApiResponse<LoginResponse>
            {
                Success = true,
                Message = "Token refreshed successfully",
                Data = response
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during token refresh");
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred during token refresh"
            });
        }
    }
}