import { ReactNode } from 'react';
import { Link, useLocation } from 'react-router-dom';

interface LayoutProps {
  children: ReactNode;
}

const Layout = ({ children }: LayoutProps) => {
  const location = useLocation();

  const navItems = [
    { path: '/', label: '🏠 Home', description: 'Overview' },
    { path: '/usestate', label: '📊 useState', description: 'Local State' },
    { path: '/useeffect', label: '⚡ useEffect', description: 'Side Effects' },
    { path: '/context', label: '🌐 Context', description: 'Global State' },
    { path: '/usereducer', label: '🔄 useReducer', description: 'Complex State' },
    { path: '/custom-hooks', label: '🎣 Custom Hooks', description: 'Reusable Logic' },
    { path: '/prop-drilling', label: '🕳️ Prop Drilling', description: 'Anti-Pattern' },
  ];

  const isActive = (path: string) => location.pathname === path;

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      {/* Header */}
      <header style={{
        background: 'rgba(255, 255, 255, 0.95)',
        backdropFilter: 'blur(10px)',
        borderBottom: '1px solid rgba(255, 255, 255, 0.2)',
        padding: '1rem 0',
        position: 'sticky',
        top: 0,
        zIndex: 100,
        boxShadow: '0 2px 10px rgba(0, 0, 0, 0.1)'
      }}>
        <div className="container">
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            flexWrap: 'wrap',
            gap: '1rem'
          }}>
            <div>
              <h1 style={{
                margin: 0,
                background: 'linear-gradient(45deg, #667eea, #764ba2)',
                backgroundClip: 'text',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
                fontSize: '1.8rem',
                fontWeight: 700
              }}>
                ⚛️ React State Management Demo
              </h1>
              <p style={{
                margin: '0.25rem 0 0 0',
                color: '#6c757d',
                fontSize: '0.9rem'
              }}>
                Interactive examples for learning React state patterns
              </p>
            </div>
            
            <div style={{
              background: 'linear-gradient(45deg, #667eea, #764ba2)',
              color: 'white',
              padding: '0.5rem 1rem',
              borderRadius: '20px',
              fontSize: '0.9rem',
              fontWeight: 500
            }}>
              Port: 3002
            </div>
          </div>
        </div>
      </header>

      {/* Navigation */}
      <nav style={{
        background: 'rgba(255, 255, 255, 0.9)',
        borderBottom: '1px solid rgba(0, 0, 0, 0.1)',
        padding: '0.75rem 0',
        position: 'sticky',
        top: '80px',
        zIndex: 99
      }}>
        <div className="container">
          <div style={{
            display: 'flex',
            gap: '0.5rem',
            flexWrap: 'wrap',
            justifyContent: 'center'
          }}>
            {navItems.map((item) => (
              <Link
                key={item.path}
                to={item.path}
                style={{
                  textDecoration: 'none',
                  padding: '0.5rem 1rem',
                  borderRadius: '8px',
                  fontSize: '0.9rem',
                  fontWeight: 500,
                  transition: 'all 0.2s ease',
                  background: isActive(item.path) 
                    ? 'linear-gradient(45deg, #667eea, #764ba2)' 
                    : 'transparent',
                  color: isActive(item.path) ? 'white' : '#495057',
                  border: isActive(item.path) 
                    ? 'none' 
                    : '1px solid rgba(0, 0, 0, 0.1)',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  minWidth: '100px',
                  textAlign: 'center'
                }}
                onMouseEnter={(e) => {
                  if (!isActive(item.path)) {
                    e.currentTarget.style.background = 'rgba(102, 126, 234, 0.1)';
                    e.currentTarget.style.transform = 'translateY(-1px)';
                  }
                }}
                onMouseLeave={(e) => {
                  if (!isActive(item.path)) {
                    e.currentTarget.style.background = 'transparent';
                    e.currentTarget.style.transform = 'translateY(0)';
                  }
                }}
              >
                <span style={{ fontSize: '1rem', marginBottom: '0.25rem' }}>
                  {item.label}
                </span>
                <span style={{ 
                  fontSize: '0.7rem', 
                  opacity: 0.8,
                  fontWeight: 400 
                }}>
                  {item.description}
                </span>
              </Link>
            ))}
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <main style={{ flex: 1, padding: '2rem 0' }}>
        <div className="container">
          {children}
        </div>
      </main>

      {/* Footer */}
      <footer style={{
        background: 'rgba(44, 62, 80, 0.95)',
        color: 'white',
        padding: '1.5rem 0',
        textAlign: 'center'
      }}>
        <div className="container">
          <p style={{ margin: '0 0 0.5rem 0' }}>
            Module 02 - React State Management Patterns
          </p>
          <p style={{ 
            margin: 0, 
            fontSize: '0.9rem', 
            opacity: 0.8 
          }}>
            Built with ❤️ for learning React state management
          </p>
        </div>
      </footer>
    </div>
  );
};

export default Layout;
