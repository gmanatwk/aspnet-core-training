import React from 'react';
import { Todo, TodoPriority } from '../types/Todo';

interface TodoItemProps {
  todo: Todo;
  onToggle: (id: number) => void;
  onDelete: (id: number) => void;
}

const TodoItem: React.FC<TodoItemProps> = ({ todo, onToggle, onDelete }) => {
  const formatDate = (dateString?: string) => {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const getPriorityClass = (priority: TodoPriority) => {
    switch (priority) {
      case TodoPriority.Low:
        return 'priority-low';
      case TodoPriority.Medium:
        return 'priority-medium';
      case TodoPriority.High:
        return 'priority-high';
      case TodoPriority.Urgent:
        return 'priority-urgent';
      default:
        return 'priority-medium';
    }
  };

  const getPriorityText = (priority: TodoPriority) => {
    switch (priority) {
      case TodoPriority.Low:
        return 'Low';
      case TodoPriority.Medium:
        return 'Medium';
      case TodoPriority.High:
        return 'High';
      case TodoPriority.Urgent:
        return 'Urgent';
      default:
        return 'Medium';
    }
  };

  return (
    <div className={`todo-item ${todo.isCompleted ? 'completed' : ''}`}>
      <input
        type="checkbox"
        className="todo-checkbox"
        checked={todo.isCompleted}
        onChange={() => todo.id && onToggle(todo.id)}
        aria-label={`Mark "${todo.title}" as ${todo.isCompleted ? 'pending' : 'completed'}`}
        title={`Mark "${todo.title}" as ${todo.isCompleted ? 'pending' : 'completed'}`}
      />
      
      <div className="todo-content">
        <div className="todo-title">{todo.title}</div>
        
        {todo.description && (
          <div className="todo-description">{todo.description}</div>
        )}
        
        <div className="todo-meta">
          <span className={`priority-badge ${getPriorityClass(todo.priority)}`}>
            {getPriorityText(todo.priority)}
          </span>
          
          {todo.category && (
            <span className="category-badge">{todo.category}</span>
          )}
          
          <span>Created: {formatDate(todo.createdAt)}</span>
          
          {todo.completedAt && (
            <span>Completed: {formatDate(todo.completedAt)}</span>
          )}
          
          {todo.daysOld !== undefined && (
            <span>{todo.daysOld} days old</span>
          )}
        </div>
      </div>
      
      <div className="todo-actions">
        <button
          type="button"
          className="action-button toggle-button"
          onClick={() => todo.id && onToggle(todo.id)}
          title={todo.isCompleted ? 'Mark as pending' : 'Mark as completed'}
          aria-label={todo.isCompleted ? 'Mark as pending' : 'Mark as completed'}
        >
          {todo.isCompleted ? '↶' : '✓'}
        </button>

        <button
          type="button"
          className="action-button delete-button"
          onClick={() => todo.id && onDelete(todo.id)}
          title="Delete todo"
          aria-label="Delete todo"
        >
          🗑
        </button>
      </div>
    </div>
  );
};

export default TodoItem;
