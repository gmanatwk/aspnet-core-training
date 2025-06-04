import React, { useState } from 'react';
import { useTodos } from '../context/TodoContext';

const TodosPage: React.FC = () => {
  const { todos, loading, error, addTodo, toggleTodo, deleteTodo } = useTodos();
  const [newTodoTitle, setNewTodoTitle] = useState('');
  const [filter, setFilter] = useState<'all' | 'active' | 'completed'>('all');

  const handleAddTodo = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTodoTitle.trim()) return;
    
    try {
      await addTodo(newTodoTitle);
      setNewTodoTitle('');
    } catch (err) {
      console.error('Failed to add todo:', err);
    }
  };

  const filteredTodos = todos.filter(todo => {
    if (filter === 'active') return !todo.isCompleted;
    if (filter === 'completed') return todo.isCompleted;
    return true;
  });

  if (loading) return <div className="loading">Loading todos...</div>;
  if (error) return <div className="error">{error}</div>;

  return (
    <div className="todos-page">
      <h2>My Todos</h2>
      
      <form onSubmit={handleAddTodo} className="add-todo-form">
        <input
          type="text"
          value={newTodoTitle}
          onChange={(e) => setNewTodoTitle(e.target.value)}
          placeholder="What needs to be done?"
          className="todo-input"
        />
        <button type="submit" className="add-button">
          Add Todo
        </button>
      </form>

      <div className="filter-buttons">
        <button
          className={filter === 'all' ? 'active' : ''}
          onClick={() => setFilter('all')}
        >
          All ({todos.length})
        </button>
        <button
          className={filter === 'active' ? 'active' : ''}
          onClick={() => setFilter('active')}
        >
          Active ({todos.filter(t => !t.isCompleted).length})
        </button>
        <button
          className={filter === 'completed' ? 'active' : ''}
          onClick={() => setFilter('completed')}
        >
          Completed ({todos.filter(t => t.isCompleted).length})
        </button>
      </div>

      <ul className="todo-list">
        {filteredTodos.map(todo => (
          <li key={todo.id} className={`todo-item ${todo.isCompleted ? 'completed' : ''}`}>
            <input
              type="checkbox"
              checked={todo.isCompleted}
              onChange={() => toggleTodo(todo.id!)}
            />
            <span>{todo.title}</span>
            <button
              onClick={() => deleteTodo(todo.id!)}
              className="delete-button"
            >
              ×
            </button>
          </li>
        ))}
      </ul>

      {filteredTodos.length === 0 && (
        <p className="empty-state">No todos to show</p>
      )}
    </div>
  );
};

export default TodosPage;