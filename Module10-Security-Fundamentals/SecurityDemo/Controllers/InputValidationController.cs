using Microsoft.AspNetCore.Mvc;
using SecurityDemo.Models;
using System.ComponentModel.DataAnnotations;

namespace SecurityDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class InputValidationController : ControllerBase
{
    private readonly ILogger<InputValidationController> _logger;

    public InputValidationController(ILogger<InputValidationController> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// Test endpoint for secure user registration with validation
    /// </summary>
    [HttpPost("register")]
    public IActionResult RegisterUser([FromBody] SecureUserModel user)
    {
        _logger.LogInformation("User registration attempt for: {Username}", user.Username);

        if (!ModelState.IsValid)
        {
            return BadRequest(new
            {
                Message = "Validation failed",
                Errors = ModelState.Where(x => x.Value?.Errors.Count > 0)
                    .ToDictionary(
                        kvp => kvp.Key,
                        kvp => kvp.Value?.Errors.Select(e => e.ErrorMessage).ToArray()
                    ),
                Timestamp = DateTime.UtcNow
            });
        }

        return Ok(new
        {
            Message = "User registration successful",
            Username = user.Username,
            Email = user.Email,
            Age = user.Age,
            Website = user.Website,
            Timestamp = DateTime.UtcNow,
            SecurityNote = "All inputs validated successfully"
        });
    }

    /// <summary>
    /// Test endpoint for SQL injection prevention
    /// </summary>
    [HttpGet("search")]
    public IActionResult SearchUsers([FromQuery] string query = "")
    {
        _logger.LogInformation("User search requested with query: {Query}", query);

        // Simulate safe search (in real app, use parameterized queries)
        var safeQuery = query.Replace("'", "''"); // Basic SQL injection prevention

        return Ok(new
        {
            Message = "Search completed safely",
            Query = query,
            SafeQuery = safeQuery,
            Results = new[]
            {
                new { Id = 1, Username = "john_doe", Email = "john@example.com" },
                new { Id = 2, Username = "jane_smith", Email = "jane@example.com" }
            },
            Timestamp = DateTime.UtcNow,
            SecurityNote = "Query parameters are safely handled"
        });
    }

    /// <summary>
    /// Test endpoint for XSS prevention in comments
    /// </summary>
    [HttpPost("comment")]
    public IActionResult AddComment([FromBody] CommentModel comment)
    {
        _logger.LogInformation("Comment submission from: {Author}", comment.Author);

        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        return Ok(new
        {
            Message = "Comment added successfully",
            Author = comment.Author,
            Content = comment.Content, // ASP.NET Core automatically encodes this
            Timestamp = DateTime.UtcNow,
            SecurityNote = "Content is automatically encoded to prevent XSS"
        });
    }
}

public class CommentModel
{
    [Required]
    [StringLength(100)]
    public string Author { get; set; } = string.Empty;

    [Required]
    [StringLength(1000)]
    public string Content { get; set; } = string.Empty;
}
