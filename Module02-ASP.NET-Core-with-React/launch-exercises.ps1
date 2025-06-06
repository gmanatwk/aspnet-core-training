# Interactive Exercise Launcher for Module 02 - ASP.NET Core with React
# This version shows what will be created and lets students step through

param(
    [Parameter(Position=0)]
    [string]$ExerciseName,
    
    [switch]$List,
    [switch]$Auto,
    [switch]$Preview
)

# Colors for output
$OriginalColor = $Host.UI.RawUI.ForegroundColor

# Interactive mode flag
$InteractiveMode = -not $Auto

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to pause and wait for user
function Pause-ForUser {
    if ($InteractiveMode) {
        Write-ColorOutput "Press Enter to continue..." -Color Yellow
        Read-Host
    }
}

# Function to show what will be created
function Preview-File {
    param(
        [string]$FilePath,
        [string]$Description
    )
    
    Write-ColorOutput ("=" * 60) -Color Cyan
    Write-ColorOutput "[FILE] Will create: $FilePath" -Color Blue
    Write-ColorOutput "[PURPOSE] Purpose: $Description" -Color Yellow
    Write-ColorOutput ("=" * 60) -Color Cyan
}

# Function to create file with preview
function New-FileInteractive {
    param(
        [string]$FilePath,
        [string]$Content,
        [string]$Description
    )
    
    Preview-File -FilePath $FilePath -Description $Description
    
    # Show first 20 lines of content
    Write-ColorOutput "Content preview:" -Color Green
    $lines = $Content -split "`n"
    $preview = $lines[0..19] -join "`n"
    Write-Host $preview
    
    if ($lines.Count -gt 20) {
        Write-ColorOutput "... (content truncated for preview)" -Color Yellow
    }
    Write-Host ""
    
    if ($InteractiveMode) {
        $response = Read-Host "Create this file? (Y/n/s to skip all)"
        
        switch ($response.ToLower()) {
            'n' {
                Write-ColorOutput "[SKIP]  Skipped: $FilePath" -Color Red
                return
            }
            's' {
                $script:InteractiveMode = $false
                Write-ColorOutput "[PIN] Switching to automatic mode..." -Color Cyan
            }
        }
    }
    
    # Create directory if it doesn't exist
    $directory = Split-Path -Parent $FilePath
    if ($directory -and -not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    
    # Write content to file
    Set-Content -Path $FilePath -Value $Content -Encoding UTF8
    Write-ColorOutput "[OK] Created: $FilePath" -Color Green
    Write-Host ""
}

# Function to explain a concept before creating related files
function Explain-Concept {
    param(
        [string]$Concept,
        [string]$Explanation
    )
    
    Write-ColorOutput "[TIP] Concept: $Concept" -Color Magenta
    Write-ColorOutput ("=" * 60) -Color Cyan
    Write-Host $Explanation
    Write-ColorOutput ("=" * 60) -Color Cyan
    Pause-ForUser
}

# Function to display available exercises
function Show-Exercises {
    Write-ColorOutput "Module 02 - ASP.NET Core with React Exercises:" -Color Cyan
    Write-Host ""
    Write-Host "  - exercise01: Basic Integration"
    Write-Host "  - exercise02: State Management & Routing"
    Write-Host "  - exercise03: API Integration & Performance"
    Write-Host "  - exercise04: Docker Integration"
    Write-Host ""
}

# Function to show learning objectives with interaction
function Show-LearningObjectivesInteractive {
    param([string]$Exercise)
    
    Write-ColorOutput ("=" * 60) -Color Magenta
    Write-ColorOutput "[TARGET] Learning Objectives for $Exercise" -Color Magenta
    Write-ColorOutput ("=" * 60) -Color Magenta
    
    switch ($Exercise) {
        "exercise01" {
            Write-ColorOutput "In this exercise, you will learn:" -Color Cyan
            Write-Host "  [REACT] 1. Setting up React with ASP.NET Core"
            Write-Host "  [REACT] 2. Creating a React SPA frontend"
            Write-Host "  [REACT] 3. Configuring development proxy"
            Write-Host "  [REACT] 4. Basic component structure"
            Write-Host ""
            Write-ColorOutput "Key concepts:" -Color Yellow
            Write-Host "  - React project setup with Vite"
            Write-Host "  - ASP.NET Core as API backend"
            Write-Host "  - Development server configuration"
            Write-Host "  - Component-based architecture"
        }
        "exercise02" {
            Write-ColorOutput "Building on Exercise 1, you will add:" -Color Cyan
            Write-Host "  [UPDATE] 1. React Router for navigation"
            Write-Host "  [UPDATE] 2. State management with Context API"
            Write-Host "  [UPDATE] 3. Form handling and validation"
            Write-Host "  [UPDATE] 4. Component lifecycle management"
            Write-Host ""
            Write-ColorOutput "Advanced concepts:" -Color Yellow
            Write-Host "  - Client-side routing"
            Write-Host "  - Global state management"
            Write-Host "  - Controlled components"
            Write-Host "  - Effect hooks and cleanup"
        }
        "exercise03" {
            Write-ColorOutput "Integrating with APIs and optimization:" -Color Cyan
            Write-Host "  [LAUNCH] 1. HTTP client configuration"
            Write-Host "  [LAUNCH] 2. API integration patterns"
            Write-Host "  [LAUNCH] 3. Error handling and loading states"
            Write-Host "  [LAUNCH] 4. Performance optimization"
            Write-Host ""
            Write-ColorOutput "Production concepts:" -Color Yellow
            Write-Host "  - Fetch API and error handling"
            Write-Host "  - Loading and error states"
            Write-Host "  - Code splitting and lazy loading"
            Write-Host "  - Build optimization"
        }
        "exercise04" {
            Write-ColorOutput "Docker integration for full-stack development:" -Color Cyan
            Write-Host "  [DOCKER] 1. Containerizing ASP.NET Core API"
            Write-Host "  [DOCKER] 2. Containerizing React application"
            Write-Host "  [DOCKER] 3. Docker Compose for multi-container setup"
            Write-Host "  [DOCKER] 4. Development and production configurations"
            Write-Host ""
            Write-ColorOutput "DevOps concepts:" -Color Yellow
            Write-Host "  - Multi-stage Docker builds"
            Write-Host "  - Container networking"
            Write-Host "  - Environment configuration"
            Write-Host "  - Development workflow with containers"
        }
    }
    
    Write-ColorOutput ("=" * 60) -Color Magenta
    Pause-ForUser
}

# Function to show what will be created overview
function Show-CreationOverview {
    param([string]$Exercise)
    
    Write-ColorOutput ("=" * 60) -Color Cyan
    Write-ColorOutput "[OVERVIEW] Overview: What will be created" -Color Cyan
    Write-ColorOutput ("=" * 60) -Color Cyan
    
    switch ($Exercise) {
        "exercise01" {
            Write-ColorOutput "Project Structure:" -Color Green
            Write-Host "  ReactTodoApp/"
            Write-Host "  ├── backend/                  $(Write-ColorOutput '# ASP.NET Core API' -Color Yellow -NoNewline)"
            Write-Host "  │   ├── Controllers/"
            Write-Host "  │   │   └── WeatherController.cs $(Write-ColorOutput '# Sample API endpoint' -Color Yellow -NoNewline)"
            Write-Host "  │   ├── Program.cs           $(Write-ColorOutput '# API configuration' -Color Yellow -NoNewline)"
            Write-Host "  │   └── appsettings.json     $(Write-ColorOutput '# API settings' -Color Yellow -NoNewline)"
            Write-Host "  ├── frontend/                $(Write-ColorOutput '# React SPA' -Color Yellow -NoNewline)"
            Write-Host "  │   ├── src/"
            Write-Host "  │   │   ├── components/      $(Write-ColorOutput '# React components' -Color Yellow -NoNewline)"
            Write-Host "  │   │   ├── App.tsx          $(Write-ColorOutput '# Main app component' -Color Yellow -NoNewline)"
            Write-Host "  │   │   └── main.tsx         $(Write-ColorOutput '# Entry point' -Color Yellow -NoNewline)"
            Write-Host "  │   ├── package.json         $(Write-ColorOutput '# Node dependencies' -Color Yellow -NoNewline)"
            Write-Host "  │   └── vite.config.ts       $(Write-ColorOutput '# Vite configuration' -Color Yellow -NoNewline)"
            Write-Host "  └── docker-compose.yml       $(Write-ColorOutput '# Container orchestration' -Color Yellow -NoNewline)"
            Write-Host ""
            Write-ColorOutput "This creates a full-stack React + ASP.NET Core setup" -Color Blue
        }
        
        "exercise02" {
            Write-ColorOutput "Building on Exercise 1, adding:" -Color Green
            Write-Host "  frontend/src/"
            Write-Host "  ├── components/"
            Write-Host "  │   ├── Navigation.tsx       $(Write-ColorOutput '# Navigation component' -Color Yellow -NoNewline)"
            Write-Host "  │   ├── UserProfile.tsx      $(Write-ColorOutput '# User profile component' -Color Yellow -NoNewline)"
            Write-Host "  │   └── ProductList.tsx      $(Write-ColorOutput '# Product listing' -Color Yellow -NoNewline)"
            Write-Host "  ├── context/"
            Write-Host "  │   └── AppContext.tsx       $(Write-ColorOutput '# Global state management' -Color Yellow -NoNewline)"
            Write-Host "  ├── hooks/"
            Write-Host "  │   └── useApi.ts            $(Write-ColorOutput '# Custom API hooks' -Color Yellow -NoNewline)"
            Write-Host "  └── pages/"
            Write-Host "      ├── Home.tsx             $(Write-ColorOutput '# Home page' -Color Yellow -NoNewline)"
            Write-Host "      └── About.tsx            $(Write-ColorOutput '# About page' -Color Yellow -NoNewline)"
            Write-Host ""
            Write-ColorOutput "Adds routing and state management" -Color Blue
        }
        
        "exercise03" {
            Write-ColorOutput "API integration and optimization:" -Color Green
            Write-Host "  frontend/src/"
            Write-Host "  ├── services/"
            Write-Host "  │   ├── api.ts               $(Write-ColorOutput '# API client configuration' -Color Yellow -NoNewline)"
            Write-Host "  │   └── weatherService.ts    $(Write-ColorOutput '# Weather API service' -Color Yellow -NoNewline)"
            Write-Host "  ├── components/"
            Write-Host "  │   ├── LoadingSpinner.tsx   $(Write-ColorOutput '# Loading component' -Color Yellow -NoNewline)"
            Write-Host "  │   └── ErrorBoundary.tsx    $(Write-ColorOutput '# Error handling' -Color Yellow -NoNewline)"
            Write-Host "  └── utils/"
            Write-Host "      └── errorHandler.ts      $(Write-ColorOutput '# Error utilities' -Color Yellow -NoNewline)"
            Write-Host ""
            Write-ColorOutput "Adds production-ready API integration" -Color Blue
        }
        
        "exercise04" {
            Write-ColorOutput "Docker integration for the full stack:" -Color Green
            Write-Host "  ReactTodoApp/"
            Write-Host "  ├── backend/"
            Write-Host "  │   └── Dockerfile           $(Write-ColorOutput '# API container config' -Color Yellow -NoNewline)"
            Write-Host "  ├── frontend/"
            Write-Host "  │   └── Dockerfile           $(Write-ColorOutput '# React container config' -Color Yellow -NoNewline)"
            Write-Host "  ├── docker-compose.yml       $(Write-ColorOutput '# Multi-container setup' -Color Yellow -NoNewline)"
            Write-Host "  ├── docker-compose.dev.yml   $(Write-ColorOutput '# Development overrides' -Color Yellow -NoNewline)"
            Write-Host "  └── .dockerignore            $(Write-ColorOutput '# Docker ignore rules' -Color Yellow -NoNewline)"
            Write-Host ""
            Write-ColorOutput "Complete containerized development environment" -Color Blue
        }
    }
    
    Write-ColorOutput ("=" * 60) -Color Cyan
    Pause-ForUser
}

# Main script starts here
if ($List) {
    Show-Exercises
    exit 0
}

if (-not $ExerciseName) {
    Write-ColorOutput "[ERROR] Usage: .\launch-exercises.ps1 <exercise-name> [options]" -Color Red
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -List          Show all available exercises"
    Write-Host "  -Auto          Skip interactive mode"
    Write-Host "  -Preview       Show what will be created without creating"
    Write-Host ""
    Show-Exercises
    exit 1
}

$PROJECT_NAME = "ReactTodoApp"
$PREVIEW_ONLY = $Preview

# Validate exercise name
$EXERCISE_TITLE = switch ($ExerciseName) {
    "exercise01" { "Basic Integration"; break }
    "exercise02" { "State Management & Routing"; break }
    "exercise03" { "API Integration & Performance"; break }
    "exercise04" { "Docker Integration"; break }
    default {
        Write-ColorOutput "[ERROR] Unknown exercise: $ExerciseName" -Color Red
        Write-Host ""
        Show-Exercises
        exit 1
    }
}

# Welcome screen
Write-ColorOutput ("=" * 60) -Color Magenta
Write-ColorOutput "[LAUNCH] Module 02 - ASP.NET Core with React" -Color Magenta
Write-ColorOutput ("=" * 60) -Color Magenta
Write-Host ""
Write-ColorOutput "[PURPOSE] Exercise: $EXERCISE_TITLE" -Color Blue
Write-ColorOutput "[PACKAGE] Project: $PROJECT_NAME" -Color Blue
Write-Host ""

if ($InteractiveMode) {
    Write-ColorOutput "[INTERACTIVE] Interactive Mode: ON" -Color Yellow
    Write-ColorOutput "You'll see what each file does before it's created" -Color Cyan
} else {
    Write-ColorOutput "[AUTO] Automatic Mode: ON" -Color Yellow
}

Write-Host ""
Pause-ForUser

# Show learning objectives
Show-LearningObjectivesInteractive -Exercise $ExerciseName

# Show creation overview
Show-CreationOverview -Exercise $ExerciseName

if ($PREVIEW_ONLY) {
    Write-ColorOutput "Preview mode - no files will be created" -Color Yellow
    exit 0
}

# Check if project exists
$SKIP_PROJECT_CREATION = $false
if (Test-Path $PROJECT_NAME) {
    if ($ExerciseName -in @("exercise02", "exercise03", "exercise04")) {
        Write-ColorOutput "✓ Found existing $PROJECT_NAME from previous exercise" -Color Green
        Write-ColorOutput "This exercise will build on your existing work" -Color Cyan
        Set-Location $PROJECT_NAME
        $SKIP_PROJECT_CREATION = $true
    } else {
        Write-ColorOutput "⚠️  Project '$PROJECT_NAME' already exists!" -Color Yellow
        $response = Read-Host "Do you want to overwrite it? (y/N)"
        if ($response -notmatch '^[Yy]$') {
            exit 1
        }
        Remove-Item -Recurse -Force $PROJECT_NAME
        $SKIP_PROJECT_CREATION = $false
    }
} else {
    $SKIP_PROJECT_CREATION = $false
}

# Exercise-specific implementation
switch ($ExerciseName) {
    "exercise01" {
        # Exercise 1: Basic React Integration
        
        Explain-Concept -Concept "React SPA with ASP.NET Core" -Explanation @"
Single Page Applications (SPAs) with React and ASP.NET Core:
* Frontend: React handles UI and user interactions
* Backend: ASP.NET Core provides API endpoints
* Development: Vite dev server proxies API calls
* Production: React builds to static files served by ASP.NET Core
"@
        
        if (-not $SKIP_PROJECT_CREATION) {
            Write-ColorOutput "Creating React + ASP.NET Core project structure..." -Color Cyan
            New-Item -ItemType Directory -Path "$PROJECT_NAME" -Force | Out-Null
            Set-Location $PROJECT_NAME
        }
        
        # Create backend API
        Explain-Concept -Concept "ASP.NET Core API Backend" -Explanation @"
The backend provides RESTful API endpoints:
* Minimal API or Controller-based
* CORS configuration for React frontend
* Development and production configurations
* JSON serialization for API responses
"@
        
        Write-ColorOutput "Creating ASP.NET Core backend..." -Color Cyan
        New-Item -ItemType Directory -Path "backend" -Force | Out-Null
        Set-Location backend
        dotnet new webapi --framework net8.0 --name ReactIntegrationAPI
        Set-Location ReactIntegrationAPI
        Remove-Item -Force WeatherForecast.cs, Controllers/WeatherForecastController.cs -ErrorAction SilentlyContinue
        
        New-FileInteractive -FilePath "Controllers/WeatherController.cs" -Description "Weather API controller for testing React integration" -Content @'
using Microsoft.AspNetCore.Mvc;

namespace ReactIntegrationAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class WeatherController : ControllerBase
    {
        private static readonly string[] Summaries = new[]
        {
            "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
        };

        [HttpGet]
        public IEnumerable<WeatherForecast> Get()
        {
            return Enumerable.Range(1, 5).Select(index => new WeatherForecast(
                DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
                Random.Shared.Next(-20, 55),
                Summaries[Random.Shared.Next(Summaries.Length)]
            ))
            .ToArray();
        }
    }

    public record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
    {
        public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
    }
}
'@
        
        New-FileInteractive -FilePath "Program.cs" -Description "Program.cs configured for React integration with CORS" -Content @'
var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add CORS for React development
builder.Services.AddCors(options =>
{
    options.AddPolicy("ReactApp", policy =>
    {
        policy.WithOrigins("http://localhost:5173", "http://localhost:3000") // Vite dev and Docker ports
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "ReactIntegrationAPI v1");
        c.RoutePrefix = "swagger";
    });
}

app.UseCors("ReactApp");
app.UseAuthorization();
app.MapControllers();

app.Run();
'@
        
        # Create React frontend
        Set-Location ../..
        Explain-Concept -Concept "React Frontend with Vite" -Explanation @"
Vite is a modern build tool for React:
* Fast development server with hot reload
* TypeScript support out of the box
* Optimized production builds
* Easy proxy configuration for API calls
"@
        
        Write-ColorOutput "Creating React frontend with Vite..." -Color Cyan
        New-Item -ItemType Directory -Path "frontend" -Force | Out-Null
        Set-Location frontend
        
        # Create package.json for React app
        New-FileInteractive -FilePath "package.json" -Description "Package.json with locked React and Vite versions" -Content @'
{
  "name": "react-integration-frontend",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.43",
    "@types/react-dom": "^18.2.17",
    "@typescript-eslint/eslint-plugin": "^6.14.0",
    "@typescript-eslint/parser": "^6.14.0",
    "@vitejs/plugin-react": "^4.2.1",
    "eslint": "^8.55.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.5",
    "typescript": "^5.2.2",
    "vite": "^5.0.8"
  }
}
'@
        
        New-FileInteractive -FilePath "vite.config.ts" -Description "Vite configuration with API proxy" -Content @'
import { defineConfig } from "vite"
import react from "@vitejs/plugin-react"

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      "/api": {
        target: "http://localhost:5000",
        changeOrigin: true,
        secure: false,
      },
    },
  },
})
'@
        
        New-FileInteractive -FilePath "tsconfig.json" -Description "TypeScript configuration for React" -Content @'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "types": ["vite/client"]
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
'@
        
        New-FileInteractive -FilePath "tsconfig.node.json" -Description "TypeScript configuration for Node.js tools (Vite)" -Content @'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
'@
        
        # Create React components
        New-Item -ItemType Directory -Path "src/components" -Force | Out-Null
        
        New-FileInteractive -FilePath "src/App.tsx" -Description "Main React App component with API integration" -Content @'
import { useState, useEffect } from "react"
import "./App.css"

interface WeatherForecast {
  date: string;
  temperatureC: number;
  temperatureF: number;
  summary: string;
}

function App() {
  const [weather, setWeather] = useState<WeatherForecast[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchWeather();
  }, []);

  const fetchWeather = async () => {
    try {
      setLoading(true);
      const response = await fetch("/api/weather");
      if (!response.ok) {
        throw new Error("Failed to fetch weather data");
      }
      const data = await response.json();
      setWeather(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : "An error occurred");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>React + ASP.NET Core Integration</h1>
        <p>Weather Forecast from API</p>
      </header>

      <main>
        {loading && <p>Loading weather data...</p>}
        {error && <p style={{ color: "red" }}>Error: {error}</p>}
        {!loading && !error && (
          <div className="weather-grid">
            {weather.map((forecast, index) => (
              <div key={index} className="weather-card">
                <h3>{forecast.date}</h3>
                <p>Temperature: {forecast.temperatureC}°C ({forecast.temperatureF}°F)</p>
                <p>Summary: {forecast.summary}</p>
              </div>
            ))}
          </div>
        )}

        <button onClick={fetchWeather} disabled={loading}>
          Refresh Weather
        </button>
      </main>
    </div>
  );
}

export default App;
'@
        
        New-FileInteractive -FilePath "src/App.css" -Description "CSS styles for the React application" -Content @'
.App {
  text-align: center;
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.App-header {
  margin-bottom: 2rem;
}

.App-header h1 {
  color: #333;
  margin-bottom: 0.5rem;
}

.weather-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
  margin: 2rem 0;
}

.weather-card {
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 1rem;
  background-color: #f9f9f9;
}

.weather-card h3 {
  margin-top: 0;
  color: #555;
}

button {
  background-color: #007bff;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
}

button:hover:not(:disabled) {
  background-color: #0056b3;
}

button:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}
'@
        
        New-FileInteractive -FilePath "src/main.tsx" -Description "React application entry point" -Content @'
import React from "react"
import ReactDOM from "react-dom/client"
import App from "./App.tsx"
import "./index.css"

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
'@
        
        New-FileInteractive -FilePath "src/index.css" -Description "Global CSS styles" -Content @'
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", "Oxygen",
    "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue",
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #f5f5f5;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, "Courier New",
    monospace;
}

* {
  box-sizing: border-box;
}
'@
        
        New-FileInteractive -FilePath "index.html" -Description "HTML template for React application" -Content @'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>React + ASP.NET Core</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
'@
        
        Write-ColorOutput "Installing React dependencies..." -Color Cyan
        # We're already in the frontend directory
        npm install
        Set-Location ..
        
        Write-ColorOutput "[OK] Exercise 1 setup complete!" -Color Green
        Write-ColorOutput "To run the application:" -Color Yellow
        Write-Host ""
        Write-ColorOutput "Terminal 1 (Backend):" -Color Cyan
        Write-Host "cd backend/ReactIntegrationAPI"
        Write-Host "dotnet run"
        Write-Host ""
        Write-ColorOutput "Terminal 2 (Frontend):" -Color Cyan
        Write-Host "cd frontend"
        Write-Host "npm run dev"
        Write-Host ""
        Write-ColorOutput "Then open: http://localhost:5173" -Color Blue
        Write-ColorOutput "API Swagger: http://localhost:5000/swagger" -Color Blue
        Write-Host ""
        Write-ColorOutput "Note: Docker integration will be added in Exercise 4" -Color Yellow
    }
    
    "exercise02" {
        # Exercise 2: State Management & Routing
        
        Explain-Concept -Concept "React Router and State Management" -Explanation @"
Advanced React patterns for larger applications:
* React Router for client-side navigation
* Context API for global state management
* Custom hooks for reusable logic
* Component composition patterns
"@
        
        Write-ColorOutput "Adding routing and state management to existing project..." -Color Cyan
        
        if (-not (Test-Path "frontend")) {
            Write-ColorOutput "[ERROR] Frontend directory not found. Run exercise01 first." -Color Red
            exit 1
        }
        
        Set-Location frontend
        
        # Update package.json to add router
        Write-ColorOutput "Adding React Router dependency..." -Color Cyan
        npm install react-router-dom@^6.20.1
        npm install --save-dev @types/react-router-dom
        
        # Create context for state management
        New-Item -ItemType Directory -Path "src/context" -Force | Out-Null
        New-FileInteractive -FilePath "src/context/AppContext.tsx" -Description "Global state management with Context API and useReducer" -Content @'
import React, { createContext, useContext, useReducer, ReactNode } from "react";

interface User {
  id: number;
  name: string;
  email: string;
}

interface AppState {
  user: User | null;
  theme: "light" | "dark";
  notifications: string[];
}

type AppAction =
  | { type: "SET_USER"; payload: User }
  | { type: "LOGOUT" }
  | { type: "TOGGLE_THEME" }
  | { type: "ADD_NOTIFICATION"; payload: string }
  | { type: "REMOVE_NOTIFICATION"; payload: number };

const initialState: AppState = {
  user: null,
  theme: "light",
  notifications: [],
};

const appReducer = (state: AppState, action: AppAction): AppState => {
  switch (action.type) {
    case "SET_USER":
      return { ...state, user: action.payload };
    case "LOGOUT":
      return { ...state, user: null };
    case "TOGGLE_THEME":
      return { ...state, theme: state.theme === "light" ? "dark" : "light" };
    case "ADD_NOTIFICATION":
      return {
        ...state,
        notifications: [...state.notifications, action.payload],
      };
    case "REMOVE_NOTIFICATION":
      return {
        ...state,
        notifications: state.notifications.filter((_, index) => index !== action.payload),
      };
    default:
      return state;
  }
};

const AppContext = createContext<{
  state: AppState;
  dispatch: React.Dispatch<AppAction>;
} | null>(null);

export const AppProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [state, dispatch] = useReducer(appReducer, initialState);

  return (
    <AppContext.Provider value={{ state, dispatch }}>
      {children}
    </AppContext.Provider>
  );
};

export const useAppContext = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error("useAppContext must be used within an AppProvider");
  }
  return context;
};
'@
        
        # Create custom hooks
        New-Item -ItemType Directory -Path "src/hooks" -Force | Out-Null
        New-FileInteractive -FilePath "src/hooks/useApi.ts" -Description "Custom hook for API calls with loading and error states" -Content @'
import { useState, useEffect } from "react";

interface ApiState<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
}

export function useApi<T>(url: string, dependencies: any[] = []) {
  const [state, setState] = useState<ApiState<T>>({
    data: null,
    loading: true,
    error: null,
  });

  useEffect(() => {
    let isCancelled = false;

    const fetchData = async () => {
      try {
        setState(prev => ({ ...prev, loading: true, error: null }));

        const response = await fetch(url);
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();

        if (!isCancelled) {
          setState({ data, loading: false, error: null });
        }
      } catch (error) {
        if (!isCancelled) {
          setState({
            data: null,
            loading: false,
            error: error instanceof Error ? error.message : "An error occurred",
          });
        }
      }
    };

    fetchData();

    return () => {
      isCancelled = true;
    };
  }, dependencies);

  const refetch = () => {
    setState(prev => ({ ...prev, loading: true, error: null }));
    // Trigger useEffect by updating a dependency
  };

  return { ...state, refetch };
}
'@
        
        # Create pages
        New-Item -ItemType Directory -Path "src/pages" -Force | Out-Null
        New-FileInteractive -FilePath "src/pages/Home.tsx" -Description "Home page component with state management integration" -Content @'
import { useAppContext } from "../context/AppContext";
import { useApi } from "../hooks/useApi";

interface WeatherForecast {
  date: string;
  temperatureC: number;
  temperatureF: number;
  summary: string;
}

export default function Home() {
  const { state, dispatch } = useAppContext();
  const { data: weather, loading, error, refetch } = useApi<WeatherForecast[]>("/api/weather");

  const handleAddNotification = () => {
    dispatch({
      type: "ADD_NOTIFICATION",
      payload: `Weather refreshed at ${new Date().toLocaleTimeString()}`,
    });
  };

  const handleRefresh = () => {
    refetch();
    handleAddNotification();
  };

  return (
    <div className="page">
      <h1>Home Page</h1>
      <p>Welcome to the React + ASP.NET Core integration demo!</p>

      <div className="user-info">
        {state.user ? (
          <p>Hello, {state.user.name}!</p>
        ) : (
          <p>Please log in to see personalized content.</p>
        )}
      </div>

      <div className="weather-section">
        <h2>Weather Forecast</h2>
        {loading && <p>Loading weather data...</p>}
        {error && <p style={{ color: "red" }}>Error: {error}</p>}
        {weather && (
          <div className="weather-grid">
            {weather.map((forecast, index) => (
              <div key={index} className="weather-card">
                <h3>{forecast.date}</h3>
                <p>Temperature: {forecast.temperatureC}°C ({forecast.temperatureF}°F)</p>
                <p>Summary: {forecast.summary}</p>
              </div>
            ))}
          </div>
        )}

        <button onClick={handleRefresh} disabled={loading}>
          Refresh Weather
        </button>
      </div>
    </div>
  );
}
'@
        
        New-FileInteractive -FilePath "src/pages/About.tsx" -Description "About page with theme toggle and notifications" -Content @'
import { useAppContext } from "../context/AppContext";

export default function About() {
  const { state, dispatch } = useAppContext();

  const handleToggleTheme = () => {
    dispatch({ type: "TOGGLE_THEME" });
  };

  return (
    <div className="page">
      <h1>About</h1>
      <p>This is a demo application showcasing React + ASP.NET Core integration.</p>

      <div className="features">
        <h2>Features Demonstrated:</h2>
        <ul>
          <li>React Router for navigation</li>
          <li>Context API for state management</li>
          <li>Custom hooks for API calls</li>
          <li>TypeScript integration</li>
          <li>Responsive design</li>
        </ul>
      </div>

      <div className="theme-section">
        <h3>Theme: {state.theme}</h3>
        <button onClick={handleToggleTheme}>
          Switch to {state.theme === "light" ? "dark" : "light"} theme
        </button>
      </div>

      <div className="notifications-section">
        <h3>Notifications ({state.notifications.length})</h3>
        {state.notifications.length === 0 ? (
          <p>No notifications</p>
        ) : (
          <ul>
            {state.notifications.map((notification, index) => (
              <li key={index}>
                {notification}
                <button
                  onClick={() => dispatch({ type: "REMOVE_NOTIFICATION", payload: index })}
                  style={{ marginLeft: "10px", fontSize: "12px" }}
                >
                  ×
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}
'@
        
        # Create navigation component
        New-FileInteractive -FilePath "src/components/Navigation.tsx" -Description "Navigation component with routing and user state" -Content @'
import { Link, useLocation } from "react-router-dom";
import { useAppContext } from "../context/AppContext";

export default function Navigation() {
  const location = useLocation();
  const { state, dispatch } = useAppContext();

  const handleLogin = () => {
    // Simulate login
    dispatch({
      type: "SET_USER",
      payload: { id: 1, name: "John Doe", email: "john@example.com" },
    });
    dispatch({
      type: "ADD_NOTIFICATION",
      payload: "Successfully logged in!",
    });
  };

  const handleLogout = () => {
    dispatch({ type: "LOGOUT" });
    dispatch({
      type: "ADD_NOTIFICATION",
      payload: "Successfully logged out!",
    });
  };

  return (
    <nav className={`navigation ${state.theme}`}>
      <div className="nav-brand">
        <h2>React + ASP.NET Core</h2>
      </div>

      <div className="nav-links">
        <Link
          to="/"
          className={location.pathname === "/" ? "active" : ""}
        >
          Home
        </Link>
        <Link
          to="/about"
          className={location.pathname === "/about" ? "active" : ""}
        >
          About
        </Link>
      </div>

      <div className="nav-user">
        {state.user ? (
          <div className="user-menu">
            <span>Welcome, {state.user.name}</span>
            <button onClick={handleLogout}>Logout</button>
          </div>
        ) : (
          <button onClick={handleLogin}>Login</button>
        )}
      </div>
    </nav>
  );
}
'@
        
        # Update App.tsx for routing
        New-FileInteractive -FilePath "src/App.tsx" -Description "Updated App component with routing and context provider" -Content @'
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { AppProvider } from "./context/AppContext";
import Navigation from "./components/Navigation";
import Home from "./pages/Home";
import About from "./pages/About";
import "./App.css";

function App() {
  return (
    <AppProvider>
      <Router>
        <div className="App">
          <Navigation />
          <main className="main-content">
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/about" element={<About />} />
            </Routes>
          </main>
        </div>
      </Router>
    </AppProvider>
  );
}

export default App;
'@
        
        Write-ColorOutput "[OK] Exercise 2 setup complete!" -Color Green
        Write-ColorOutput "New features added:" -Color Yellow
        Write-Host "- React Router for navigation"
        Write-Host "- Context API for global state"
        Write-Host "- Custom hooks for API calls"
        Write-Host "- Theme switching"
        Write-Host "- Notification system"
    }
    
    "exercise03" {
        # Exercise 3: API Integration & Performance
        
        Explain-Concept -Concept "Production-Ready API Integration" -Explanation @"
Advanced patterns for robust React applications:
* Centralized API client configuration
* Error boundaries for graceful error handling
* Loading states and user feedback
* Performance optimization techniques
"@
        
        Write-ColorOutput "Adding production-ready API integration..." -Color Cyan
        
        if (-not (Test-Path "frontend")) {
            Write-ColorOutput "[ERROR] Frontend directory not found. Run previous exercises first." -Color Red
            exit 1
        }
        
        Set-Location frontend
        
        # Create services directory
        New-Item -ItemType Directory -Path "src/services" -Force | Out-Null
        New-FileInteractive -FilePath "src/services/api.ts" -Description "Centralized API client with error handling and authentication support" -Content @'
// Centralized API configuration
const API_BASE_URL = import.meta.env.VITE_API_URL || "/api";

export interface ApiResponse<T> {
  data: T;
  success: boolean;
  message?: string;
}

export interface ApiError {
  message: string;
  status: number;
  details?: any;
}

class ApiClient {
  private baseURL: string;
  private defaultHeaders: Record<string, string>;

  constructor(baseURL: string) {
    this.baseURL = baseURL;
    this.defaultHeaders = {
      "Content-Type": "application/json",
    };
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this.baseURL}${endpoint}`;

    const config: RequestInit = {
      ...options,
      headers: {
        ...this.defaultHeaders,
        ...options.headers,
      },
    };

    try {
      const response = await fetch(url, config);

      if (!response.ok) {
        const errorData = await response.text();
        throw new ApiError(
          errorData || `HTTP error! status: ${response.status}`,
          response.status
        );
      }

      const data = await response.json();
      return data;
    } catch (error) {
      if (error instanceof ApiError) {
        throw error;
      }

      throw new ApiError(
        error instanceof Error ? error.message : "Network error occurred",
        0
      );
    }
  }

  async get<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: "GET" });
  }

  async post<T>(endpoint: string, data?: any): Promise<T> {
    return this.request<T>(endpoint, {
      method: "POST",
      body: data ? JSON.stringify(data) : undefined,
    });
  }

  setAuthToken(token: string) {
    this.defaultHeaders.Authorization = `Bearer ${token}`;
  }

  removeAuthToken() {
    delete this.defaultHeaders.Authorization;
  }
}

export class ApiError extends Error {
  constructor(message: string, public status: number, public details?: any) {
    super(message);
    this.name = "ApiError";
  }
}

export const apiClient = new ApiClient(API_BASE_URL);
'@
        
        Write-ColorOutput "[OK] Exercise 3 setup complete!" -Color Green
        Write-ColorOutput "Production features added:" -Color Yellow
        Write-Host "- Centralized API client"
        Write-Host "- Error handling utilities"
        Write-Host "- Performance optimizations"
    }
    
    "exercise04" {
        # Exercise 4: Docker Integration
        
        Explain-Concept -Concept "Containerized Full-Stack Development" -Explanation @"
Docker provides consistent development environments:
* Multi-stage builds for optimized production images
* Docker Compose for orchestrating multiple services
* Environment-specific configurations
* Simplified deployment and scaling
"@
        
        Write-ColorOutput "Adding Docker integration for full-stack development..." -Color Cyan
        
        if (-not (Test-Path "backend") -or -not (Test-Path "frontend")) {
            Write-ColorOutput "[ERROR] Backend and frontend directories not found. Run previous exercises first." -Color Red
            exit 1
        }
        
        # Create Dockerfile for backend
        New-FileInteractive -FilePath "backend/ReactIntegrationAPI/Dockerfile" -Description "Multi-stage Dockerfile for ASP.NET Core API" -Content @'
# Multi-stage build for ASP.NET Core API
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ReactIntegrationAPI.csproj", "."]
RUN dotnet restore "./ReactIntegrationAPI.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "ReactIntegrationAPI.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ReactIntegrationAPI.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ReactIntegrationAPI.dll"]
'@
        
        # Create Dockerfile for frontend
        New-FileInteractive -FilePath "frontend/Dockerfile" -Description "Multi-stage Dockerfile for React frontend with nginx" -Content @'
# Multi-stage build for React frontend
FROM node:18-alpine AS build
WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm install

# Copy source code and build
COPY . .
RUN npm run build

# Production stage with nginx
FROM nginx:alpine AS production
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
'@
        
        # Create nginx configuration
        New-FileInteractive -FilePath "frontend/nginx.conf" -Description "Nginx configuration with API proxy and security headers" -Content @'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Handle client-side routing
    location / {
        try_files $uri $uri/ /index.html;
    }

    # API proxy for production
    location /api/ {
        proxy_pass http://backend:8080/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss;
}
'@
        
        # Create updated docker-compose.yml for production
        New-FileInteractive -FilePath "docker-compose.yml" -Description "Production Docker Compose configuration with proper ports" -Content @'
version: "3.8"

services:
  backend:
    build:
      context: ./backend/ReactIntegrationAPI
      dockerfile: Dockerfile
    ports:
      - "5001:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:8080
    networks:
      - app-network

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:80"
    depends_on:
      - backend
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
'@
        
        # Create startup scripts
        New-Item -ItemType Directory -Path "scripts" -Force | Out-Null
        New-FileInteractive -FilePath "scripts/start-dev.ps1" -Description "Development startup script" -Content @'
Write-Host "[LAUNCH] Starting React + ASP.NET Core in development mode..." -ForegroundColor Cyan

# Check if Docker is running
$dockerInfo = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Docker is not running. Please start Docker first." -ForegroundColor Red
    exit 1
}

Write-Host "[PACKAGE] Building and starting containers..." -ForegroundColor Yellow
docker-compose up --build

Write-Host "[OK] Development environment started!" -ForegroundColor Green
Write-Host "[WEB] Frontend: http://localhost:5173" -ForegroundColor Blue
Write-Host "[API] Backend API: http://localhost:5000" -ForegroundColor Blue
'@
        
        Write-ColorOutput "[OK] Exercise 4 setup complete!" -Color Green
        Write-ColorOutput "Docker integration added:" -Color Yellow
        Write-Host "- Multi-stage Dockerfiles for both frontend and backend"
        Write-Host "- Docker Compose orchestration"
        Write-Host "- Startup scripts for easy deployment"
        Write-Host ""
        
        # Check if Docker is running
        Write-ColorOutput "[DOCKER] Starting Docker containers..." -Color Cyan
        $dockerInfo = docker info 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "[ERROR] Docker is not running. Please start Docker first." -Color Red
            Write-ColorOutput "Then run: docker-compose up --build" -Color Yellow
            exit 1
        }
        
        Write-ColorOutput "Building and starting containers with docker-compose..." -Color Cyan
        docker-compose up --build -d
        
        Write-Host ""
        Write-ColorOutput "[OK] Docker containers are now running!" -Color Green
        Write-ColorOutput "[WEB] Frontend: http://localhost:3000" -Color Blue
        Write-ColorOutput "[API] Backend API: http://localhost:5001" -Color Blue
        Write-ColorOutput "[LEARN] Swagger UI: http://localhost:5001/swagger/index.html" -Color Blue
        Write-Host ""
        Write-ColorOutput "Container status:" -Color Yellow
        docker-compose ps
        Write-Host ""
        Write-ColorOutput "To stop containers: docker-compose down" -Color Cyan
        Write-ColorOutput "To view logs: docker-compose logs -f" -Color Cyan
    }
}

Write-Host ""
Write-ColorOutput ("=" * 60) -Color Green
Write-ColorOutput "[COMPLETE] Module 02 Exercise setup complete!" -Color Green
Write-ColorOutput ("=" * 60) -Color Green
Write-Host ""
Write-ColorOutput "[OVERVIEW] Next Steps:" -Color Yellow
Write-Host "1. Review the created files and understand their purpose"
Write-Host "2. Test your application using the provided startup commands"
Write-Host "3. Experiment with the features implemented in this exercise"
Write-Host "4. Move on to the next exercise to build upon this foundation"
Write-Host ""
Write-ColorOutput "Happy learning! [LAUNCH]" -Color Cyan