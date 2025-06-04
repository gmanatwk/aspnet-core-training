import React, { useState, useEffect } from 'react';
import { type Todo, todoService } from '../services/todoService';

const TodoApp: React.FC = () => {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [newTodo, setNewTodo] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadTodos();
  }, []);

  const loadTodos = async () => {
    try {
      setLoading(true);
      const data = await todoService.getAll();
      setTodos(data);
      setError(null);
    } catch (err) {
      setError('Failed to load todos');
      console.error('Error loading todos:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleAddTodo = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTodo.trim()) return;

    try {
      const todo = await todoService.create({
        title: newTodo,
        isCompleted: false,
      });
      setTodos([...todos, todo]);
      setNewTodo('');
    } catch (err) {
      setError('Failed to add todo');
      console.error('Error adding todo:', err);
    }
  };

  const handleToggleTodo = async (id: number) => {
    const todo = todos.find(t => t.id === id);
    if (!todo) return;

    try {
      await todoService.update(id, { isCompleted: !todo.isCompleted });
      setTodos(todos.map(t => 
        t.id === id ? { ...t, isCompleted: !t.isCompleted } : t
      ));
    } catch (err) {
      setError('Failed to update todo');
      console.error('Error updating todo:', err);
    }
  };

  const handleDeleteTodo = async (id: number) => {
    try {
      await todoService.delete(id);
      setTodos(todos.filter(t => t.id !== id));
    } catch (err) {
      setError('Failed to delete todo');
      console.error('Error deleting todo:', err);
    }
  };

  if (loading) return <div className="loading">Loading todos...</div>;

  return (
    <div className="todo-app">
      <h1>Docker Todo App</h1>
      
      {error && <div className="error">{error}</div>}
      
      <form onSubmit={handleAddTodo} className="add-todo-form">
        <input
          type="text"
          value={newTodo}
          onChange={(e) => setNewTodo(e.target.value)}
          placeholder="Add a new todo..."
          className="todo-input"
        />
        <button type="submit" className="add-button">Add Todo</button>
      </form>

      <div className="todo-list">
        {todos.map(todo => (
          <div key={todo.id} className={`todo-item ${todo.isCompleted ? 'completed' : ''}`}>
            <input
              type="checkbox"
              checked={todo.isCompleted}
              onChange={() => handleToggleTodo(todo.id!)}
            />
            <span className="todo-title">{todo.title}</span>
            <button 
              onClick={() => handleDeleteTodo(todo.id!)}
              className="delete-button"
            >
              Delete
            </button>
          </div>
        ))}
      </div>

      <div className="stats">
        <p>Total: {todos.length} | Completed: {todos.filter(t => t.isCompleted).length}</p>
      </div>
    </div>
  );
};

export default TodoApp;