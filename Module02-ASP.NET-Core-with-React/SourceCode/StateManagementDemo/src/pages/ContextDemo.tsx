import { useAppContext } from '../context/AppContext';
import { useCounter } from '../context/CounterContext';
import StateVisualizer from '../components/StateVisualizer';

// Child components to demonstrate context usage
const UserProfile = () => {
  const { state, login, logout } = useAppContext();
  
  const handleLogin = () => {
    login({
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
    });
  };

  return (
    <div className="card">
      <h3 style={{ margin: '0 0 1rem 0', color: '#2c3e50' }}>
        👤 User Profile Component
      </h3>
      
      {state.user ? (
        <div>
          <div style={{
            background: '#d4edda',
            color: '#155724',
            padding: '1rem',
            borderRadius: '4px',
            marginBottom: '1rem',
          }}>
            <strong>Welcome, {state.user.name}!</strong><br />
            <small>{state.user.email}</small>
          </div>
          <button className="button danger" onClick={logout}>
            Logout
          </button>
        </div>
      ) : (
        <div>
          <div style={{
            background: '#f8d7da',
            color: '#721c24',
            padding: '1rem',
            borderRadius: '4px',
            marginBottom: '1rem',
          }}>
            Please log in to continue
          </div>
          <button className="button" onClick={handleLogin}>
            Login as John Doe
          </button>
        </div>
      )}
    </div>
  );
};

const ThemeToggle = () => {
  const { state, toggleTheme } = useAppContext();
  
  return (
    <div className="card">
      <h3 style={{ margin: '0 0 1rem 0', color: '#2c3e50' }}>
        🎨 Theme Toggle Component
      </h3>
      
      <div style={{
        background: state.theme === 'light' ? '#fff3cd' : '#d1ecf1',
        color: state.theme === 'light' ? '#856404' : '#0c5460',
        padding: '1rem',
        borderRadius: '4px',
        marginBottom: '1rem',
        textAlign: 'center',
      }}>
        Current theme: <strong>{state.theme}</strong>
        <br />
        {state.theme === 'light' ? '☀️' : '🌙'}
      </div>
      
      <button className="button secondary" onClick={toggleTheme}>
        Switch to {state.theme === 'light' ? 'Dark' : 'Light'} Theme
      </button>
    </div>
  );
};

const NotificationCenter = () => {
  const { state, addNotification, removeNotification } = useAppContext();
  
  const addRandomNotification = () => {
    const messages = [
      'New message received!',
      'Task completed successfully',
      'System update available',
      'Welcome to the app!',
      'Data saved automatically',
    ];
    const randomMessage = messages[Math.floor(Math.random() * messages.length)];
    addNotification(randomMessage);
  };

  return (
    <div className="card">
      <h3 style={{ margin: '0 0 1rem 0', color: '#2c3e50' }}>
        🔔 Notification Center
      </h3>
      
      <button className="button" onClick={addRandomNotification}>
        Add Random Notification
      </button>
      
      <div style={{ marginTop: '1rem' }}>
        <strong>Notifications ({state.notifications.length}):</strong>
        {state.notifications.length === 0 ? (
          <div style={{
            color: '#6c757d',
            fontStyle: 'italic',
            textAlign: 'center',
            padding: '1rem',
          }}>
            No notifications
          </div>
        ) : (
          <div style={{ marginTop: '0.5rem' }}>
            {state.notifications.map((notification, index) => (
              <div
                key={index}
                style={{
                  background: '#d1ecf1',
                  color: '#0c5460',
                  padding: '0.75rem',
                  borderRadius: '4px',
                  marginBottom: '0.5rem',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                }}
              >
                <span>{notification}</span>
                <button
                  className="button danger"
                  style={{ padding: '0.25rem 0.5rem', fontSize: '0.8rem' }}
                  onClick={() => removeNotification(index)}
                >
                  ×
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

const CounterDisplay = () => {
  const { count, increment, decrement, reset } = useCounter();
  
  return (
    <div className="card">
      <h3 style={{ margin: '0 0 1rem 0', color: '#2c3e50' }}>
        🔢 Global Counter Component
      </h3>
      
      <div style={{
        fontSize: '3rem',
        fontWeight: 'bold',
        textAlign: 'center',
        padding: '1rem',
        background: '#f8f9fa',
        borderRadius: '4px',
        marginBottom: '1rem',
      }}>
        {count}
      </div>
      
      <div style={{ display: 'flex', gap: '0.5rem', justifyContent: 'center' }}>
        <button className="button danger" onClick={decrement}>
          -1
        </button>
        <button className="button secondary" onClick={reset}>
          Reset
        </button>
        <button className="button success" onClick={increment}>
          +1
        </button>
      </div>
    </div>
  );
};

const ContextDemo = () => {
  const { state, setLoading } = useAppContext();

  const simulateLoading = async () => {
    setLoading(true);
    await new Promise(resolve => setTimeout(resolve, 2000));
    setLoading(false);
  };

  return (
    <div>
      <div className="card">
        <h1 style={{ margin: '0 0 1rem 0', color: '#2c3e50' }}>
          🌐 Context API Demonstrations
        </h1>
        <p style={{ color: '#6c757d', margin: 0 }}>
          Learn how to share state across components without prop drilling.
          The Context API provides a way to pass data through the component tree
          without having to pass props down manually at every level.
        </p>
      </div>

      {/* Global State Visualizer */}
      <StateVisualizer
        title="Global Application State"
        state={state}
        actions={
          <button 
            className="button" 
            onClick={simulateLoading}
            disabled={state.isLoading}
          >
            {state.isLoading ? 'Loading...' : 'Simulate Loading'}
          </button>
        }
      >
        <div style={{
          background: state.isLoading ? '#fff3cd' : '#d4edda',
          color: state.isLoading ? '#856404' : '#155724',
          padding: '1rem',
          borderRadius: '4px',
          marginBottom: '1rem',
          textAlign: 'center',
        }}>
          {state.isLoading ? '🔄 Loading...' : '✅ Ready'}
        </div>
      </StateVisualizer>

      {/* Component Grid */}
      <div className="grid grid-2">
        <UserProfile />
        <ThemeToggle />
        <NotificationCenter />
        <CounterDisplay />
      </div>

      {/* Context Benefits */}
      <div className="card">
        <h2 style={{ color: '#2c3e50', marginBottom: '1rem' }}>
          💡 Context API Benefits
        </h2>
        <div className="grid grid-2">
          <div>
            <h3 style={{ color: '#495057' }}>✅ Advantages</h3>
            <ul style={{ paddingLeft: '1.5rem' }}>
              <li>Eliminates prop drilling</li>
              <li>Shares state across distant components</li>
              <li>Built into React (no external dependencies)</li>
              <li>Type-safe with TypeScript</li>
              <li>Can be combined with useReducer for complex state</li>
            </ul>
          </div>
          <div>
            <h3 style={{ color: '#495057' }}>⚠️ Considerations</h3>
            <ul style={{ paddingLeft: '1.5rem' }}>
              <li>All consumers re-render when context changes</li>
              <li>Can make components less reusable</li>
              <li>Overuse can lead to performance issues</li>
              <li>Testing becomes more complex</li>
              <li>Not suitable for frequently changing data</li>
            </ul>
          </div>
        </div>
      </div>

      {/* Usage Patterns */}
      <div className="card">
        <h2 style={{ color: '#2c3e50', marginBottom: '1rem' }}>
          🎯 When to Use Context
        </h2>
        <div className="grid grid-3">
          <div style={{
            background: '#d4edda',
            color: '#155724',
            padding: '1.5rem',
            borderRadius: '8px',
            textAlign: 'center',
          }}>
            <h3 style={{ margin: '0 0 0.5rem 0' }}>👤 User Authentication</h3>
            <p style={{ margin: 0, fontSize: '0.9rem' }}>
              Current user, login status, permissions
            </p>
          </div>
          
          <div style={{
            background: '#d1ecf1',
            color: '#0c5460',
            padding: '1.5rem',
            borderRadius: '8px',
            textAlign: 'center',
          }}>
            <h3 style={{ margin: '0 0 0.5rem 0' }}>🎨 Theme/Settings</h3>
            <p style={{ margin: 0, fontSize: '0.9rem' }}>
              UI theme, language, user preferences
            </p>
          </div>
          
          <div style={{
            background: '#fff3cd',
            color: '#856404',
            padding: '1.5rem',
            borderRadius: '8px',
            textAlign: 'center',
          }}>
            <h3 style={{ margin: '0 0 0.5rem 0' }}>🔔 Notifications</h3>
            <p style={{ margin: 0, fontSize: '0.9rem' }}>
              Global messages, alerts, toasts
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ContextDemo;
