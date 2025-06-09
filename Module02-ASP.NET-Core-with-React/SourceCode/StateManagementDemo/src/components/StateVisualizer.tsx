import { ReactNode } from 'react';

interface StateVisualizerProps {
  title: string;
  state: any;
  children?: ReactNode;
  actions?: ReactNode;
}

const StateVisualizer = ({ title, state, children, actions }: StateVisualizerProps) => {
  return (
    <div className="card">
      <h3 style={{ 
        margin: '0 0 1rem 0', 
        color: '#2c3e50',
        display: 'flex',
        alignItems: 'center',
        gap: '0.5rem'
      }}>
        <span>🔍</span>
        {title}
      </h3>
      
      {children && (
        <div style={{ marginBottom: '1rem' }}>
          {children}
        </div>
      )}
      
      <div className="state-display">
        <strong>Current State:</strong>
        <pre>{JSON.stringify(state, null, 2)}</pre>
      </div>
      
      {actions && (
        <div style={{ 
          marginTop: '1rem',
          display: 'flex',
          gap: '0.5rem',
          flexWrap: 'wrap'
        }}>
          {actions}
        </div>
      )}
    </div>
  );
};

export default StateVisualizer;
