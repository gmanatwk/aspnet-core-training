import React, { useState } from 'react';
import { Todo, TodoPriority } from '../types/Todo';

interface TodoFormProps {
  onSubmit: (todo: Omit<Todo, 'id' | 'createdAt' | 'completedAt' | 'status' | 'daysOld'>) => Promise<boolean>;
}

const TodoForm: React.FC<TodoFormProps> = ({ onSubmit }) => {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [priority, setPriority] = useState<TodoPriority>(TodoPriority.Medium);
  const [category, setCategory] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!title.trim()) {
      return;
    }

    setIsSubmitting(true);

    const todoData = {
      title: title.trim(),
      description: description.trim() || undefined,
      isCompleted: false,
      priority,
      category: category.trim() || undefined
    };

    const success = await onSubmit(todoData);
    
    if (success) {
      // Reset form on successful submission
      setTitle('');
      setDescription('');
      setPriority(TodoPriority.Medium);
      setCategory('');
    }

    setIsSubmitting(false);
  };

  return (
    <form onSubmit={handleSubmit} className="add-todo-form">
      <div className="form-row">
        <input
          type="text"
          className="todo-input todo-input-main"
          placeholder="What needs to be done?"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          disabled={isSubmitting}
          required
          aria-label="Todo title"
        />

        <select
          className="priority-select"
          value={priority}
          onChange={(e) => setPriority(parseInt(e.target.value) as TodoPriority)}
          disabled={isSubmitting}
          aria-label="Select priority level"
        >
          <option value={TodoPriority.Low}>Low Priority</option>
          <option value={TodoPriority.Medium}>Medium Priority</option>
          <option value={TodoPriority.High}>High Priority</option>
          <option value={TodoPriority.Urgent}>Urgent</option>
        </select>

        <input
          type="text"
          className="category-input category-input-sized"
          placeholder="Category (optional)"
          value={category}
          onChange={(e) => setCategory(e.target.value)}
          disabled={isSubmitting}
          aria-label="Todo category"
        />

        <button
          type="submit"
          className="add-button"
          disabled={isSubmitting || !title.trim()}
        >
          {isSubmitting ? 'Adding...' : 'Add Todo'}
        </button>
      </div>

      <textarea
        className="todo-textarea todo-textarea-spaced"
        placeholder="Description (optional)"
        value={description}
        onChange={(e) => setDescription(e.target.value)}
        disabled={isSubmitting}
        rows={3}
        aria-label="Todo description"
      />
    </form>
  );
};

export default TodoForm;
