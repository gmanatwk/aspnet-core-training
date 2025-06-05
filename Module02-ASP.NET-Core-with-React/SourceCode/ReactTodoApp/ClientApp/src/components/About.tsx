import React from 'react';

const About: React.FC = () => {
  return (
    <div className="todo-container">
      <h2>About This Application</h2>
      
      <div className="about-content">
        <p>
          This is a comprehensive Todo application built as part of <strong>Module 02: ASP.NET Core with React</strong>
          in the ASP.NET Core training program.
        </p>

        <h3 className="about-section-title">
          🎯 Learning Objectives
        </h3>
        <ul className="about-list">
          <li>Integration of React frontend with ASP.NET Core backend</li>
          <li>RESTful API design and implementation</li>
          <li>State management in React applications</li>
          <li>Routing with React Router</li>
          <li>HTTP client communication with Axios</li>
          <li>TypeScript for type-safe development</li>
          <li>Modern build tools (Vite) integration</li>
          <li>Docker containerization for full-stack applications</li>
        </ul>

        <h3 className="about-section-title">
          🛠 Technology Stack
        </h3>
        <div className="tech-stack-grid">
          <div className="tech-stack-card">
            <h4 className="tech-stack-title">Backend</h4>
            <ul className="tech-stack-list">
              <li>• ASP.NET Core 8.0</li>
              <li>• Web API Controllers</li>
              <li>• Swagger/OpenAPI</li>
              <li>• Dependency Injection</li>
              <li>• CORS Configuration</li>
            </ul>
          </div>

          <div className="tech-stack-card">
            <h4 className="tech-stack-title">Frontend</h4>
            <ul className="tech-stack-list">
              <li>• React 18</li>
              <li>• TypeScript</li>
              <li>• React Router</li>
              <li>• Axios HTTP Client</li>
              <li>• Vite Build Tool</li>
            </ul>
          </div>
        </div>

        <h3 className="about-section-title">
          🚀 Features Implemented
        </h3>
        <div className="features-grid">
          <div>
            <h4 className="feature-title feature-title-success">✅ Core Functionality</h4>
            <ul>
              <li>Create, read, update, delete todos</li>
              <li>Toggle completion status</li>
              <li>Priority levels (Low, Medium, High, Urgent)</li>
              <li>Categories for organization</li>
              <li>Detailed descriptions</li>
            </ul>
          </div>

          <div>
            <h4 className="feature-title feature-title-success">✅ Advanced Features</h4>
            <ul>
              <li>Real-time filtering and search</li>
              <li>Statistics and analytics</li>
              <li>Responsive design</li>
              <li>Error handling and loading states</li>
              <li>API documentation with Swagger</li>
            </ul>
          </div>
        </div>

        <h3 className="about-section-title">
          📚 Exercise Progression
        </h3>
        <div className="exercise-progression-box">
          <p><strong>Exercise 1:</strong> Basic Integration - Set up React with ASP.NET Core</p>
          <p><strong>Exercise 2:</strong> State Management & Routing - Add React Router and advanced state</p>
          <p><strong>Exercise 3:</strong> API Integration & Performance - Optimize API calls and add features</p>
          <p><strong>Exercise 4:</strong> Docker Integration - Containerize the full-stack application</p>
        </div>

        <h3 className="about-section-title">
          🔗 Useful Links
        </h3>
        <div className="useful-links">
          <a
            href="/swagger"
            target="_blank"
            rel="noopener noreferrer"
            className="link-button link-button-primary"
          >
            📖 API Documentation
          </a>
          <a
            href="https://reactjs.org/docs"
            target="_blank"
            rel="noopener noreferrer"
            className="link-button link-button-react"
          >
            ⚛️ React Docs
          </a>
          <a
            href="https://docs.microsoft.com/en-us/aspnet/core/"
            target="_blank"
            rel="noopener noreferrer"
            className="link-button link-button-dotnet"
          >
            🔷 ASP.NET Core Docs
          </a>
        </div>

        <div className="pro-tip-box">
          <p className="pro-tip-text">
            <strong>💡 Pro Tip:</strong> Use the browser's developer tools to inspect network requests
            and see how the React frontend communicates with the ASP.NET Core API!
          </p>
        </div>
      </div>
    </div>
  );
};

export default About;
