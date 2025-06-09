import Link from 'next/link';
import { useRouter } from 'next/router';
import { ReactNode } from 'react';

interface LayoutProps {
  children: ReactNode;
}

export default function Layout({ children }: LayoutProps) {
  const router = useRouter();

  const isActive = (path: string) => router.pathname === path;

  return (
    <div className="layout">
      <header className="header">
        <div className="container">
          <div className="header-content">
            <h1 className="logo">
              <Link href="/">Next.js Todo (SSR)</Link>
            </h1>
            
            <nav className="nav">
              <Link 
                href="/" 
                className={`nav-link ${isActive('/') ? 'active' : ''}`}
              >
                Todos
              </Link>
              <Link 
                href="/stats" 
                className={`nav-link ${isActive('/stats') ? 'active' : ''}`}
              >
                Statistics
              </Link>
              <Link 
                href="/about" 
                className={`nav-link ${isActive('/about') ? 'active' : ''}`}
              >
                About SSR
              </Link>
              <a 
                href="http://localhost:5000/swagger" 
                target="_blank" 
                rel="noopener noreferrer" 
                className="nav-link external"
              >
                API Docs ↗
              </a>
              <a 
                href="http://localhost:5173" 
                target="_blank" 
                rel="noopener noreferrer" 
                className="nav-link external csr-link"
              >
                CSR Version ↗
              </a>
            </nav>
          </div>
        </div>
      </header>

      <main className="main">
        <div className="container">
          {children}
        </div>
      </main>

      <footer className="footer">
        <div className="container">
          <p>
            Module 02 - Next.js SSR Demo | 
            <span className="highlight"> Server-Side Rendered</span> | 
            Built with ❤️ for learning
          </p>
          <p className="tech-info">
            Next.js {process.env.NODE_ENV === 'development' ? 'Development' : 'Production'} Mode
          </p>
        </div>
      </footer>

      <style jsx>{`
        .layout {
          min-height: 100vh;
          display: flex;
          flex-direction: column;
        }

        .header {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
          padding: 1rem 0;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .container {
          max-width: 1200px;
          margin: 0 auto;
          padding: 0 1rem;
        }

        .header-content {
          display: flex;
          justify-content: space-between;
          align-items: center;
          flex-wrap: wrap;
          gap: 1rem;
        }

        .logo {
          margin: 0;
          font-size: 1.5rem;
          font-weight: 700;
        }

        .logo a {
          color: white;
          text-decoration: none;
        }

        .nav {
          display: flex;
          gap: 1.5rem;
          align-items: center;
          flex-wrap: wrap;
        }

        .nav-link {
          color: white;
          text-decoration: none;
          padding: 0.5rem 1rem;
          border-radius: 4px;
          transition: all 0.2s ease;
          font-weight: 500;
        }

        .nav-link:hover {
          background: rgba(255, 255, 255, 0.1);
          transform: translateY(-1px);
        }

        .nav-link.active {
          background: rgba(255, 255, 255, 0.2);
          font-weight: 600;
        }

        .nav-link.external {
          background: rgba(255, 255, 255, 0.1);
          border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .nav-link.csr-link {
          background: rgba(255, 193, 7, 0.2);
          border: 1px solid rgba(255, 193, 7, 0.5);
        }

        .main {
          flex: 1;
          padding: 2rem 0;
          background: #f8f9fa;
        }

        .footer {
          background: #2c3e50;
          color: white;
          padding: 1.5rem 0;
          text-align: center;
        }

        .footer p {
          margin: 0.25rem 0;
        }

        .highlight {
          background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
          background-clip: text;
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
          font-weight: 600;
        }

        .tech-info {
          font-size: 0.9rem;
          opacity: 0.8;
        }

        @media (max-width: 768px) {
          .header-content {
            flex-direction: column;
            text-align: center;
          }

          .nav {
            justify-content: center;
          }

          .nav-link {
            padding: 0.4rem 0.8rem;
            font-size: 0.9rem;
          }

          .main {
            padding: 1rem 0;
          }
        }
      `}</style>

      <style jsx global>{`
        * {
          box-sizing: border-box;
        }

        body {
          margin: 0;
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
            'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
            sans-serif;
          -webkit-font-smoothing: antialiased;
          -moz-osx-font-smoothing: grayscale;
          background: #f8f9fa;
        }

        a {
          color: inherit;
          text-decoration: none;
        }

        button {
          font-family: inherit;
        }
      `}</style>
    </div>
  );
}
