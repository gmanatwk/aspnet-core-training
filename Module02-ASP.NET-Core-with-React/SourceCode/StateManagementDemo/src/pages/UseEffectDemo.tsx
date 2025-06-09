import { useState, useEffect } from 'react';
import StateVisualizer from '../components/StateVisualizer';

const UseEffectDemo = () => {
  // Effect with no dependencies (runs on every render)
  const [renderCount, setRenderCount] = useState(0);
  const [effectCount, setEffectCount] = useState(0);

  // Effect with empty dependencies (runs once on mount)
  const [mountTime, setMountTime] = useState<string>('');

  // Effect with dependencies (runs when dependencies change)
  const [name, setName] = useState('');
  const [greeting, setGreeting] = useState('');

  // Timer effect with cleanup
  const [seconds, setSeconds] = useState(0);
  const [isTimerRunning, setIsTimerRunning] = useState(false);

  // Data fetching effect
  const [users, setUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Window resize effect
  const [windowSize, setWindowSize] = useState({
    width: window.innerWidth,
    height: window.innerHeight,
  });

  // Effect that runs on every render
  useEffect(() => {
    setEffectCount(prev => prev + 1);
    console.log('Effect ran! Render count:', renderCount + 1);
  });

  // Effect that runs once on mount
  useEffect(() => {
    setMountTime(new Date().toLocaleTimeString());
    console.log('Component mounted at:', new Date().toLocaleTimeString());
    
    return () => {
      console.log('Component will unmount');
    };
  }, []);

  // Effect that runs when name changes
  useEffect(() => {
    if (name) {
      setGreeting(`Hello, ${name}! Nice to meet you.`);
    } else {
      setGreeting('');
    }
    console.log('Name changed to:', name);
  }, [name]);

  // Timer effect with cleanup
  useEffect(() => {
    let interval: NodeJS.Timeout | null = null;
    
    if (isTimerRunning) {
      interval = setInterval(() => {
        setSeconds(prev => prev + 1);
      }, 1000);
    }
    
    return () => {
      if (interval) {
        clearInterval(interval);
      }
    };
  }, [isTimerRunning]);

  // Window resize effect
  useEffect(() => {
    const handleResize = () => {
      setWindowSize({
        width: window.innerWidth,
        height: window.innerHeight,
      });
    };

    window.addEventListener('resize', handleResize);
    
    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, []);

  // Data fetching effect
  const fetchUsers = async () => {
    setLoading(true);
    setError(null);
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      const mockUsers = [
        { id: 1, name: 'John Doe', email: 'john@example.com' },
        { id: 2, name: 'Jane Smith', email: 'jane@example.com' },
        { id: 3, name: 'Bob Johnson', email: 'bob@example.com' },
      ];
      
      setUsers(mockUsers);
    } catch (err) {
      setError('Failed to fetch users');
    } finally {
      setLoading(false);
    }
  };

  const triggerRerender = () => {
    setRenderCount(prev => prev + 1);
  };

  const resetTimer = () => {
    setSeconds(0);
    setIsTimerRunning(false);
  };

  return (
    <div>
      <div className="card">
        <h1 style={{ margin: '0 0 1rem 0', color: '#2c3e50' }}>
          ⚡ useEffect Hook Demonstrations
        </h1>
        <p style={{ color: '#6c757d', margin: 0 }}>
          Learn how to handle side effects, lifecycle events, and cleanup in React components.
          Watch how different dependency arrays affect when effects run.
        </p>
      </div>

      <div className="grid grid-2">
        {/* Effect with no dependencies */}
        <StateVisualizer
          title="Effect with No Dependencies"
          state={{ renderCount, effectCount }}
          actions={
            <button className="button" onClick={triggerRerender}>
              Trigger Re-render
            </button>
          }
        >
          <div style={{
            background: '#fff3cd',
            color: '#856404',
            padding: '1rem',
            borderRadius: '4px',
            marginBottom: '1rem',
          }}>
            ⚠️ <strong>Warning:</strong> This effect runs on every render! 
            Check the console to see how many times it executes.
          </div>
          <p>
            <strong>Render Count:</strong> {renderCount}<br />
            <strong>Effect Count:</strong> {effectCount}
          </p>
        </StateVisualizer>

        {/* Effect with empty dependencies */}
        <StateVisualizer
          title="Effect with Empty Dependencies"
          state={{ mountTime }}
        >
          <div style={{
            background: '#d4edda',
            color: '#155724',
            padding: '1rem',
            borderRadius: '4px',
            marginBottom: '1rem',
          }}>
            ✅ This effect runs only once when the component mounts.
          </div>
          <p>
            <strong>Component mounted at:</strong> {mountTime}
          </p>
        </StateVisualizer>

        {/* Effect with dependencies */}
        <StateVisualizer
          title="Effect with Dependencies"
          state={{ name, greeting }}
        >
          <div className="form-group">
            <label>Enter your name:</label>
            <input
              className="input"
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Type your name..."
            />
          </div>
          
          {greeting && (
            <div style={{
              background: '#d1ecf1',
              color: '#0c5460',
              padding: '1rem',
              borderRadius: '4px',
              marginTop: '1rem',
            }}>
              {greeting}
            </div>
          )}
        </StateVisualizer>

        {/* Timer effect with cleanup */}
        <StateVisualizer
          title="Timer Effect with Cleanup"
          state={{ seconds, isTimerRunning }}
          actions={
            <>
              <button 
                className={`button ${isTimerRunning ? 'danger' : 'success'}`}
                onClick={() => setIsTimerRunning(!isTimerRunning)}
              >
                {isTimerRunning ? 'Stop Timer' : 'Start Timer'}
              </button>
              <button 
                className="button secondary" 
                onClick={resetTimer}
              >
                Reset
              </button>
            </>
          }
        >
          <div style={{
            fontSize: '2rem',
            fontWeight: 'bold',
            textAlign: 'center',
            padding: '1rem',
            background: isTimerRunning ? '#d4edda' : '#f8f9fa',
            color: isTimerRunning ? '#155724' : '#6c757d',
            borderRadius: '4px',
            marginBottom: '1rem',
          }}>
            {Math.floor(seconds / 60)}:{(seconds % 60).toString().padStart(2, '0')}
          </div>
          <p style={{ textAlign: 'center', margin: 0 }}>
            Timer is {isTimerRunning ? 'running' : 'stopped'}
          </p>
        </StateVisualizer>

        {/* Data fetching effect */}
        <StateVisualizer
          title="Data Fetching Effect"
          state={{ users: users.length, loading, error }}
          actions={
            <button 
              className="button" 
              onClick={fetchUsers}
              disabled={loading}
            >
              {loading ? 'Loading...' : 'Fetch Users'}
            </button>
          }
        >
          {loading && (
            <div style={{
              background: '#d1ecf1',
              color: '#0c5460',
              padding: '1rem',
              borderRadius: '4px',
              marginBottom: '1rem',
              textAlign: 'center',
            }}>
              🔄 Loading users...
            </div>
          )}
          
          {error && (
            <div style={{
              background: '#f8d7da',
              color: '#721c24',
              padding: '1rem',
              borderRadius: '4px',
              marginBottom: '1rem',
            }}>
              ❌ {error}
            </div>
          )}
          
          {users.length > 0 && (
            <div>
              <strong>Users ({users.length}):</strong>
              <div style={{ marginTop: '0.5rem' }}>
                {users.map(user => (
                  <div 
                    key={user.id}
                    style={{
                      background: '#f8f9fa',
                      padding: '0.5rem',
                      borderRadius: '4px',
                      marginBottom: '0.5rem',
                    }}
                  >
                    <strong>{user.name}</strong><br />
                    <small>{user.email}</small>
                  </div>
                ))}
              </div>
            </div>
          )}
        </StateVisualizer>

        {/* Window resize effect */}
        <StateVisualizer
          title="Window Resize Effect"
          state={windowSize}
        >
          <div style={{
            background: '#e2e3e5',
            color: '#383d41',
            padding: '1rem',
            borderRadius: '4px',
            textAlign: 'center',
          }}>
            <p style={{ margin: '0 0 0.5rem 0' }}>
              <strong>Current Window Size:</strong>
            </p>
            <p style={{ margin: 0, fontSize: '1.2rem', fontWeight: 'bold' }}>
              {windowSize.width} × {windowSize.height}
            </p>
            <p style={{ margin: '0.5rem 0 0 0', fontSize: '0.9rem' }}>
              Try resizing your browser window!
            </p>
          </div>
        </StateVisualizer>
      </div>

      <div className="card">
        <h2 style={{ color: '#2c3e50', marginBottom: '1rem' }}>
          💡 useEffect Patterns & Best Practices
        </h2>
        <div className="grid grid-2">
          <div>
            <h3 style={{ color: '#495057' }}>🎯 Dependency Array Patterns</h3>
            <ul style={{ paddingLeft: '1.5rem' }}>
              <li><code>useEffect(() => {})</code> - Runs on every render</li>
              <li><code>useEffect(() => {}, [])</code> - Runs once on mount</li>
              <li><code>useEffect(() => {}, [dep])</code> - Runs when dep changes</li>
              <li><code>useEffect(() => {}, [a, b])</code> - Runs when a or b changes</li>
            </ul>
          </div>
          <div>
            <h3 style={{ color: '#495057' }}>🧹 Cleanup Patterns</h3>
            <ul style={{ paddingLeft: '1.5rem' }}>
              <li>Clear timers and intervals</li>
              <li>Remove event listeners</li>
              <li>Cancel network requests</li>
              <li>Clean up subscriptions</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default UseEffectDemo;
