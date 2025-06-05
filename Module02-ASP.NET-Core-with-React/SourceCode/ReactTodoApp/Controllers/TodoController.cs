using Microsoft.AspNetCore.Mvc;
using ReactTodoApp.Models;
using ReactTodoApp.Services;

namespace ReactTodoApp.Controllers;

/// <summary>
/// Todo API Controller for Module 02 - ASP.NET Core with React
/// Provides full CRUD operations for Todo items
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class TodoController : ControllerBase
{
    private readonly ITodoService _todoService;
    private readonly ILogger<TodoController> _logger;

    public TodoController(ITodoService todoService, ILogger<TodoController> logger)
    {
        _todoService = todoService;
        _logger = logger;
    }

    /// <summary>
    /// Get all todos with optional filtering
    /// </summary>
    /// <param name="completed">Filter by completion status</param>
    /// <param name="category">Filter by category</param>
    /// <param name="priority">Filter by priority</param>
    /// <returns>List of todos</returns>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Todo>>> GetTodos(
        [FromQuery] bool? completed = null,
        [FromQuery] string? category = null,
        [FromQuery] TodoPriority? priority = null)
    {
        try
        {
            _logger.LogInformation("Retrieving todos with filters - Completed: {Completed}, Category: {Category}, Priority: {Priority}", 
                completed, category, priority);

            var todos = await _todoService.GetAllAsync(completed, category, priority);
            return Ok(todos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving todos");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get todo by ID
    /// </summary>
    /// <param name="id">Todo ID</param>
    /// <returns>Todo details</returns>
    [HttpGet("{id}")]
    public async Task<ActionResult<Todo>> GetTodo(int id)
    {
        try
        {
            _logger.LogInformation("Retrieving todo with ID: {TodoId}", id);
            var todo = await _todoService.GetByIdAsync(id);

            if (todo == null)
            {
                _logger.LogWarning("Todo with ID {TodoId} not found", id);
                return NotFound($"Todo with ID {id} not found");
            }

            return Ok(todo);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving todo {TodoId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Create a new todo
    /// </summary>
    /// <param name="todo">Todo to create</param>
    /// <returns>Created todo</returns>
    [HttpPost]
    public async Task<ActionResult<Todo>> CreateTodo([FromBody] Todo todo)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            _logger.LogInformation("Creating new todo: {TodoTitle}", todo.Title);
            
            var createdTodo = await _todoService.CreateAsync(todo);
            return CreatedAtAction(nameof(GetTodo), new { id = createdTodo.Id }, createdTodo);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating todo");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Update an existing todo
    /// </summary>
    /// <param name="id">Todo ID</param>
    /// <param name="todo">Updated todo data</param>
    /// <returns>Updated todo</returns>
    [HttpPut("{id}")]
    public async Task<ActionResult<Todo>> UpdateTodo(int id, [FromBody] Todo todo)
    {
        try
        {
            if (id != todo.Id)
            {
                return BadRequest("ID mismatch");
            }

            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            _logger.LogInformation("Updating todo with ID: {TodoId}", id);

            var updatedTodo = await _todoService.UpdateAsync(todo);
            if (updatedTodo == null)
            {
                return NotFound($"Todo with ID {id} not found");
            }

            return Ok(updatedTodo);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating todo {TodoId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Delete a todo
    /// </summary>
    /// <param name="id">Todo ID</param>
    /// <returns>Success message</returns>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteTodo(int id)
    {
        try
        {
            _logger.LogInformation("Deleting todo with ID: {TodoId}", id);

            var success = await _todoService.DeleteAsync(id);
            if (!success)
            {
                return NotFound($"Todo with ID {id} not found");
            }

            return Ok($"Todo with ID {id} deleted successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting todo {TodoId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Toggle todo completion status
    /// </summary>
    /// <param name="id">Todo ID</param>
    /// <returns>Updated todo</returns>
    [HttpPatch("{id}/toggle")]
    public async Task<ActionResult<Todo>> ToggleTodo(int id)
    {
        try
        {
            _logger.LogInformation("Toggling completion status for todo ID: {TodoId}", id);

            var updatedTodo = await _todoService.ToggleCompletionAsync(id);
            if (updatedTodo == null)
            {
                return NotFound($"Todo with ID {id} not found");
            }

            return Ok(updatedTodo);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error toggling todo {TodoId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get todo statistics
    /// </summary>
    /// <returns>Todo statistics</returns>
    [HttpGet("stats")]
    public async Task<ActionResult<object>> GetStats()
    {
        try
        {
            _logger.LogInformation("Retrieving todo statistics");
            var stats = await _todoService.GetStatsAsync();
            return Ok(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving todo statistics");
            return StatusCode(500, "Internal server error");
        }
    }
}
