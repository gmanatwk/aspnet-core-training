import React, { useCallback, useMemo } from 'react';
import { FixedSizeList as List } from 'react-window';
import { Todo } from '../services/todoService';

interface VirtualizedTodoListProps {
  todos: Todo[];
  onToggle: (id: number) => void;
  onDelete: (id: number) => void;
  height: number;
}

interface TodoItemProps {
  index: number;
  style: React.CSSProperties;
  data: {
    todos: Todo[];
    onToggle: (id: number) => void;
    onDelete: (id: number) => void;
  };
}

const TodoItem: React.FC<TodoItemProps> = React.memo(({ index, style, data }) => {
  const { todos, onToggle, onDelete } = data;
  const todo = todos[index];

  return (
    <div style={style} className={`todo-item ${todo.isCompleted ? 'completed' : ''}`}>
      <input
        type="checkbox"
        checked={todo.isCompleted}
        onChange={() => onToggle(todo.id!)}
      />
      <span>{todo.title}</span>
      <button onClick={() => onDelete(todo.id!)} className="delete-button">
        ×
      </button>
    </div>
  );
});

const VirtualizedTodoList: React.FC<VirtualizedTodoListProps> = ({ 
  todos, 
  onToggle, 
  onDelete, 
  height 
}) => {
  const itemData = useMemo(
    () => ({ todos, onToggle, onDelete }),
    [todos, onToggle, onDelete]
  );

  return (
    <List
      height={height}
      itemCount={todos.length}
      itemSize={50}
      width="100%"
      itemData={itemData}
    >
      {TodoItem}
    </List>
  );
};

export default React.memo(VirtualizedTodoList);