import React from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const HomePage: React.FC = () => {
  const { isAuthenticated, user } = useAuth();

  return (
    <div className="home-page">
      <h1>Welcome to Todo App</h1>
      {isAuthenticated ? (
        <div>
          <p>Hello, {user?.name}!</p>
          <Link to="/todos" className="btn btn-primary">
            Go to Todos
          </Link>
        </div>
      ) : (
        <div>
          <p>Please login to manage your todos.</p>
          <Link to="/login" className="btn btn-primary">
            Login
          </Link>
        </div>
      )}
    </div>
  );
};

export default HomePage;