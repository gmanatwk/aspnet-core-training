using System.ComponentModel.DataAnnotations;

namespace ReactTodoApp.Models;

/// <summary>
/// Todo model for Module 02 - ASP.NET Core with React
/// Represents a todo item with validation attributes
/// </summary>
public class Todo
{
    public int Id { get; set; }

    [Required(ErrorMessage = "Title is required")]
    [StringLength(200, ErrorMessage = "Title cannot exceed 200 characters")]
    public string Title { get; set; } = string.Empty;

    public bool IsCompleted { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? CompletedAt { get; set; }

    [StringLength(500, ErrorMessage = "Description cannot exceed 500 characters")]
    public string? Description { get; set; }

    public TodoPriority Priority { get; set; } = TodoPriority.Medium;

    public string? Category { get; set; }

    // Computed properties for API responses
    public string Status => IsCompleted ? "Completed" : "Pending";
    
    public int DaysOld => (DateTime.UtcNow - CreatedAt).Days;
}

/// <summary>
/// Priority levels for todos
/// </summary>
public enum TodoPriority
{
    Low = 1,
    Medium = 2,
    High = 3,
    Urgent = 4
}
