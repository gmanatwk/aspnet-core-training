#!/bin/bash

# Interactive Exercise Launcher for ASP.NET Core Training
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

# Function to show learning objectives with interaction
show_learning_objectives_interactive() {
    local exercise=$1
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}🎯 Learning Objectives for $exercise${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    case $exercise in
        "module01-exercise01")
            echo -e "${CYAN}In this exercise, you will learn:${NC}"
            echo "  📚 1. How to create your first ASP.NET Core application"
            echo "  📚 2. Understanding the project structure"
            echo "  📚 3. Running and testing your application"
            echo "  📚 4. Making basic modifications"
            echo ""
            echo -e "${YELLOW}Key concepts:${NC}"
            echo "  • Web application templates"
            echo "  • Razor Pages basics"
            echo "  • Static files and wwwroot"
            echo "  • Hot reload functionality"
            ;;
        "module01-exercise02")
            echo -e "${CYAN}Building on Exercise 1, you will explore:${NC}"
            echo "  📁 1. Deep dive into project structure"
            echo "  📁 2. Understanding Program.cs"
            echo "  📁 3. Configuration with appsettings.json"
            echo "  📁 4. Pages and layout system"
            echo ""
            echo -e "${YELLOW}Key concepts:${NC}"
            echo "  • Service configuration"
            echo "  • Middleware pipeline"
            echo "  • Dependency injection basics"
            echo "  • Environment-based configuration"
            ;;
        "module01-exercise03")
            echo -e "${CYAN}Advanced topics for your first app:${NC}"
            echo "  ⚙️ 1. Custom middleware implementation"
            echo "  ⚙️ 2. Configuration providers"
            echo "  ⚙️ 3. Request pipeline customization"
            echo "  ⚙️ 4. Error handling"
            echo ""
            echo -e "${YELLOW}Key concepts:${NC}"
            echo "  • Middleware order matters"
            echo "  • Custom request handling"
            echo "  • Application lifetime"
            echo "  • Health checks"
            ;;
        "module02-exercise01")
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
        "module02-exercise02")
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
        "module02-exercise03")
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
        "module02-exercise04")
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
        "module03-exercise01")
            echo -e "${CYAN}In this exercise, you will learn:${NC}"
            echo "  📚 1. RESTful API principles and design"
            echo "  📚 2. Creating controllers with CRUD operations"
            echo "  📚 3. Dependency injection with DbContext"
            echo "  📚 4. Using Entity Framework Core with in-memory database"
            echo ""
            echo -e "${YELLOW}Key concepts:${NC}"
            echo "  • HTTP methods (GET, POST, PUT, DELETE)"
            echo "  • Status codes (200, 201, 404, etc.)"
            echo "  • Model binding and validation"
            echo "  • Async/await patterns"
            ;;
        "module03-exercise02")
            echo -e "${CYAN}Building on Exercise 1, you will add:${NC}"
            echo "  🔐 1. JWT authentication to your API"
            echo "  🔐 2. User registration and login endpoints"
            echo "  🔐 3. [Authorize] attribute for protected routes"
            echo "  🔐 4. Role-based access control"
            echo ""
            echo -e "${YELLOW}New concepts:${NC}"
            echo "  • JWT tokens and claims"
            echo "  • Authentication vs Authorization"
            echo "  • Password hashing"
            echo "  • Security best practices"
            ;;
        "module03-exercise03")
            echo -e "${CYAN}Finalizing your API with production features:${NC}"
            echo "  📊 1. API versioning strategies"
            echo "  📊 2. Comprehensive Swagger documentation"
            echo "  📊 3. Health check endpoints"
            echo "  📊 4. Advanced API features"
            echo ""
            echo -e "${YELLOW}Professional concepts:${NC}"
            echo "  • Backward compatibility"
            echo "  • API documentation"
            echo "  • Monitoring and health checks"
            echo "  • Production readiness"
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
        "module01-exercise01")
            echo -e "${GREEN}Project Structure:${NC}"
            echo "  MyFirstWebApp/"
            echo "  ├── Pages/"
            echo "  │   ├── Index.cshtml         ${YELLOW}# Home page view${NC}"
            echo "  │   ├── Index.cshtml.cs      ${YELLOW}# Home page code-behind${NC}"
            echo "  │   └── _Layout.cshtml       ${YELLOW}# Shared layout${NC}"
            echo "  ├── wwwroot/"
            echo "  │   ├── css/                 ${YELLOW}# Stylesheets${NC}"
            echo "  │   └── js/                  ${YELLOW}# JavaScript files${NC}"
            echo "  ├── Program.cs               ${YELLOW}# Application entry point${NC}"
            echo "  └── appsettings.json         ${YELLOW}# Configuration${NC}"
            echo ""
            echo -e "${BLUE}This is a Razor Pages application${NC}"
            ;;
            
        "module01-exercise02")
            echo -e "${GREEN}Building on Exercise 1, you'll explore:${NC}"
            echo "  • Program.cs configuration in detail"
            echo "  • appsettings.json and environment-specific settings"
            echo "  • Page lifecycle and model binding"
            echo "  • Layout and ViewImports files"
            echo ""
            echo -e "${YELLOW}No new files, just deeper understanding${NC}"
            ;;
            
        "module01-exercise03")
            echo -e "${GREEN}New concepts to add:${NC}"
            echo "  • Custom middleware in Program.cs"
            echo "  • Request logging middleware"
            echo "  • Health check endpoint"
            echo "  • Custom error pages"
            echo ""
            echo -e "${BLUE}Files to modify:${NC}"
            echo "  • Program.cs (add middleware)"
            echo "  • appsettings.json (add custom settings)"
            ;;

        "module02-exercise01")
            echo -e "${GREEN}Project Structure:${NC}"
            echo "  ReactIntegration/"
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

        "module02-exercise02")
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

        "module02-exercise03")
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

        "module02-exercise04")
            echo -e "${GREEN}Docker integration for the full stack:${NC}"
            echo "  ReactIntegration/"
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

        "module03-exercise01")
            echo -e "${GREEN}Project Structure:${NC}"
            echo "  RestfulAPI/"
            echo "  ├── Controllers/"
            echo "  │   └── BooksController.cs    ${YELLOW}# Your API endpoints${NC}"
            echo "  ├── Models/"
            echo "  │   ├── Book.cs              ${YELLOW}# Book entity model${NC}"
            echo "  │   └── Author.cs            ${YELLOW}# Author entity model${NC}"
            echo "  ├── Data/"
            echo "  │   └── LibraryContext.cs    ${YELLOW}# EF Core database context${NC}"
            echo "  ├── Program.cs               ${YELLOW}# App configuration${NC}"
            echo "  └── appsettings.json         ${YELLOW}# Configuration file${NC}"
            echo ""
            echo -e "${BLUE}Packages to be installed:${NC}"
            echo "  • Microsoft.EntityFrameworkCore.InMemory (8.0.11)"
            echo "  • Swashbuckle.AspNetCore (Already included)"
            ;;
            
        "module03-exercise02")
            echo -e "${GREEN}New additions to your existing project:${NC}"
            echo "  RestfulAPI/"
            echo "  ├── Controllers/"
            echo "  │   ├── BooksController.cs    ${YELLOW}# (existing - will guide updates)${NC}"
            echo "  │   └── AuthController.cs     ${YELLOW}# NEW - Authentication endpoints${NC}"
            echo "  ├── Models/"
            echo "  │   └── Auth/"
            echo "  │       └── AuthModels.cs    ${YELLOW}# NEW - Auth request/response models${NC}"
            echo "  ├── Services/                 ${YELLOW}# NEW - Business logic layer${NC}"
            echo "  └── Middleware/               ${YELLOW}# NEW - Custom middleware${NC}"
            echo ""
            echo -e "${BLUE}New packages:${NC}"
            echo "  • Microsoft.AspNetCore.Authentication.JwtBearer (8.0.11)"
            ;;
            
        "module03-exercise03")
            echo -e "${GREEN}Final enhancements to your API:${NC}"
            echo "  RestfulAPI/"
            echo "  ├── Controllers/"
            echo "  │   ├── V1/                  ${YELLOW}# NEW - Version 1 controllers${NC}"
            echo "  │   └── V2/"
            echo "  │       └── BooksV2Controller.cs ${YELLOW}# NEW - Version 2 with pagination${NC}"
            echo "  ├── Configuration/"
            echo "  │   └── ConfigureSwaggerOptions.cs ${YELLOW}# NEW - Multi-version Swagger${NC}"
            echo "  └── (existing files enhanced)"
            echo ""
            echo -e "${BLUE}New packages:${NC}"
            echo "  • Asp.Versioning.Mvc (8.0.0)"
            echo "  • Asp.Versioning.Mvc.ApiExplorer (8.0.0)"
            echo "  • Swashbuckle.AspNetCore.Annotations (6.8.1)"
            ;;
    esac
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
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
    echo -e "${CYAN}Available Exercises:${NC}"
    echo ""
    echo -e "${BLUE}Module 1 - Introduction to ASP.NET Core:${NC}"
    echo "  - module01-exercise01: Create Your First App"
    echo "  - module01-exercise02: Explore Project Structure"
    echo "  - module01-exercise03: Configuration and Middleware"
    echo ""
    echo -e "${BLUE}Module 2 - ASP.NET Core with React:${NC}"
    echo "  - module02-exercise01: Basic Integration"
    echo "  - module02-exercise02: State Management & Routing"
    echo "  - module02-exercise03: API Integration & Performance"
    echo "  - module02-exercise04: Docker Integration"
    echo ""
    echo -e "${BLUE}Module 3 - Working with Web APIs:${NC}"
    echo "  - module03-exercise01: Create Basic API"
    echo "  - module03-exercise02: Add Authentication & Security"
    echo "  - module03-exercise03: API Documentation & Versioning"
    echo ""
    echo -e "${BLUE}Module 4 - Authentication and Authorization:${NC}"
    echo "  - module04-exercise01: JWT Implementation"
    echo "  - module04-exercise02: Role-Based Authorization"
    echo "  - module04-exercise03: Custom Authorization Policies"
    echo ""
    echo -e "${BLUE}Module 5 - Entity Framework Core:${NC}"
    echo "  - module05-exercise01: Basic EF Core Setup"
    echo "  - module05-exercise02: Advanced LINQ Queries"
    echo "  - module05-exercise03: Repository Pattern"
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
    # Module 1 exercises
    "module01-exercise01")
        PROJECT_NAME="MyFirstWebApp"
        MODULE="Module01-Introduction-to-ASP.NET-Core"
        EXERCISE_TITLE="Create Your First App"
        ;;
    "module01-exercise02")
        PROJECT_NAME="MyFirstWebApp"
        MODULE="Module01-Introduction-to-ASP.NET-Core"
        EXERCISE_TITLE="Explore Project Structure"
        ;;
    "module01-exercise03")
        PROJECT_NAME="MyFirstWebApp"
        MODULE="Module01-Introduction-to-ASP.NET-Core"
        EXERCISE_TITLE="Configuration and Middleware"
        ;;
    # Module 2 exercises
    "module02-exercise01")
        PROJECT_NAME="ReactIntegration"
        MODULE="Module02-ASP.NET-Core-with-React"
        EXERCISE_TITLE="Basic Integration"
        ;;
    "module02-exercise02")
        PROJECT_NAME="ReactIntegration"
        MODULE="Module02-ASP.NET-Core-with-React"
        EXERCISE_TITLE="State Management & Routing"
        ;;
    "module02-exercise03")
        PROJECT_NAME="ReactIntegration"
        MODULE="Module02-ASP.NET-Core-with-React"
        EXERCISE_TITLE="API Integration & Performance"
        ;;
    "module02-exercise04")
        PROJECT_NAME="ReactIntegration"
        MODULE="Module02-ASP.NET-Core-with-React"
        EXERCISE_TITLE="Docker Integration"
        ;;
    # Module 3 exercises
    "module03-exercise01")
        PROJECT_NAME="RestfulAPI"
        MODULE="Module03-Working-with-Web-APIs"
        EXERCISE_TITLE="Create Basic API"
        ;;
    "module03-exercise02")
        PROJECT_NAME="RestfulAPI"
        MODULE="Module03-Working-with-Web-APIs"
        EXERCISE_TITLE="Add Authentication & Security"
        ;;
    "module03-exercise03")
        PROJECT_NAME="RestfulAPI"
        MODULE="Module03-Working-with-Web-APIs"
        EXERCISE_TITLE="API Documentation & Versioning"
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
echo -e "${MAGENTA}🚀 ASP.NET Core Training - Interactive Exercise Launcher${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📚 Module: $MODULE${NC}"
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
    if [[ $EXERCISE_NAME == *"exercise02" ]] || [[ $EXERCISE_NAME == *"exercise03" ]]; then
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
if [[ $EXERCISE_NAME == "module02-exercise01" ]]; then
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
            return Enumerable.Range(1, 5).Select(index => new WeatherForecast
            {
                Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
                TemperatureC = Random.Shared.Next(-20, 55),
                Summary = Summaries[Random.Shared.Next(Summaries.Length)]
            })
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
        policy.WithOrigins("http://localhost:5173") // Vite default port
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
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
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}' \
"TypeScript configuration for React"

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

    # Create Docker setup
    cd ../
    create_file_interactive "docker-compose.yml" \
'version: "3.8"

services:
  backend:
    build:
      context: ./backend/ReactIntegrationAPI
      dockerfile: Dockerfile
    ports:
      - "5000:8080"
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
      - "5173:5173"
    depends_on:
      - backend
    networks:
      - app-network

networks:
  app-network:
    driver: bridge' \
"Docker Compose configuration for full-stack development"

    echo -e "${CYAN}Installing React dependencies...${NC}"
    cd frontend
    npm install
    cd ../

    echo -e "${GREEN}✅ Module 2 Exercise 1 setup complete!${NC}"
    echo -e "${YELLOW}To run the application:${NC}"
    echo "1. Backend: cd backend/ReactIntegrationAPI && dotnet run"
    echo "2. Frontend: cd frontend && npm run dev"
    echo "3. Or use Docker: docker-compose up"

elif [[ $EXERCISE_NAME == "module02-exercise02" ]]; then
    # Exercise 2: State Management & Routing

    explain_concept "React Router and State Management" \
"Advanced React patterns for larger applications:
• React Router for client-side navigation
• Context API for global state management
• Custom hooks for reusable logic
• Component composition patterns"

    echo -e "${CYAN}Adding routing and state management to existing project...${NC}"

    if [ ! -d "frontend" ]; then
        echo -e "${RED}❌ Frontend directory not found. Run module02-exercise01 first.${NC}"
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

    # Update CSS for new components
    create_file_interactive "src/App.css" \
'.App {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.navigation {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 2rem;
  background-color: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
  transition: background-color 0.3s ease;
}

.navigation.dark {
  background-color: #343a40;
  color: white;
  border-bottom-color: #495057;
}

.nav-brand h2 {
  margin: 0;
  color: #007bff;
}

.navigation.dark .nav-brand h2 {
  color: #66b3ff;
}

.nav-links {
  display: flex;
  gap: 1rem;
}

.nav-links a {
  text-decoration: none;
  color: #495057;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  transition: background-color 0.2s ease;
}

.navigation.dark .nav-links a {
  color: #adb5bd;
}

.nav-links a:hover,
.nav-links a.active {
  background-color: #007bff;
  color: white;
}

.nav-user {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.user-menu {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.main-content {
  flex: 1;
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
}

.page {
  animation: fadeIn 0.3s ease-in;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
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
  transition: transform 0.2s ease;
}

.weather-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.features ul {
  list-style-type: none;
  padding: 0;
}

.features li {
  padding: 0.5rem 0;
  border-bottom: 1px solid #eee;
}

.features li:before {
  content: "✓ ";
  color: #28a745;
  font-weight: bold;
}

button {
  background-color: #007bff;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  transition: background-color 0.2s ease;
}

button:hover:not(:disabled) {
  background-color: #0056b3;
}

button:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.theme-section,
.notifications-section {
  margin: 2rem 0;
  padding: 1rem;
  border: 1px solid #ddd;
  border-radius: 8px;
  background-color: #f8f9fa;
}

.notifications-section ul {
  list-style: none;
  padding: 0;
}

.notifications-section li {
  padding: 0.5rem;
  margin: 0.25rem 0;
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  border-radius: 4px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}' \
"Enhanced CSS with navigation and theme support"

    echo -e "${GREEN}✅ Module 2 Exercise 2 setup complete!${NC}"
    echo -e "${YELLOW}New features added:${NC}"
    echo "• React Router for navigation"
    echo "• Context API for global state"
    echo "• Custom hooks for API calls"
    echo "• Theme switching"
    echo "• Notification system"

elif [[ $EXERCISE_NAME == "module02-exercise03" ]]; then
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

  async put<T>(endpoint: string, data?: any): Promise<T> {
    return this.request<T>(endpoint, {
      method: "PUT",
      body: data ? JSON.stringify(data) : undefined,
    });
  }

  async delete<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: "DELETE" });
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

    create_file_interactive "src/services/weatherService.ts" \
'import { apiClient, ApiError } from "./api";

export interface WeatherForecast {
  date: string;
  temperatureC: number;
  temperatureF: number;
  summary: string;
}

export interface WeatherStats {
  averageTemp: number;
  minTemp: number;
  maxTemp: number;
  totalForecasts: number;
}

export class WeatherService {
  static async getForecasts(): Promise<WeatherForecast[]> {
    try {
      return await apiClient.get<WeatherForecast[]>("/weather");
    } catch (error) {
      console.error("Failed to fetch weather forecasts:", error);
      throw error;
    }
  }

  static async getForecastById(id: number): Promise<WeatherForecast> {
    try {
      return await apiClient.get<WeatherForecast>(`/weather/${id}`);
    } catch (error) {
      console.error(`Failed to fetch weather forecast ${id}:`, error);
      throw error;
    }
  }

  static async getWeatherStats(forecasts: WeatherForecast[]): Promise<WeatherStats> {
    if (forecasts.length === 0) {
      return {
        averageTemp: 0,
        minTemp: 0,
        maxTemp: 0,
        totalForecasts: 0,
      };
    }

    const temperatures = forecasts.map(f => f.temperatureC);

    return {
      averageTemp: Math.round(temperatures.reduce((a, b) => a + b, 0) / temperatures.length),
      minTemp: Math.min(...temperatures),
      maxTemp: Math.max(...temperatures),
      totalForecasts: forecasts.length,
    };
  }

  static async refreshCache(): Promise<void> {
    // Simulate cache refresh
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
}' \
"Weather service with business logic and error handling"

    # Create error boundary component
    create_file_interactive "src/components/ErrorBoundary.tsx" \
'import React, { Component, ErrorInfo, ReactNode } from "react";

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export default class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error("Error caught by boundary:", error, errorInfo);

    // In a real app, you would log this to an error reporting service
    // logErrorToService(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }

      return (
        <div className="error-boundary">
          <h2>🚨 Something went wrong</h2>
          <details style={{ whiteSpace: "pre-wrap" }}>
            <summary>Error details</summary>
            {this.state.error?.toString()}
          </details>
          <button
            onClick={() => this.setState({ hasError: false, error: undefined })}
          >
            Try again
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}' \
"Error boundary component for graceful error handling"

    create_file_interactive "src/components/LoadingSpinner.tsx" \
'import React from "react";

interface LoadingSpinnerProps {
  size?: "small" | "medium" | "large";
  message?: string;
  overlay?: boolean;
}

export default function LoadingSpinner({
  size = "medium",
  message = "Loading...",
  overlay = false
}: LoadingSpinnerProps) {
  const sizeClasses = {
    small: "spinner-small",
    medium: "spinner-medium",
    large: "spinner-large"
  };

  const spinner = (
    <div className={`loading-spinner ${sizeClasses[size]}`}>
      <div className="spinner"></div>
      {message && <p className="loading-message">{message}</p>}
    </div>
  );

  if (overlay) {
    return (
      <div className="loading-overlay">
        {spinner}
      </div>
    );
  }

  return spinner;
}' \
"Reusable loading spinner component with different sizes"

    # Create utility functions
    mkdir -p src/utils
    create_file_interactive "src/utils/errorHandler.ts" \
'import { ApiError } from "../services/api";

export interface ErrorInfo {
  message: string;
  type: "network" | "api" | "validation" | "unknown";
  canRetry: boolean;
  statusCode?: number;
}

export function parseError(error: unknown): ErrorInfo {
  if (error instanceof ApiError) {
    return {
      message: error.message,
      type: "api",
      canRetry: error.status >= 500 || error.status === 0,
      statusCode: error.status,
    };
  }

  if (error instanceof TypeError && error.message.includes("fetch")) {
    return {
      message: "Network connection failed. Please check your internet connection.",
      type: "network",
      canRetry: true,
    };
  }

  if (error instanceof Error) {
    return {
      message: error.message,
      type: "unknown",
      canRetry: false,
    };
  }

  return {
    message: "An unexpected error occurred",
    type: "unknown",
    canRetry: false,
  };
}

export function getRetryDelay(attempt: number): number {
  // Exponential backoff: 1s, 2s, 4s, 8s, max 30s
  return Math.min(1000 * Math.pow(2, attempt), 30000);
}

export function shouldRetry(error: ErrorInfo, attempt: number, maxAttempts: number = 3): boolean {
  return error.canRetry && attempt < maxAttempts;
}' \
"Error handling utilities with retry logic"

    # Update the enhanced API hook
    create_file_interactive "src/hooks/useApiWithRetry.ts" \
'import { useState, useEffect, useCallback } from "react";
import { parseError, shouldRetry, getRetryDelay, ErrorInfo } from "../utils/errorHandler";

interface ApiState<T> {
  data: T | null;
  loading: boolean;
  error: ErrorInfo | null;
  retryCount: number;
}

export function useApiWithRetry<T>(
  apiCall: () => Promise<T>,
  dependencies: any[] = [],
  maxRetries: number = 3
) {
  const [state, setState] = useState<ApiState<T>>({
    data: null,
    loading: true,
    error: null,
    retryCount: 0,
  });

  const fetchData = useCallback(async (retryAttempt: number = 0) => {
    try {
      setState(prev => ({
        ...prev,
        loading: true,
        error: null,
        retryCount: retryAttempt
      }));

      const data = await apiCall();

      setState({
        data,
        loading: false,
        error: null,
        retryCount: retryAttempt,
      });
    } catch (error) {
      const errorInfo = parseError(error);

      if (shouldRetry(errorInfo, retryAttempt, maxRetries)) {
        const delay = getRetryDelay(retryAttempt);
        console.log(`Retrying in ${delay}ms (attempt ${retryAttempt + 1}/${maxRetries})`);

        setTimeout(() => {
          fetchData(retryAttempt + 1);
        }, delay);
      } else {
        setState({
          data: null,
          loading: false,
          error: errorInfo,
          retryCount: retryAttempt,
        });
      }
    }
  }, [apiCall, maxRetries]);

  useEffect(() => {
    fetchData();
  }, dependencies);

  const refetch = useCallback(() => {
    fetchData(0);
  }, [fetchData]);

  return { ...state, refetch };
}' \
"Enhanced API hook with automatic retry logic"

    echo -e "${GREEN}✅ Module 2 Exercise 3 setup complete!${NC}"
    echo -e "${YELLOW}Production features added:${NC}"
    echo "• Centralized API client"
    echo "• Error boundaries"
    echo "• Loading states"
    echo "• Automatic retry logic"
    echo "• Performance optimizations"

elif [[ $EXERCISE_NAME == "module02-exercise04" ]]; then
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
RUN npm ci --only=production

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
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss;
}' \
"Nginx configuration with API proxy and security headers"

    # Create production docker-compose
    create_file_interactive "docker-compose.yml" \
'version: "3.8"

services:
  backend:
    build:
      context: ./backend/ReactIntegrationAPI
      dockerfile: Dockerfile
    container_name: react-integration-api
    ports:
      - "5000:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ASPNETCORE_URLS=http://+:8080
    networks:
      - app-network
    restart: unless-stopped

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: react-integration-frontend
    ports:
      - "3000:80"
    depends_on:
      - backend
    networks:
      - app-network
    restart: unless-stopped

networks:
  app-network:
    driver: bridge

volumes:
  app-data:' \
"Production Docker Compose configuration"

    # Create development docker-compose override
    create_file_interactive "docker-compose.dev.yml" \
'version: "3.8"

services:
  backend:
    build:
      context: ./backend/ReactIntegrationAPI
      dockerfile: Dockerfile.dev
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:8080
    volumes:
      - ./backend/ReactIntegrationAPI:/app
      - /app/bin
      - /app/obj
    command: ["dotnet", "watch", "run", "--urls", "http://+:8080"]

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - CHOKIDAR_USEPOLLING=true
    command: ["npm", "run", "dev", "--", "--host", "0.0.0.0"]' \
"Development Docker Compose override with hot reload"

    # Create development Dockerfile for backend
    create_file_interactive "backend/ReactIntegrationAPI/Dockerfile.dev" \
'FROM mcr.microsoft.com/dotnet/sdk:8.0
WORKDIR /app

# Copy csproj and restore dependencies
COPY *.csproj ./
RUN dotnet restore

# Copy everything else
COPY . ./

# Install dotnet tools
RUN dotnet tool install --global dotnet-ef
ENV PATH="$PATH:/root/.dotnet/tools"

EXPOSE 8080

# Use dotnet watch for hot reload
CMD ["dotnet", "watch", "run", "--urls", "http://+:8080"]' \
"Development Dockerfile for ASP.NET Core with hot reload"

    # Create development Dockerfile for frontend
    create_file_interactive "frontend/Dockerfile.dev" \
'FROM node:18-alpine
WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm install

# Copy source code
COPY . .

EXPOSE 5173

# Use Vite dev server with hot reload
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5173"]' \
"Development Dockerfile for React with Vite hot reload"

    # Create .dockerignore files
    create_file_interactive ".dockerignore" \
'# Git
.git
.gitignore
README.md

# Docker
Dockerfile*
docker-compose*
.dockerignore

# Node modules
node_modules
npm-debug.log*

# .NET
bin/
obj/
*.user
*.suo
*.cache
*.docstates
[Dd]ebug/
[Rr]elease/

# IDE
.vs/
.vscode/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
logs
*.log' \
"Docker ignore file to exclude unnecessary files"

    # Create environment file template
    create_file_interactive ".env.example" \
'# Environment Configuration Template
# Copy this file to .env and update values as needed

# API Configuration
API_URL=http://localhost:5000/api
ASPNETCORE_ENVIRONMENT=Development

# Frontend Configuration
VITE_API_URL=http://localhost:5000/api

# Database (if using real database)
# CONNECTION_STRING=Server=localhost;Database=ReactIntegration;Trusted_Connection=true;

# Security (generate secure values for production)
# JWT_SECRET=your-super-secret-jwt-key-here
# JWT_ISSUER=ReactIntegrationApp
# JWT_AUDIENCE=ReactIntegrationUsers

# Docker Configuration
COMPOSE_PROJECT_NAME=react-integration' \
"Environment configuration template"

    # Create startup scripts
    create_file_interactive "scripts/start-dev.sh" \
'#!/bin/bash
echo "🚀 Starting React + ASP.NET Core in development mode..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Build and start development containers
echo "📦 Building development containers..."
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --build

echo "✅ Development environment started!"
echo "🌐 Frontend: http://localhost:5173"
echo "🔧 Backend API: http://localhost:5000"
echo "📚 Swagger UI: http://localhost:5000/swagger"' \
"Development startup script"

    create_file_interactive "scripts/start-prod.sh" \
'#!/bin/bash
echo "🚀 Starting React + ASP.NET Core in production mode..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Build and start production containers
echo "📦 Building production containers..."
docker-compose up --build -d

echo "✅ Production environment started!"
echo "🌐 Application: http://localhost:3000"
echo "🔧 Backend API: http://localhost:5000"

# Show container status
docker-compose ps' \
"Production startup script"

    # Make scripts executable
    chmod +x scripts/start-dev.sh scripts/start-prod.sh

    echo -e "${GREEN}✅ Module 2 Exercise 4 setup complete!${NC}"
    echo -e "${YELLOW}Docker integration added:${NC}"
    echo "• Multi-stage Dockerfiles for both frontend and backend"
    echo "• Production and development configurations"
    echo "• Nginx reverse proxy for frontend"
    echo "• Docker Compose orchestration"
    echo "• Hot reload support in development"
    echo ""
    echo -e "${CYAN}Usage:${NC}"
    echo "• Development: ./scripts/start-dev.sh"
    echo "• Production: ./scripts/start-prod.sh"
    echo "• Manual: docker-compose up --build"

elif [[ $EXERCISE_NAME == "module03-exercise01" ]]; then
    # Exercise 1: Basic CRUD API
    
    explain_concept "RESTful APIs" \
"REST (Representational State Transfer) is an architectural style for APIs:
• Uses HTTP methods: GET (read), POST (create), PUT (update), DELETE (delete)
• Resources are identified by URLs (e.g., /api/books)
• Stateless - each request contains all needed information
• Returns appropriate HTTP status codes"
    
    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${CYAN}Creating new Web API project...${NC}"
        dotnet new webapi -n "$PROJECT_NAME" --framework net8.0
        cd "$PROJECT_NAME"
        rm -f WeatherForecast.cs Controllers/WeatherForecastController.cs
    fi
    
    explain_concept "Models (Domain Entities)" \
"Models represent the data structure of your application:
• They become database tables with Entity Framework
• Properties become columns
• Relationships can be defined between models
• Data annotations can add validation"
    
    # Create models
    create_file_interactive "Models/Book.cs" \
'namespace RestfulAPI.Models
{
    public class Book
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string ISBN { get; set; } = string.Empty;
        public int PublicationYear { get; set; }
        
        // TODO: Add navigation properties for relationships
        // public int AuthorId { get; set; }
        // public Author? Author { get; set; }
    }
}' \
"The Book model represents a book in your library system"
    
    create_file_interactive "Models/Author.cs" \
'namespace RestfulAPI.Models
{
    public class Author
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        
        // TODO: Add navigation property
        // public ICollection<Book> Books { get; set; } = new List<Book>();
    }
}' \
"The Author model represents book authors"
    
    explain_concept "Entity Framework Core & DbContext" \
"Entity Framework Core is an ORM (Object-Relational Mapper):
• DbContext represents a database session
• DbSet<T> properties represent database tables
• Handles CRUD operations and change tracking
• In-memory database is great for learning (no SQL setup needed)"
    
    create_file_interactive "Data/LibraryContext.cs" \
'using Microsoft.EntityFrameworkCore;
using RestfulAPI.Models;

namespace RestfulAPI.Data
{
    public class LibraryContext : DbContext
    {
        public LibraryContext(DbContextOptions<LibraryContext> options)
            : base(options)
        {
        }

        // DbSet properties represent tables in the database
        public DbSet<Book> Books => Set<Book>();
        public DbSet<Author> Authors => Set<Author>();
        
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // TODO: Configure entity relationships and constraints
            base.OnModelCreating(modelBuilder);
        }
    }
}' \
"DbContext manages database connections and entity tracking"
    
    explain_concept "Controllers & Dependency Injection" \
"Controllers handle HTTP requests in ASP.NET Core:
• [ApiController] attribute adds API-specific behaviors
• Route attributes define URL patterns
• Constructor injection provides dependencies
• Action methods handle specific HTTP verbs"
    
    create_file_interactive "Controllers/BooksController.cs" \
'using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Models;
using RestfulAPI.Data;

namespace RestfulAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BooksController : ControllerBase
    {
        private readonly LibraryContext _context;

        // Dependency Injection provides the DbContext
        public BooksController(LibraryContext context)
        {
            _context = context;
        }

        // GET: api/books
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Book>>> GetBooks()
        {
            // TODO: Implement getting all books
            // HINT: Use await _context.Books.ToListAsync()
            return Ok(new { message = "Implement GetBooks" });
        }

        // GET: api/books/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Book>> GetBook(int id)
        {
            // TODO: Get a specific book by ID
            // HINT: Check if book is null and return NotFound()
            return Ok(new { message = $"Implement GetBook for id: {id}" });
        }

        // POST: api/books
        [HttpPost]
        public async Task<ActionResult<Book>> CreateBook(Book book)
        {
            // TODO: Add book to database
            // STEPS:
            // 1. _context.Books.Add(book)
            // 2. await _context.SaveChangesAsync()
            // 3. Return CreatedAtAction(nameof(GetBook), new { id = book.Id }, book)
            return Ok(new { message = "Implement CreateBook" });
        }

        // TODO: Add PUT and DELETE methods
    }
}' \
"The controller handles HTTP requests for book operations"
    
    # Update Program.cs
    explain_concept "Program.cs Configuration" \
"Program.cs is the application entry point:
• Configures services (DI container)
• Sets up the request pipeline (middleware)
• Order matters in the pipeline
• Services are configured before building the app"
    
    create_file_interactive "Program_Updated.cs" \
'using Microsoft.EntityFrameworkCore;
using RestfulAPI.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add Entity Framework with In-Memory Database
builder.Services.AddDbContext<LibraryContext>(options =>
    options.UseInMemoryDatabase("LibraryDB"));

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();' \
"Updated Program.cs with Entity Framework configuration"
    
    echo -e "${YELLOW}📌 Note: Replace the existing Program.cs with Program_Updated.cs content${NC}"
    
    # Install packages
    echo -e "${CYAN}Installing required packages...${NC}"
    dotnet add package Microsoft.EntityFrameworkCore.InMemory --version 8.0.11
    echo -e "${GREEN}✅ Package installation complete${NC}"
    
elif [[ $EXERCISE_NAME == "module03-exercise02" ]]; then
    # Exercise 2: Add Authentication
    
    explain_concept "JWT Authentication" \
"JWT (JSON Web Tokens) provide stateless authentication:
• Client sends credentials to login endpoint
• Server validates and returns a JWT token
• Client includes token in Authorization header
• Server validates token on each request
• Tokens contain claims (user info, roles, etc.)"
    
    echo -e "${CYAN}Adding authentication to your existing API...${NC}"
    
    create_file_interactive "Models/Auth/AuthModels.cs" \
'namespace RestfulAPI.Models.Auth
{
    public class RegisterModel
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
    }
    
    public class LoginModel
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }
    
    public class AuthResponse
    {
        public string Token { get; set; } = string.Empty;
        public DateTime Expiration { get; set; }
    }
}' \
"Models for authentication requests and responses"
    
    create_file_interactive "Controllers/AuthController.cs" \
'using Microsoft.AspNetCore.Mvc;
using RestfulAPI.Models.Auth;

namespace RestfulAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        // TODO: Inject services needed for auth
        
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterModel model)
        {
            // TODO: Implement user registration
            // IMPORTANT: Never store passwords in plain text!
            // Steps:
            // 1. Validate model
            // 2. Check if user exists
            // 3. Hash password
            // 4. Create user
            // 5. Return success
            
            return Ok(new { message = "Implement registration" });
        }
        
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginModel model)
        {
            // TODO: Implement login with JWT
            // Steps:
            // 1. Find user
            // 2. Verify password
            // 3. Generate JWT token
            // 4. Return token
            
            return Ok(new { message = "Implement login" });
        }
    }
}' \
"Authentication controller for user registration and login"
    
    explain_concept "Protecting Endpoints" \
"Use attributes to control access:
• [Authorize] - Requires authentication
• [Authorize(Roles = \"Admin\")] - Requires specific role
• [AllowAnonymous] - Allows public access
• Apply to controllers or individual actions"
    
    create_file_interactive "UPDATE_INSTRUCTIONS.md" \
'# Update Your Existing Controllers

## 1. Update BooksController.cs

Add authentication to your BooksController:

```csharp
using Microsoft.AspNetCore.Authorization;

[Authorize] // Add this to require authentication
[ApiController]
[Route("api/[controller]")]
public class BooksController : ControllerBase
{
    // Your existing code...
    
    // Make GET endpoints public:
    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<IEnumerable<Book>>> GetBooks()
    {
        // Existing implementation
    }
}
```

## 2. Update Program.cs

Add authentication services:

```csharp
// After AddSwaggerGen()
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
        };
    });

// In the pipeline, add:
app.UseAuthentication(); // Before UseAuthorization
app.UseAuthorization();
```

## 3. Update appsettings.json

Add JWT configuration:

```json
{
  "Jwt": {
    "Key": "ThisIsMySecretKeyForJwtAuthentication",
    "Issuer": "YourAppName",
    "Audience": "YourAppUsers",
    "ExpiryMinutes": 60
  }
}
```' \
"Instructions for updating existing files with authentication"
    
    # Install packages
    echo -e "${CYAN}Installing authentication packages...${NC}"
    dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.11
    echo -e "${GREEN}✅ Authentication packages installed${NC}"
    
elif [[ $EXERCISE_NAME == "module03-exercise03" ]]; then
    # Exercise 3: Versioning & Documentation
    
    explain_concept "API Versioning" \
"API versioning allows multiple versions to coexist:
• Maintains backward compatibility
• Allows gradual migration
• Common strategies: URL path, query string, headers
• Each version can have different features"
    
    echo -e "${CYAN}Adding versioning and documentation to your API...${NC}"
    
    create_file_interactive "Controllers/V2/BooksV2Controller.cs" \
'using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;
using RestfulAPI.Models;

namespace RestfulAPI.Controllers.V2
{
    [ApiVersion("2.0")]
    [ApiController]
    [Route("api/v{version:apiVersion}/books")]
    public class BooksV2Controller : ControllerBase
    {
        // TODO: Inject services
        
        [HttpGet]
        public async Task<IActionResult> GetBooks(
            [FromQuery] int page = 1, 
            [FromQuery] int pageSize = 10)
        {
            // TODO: Implement pagination
            // V2 adds pagination support
            
            return Ok(new 
            { 
                page = page,
                pageSize = pageSize,
                items = new List<Book>(),
                totalCount = 0
            });
        }
        
        // TODO: Implement other methods with V2 enhancements
    }
}' \
"Version 2 of the Books API with pagination support"
    
    explain_concept "Swagger Documentation" \
"Swagger/OpenAPI provides interactive API documentation:
• Auto-generated from your code
• Interactive testing interface
• Shows all endpoints, parameters, responses
• Can generate client SDKs"
    
    create_file_interactive "Configuration/ConfigureSwaggerOptions.cs" \
'using Microsoft.Extensions.Options;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;
using Asp.Versioning.ApiExplorer;

namespace RestfulAPI.Configuration
{
    public class ConfigureSwaggerOptions : IConfigureOptions<SwaggerGenOptions>
    {
        private readonly IApiVersionDescriptionProvider _provider;

        public ConfigureSwaggerOptions(IApiVersionDescriptionProvider provider)
        {
            _provider = provider;
        }

        public void Configure(SwaggerGenOptions options)
        {
            // Add swagger document for each API version
            foreach (var description in _provider.ApiVersionDescriptions)
            {
                options.SwaggerDoc(description.GroupName, CreateInfoForApiVersion(description));
            }
        }

        private static OpenApiInfo CreateInfoForApiVersion(ApiVersionDescription description)
        {
            var info = new OpenApiInfo
            {
                Title = "Library API",
                Version = description.ApiVersion.ToString(),
                Description = "A RESTful API for managing library resources"
            };

            if (description.IsDeprecated)
            {
                info.Description += " This API version has been deprecated.";
            }

            return info;
        }
    }
}' \
"Configuration for multi-version Swagger documentation"
    
    create_file_interactive "VERSIONING_UPDATE.md" \
'# Add Versioning to Your API

## Update Program.cs

Add these services after existing service configuration:

```csharp
// API Versioning
builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true;
    options.ReportApiVersions = true;
    options.ApiVersionReader = ApiVersionReader.Combine(
        new UrlSegmentApiVersionReader(),
        new HeaderApiVersionReader("x-api-version"),
        new MediaTypeApiVersionReader("x-api-version")
    );
}).AddApiExplorer(options =>
{
    options.GroupNameFormat = "'v'VVV";
    options.SubstituteApiVersionInUrl = true;
});

// Configure Swagger for versioning
builder.Services.AddTransient<IConfigureOptions<SwaggerGenOptions>, ConfigureSwaggerOptions>();
builder.Services.AddSwaggerGen(options =>
{
    options.OperationFilter<SwaggerDefaultValues>();
});

// Update Swagger UI to show all versions
app.UseSwaggerUI(options =>
{
    var descriptions = app.DescribeApiVersions();
    foreach (var description in descriptions)
    {
        options.SwaggerEndpoint($"/swagger/{description.GroupName}/swagger.json",
            description.GroupName.ToUpperInvariant());
    }
});
```

## Move V1 Controllers

1. Create Controllers/V1 folder
2. Move existing controllers there
3. Add [ApiVersion("1.0")] attribute
4. Update namespace to include .V1' \
"Instructions for implementing API versioning"
    
    # Install packages
    echo -e "${CYAN}Installing versioning packages...${NC}"
    dotnet add package Asp.Versioning.Mvc --version 8.0.0
    dotnet add package Asp.Versioning.Mvc.ApiExplorer --version 8.0.0
    dotnet add package Swashbuckle.AspNetCore.Annotations --version 6.8.1
    echo -e "${GREEN}✅ Versioning packages installed${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Exercise setup complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "1. Review the created files and understand their purpose"
echo "2. Implement all TODO items in the code"
echo "3. Test your API using Swagger UI at http://localhost:5000/swagger"
echo "4. Validate your implementation with the exercise requirements"
echo ""
echo -e "${CYAN}Happy learning! 🚀${NC}"