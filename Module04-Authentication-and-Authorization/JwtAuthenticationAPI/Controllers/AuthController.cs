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
                Expiration = DateTime.UtcNow.AddMinutes(60),
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

            var user = await _userService.RegisterAsync(request);

            if (user == null)
            {
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Username already exists"
                });
            }

            var token = _jwtTokenService.GenerateToken(user);
            var response = new LoginResponse
            {
                Token = token,
                Expiration = DateTime.UtcNow.AddMinutes(60),
                Username = user.Username,
                Roles = user.Roles
            };

            _logger.LogInformation("User registered successfully: {Username}", request.Username);

            return Ok(new ApiResponse<LoginResponse>
            {
                Success = true,
                Message = "Registration successful",
                Data = response
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
    [HttpGet("profile")]
    [Authorize]
    public async Task<IActionResult> GetProfile()
    {
        try
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return Unauthorized(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid token"
                });
            }

            var user = await _userService.GetUserByIdAsync(userId);
            if (user == null)
            {
                return NotFound(new ApiResponse<object>
                {
                    Success = false,
                    Message = "User not found"
                });
            }

            var userProfile = new
            {
                Id = user.Id,
                Username = user.Username,
                Email = user.Email,
                Roles = user.Roles,
                CreatedAt = user.CreatedAt
            };

            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Profile retrieved successfully",
                Data = userProfile
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving profile for user");
            return StatusCode(500, new ApiResponse<object>
            {
                Success = false,
                Message = "An error occurred while retrieving profile"
            });
        }
    }
}
