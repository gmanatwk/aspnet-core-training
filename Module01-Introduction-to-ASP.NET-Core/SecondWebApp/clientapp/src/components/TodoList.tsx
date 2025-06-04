import React, { useState, useEffect } from 'react';
import { Todo, todoService } from '../services/todoService';

const TodoList: React.FC = () => {
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
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleAddTodo = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTodo.trim()) return;

    try {
      const todo: Todo = {
        title: newTodo,
        isCompleted: false
      };
      const created = await todoService.create(todo);
      setTodos([...todos, created]);
      setNewTodo('');
    } catch (err) {
      setError('Failed to add todo');
    }
  };

  const handleToggle = async (todo: Todo) => {
    try {
      const updated = { ...todo, isCompleted: !todo.isCompleted };
      await todoService.update(todo.id!, updated);
      setTodos(todos.map(t => t.id === todo.id ? updated : t));
    } catch (err) {
      setError('Failed to update todo');
    }
  };

  const handleDelete = async (id: number) => {
    try {
      await todoService.delete(id);
      setTodos(todos.filter(t => t.id !== id));
    } catch (err) {
      setError('Failed to delete todo');
    }
  };

  if (loading) return <div>Loading...</div>;
  if (error) return <div className="error">{error}</div>;

  return (
    <div className="todo-container">
      <h1>Todo List</h1>
      
      <form onSubmit={handleAddTodo} className="add-todo-form">
        <input
          type="text"
          value={newTodo}
          onChange={(e) => setNewTodo(e.target.value)}
          placeholder="Add a new todo..."
          className="todo-input"
        />
        <button type="submit" className="add-button">Add</button>
      </form>

      <ul className="todo-list">
        {todos.map(todo => (
          <li key={todo.id} className={`todo-item ${todo.isCompleted ? 'completed' : ''}`}>
            <input
              type="checkbox"
              checked={todo.isCompleted}
              onChange={() => handleToggle(todo)}
            />
            <span>{todo.title}</span>
            <button 
              onClick={() => handleDelete(todo.id!)}
              className="delete-button"
            >
              Delete
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default TodoList;
