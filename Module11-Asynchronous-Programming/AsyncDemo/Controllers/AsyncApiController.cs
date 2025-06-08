using Microsoft.AspNetCore.Mvc;
using AsyncDemo.Services;
using AsyncDemo.Models;
using AsyncDemo.Data;
using Microsoft.EntityFrameworkCore;

namespace AsyncDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AsyncApiController : ControllerBase
{
    private readonly IAsyncBasicsService _asyncService;
    private readonly IAsyncDataService _dataService;
    private readonly ILogger<AsyncApiController> _logger;

    public AsyncApiController(
        IAsyncBasicsService asyncService,
        IAsyncDataService dataService,
        ILogger<AsyncApiController> logger)
    {
        _asyncService = asyncService;
        _dataService = dataService;
        _logger = logger;
    }

    /// <summary>
    /// Basic async endpoint
    /// </summary>
    [HttpGet("basic")]
    public async Task<ActionResult<string>> GetBasicDataAsync()
    {
        try
        {
            var result = await _asyncService.GetDataAsync();
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetBasicDataAsync");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Async endpoint with multiple concurrent operations
    /// </summary>
    [HttpGet("multiple")]
    public async Task<ActionResult<List<string>>> GetMultipleDataAsync()
    {
        try
        {
            var results = await _asyncService.GetMultipleDataAsync();
            return Ok(results);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetMultipleDataAsync");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Async endpoint with timeout
    /// </summary>
    [HttpGet("timeout/{timeoutMs}")]
    public async Task<ActionResult<string>> GetDataWithTimeoutAsync(int timeoutMs)
    {
        try
        {
            var result = await _asyncService.GetDataWithTimeoutAsync(timeoutMs);
            return Ok(result);
        }
        catch (TimeoutException ex)
        {
            _logger.LogWarning(ex, "Timeout in GetDataWithTimeoutAsync");
            return StatusCode(408, "Request timeout");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetDataWithTimeoutAsync");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Async database operations
    /// </summary>
    [HttpGet("users")]
    public async Task<ActionResult<List<User>>> GetUsersAsync()
    {
        try
        {
            var users = await _dataService.GetAllUsersAsync();
            return Ok(users);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetUsersAsync");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Async POST endpoint
    /// </summary>
    [HttpPost("users")]
    public async Task<ActionResult<User>> CreateUserAsync([FromBody] CreateUserRequest request)
    {
        try
        {
            var user = await _dataService.CreateUserAsync(request.Name, request.Email);
            return CreatedAtAction(nameof(GetUserAsync), new { id = user.Id }, user);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in CreateUserAsync");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Async GET by ID endpoint
    /// </summary>
    [HttpGet("users/{id}")]
    public async Task<ActionResult<User>> GetUserAsync(int id)
    {
        try
        {
            var user = await _dataService.GetUserByIdAsync(id);
            if (user == null)
            {
                return NotFound();
            }
            return Ok(user);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetUserAsync");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Async external API call
    /// </summary>
    [HttpGet("external/{userId}")]
    public async Task<ActionResult<object>> GetExternalDataAsync(int userId)
    {
        try
        {
            var externalData = await _dataService.GetExternalUserDataAsync(userId);
            return Ok(externalData);
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "External API error in GetExternalDataAsync");
            return StatusCode(502, "External service unavailable");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetExternalDataAsync");
            return StatusCode(500, "Internal server error");
        }
    }
}

public record CreateUserRequest(string Name, string Email);
