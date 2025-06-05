using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using JwtAuthenticationAPI.Models;

namespace JwtAuthenticationAPI.Controllers;

/// <summary>
/// Editor endpoints from Exercise 02
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class EditorController : ControllerBase
{
    /// <summary>
    /// Content management - Editor or Admin access
    /// </summary>
    [HttpGet("content")]
    [Authorize(Policy = "EditorOrAdmin")]
    public IActionResult GetContent()
    {
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Content Management Data",
            Data = new
            {
                Articles = new[]
                {
                    new { Id = 1, Title = "Getting Started with JWT", Status = "Published" },
                    new { Id = 2, Title = "Role-Based Authorization", Status = "Draft" },
                    new { Id = 3, Title = "Custom Policies", Status = "Review" }
                },
                CanPublish = User.IsInRole("Editor") || User.IsInRole("Admin"),
                CanDelete = User.IsInRole("Admin")
            }
        });
    }
    
    /// <summary>
    /// Create content - requires Editor role
    /// </summary>
    [HttpPost("content")]
    [Authorize(Roles = "Editor,Admin")]
    public IActionResult CreateContent([FromBody] object content)
    {
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "Content created successfully",
            Data = new { Id = 4, CreatedAt = DateTime.UtcNow }
        });
    }
}