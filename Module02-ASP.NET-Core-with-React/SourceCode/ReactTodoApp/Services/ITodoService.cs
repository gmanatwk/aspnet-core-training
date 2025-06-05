using ReactTodoApp.Models;

namespace ReactTodoApp.Services;

/// <summary>
/// Interface for Todo service operations
/// </summary>
public interface ITodoService
{
    Task<IEnumerable<Todo>> GetAllAsync(bool? completed = null, string? category = null, TodoPriority? priority = null);
    Task<Todo?> GetByIdAsync(int id);
    Task<Todo> CreateAsync(Todo todo);
    Task<Todo?> UpdateAsync(Todo todo);
    Task<bool> DeleteAsync(int id);
    Task<Todo?> ToggleCompletionAsync(int id);
    Task<object> GetStatsAsync();
}
