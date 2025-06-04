import React, { createContext, useContext, useState, useEffect, type ReactNode } from 'react';
import { type Todo, todoService } from '../services/todoService';

interface TodoContextType {
  todos: Todo[];
  loading: boolean;
  error: string | null;
  addTodo: (title: string) => Promise<void>;
  updateTodo: (id: number, todo: Todo) => Promise<void>;
  deleteTodo: (id: number) => Promise<void>;
  toggleTodo: (id: number) => Promise<void>;
  refreshTodos: () => Promise<void>;
}

const TodoContext = createContext<TodoContextType | undefined>(undefined);

export const useTodos = () => {
  const context = useContext(TodoContext);
  if (!context) {
    throw new Error('useTodos must be used within a TodoProvider');
  }
  return context;
};

interface TodoProviderProps {
  children: ReactNode;
}

export const TodoProvider: React.FC<TodoProviderProps> = ({ children }) => {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    refreshTodos();
  }, []);

  const refreshTodos = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await todoService.getAll();
      setTodos(data);
    } catch (err) {
      setError('Failed to load todos');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const addTodo = async (title: string) => {
    try {
      const newTodo: Todo = {
        title,
        isCompleted: false
      };
      const created = await todoService.create(newTodo);
      setTodos(prevTodos => [...prevTodos, created]);
    } catch (err) {
      setError('Failed to add todo');
      throw err;
    }
  };

  const updateTodo = async (id: number, todo: Todo) => {
    try {
      await todoService.update(id, todo);
      setTodos(prevTodos => 
        prevTodos.map(t => t.id === id ? { ...t, ...todo } : t)
      );
    } catch (err) {
      setError('Failed to update todo');
      throw err;
    }
  };

  const deleteTodo = async (id: number) => {
    try {
      await todoService.delete(id);
      setTodos(prevTodos => prevTodos.filter(t => t.id !== id));
    } catch (err) {
      setError('Failed to delete todo');
      throw err;
    }
  };

  const toggleTodo = async (id: number) => {
    const todo = todos.find(t => t.id === id);
    if (!todo) return;

    await updateTodo(id, { ...todo, isCompleted: !todo.isCompleted });
  };

  const value: TodoContextType = {
    todos,
    loading,
    error,
    addTodo,
    updateTodo,
    deleteTodo,
    toggleTodo,
    refreshTodos
  };

  return <TodoContext.Provider value={value}>{children}</TodoContext.Provider>;
};