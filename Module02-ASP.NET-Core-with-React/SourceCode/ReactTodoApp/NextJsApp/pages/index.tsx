import { useState, useEffect } from 'react';
import { GetServerSideProps } from 'next';
import Head from 'next/head';
import { todoApi } from '@/lib/api';
import { Todo, TodoFilters, TodoPriority } from '@/types/todo';
import TodoItem from '@/components/TodoItem';
import TodoForm from '@/components/TodoForm';

interface HomeProps {
  initialTodos: Todo[];
  renderTime: string;
}

export default function Home({ initialTodos, renderTime }: HomeProps) {
  const [todos, setTodos] = useState<Todo[]>(initialTodos);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [filters, setFilters] = useState<TodoFilters>({});

  // Load todos when filters change (client-side)
  useEffect(() => {
    if (Object.keys(filters).length > 0) {
      loadTodos();
    }
  }, [filters]);

  const loadTodos = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await todoApi.getAll(filters);
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
      const newTodo = await todoApi.create(todoData);
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
      const updatedTodo = await todoApi.toggle(id);
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
      await todoApi.delete(id);
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
    setTodos(initialTodos); // Reset to server-rendered data
  };

  const getFilteredTodosCount = () => {
    return {
      total: todos.length,
      completed: todos.filter(t => t.isCompleted).length,
      pending: todos.filter(t => !t.isCompleted).length
    };
  };

  const counts = getFilteredTodosCount();

  return (
    <>
      <Head>
        <title>Next.js Todo App - SSR Demo</title>
        <meta name="description" content="Server-side rendered Todo application with Next.js and ASP.NET Core" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>

      <div className="todo-container">
        <div className="ssr-info">
          <h1>📋 Todo List (Server-Side Rendered)</h1>
          <p className="render-info">
            🚀 <strong>SSR:</strong> This page was rendered on the server at <strong>{renderTime}</strong>
          </p>
          <p className="initial-data">
            📦 <strong>Initial Data:</strong> {initialTodos.length} todos loaded from server
          </p>
        </div>

        <div className="filters-section">
          <h3>Filters</h3>
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
            />

            {Object.keys(filters).length > 0 && (
              <button type="button" onClick={clearFilters} className="clear-filters-btn">
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
              className="error-close"
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
          {loading && <span className="loading-indicator">🔄 Loading...</span>}
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

      <style jsx>{`
        .todo-container {
          max-width: 800px;
          margin: 0 auto;
        }

        .ssr-info {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
          padding: 2rem;
          border-radius: 8px;
          margin-bottom: 2rem;
          text-align: center;
        }

        .ssr-info h1 {
          margin: 0 0 1rem 0;
          font-size: 2rem;
        }

        .render-info,
        .initial-data {
          margin: 0.5rem 0;
          font-size: 1rem;
        }

        .filters-section {
          background: white;
          padding: 1.5rem;
          border-radius: 8px;
          margin-bottom: 2rem;
          border: 1px solid #e1e5e9;
        }

        .filters-section h3 {
          margin: 0 0 1rem 0;
          color: #2c3e50;
        }

        .filters {
          display: flex;
          gap: 1rem;
          flex-wrap: wrap;
          align-items: center;
        }

        .filter-select {
          padding: 0.5rem;
          border: 1px solid #ced4da;
          border-radius: 4px;
          font-size: 0.9rem;
          min-width: 150px;
        }

        .clear-filters-btn {
          background: #6c757d;
          color: white;
          border: none;
          padding: 0.5rem 1rem;
          border-radius: 4px;
          cursor: pointer;
          font-size: 0.9rem;
        }

        .clear-filters-btn:hover {
          background: #5a6268;
        }

        .error {
          background: #f8d7da;
          color: #721c24;
          padding: 1rem;
          border-radius: 4px;
          margin-bottom: 1rem;
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .error-close {
          background: none;
          border: none;
          font-size: 1.5rem;
          cursor: pointer;
          color: #721c24;
        }

        .todo-stats {
          background: white;
          padding: 1rem;
          border-radius: 4px;
          margin-bottom: 1rem;
          display: flex;
          justify-content: space-between;
          align-items: center;
          border: 1px solid #e1e5e9;
        }

        .todo-stats p {
          margin: 0;
          color: #6c757d;
        }

        .loading-indicator {
          color: #007bff;
          font-weight: 500;
        }

        .empty-state {
          text-align: center;
          padding: 3rem 1rem;
          background: white;
          border-radius: 8px;
          border: 1px solid #e1e5e9;
        }

        .empty-state h3 {
          color: #6c757d;
          margin-bottom: 0.5rem;
        }

        .empty-state p {
          color: #6c757d;
          margin: 0;
        }

        .todo-list {
          display: flex;
          flex-direction: column;
          gap: 0.5rem;
        }

        @media (max-width: 768px) {
          .filters {
            flex-direction: column;
            align-items: stretch;
          }

          .filter-select {
            min-width: auto;
          }

          .todo-stats {
            flex-direction: column;
            gap: 0.5rem;
            text-align: center;
          }
        }
      `}</style>
    </>
  );
}

// This function runs on the server before the page is sent to the client
export const getServerSideProps: GetServerSideProps = async () => {
  try {
    // Fetch initial todos on the server
    const initialTodos = await todoApi.getAll();
    const renderTime = new Date().toISOString();

    return {
      props: {
        initialTodos,
        renderTime,
      },
    };
  } catch (error) {
    console.error('Error fetching initial todos:', error);
    
    return {
      props: {
        initialTodos: [],
        renderTime: new Date().toISOString(),
      },
    };
  }
};
