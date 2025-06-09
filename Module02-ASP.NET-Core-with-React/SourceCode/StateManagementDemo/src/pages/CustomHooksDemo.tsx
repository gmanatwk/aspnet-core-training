import { useState } from 'react';
import StateVisualizer from '../components/StateVisualizer';
import { useLocalStorage } from '../hooks/useLocalStorage';
import { useCounter } from '../hooks/useCounter';
import { useFetch } from '../hooks/useFetch';

const CustomHooksDemo = () => {
  // useLocalStorage hook demo
  const [name, setName] = useLocalStorage('demo-name', '');
  const [preferences, setPreferences] = useLocalStorage('demo-preferences', {
    theme: 'light',
    notifications: true,
    language: 'en',
  });

  // useCounter hook demo
  const counter1 = useCounter({ initialValue: 0, min: 0, max: 10, step: 1 });
  const counter2 = useCounter({ initialValue: 50, min: 0, max: 100, step: 5 });

  // useFetch hook demo
  const [selectedEndpoint, setSelectedEndpoint] = useState('/api/users');
  const { data, loading, error, refetch } = useFetch(selectedEndpoint, { immediate: false });

  const updatePreference = (key: string, value: any) => {
    setPreferences(prev => ({
      ...prev,
      [key]: value,
    }));
  };

  return (
    <div>
      <div className="card">
        <h1 style={{ margin: '0 0 1rem 0', color: '#2c3e50' }}>
          🎣 Custom Hooks Demonstrations
        </h1>
        <p style={{ color: '#6c757d', margin: 0 }}>
          Learn how to create reusable stateful logic with custom hooks.
          Custom hooks allow you to extract component logic into reusable functions
          that can be shared across multiple components.
        </p>
      </div>

      <div className="grid grid-2">
        {/* useLocalStorage Hook */}
        <StateVisualizer
          title="useLocalStorage Hook"
          state={{ name, preferences }}
          actions={
            <>
              <button 
                className="button secondary"
                onClick={() => {
                  setName('');
                  setPreferences({
                    theme: 'light',
                    notifications: true,
                    language: 'en',
                  });
                }}
              >
                Reset All
              </button>
            </>
          }
        >
          <div style={{ marginBottom: '1rem' }}>
            <div style={{
              background: '#d1ecf1',
              color: '#0c5460',
              padding: '0.75rem',
              borderRadius: '4px',
              fontSize: '0.9rem',
            }}>
              💾 Data is automatically saved to localStorage and persists across page reloads!
            </div>
          </div>

          <div className="form-group">
            <label>Your Name:</label>
            <input
              className="input"
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Enter your name"
            />
          </div>

          <fieldset style={{ border: '1px solid #dee2e6', borderRadius: '4px', padding: '1rem' }}>
            <legend style={{ fontWeight: 'bold', color: '#495057' }}>Preferences</legend>
            
            <div className="form-group">
              <label>Theme:</label>
              <select
                className="input"
                value={preferences.theme}
                onChange={(e) => updatePreference('theme', e.target.value)}
              >
                <option value="light">Light</option>
                <option value="dark">Dark</option>
                <option value="auto">Auto</option>
              </select>
            </div>

            <div className="form-group">
              <label>Language:</label>
              <select
                className="input"
                value={preferences.language}
                onChange={(e) => updatePreference('language', e.target.value)}
              >
                <option value="en">English</option>
                <option value="es">Spanish</option>
                <option value="fr">French</option>
                <option value="de">German</option>
              </select>
            </div>

            <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <input
                type="checkbox"
                checked={preferences.notifications}
                onChange={(e) => updatePreference('notifications', e.target.checked)}
              />
              Enable notifications
            </label>
          </fieldset>
        </StateVisualizer>

        {/* useCounter Hook */}
        <StateVisualizer
          title="useCounter Hook (with constraints)"
          state={{
            counter1: {
              value: counter1.count,
              isAtMin: counter1.isAtMin,
              isAtMax: counter1.isAtMax,
            },
            counter2: {
              value: counter2.count,
              isAtMin: counter2.isAtMin,
              isAtMax: counter2.isAtMax,
            },
          }}
        >
          <div style={{ marginBottom: '1.5rem' }}>
            <h4 style={{ margin: '0 0 0.5rem 0', color: '#495057' }}>
              Counter 1 (0-10, step: 1)
            </h4>
            <div style={{
              fontSize: '2rem',
              fontWeight: 'bold',
              textAlign: 'center',
              padding: '1rem',
              background: counter1.isAtMax ? '#f8d7da' : counter1.isAtMin ? '#fff3cd' : '#d4edda',
              color: counter1.isAtMax ? '#721c24' : counter1.isAtMin ? '#856404' : '#155724',
              borderRadius: '4px',
              marginBottom: '0.5rem',
            }}>
              {counter1.count}
            </div>
            <div style={{ display: 'flex', gap: '0.5rem', justifyContent: 'center' }}>
              <button 
                className="button danger"
                onClick={counter1.decrement}
                disabled={counter1.isAtMin}
              >
                -1
              </button>
              <button 
                className="button secondary"
                onClick={counter1.reset}
              >
                Reset
              </button>
              <button 
                className="button success"
                onClick={counter1.increment}
                disabled={counter1.isAtMax}
              >
                +1
              </button>
            </div>
          </div>

          <div>
            <h4 style={{ margin: '0 0 0.5rem 0', color: '#495057' }}>
              Counter 2 (0-100, step: 5)
            </h4>
            <div style={{
              fontSize: '2rem',
              fontWeight: 'bold',
              textAlign: 'center',
              padding: '1rem',
              background: counter2.isAtMax ? '#f8d7da' : counter2.isAtMin ? '#fff3cd' : '#d1ecf1',
              color: counter2.isAtMax ? '#721c24' : counter2.isAtMin ? '#856404' : '#0c5460',
              borderRadius: '4px',
              marginBottom: '0.5rem',
            }}>
              {counter2.count}
            </div>
            <div style={{ display: 'flex', gap: '0.5rem', justifyContent: 'center' }}>
              <button 
                className="button danger"
                onClick={counter2.decrement}
                disabled={counter2.isAtMin}
              >
                -5
              </button>
              <button 
                className="button secondary"
                onClick={counter2.reset}
              >
                Reset
              </button>
              <button 
                className="button success"
                onClick={counter2.increment}
                disabled={counter2.isAtMax}
              >
                +5
              </button>
            </div>
          </div>
        </StateVisualizer>

        {/* useFetch Hook */}
        <StateVisualizer
          title="useFetch Hook"
          state={{ 
            endpoint: selectedEndpoint,
            loading, 
            error, 
            dataLength: Array.isArray(data) ? data.length : data ? 1 : 0 
          }}
          actions={
            <>
              <button 
                className="button"
                onClick={refetch}
                disabled={loading}
              >
                {loading ? 'Loading...' : 'Fetch Data'}
              </button>
            </>
          }
        >
          <div className="form-group">
            <label>API Endpoint:</label>
            <select
              className="input"
              value={selectedEndpoint}
              onChange={(e) => setSelectedEndpoint(e.target.value)}
            >
              <option value="/api/users">Users</option>
              <option value="/api/posts">Posts</option>
              <option value="/api/products">Products</option>
            </select>
          </div>

          {loading && (
            <div style={{
              background: '#d1ecf1',
              color: '#0c5460',
              padding: '1rem',
              borderRadius: '4px',
              textAlign: 'center',
              margin: '1rem 0',
            }}>
              🔄 Loading data...
            </div>
          )}

          {error && (
            <div style={{
              background: '#f8d7da',
              color: '#721c24',
              padding: '1rem',
              borderRadius: '4px',
              margin: '1rem 0',
            }}>
              ❌ Error: {error}
            </div>
          )}

          {data && !loading && (
            <div style={{
              background: '#d4edda',
              color: '#155724',
              padding: '1rem',
              borderRadius: '4px',
              margin: '1rem 0',
            }}>
              <strong>✅ Data loaded successfully!</strong>
              <div style={{ marginTop: '0.5rem', fontSize: '0.9rem' }}>
                {Array.isArray(data) ? (
                  <div>
                    <p>Found {data.length} items:</p>
                    <ul style={{ margin: '0.5rem 0', paddingLeft: '1.5rem' }}>
                      {data.slice(0, 3).map((item: any, index) => (
                        <li key={index}>
                          {item.name || item.title || `Item ${item.id}`}
                        </li>
                      ))}
                      {data.length > 3 && <li>... and {data.length - 3} more</li>}
                    </ul>
                  </div>
                ) : (
                  <pre style={{ margin: 0, fontSize: '0.8rem' }}>
                    {JSON.stringify(data, null, 2)}
                  </pre>
                )}
              </div>
            </div>
          )}
        </StateVisualizer>

        {/* Custom Hook Benefits */}
        <div className="card">
          <h3 style={{ margin: '0 0 1rem 0', color: '#2c3e50' }}>
            🎯 Custom Hook Benefits
          </h3>
          <ul style={{ paddingLeft: '1.5rem', margin: 0 }}>
            <li><strong>Reusability:</strong> Share logic across components</li>
            <li><strong>Separation of Concerns:</strong> Keep components clean</li>
            <li><strong>Testability:</strong> Test logic independently</li>
            <li><strong>Composition:</strong> Combine multiple hooks</li>
            <li><strong>Abstraction:</strong> Hide complex implementation details</li>
          </ul>
        </div>
      </div>

      <div className="card">
        <h2 style={{ color: '#2c3e50', marginBottom: '1rem' }}>
          🛠️ Custom Hook Patterns
        </h2>
        <div className="grid grid-3">
          <div style={{
            background: '#d4edda',
            color: '#155724',
            padding: '1.5rem',
            borderRadius: '8px',
          }}>
            <h3 style={{ margin: '0 0 0.5rem 0' }}>💾 Data Persistence</h3>
            <p style={{ margin: 0, fontSize: '0.9rem' }}>
              useLocalStorage, useSessionStorage, useCookies
            </p>
          </div>
          
          <div style={{
            background: '#d1ecf1',
            color: '#0c5460',
            padding: '1.5rem',
            borderRadius: '8px',
          }}>
            <h3 style={{ margin: '0 0 0.5rem 0' }}>🌐 API Integration</h3>
            <p style={{ margin: 0, fontSize: '0.9rem' }}>
              useFetch, useApi, useQuery, useMutation
            </p>
          </div>
          
          <div style={{
            background: '#fff3cd',
            color: '#856404',
            padding: '1.5rem',
            borderRadius: '8px',
          }}>
            <h3 style={{ margin: '0 0 0.5rem 0' }}>🎮 UI Interactions</h3>
            <p style={{ margin: 0, fontSize: '0.9rem' }}>
              useToggle, useCounter, useForm, useModal
            </p>
          </div>
        </div>
      </div>

      <div className="card">
        <h2 style={{ color: '#2c3e50', marginBottom: '1rem' }}>
          📝 Creating Custom Hooks
        </h2>
        <div style={{
          background: '#f8f9fa',
          padding: '1.5rem',
          borderRadius: '8px',
          border: '1px solid #e9ecef',
        }}>
          <h3 style={{ margin: '0 0 1rem 0', color: '#495057' }}>Rules for Custom Hooks:</h3>
          <ol style={{ paddingLeft: '1.5rem', margin: 0 }}>
            <li style={{ marginBottom: '0.5rem' }}>
              <strong>Start with "use":</strong> Function name must begin with "use"
            </li>
            <li style={{ marginBottom: '0.5rem' }}>
              <strong>Call hooks at the top level:</strong> Don't call hooks inside loops, conditions, or nested functions
            </li>
            <li style={{ marginBottom: '0.5rem' }}>
              <strong>Return consistent values:</strong> Always return the same structure
            </li>
            <li style={{ marginBottom: '0.5rem' }}>
              <strong>Handle cleanup:</strong> Use useEffect cleanup for subscriptions, timers, etc.
            </li>
            <li>
              <strong>Keep it focused:</strong> Each hook should have a single responsibility
            </li>
          </ol>
        </div>
      </div>
    </div>
  );
};

export default CustomHooksDemo;
