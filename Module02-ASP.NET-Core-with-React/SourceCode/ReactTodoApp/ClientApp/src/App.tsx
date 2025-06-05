import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import TodoList from './components/TodoList';
import TodoStats from './components/TodoStats';
import About from './components/About';
import './App.css';

function App() {
  return (
    <Router>
      <div className="app">
        <header className="app-header">
          <div className="container">
            <h1>React + ASP.NET Core Todo App</h1>
            <nav className="nav">
              <Link to="/" className="nav-link">Todos</Link>
              <Link to="/stats" className="nav-link">Statistics</Link>
              <Link to="/about" className="nav-link">About</Link>
              <a href="/swagger" target="_blank" rel="noopener noreferrer" className="nav-link">
                API Docs
              </a>
            </nav>
          </div>
        </header>

        <main className="main-content">
          <div className="container">
            <Routes>
              <Route path="/" element={<TodoList />} />
              <Route path="/stats" element={<TodoStats />} />
              <Route path="/about" element={<About />} />
            </Routes>
          </div>
        </main>

        <footer className="app-footer">
          <div className="container">
            <p>Module 02 - ASP.NET Core with React | Built with ❤️ for learning</p>
          </div>
        </footer>
      </div>
    </Router>
  );
}

export default App;
