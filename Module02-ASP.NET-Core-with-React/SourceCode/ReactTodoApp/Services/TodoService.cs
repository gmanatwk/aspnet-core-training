using ReactTodoApp.Models;

namespace ReactTodoApp.Services;

/// <summary>
/// In-memory Todo service implementation for Module 02
/// In a real application, this would use a database
/// </summary>
public class TodoService : ITodoService
{
    private static readonly List<Todo> _todos = new()
    {
        new Todo 
        { 
            Id = 1, 
            Title = "Learn React Basics", 
            Description = "Complete React fundamentals tutorial",
            IsCompleted = true, 
            CreatedAt = DateTime.UtcNow.AddDays(-5),
            CompletedAt = DateTime.UtcNow.AddDays(-2),
            Priority = TodoPriority.High,
            Category = "Learning"
        },
        new Todo 
        { 
            Id = 2, 
            Title = "Build ASP.NET Core API", 
            Description = "Create RESTful API with CRUD operations",
            IsCompleted = true, 
            CreatedAt = DateTime.UtcNow.AddDays(-4),
            CompletedAt = DateTime.UtcNow.AddDays(-1),
            Priority = TodoPriority.High,
            Category = "Development"
        },
        new Todo 
        { 
            Id = 3, 
            Title = "Integrate React with ASP.NET Core", 
            Description = "Set up SPA services and proxy configuration",
            IsCompleted = false, 
            CreatedAt = DateTime.UtcNow.AddDays(-3),
            Priority = TodoPriority.Medium,
            Category = "Development"
        },
        new Todo 
        { 
            Id = 4, 
            Title = "Add State Management", 
            Description = "Implement Redux or Context API for state management",
            IsCompleted = false, 
            CreatedAt = DateTime.UtcNow.AddDays(-2),
            Priority = TodoPriority.Medium,
            Category = "Development"
        },
        new Todo 
        { 
            Id = 5, 
            Title = "Implement Routing", 
            Description = "Add React Router for navigation",
            IsCompleted = false, 
            CreatedAt = DateTime.UtcNow.AddDays(-1),
            Priority = TodoPriority.Low,
            Category = "Development"
        },
        new Todo 
        { 
            Id = 6, 
            Title = "Docker Integration", 
            Description = "Containerize both frontend and backend",
            IsCompleted = false, 
            CreatedAt = DateTime.UtcNow,
            Priority = TodoPriority.Urgent,
            Category = "DevOps"
        }
    };

    private static int _nextId = 7;

    public Task<IEnumerable<Todo>> GetAllAsync(bool? completed = null, string? category = null, TodoPriority? priority = null)
    {
        var query = _todos.AsEnumerable();

        if (completed.HasValue)
        {
            query = query.Where(t => t.IsCompleted == completed.Value);
        }

        if (!string.IsNullOrEmpty(category))
        {
            query = query.Where(t => t.Category?.Equals(category, StringComparison.OrdinalIgnoreCase) == true);
        }

        if (priority.HasValue)
        {
            query = query.Where(t => t.Priority == priority.Value);
        }

        return Task.FromResult(query.OrderByDescending(t => t.CreatedAt).AsEnumerable());
    }

    public Task<Todo?> GetByIdAsync(int id)
    {
        var todo = _todos.FirstOrDefault(t => t.Id == id);
        return Task.FromResult(todo);
    }

    public Task<Todo> CreateAsync(Todo todo)
    {
        todo.Id = _nextId++;
        todo.CreatedAt = DateTime.UtcNow;
        todo.CompletedAt = null;
        
        _todos.Add(todo);
        return Task.FromResult(todo);
    }

    public Task<Todo?> UpdateAsync(Todo todo)
    {
        var existingTodo = _todos.FirstOrDefault(t => t.Id == todo.Id);
        if (existingTodo == null)
        {
            return Task.FromResult<Todo?>(null);
        }

        existingTodo.Title = todo.Title;
        existingTodo.Description = todo.Description;
        existingTodo.Priority = todo.Priority;
        existingTodo.Category = todo.Category;
        
        // Handle completion status change
        if (existingTodo.IsCompleted != todo.IsCompleted)
        {
            existingTodo.IsCompleted = todo.IsCompleted;
            existingTodo.CompletedAt = todo.IsCompleted ? DateTime.UtcNow : null;
        }

        return Task.FromResult<Todo?>(existingTodo);
    }

    public Task<bool> DeleteAsync(int id)
    {
        var todo = _todos.FirstOrDefault(t => t.Id == id);
        if (todo == null)
        {
            return Task.FromResult(false);
        }

        _todos.Remove(todo);
        return Task.FromResult(true);
    }

    public Task<Todo?> ToggleCompletionAsync(int id)
    {
        var todo = _todos.FirstOrDefault(t => t.Id == id);
        if (todo == null)
        {
            return Task.FromResult<Todo?>(null);
        }

        todo.IsCompleted = !todo.IsCompleted;
        todo.CompletedAt = todo.IsCompleted ? DateTime.UtcNow : null;

        return Task.FromResult<Todo?>(todo);
    }

    public Task<object> GetStatsAsync()
    {
        var stats = new
        {
            Total = _todos.Count,
            Completed = _todos.Count(t => t.IsCompleted),
            Pending = _todos.Count(t => !t.IsCompleted),
            ByPriority = _todos.GroupBy(t => t.Priority)
                .ToDictionary(g => g.Key.ToString(), g => g.Count()),
            ByCategory = _todos.Where(t => !string.IsNullOrEmpty(t.Category))
                .GroupBy(t => t.Category!)
                .ToDictionary(g => g.Key, g => g.Count()),
            CompletionRate = _todos.Count > 0 ? 
                Math.Round((double)_todos.Count(t => t.IsCompleted) / _todos.Count * 100, 1) : 0
        };

        return Task.FromResult<object>(stats);
    }
}
