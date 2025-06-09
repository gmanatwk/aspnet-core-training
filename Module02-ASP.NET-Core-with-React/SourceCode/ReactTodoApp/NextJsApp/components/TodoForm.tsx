import { useState } from 'react';
import { TodoPriority } from '@/types/todo';

interface TodoFormProps {
  onSubmit: (todoData: {
    title: string;
    description?: string;
    priority: TodoPriority;
    category?: string;
  }) => Promise<boolean>;
}

export default function TodoForm({ onSubmit }: TodoFormProps) {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [priority, setPriority] = useState<TodoPriority>(TodoPriority.Medium);
  const [category, setCategory] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!title.trim()) return;

    setIsSubmitting(true);
    
    try {
      const success = await onSubmit({
        title: title.trim(),
        description: description.trim() || undefined,
        priority,
        category: category.trim() || undefined,
      });

      if (success) {
        // Reset form
        setTitle('');
        setDescription('');
        setPriority(TodoPriority.Medium);
        setCategory('');
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="todo-form">
      <div className="form-group">
        <label htmlFor="title">Title *</label>
        <input
          id="title"
          type="text"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Enter todo title..."
          required
          disabled={isSubmitting}
          className="form-input"
        />
      </div>

      <div className="form-group">
        <label htmlFor="description">Description</label>
        <textarea
          id="description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          placeholder="Enter description (optional)..."
          disabled={isSubmitting}
          className="form-textarea"
          rows={3}
        />
      </div>

      <div className="form-row">
        <div className="form-group">
          <label htmlFor="priority">Priority</label>
          <select
            id="priority"
            value={priority}
            onChange={(e) => setPriority(parseInt(e.target.value) as TodoPriority)}
            disabled={isSubmitting}
            className="form-select"
          >
            <option value={TodoPriority.Low}>Low</option>
            <option value={TodoPriority.Medium}>Medium</option>
            <option value={TodoPriority.High}>High</option>
            <option value={TodoPriority.Urgent}>Urgent</option>
          </select>
        </div>

        <div className="form-group">
          <label htmlFor="category">Category</label>
          <input
            id="category"
            type="text"
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            placeholder="e.g., Work, Personal..."
            disabled={isSubmitting}
            className="form-input"
          />
        </div>
      </div>

      <button
        type="submit"
        disabled={!title.trim() || isSubmitting}
        className="submit-button"
      >
        {isSubmitting ? 'Adding...' : 'Add Todo'}
      </button>

      <style jsx>{`
        .todo-form {
          background: white;
          padding: 1.5rem;
          border-radius: 8px;
          border: 1px solid #e1e5e9;
          margin-bottom: 2rem;
        }

        .form-group {
          margin-bottom: 1rem;
        }

        .form-row {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 1rem;
        }

        label {
          display: block;
          margin-bottom: 0.5rem;
          font-weight: 600;
          color: #2c3e50;
          font-size: 0.9rem;
        }

        .form-input,
        .form-textarea,
        .form-select {
          width: 100%;
          padding: 0.75rem;
          border: 1px solid #ced4da;
          border-radius: 4px;
          font-size: 1rem;
          transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .form-input:focus,
        .form-textarea:focus,
        .form-select:focus {
          outline: none;
          border-color: #007bff;
          box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
        }

        .form-input:disabled,
        .form-textarea:disabled,
        .form-select:disabled {
          background-color: #f8f9fa;
          cursor: not-allowed;
        }

        .form-textarea {
          resize: vertical;
          min-height: 80px;
        }

        .submit-button {
          background: #007bff;
          color: white;
          border: none;
          padding: 0.75rem 2rem;
          border-radius: 4px;
          font-size: 1rem;
          font-weight: 600;
          cursor: pointer;
          transition: background-color 0.2s ease;
          width: 100%;
        }

        .submit-button:hover:not(:disabled) {
          background: #0056b3;
        }

        .submit-button:disabled {
          background: #6c757d;
          cursor: not-allowed;
        }

        @media (max-width: 768px) {
          .form-row {
            grid-template-columns: 1fr;
          }
          
          .todo-form {
            padding: 1rem;
          }
        }
      `}</style>
    </form>
  );
}
