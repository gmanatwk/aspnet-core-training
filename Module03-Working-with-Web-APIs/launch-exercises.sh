#!/bin/bash

# Module 3 Interactive Exercise Launcher
# Working with Web APIs

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

# Function to show learning objectives
show_learning_objectives() {
    local exercise=$1
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}🎯 Learning Objectives${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${CYAN}In this exercise, you will learn:${NC}"
            echo "  📚 1. RESTful API principles and design"
            echo "  📚 2. Creating complete CRUD operations for Products"
            echo "  📚 3. Entity Framework Core with in-memory database"
            echo "  📚 4. Data Transfer Objects (DTOs) for clean API contracts"
            echo "  📚 5. Input validation and error handling"
            echo ""
            echo -e "${YELLOW}Key concepts:${NC}"
            echo "  • HTTP methods (GET, POST, PUT, DELETE)"
            echo "  • Status codes (200, 201, 404, 400, etc.)"
            echo "  • Model binding and validation"
            echo "  • Async/await patterns"
            echo "  • Swagger/OpenAPI documentation"
            ;;
        "exercise02")
            echo -e "${CYAN}Building on Exercise 1, you will add:${NC}"
            echo "  🔐 1. JWT authentication to your Products API"
            echo "  🔐 2. User registration and login endpoints"
            echo "  🔐 3. [Authorize] attribute for protected routes"
            echo "  🔐 4. Role-based access control"
            echo "  🔐 5. Identity framework integration"
            echo ""
            echo -e "${YELLOW}New concepts:${NC}"
            echo "  • JWT tokens and claims"
            echo "  • Authentication vs Authorization"
            echo "  • ASP.NET Core Identity"
            echo "  • Password hashing and security"
            echo "  • Refresh tokens"
            ;;
        "exercise03")
            echo -e "${CYAN}Finalizing your API with production features:${NC}"
            echo "  📊 1. API versioning strategies"
            echo "  📊 2. Comprehensive Swagger documentation"
            echo "  📊 3. Health check endpoints"
            echo "  📊 4. Advanced API features and monitoring"
            echo "  📊 5. Production-ready configuration"
            echo ""
            echo -e "${YELLOW}Professional concepts:${NC}"
            echo "  • Backward compatibility"
            echo "  • API documentation best practices"
            echo "  • Monitoring and health checks"
            echo "  • Performance and security"
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
            echo -e "${GREEN}🎯 Exercise 01: Create Complete Products API${NC}"
            echo ""
            echo -e "${YELLOW}📋 What you'll build:${NC}"
            echo "  ✅ Complete RESTful Products API with full CRUD operations"
            echo "  ✅ Entity Framework with in-memory database and seed data"
            echo "  ✅ Data Transfer Objects (DTOs) for clean API contracts"
            echo "  ✅ Input validation and error handling"
            echo "  ✅ Swagger documentation with XML comments"
            echo "  ✅ SKU uniqueness validation"
            echo "  ✅ Advanced filtering and search capabilities"
            echo ""
            echo -e "${BLUE}🚀 RECOMMENDED: Use the Complete Working Example${NC}"
            echo "  ${CYAN}cd SourceCode/RestfulAPI && dotnet run${NC}"
            echo "  Then visit: ${CYAN}http://localhost:5000${NC} for Swagger UI"
            echo ""
            echo -e "${GREEN}📁 Complete Project Structure:${NC}"
            echo "  RestfulAPI/"
            echo "  ├── Controllers/"
            echo "  │   └── ProductsController.cs ${YELLOW}# Complete CRUD with filtering${NC}"
            echo "  ├── Models/"
            echo "  │   └── Product.cs           ${YELLOW}# Full Product entity${NC}"
            echo "  ├── DTOs/"
            echo "  │   └── ProductDtos.cs       ${YELLOW}# Create/Update/Response DTOs${NC}"
            echo "  ├── Data/"
            echo "  │   └── ApplicationDbContext.cs ${YELLOW}# EF Core with seed data${NC}"
            echo "  ├── Program.cs               ${YELLOW}# Complete configuration${NC}"
            echo "  └── appsettings.json         ${YELLOW}# Settings${NC}"
            ;;

        "exercise02")
            echo -e "${GREEN}🎯 Exercise 02: Add Authentication & Security${NC}"
            echo ""
            echo -e "${YELLOW}📋 Building on your Products API:${NC}"
            echo "  ✅ JWT authentication with ASP.NET Core Identity"
            echo "  ✅ User registration and login endpoints"
            echo "  ✅ Role-based authorization (Admin, User roles)"
            echo "  ✅ Refresh token support"
            echo "  ✅ Protected endpoints with [Authorize] attributes"
            echo "  ✅ Password validation and security best practices"
            echo ""
            echo -e "${GREEN}📁 New additions to your project:${NC}"
            echo "  RestfulAPI/"
            echo "  ├── Controllers/"
            echo "  │   ├── ProductsController.cs ${YELLOW}# (enhanced with [Authorize])${NC}"
            echo "  │   └── AuthController.cs     ${YELLOW}# NEW - Authentication endpoints${NC}"
            echo "  ├── Models/Auth/"
            echo "  │   ├── User.cs              ${YELLOW}# NEW - Identity user model${NC}"
            echo "  │   └── AuthModels.cs        ${YELLOW}# NEW - Auth request/response models${NC}"
            echo "  ├── Services/"
            echo "  │   └── JwtService.cs        ${YELLOW}# NEW - JWT token generation${NC}"
            echo "  └── Data/"
            echo "      └── ApplicationDbContext.cs ${YELLOW}# Enhanced with Identity${NC}"
            echo ""
            echo -e "${BLUE}New packages:${NC}"
            echo "  • Microsoft.AspNetCore.Authentication.JwtBearer"
            echo "  • Microsoft.AspNetCore.Identity.EntityFrameworkCore"
            echo "  • System.IdentityModel.Tokens.Jwt"
            ;;

        "exercise03")
            echo -e "${GREEN}🎯 Exercise 03: API Documentation & Versioning${NC}"
            echo ""
            echo -e "${YELLOW}📋 Professional API features:${NC}"
            echo "  ✅ API versioning with URL path strategy"
            echo "  ✅ Multi-version Swagger documentation"
            echo "  ✅ Health checks with custom monitoring"
            echo "  ✅ Advanced Swagger configuration with JWT support"
            echo "  ✅ API analytics and monitoring middleware"
            echo "  ✅ Production-ready configuration"
            echo ""
            echo -e "${GREEN}📁 Final enhancements:${NC}"
            echo "  RestfulAPI/"
            echo "  ├── Controllers/"
            echo "  │   ├── V1/ProductsController.cs ${YELLOW}# Version 1 API${NC}"
            echo "  │   └── V2/ProductsController.cs ${YELLOW}# Version 2 with pagination${NC}"
            echo "  ├── Configuration/"
            echo "  │   └── ConfigureSwaggerOptions.cs ${YELLOW}# Multi-version Swagger${NC}"
            echo "  ├── HealthChecks/"
            echo "  │   └── ApiHealthCheck.cs    ${YELLOW}# Custom health monitoring${NC}"
            echo "  ├── Middleware/"
            echo "  │   └── ApiAnalyticsMiddleware.cs ${YELLOW}# Request analytics${NC}"
            echo "  └── (all existing files enhanced)"
            echo ""
            echo -e "${BLUE}New packages:${NC}"
            echo "  • Asp.Versioning.Mvc"
            echo "  • Asp.Versioning.Mvc.ApiExplorer"
            echo "  • AspNetCore.HealthChecks.UI"
            echo "  • Swashbuckle.AspNetCore.Annotations"
            ;;
    esac
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to explain a concept
explain_concept() {
    local concept=$1
    local explanation=$2
    
    echo -e "${MAGENTA}💡 Concept: $concept${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "$explanation"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to show available exercises
show_exercises() {
    echo -e "${CYAN}Module 3 - Working with Web APIs${NC}"
    echo -e "${CYAN}Available Exercises:${NC}"
    echo ""
    echo "  - exercise01: Create Basic API"
    echo "  - exercise02: Add Authentication & Security"
    echo "  - exercise03: API Documentation & Versioning"
    echo ""
    echo "Usage:"
    echo "  ./launch-exercises.sh <exercise-name> [options]"
    echo ""
    echo "Options:"
    echo "  --list          Show all available exercises"
    echo "  --auto          Skip interactive mode"
    echo "  --preview       Show what will be created without creating"
}

# Main script starts here
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Usage: $0 <exercise-name> [options]${NC}"
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
PROJECT_NAME="RestfulAPI"
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

# Validate exercise name
case $EXERCISE_NAME in
    "exercise01"|"exercise02"|"exercise03")
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
echo -e "${MAGENTA}🚀 Module 3: Working with Web APIs${NC}"
echo -e "${MAGENTA}Exercise: $EXERCISE_NAME${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show the recommended approach
echo -e "${GREEN}🎯 RECOMMENDED APPROACH:${NC}"
echo -e "${CYAN}For the best learning experience, use the complete working implementation:${NC}"
echo ""
echo -e "${YELLOW}1. Use the working source code:${NC}"
echo -e "   ${CYAN}cd SourceCode/RestfulAPI${NC}"
echo -e "   ${CYAN}dotnet run${NC}"
echo -e "   ${CYAN}# Visit: http://localhost:5000 for Swagger UI${NC}"
echo ""
echo -e "${YELLOW}2. Or use Docker for full-stack experience:${NC}"
echo -e "   ${CYAN}cd SourceCode${NC}"
echo -e "   ${CYAN}docker-compose up --build${NC}"
echo -e "   ${CYAN}# Frontend: http://localhost:3000${NC}"
echo -e "   ${CYAN}# API: http://localhost:5001${NC}"
echo ""
echo -e "${YELLOW}⚠️  The template created by this script is basic and may not match${NC}"
echo -e "${YELLOW}   all exercise requirements. The SourceCode version is complete!${NC}"
echo ""

if [ "$INTERACTIVE_MODE" = true ]; then
    echo -e "${YELLOW}🎮 Interactive Mode: ON${NC}"
    echo -e "${CYAN}You'll see what each file does before it's created${NC}"
else
    echo -e "${YELLOW}⚡ Automatic Mode: ON${NC}"
fi

echo ""
echo -n "Continue with template creation? (y/N): "
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}💡 Great choice! Use the SourceCode version for the best experience.${NC}"
    exit 0
fi

# Show learning objectives
show_learning_objectives $EXERCISE_NAME

# Show creation overview
show_creation_overview $EXERCISE_NAME

if [ "$PREVIEW_ONLY" = true ]; then
    echo -e "${YELLOW}Preview mode - no files will be created${NC}"
    exit 0
fi

# Check if project exists in current directory
if [ -d "$PROJECT_NAME" ]; then
    if [[ $EXERCISE_NAME == "exercise02" ]] || [[ $EXERCISE_NAME == "exercise03" ]]; then
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

        # Add required packages first
        echo -e "${CYAN}Adding Entity Framework packages...${NC}"
        dotnet add package Microsoft.EntityFrameworkCore.InMemory --version 8.0.11 > /dev/null 2>&1
        dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 8.0.11 > /dev/null 2>&1
        dotnet add package Microsoft.EntityFrameworkCore.Tools --version 8.0.11 > /dev/null 2>&1
        echo -e "${GREEN}✅ Required packages installed${NC}"

        # Enable XML documentation generation by recreating the .csproj file
        echo -e "${CYAN}Configuring XML documentation...${NC}"
        cat > RestfulAPI.csproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    <NoWarn>$(NoWarn);1591</NoWarn>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.OpenApi" Version="8.0.16" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.InMemory" Version="8.0.11" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="8.0.11" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.Tools" Version="8.0.11">
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
      <PrivateAssets>all</PrivateAssets>
    </PackageReference>
    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.6.2" />
  </ItemGroup>

</Project>
EOF
        echo -e "${GREEN}✅ XML documentation enabled${NC}"

        # Create launchSettings.json to ensure consistent port
        create_file_interactive "Properties/launchSettings.json" \
'{
  "profiles": {
    "http": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "http://localhost:5000",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}' \
"Launch settings to ensure consistent port 5000"

        # Update Program.cs with proper configuration
        create_file_interactive "Program.cs" \
'using Microsoft.EntityFrameworkCore;
using RestfulAPI.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();

// Add Entity Framework with In-Memory Database
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseInMemoryDatabase("ProductsDB"));

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "Products API", Version = "v1" });

    // Include XML comments for better documentation
    var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
    {
        c.IncludeXmlComments(xmlPath);
    }
});

// Add CORS for development
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Products API v1");
        c.RoutePrefix = "swagger"; // Serve Swagger UI at /swagger
    });
}

// Seed the database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    context.Database.EnsureCreated();
}

app.UseCors("AllowAll");

// Only use HTTPS redirection in production
if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseAuthorization();
app.MapControllers();

app.Run();' \
"Program.cs with Entity Framework and development-friendly configuration"
    fi
    
    explain_concept "Models (Domain Entities)" \
"Models represent the data structure of your application:
• They become database tables with Entity Framework
• Properties become columns
• Relationships can be defined between models
• Data annotations can add validation"
    
    # Create Product model (aligned with exercises)
    create_file_interactive "Models/Product.cs" \
'using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.Models
{
    /// <summary>
    /// Product entity model
    /// </summary>
    public class Product
    {
        /// <summary>
        /// Unique identifier
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Product name
        /// </summary>
        [Required]
        [StringLength(200)]
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// Product description
        /// </summary>
        [StringLength(2000)]
        public string Description { get; set; } = string.Empty;

        /// <summary>
        /// Product price
        /// </summary>
        [Range(0.01, double.MaxValue)]
        public decimal Price { get; set; }

        /// <summary>
        /// Product category
        /// </summary>
        [Required]
        [StringLength(100)]
        public string Category { get; set; } = string.Empty;

        /// <summary>
        /// Stock quantity
        /// </summary>
        [Range(0, int.MaxValue)]
        public int StockQuantity { get; set; }

        /// <summary>
        /// Stock keeping unit
        /// </summary>
        [Required]
        [StringLength(50)]
        public string Sku { get; set; } = string.Empty;

        /// <summary>
        /// Indicates if the product is active
        /// </summary>
        public bool IsActive { get; set; } = true;

        /// <summary>
        /// Indicates if the product is available for sale
        /// </summary>
        public bool IsAvailable { get; set; } = true;

        /// <summary>
        /// Creation timestamp
        /// </summary>
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Last update timestamp
        /// </summary>
        public DateTime? UpdatedAt { get; set; }

        /// <summary>
        /// Soft delete flag
        /// </summary>
        public bool IsDeleted { get; set; } = false;
    }
}' \
"The Product model represents a product in your e-commerce system"
    
    # Create DTOs (Data Transfer Objects)
    explain_concept "Data Transfer Objects (DTOs)" \
"DTOs provide clean API contracts:
• Separate internal models from API responses
• Control what data is exposed to clients
• Enable versioning and backward compatibility
• Provide validation for incoming data"

    create_file_interactive "DTOs/ProductDtos.cs" \
'using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.DTOs
{
    /// <summary>
    /// Product data transfer object
    /// </summary>
    public record ProductDto
    {
        public int Id { get; init; }
        public string Name { get; init; } = string.Empty;
        public string Description { get; init; } = string.Empty;
        public decimal Price { get; init; }
        public string Category { get; init; } = string.Empty;
        public int StockQuantity { get; init; }
        public string Sku { get; init; } = string.Empty;
        public bool IsActive { get; init; }
        public bool IsAvailable { get; init; }
        public DateTime CreatedAt { get; init; }
        public DateTime? UpdatedAt { get; init; }
    }

    /// <summary>
    /// DTO for creating a new product
    /// </summary>
    public record CreateProductDto
    {
        [Required(ErrorMessage = "Product name is required")]
        [StringLength(200, MinimumLength = 1)]
        public string Name { get; init; } = string.Empty;

        [StringLength(2000)]
        public string Description { get; init; } = string.Empty;

        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than 0")]
        public decimal Price { get; init; }

        [Required]
        [StringLength(100, MinimumLength = 1)]
        public string Category { get; init; } = string.Empty;

        [Range(0, int.MaxValue)]
        public int StockQuantity { get; init; }

        [Required]
        [StringLength(50, MinimumLength = 1)]
        public string Sku { get; init; } = string.Empty;

        public bool? IsActive { get; init; }
    }

    /// <summary>
    /// DTO for updating an existing product
    /// </summary>
    public record UpdateProductDto
    {
        [Required]
        [StringLength(200, MinimumLength = 1)]
        public string Name { get; init; } = string.Empty;

        [StringLength(2000)]
        public string Description { get; init; } = string.Empty;

        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal Price { get; init; }

        [Required]
        [StringLength(100, MinimumLength = 1)]
        public string Category { get; init; } = string.Empty;

        [Range(0, int.MaxValue)]
        public int StockQuantity { get; init; }

        [Required]
        [StringLength(50, MinimumLength = 1)]
        public string Sku { get; init; } = string.Empty;

        public bool? IsActive { get; init; }
        public bool? IsAvailable { get; init; }
    }
}' \
"DTOs provide clean separation between API contracts and internal models"

    explain_concept "Entity Framework Core & DbContext" \
"Entity Framework Core is an ORM (Object-Relational Mapper):
• DbContext represents a database session
• DbSet<T> properties represent database tables
• Handles CRUD operations and change tracking
• In-memory database is great for learning (no SQL setup needed)"
    
    create_file_interactive "Data/ApplicationDbContext.cs" \
'using Microsoft.EntityFrameworkCore;
using RestfulAPI.Models;

namespace RestfulAPI.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<Product> Products => Set<Product>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Configure Product entity
            modelBuilder.Entity<Product>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
                entity.Property(e => e.Description).HasMaxLength(2000);
                entity.Property(e => e.Category).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Sku).IsRequired().HasMaxLength(50);
                entity.HasIndex(e => e.Sku).IsUnique();
                entity.Property(e => e.Price).HasPrecision(18, 2);

                // Add query filter to exclude soft-deleted items
                entity.HasQueryFilter(p => !p.IsDeleted);
            });

            // Seed data
            modelBuilder.Entity<Product>().HasData(
                new Product
                {
                    Id = 1,
                    Name = "Laptop Computer",
                    Description = "High-performance laptop with 16GB RAM and 512GB SSD",
                    Price = 999.99m,
                    Category = "Electronics",
                    StockQuantity = 50,
                    Sku = "ELEC-LAP-001",
                    IsActive = true,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Product
                {
                    Id = 2,
                    Name = "Wireless Mouse",
                    Description = "Ergonomic wireless mouse with precision tracking",
                    Price = 29.99m,
                    Category = "Accessories",
                    StockQuantity = 100,
                    Sku = "ACC-MOU-002",
                    IsActive = true,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Product
                {
                    Id = 3,
                    Name = "Programming Book",
                    Description = "Comprehensive guide to modern software development",
                    Price = 49.99m,
                    Category = "Books",
                    StockQuantity = 25,
                    Sku = "BOOK-PROG-003",
                    IsActive = true,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                }
            );
        }
    }
}' \
"ApplicationDbContext manages database connections and entity tracking"
    
    explain_concept "Controllers & Dependency Injection" \
"Controllers handle HTTP requests in ASP.NET Core:
• [ApiController] attribute adds API-specific behaviors
• Route attributes define URL patterns
• Constructor injection provides dependencies
• Action methods handle specific HTTP verbs"
    
    create_file_interactive "Controllers/ProductsController.cs" \
'using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Data;
using RestfulAPI.DTOs;
using RestfulAPI.Models;

namespace RestfulAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class ProductsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<ProductsController> _logger;

        public ProductsController(ApplicationDbContext context, ILogger<ProductsController> logger)
        {
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// Get all products with optional filtering
        /// </summary>
        /// <param name="category">Filter by category name</param>
        /// <param name="name">Filter by product name</param>
        /// <param name="minPrice">Minimum price filter</param>
        /// <param name="maxPrice">Maximum price filter</param>
        /// <returns>List of products</returns>
        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<ProductDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<ProductDto>>> GetProducts(
            [FromQuery] string? category = null,
            [FromQuery] string? name = null,
            [FromQuery] decimal? minPrice = null,
            [FromQuery] decimal? maxPrice = null)
        {
            _logger.LogInformation("Getting products with filters - Category: {Category}, Name: {Name}, MinPrice: {MinPrice}, MaxPrice: {MaxPrice}",
                category, name, minPrice, maxPrice);

            var query = _context.Products.AsQueryable();

            if (!string.IsNullOrWhiteSpace(category))
            {
                query = query.Where(p => p.Category.Contains(category));
            }

            if (!string.IsNullOrWhiteSpace(name))
            {
                query = query.Where(p => p.Name.Contains(name));
            }

            if (minPrice.HasValue)
            {
                query = query.Where(p => p.Price >= minPrice.Value);
            }

            if (maxPrice.HasValue)
            {
                query = query.Where(p => p.Price <= maxPrice.Value);
            }

            var products = await query
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Category = p.Category,
                    StockQuantity = p.StockQuantity,
                    Sku = p.Sku,
                    IsActive = p.IsActive,
                    IsAvailable = p.IsAvailable,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .ToListAsync();

            return Ok(products);
        }

        /// <summary>
        /// Get a specific product by ID
        /// </summary>
        /// <param name="id">Product ID</param>
        /// <returns>Product details</returns>
        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(ProductDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<ProductDto>> GetProduct(int id)
        {
            _logger.LogInformation("Getting product with ID: {ProductId}", id);

            var product = await _context.Products
                .Where(p => p.Id == id)
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Category = p.Category,
                    StockQuantity = p.StockQuantity,
                    Sku = p.Sku,
                    IsActive = p.IsActive,
                    IsAvailable = p.IsAvailable,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .FirstOrDefaultAsync();

            if (product == null)
            {
                _logger.LogWarning("Product with ID {ProductId} not found", id);
                return NotFound(new { message = $"Product with ID {id} not found" });
            }

            return Ok(product);
        }

        /// <summary>
        /// Create a new product (Admin only)
        /// </summary>
        /// <param name="createProductDto">Product creation data</param>
        /// <returns>Created product</returns>
        [HttpPost]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(typeof(ProductDto), StatusCodes.Status201Created)]
        [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<ActionResult<ProductDto>> CreateProduct([FromBody] CreateProductDto createProductDto)
        {
            _logger.LogInformation("Creating new product: {ProductName}", createProductDto.Name);

            // Check for duplicate SKU
            var skuExists = await _context.Products.AnyAsync(p => p.Sku == createProductDto.Sku);
            if (skuExists)
            {
                return BadRequest(new { message = $"Product with SKU {createProductDto.Sku} already exists" });
            }

            var product = new Product
            {
                Name = createProductDto.Name,
                Description = createProductDto.Description,
                Price = createProductDto.Price,
                Category = createProductDto.Category,
                StockQuantity = createProductDto.StockQuantity,
                Sku = createProductDto.Sku,
                IsActive = createProductDto.IsActive ?? true,
                IsAvailable = true,
                CreatedAt = DateTime.UtcNow
            };

            _context.Products.Add(product);
            await _context.SaveChangesAsync();

            var productDto = new ProductDto
            {
                Id = product.Id,
                Name = product.Name,
                Description = product.Description,
                Price = product.Price,
                Category = product.Category,
                StockQuantity = product.StockQuantity,
                Sku = product.Sku,
                IsActive = product.IsActive,
                IsAvailable = product.IsAvailable,
                CreatedAt = product.CreatedAt,
                UpdatedAt = product.UpdatedAt
            };

            return CreatedAtAction(
                nameof(GetProduct),
                new { id = product.Id },
                productDto);
        }

        /// <summary>
        /// Update an existing product (Admin only)
        /// </summary>
        /// <param name="id">Product ID</param>
        /// <param name="updateProductDto">Updated product data</param>
        /// <returns>No content</returns>
        [HttpPut("{id:int}")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<IActionResult> UpdateProduct(int id, [FromBody] UpdateProductDto updateProductDto)
        {
            _logger.LogInformation("Updating product with ID: {ProductId}", id);

            var product = await _context.Products.FindAsync(id);
            if (product == null)
            {
                return NotFound(new { message = $"Product with ID {id} not found" });
            }

            // Check for duplicate SKU (if changed)
            if (!string.IsNullOrEmpty(updateProductDto.Sku) && product.Sku != updateProductDto.Sku)
            {
                var skuExists = await _context.Products.AnyAsync(p => p.Sku == updateProductDto.Sku && p.Id != id);
                if (skuExists)
                {
                    return BadRequest(new { message = $"Product with SKU {updateProductDto.Sku} already exists" });
                }
            }

            product.Name = updateProductDto.Name;
            product.Description = updateProductDto.Description;
            product.Price = updateProductDto.Price;
            product.Category = updateProductDto.Category;
            product.StockQuantity = updateProductDto.StockQuantity;

            if (!string.IsNullOrEmpty(updateProductDto.Sku))
            {
                product.Sku = updateProductDto.Sku;
            }

            if (updateProductDto.IsActive.HasValue)
            {
                product.IsActive = updateProductDto.IsActive.Value;
            }

            if (updateProductDto.IsAvailable.HasValue)
            {
                product.IsAvailable = updateProductDto.IsAvailable.Value;
            }

            product.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return NoContent();
        }

        /// <summary>
        /// Delete a product (Admin only)
        /// </summary>
        /// <param name="id">Product ID</param>
        /// <returns>No content</returns>
        [HttpDelete("{id:int}")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<IActionResult> DeleteProduct(int id)
        {
            _logger.LogInformation("Deleting product with ID: {ProductId}", id);

            var product = await _context.Products.FindAsync(id);
            if (product == null)
            {
                return NotFound(new { message = $"Product with ID {id} not found" });
            }

            _context.Products.Remove(product);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        /// <summary>
        /// Get products by category
        /// </summary>
        /// <param name="category">Category name</param>
        /// <returns>List of products in the category</returns>
        [HttpGet("by-category/{category}")]
        [ProducesResponseType(typeof(IEnumerable<ProductDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<ProductDto>>> GetProductsByCategory(string category)
        {
            var products = await _context.Products
                .Where(p => p.Category.Contains(category))
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Category = p.Category,
                    StockQuantity = p.StockQuantity,
                    Sku = p.Sku,
                    IsActive = p.IsActive,
                    IsAvailable = p.IsAvailable,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .ToListAsync();

            return Ok(products);
        }
    }
}' \
"Complete ProductsController with full CRUD operations"
    
    # Update Program.cs
    explain_concept "Program.cs Configuration" \
"Program.cs is the application entry point:
• Configures services (DI container)
• Sets up the request pipeline (middleware)
• Order matters in the pipeline
• Services are configured before building the app"
    
    create_file_interactive "EXERCISE_GUIDE.md" \
'# Exercise 1: Complete Products API

## 🎯 What You Have Built
This script has created a **complete, working Products API** with all the features from the exercise:

### ✅ Features Implemented:
- **Full CRUD Operations**: GET, POST, PUT, DELETE for products
- **Advanced Filtering**: Filter by category, name, price range
- **Input Validation**: Data annotations and SKU uniqueness validation
- **Error Handling**: Proper HTTP status codes and error messages
- **Entity Framework**: In-memory database with seed data
- **DTOs**: Clean separation between API contracts and domain models
- **Swagger Documentation**: Interactive API documentation with XML comments

### 🚀 Testing Your API:
1. **Run the application**:
   ```bash
   dotnet run
   ```

2. **Open Swagger UI**:
   - Navigate to: `http://localhost:5000/swagger`
   - Explore all available endpoints

3. **Test the endpoints**:
   - **GET /api/products** - Get all products (3 seeded products)
   - **GET /api/products?category=Electronics** - Filter by category
   - **GET /api/products?name=Laptop** - Filter by name
   - **GET /api/products?minPrice=30&maxPrice=100** - Filter by price range
   - **GET /api/products/1** - Get specific product
   - **POST /api/products** - Create new product
   - **PUT /api/products/1** - Update existing product
   - **DELETE /api/products/1** - Delete product
   - **GET /api/products/by-category/Electronics** - Get products by category

### 📊 Sample Data Included:
1. **Laptop Computer** (Electronics, $999.99)
2. **Wireless Mouse** (Accessories, $29.99)
3. **Programming Book** (Books, $49.99)

### 🧪 Example API Calls:

**Create a new product:**
```bash
curl -X POST "http://localhost:5000/api/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Wireless Headphones",
    "description": "High-quality wireless headphones with noise cancellation",
    "price": 199.99,
    "category": "Electronics",
    "stockQuantity": 75,
    "sku": "ELEC-HEAD-004",
    "isActive": true
  }'
```

**Filter products:**
```bash
# Get Electronics products
curl "http://localhost:5000/api/products?category=Electronics"

# Get products under $50
curl "http://localhost:5000/api/products?maxPrice=50"
```

### 🎓 Key Learning Points:
- **RESTful Design**: Proper HTTP methods and status codes
- **Entity Framework**: Code-first approach with in-memory database
- **Data Transfer Objects**: Clean API contracts separate from domain models
- **Input Validation**: Data annotations and business rule validation
- **Error Handling**: Meaningful error responses
- **Async Programming**: Proper async/await patterns
- **Dependency Injection**: Constructor injection for services

### 🔍 Code Structure:
- **Models/Product.cs**: Domain entity with full validation
- **DTOs/ProductDtos.cs**: API contracts (ProductDto, CreateProductDto, UpdateProductDto)
- **Data/ApplicationDbContext.cs**: EF Core context with configuration and seed data
- **Controllers/ProductsController.cs**: Complete REST API with all CRUD operations
- **Program.cs**: Application configuration with EF Core and Swagger

### ✨ Ready for Exercise 2!
Your Products API is now complete and ready for Exercise 2, where you will add authentication and security features.' \
"Complete working Products API - ready to use!"
    
    # Install packages
    echo -e "${CYAN}Installing required packages...${NC}"
    dotnet add package Microsoft.EntityFrameworkCore.InMemory --version 8.0.11 > /dev/null 2>&1
    echo -e "${GREEN}✅ Package installation complete${NC}"
    
elif [[ $EXERCISE_NAME == "exercise02" ]]; then
    # Exercise 2: Add Authentication

    # Add authentication packages
    echo -e "${CYAN}Adding authentication packages...${NC}"
    dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.11 > /dev/null 2>&1
    dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore --version 8.0.11 > /dev/null 2>&1
    dotnet add package System.IdentityModel.Tokens.Jwt --version 8.0.2 > /dev/null 2>&1
    echo -e "${GREEN}✅ Authentication packages installed${NC}"

    explain_concept "JWT Authentication" \
"JWT (JSON Web Tokens) provide stateless authentication:
• Client sends credentials to login endpoint
• Server validates and returns a JWT token
• Client includes token in Authorization header
• Server validates token on each request
• Tokens contain claims (user info, roles, etc.)"

    echo -e "${CYAN}Adding authentication to your existing API...${NC}"
    
    create_file_interactive "Models/Auth/User.cs" \
'using Microsoft.AspNetCore.Identity;

namespace RestfulAPI.Models.Auth
{
    public class User : IdentityUser
    {
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? LastLoginAt { get; set; }
        public bool IsActive { get; set; } = true;
    }
}' \
"Identity user model for authentication"

    create_file_interactive "Models/Auth/AuthModels.cs" \
'using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.Models.Auth
{
    public class RegisterModel
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [StringLength(100, MinimumLength = 6)]
        public string Password { get; set; } = string.Empty;

        [Required]
        [Compare("Password")]
        public string ConfirmPassword { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string LastName { get; set; } = string.Empty;
    }

    public class LoginModel
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string Password { get; set; } = string.Empty;

        public bool RememberMe { get; set; }
    }

    public class TokenResponse
    {
        public string Token { get; set; } = string.Empty;
        public DateTime Expiration { get; set; }
        public string RefreshToken { get; set; } = string.Empty;
        public UserInfo User { get; set; } = new();
    }

    public class UserInfo
    {
        public string Id { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public List<string> Roles { get; set; } = new();
    }

    public class RefreshTokenModel
    {
        [Required]
        public string Token { get; set; } = string.Empty;

        [Required]
        public string RefreshToken { get; set; } = string.Empty;
    }
}' \
"Complete authentication models with validation"
    
    create_file_interactive "Services/JwtService.cs" \
'using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using RestfulAPI.Models.Auth;
using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;

namespace RestfulAPI.Services
{
    public interface IJwtService
    {
        Task<TokenResponse> GenerateTokenAsync(User user);
        ClaimsPrincipal? ValidateToken(string token);
        string GenerateRefreshToken();
    }

    public class JwtService : IJwtService
    {
        private readonly IConfiguration _configuration;
        private readonly UserManager<User> _userManager;

        public JwtService(IConfiguration configuration, UserManager<User> userManager)
        {
            _configuration = configuration;
            _userManager = userManager;
        }

        public async Task<TokenResponse> GenerateTokenAsync(User user)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"]!);
            var roles = await _userManager.GetRolesAsync(user);

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id),
                new Claim(ClaimTypes.Email, user.Email!),
                new Claim(ClaimTypes.Name, $"{user.FirstName} {user.LastName}"),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            };

            // Add role claims
            foreach (var role in roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddHours(1),
                Issuer = _configuration["Jwt:Issuer"],
                Audience = _configuration["Jwt:Audience"],
                SigningCredentials = new SigningCredentials(
                    new SymmetricSecurityKey(key),
                    SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            var tokenString = tokenHandler.WriteToken(token);

            return new TokenResponse
            {
                Token = tokenString,
                Expiration = tokenDescriptor.Expires.Value,
                RefreshToken = GenerateRefreshToken(),
                User = new UserInfo
                {
                    Id = user.Id,
                    Email = user.Email!,
                    FullName = $"{user.FirstName} {user.LastName}",
                    Roles = roles.ToList()
                }
            };
        }

        public ClaimsPrincipal? ValidateToken(string token)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"]!);

            try
            {
                var validationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = true,
                    ValidIssuer = _configuration["Jwt:Issuer"],
                    ValidateAudience = true,
                    ValidAudience = _configuration["Jwt:Audience"],
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero
                };

                var principal = tokenHandler.ValidateToken(token, validationParameters, out _);
                return principal;
            }
            catch
            {
                return null;
            }
        }

        public string GenerateRefreshToken()
        {
            var randomNumber = new byte[32];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }
    }
}' \
"Complete JWT service with refresh token support"
    
    create_file_interactive "Controllers/AuthController.cs" \
'using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Data;
using RestfulAPI.Models.Auth;
using RestfulAPI.Services;
using System.Security.Claims;

namespace RestfulAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class AuthController : ControllerBase
    {
        private readonly UserManager<User> _userManager;
        private readonly SignInManager<User> _signInManager;
        private readonly IJwtService _jwtService;
        private readonly ApplicationDbContext _context;
        private readonly ILogger<AuthController> _logger;

        public AuthController(
            UserManager<User> userManager,
            SignInManager<User> signInManager,
            IJwtService jwtService,
            ApplicationDbContext context,
            ILogger<AuthController> logger)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _jwtService = jwtService;
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// Register a new user
        /// </summary>
        [HttpPost("register")]
        [ProducesResponseType(typeof(TokenResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<TokenResponse>> Register([FromBody] RegisterModel model)
        {
            _logger.LogInformation("New user registration attempt for {Email}", model.Email);

            var user = new User
            {
                UserName = model.Email,
                Email = model.Email,
                FirstName = model.FirstName,
                LastName = model.LastName,
                CreatedAt = DateTime.UtcNow
            };

            var result = await _userManager.CreateAsync(user, model.Password);

            if (!result.Succeeded)
            {
                _logger.LogWarning("Registration failed for {Email}: {Errors}",
                    model.Email, string.Join(", ", result.Errors.Select(e => e.Description)));

                return BadRequest(new ValidationProblemDetails
                {
                    Errors = result.Errors.ToDictionary(
                        e => e.Code,
                        e => new[] { e.Description })
                });
            }

            // Assign default role
            await _userManager.AddToRoleAsync(user, "User");

            // Generate token
            var tokenResponse = await _jwtService.GenerateTokenAsync(user);

            _logger.LogInformation("User {Email} registered successfully", model.Email);

            return Ok(tokenResponse);
        }

        /// <summary>
        /// Login with email and password
        /// </summary>
        [HttpPost("login")]
        [ProducesResponseType(typeof(TokenResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<TokenResponse>> Login([FromBody] LoginModel model)
        {
            _logger.LogInformation("Login attempt for {Email}", model.Email);

            var user = await _userManager.FindByEmailAsync(model.Email);
            if (user == null)
            {
                _logger.LogWarning("Login failed for {Email}: User not found", model.Email);
                return Unauthorized(new { message = "Invalid email or password" });
            }

            var result = await _signInManager.CheckPasswordSignInAsync(user, model.Password, false);
            if (!result.Succeeded)
            {
                _logger.LogWarning("Login failed for {Email}: Invalid password", model.Email);
                return Unauthorized(new { message = "Invalid email or password" });
            }

            // Update last login
            user.LastLoginAt = DateTime.UtcNow;
            await _userManager.UpdateAsync(user);

            // Generate token
            var tokenResponse = await _jwtService.GenerateTokenAsync(user);

            _logger.LogInformation("User {Email} logged in successfully", model.Email);

            return Ok(tokenResponse);
        }

        /// <summary>
        /// Get current user profile
        /// </summary>
        [HttpGet("profile")]
        [Authorize]
        [ProducesResponseType(typeof(UserInfo), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<UserInfo>> GetProfile()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized();
            }

            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
            {
                return Unauthorized();
            }

            var roles = await _userManager.GetRolesAsync(user);

            var userInfo = new UserInfo
            {
                Id = user.Id,
                Email = user.Email!,
                FullName = $"{user.FirstName} {user.LastName}",
                Roles = roles.ToList()
            };

            return Ok(userInfo);
        }
    }
}' \
"Complete authentication controller with registration, login, and profile"
    
    explain_concept "Protecting Endpoints" \
"Use attributes to control access:
• [Authorize] - Requires authentication
• [Authorize(Roles = \"Admin\")] - Requires specific role
• [AllowAnonymous] - Allows public access
• Apply to controllers or individual actions"
    
    create_file_interactive "AUTHENTICATION_GUIDE.md" \
'# Adding Authentication to Your API

## Update Program.cs
Add these lines after existing service configuration:

```csharp
// Add JWT Service
builder.Services.AddScoped<JwtService>();

// Add Authentication
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

// In the pipeline, add BEFORE app.UseAuthorization():
app.UseAuthentication();
```

## Update appsettings.json
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
```

## Update ProductsController
Add authentication to protect certain endpoints:

```csharp
using Microsoft.AspNetCore.Authorization;

// Add to the top of your ProductsController class
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class ProductsController : ControllerBase
{
    // Keep GET endpoints public for browsing:
    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetProducts(...)
    {
        // Existing implementation
    }

    // Protect create/update/delete operations:
    [HttpPost]
    [Authorize] // Require authentication for creating products
    public async Task<ActionResult<ProductDto>> CreateProduct(...)
    {
        // Existing implementation
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin")] // Only admins can update
    public async Task<IActionResult> UpdateProduct(...)
    {
        // Existing implementation
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = "Admin")] // Only admins can delete
    public async Task<IActionResult> DeleteProduct(...)
    {
        // Existing implementation
    }
}
```

## Testing Authentication:
1. Call POST /api/auth/login with username and password
2. Copy the token from the response
3. In Swagger, click "Authorize" button
4. Enter: Bearer YOUR_TOKEN_HERE
5. Now you can access protected endpoints!' \
"Step-by-step guide for adding authentication"
    
    # Update ApplicationDbContext to support Identity
    create_file_interactive "Data/ApplicationDbContext.cs" \
'using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Models;
using RestfulAPI.Models.Auth;

namespace RestfulAPI.Data
{
    public class ApplicationDbContext : IdentityDbContext<User>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public DbSet<Product> Products { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure Product entity
            modelBuilder.Entity<Product>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
                entity.Property(e => e.Description).HasMaxLength(2000);
                entity.Property(e => e.Category).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Sku).IsRequired().HasMaxLength(50);
                entity.HasIndex(e => e.Sku).IsUnique();
                entity.Property(e => e.Price).HasPrecision(18, 2);
            });

            // Configure Identity User entity
            modelBuilder.Entity<User>(entity =>
            {
                entity.Property(e => e.FirstName).HasMaxLength(100);
                entity.Property(e => e.LastName).HasMaxLength(100);
            });

            // Seed roles
            var adminRoleId = Guid.NewGuid().ToString();
            var userRoleId = Guid.NewGuid().ToString();

            modelBuilder.Entity<IdentityRole>().HasData(
                new IdentityRole
                {
                    Id = adminRoleId,
                    Name = "Admin",
                    NormalizedName = "ADMIN"
                },
                new IdentityRole
                {
                    Id = userRoleId,
                    Name = "User",
                    NormalizedName = "USER"
                }
            );

            // Seed Product data
            modelBuilder.Entity<Product>().HasData(
                new Product { Id = 1, Name = "Laptop", Description = "High-performance laptop", Price = 999.99m, Category = "Electronics", Sku = "LAP001", StockQuantity = 10 },
                new Product { Id = 2, Name = "Mouse", Description = "Wireless mouse", Price = 29.99m, Category = "Accessories", Sku = "MOU001", StockQuantity = 50 },
                new Product { Id = 3, Name = "Keyboard", Description = "Mechanical keyboard", Price = 79.99m, Category = "Accessories", Sku = "KEY001", StockQuantity = 25 }
            );
        }
    }
}' \
"Updated Entity Framework DbContext with Identity support"

    # Update Program.cs with Identity and JWT configuration
    create_file_interactive "Program.cs" \
'using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using RestfulAPI.Data;
using RestfulAPI.Models.Auth;
using RestfulAPI.Services;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();

// Add Entity Framework with In-Memory Database
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseInMemoryDatabase("RestfulAPIDb"));

// Add Identity
builder.Services.AddIdentity<User, IdentityRole>(options =>
{
    // Password settings
    options.Password.RequireDigit = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequireUppercase = true;
    options.Password.RequiredLength = 6;
    options.Password.RequiredUniqueChars = 1;

    // Lockout settings
    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(5);
    options.Lockout.MaxFailedAccessAttempts = 5;
    options.Lockout.AllowedForNewUsers = true;

    // User settings
    options.User.AllowedUserNameCharacters =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._@+";
    options.User.RequireUniqueEmail = true;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// Add JWT Service
builder.Services.AddScoped<IJwtService, JwtService>();

// Add JWT Authentication
var jwtKey = builder.Configuration["Jwt:Key"] ?? "your-super-secret-key-that-is-at-least-32-characters-long";
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "RestfulAPI";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "RestfulAPIUsers";

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
        };
    });

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "Products API", Version = "v1" });

    // Include XML comments for better documentation
    var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
    {
        c.IncludeXmlComments(xmlPath);
    }

    // Add JWT Authentication to Swagger
    c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Enter Bearer [space] and then your token in the text input below.",
        Name = "Authorization",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "Bearer"
                },
                Scheme = "oauth2",
                Name = "Bearer",
                In = Microsoft.OpenApi.Models.ParameterLocation.Header,
            },
            new List<string>()
        }
    });
});

// Add CORS for development
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Products API v1");
        c.RoutePrefix = "swagger"; // Serve Swagger UI at /swagger
    });
}

// Seed the database and roles
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();

    context.Database.EnsureCreated();

    // Ensure roles exist
    if (!await roleManager.RoleExistsAsync("Admin"))
    {
        await roleManager.CreateAsync(new IdentityRole("Admin"));
    }

    if (!await roleManager.RoleExistsAsync("User"))
    {
        await roleManager.CreateAsync(new IdentityRole("User"));
    }
}

app.UseCors("AllowAll");

// Only use HTTPS redirection in production
if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();' \
"Program.cs configured with Identity and JWT authentication"

    # Install packages
    echo -e "${CYAN}Installing authentication packages...${NC}"
    dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.11 > /dev/null 2>&1
    dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore --version 8.0.11 > /dev/null 2>&1
    dotnet add package System.IdentityModel.Tokens.Jwt --version 8.0.2 > /dev/null 2>&1
    echo -e "${GREEN}✅ Authentication packages installed${NC}"
    
elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    # Exercise 3: Versioning & Documentation

    # Add versioning packages
    echo -e "${CYAN}Adding API versioning packages...${NC}"
    dotnet add package Asp.Versioning.Mvc --version 8.0.0 > /dev/null 2>&1
    dotnet add package Asp.Versioning.Mvc.ApiExplorer --version 8.0.0 > /dev/null 2>&1
    dotnet add package Swashbuckle.AspNetCore.Annotations --version 6.8.1 > /dev/null 2>&1
    echo -e "${GREEN}✅ Versioning packages installed${NC}"

    explain_concept "API Versioning" \
"API versioning allows multiple versions to coexist:
• Maintains backward compatibility
• Allows gradual migration
• Common strategies: URL path, query string, headers
• Each version can have different features"

    echo -e "${CYAN}Adding versioning and documentation to your API...${NC}"
    
    create_file_interactive "Controllers/V1/ProductsV1Controller.cs" \
'using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;
using RestfulAPI.Models;
using RestfulAPI.DTOs;
using RestfulAPI.Data;
using Microsoft.EntityFrameworkCore;

namespace RestfulAPI.Controllers.V1
{
    [ApiVersion("1.0")]
    [ApiController]
    [Route("api/v{version:apiVersion}/products")]
    [Produces("application/json")]
    public class ProductsV1Controller : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<ProductsV1Controller> _logger;

        public ProductsV1Controller(ApplicationDbContext context, ILogger<ProductsV1Controller> logger)
        {
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// Get all products (V1 - basic filtering)
        /// </summary>
        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<ProductDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<ProductDto>>> GetProducts(
            [FromQuery] string? category = null,
            [FromQuery] string? name = null)
        {
            _logger.LogInformation("V1 API: Getting products with basic filters");

            var query = _context.Products.AsQueryable();

            if (!string.IsNullOrWhiteSpace(category))
            {
                query = query.Where(p => p.Category.Contains(category));
            }

            if (!string.IsNullOrWhiteSpace(name))
            {
                query = query.Where(p => p.Name.Contains(name));
            }

            var products = await query
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Category = p.Category,
                    StockQuantity = p.StockQuantity,
                    Sku = p.Sku,
                    IsActive = p.IsActive,
                    IsAvailable = p.IsAvailable,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .ToListAsync();

            return Ok(products);
        }
    }
}' \
"Version 1 of the Products API (basic functionality)"

    create_file_interactive "Controllers/V2/ProductsV2Controller.cs" \
'using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;
using RestfulAPI.Models;
using RestfulAPI.DTOs;
using RestfulAPI.Data;
using Microsoft.EntityFrameworkCore;

namespace RestfulAPI.Controllers.V2
{
    [ApiVersion("2.0")]
    [ApiController]
    [Route("api/v{version:apiVersion}/products")]
    [Produces("application/json")]
    public class ProductsV2Controller : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<ProductsV2Controller> _logger;

        public ProductsV2Controller(ApplicationDbContext context, ILogger<ProductsV2Controller> logger)
        {
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// Get all products with pagination (V2 enhancement)
        /// </summary>
        [HttpGet]
        [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetProducts(
            [FromQuery] string? category = null,
            [FromQuery] string? name = null,
            [FromQuery] decimal? minPrice = null,
            [FromQuery] decimal? maxPrice = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            _logger.LogInformation("V2 API: Getting products with pagination and advanced filters");

            var query = _context.Products.AsQueryable();

            // Apply filters
            if (!string.IsNullOrWhiteSpace(category))
            {
                query = query.Where(p => p.Category.Contains(category));
            }

            if (!string.IsNullOrWhiteSpace(name))
            {
                query = query.Where(p => p.Name.Contains(name));
            }

            if (minPrice.HasValue)
            {
                query = query.Where(p => p.Price >= minPrice.Value);
            }

            if (maxPrice.HasValue)
            {
                query = query.Where(p => p.Price <= maxPrice.Value);
            }

            // Get total count for pagination
            var totalItems = await query.CountAsync();

            // Apply pagination
            var products = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Category = p.Category,
                    StockQuantity = p.StockQuantity,
                    Sku = p.Sku,
                    IsActive = p.IsActive,
                    IsAvailable = p.IsAvailable,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .ToListAsync();

            // V2 returns paginated response with metadata
            return Ok(new
            {
                page = page,
                pageSize = pageSize,
                totalItems = totalItems,
                totalPages = (int)Math.Ceiling(totalItems / (double)pageSize),
                hasNextPage = page < (int)Math.Ceiling(totalItems / (double)pageSize),
                hasPreviousPage = page > 1,
                items = products
            });
        }

        /// <summary>
        /// Get product statistics (V2 exclusive feature)
        /// </summary>
        [HttpGet("statistics")]
        [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetProductStatistics()
        {
            var stats = await _context.Products
                .GroupBy(p => p.Category)
                .Select(g => new
                {
                    Category = g.Key,
                    Count = g.Count(),
                    AveragePrice = g.Average(p => p.Price),
                    TotalStock = g.Sum(p => p.StockQuantity)
                })
                .ToListAsync();

            var totalProducts = await _context.Products.CountAsync();
            var totalValue = await _context.Products.SumAsync(p => p.Price * p.StockQuantity);

            return Ok(new
            {
                TotalProducts = totalProducts,
                TotalInventoryValue = totalValue,
                CategoryBreakdown = stats
            });
        }
    }
}' \
"Version 2 of the Products API with pagination and enhanced features"
    
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
            
            // Add JWT Authentication
            options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
            {
                Description = "JWT Authorization header using the Bearer scheme. Example: \"Bearer {token}\"",
                Name = "Authorization",
                In = ParameterLocation.Header,
                Type = SecuritySchemeType.ApiKey,
                Scheme = "Bearer"
            });

            options.AddSecurityRequirement(new OpenApiSecurityRequirement
            {
                {
                    new OpenApiSecurityScheme
                    {
                        Reference = new OpenApiReference
                        {
                            Type = ReferenceType.SecurityScheme,
                            Id = "Bearer"
                        }
                    },
                    Array.Empty<string>()
                }
            });
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
    
    create_file_interactive "HealthChecks/ApiHealthCheck.cs" \
'using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Data;

namespace RestfulAPI.HealthChecks
{
    public class ApiHealthCheck : IHealthCheck
    {
        private readonly ApplicationDbContext _context;

        public ApiHealthCheck(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<HealthCheckResult> CheckHealthAsync(
            HealthCheckContext context,
            CancellationToken cancellationToken = default)
        {
            try
            {
                // Check database connectivity
                await _context.Database.CanConnectAsync(cancellationToken);
                
                // You can add more checks here
                
                return HealthCheckResult.Healthy("API is healthy");
            }
            catch (Exception ex)
            {
                return HealthCheckResult.Unhealthy(
                    "API is unhealthy", 
                    exception: ex);
            }
        }
    }
}' \
"Custom health check for monitoring API status"
    
    # Update Program.cs to support multiple API versions
    create_file_interactive "Program.cs" \
'using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.Options;
using Microsoft.OpenApi.Models;
using RestfulAPI.Data;
using RestfulAPI.Models.Auth;
using RestfulAPI.Services;
using RestfulAPI.Configuration;
using RestfulAPI.HealthChecks;
using Swashbuckle.AspNetCore.SwaggerGen;
using System.Text;
using Asp.Versioning;
using Asp.Versioning.ApiExplorer;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();

// Add API Versioning
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
    options.GroupNameFormat = "'"'"'v'"'"'VVV";
    options.SubstituteApiVersionInUrl = true;
});

// Add Entity Framework with In-Memory Database
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseInMemoryDatabase("RestfulAPIDb"));

// Add Identity
builder.Services.AddIdentity<User, IdentityRole>(options =>
{
    // Password settings
    options.Password.RequireDigit = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequireUppercase = true;
    options.Password.RequiredLength = 6;
    options.Password.RequiredUniqueChars = 1;

    // Lockout settings
    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(5);
    options.Lockout.MaxFailedAccessAttempts = 5;
    options.Lockout.AllowedForNewUsers = true;

    // User settings
    options.User.AllowedUserNameCharacters =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._@+";
    options.User.RequireUniqueEmail = true;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// Add JWT Service
builder.Services.AddScoped<IJwtService, JwtService>();

// Add JWT Authentication
var jwtKey = builder.Configuration["Jwt:Key"] ?? "your-super-secret-key-that-is-at-least-32-characters-long";
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "RestfulAPI";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "RestfulAPIUsers";

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
        };
    });

// Configure Swagger for multiple API versions
builder.Services.AddTransient<IConfigureOptions<SwaggerGenOptions>, ConfigureSwaggerOptions>();
builder.Services.AddSwaggerGen();

// Add Health Checks
builder.Services.AddHealthChecks()
    .AddCheck<ApiHealthCheck>("api_health_check");

// Add CORS for development
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();

    // Configure Swagger UI for multiple versions
    var apiVersionDescriptionProvider = app.Services.GetRequiredService<IApiVersionDescriptionProvider>();
    app.UseSwaggerUI(options =>
    {
        foreach (var description in apiVersionDescriptionProvider.ApiVersionDescriptions)
        {
            options.SwaggerEndpoint($"/swagger/{description.GroupName}/swagger.json",
                $"Products API {description.GroupName.ToUpperInvariant()}");
        }
        options.RoutePrefix = "swagger";
    });
}

// Seed the database and roles
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();

    context.Database.EnsureCreated();

    // Ensure roles exist
    if (!await roleManager.RoleExistsAsync("Admin"))
    {
        await roleManager.CreateAsync(new IdentityRole("Admin"));
    }

    if (!await roleManager.RoleExistsAsync("User"))
    {
        await roleManager.CreateAsync(new IdentityRole("User"));
    }
}

app.UseCors("AllowAll");

// Only use HTTPS redirection in production
if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

// Add health check endpoint
app.MapHealthChecks("/health");

app.Run();' \
"Program.cs configured for multiple API versions with v1 and v2 support"
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
echo -e "${CYAN}Happy coding! 🚀${NC}"