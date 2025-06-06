#!/bin/bash

# Interactive Exercise Launcher for Module 02 - ASP.NET Core with React
# This version shows what will be created and lets students step through

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Interactive mode flag
INTERACTIVE_MODE=true

# Function to pause and wait for user
pause_for_user() {
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -e "${YELLOW}Press Enter to continue...${NC}"
        read -r
    fi
}

# Function to show what will be created
preview_file() {
    local file_path=$1
    local description=$2
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📄 Will create: $file_path${NC}"
    echo -e "${YELLOW}📝 Purpose: $description${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to create file with preview
create_file_interactive() {
    local file_path=$1
    local content=$2
    local description=$3
    
    preview_file "$file_path" "$description"
    
    # Show first 20 lines of content
    echo -e "${GREEN}Content preview:${NC}"
    echo "$content" | head -20
    if [ $(echo "$content" | wc -l) -gt 20 ]; then
        echo -e "${YELLOW}... (content truncated for preview)${NC}"
    fi
    echo ""
    
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -e "${YELLOW}Create this file? (Y/n/s to skip all):${NC} \c"
        read -r response
        
        case $response in
            [nN])
                echo -e "${RED}⏭️  Skipped: $file_path${NC}"
                return
                ;;
            [sS])
                INTERACTIVE_MODE=false
                echo -e "${CYAN}📌 Switching to automatic mode...${NC}"
                ;;
        esac
    fi
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$file_path")"
    
    # Write content to file
    echo "$content" > "$file_path"
    echo -e "${GREEN}✅ Created: $file_path${NC}"
    echo ""
}

# Function to explain a concept before creating related files
explain_concept() {
    local concept=$1
    local explanation=$2
    
    echo -e "${MAGENTA}💡 Concept: $concept${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "$explanation"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to display available exercises
show_exercises() {
    echo -e "${CYAN}Module 02 - ASP.NET Core with React Exercises:${NC}"
    echo ""
    echo "  - exercise01: Basic Integration"
    echo "  - exercise02: State Management & Routing"
    echo "  - exercise03: API Integration & Performance"
    echo "  - exercise04: Docker Integration"
    echo ""
}

# Function to show learning objectives with interaction
show_learning_objectives_interactive() {
    local exercise=$1
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}🎯 Learning Objectives for $exercise${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${CYAN}In this exercise, you will learn:${NC}"
            echo "  ⚛️ 1. Setting up React with ASP.NET Core"
            echo "  ⚛️ 2. Creating a React SPA frontend"
            echo "  ⚛️ 3. Configuring development proxy"
            echo "  ⚛️ 4. Basic component structure"
            echo ""
            echo -e "${YELLOW}Key concepts:${NC}"
            echo "  • React project setup with Vite"
            echo "  • ASP.NET Core as API backend"
            echo "  • Development server configuration"
            echo "  • Component-based architecture"
            ;;
        "exercise02")
            echo -e "${CYAN}Building on Exercise 1, you will add:${NC}"
            echo "  🔄 1. React Router for navigation"
            echo "  🔄 2. State management with Context API"
            echo "  🔄 3. Form handling and validation"
            echo "  🔄 4. Component lifecycle management"
            echo ""
            echo -e "${YELLOW}Advanced concepts:${NC}"
            echo "  • Client-side routing"
            echo "  • Global state management"
            echo "  • Controlled components"
            echo "  • Effect hooks and cleanup"
            ;;
        "exercise03")
            echo -e "${CYAN}Integrating with APIs and optimization:${NC}"
            echo "  🚀 1. HTTP client configuration"
            echo "  🚀 2. API integration patterns"
            echo "  🚀 3. Error handling and loading states"
            echo "  🚀 4. Performance optimization"
            echo ""
            echo -e "${YELLOW}Production concepts:${NC}"
            echo "  • Fetch API and error handling"
            echo "  • Loading and error states"
            echo "  • Code splitting and lazy loading"
            echo "  • Build optimization"
            ;;
        "exercise04")
            echo -e "${CYAN}Docker integration for full-stack development:${NC}"
            echo "  🐳 1. Containerizing ASP.NET Core API"
            echo "  🐳 2. Containerizing React application"
            echo "  🐳 3. Docker Compose for multi-container setup"
            echo "  🐳 4. Development and production configurations"
            echo ""
            echo -e "${YELLOW}DevOps concepts:${NC}"
            echo "  • Multi-stage Docker builds"
            echo "  • Container networking"
            echo "  • Environment configuration"
            echo "  • Development workflow with containers"
            ;;
    esac
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to show what will be created overview
show_creation_overview() {
    local exercise=$1
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📋 Overview: What will be created${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${GREEN}Project Structure:${NC}"
            echo "  ReactTodoApp/"
            echo "  ├── backend/                  ${YELLOW}# ASP.NET Core API${NC}"
            echo "  │   ├── Controllers/"
            echo "  │   │   └── WeatherController.cs ${YELLOW}# Sample API endpoint${NC}"
            echo "  │   ├── Program.cs           ${YELLOW}# API configuration${NC}"
            echo "  │   └── appsettings.json     ${YELLOW}# API settings${NC}"
            echo "  ├── frontend/                ${YELLOW}# React SPA${NC}"
            echo "  │   ├── src/"
            echo "  │   │   ├── components/      ${YELLOW}# React components${NC}"
            echo "  │   │   ├── App.tsx          ${YELLOW}# Main app component${NC}"
            echo "  │   │   └── main.tsx         ${YELLOW}# Entry point${NC}"
            echo "  │   ├── package.json         ${YELLOW}# Node dependencies${NC}"
            echo "  │   └── vite.config.ts       ${YELLOW}# Vite configuration${NC}"
            echo "  └── docker-compose.yml       ${YELLOW}# Container orchestration${NC}"
            echo ""
            echo -e "${BLUE}This creates a full-stack React + ASP.NET Core setup${NC}"
            ;;
            
        "exercise02")
            echo -e "${GREEN}Building on Exercise 1, adding:${NC}"
            echo "  frontend/src/"
            echo "  ├── components/"
            echo "  │   ├── Navigation.tsx       ${YELLOW}# Navigation component${NC}"
            echo "  │   ├── UserProfile.tsx      ${YELLOW}# User profile component${NC}"
            echo "  │   └── ProductList.tsx      ${YELLOW}# Product listing${NC}"
            echo "  ├── context/"
            echo "  │   └── AppContext.tsx       ${YELLOW}# Global state management${NC}"
            echo "  ├── hooks/"
            echo "  │   └── useApi.ts            ${YELLOW}# Custom API hooks${NC}"
            echo "  └── pages/"
            echo "      ├── Home.tsx             ${YELLOW}# Home page${NC}"
            echo "      └── About.tsx            ${YELLOW}# About page${NC}"
            echo ""
            echo -e "${BLUE}Adds routing and state management${NC}"
            ;;
            
        "exercise03")
            echo -e "${GREEN}API integration and optimization:${NC}"
            echo "  frontend/src/"
            echo "  ├── services/"
            echo "  │   ├── api.ts               ${YELLOW}# API client configuration${NC}"
            echo "  │   └── weatherService.ts    ${YELLOW}# Weather API service${NC}"
            echo "  ├── components/"
            echo "  │   ├── LoadingSpinner.tsx   ${YELLOW}# Loading component${NC}"
            echo "  │   └── ErrorBoundary.tsx    ${YELLOW}# Error handling${NC}"
            echo "  └── utils/"
            echo "      └── errorHandler.ts      ${YELLOW}# Error utilities${NC}"
            echo ""
            echo -e "${BLUE}Adds production-ready API integration${NC}"
            ;;
            
        "exercise04")
            echo -e "${GREEN}Docker integration for the full stack:${NC}"
            echo "  ReactTodoApp/"
            echo "  ├── backend/"
            echo "  │   └── Dockerfile           ${YELLOW}# API container config${NC}"
            echo "  ├── frontend/"
            echo "  │   └── Dockerfile           ${YELLOW}# React container config${NC}"
            echo "  ├── docker-compose.yml       ${YELLOW}# Multi-container setup${NC}"
            echo "  ├── docker-compose.dev.yml   ${YELLOW}# Development overrides${NC}"
            echo "  └── .dockerignore            ${YELLOW}# Docker ignore rules${NC}"
            echo ""
            echo -e "${BLUE}Complete containerized development environment${NC}"
            ;;
    esac
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Main script starts here
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Usage: $0 <exercise-name> [options]${NC}"
    echo ""
    echo "Options:"
    echo "  --list          Show all available exercises"
    echo "  --auto          Skip interactive mode"
    echo "  --preview       Show what will be created without creating"
    echo ""
    show_exercises
    exit 1
fi

# Handle --list option
if [ "$1" == "--list" ]; then
    show_exercises
    exit 0
fi

EXERCISE_NAME=$1
PREVIEW_ONLY=false

# Parse options
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            INTERACTIVE_MODE=false
            shift
            ;;
        --preview)
            PREVIEW_ONLY=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Determine exercise configuration
case $EXERCISE_NAME in
    "exercise01")
        PROJECT_NAME="ReactTodoApp"
        EXERCISE_TITLE="Basic Integration"
        ;;
    "exercise02")
        PROJECT_NAME="ReactTodoApp"
        EXERCISE_TITLE="State Management & Routing"
        ;;
    "exercise03")
        PROJECT_NAME="ReactTodoApp"
        EXERCISE_TITLE="API Integration & Performance"
        ;;
    "exercise04")
        PROJECT_NAME="ReactTodoApp"
        EXERCISE_TITLE="Docker Integration"
        ;;
    *)
        echo -e "${RED}❌ Unknown exercise: $EXERCISE_NAME${NC}"
        echo ""
        show_exercises
        exit 1
        ;;
esac

# Welcome screen
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}🚀 Module 02 - ASP.NET Core with React${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📝 Exercise: $EXERCISE_TITLE${NC}"
echo -e "${BLUE}📦 Project: $PROJECT_NAME${NC}"
echo ""

if [ "$INTERACTIVE_MODE" = true ]; then
    echo -e "${YELLOW}🎮 Interactive Mode: ON${NC}"
    echo -e "${CYAN}You'll see what each file does before it's created${NC}"
else
    echo -e "${YELLOW}⚡ Automatic Mode: ON${NC}"
fi

echo ""
pause_for_user

# Show learning objectives
show_learning_objectives_interactive $EXERCISE_NAME

# Show creation overview
show_creation_overview $EXERCISE_NAME

if [ "$PREVIEW_ONLY" = true ]; then
    echo -e "${YELLOW}Preview mode - no files will be created${NC}"
    exit 0
fi

# Check if project exists
if [ -d "$PROJECT_NAME" ]; then
    if [[ $EXERCISE_NAME == "exercise02" ]] || [[ $EXERCISE_NAME == "exercise03" ]] || [[ $EXERCISE_NAME == "exercise04" ]]; then
        echo -e "${GREEN}✓ Found existing $PROJECT_NAME from previous exercise${NC}"
        echo -e "${CYAN}This exercise will build on your existing work${NC}"
        cd "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=true
    else
        echo -e "${YELLOW}⚠️  Project '$PROJECT_NAME' already exists!${NC}"
        echo -n "Do you want to overwrite it? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            exit 1
        fi
        rm -rf "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=false
    fi
else
    SKIP_PROJECT_CREATION=false
fi

# Exercise-specific implementation
if [[ $EXERCISE_NAME == "exercise01" ]]; then
    # Exercise 1: Basic React Integration

    explain_concept "React SPA with ASP.NET Core" \
"Single Page Applications (SPAs) with React and ASP.NET Core:
• Frontend: React handles UI and user interactions
• Backend: ASP.NET Core provides API endpoints
• Development: Vite dev server proxies API calls
• Production: React builds to static files served by ASP.NET Core"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${CYAN}Creating React + ASP.NET Core project structure...${NC}"
        mkdir -p "$PROJECT_NAME"
        cd "$PROJECT_NAME"
    fi

    # Create backend API
    explain_concept "ASP.NET Core API Backend" \
"The backend provides RESTful API endpoints:
• Minimal API or Controller-based
• CORS configuration for React frontend
• Development and production configurations
• JSON serialization for API responses"

    echo -e "${CYAN}Creating ASP.NET Core backend...${NC}"
    mkdir -p backend
    cd backend
    dotnet new webapi --framework net8.0 --name ReactIntegrationAPI
    cd ReactIntegrationAPI
    rm -f WeatherForecast.cs Controllers/WeatherForecastController.cs

    create_file_interactive "Controllers/WeatherController.cs" \
'using Microsoft.AspNetCore.Mvc;

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
}' \
"Weather API controller for testing React integration"

    create_file_interactive "Program.cs" \
'var builder = WebApplication.CreateBuilder(args);

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

app.Run();' \
"Program.cs configured for React integration with CORS"

    # Create React frontend
    cd ../../
    explain_concept "React Frontend with Vite" \
"Vite is a modern build tool for React:
• Fast development server with hot reload
• TypeScript support out of the box
• Optimized production builds
• Easy proxy configuration for API calls"

    echo -e "${CYAN}Creating React frontend with Vite...${NC}"
    mkdir -p frontend
    cd frontend

    # Create package.json for React app
    create_file_interactive "package.json" \
'{
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
}' \
"Package.json with locked React and Vite versions"

    create_file_interactive "vite.config.ts" \
'import { defineConfig } from "vite"
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
})' \
"Vite configuration with API proxy"

    create_file_interactive "tsconfig.json" \
'{
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
}' \
"TypeScript configuration for React"

    create_file_interactive "tsconfig.node.json" \
'{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}' \
"TypeScript configuration for Node.js tools (Vite)"

    # Create React components
    mkdir -p src/components

    create_file_interactive "src/App.tsx" \
'import { useState, useEffect } from "react"
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

export default App;' \
"Main React App component with API integration"

    create_file_interactive "src/App.css" \
'.App {
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
}' \
"CSS styles for the React application"

    create_file_interactive "src/main.tsx" \
'import React from "react"
import ReactDOM from "react-dom/client"
import App from "./App.tsx"
import "./index.css"

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)' \
"React application entry point"

    create_file_interactive "src/index.css" \
'body {
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
}' \
"Global CSS styles"

    create_file_interactive "index.html" \
'<!doctype html>
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
</html>' \
"HTML template for React application"

    echo -e "${CYAN}Installing React dependencies...${NC}"
    # We're already in the frontend directory
    npm install
    cd ../

    echo -e "${GREEN}✅ Exercise 1 setup complete!${NC}"
    echo -e "${YELLOW}To run the application:${NC}"
    echo ""
    echo -e "${CYAN}Terminal 1 (Backend):${NC}"
    echo "cd backend/ReactIntegrationAPI"
    echo "dotnet run"
    echo ""
    echo -e "${CYAN}Terminal 2 (Frontend):${NC}"
    echo "cd frontend"
    echo "npm run dev"
    echo ""
    echo -e "${BLUE}Then open: http://localhost:5173${NC}"
    echo -e "${BLUE}API Swagger: http://localhost:5000/swagger${NC}"
    echo ""
    echo -e "${YELLOW}Note: Docker integration will be added in Exercise 4${NC}"

elif [[ $EXERCISE_NAME == "exercise02" ]]; then
    # Exercise 2: State Management & Routing

    explain_concept "React Router and State Management" \
"Advanced React patterns for larger applications:
• React Router for client-side navigation
• Context API for global state management
• Custom hooks for reusable logic
• Component composition patterns"

    echo -e "${CYAN}Adding routing and state management to existing project...${NC}"

    if [ ! -d "frontend" ]; then
        echo -e "${RED}❌ Frontend directory not found. Run exercise01 first.${NC}"
        exit 1
    fi

    cd frontend

    # Update package.json to add router
    echo -e "${CYAN}Adding React Router dependency...${NC}"
    npm install react-router-dom@^6.20.1
    npm install --save-dev @types/react-router-dom

    # Create context for state management
    mkdir -p src/context
    create_file_interactive "src/context/AppContext.tsx" \
'import React, { createContext, useContext, useReducer, ReactNode } from "react";

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
};' \
"Global state management with Context API and useReducer"

    # Create custom hooks
    mkdir -p src/hooks
    create_file_interactive "src/hooks/useApi.ts" \
'import { useState, useEffect } from "react";

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
}' \
"Custom hook for API calls with loading and error states"

    # Create pages
    mkdir -p src/pages
    create_file_interactive "src/pages/Home.tsx" \
'import { useAppContext } from "../context/AppContext";
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
}' \
"Home page component with state management integration"

    create_file_interactive "src/pages/About.tsx" \
'import { useAppContext } from "../context/AppContext";

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
}' \
"About page with theme toggle and notifications"

    # Create navigation component
    create_file_interactive "src/components/Navigation.tsx" \
'import { Link, useLocation } from "react-router-dom";
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
}' \
"Navigation component with routing and user state"

    # Update App.tsx for routing
    create_file_interactive "src/App.tsx" \
'import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
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

export default App;' \
"Updated App component with routing and context provider"

    echo -e "${GREEN}✅ Exercise 2 setup complete!${NC}"
    echo -e "${YELLOW}New features added:${NC}"
    echo "• React Router for navigation"
    echo "• Context API for global state"
    echo "• Custom hooks for API calls"
    echo "• Theme switching"
    echo "• Notification system"

elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    # Exercise 3: API Integration & Performance

    explain_concept "Production-Ready API Integration" \
"Advanced patterns for robust React applications:
• Centralized API client configuration
• Error boundaries for graceful error handling
• Loading states and user feedback
• Performance optimization techniques"

    echo -e "${CYAN}Adding production-ready API integration...${NC}"

    if [ ! -d "frontend" ]; then
        echo -e "${RED}❌ Frontend directory not found. Run previous exercises first.${NC}"
        exit 1
    fi

    cd frontend

    # Create services directory
    mkdir -p src/services
    create_file_interactive "src/services/api.ts" \
'// Centralized API configuration
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

export const apiClient = new ApiClient(API_BASE_URL);' \
"Centralized API client with error handling and authentication support"

    echo -e "${GREEN}✅ Exercise 3 setup complete!${NC}"
    echo -e "${YELLOW}Production features added:${NC}"
    echo "• Centralized API client"
    echo "• Error handling utilities"
    echo "• Performance optimizations"

elif [[ $EXERCISE_NAME == "exercise04" ]]; then
    # Exercise 4: Docker Integration

    explain_concept "Containerized Full-Stack Development" \
"Docker provides consistent development environments:
• Multi-stage builds for optimized production images
• Docker Compose for orchestrating multiple services
• Environment-specific configurations
• Simplified deployment and scaling"

    echo -e "${CYAN}Adding Docker integration for full-stack development...${NC}"

    if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
        echo -e "${RED}❌ Backend and frontend directories not found. Run previous exercises first.${NC}"
        exit 1
    fi

    # Create Dockerfile for backend
    create_file_interactive "backend/ReactIntegrationAPI/Dockerfile" \
'# Multi-stage build for ASP.NET Core API
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
ENTRYPOINT ["dotnet", "ReactIntegrationAPI.dll"]' \
"Multi-stage Dockerfile for ASP.NET Core API"

    # Create Dockerfile for frontend
    create_file_interactive "frontend/Dockerfile" \
'# Multi-stage build for React frontend
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
CMD ["nginx", "-g", "daemon off;"]' \
"Multi-stage Dockerfile for React frontend with nginx"

    # Create nginx configuration
    create_file_interactive "frontend/nginx.conf" \
'server {
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
    add_header Content-Security-Policy "default-src '\''self'\'' http: https: data: blob: '\''unsafe-inline'\''" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss;
}' \
"Nginx configuration with API proxy and security headers"

    # Create updated docker-compose.yml for production
    create_file_interactive "docker-compose.yml" \
'version: "3.8"

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
    driver: bridge' \
"Production Docker Compose configuration with proper ports"

    # Create startup scripts
    mkdir -p scripts
    create_file_interactive "scripts/start-dev.sh" \
'#!/bin/bash
echo "🚀 Starting React + ASP.NET Core in development mode..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "📦 Building and starting containers..."
docker-compose up --build

echo "✅ Development environment started!"
echo "🌐 Frontend: http://localhost:5173"
echo "🔧 Backend API: http://localhost:5000"' \
"Development startup script"

    chmod +x scripts/start-dev.sh

    echo -e "${GREEN}✅ Exercise 4 setup complete!${NC}"
    echo -e "${YELLOW}Docker integration added:${NC}"
    echo "• Multi-stage Dockerfiles for both frontend and backend"
    echo "• Docker Compose orchestration"
    echo "• Startup scripts for easy deployment"
    echo ""

    # Check if Docker is running
    echo -e "${CYAN}🐳 Starting Docker containers...${NC}"
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
        echo -e "${YELLOW}Then run: docker-compose up --build${NC}"
        exit 1
    fi

    echo -e "${CYAN}Building and starting containers with docker-compose...${NC}"
    docker-compose up --build -d

    echo ""
    echo -e "${GREEN}🎉 Docker containers are now running!${NC}"
    echo -e "${BLUE}🌐 Frontend: http://localhost:3000${NC}"
    echo -e "${BLUE}🔧 Backend API: http://localhost:5001${NC}"
    echo -e "${BLUE}📚 Swagger UI: http://localhost:5001/swagger/index.html${NC}"
    echo ""
    echo -e "${YELLOW}Container status:${NC}"
    docker-compose ps
    echo ""
    echo -e "${CYAN}To stop containers: docker-compose down${NC}"
    echo -e "${CYAN}To view logs: docker-compose logs -f${NC}"

fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Module 02 Exercise setup complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "1. Review the created files and understand their purpose"
echo "2. Test your application using the provided startup commands"
echo "3. Experiment with the features implemented in this exercise"
echo "4. Move on to the next exercise to build upon this foundation"
echo ""
echo -e "${CYAN}Happy learning! 🚀${NC}"
