const Home = () => {
  return (
    <div>
      <div className="card text-center">
        <h1 style={{ 
          fontSize: '2.5rem', 
          margin: '0 0 1rem 0',
          background: 'linear-gradient(45deg, #667eea, #764ba2)',
          backgroundClip: 'text',
          WebkitBackgroundClip: 'text',
          WebkitTextFillColor: 'transparent'
        }}>
          🎯 React State Management Patterns
        </h1>
        <p style={{ fontSize: '1.2rem', color: '#6c757d', margin: '0 0 2rem 0' }}>
          Interactive demonstrations of different state management approaches in React
        </p>
      </div>

      <div className="grid grid-2">
        <div className="card">
          <h2 style={{ color: '#2c3e50', marginBottom: '1rem' }}>
            📚 What You'll Learn
          </h2>
          <ul style={{ 
            listStyle: 'none', 
            padding: 0, 
            margin: 0,
            display: 'flex',
            flexDirection: 'column',
            gap: '0.75rem'
          }}>
            <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span>📊</span> <strong>useState</strong> - Managing local component state
            </li>
            <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span>⚡</span> <strong>useEffect</strong> - Handling side effects and lifecycle
            </li>
            <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span>🌐</span> <strong>Context API</strong> - Sharing state across components
            </li>
            <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span>🔄</span> <strong>useReducer</strong> - Managing complex state logic
            </li>
            <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span>🎣</span> <strong>Custom Hooks</strong> - Creating reusable state logic
            </li>
            <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span>🕳️</span> <strong>Prop Drilling</strong> - Understanding the problem
            </li>
          </ul>
        </div>

        <div className="card">
          <h2 style={{ color: '#2c3e50', marginBottom: '1rem' }}>
            🎪 Interactive Features
          </h2>
          <ul style={{ 
            listStyle: 'none', 
            padding: 0, 
            margin: 0,
            display: 'flex',
            flexDirection: 'column',
            gap: '0.75rem'
          }}>
            <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span>🔍</span> <strong>State Visualization</strong> - See state changes in real-time
            </li>
            <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span>🎮</span> <strong>Interactive Controls</strong> - Buttons to trigger state changes
            </li>
            <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span>📱</span> <strong>Responsive Design</strong> - Works on all devices
            </li>
            <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span>💾</span> <strong>Persistent State</strong> - localStorage integration examples
            </li>
            <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span>🔄</span> <strong>Live Updates</strong> - Watch state propagate through components
            </li>
            <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span>🎨</span> <strong>Visual Feedback</strong> - Animations and transitions
            </li>
          </ul>
        </div>
      </div>

      <div className="card">
        <h2 style={{ color: '#2c3e50', marginBottom: '1rem' }}>
          🚀 Getting Started
        </h2>
        <div className="grid grid-3">
          <div style={{
            background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
            color: 'white',
            padding: '1.5rem',
            borderRadius: '8px',
            textAlign: 'center'
          }}>
            <h3 style={{ margin: '0 0 0.5rem 0' }}>1. Start Simple</h3>
            <p style={{ margin: 0, opacity: 0.9 }}>
              Begin with useState to understand local state management
            </p>
          </div>
          
          <div style={{
            background: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
            color: 'white',
            padding: '1.5rem',
            borderRadius: '8px',
            textAlign: 'center'
          }}>
            <h3 style={{ margin: '0 0 0.5rem 0' }}>2. Add Effects</h3>
            <p style={{ margin: 0, opacity: 0.9 }}>
              Learn useEffect for side effects and data fetching
            </p>
          </div>
          
          <div style={{
            background: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
            color: 'white',
            padding: '1.5rem',
            borderRadius: '8px',
            textAlign: 'center'
          }}>
            <h3 style={{ margin: '0 0 0.5rem 0' }}>3. Scale Up</h3>
            <p style={{ margin: 0, opacity: 0.9 }}>
              Explore Context API and useReducer for complex apps
            </p>
          </div>
        </div>
      </div>

      <div className="card">
        <h2 style={{ color: '#2c3e50', marginBottom: '1rem' }}>
          💡 Teaching Tips
        </h2>
        <div style={{ 
          background: '#f8f9fa', 
          padding: '1.5rem', 
          borderRadius: '8px',
          border: '1px solid #e9ecef'
        }}>
          <ul style={{ margin: 0, paddingLeft: '1.5rem' }}>
            <li style={{ marginBottom: '0.5rem' }}>
              <strong>Use React DevTools</strong> - Install the browser extension to inspect state changes
            </li>
            <li style={{ marginBottom: '0.5rem' }}>
              <strong>Open Console</strong> - Many examples log state changes for debugging
            </li>
            <li style={{ marginBottom: '0.5rem' }}>
              <strong>Compare Patterns</strong> - Navigate between examples to see different approaches
            </li>
            <li style={{ marginBottom: '0.5rem' }}>
              <strong>Experiment</strong> - Try breaking things to understand how state works
            </li>
            <li>
              <strong>Build Along</strong> - Use these examples as starting points for your own projects
            </li>
          </ul>
        </div>
      </div>

      <div className="text-center mt-4">
        <p style={{ 
          fontSize: '1.1rem', 
          color: '#495057',
          margin: 0
        }}>
          🎓 <strong>Ready to explore?</strong> Use the navigation above to start with any pattern!
        </p>
      </div>
    </div>
  );
};

export default Home;
