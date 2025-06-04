import React, { useEffect, useState } from 'react';

function App() {
  const [todos, setTodos] = useState([]);

  useEffect(() => {
    fetch('https://localhost:5001/api/todo')
      .then(response => response.json())
      .then(data => setTodos(data));
  }, []);

  return (
    <div>
      <h1>Todo List</h1>
      <ul>
        {todos.map(todo => (
          <li key={todo.id}>
            <strong>{todo.todoItem}</strong> - {todo.todoState}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
