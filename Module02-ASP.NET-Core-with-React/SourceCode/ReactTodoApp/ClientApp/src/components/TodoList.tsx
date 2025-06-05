import React, { useState, useEffect } from 'react';
import { Todo, TodoPriority, TodoFilters } from '../types/Todo';
import { todoService } from '../services/todoService';
import TodoItem from './TodoItem';
import TodoForm from './TodoForm';

const TodoList: React.FC = () => {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filters, setFilters] = useState<TodoFilters>({});

  useEffect(() => {
    loadTodos();
  }, [filters]);

  const loadTodos = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await todoService.getAll(filters);
      setTodos(data);
    } catch (err) {
      setError('Failed to load todos. Please try again.');
      console.error('Error loading todos:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleAddTodo = async (todoData: Omit<Todo, 'id' | 'createdAt' | 'completedAt' | 'status' | 'daysOld'>) => {
    try {
      const newTodo = await todoService.create(todoData);
      setTodos(prevTodos => [newTodo, ...prevTodos]);
      return true;
    } catch (err) {
      setError('Failed to add todo. Please try again.');
      console.error('Error adding todo:', err);
      return false;
    }
  };

  const handleToggleTodo = async (id: number) => {
    try {
      const updatedTodo = await todoService.toggle(id);
      setTodos(prevTodos =>
        prevTodos.map(todo =>
          todo.id === id ? updatedTodo : todo
        )
      );
    } catch (err) {
      setError('Failed to update todo. Please try again.');
      console.error('Error toggling todo:', err);
    }
  };

  const handleDeleteTodo = async (id: number) => {
    try {
      await todoService.delete(id);
      setTodos(prevTodos => prevTodos.filter(todo => todo.id !== id));
    } catch (err) {
      setError('Failed to delete todo. Please try again.');
      console.error('Error deleting todo:', err);
    }
  };

  const handleFilterChange = (newFilters: Partial<TodoFilters>) => {
    setFilters(prev => ({ ...prev, ...newFilters }));
  };

  const clearFilters = () => {
    setFilters({});
  };

  const getFilteredTodosCount = () => {
    return {
      total: todos.length,
      completed: todos.filter(t => t.isCompleted).length,
      pending: todos.filter(t => !t.isCompleted).length
    };
  };

  const counts = getFilteredTodosCount();

  if (loading) {
    return <div className="loading">Loading todos...</div>;
  }

  return (
    <div className="todo-container">
      <div className="todo-header">
        <h2>My Todos</h2>
        <div className="filters">
          <select
            className="filter-select"
            value={filters.completed?.toString() || ''}
            onChange={(e) => {
              const value = e.target.value;
              handleFilterChange({
                completed: value === '' ? undefined : value === 'true'
              });
            }}
            aria-label="Filter by completion status"
            title="Filter todos by completion status"
          >
            <option value="">All Status</option>
            <option value="false">Pending</option>
            <option value="true">Completed</option>
          </select>

          <select
            className="filter-select"
            value={filters.priority?.toString() || ''}
            onChange={(e) => {
              const value = e.target.value;
              handleFilterChange({
                priority: value === '' ? undefined : parseInt(value) as TodoPriority
              });
            }}
            aria-label="Filter by priority level"
            title="Filter todos by priority level"
          >
            <option value="">All Priorities</option>
            <option value={TodoPriority.Low}>Low</option>
            <option value={TodoPriority.Medium}>Medium</option>
            <option value={TodoPriority.High}>High</option>
            <option value={TodoPriority.Urgent}>Urgent</option>
          </select>

          <input
            type="text"
            className="filter-select"
            placeholder="Filter by category"
            value={filters.category || ''}
            onChange={(e) => handleFilterChange({ category: e.target.value || undefined })}
            aria-label="Filter by category"
            title="Filter todos by category"
          />

          {(filters.completed !== undefined || filters.priority !== undefined || filters.category) && (
            <button type="button" onClick={clearFilters} className="action-button">
              Clear Filters
            </button>
          )}
        </div>
      </div>

      {error && (
        <div className="error">
          {error}
          <button
            type="button"
            onClick={() => setError(null)}
            className="error-close-button"
            aria-label="Close error message"
            title="Close error message"
          >
            ×
          </button>
        </div>
      )}

      <TodoForm onSubmit={handleAddTodo} />

      <div className="todo-stats">
        <p>
          Showing {counts.total} todos: {counts.pending} pending, {counts.completed} completed
        </p>
      </div>

      {todos.length === 0 ? (
        <div className="empty-state">
          <h3>No todos found</h3>
          <p>
            {Object.keys(filters).length > 0
              ? 'Try adjusting your filters or add a new todo.'
              : 'Add your first todo to get started!'}
          </p>
        </div>
      ) : (
        <div className="todo-list">
          {todos.map(todo => (
            <TodoItem
              key={todo.id}
              todo={todo}
              onToggle={handleToggleTodo}
              onDelete={handleDeleteTodo}
            />
          ))}
        </div>
      )}
    </div>
  );
};

export default TodoList;
