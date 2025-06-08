using Microsoft.AspNetCore.Mvc;
using DebuggingDemo.Models;

namespace DebuggingDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TestController : ControllerBase
{
    private readonly ILogger<TestController> _logger;
    private static readonly List<User> _users = new();
    private static readonly List<Order> _orders = new();

    public TestController(ILogger<TestController> logger)
    {
        _logger = logger;
        InitializeTestData();
    }

    /// <summary>
    /// Get all users - Practice basic debugging
    /// </summary>
    [HttpGet("users")]
    public ActionResult<IEnumerable<User>> GetUsers()
    {
        _logger.LogInformation("Getting all users");

        // TODO: Set a breakpoint here and inspect the _users collection
        var activeUsers = _users.Where(u => u.IsActive).ToList();

        return Ok(activeUsers);
    }

    /// <summary>
    /// Get user by ID - Practice conditional debugging
    /// </summary>
    [HttpGet("users/{id}")]
    public ActionResult<User> GetUser(int id)
    {
        _logger.LogInformation("Getting user with ID: {UserId}", id);

        // TODO: Set a conditional breakpoint here (id == 2)
        var user = _users.FirstOrDefault(u => u.Id == id);

        if (user == null)
        {
            _logger.LogWarning("User not found: {UserId}", id);
            return NotFound($"User with ID {id} not found");
        }

        return Ok(user);
    }

    /// <summary>
    /// Create user - Practice exception debugging
    /// </summary>
    [HttpPost("users")]
    public ActionResult<User> CreateUser([FromBody] User user)
    {
        try
        {
            _logger.LogInformation("Creating user: {UserName}", user.Name);

            // TODO: This method has a potential null reference bug
            // Practice debugging exceptions
            if (string.IsNullOrEmpty(user.Name))
            {
                throw new ArgumentException("User name cannot be empty");
            }

            user.Id = _users.Count + 1;
            user.CreatedAt = DateTime.UtcNow;
            _users.Add(user);

            return CreatedAtAction(nameof(GetUser), new { id = user.Id }, user);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating user");
            return BadRequest($"Error creating user: {ex.Message}");
        }
    }

    /// <summary>
    /// Calculate order total - Practice debugging calculations
    /// </summary>
    [HttpPost("orders/calculate")]
    public ActionResult<decimal> CalculateOrderTotal([FromBody] Order order)
    {
        try
        {
            _logger.LogInformation("Calculating total for order with {ItemCount} items", order.Items.Count);

            // TODO: Step through this calculation and find the bug
            var total = order.CalculateTotal();

            // TODO: Set a watch on the total variable
            order.Total = total;

            return Ok(new { OrderId = order.Id, Total = total });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error calculating order total");
            return BadRequest($"Calculation error: {ex.Message}");
        }
    }

    /// <summary>
    /// Simulate slow operation - Practice performance debugging
    /// </summary>
    [HttpGet("slow-operation")]
    public async Task<ActionResult> SlowOperation()
    {
        _logger.LogInformation("Starting slow operation");

        // TODO: Use debugging tools to measure performance
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();

        // Simulate slow work
        await Task.Delay(2000);

        stopwatch.Stop();
        _logger.LogInformation("Slow operation completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);

        return Ok(new { Message = "Operation completed", ElapsedMs = stopwatch.ElapsedMilliseconds });
    }

    private void InitializeTestData()
    {
        if (!_users.Any())
        {
            _users.AddRange(new[]
            {
                new User { Id = 1, Name = "John Doe", Email = "john@example.com", IsActive = true, CreatedAt = DateTime.UtcNow.AddDays(-10) },
                new User { Id = 2, Name = "Jane Smith", Email = "jane@example.com", IsActive = true, CreatedAt = DateTime.UtcNow.AddDays(-5) },
                new User { Id = 3, Name = "Bob Johnson", Email = "bob@example.com", IsActive = false, CreatedAt = DateTime.UtcNow.AddDays(-15) }
            });
        }
    }
}
