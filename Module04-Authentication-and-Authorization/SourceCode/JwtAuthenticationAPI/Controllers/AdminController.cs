using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using JwtAuthenticationAPI.Models;

namespace JwtAuthenticationAPI.Controllers;

/// <summary>
/// Admin-only endpoints from Exercise 02
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class AdminController : ControllerBase
{
    /// <summary>
    /// Admin dashboard - requires Admin role
    /// </summary>
    [HttpGet("dashboard")]
    [Authorize(Roles = "Admin")]
    public IActionResult GetDashboard()
    {
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Admin Dashboard Data",
            Data = new
            {
                TotalUsers = 150,
                ActiveSessions = 45,
                SystemHealth = "Good",
                LastBackup = DateTime.UtcNow.AddHours(-2)
            }
        });
    }
    
    /// <summary>
    /// Get all users - Admin only policy
    /// </summary>
    [HttpGet("users")]
    [Authorize(Policy = "AdminOnly")]
    public IActionResult GetAllUsers()
    {
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "List of all users",
            Data = new[]
            {
                new { Id = 1, Username = "admin", Role = "Admin", LastLogin = DateTime.UtcNow.AddMinutes(-30) },
                new { Id = 2, Username = "editor", Role = "Editor", LastLogin = DateTime.UtcNow.AddHours(-1) },
                new { Id = 3, Username = "user", Role = "User", LastLogin = DateTime.UtcNow.AddDays(-1) }
            }
        });
    }
}