
// In App.tsx
import { Profiler } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import './App.css';
import { AuthProvider } from './context/AuthContext';
import { TodoProvider } from './context/TodoContext';
import Navigation from './components/Navigation';
import PrivateRoute from './components/PrivateRoute';
import HomePage from  './pages/HomePage'
import LoginPage from './pages/LoginPage';
import TodosPage from './pages/TodosPage';



function onRenderCallback(
  id: string,
  phase: "mount" | "update",
  actualDuration: number,
  // baseDuration: number,
  // startTime: number,
  // commitTime: number,
  // interactions: Set<any>
) {
  console.log(`Component ${id} (${phase}) took ${actualDuration}ms`);
}



function App() {
  return (
    <Router>
      <AuthProvider>
        <TodoProvider>
          <div className="App">
            <Navigation />
            <main className="main-content">
              <Routes>
                <Route path="/" element={<HomePage />} />
                <Route path="/login" element={<LoginPage />} />
                <Route path="/todos" element={
                  <PrivateRoute>
                    <Profiler id="TodosPage" onRender={onRenderCallback}>
                      <TodosPage /> 
                    </Profiler>
                  </PrivateRoute>
                } />
              </Routes>
            </main>
          </div>
        </TodoProvider>
      </AuthProvider>
    </Router>
  );
}

export default App;