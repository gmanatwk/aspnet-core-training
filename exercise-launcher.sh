#!/bin/bash

# Enhanced Exercise Launcher for ASP.NET Core Training
# This script sets up exercises with complete scaffolding to minimize manual copying

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

# Function to create directory structure
create_directory_structure() {
    local dirs=("$@")
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        echo -e "  📁 Created: $dir"
    done
}

# Function to create a file with content
create_file() {
    local file_path=$1
    local content=$2
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$file_path")"
    
    # Write content to file
    echo "$content" > "$file_path"
    echo -e "  📄 Created: $file_path"
}

# Check if exercise name is provided
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Usage: $0 <exercise-name> [options]${NC}"
    echo ""
    echo "Options:"
    echo "  --list          Show all available exercises"
    echo "  --validate      Run validation after setup"
    echo "  --solution      Show solution branch name"
    echo ""
    show_exercises
    exit 1
fi

# Handle --list option first
if [ "$1" == "--list" ]; then
    show_exercises
    exit 0
fi

EXERCISE_NAME=$1
VALIDATE_AFTER_SETUP=false
SHOW_SOLUTION=false

# Parse additional options
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --validate)
            VALIDATE_AFTER_SETUP=true
            shift
            ;;
        --solution)
            SHOW_SOLUTION=true
            shift
            ;;
        --list)
            show_exercises
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

echo -e "${MAGENTA}🚀 ASP.NET Core Training - Exercise Launcher${NC}"
echo -e "${MAGENTA}============================================${NC}"
echo ""

# Determine exercise configuration
case $EXERCISE_NAME in
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
    "module02-exercise01")
        PROJECT_NAME="ReactIntegrationApp"
        MODULE="Module02-ASP.NET-Core-with-React"
        EXERCISE_TITLE="Basic React Integration"
        ;;
    "module02-exercise02")
        PROJECT_NAME="ReactStateApp"
        MODULE="Module02-ASP.NET-Core-with-React"
        EXERCISE_TITLE="State Management & Routing"
        ;;
    "module02-exercise03")
        PROJECT_NAME="ReactApiApp"
        MODULE="Module02-ASP.NET-Core-with-React"
        EXERCISE_TITLE="API Integration & Performance"
        ;;
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
    "module04-exercise01")
        PROJECT_NAME="JwtAuthAPI"
        MODULE="Module04-Authentication-and-Authorization"
        EXERCISE_TITLE="JWT Implementation"
        ;;
    "module05-exercise01")
        PROJECT_NAME="EFCoreDemo"
        MODULE="Module05-Entity-Framework-Core"
        EXERCISE_TITLE="Basic EF Core Setup"
        ;;
    *)
        echo -e "${RED}❌ Unknown exercise: $EXERCISE_NAME${NC}"
        echo ""
        show_exercises
        exit 1
        ;;
esac

echo -e "${BLUE}📚 Module: $MODULE${NC}"
echo -e "${BLUE}📝 Exercise: $EXERCISE_TITLE${NC}"
echo -e "${BLUE}📦 Project: $PROJECT_NAME${NC}"
echo ""

# Check if project already exists
if [ -d "$PROJECT_NAME" ]; then
    # Check if this is a follow-up exercise that builds on the previous one
    if [[ $EXERCISE_NAME == *"exercise02" ]] || [[ $EXERCISE_NAME == *"exercise03" ]]; then
        echo -e "${GREEN}✓ Found existing $PROJECT_NAME from previous exercise${NC}"
        echo -e "${CYAN}This exercise will build on your existing work${NC}"
        cd "$PROJECT_NAME"
        
        # Skip project creation and go directly to exercise-specific setup
        SKIP_PROJECT_CREATION=true
    else
        # For exercise01 or different modules, ask about overwriting
        echo -e "${YELLOW}⚠️  Project '$PROJECT_NAME' already exists!${NC}"
        echo -n "Do you want to overwrite it? This will delete all existing work! (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo -e "${RED}Setup cancelled. Existing project preserved.${NC}"
            exit 1
        fi
        echo -n "Creating backup... "
        backup_name="${PROJECT_NAME}_backup_$(date +%Y%m%d_%H%M%S)"
        mv "$PROJECT_NAME" "$backup_name"
        echo -e "${GREEN}✓ Backed up to $backup_name${NC}"
        SKIP_PROJECT_CREATION=false
    fi
else
    SKIP_PROJECT_CREATION=false
fi

# Create project or enhance existing
if [ "$SKIP_PROJECT_CREATION" = true ]; then
    echo -e "${CYAN}Enhancing existing project for $EXERCISE_TITLE...${NC}"
else
    echo -e "${CYAN}Step 1: Creating project structure...${NC}"
fi

# Module 1 Introduction Setup
if [[ $EXERCISE_NAME == module01-exercise* ]]; then
    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        # Module 1 uses Razor Pages (webapp template)
        dotnet new webapp -n "$PROJECT_NAME" --framework net8.0 > /dev/null 2>&1
        cd "$PROJECT_NAME"
    fi
    
    if [[ $EXERCISE_NAME == "module01-exercise01" ]]; then
        # Exercise 1: Basic modifications to understand structure
        create_file "EXERCISE_GUIDE.md" "# Exercise 1: Create Your First App

## Your Tasks:
1. ✏️ Modify Pages/Index.cshtml to display a custom welcome message
2. 🎨 Add custom CSS in wwwroot/css/site.css
3. 📝 Create a new Razor Page called About
4. 🧪 Test hot reload functionality

## Key Files to Explore:
- Program.cs - Application configuration
- Pages/Index.cshtml - Home page view
- Pages/Index.cshtml.cs - Code-behind file
- wwwroot/ - Static files

## Testing:
Run with: dotnet run
Navigate to: https://localhost:5001"
        
        # Add a hint to Index.cshtml
        echo -e "${CYAN}Adding exercise hints to Index.cshtml...${NC}"
        
    elif [[ $EXERCISE_NAME == "module01-exercise02" ]]; then
        # Exercise 2: Understanding project structure
        create_file "PROJECT_STRUCTURE_GUIDE.md" "# Project Structure Guide

## Directories:
- Pages/ - Razor Pages (views and code-behind)
- wwwroot/ - Static files (CSS, JS, images)
- bin/ - Compiled output
- obj/ - Build artifacts

## Key Files:
- Program.cs - Entry point and configuration
- appsettings.json - Configuration settings
- *.csproj - Project file with dependencies

## Your Tasks:
1. Add a custom configuration setting in appsettings.json
2. Read and display it in Index.cshtml.cs
3. Add a new CSS file and reference it
4. Create a Privacy page"
        
    elif [[ $EXERCISE_NAME == "module01-exercise03" ]]; then
        # Exercise 3: Configuration and Middleware
        create_file "MIDDLEWARE_EXERCISE.md" "# Middleware and Configuration Exercise

## Your Tasks:
1. Add custom middleware to log requests
2. Configure different settings for Development/Production
3. Add custom error handling
4. Implement request timing middleware

## Code Templates:
Check Program.cs for TODO comments"
        
        # Modify Program.cs with middleware TODOs
        create_file "Program_Modified.cs" 'var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();

// TODO: Exercise 3.1 - Add your custom services here

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

// TODO: Exercise 3.2 - Add custom middleware here
// app.Use(async (context, next) =>
// {
//     // Log request
//     await next();
//     // Log response
// });

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseAuthorization();
app.MapRazorPages();

// TODO: Exercise 3.3 - Add endpoint for health check

app.Run();'
        
        echo -e "${CYAN}Created middleware exercise template${NC}"
    fi

# Module 2 React Integration Setup
elif [[ $EXERCISE_NAME == module02-exercise* ]]; then
    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        # Create ASP.NET Core project
        dotnet new webapi -n "$PROJECT_NAME" --framework net8.0 > /dev/null 2>&1
        cd "$PROJECT_NAME"
    fi
    
    # Create directory structure
    create_directory_structure \
        "Controllers" \
        "Models" \
        "Services" \
        "ClientApp/src/components" \
        "ClientApp/src/services" \
        "ClientApp/public" \
        "DTOs"
    
    # Create React app files
    create_file "ClientApp/package.json" '{
  "name": "client-app",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.43",
    "@types/react-dom": "^18.2.17",
    "@vitejs/plugin-react": "^4.2.1",
    "typescript": "^5.2.2",
    "vite": "^5.0.8"
  }
}'

    create_file "ClientApp/index.html" '<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>React + ASP.NET Core</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>'

    create_file "ClientApp/src/main.tsx" 'import React from "react"
import ReactDOM from "react-dom/client"
import App from "./App"
import "./index.css"

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)'

    create_file "ClientApp/src/App.tsx" 'import { useState, useEffect } from "react"
import "./App.css"

function App() {
  const [message, setMessage] = useState("")

  useEffect(() => {
    // TODO: Exercise - Fetch data from your API
    setMessage("Welcome to React + ASP.NET Core!")
  }, [])

  return (
    <div className="App">
      <h1>{message}</h1>
      {/* TODO: Add your components here */}
    </div>
  )
}

export default App'

    create_file "ClientApp/src/index.css" ':root {
  font-family: Inter, system-ui, Avenir, Helvetica, Arial, sans-serif;
  line-height: 1.5;
  font-weight: 400;
}

body {
  margin: 0;
  display: flex;
  place-items: center;
  min-width: 320px;
  min-height: 100vh;
}

h1 {
  font-size: 3.2em;
  line-height: 1.1;
}'

    create_file "ClientApp/src/App.css" '.App {
  max-width: 1280px;
  margin: 0 auto;
  padding: 2rem;
  text-align: center;
}'

    create_file "ClientApp/tsconfig.json" '{
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
}'

    create_file "ClientApp/tsconfig.node.json" '{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}'

    create_file "ClientApp/vite.config.ts" 'import { defineConfig } from "vite"
import react from "@vitejs/plugin-react"

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      "/api": {
        target: "http://localhost:5000",
        changeOrigin: true,
        secure: false
      }
    }
  }
})'

    # Update Program.cs for React integration
    create_file "Program.cs" 'var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// TODO: Add your services here

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Serve static files from React app
app.UseDefaultFiles();
app.UseStaticFiles();

app.UseAuthorization();

app.MapControllers();

// TODO: Add SPA fallback routing

app.Run();'

    # Add required packages
    echo -e "${CYAN}Step 2: Installing packages...${NC}"
    dotnet add package Microsoft.AspNetCore.SpaServices.Extensions --version 8.0.0 > /dev/null 2>&1
    echo -e "  ✅ Added SPA Services package"

# Module 3 API Setup
elif [[ $EXERCISE_NAME == module03-exercise* ]]; then
    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        dotnet new webapi -n "$PROJECT_NAME" --framework net8.0 > /dev/null 2>&1
        cd "$PROJECT_NAME"
        
        # Remove default WeatherForecast files
        rm -f WeatherForecast.cs Controllers/WeatherForecastController.cs
    fi
    
    # Exercise-specific setup
    if [[ $EXERCISE_NAME == "module03-exercise01" ]]; then
        # Exercise 1: Basic CRUD API
        echo -e "${CYAN}Setting up Exercise 1: Basic CRUD API${NC}"
        
        create_directory_structure \
            "Controllers" \
            "Models" \
            "Data"
        
        # Create base models
        create_file "Models/Book.cs" 'namespace RestfulAPI.Models
{
    public class Book
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string ISBN { get; set; } = string.Empty;
        public int PublicationYear { get; set; }
        
        // TODO: Add navigation properties
    }
}'

    create_file "Models/Author.cs" 'namespace RestfulAPI.Models
{
    public class Author
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        
        // TODO: Add navigation properties
    }
}'

    create_file "Data/LibraryContext.cs" 'using Microsoft.EntityFrameworkCore;
using RestfulAPI.Models;

namespace RestfulAPI.Data
{
    public class LibraryContext : DbContext
    {
        public LibraryContext(DbContextOptions<LibraryContext> options)
            : base(options)
        {
        }

        public DbSet<Book> Books => Set<Book>();
        public DbSet<Author> Authors => Set<Author>();
        
        // TODO: Add entity configurations
    }
}'

    create_file "Controllers/BooksController.cs" 'using Microsoft.AspNetCore.Mvc;
using RestfulAPI.Models;
using RestfulAPI.Data;

namespace RestfulAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BooksController : ControllerBase
    {
        private readonly LibraryContext _context;

        public BooksController(LibraryContext context)
        {
            _context = context;
        }

        // TODO: Implement CRUD operations
        [HttpGet]
        public IActionResult GetBooks()
        {
            // TODO: Return all books
            return Ok(new { message = "Implement GetBooks" });
        }
    }
}'

        # Install packages for Exercise 1
        echo -e "${CYAN}Installing packages...${NC}"
        dotnet add package Microsoft.EntityFrameworkCore.InMemory --version 8.0.11 > /dev/null 2>&1
        echo -e "  ✅ Added Entity Framework Core InMemory"
        
    elif [[ $EXERCISE_NAME == "module03-exercise02" ]]; then
        # Exercise 2: Add Authentication (builds on Exercise 1)
        echo -e "${CYAN}Setting up Exercise 2: Authentication & Security${NC}"
        echo -e "${YELLOW}This exercise builds on Exercise 1${NC}"
        
        # Add new directories for auth
        create_directory_structure \
            "Models/Auth" \
            "Services" \
            "Middleware"
        
        # Create auth models
        create_file "Models/Auth/AuthModels.cs" 'namespace RestfulAPI.Models.Auth
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
}'
        
        # Create auth controller
        create_file "Controllers/AuthController.cs" 'using Microsoft.AspNetCore.Mvc;
using RestfulAPI.Models.Auth;

namespace RestfulAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        // TODO: Exercise 2.1 - Implement user registration
        [HttpPost("register")]
        public IActionResult Register([FromBody] RegisterModel model)
        {
            // TODO: Implement registration logic
            return Ok(new { message = "Implement registration" });
        }
        
        // TODO: Exercise 2.2 - Implement login
        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginModel model)
        {
            // TODO: Generate JWT token
            return Ok(new { message = "Implement login" });
        }
    }
}'
        
        # Update existing BooksController to add [Authorize]
        create_file "UPDATE_BOOKS_CONTROLLER.md" "# Update Your BooksController

Add authentication to your existing BooksController:

1. Add using statement:
   using Microsoft.AspNetCore.Authorization;

2. Add [Authorize] attribute to the class or specific methods:
   [Authorize]
   [ApiController]
   [Route(\"api/[controller]\")]
   public class BooksController : ControllerBase

3. For public endpoints, use [AllowAnonymous]:
   [HttpGet]
   [AllowAnonymous]
   public async Task<IActionResult> GetBooks()"
        
        # Install auth packages
        echo -e "${CYAN}Installing authentication packages...${NC}"
        dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.11 > /dev/null 2>&1
        echo -e "  ✅ Added JWT Bearer Authentication"
        
    elif [[ $EXERCISE_NAME == "module03-exercise03" ]]; then
        # Exercise 3: API Documentation & Versioning (builds on Exercise 2)
        echo -e "${CYAN}Setting up Exercise 3: API Documentation & Versioning${NC}"
        echo -e "${YELLOW}This exercise builds on Exercises 1 & 2${NC}"
        
        # Add versioning directories
        create_directory_structure \
            "Controllers/V1" \
            "Controllers/V2" \
            "Configuration"
        
        # Create versioning configuration
        create_file "Configuration/ConfigureSwaggerOptions.cs" 'using Microsoft.Extensions.Options;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace RestfulAPI.Configuration
{
    public class ConfigureSwaggerOptions : IConfigureOptions<SwaggerGenOptions>
    {
        public void Configure(SwaggerGenOptions options)
        {
            // TODO: Exercise 3.1 - Configure Swagger for multiple API versions
            options.SwaggerDoc("v1", new OpenApiInfo
            {
                Title = "Library API",
                Version = "v1",
                Description = "Version 1 of the Library API"
            });
            
            // TODO: Add v2 documentation
        }
    }
}'
        
        # Create V2 controller example
        create_file "Controllers/V2/BooksV2Controller.cs" 'using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;

namespace RestfulAPI.Controllers.V2
{
    [ApiVersion("2.0")]
    [ApiController]
    [Route("api/v{version:apiVersion}/books")]
    public class BooksV2Controller : ControllerBase
    {
        // TODO: Exercise 3.2 - Implement V2 with enhanced features
        [HttpGet]
        public IActionResult GetBooks([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
        {
            // TODO: Add pagination support
            return Ok(new { message = "V2 with pagination" });
        }
    }
}'
        
        # Install versioning packages
        echo -e "${CYAN}Installing API versioning packages...${NC}"
        dotnet add package Swashbuckle.AspNetCore.Annotations --version 6.8.1 > /dev/null 2>&1
        dotnet add package Asp.Versioning.Mvc --version 8.0.0 > /dev/null 2>&1
        dotnet add package Asp.Versioning.Mvc.ApiExplorer --version 8.0.0 > /dev/null 2>&1
        echo -e "  ✅ Added API Documentation and Versioning packages"
    fi

# Module 4 Authentication Setup
elif [[ $EXERCISE_NAME == module04-exercise* ]]; then
    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        dotnet new webapi -n "$PROJECT_NAME" --framework net8.0 > /dev/null 2>&1
        cd "$PROJECT_NAME"
    fi
    
    create_directory_structure \
        "Controllers" \
        "Models" \
        "Services" \
        "Requirements" \
        "Handlers"
    
    create_file "Models/AuthModels.cs" 'namespace JwtAuthAPI.Models
{
    public class LoginRequest
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }

    public class LoginResponse
    {
        public string Token { get; set; } = string.Empty;
        public DateTime Expiration { get; set; }
    }

    public class User
    {
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public List<string> Roles { get; set; } = new();
        
        // TODO: Add additional claims
    }
}'

    create_file "Services/JwtTokenService.cs" 'using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using JwtAuthAPI.Models;

namespace JwtAuthAPI.Services
{
    public class JwtTokenService
    {
        private readonly IConfiguration _configuration;

        public JwtTokenService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public LoginResponse GenerateToken(User user)
        {
            // TODO: Implement JWT token generation
            throw new NotImplementedException("Implement token generation");
        }
    }
}'

    create_file "appsettings.json" '{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Jwt": {
    "Key": "ThisIsMySecretKeyForJwtAuthenticationHmacSha256",
    "Issuer": "YourIssuer",
    "Audience": "YourAudience",
    "ExpiryMinutes": 60
  }
}'

    echo -e "${CYAN}Step 2: Installing packages...${NC}"
    dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.11 > /dev/null 2>&1
    dotnet add package System.IdentityModel.Tokens.Jwt --version 8.0.2 > /dev/null 2>&1
    echo -e "  ✅ Added JWT packages"

# Module 5 EF Core Setup
elif [[ $EXERCISE_NAME == module05-exercise* ]]; then
    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        dotnet new webapi -n "$PROJECT_NAME" --framework net8.0 > /dev/null 2>&1
        cd "$PROJECT_NAME"
    fi
    
    create_directory_structure \
        "Controllers" \
        "Models" \
        "Data" \
        "Repositories" \
        "Services" \
        "DTOs"
    
    create_file "Models/Product.cs" 'namespace EFCoreDemo.Models
{
    public class Product
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int CategoryId { get; set; }
        
        // TODO: Add navigation properties
    }
}'

    create_file "Models/Category.cs" 'namespace EFCoreDemo.Models
{
    public class Category
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        
        // TODO: Add navigation properties
    }
}'

    create_file "Data/AppDbContext.cs" 'using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Models;

namespace EFCoreDemo.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        {
        }

        public DbSet<Product> Products => Set<Product>();
        public DbSet<Category> Categories => Set<Category>();
        
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // TODO: Configure entities
            base.OnModelCreating(modelBuilder);
        }
    }
}'

    echo -e "${CYAN}Step 2: Installing packages...${NC}"
    dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 8.0.6 > /dev/null 2>&1
    dotnet add package Microsoft.EntityFrameworkCore.Tools --version 8.0.6 > /dev/null 2>&1
    dotnet add package Microsoft.EntityFrameworkCore.Design --version 8.0.6 > /dev/null 2>&1
    echo -e "  ✅ Added Entity Framework Core packages"

else
    # Generic setup for other modules
    dotnet new webapi -n "$PROJECT_NAME" --framework net8.0 > /dev/null 2>&1
    cd "$PROJECT_NAME"
fi

# Common setup for all projects
echo -e "${CYAN}Step 3: Creating exercise helpers...${NC}"

# Create TODO tracker file
create_file "EXERCISE_TODOS.md" "# Exercise TODO List

## Main Tasks
- [ ] Review the exercise requirements in $MODULE/Exercises/$EXERCISE_NAME.md
- [ ] Implement all TODO comments in the code
- [ ] Run tests to validate your implementation
- [ ] Check your solution against the validation script

## Code TODOs
Run this command to find all TODOs in your code:
\`\`\`bash
grep -r \"TODO\" . --include=\"*.cs\" --include=\"*.tsx\" --include=\"*.ts\"
\`\`\`

## Validation
Run the validation script when you're done:
\`\`\`bash
../validate-exercise.sh $EXERCISE_NAME
\`\`\`
"

# Create a validation script
create_file "../validate-exercise.sh" '#!/bin/bash
# Exercise validation script
EXERCISE=$1

echo "🔍 Validating exercise: $EXERCISE"

# Check if project builds
echo -n "Checking if project builds... "
if dotnet build --nologo --verbosity quiet > /dev/null 2>&1; then
    echo "✅"
else
    echo "❌"
    echo "Build failed. Run '\''dotnet build'\'' to see errors."
    exit 1
fi

# Check for remaining TODOs
echo -n "Checking for incomplete TODOs... "
TODO_COUNT=$(grep -r "TODO" . --include="*.cs" --include="*.tsx" --include="*.ts" | wc -l)
if [ $TODO_COUNT -gt 0 ]; then
    echo "⚠️  Found $TODO_COUNT TODOs"
else
    echo "✅"
fi

# Run tests if they exist
if [ -f "*.Tests.csproj" ]; then
    echo -n "Running tests... "
    if dotnet test --nologo --verbosity quiet > /dev/null 2>&1; then
        echo "✅"
    else
        echo "❌"
    fi
fi

echo ""
echo "Validation complete!"
'
chmod +x ../validate-exercise.sh

# Create helpful scripts
create_file "run-exercise.sh" '#!/bin/bash
# Quick run script for the exercise

echo "🚀 Starting the application..."

# For React apps, run both frontend and backend
if [ -d "ClientApp" ]; then
    echo "Starting backend..."
    dotnet run &
    BACKEND_PID=$!
    
    echo "Starting frontend..."
    cd ClientApp
    npm install
    npm run dev &
    FRONTEND_PID=$!
    
    echo ""
    echo "✅ Application running!"
    echo "Backend: http://localhost:5000"
    echo "Frontend: http://localhost:5173"
    echo ""
    echo "Press Ctrl+C to stop both servers"
    
    trap "kill $BACKEND_PID $FRONTEND_PID" INT
    wait
else
    dotnet run
fi
'
chmod +x run-exercise.sh

# Final setup steps
echo -e "${CYAN}Step 4: Final setup...${NC}"

# Restore packages
dotnet restore > /dev/null 2>&1
echo -e "  ✅ Packages restored"

# Build to verify
if dotnet build --nologo --verbosity quiet > /dev/null 2>&1; then
    echo -e "  ✅ Build successful"
else
    echo -e "  ⚠️  Build has warnings/errors - this is expected for exercises"
fi

# Install npm packages for React exercises
if [ -d "ClientApp" ]; then
    echo -e "  📦 Installing React dependencies..."
    cd ClientApp
    npm install > /dev/null 2>&1
    cd ..
    echo -e "  ✅ React setup complete"
fi

echo ""
echo -e "${GREEN}🎉 Exercise setup complete!${NC}"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "1. 📖 Review the exercise instructions:"
echo -e "   ${BLUE}$MODULE/Exercises/$EXERCISE_NAME.md${NC}"
echo ""
echo "2. 📝 Check the TODO list:"
echo -e "   ${BLUE}cat EXERCISE_TODOS.md${NC}"
echo ""
echo "3. 🔍 Find all TODOs in the code:"
echo -e "   ${BLUE}grep -r \"TODO\" . --include=\"*.cs\"${NC}"
echo ""
echo "4. ▶️  Run the application:"
echo -e "   ${BLUE}./run-exercise.sh${NC}"
echo ""
echo "5. ✅ Validate your solution:"
echo -e "   ${BLUE}../validate-exercise.sh $EXERCISE_NAME${NC}"
echo ""

if [ "$SHOW_SOLUTION" = true ]; then
    echo -e "${MAGENTA}💡 Solution Branch:${NC}"
    echo -e "   ${BLUE}git checkout solution/$EXERCISE_NAME${NC}"
    echo ""
fi

echo -e "${CYAN}Happy coding! 🚀${NC}"