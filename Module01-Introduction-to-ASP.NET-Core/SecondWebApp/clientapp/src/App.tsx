import React from 'react';
import './App.css';
import TodoList from './components/TodoList';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>React + ASP.NET Core Todo App</h1>
      </header>
      <main>
        <TodoList />
      </main>
    </div>
  );
}

export default App;
