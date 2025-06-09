import { Todo, TodoPriority } from '@/types/todo';

interface TodoItemProps {
  todo: Todo;
  onToggle: (id: number) => void;
  onDelete: (id: number) => void;
}

const getPriorityColor = (priority: TodoPriority): string => {
  switch (priority) {
    case TodoPriority.Low:
      return '#28a745'; // Green
    case TodoPriority.Medium:
      return '#ffc107'; // Yellow
    case TodoPriority.High:
      return '#fd7e14'; // Orange
    case TodoPriority.Urgent:
      return '#dc3545'; // Red
    default:
      return '#6c757d'; // Gray
  }
};

const getPriorityText = (priority: TodoPriority): string => {
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
      return 'Unknown';
  }
};

export default function TodoItem({ todo, onToggle, onDelete }: TodoItemProps) {
  return (
    <div className={`todo-item ${todo.isCompleted ? 'completed' : ''}`}>
      <div className="todo-content">
        <input
          type="checkbox"
          checked={todo.isCompleted}
          onChange={() => onToggle(todo.id)}
          className="todo-checkbox"
        />
        
        <div className="todo-details">
          <h3 className="todo-title">{todo.title}</h3>
          {todo.description && (
            <p className="todo-description">{todo.description}</p>
          )}
          
          <div className="todo-meta">
            <span 
              className="priority-badge"
              style={{ backgroundColor: getPriorityColor(todo.priority) }}
            >
              {getPriorityText(todo.priority)}
            </span>
            
            {todo.category && (
              <span className="category-badge">{todo.category}</span>
            )}
            
            <span className="date-info">
              Created {todo.daysOld} days ago
            </span>
            
            {todo.isCompleted && todo.completedAt && (
              <span className="completion-info">
                Completed on {new Date(todo.completedAt).toLocaleDateString()}
              </span>
            )}
          </div>
        </div>
      </div>
      
      <button
        onClick={() => onDelete(todo.id)}
        className="delete-button"
        aria-label={`Delete todo: ${todo.title}`}
      >
        ×
      </button>

      <style jsx>{`
        .todo-item {
          display: flex;
          align-items: flex-start;
          padding: 1rem;
          border: 1px solid #e1e5e9;
          border-radius: 8px;
          margin-bottom: 0.5rem;
          background: white;
          transition: all 0.2s ease;
        }

        .todo-item:hover {
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .todo-item.completed {
          opacity: 0.7;
          background: #f8f9fa;
        }

        .todo-content {
          display: flex;
          align-items: flex-start;
          flex: 1;
          gap: 0.75rem;
        }

        .todo-checkbox {
          margin-top: 0.25rem;
          width: 1.2rem;
          height: 1.2rem;
        }

        .todo-details {
          flex: 1;
        }

        .todo-title {
          margin: 0 0 0.5rem 0;
          font-size: 1.1rem;
          font-weight: 600;
          color: #2c3e50;
        }

        .todo-item.completed .todo-title {
          text-decoration: line-through;
          color: #6c757d;
        }

        .todo-description {
          margin: 0 0 0.75rem 0;
          color: #6c757d;
          font-size: 0.9rem;
          line-height: 1.4;
        }

        .todo-meta {
          display: flex;
          flex-wrap: wrap;
          gap: 0.5rem;
          align-items: center;
        }

        .priority-badge {
          padding: 0.25rem 0.5rem;
          border-radius: 12px;
          color: white;
          font-size: 0.75rem;
          font-weight: 600;
          text-transform: uppercase;
        }

        .category-badge {
          padding: 0.25rem 0.5rem;
          background: #e9ecef;
          color: #495057;
          border-radius: 12px;
          font-size: 0.75rem;
          font-weight: 500;
        }

        .date-info,
        .completion-info {
          font-size: 0.75rem;
          color: #6c757d;
        }

        .delete-button {
          background: #dc3545;
          color: white;
          border: none;
          border-radius: 50%;
          width: 2rem;
          height: 2rem;
          font-size: 1.2rem;
          cursor: pointer;
          display: flex;
          align-items: center;
          justify-content: center;
          transition: background-color 0.2s ease;
        }

        .delete-button:hover {
          background: #c82333;
        }

        @media (max-width: 768px) {
          .todo-item {
            padding: 0.75rem;
          }
          
          .todo-meta {
            flex-direction: column;
            align-items: flex-start;
          }
        }
      `}</style>
    </div>
  );
}
