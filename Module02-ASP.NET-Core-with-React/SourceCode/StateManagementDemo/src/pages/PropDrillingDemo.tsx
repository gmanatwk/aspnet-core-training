import { useState, createContext, useContext } from 'react';
import StateVisualizer from '../components/StateVisualizer';

// Types for our demo
interface User {
  name: string;
  role: string;
  preferences: {
    theme: string;
    language: string;
  };
}

interface AppData {
  user: User;
  updateUser: (updates: Partial<User>) => void;
  updatePreferences: (prefs: Partial<User['preferences']>) => void;
}

// Context solution
const AppDataContext = createContext<AppData | null>(null);

// Prop drilling example components
const Level1WithProps = ({ user, updateUser, updatePreferences }: AppData) => {
  return (
    <div style={{
      border: '2px solid #007bff',
      borderRadius: '8px',
      padding: '1rem',
      margin: '0.5rem 0',
      background: 'rgba(0, 123, 255, 0.05)',
    }}>
      <h4 style={{ margin: '0 0 0.5rem 0', color: '#007bff' }}>
        📦 Level 1 Component (Props)
      </h4>
      <p style={{ margin: '0 0 1rem 0', fontSize: '0.9rem', color: '#6c757d' }}>
        Receives props and passes them down to Level 2
      </p>
      <Level2WithProps user={user} updateUser={updateUser} updatePreferences={updatePreferences} />
    </div>
  );
};

const Level2WithProps = ({ user, updateUser, updatePreferences }: AppData) => {
  return (
    <div style={{
      border: '2px solid #28a745',
      borderRadius: '8px',
      padding: '1rem',
      margin: '0.5rem 0',
      background: 'rgba(40, 167, 69, 0.05)',
    }}>
      <h4 style={{ margin: '0 0 0.5rem 0', color: '#28a745' }}>
        📦 Level 2 Component (Props)
      </h4>
      <p style={{ margin: '0 0 1rem 0', fontSize: '0.9rem', color: '#6c757d' }}>
        Doesn't use the props but must pass them to Level 3
      </p>
      <Level3WithProps user={user} updateUser={updateUser} updatePreferences={updatePreferences} />
    </div>
  );
};

const Level3WithProps = ({ user, updateUser, updatePreferences }: AppData) => {
  return (
    <div style={{
      border: '2px solid #ffc107',
      borderRadius: '8px',
      padding: '1rem',
      margin: '0.5rem 0',
      background: 'rgba(255, 193, 7, 0.05)',
    }}>
      <h4 style={{ margin: '0 0 0.5rem 0', color: '#856404' }}>
        📦 Level 3 Component (Props)
      </h4>
      <p style={{ margin: '0 0 1rem 0', fontSize: '0.9rem', color: '#6c757d' }}>
        Finally uses the props to render user info and controls
      </p>
      <UserControlsWithProps user={user} updateUser={updateUser} updatePreferences={updatePreferences} />
    </div>
  );
};

const UserControlsWithProps = ({ user, updateUser, updatePreferences }: AppData) => {
  return (
    <div style={{
      border: '2px solid #dc3545',
      borderRadius: '8px',
      padding: '1rem',
      background: 'rgba(220, 53, 69, 0.05)',
    }}>
      <h4 style={{ margin: '0 0 0.5rem 0', color: '#dc3545' }}>
        🎮 User Controls (Props)
      </h4>
      <div style={{ fontSize: '0.9rem', marginBottom: '1rem' }}>
        <strong>Current User:</strong> {user.name} ({user.role})
      </div>
      <div style={{ display: 'grid', gap: '0.5rem' }}>
        <input
          className="input"
          type="text"
          value={user.name}
          onChange={(e) => updateUser({ name: e.target.value })}
          placeholder="User name"
        />
        <select
          className="input"
          value={user.preferences.theme}
          onChange={(e) => updatePreferences({ theme: e.target.value })}
        >
          <option value="light">Light Theme</option>
          <option value="dark">Dark Theme</option>
        </select>
      </div>
    </div>
  );
};

// Context solution components
const Level1WithContext = () => {
  return (
    <div style={{
      border: '2px solid #007bff',
      borderRadius: '8px',
      padding: '1rem',
      margin: '0.5rem 0',
      background: 'rgba(0, 123, 255, 0.05)',
    }}>
      <h4 style={{ margin: '0 0 0.5rem 0', color: '#007bff' }}>
        📦 Level 1 Component (Context)
      </h4>
      <p style={{ margin: '0 0 1rem 0', fontSize: '0.9rem', color: '#6c757d' }}>
        No props needed! Just renders Level 2
      </p>
      <Level2WithContext />
    </div>
  );
};

const Level2WithContext = () => {
  return (
    <div style={{
      border: '2px solid #28a745',
      borderRadius: '8px',
      padding: '1rem',
      margin: '0.5rem 0',
      background: 'rgba(40, 167, 69, 0.05)',
    }}>
      <h4 style={{ margin: '0 0 0.5rem 0', color: '#28a745' }}>
        📦 Level 2 Component (Context)
      </h4>
      <p style={{ margin: '0 0 1rem 0', fontSize: '0.9rem', color: '#6c757d' }}>
        Clean component - no prop drilling needed!
      </p>
      <Level3WithContext />
    </div>
  );
};

const Level3WithContext = () => {
  return (
    <div style={{
      border: '2px solid #ffc107',
      borderRadius: '8px',
      padding: '1rem',
      margin: '0.5rem 0',
      background: 'rgba(255, 193, 7, 0.05)',
    }}>
      <h4 style={{ margin: '0 0 0.5rem 0', color: '#856404' }}>
        📦 Level 3 Component (Context)
      </h4>
      <p style={{ margin: '0 0 1rem 0', fontSize: '0.9rem', color: '#6c757d' }}>
        Still clean - context handles the data flow
      </p>
      <UserControlsWithContext />
    </div>
  );
};

const UserControlsWithContext = () => {
  const context = useContext(AppDataContext);
  if (!context) return <div>Context not available</div>;
  
  const { user, updateUser, updatePreferences } = context;
  
  return (
    <div style={{
      border: '2px solid #dc3545',
      borderRadius: '8px',
      padding: '1rem',
      background: 'rgba(220, 53, 69, 0.05)',
    }}>
      <h4 style={{ margin: '0 0 0.5rem 0', color: '#dc3545' }}>
        🎮 User Controls (Context)
      </h4>
      <div style={{ fontSize: '0.9rem', marginBottom: '1rem' }}>
        <strong>Current User:</strong> {user.name} ({user.role})
      </div>
      <div style={{ display: 'grid', gap: '0.5rem' }}>
        <input
          className="input"
          type="text"
          value={user.name}
          onChange={(e) => updateUser({ name: e.target.value })}
          placeholder="User name"
        />
        <select
          className="input"
          value={user.preferences.theme}
          onChange={(e) => updatePreferences({ theme: e.target.value })}
        >
          <option value="light">Light Theme</option>
          <option value="dark">Dark Theme</option>
        </select>
      </div>
    </div>
  );
};

const PropDrillingDemo = () => {
  const [user, setUser] = useState<User>({
    name: 'John Doe',
    role: 'Developer',
    preferences: {
      theme: 'light',
      language: 'en',
    },
  });

  const updateUser = (updates: Partial<User>) => {
    setUser(prev => ({ ...prev, ...updates }));
  };

  const updatePreferences = (prefs: Partial<User['preferences']>) => {
    setUser(prev => ({
      ...prev,
      preferences: { ...prev.preferences, ...prefs },
    }));
  };

  const appData: AppData = {
    user,
    updateUser,
    updatePreferences,
  };

  return (
    <div>
      <div className="card">
        <h1 style={{ margin: '0 0 1rem 0', color: '#2c3e50' }}>
          🕳️ Prop Drilling Problem & Solutions
        </h1>
        <p style={{ color: '#6c757d', margin: 0 }}>
          Prop drilling occurs when you need to pass data through many component layers
          to reach a deeply nested component. This demo shows the problem and how
          Context API solves it.
        </p>
      </div>

      {/* Current State */}
      <StateVisualizer
        title="Current Application State"
        state={user}
        actions={
          <>
            <button 
              className="button"
              onClick={() => updateUser({ 
                name: 'Jane Smith', 
                role: 'Designer' 
              })}
            >
              Switch to Jane
            </button>
            <button 
              className="button secondary"
              onClick={() => updateUser({ 
                name: 'John Doe', 
                role: 'Developer' 
              })}
            >
              Switch to John
            </button>
          </>
        }
      />

      <div className="grid grid-2">
        {/* Prop Drilling Example */}
        <div className="card">
          <h2 style={{ margin: '0 0 1rem 0', color: '#dc3545' }}>
            ❌ With Prop Drilling
          </h2>
          <div style={{
            background: '#f8d7da',
            color: '#721c24',
            padding: '1rem',
            borderRadius: '4px',
            marginBottom: '1rem',
          }}>
            <strong>Problems:</strong>
            <ul style={{ margin: '0.5rem 0', paddingLeft: '1.5rem' }}>
              <li>Props passed through components that don't use them</li>
              <li>Difficult to maintain and refactor</li>
              <li>Tight coupling between components</li>
              <li>Verbose and repetitive code</li>
            </ul>
          </div>
          <Level1WithProps {...appData} />
        </div>

        {/* Context Solution */}
        <div className="card">
          <h2 style={{ margin: '0 0 1rem 0', color: '#28a745' }}>
            ✅ With Context API
          </h2>
          <div style={{
            background: '#d4edda',
            color: '#155724',
            padding: '1rem',
            borderRadius: '4px',
            marginBottom: '1rem',
          }}>
            <strong>Benefits:</strong>
            <ul style={{ margin: '0.5rem 0', paddingLeft: '1.5rem' }}>
              <li>No props passed through intermediate components</li>
              <li>Cleaner, more maintainable code</li>
              <li>Loose coupling between components</li>
              <li>Data available anywhere in the tree</li>
            </ul>
          </div>
          <AppDataContext.Provider value={appData}>
            <Level1WithContext />
          </AppDataContext.Provider>
        </div>
      </div>

      {/* Comparison Table */}
      <div className="card">
        <h2 style={{ color: '#2c3e50', marginBottom: '1rem' }}>
          📊 Prop Drilling vs Context API
        </h2>
        <div style={{ overflowX: 'auto' }}>
          <table style={{
            width: '100%',
            borderCollapse: 'collapse',
            fontSize: '0.9rem',
          }}>
            <thead>
              <tr style={{ background: '#f8f9fa' }}>
                <th style={{ padding: '1rem', textAlign: 'left', borderBottom: '2px solid #dee2e6' }}>
                  Aspect
                </th>
                <th style={{ padding: '1rem', textAlign: 'left', borderBottom: '2px solid #dee2e6' }}>
                  Prop Drilling
                </th>
                <th style={{ padding: '1rem', textAlign: 'left', borderBottom: '2px solid #dee2e6' }}>
                  Context API
                </th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td style={{ padding: '0.75rem', borderBottom: '1px solid #dee2e6', fontWeight: 'bold' }}>
                  Code Complexity
                </td>
                <td style={{ padding: '0.75rem', borderBottom: '1px solid #dee2e6', color: '#dc3545' }}>
                  High - Many prop declarations
                </td>
                <td style={{ padding: '0.75rem', borderBottom: '1px solid #dee2e6', color: '#28a745' }}>
                  Low - Clean component interfaces
                </td>
              </tr>
              <tr style={{ background: '#f8f9fa' }}>
                <td style={{ padding: '0.75rem', borderBottom: '1px solid #dee2e6', fontWeight: 'bold' }}>
                  Maintainability
                </td>
                <td style={{ padding: '0.75rem', borderBottom: '1px solid #dee2e6', color: '#dc3545' }}>
                  Difficult - Changes affect many files
                </td>
                <td style={{ padding: '0.75rem', borderBottom: '1px solid #dee2e6', color: '#28a745' }}>
                  Easy - Centralized state management
                </td>
              </tr>
              <tr>
                <td style={{ padding: '0.75rem', borderBottom: '1px solid #dee2e6', fontWeight: 'bold' }}>
                  Performance
                </td>
                <td style={{ padding: '0.75rem', borderBottom: '1px solid #dee2e6', color: '#28a745' }}>
                  Good - Only necessary re-renders
                </td>
                <td style={{ padding: '0.75rem', borderBottom: '1px solid #dee2e6', color: '#ffc107' }}>
                  Moderate - All consumers re-render
                </td>
              </tr>
              <tr style={{ background: '#f8f9fa' }}>
                <td style={{ padding: '0.75rem', borderBottom: '1px solid #dee2e6', fontWeight: 'bold' }}>
                  Testing
                </td>
                <td style={{ padding: '0.75rem', borderBottom: '1px solid #dee2e6', color: '#28a745' }}>
                  Easy - Props are explicit
                </td>
                <td style={{ padding: '0.75rem', borderBottom: '1px solid #dee2e6', color: '#ffc107' }}>
                  Complex - Need to mock context
                </td>
              </tr>
              <tr>
                <td style={{ padding: '0.75rem', borderBottom: '1px solid #dee2e6', fontWeight: 'bold' }}>
                  Reusability
                </td>
                <td style={{ padding: '0.75rem', borderBottom: '1px solid #dee2e6', color: '#28a745' }}>
                  High - Components are self-contained
                </td>
                <td style={{ padding: '0.75rem', borderBottom: '1px solid #dee2e6', color: '#dc3545' }}>
                  Low - Depends on context provider
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      {/* Best Practices */}
      <div className="card">
        <h2 style={{ color: '#2c3e50', marginBottom: '1rem' }}>
          💡 Best Practices
        </h2>
        <div className="grid grid-2">
          <div>
            <h3 style={{ color: '#495057' }}>✅ Use Context When:</h3>
            <ul style={{ paddingLeft: '1.5rem' }}>
              <li>Data is needed by many components at different nesting levels</li>
              <li>Props would be passed through 3+ component levels</li>
              <li>The data represents global application state</li>
              <li>You want to avoid tight coupling</li>
            </ul>
          </div>
          <div>
            <h3 style={{ color: '#495057' }}>✅ Use Props When:</h3>
            <ul style={{ paddingLeft: '1.5rem' }}>
              <li>Data is only needed by direct children</li>
              <li>Component reusability is important</li>
              <li>The data flow is simple and linear</li>
              <li>You want explicit data dependencies</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PropDrillingDemo;
