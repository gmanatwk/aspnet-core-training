using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using JwtAuthenticationAPI.Models;
using System.Security.Claims;

namespace JwtAuthenticationAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize] // All endpoints require authentication
public class SecureController : ControllerBase
{
    private readonly ILogger<SecureController> _logger;

    public SecureController(ILogger<SecureController> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// Get public data (accessible to any authenticated user)
    /// </summary>
    [HttpGet("public")]
    public IActionResult GetPublicData()
    {
        var username = User.FindFirst(ClaimTypes.Name)?.Value;
        var roles = User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();

        _logger.LogInformation("Public data accessed by user: {Username}", username);

        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Public data retrieved successfully",
            Data = new
            {
                Message = "This is public data accessible to any authenticated user",
                AccessedBy = username,
                UserRoles = roles,
                Timestamp = DateTime.UtcNow
            }
        });
    }

    /// <summary>
    /// Get user-specific data
    /// </summary>
    [HttpGet("user-data")]
    public IActionResult GetUserData()
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var username = User.FindFirst(ClaimTypes.Name)?.Value;
        var email = User.FindFirst(ClaimTypes.Email)?.Value;

        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "User data retrieved successfully",
            Data = new
            {
                UserId = userId,
                Username = username,
                Email = email,
                Message = "This is your personal data",
                LastAccessed = DateTime.UtcNow
            }
        });
    }

    /// <summary>
    /// Test endpoint to verify JWT token claims
    /// </summary>
    [HttpGet("claims")]
    public IActionResult GetClaims()
    {
        var claims = User.Claims.Select(c => new { c.Type, c.Value }).ToList();

        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Claims retrieved successfully",
            Data = new
            {
                Claims = claims,
                TotalClaims = claims.Count,
                Timestamp = DateTime.UtcNow
            }
        });
    }

    /// <summary>
    /// Admin-only endpoint (requires Admin role)
    /// </summary>
    [HttpGet("admin")]
    [Authorize(Roles = "Admin")]
    public IActionResult GetAdminData()
    {
        var username = User.FindFirst(ClaimTypes.Name)?.Value;

        _logger.LogInformation("Admin data accessed by user: {Username}", username);

        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Admin data retrieved successfully",
            Data = new
            {
                Message = "This is admin-only data",
                AccessedBy = username,
                AdminLevel = "Full Access",
                Timestamp = DateTime.UtcNow
            }
        });
    }

    /// <summary>
    /// Manager or Admin endpoint
    /// </summary>
    [HttpGet("manager")]
    [Authorize(Roles = "Manager,Admin")]
    public IActionResult GetManagerData()
    {
        var username = User.FindFirst(ClaimTypes.Name)?.Value;
        var roles = User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();

        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Manager data retrieved successfully",
            Data = new
            {
                Message = "This data is accessible to Managers and Admins",
                AccessedBy = username,
                UserRoles = roles,
                AccessLevel = "Management",
                Timestamp = DateTime.UtcNow
            }
        });
    }
}
