import Head from 'next/head';
import Link from 'next/link';

export default function About() {
  return (
    <>
      <Head>
        <title>About SSR - Next.js Demo</title>
        <meta name="description" content="Learn about Server-Side Rendering with Next.js and ASP.NET Core" />
      </Head>

      <div className="about-container">
        <div className="hero-section">
          <h1>🚀 Server-Side Rendering (SSR) Demo</h1>
          <p className="hero-subtitle">
            Understanding the difference between SSR and CSR with practical examples
          </p>
        </div>

        <div className="comparison-section">
          <h2>📊 SSR vs CSR Comparison</h2>
          
          <div className="comparison-grid">
            <div className="comparison-card ssr">
              <h3>🖥️ Server-Side Rendering (SSR)</h3>
              <p className="card-subtitle">This Next.js Application</p>
              
              <div className="features">
                <div className="feature">
                  <span className="feature-icon">⚡</span>
                  <div>
                    <strong>Faster Initial Load</strong>
                    <p>HTML is pre-rendered on the server</p>
                  </div>
                </div>
                
                <div className="feature">
                  <span className="feature-icon">🔍</span>
                  <div>
                    <strong>Better SEO</strong>
                    <p>Search engines see complete content</p>
                  </div>
                </div>
                
                <div className="feature">
                  <span className="feature-icon">📱</span>
                  <div>
                    <strong>Better Performance on Slow Devices</strong>
                    <p>Less JavaScript processing on client</p>
                  </div>
                </div>
                
                <div className="feature">
                  <span className="feature-icon">🌐</span>
                  <div>
                    <strong>Works Without JavaScript</strong>
                    <p>Basic functionality available immediately</p>
                  </div>
                </div>
              </div>
              
              <div className="demo-link">
                <p><strong>You're viewing this now!</strong></p>
                <p>Port: <code>3001</code></p>
              </div>
            </div>

            <div className="comparison-card csr">
              <h3>💻 Client-Side Rendering (CSR)</h3>
              <p className="card-subtitle">The React SPA Version</p>
              
              <div className="features">
                <div className="feature">
                  <span className="feature-icon">🔄</span>
                  <div>
                    <strong>Dynamic Interactions</strong>
                    <p>Rich client-side interactions after load</p>
                  </div>
                </div>
                
                <div className="feature">
                  <span className="feature-icon">📦</span>
                  <div>
                    <strong>Smaller Server Load</strong>
                    <p>Static files served, processing on client</p>
                  </div>
                </div>
                
                <div className="feature">
                  <span className="feature-icon">🛠️</span>
                  <div>
                    <strong>Simpler Deployment</strong>
                    <p>Static files can be served from CDN</p>
                  </div>
                </div>
                
                <div className="feature">
                  <span className="feature-icon">⚙️</span>
                  <div>
                    <strong>Better Development Experience</strong>
                    <p>Hot reload and simpler debugging</p>
                  </div>
                </div>
              </div>
              
              <div className="demo-link">
                <a 
                  href="http://localhost:5173" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="csr-link"
                >
                  View CSR Version →
                </a>
                <p>Port: <code>5173</code></p>
              </div>
            </div>
          </div>
        </div>

        <div className="technical-section">
          <h2>🔧 Technical Implementation</h2>
          
          <div className="tech-grid">
            <div className="tech-card">
              <h3>SSR Implementation (This App)</h3>
              <ul>
                <li><strong>Framework:</strong> Next.js 14</li>
                <li><strong>Rendering:</strong> getServerSideProps</li>
                <li><strong>Data Fetching:</strong> Server-side API calls</li>
                <li><strong>Hydration:</strong> Client-side React takes over</li>
                <li><strong>Port:</strong> 3001</li>
              </ul>
            </div>
            
            <div className="tech-card">
              <h3>CSR Implementation</h3>
              <ul>
                <li><strong>Framework:</strong> React + Vite</li>
                <li><strong>Rendering:</strong> Client-side only</li>
                <li><strong>Data Fetching:</strong> useEffect + API calls</li>
                <li><strong>Loading:</strong> Shows loading states</li>
                <li><strong>Port:</strong> 5173</li>
              </ul>
            </div>
          </div>
        </div>

        <div className="demo-section">
          <h2>🧪 Try the Comparison</h2>
          
          <div className="demo-instructions">
            <div className="instruction-card">
              <h3>1. View Page Source</h3>
              <p>Right-click → "View Page Source" on both applications:</p>
              <ul>
                <li><strong>SSR (this app):</strong> You'll see complete HTML with todo data</li>
                <li><strong>CSR (React app):</strong> You'll see mostly empty HTML with just a div</li>
              </ul>
            </div>
            
            <div className="instruction-card">
              <h3>2. Disable JavaScript</h3>
              <p>In Chrome DevTools → Settings → Preferences → Debugger → Disable JavaScript:</p>
              <ul>
                <li><strong>SSR:</strong> Content still visible (though not interactive)</li>
                <li><strong>CSR:</strong> Blank page</li>
              </ul>
            </div>
            
            <div className="instruction-card">
              <h3>3. Network Throttling</h3>
              <p>DevTools → Network → Throttling → Slow 3G:</p>
              <ul>
                <li><strong>SSR:</strong> Content appears immediately</li>
                <li><strong>CSR:</strong> Loading delay while JavaScript downloads</li>
              </ul>
            </div>
          </div>
        </div>

        <div className="decision-section">
          <h2>🤔 When to Use Each Approach</h2>
          
          <div className="decision-grid">
            <div className="decision-card">
              <h3>Choose SSR When:</h3>
              <ul>
                <li>SEO is critical (public websites)</li>
                <li>Initial load performance matters</li>
                <li>Content-heavy applications</li>
                <li>Supporting slow devices/networks</li>
                <li>E-commerce or marketing sites</li>
              </ul>
            </div>
            
            <div className="decision-card">
              <h3>Choose CSR When:</h3>
              <ul>
                <li>Building internal tools/dashboards</li>
                <li>Highly interactive applications</li>
                <li>SEO is not important</li>
                <li>Simpler deployment requirements</li>
                <li>Team prefers SPA development</li>
              </ul>
            </div>
          </div>
        </div>

        <div className="navigation-section">
          <h2>🧭 Explore the Demo</h2>
          <div className="nav-links">
            <Link href="/" className="nav-button primary">
              📋 View Todos (SSR)
            </Link>
            <Link href="/stats" className="nav-button secondary">
              📊 Statistics (SSR)
            </Link>
            <a 
              href="http://localhost:5173" 
              target="_blank" 
              rel="noopener noreferrer"
              className="nav-button csr"
            >
              💻 React SPA (CSR) →
            </a>
          </div>
        </div>
      </div>

      <style jsx>{`
        .about-container {
          max-width: 1000px;
          margin: 0 auto;
        }

        .hero-section {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
          padding: 3rem 2rem;
          border-radius: 8px;
          text-align: center;
          margin-bottom: 3rem;
        }

        .hero-section h1 {
          margin: 0 0 1rem 0;
          font-size: 2.5rem;
        }

        .hero-subtitle {
          margin: 0;
          font-size: 1.2rem;
          opacity: 0.9;
        }

        .comparison-section,
        .technical-section,
        .demo-section,
        .decision-section,
        .navigation-section {
          margin-bottom: 3rem;
        }

        .comparison-section h2,
        .technical-section h2,
        .demo-section h2,
        .decision-section h2,
        .navigation-section h2 {
          color: #2c3e50;
          margin-bottom: 2rem;
          font-size: 1.8rem;
        }

        .comparison-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 2rem;
        }

        .comparison-card {
          background: white;
          padding: 2rem;
          border-radius: 8px;
          border: 1px solid #e1e5e9;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .comparison-card.ssr {
          border-top: 4px solid #28a745;
        }

        .comparison-card.csr {
          border-top: 4px solid #007bff;
        }

        .comparison-card h3 {
          margin: 0 0 0.5rem 0;
          font-size: 1.3rem;
        }

        .card-subtitle {
          color: #6c757d;
          margin: 0 0 1.5rem 0;
          font-style: italic;
        }

        .features {
          display: flex;
          flex-direction: column;
          gap: 1rem;
          margin-bottom: 1.5rem;
        }

        .feature {
          display: flex;
          align-items: flex-start;
          gap: 0.75rem;
        }

        .feature-icon {
          font-size: 1.2rem;
          margin-top: 0.2rem;
        }

        .feature strong {
          display: block;
          margin-bottom: 0.25rem;
          color: #2c3e50;
        }

        .feature p {
          margin: 0;
          color: #6c757d;
          font-size: 0.9rem;
        }

        .demo-link {
          background: #f8f9fa;
          padding: 1rem;
          border-radius: 4px;
          text-align: center;
        }

        .demo-link p {
          margin: 0.25rem 0;
        }

        .csr-link {
          color: #007bff;
          text-decoration: none;
          font-weight: 600;
        }

        .csr-link:hover {
          text-decoration: underline;
        }

        .tech-grid,
        .decision-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 2rem;
        }

        .tech-card,
        .decision-card {
          background: white;
          padding: 2rem;
          border-radius: 8px;
          border: 1px solid #e1e5e9;
        }

        .tech-card h3,
        .decision-card h3 {
          margin: 0 0 1rem 0;
          color: #2c3e50;
        }

        .tech-card ul,
        .decision-card ul {
          margin: 0;
          padding-left: 1.5rem;
        }

        .tech-card li,
        .decision-card li {
          margin-bottom: 0.5rem;
        }

        .demo-instructions {
          display: grid;
          gap: 1.5rem;
        }

        .instruction-card {
          background: white;
          padding: 2rem;
          border-radius: 8px;
          border: 1px solid #e1e5e9;
        }

        .instruction-card h3 {
          margin: 0 0 1rem 0;
          color: #2c3e50;
        }

        .instruction-card ul {
          margin: 0.5rem 0 0 1.5rem;
        }

        .nav-links {
          display: flex;
          gap: 1rem;
          justify-content: center;
          flex-wrap: wrap;
        }

        .nav-button {
          padding: 1rem 2rem;
          border-radius: 8px;
          text-decoration: none;
          font-weight: 600;
          transition: all 0.2s ease;
          display: inline-block;
        }

        .nav-button.primary {
          background: #007bff;
          color: white;
        }

        .nav-button.secondary {
          background: #6c757d;
          color: white;
        }

        .nav-button.csr {
          background: #28a745;
          color: white;
        }

        .nav-button:hover {
          transform: translateY(-2px);
          box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }

        code {
          background: #f8f9fa;
          padding: 0.2rem 0.4rem;
          border-radius: 3px;
          font-family: 'Monaco', 'Consolas', monospace;
          font-size: 0.9rem;
        }

        @media (max-width: 768px) {
          .comparison-grid,
          .tech-grid,
          .decision-grid {
            grid-template-columns: 1fr;
          }

          .hero-section {
            padding: 2rem 1rem;
          }

          .hero-section h1 {
            font-size: 2rem;
          }

          .nav-links {
            flex-direction: column;
            align-items: center;
          }

          .nav-button {
            width: 100%;
            max-width: 300px;
            text-align: center;
          }
        }
      `}</style>
    </>
  );
}
