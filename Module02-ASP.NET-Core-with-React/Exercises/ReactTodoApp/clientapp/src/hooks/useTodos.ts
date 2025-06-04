import { useState, useEffect, useCallback } from 'react';
import { type Todo, type TodoStats, todoService } from '../services/todoService';
import cacheService from '../services/cacheService';

interface UseTodosResult {
  todos: Todo[];
  stats: TodoStats | null;
  loading: boolean;
  error: string | null;
  refetch: () => Promise<void>;
  createTodo: (title: string) => Promise<void>;
  updateTodo: (id: number, updates: Partial<Todo>) => Promise<void>;
  deleteTodo: (id: number) => Promise<void>;
  bulkDelete: (ids: number[]) => Promise<void>;
  bulkComplete: (ids: number[]) => Promise<void>;
}

export function useTodos(): UseTodosResult {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [stats, setStats] = useState<TodoStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const CACHE_KEY = 'todos-list';
  const STATS_CACHE_KEY = 'todos-stats';

  const fetchTodos = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      // Check cache first
      const cachedTodos = cacheService.get<Todo[]>(CACHE_KEY);
      if (cachedTodos) {
        setTodos(cachedTodos);
        setLoading(false);
      }

      // Fetch fresh data
      const [todosData, statsData] = await Promise.all([
        todoService.getAll(),
        todoService.getStats(),
      ]);

      setTodos(todosData);
      setStats(statsData);
      
      // Update cache
      cacheService.set(CACHE_KEY, todosData, 300); // 5 minutes
      cacheService.set(STATS_CACHE_KEY, statsData, 300);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch todos');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchTodos();
  }, [fetchTodos]);

  const createTodo = useCallback(async (title: string) => {
    // Optimistic update
    const tempId = -Date.now();
    const tempTodo: Todo = {
      id: tempId,
      title,
      isCompleted: false,
      createdAt: new Date().toISOString(),
    };

    setTodos(prev => [...prev, tempTodo]);

    try {
      const newTodo = await todoService.create({ title, isCompleted: false });
      setTodos(prev => prev.map(t => t.id === tempId ? newTodo : t));
      
      // Update stats
      setStats(prev => prev ? { ...prev, total: prev.total + 1, active: prev.active + 1 } : null);
      
      // Invalidate cache
      cacheService.invalidate(CACHE_KEY);
      cacheService.invalidate(STATS_CACHE_KEY);
    } catch (err: any) {
      // Revert optimistic update
      setTodos(prev => prev.filter(t => t.id !== tempId));
      throw err;
    }
  }, []);

  const updateTodo = useCallback(async (id: number, updates: Partial<Todo>) => {
    // Optimistic update
    const originalTodos = [...todos];
    setTodos(prev => prev.map(t => t.id === id ? { ...t, ...updates } : t));

    try {
      await todoService.update(id, updates);
      
      // Update stats if completion status changed
      if ('isCompleted' in updates) {
        setStats(prev => {
          if (!prev) return null;
          const delta = updates.isCompleted ? 1 : -1;
          return {
            ...prev,
            completed: prev.completed + delta,
            active: prev.active - delta,
          };
        });
      }

      // Invalidate cache
      cacheService.invalidate(CACHE_KEY);
      cacheService.invalidate(STATS_CACHE_KEY);
    } catch (err: any) {
      // Revert optimistic update
      setTodos(originalTodos);
      throw err;
    }
  }, [todos]);

  const deleteTodo = useCallback(async (id: number) => {
    // Optimistic update
    const todoToDelete = todos.find(t => t.id === id);
    if (!todoToDelete) return;

    setTodos(prev => prev.filter(t => t.id !== id));

    try {
      await todoService.delete(id);
      
      // Update stats
      setStats(prev => {
        if (!prev) return null;
        return {
          ...prev,
          total: prev.total - 1,
          completed: todoToDelete.isCompleted ? prev.completed - 1 : prev.completed,
          active: !todoToDelete.isCompleted ? prev.active - 1 : prev.active,
        };
      });

      // Invalidate cache
      cacheService.invalidate(CACHE_KEY);
      cacheService.invalidate(STATS_CACHE_KEY);
    } catch (err: any) {
      // Revert optimistic update
      setTodos(prev => [...prev, todoToDelete].sort((a, b) => (a.id || 0) - (b.id || 0)));
      throw err;
    }
  }, [todos]);

  const bulkDelete = useCallback(async (ids: number[]) => {
    const originalTodos = [...todos];
    setTodos(prev => prev.filter(t => !ids.includes(t.id!)));

    try {
      await todoService.bulkDelete(ids);
      cacheService.invalidate(CACHE_KEY);
      cacheService.invalidate(STATS_CACHE_KEY);
      await fetchTodos(); // Refetch to get updated stats
    } catch (err: any) {
      setTodos(originalTodos);
      throw err;
    }
  }, [todos, fetchTodos]);

  const bulkComplete = useCallback(async (ids: number[]) => {
    const originalTodos = [...todos];
    setTodos(prev => prev.map(t => ids.includes(t.id!) ? { ...t, isCompleted: true } : t));

    try {
      await todoService.bulkComplete(ids);
      cacheService.invalidate(CACHE_KEY);
      cacheService.invalidate(STATS_CACHE_KEY);
      await fetchTodos(); // Refetch to get updated stats
    } catch (err: any) {
      setTodos(originalTodos);
      throw err;
    }
  }, [todos, fetchTodos]);

  return {
    todos,
    stats,
    loading,
    error,
    refetch: fetchTodos,
    createTodo,
    updateTodo,
    deleteTodo,
    bulkDelete,
    bulkComplete,
  };
}