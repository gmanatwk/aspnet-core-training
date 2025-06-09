#!/bin/bash

# Module 5 Interactive Exercise Launcher
# Entity Framework Core

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
            echo "  📚 1. Setting up Entity Framework Core with SQLite"
            echo "  📚 2. Creating entity models with data annotations"
            echo "  📚 3. Configuring DbContext with Fluent API"
            echo "  📚 4. Implementing basic CRUD operations"
            echo ""
            echo -e "${YELLOW}Key concepts:${NC}"
            echo "  • Code-First approach with EF Core"
            echo "  • Entity relationships and navigation properties"
            echo "  • Database migrations and seeding"
            echo "  • Async/await patterns with EF Core"
            ;;
        "exercise02")
            echo -e "${CYAN}Building on Exercise 1, you will add:${NC}"
            echo "  🔍 1. Complex LINQ queries with navigation properties"
            echo "  🔍 2. Advanced filtering and sorting capabilities"
            echo "  🔍 3. Efficient loading strategies (Include, ThenInclude)"
            echo "  🔍 4. Query performance optimization"
            echo ""
            echo -e "${YELLOW}Advanced concepts:${NC}"
            echo "  • LINQ query optimization"
            echo "  • Eager vs Lazy loading"
            echo "  • Query performance monitoring"
            echo "  • Database indexing strategies"
            ;;
        "exercise03")
            echo -e "${CYAN}Implementing professional patterns:${NC}"
            echo "  🏗️ 1. Repository pattern implementation"
            echo "  🏗️ 2. Unit of Work pattern"
            echo "  🏗️ 3. Generic repository with specific implementations"
            echo "  🏗️ 4. Dependency injection with repositories"
            echo ""
            echo -e "${YELLOW}Design patterns:${NC}"
            echo "  • Separation of concerns"
            echo "  • Testable architecture"
            echo "  • Clean code principles"
            echo "  • SOLID principles application"
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
            echo -e "${GREEN}🎯 Exercise 01: Basic EF Core Setup and CRUD Operations${NC}"
            echo ""
            echo -e "${YELLOW}📋 What you'll build:${NC}"
            echo "  ✅ BookStore API with Entity Framework Core"
            echo "  ✅ SQLite database with Code-First approach"
            echo "  ✅ Book entity with proper validation and relationships"
            echo "  ✅ Complete CRUD operations with async patterns"
            echo ""
            echo -e "${BLUE}🚀 RECOMMENDED: Use the Complete Working Example${NC}"
            echo "  ${CYAN}cd SourceCode/EFCoreDemo && dotnet run${NC}"
            echo "  Then visit: ${CYAN}http://localhost:5000${NC} for the demo interface"
            echo ""
            echo -e "${GREEN}📁 Template Structure:${NC}"
            echo "  EFCoreDemo/"
            echo "  ├── Controllers/"
            echo "  │   └── BooksController.cs      ${YELLOW}# CRUD API endpoints${NC}"
            echo "  ├── Models/"
            echo "  │   └── Book.cs                 ${YELLOW}# Book entity model${NC}"
            echo "  ├── Data/"
            echo "  │   └── BookStoreContext.cs     ${YELLOW}# EF Core DbContext${NC}"
            echo "  ├── Program.cs                  ${YELLOW}# App configuration${NC}"
            echo "  └── appsettings.json            ${YELLOW}# Connection strings${NC}"
            ;;
            
        "exercise02")
            echo -e "${GREEN}🎯 Exercise 02: Advanced Querying with LINQ${NC}"
            echo ""
            echo -e "${YELLOW}📋 Building on Exercise 1:${NC}"
            echo "  ✅ Product and Category entities with relationships"
            echo "  ✅ Complex LINQ queries with navigation properties"
            echo "  ✅ Advanced filtering, sorting, and pagination"
            echo "  ✅ Query performance optimization techniques"
            echo ""
            echo -e "${GREEN}📁 New additions:${NC}"
            echo "  EFCoreDemo/"
            echo "  ├── Models/"
            echo "  │   ├── Product.cs              ${YELLOW}# Product entity${NC}"
            echo "  │   ├── Category.cs             ${YELLOW}# Category entity${NC}"
            echo "  │   └── ProductCategory.cs      ${YELLOW}# Many-to-many relationship${NC}"
            echo "  ├── Controllers/"
            echo "  │   ├── ProductsController.cs   ${YELLOW}# Advanced LINQ queries${NC}"
            echo "  │   └── CategoriesController.cs ${YELLOW}# Category management${NC}"
            echo "  └── Data/"
            echo "      └── ProductCatalogContext.cs ${YELLOW}# Extended DbContext${NC}"
            ;;
            
        "exercise03")
            echo -e "${GREEN}🎯 Exercise 03: Repository Pattern Implementation${NC}"
            echo ""
            echo -e "${YELLOW}📋 Professional architecture patterns:${NC}"
            echo "  ✅ Generic repository interface and implementation"
            echo "  ✅ Specific repositories for entities"
            echo "  ✅ Unit of Work pattern for transaction management"
            echo "  ✅ Dependency injection configuration"
            echo ""
            echo -e "${GREEN}📁 Repository structure:${NC}"
            echo "  EFCoreDemo/"
            echo "  ├── Repositories/"
            echo "  │   ├── IRepository.cs          ${YELLOW}# Generic repository interface${NC}"
            echo "  │   ├── Repository.cs           ${YELLOW}# Generic implementation${NC}"
            echo "  │   ├── IBookRepository.cs      ${YELLOW}# Book-specific interface${NC}"
            echo "  │   ├── BookRepository.cs       ${YELLOW}# Book-specific implementation${NC}"
            echo "  │   └── IUnitOfWork.cs          ${YELLOW}# Unit of Work pattern${NC}"
            echo "  └── Controllers/ (refactored to use repositories)"
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
    echo -e "${CYAN}Module 5 - Entity Framework Core${NC}"
    echo -e "${CYAN}Available Exercises:${NC}"
    echo ""
    echo "  - exercise01: Basic EF Core Setup and CRUD Operations"
    echo "  - exercise02: Advanced Querying with LINQ"
    echo "  - exercise03: Repository Pattern Implementation"
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
PROJECT_NAME="EFCoreDemo"
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
echo -e "${MAGENTA}🚀 Module 5: Entity Framework Core${NC}"
echo -e "${MAGENTA}Exercise: $EXERCISE_NAME${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show the recommended approach
echo -e "${GREEN}🎯 RECOMMENDED APPROACH:${NC}"
echo -e "${CYAN}For the best learning experience, use the complete working implementation:${NC}"
echo ""
echo -e "${YELLOW}1. Use the working source code:${NC}"
echo -e "   ${CYAN}cd SourceCode/EFCoreDemo${NC}"
echo -e "   ${CYAN}dotnet run${NC}"
echo -e "   ${CYAN}# Visit: http://localhost:5000 for the demo interface${NC}"
echo ""
echo -e "${YELLOW}2. Or use Docker for database setup:${NC}"
echo -e "   ${CYAN}cd SourceCode${NC}"
echo -e "   ${CYAN}docker-compose up --build${NC}"
echo -e "   ${CYAN}# Includes SQLite database and demo application${NC}"
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
    # Exercise 1: Basic EF Core Setup

    explain_concept "Entity Framework Core" \
"Entity Framework Core is a lightweight, extensible ORM for .NET:
• Code-First approach: Define models in C#, generate database
• DbContext: Represents a session with the database
• DbSet<T>: Represents a table in the database
• Migrations: Version control for your database schema
• LINQ: Query your database using C# syntax"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${CYAN}Creating new Web API project...${NC}"
        dotnet new webapi -n "$PROJECT_NAME" --framework net8.0
        cd "$PROJECT_NAME"
        rm -f WeatherForecast.cs Controllers/WeatherForecastController.cs

        # Install EF Core packages
        echo -e "${CYAN}Installing Entity Framework Core packages...${NC}"
        dotnet add package Microsoft.EntityFrameworkCore.Sqlite
        dotnet add package Microsoft.EntityFrameworkCore.Tools
        dotnet add package Microsoft.EntityFrameworkCore.Design

        # Update Program.cs with EF Core configuration
        create_file_interactive "Program.cs" \
'using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Data;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        // Handle circular references in JSON serialization
        options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
        options.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
    });

// Add Entity Framework with SQLite
builder.Services.AddDbContext<BookStoreContext>(options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register services for Exercise 2 (BookQueryService will be added in Exercise 2)
// builder.Services.AddScoped<EFCoreDemo.Services.BookQueryService>();

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
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "BookStore API v1");
        c.RoutePrefix = "swagger";
    });
}

// Ensure database is created and seeded
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<BookStoreContext>();
    context.Database.EnsureCreated();
}

app.UseCors("AllowAll");
app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

// Add a root redirect to swagger
app.MapGet("/", () => Results.Redirect("/swagger"));

app.Run();' \
"Program.cs with Entity Framework Core and SQLite configuration"
    fi

    explain_concept "Entity Models" \
"Entity models represent your database tables:
• Properties become database columns
• Data annotations provide validation and constraints
• Navigation properties define relationships
• Fluent API in DbContext provides advanced configuration"

    # Create Book entity model
    create_file_interactive "Models/Book.cs" \
'using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace EFCoreDemo.Models;

/// <summary>
/// Book entity for Exercise 01 - Basic EF Core Setup
/// Updated to support relationships for Exercise 02
/// </summary>
public class Book
{
    [Key]
    public int Id { get; set; }

    [Required(ErrorMessage = "Title is required")]
    [StringLength(200, ErrorMessage = "Title cannot exceed 200 characters")]
    public string Title { get; set; } = string.Empty;

    [Required(ErrorMessage = "Author is required")]
    [StringLength(100, ErrorMessage = "Author name cannot exceed 100 characters")]
    public string Author { get; set; } = string.Empty;

    [Required(ErrorMessage = "ISBN is required")]
    [StringLength(20, ErrorMessage = "ISBN cannot exceed 20 characters")]
    public string ISBN { get; set; } = string.Empty;

    [Column(TypeName = "decimal(18,2)")]
    [Range(0.01, 9999.99, ErrorMessage = "Price must be between 0.01 and 9999.99")]
    public decimal Price { get; set; }

    [Required(ErrorMessage = "Published date is required")]
    public DateTime PublishedDate { get; set; }

    public bool IsAvailable { get; set; } = true;

    // Foreign Key for Publisher (optional for Exercise 01, used in Exercise 02)
    public int? PublisherId { get; set; }

    // Navigation properties (optional for Exercise 01, used in Exercise 02)
    [JsonIgnore]
    public virtual Publisher? Publisher { get; set; }

    [JsonIgnore]
    public virtual ICollection<BookAuthor> BookAuthors { get; set; } = new List<BookAuthor>();

    // Computed property for display
    [NotMapped]
    public string DisplayTitle => $"{Title} by {Author}";
}' \
"Book entity model with data annotations, validation, and navigation properties"

    # Create Author entity
    create_file_interactive "Models/Author.cs" \
'using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace EFCoreDemo.Models;

/// <summary>
/// Author entity for many-to-many relationship with Books
/// </summary>
public class Author
{
    [Key]
    public int Id { get; set; }

    [Required]
    [StringLength(50)]
    public string FirstName { get; set; } = string.Empty;

    [Required]
    [StringLength(50)]
    public string LastName { get; set; } = string.Empty;

    [Required]
    [StringLength(100)]
    public string Email { get; set; } = string.Empty;

    public DateTime? BirthDate { get; set; }

    [StringLength(50)]
    public string Country { get; set; } = string.Empty;

    // Navigation properties
    [JsonIgnore]
    public virtual ICollection<BookAuthor> BookAuthors { get; set; } = new List<BookAuthor>();

    // Computed property
    public string FullName => $"{FirstName} {LastName}";
}' \
"Author entity with navigation properties for many-to-many relationship"

    # Create Publisher entity
    create_file_interactive "Models/Publisher.cs" \
'using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace EFCoreDemo.Models;

/// <summary>
/// Publisher entity for one-to-many relationship with Books
/// </summary>
public class Publisher
{
    [Key]
    public int Id { get; set; }

    [Required]
    [StringLength(100)]
    public string Name { get; set; } = string.Empty;

    [StringLength(200)]
    public string Address { get; set; } = string.Empty;

    [StringLength(100)]
    public string Website { get; set; } = string.Empty;

    public int FoundedYear { get; set; }

    // Navigation properties
    [JsonIgnore]
    public virtual ICollection<Book> Books { get; set; } = new List<Book>();
}' \
"Publisher entity with one-to-many relationship to books"

    # Create BookAuthor junction entity
    create_file_interactive "Models/BookAuthor.cs" \
'using System.Text.Json.Serialization;

namespace EFCoreDemo.Models;

/// <summary>
/// BookAuthor junction entity for many-to-many relationship between Books and Authors
/// </summary>
public class BookAuthor
{
    public int BookId { get; set; }
    public int AuthorId { get; set; }
    public string Role { get; set; } = "Primary Author"; // Primary Author, Co-Author, Editor

    // Navigation properties
    [JsonIgnore]
    public virtual Book Book { get; set; } = null!;

    [JsonIgnore]
    public virtual Author Author { get; set; } = null!;
}' \
"Junction entity for many-to-many relationship between Books and Authors"

    # Create DTOs for API responses
    create_file_interactive "Models/DTOs/BookDto.cs" \
'using System.ComponentModel.DataAnnotations;

namespace EFCoreDemo.Models.DTOs;

/// <summary>
/// Book DTO for API responses without circular references
/// </summary>
public class BookDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Author { get; set; } = string.Empty;
    public string ISBN { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public DateTime PublishedDate { get; set; }
    public bool IsAvailable { get; set; }
    public string? PublisherName { get; set; }
    public List<string> Authors { get; set; } = new List<string>();
}

/// <summary>
/// Create Book DTO for API requests
/// </summary>
/// <example>
/// {
///   "title": "Learning ASP.NET Core",
///   "author": "John Developer",
///   "isbn": "978-1234567890",
///   "price": 29.99,
///   "publishedDate": "2024-01-15T00:00:00",
///   "isAvailable": true,
///   "publisherId": 1
/// }
/// </example>
public class CreateBookDto
{
    /// <summary>Book title</summary>
    /// <example>Learning ASP.NET Core</example>
    [Required(ErrorMessage = "Title is required")]
    [StringLength(200, ErrorMessage = "Title cannot exceed 200 characters")]
    public string Title { get; set; } = string.Empty;

    /// <summary>Author name</summary>
    /// <example>John Developer</example>
    [Required(ErrorMessage = "Author is required")]
    [StringLength(100, ErrorMessage = "Author name cannot exceed 100 characters")]
    public string Author { get; set; } = string.Empty;

    /// <summary>ISBN number</summary>
    /// <example>978-1234567890</example>
    [Required(ErrorMessage = "ISBN is required")]
    [StringLength(20, ErrorMessage = "ISBN cannot exceed 20 characters")]
    public string ISBN { get; set; } = string.Empty;

    /// <summary>Book price</summary>
    /// <example>29.99</example>
    [Range(0.01, 9999.99, ErrorMessage = "Price must be between 0.01 and 9999.99")]
    public decimal Price { get; set; }

    /// <summary>Publication date</summary>
    /// <example>2024-01-15T00:00:00</example>
    [Required(ErrorMessage = "Published date is required")]
    public DateTime PublishedDate { get; set; }

    /// <summary>Whether the book is available</summary>
    /// <example>true</example>
    public bool IsAvailable { get; set; } = true;

    /// <summary>Publisher ID (optional)</summary>
    /// <example>1</example>
    public int? PublisherId { get; set; }
}

/// <summary>
/// Update Book DTO for API requests
/// </summary>
/// <example>
/// {
///   "title": "Advanced ASP.NET Core",
///   "author": "Jane Developer",
///   "isbn": "978-0987654321",
///   "price": 39.99,
///   "publishedDate": "2024-02-20T00:00:00",
///   "isAvailable": true,
///   "publisherId": 2
/// }
/// </example>
public class UpdateBookDto
{
    /// <summary>Book title</summary>
    /// <example>Advanced ASP.NET Core</example>
    [Required(ErrorMessage = "Title is required")]
    [StringLength(200, ErrorMessage = "Title cannot exceed 200 characters")]
    public string Title { get; set; } = string.Empty;

    /// <summary>Author name</summary>
    /// <example>Jane Developer</example>
    [Required(ErrorMessage = "Author is required")]
    [StringLength(100, ErrorMessage = "Author name cannot exceed 100 characters")]
    public string Author { get; set; } = string.Empty;

    /// <summary>ISBN number</summary>
    /// <example>978-0987654321</example>
    [Required(ErrorMessage = "ISBN is required")]
    [StringLength(20, ErrorMessage = "ISBN cannot exceed 20 characters")]
    public string ISBN { get; set; } = string.Empty;

    /// <summary>Book price</summary>
    /// <example>39.99</example>
    [Range(0.01, 9999.99, ErrorMessage = "Price must be between 0.01 and 9999.99")]
    public decimal Price { get; set; }

    /// <summary>Publication date</summary>
    /// <example>2024-02-20T00:00:00</example>
    [Required(ErrorMessage = "Published date is required")]
    public DateTime PublishedDate { get; set; }

    /// <summary>Whether the book is available</summary>
    /// <example>true</example>
    public bool IsAvailable { get; set; }

    /// <summary>Publisher ID (optional)</summary>
    /// <example>2</example>
    public int? PublisherId { get; set; }
}' \
"DTOs for API requests and responses to avoid circular references"

    explain_concept "DbContext Configuration" \
"DbContext is the bridge between your entities and database:
• Represents a session with the database
• DbSet<T> properties represent tables
• OnModelCreating() configures entities using Fluent API
• Handles change tracking and saves changes"

    # Create BookStoreContext
    create_file_interactive "Data/BookStoreContext.cs" \
'using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Models;

namespace EFCoreDemo.Data;

public class BookStoreContext : DbContext
{
    public BookStoreContext(DbContextOptions<BookStoreContext> options) : base(options)
    {
    }

    public DbSet<Book> Books { get; set; } = null!;
    public DbSet<Author> Authors { get; set; } = null!;
    public DbSet<Publisher> Publishers { get; set; } = null!;
    public DbSet<BookAuthor> BookAuthors { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure Book entity using Fluent API
        modelBuilder.Entity<Book>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.Property(e => e.Title)
                .IsRequired()
                .HasMaxLength(200);

            entity.Property(e => e.Author)
                .IsRequired()
                .HasMaxLength(100);

            entity.Property(e => e.ISBN)
                .IsRequired()
                .HasMaxLength(20);

            entity.HasIndex(e => e.ISBN)
                .IsUnique()
                .HasDatabaseName("IX_Books_ISBN");

            entity.Property(e => e.Price)
                .HasColumnType("decimal(18,2)")
                .IsRequired();

            entity.Property(e => e.PublishedDate)
                .IsRequired();

            entity.Property(e => e.IsAvailable)
                .HasDefaultValue(true);

            // Configure Publisher relationship (optional for Exercise 01)
            entity.HasOne(e => e.Publisher)
                .WithMany(p => p.Books)
                .HasForeignKey(e => e.PublisherId)
                .OnDelete(DeleteBehavior.SetNull)
                .IsRequired(false);
        });

        // Configure Author entity
        modelBuilder.Entity<Author>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.FirstName).IsRequired().HasMaxLength(50);
            entity.Property(e => e.LastName).IsRequired().HasMaxLength(50);
            entity.Property(e => e.Email).IsRequired().HasMaxLength(100);
            entity.HasIndex(e => e.Email).IsUnique();
        });

        // Configure Publisher entity
        modelBuilder.Entity<Publisher>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            entity.HasIndex(e => e.Name).IsUnique();
        });

        // Configure BookAuthor many-to-many relationship
        modelBuilder.Entity<BookAuthor>(entity =>
        {
            entity.HasKey(ba => new { ba.BookId, ba.AuthorId });

            entity.HasOne(ba => ba.Book)
                  .WithMany(b => b.BookAuthors)
                  .HasForeignKey(ba => ba.BookId);

            entity.HasOne(ba => ba.Author)
                  .WithMany(a => a.BookAuthors)
                  .HasForeignKey(ba => ba.AuthorId);
        });

        // Seed data for Exercise 01
        SeedData(modelBuilder);
    }

    private void SeedData(ModelBuilder modelBuilder)
    {
        // Seed Publishers first
        modelBuilder.Entity<Publisher>().HasData(
            new Publisher
            {
                Id = 1,
                Name = "Tech Publications",
                Address = "123 Tech Street, Silicon Valley, CA",
                Website = "https://techpublications.com",
                FoundedYear = 1995
            },
            new Publisher
            {
                Id = 2,
                Name = "Code Masters Press",
                Address = "456 Developer Ave, Seattle, WA",
                Website = "https://codemasters.com",
                FoundedYear = 2001
            },
            new Publisher
            {
                Id = 3,
                Name = "Programming Pros",
                Address = "789 Software Blvd, Austin, TX",
                Website = "https://programmingpros.com",
                FoundedYear = 2010
            }
        );

        // Seed Books with optional publisher references
        modelBuilder.Entity<Book>().HasData(
            new Book
            {
                Id = 1,
                Title = "C# Programming Guide",
                Author = "John Smith",
                ISBN = "978-1234567890",
                Price = 29.99m,
                PublishedDate = new DateTime(2023, 1, 15),
                IsAvailable = true,
                PublisherId = 1 // Tech Publications
            },
            new Book
            {
                Id = 2,
                Title = "ASP.NET Core in Action",
                Author = "Jane Doe",
                ISBN = "978-0987654321",
                Price = 39.99m,
                PublishedDate = new DateTime(2023, 3, 20),
                IsAvailable = true,
                PublisherId = 2 // Code Masters Press
            },
            new Book
            {
                Id = 3,
                Title = "Entity Framework Core Deep Dive",
                Author = "Bob Johnson",
                ISBN = "978-1122334455",
                Price = 45.99m,
                PublishedDate = new DateTime(2023, 6, 10),
                IsAvailable = false,
                PublisherId = 3 // Programming Pros
            }
        );
    }
}' \
"BookStoreContext with Fluent API configuration and seed data"

    # Update appsettings.json with connection string
    create_file_interactive "appsettings.json" \
'{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=BookStore.db"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore.Database.Command": "Information"
    }
  },
  "AllowedHosts": "*"
}' \
"Configuration file with SQLite connection string and EF Core logging"

    explain_concept "CRUD Operations with EF Core" \
"CRUD operations using Entity Framework Core:
• Create: Add entities to DbSet, call SaveChangesAsync()
• Read: Use LINQ queries on DbSet properties
• Update: Modify tracked entities, call SaveChangesAsync()
• Delete: Remove entities from DbSet, call SaveChangesAsync()
• Always use async methods for database operations"

    # Create BooksController with CRUD operations
    create_file_interactive "Controllers/BooksController.cs" \
'using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Data;
using EFCoreDemo.Models;
using EFCoreDemo.Models.DTOs;

namespace EFCoreDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BooksController : ControllerBase
{
    private readonly BookStoreContext _context;
    private readonly ILogger<BooksController> _logger;

    public BooksController(BookStoreContext context, ILogger<BooksController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Get all books
    /// </summary>
    /// <returns>List of all books</returns>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<BookDto>>> GetBooks()
    {
        try
        {
            _logger.LogInformation("Retrieving all books");

            var books = await _context.Books
                .AsNoTracking()
                .Select(b => new BookDto
                {
                    Id = b.Id,
                    Title = b.Title,
                    Author = b.Author,
                    ISBN = b.ISBN,
                    Price = b.Price,
                    PublishedDate = b.PublishedDate,
                    IsAvailable = b.IsAvailable,
                    PublisherName = b.Publisher != null ? b.Publisher.Name : null
                })
                .OrderBy(b => b.Title)
                .ToListAsync();

            return Ok(books);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving books");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get book by ID
    /// </summary>
    /// <param name="id">Book ID</param>
    /// <returns>Book details</returns>
    [HttpGet("{id}")]
    public async Task<ActionResult<BookDto>> GetBook(int id)
    {
        try
        {
            _logger.LogInformation("Retrieving book with ID: {BookId}", id);

            var book = await _context.Books
                .AsNoTracking()
                .Where(b => b.Id == id)
                .Select(b => new BookDto
                {
                    Id = b.Id,
                    Title = b.Title,
                    Author = b.Author,
                    ISBN = b.ISBN,
                    Price = b.Price,
                    PublishedDate = b.PublishedDate,
                    IsAvailable = b.IsAvailable,
                    PublisherName = b.Publisher != null ? b.Publisher.Name : null
                })
                .FirstOrDefaultAsync();

            if (book == null)
            {
                return NotFound($"Book with ID {id} not found");
            }

            return Ok(book);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving book {BookId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Create a new book
    /// </summary>
    /// <param name="createBookDto">Book data to create</param>
    /// <returns>Created book</returns>
    /// <remarks>
    /// Sample request:
    ///
    ///     POST /api/books
    ///     {
    ///        "title": "Learning ASP.NET Core",
    ///        "author": "John Developer",
    ///        "isbn": "978-1234567890",
    ///        "price": 29.99,
    ///        "publishedDate": "2024-01-15T00:00:00",
    ///        "isAvailable": true,
    ///        "publisherId": 1
    ///     }
    ///
    /// </remarks>
    /// <response code="201">Returns the newly created book</response>
    /// <response code="400">If the book data is invalid</response>
    /// <response code="409">If a book with the same ISBN already exists</response>
    [HttpPost]
    [ProducesResponseType(typeof(BookDto), 201)]
    [ProducesResponseType(400)]
    [ProducesResponseType(409)]
    public async Task<ActionResult<BookDto>> CreateBook([FromBody] CreateBookDto createBookDto)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            _logger.LogInformation("Creating new book: {BookTitle}", createBookDto.Title);

            // Check if ISBN already exists
            var existingBook = await _context.Books
                .FirstOrDefaultAsync(b => b.ISBN == createBookDto.ISBN);

            if (existingBook != null)
            {
                return Conflict($"Book with ISBN {createBookDto.ISBN} already exists");
            }

            // Validate publisher exists if provided
            if (createBookDto.PublisherId.HasValue)
            {
                var publisherExists = await _context.Publishers
                    .AnyAsync(p => p.Id == createBookDto.PublisherId.Value);

                if (!publisherExists)
                {
                    return BadRequest($"Publisher with ID {createBookDto.PublisherId} does not exist");
                }
            }

            var book = new Book
            {
                Title = createBookDto.Title,
                Author = createBookDto.Author,
                ISBN = createBookDto.ISBN,
                Price = createBookDto.Price,
                PublishedDate = createBookDto.PublishedDate,
                IsAvailable = createBookDto.IsAvailable,
                PublisherId = createBookDto.PublisherId
            };

            _context.Books.Add(book);
            await _context.SaveChangesAsync();

            var bookDto = new BookDto
            {
                Id = book.Id,
                Title = book.Title,
                Author = book.Author,
                ISBN = book.ISBN,
                Price = book.Price,
                PublishedDate = book.PublishedDate,
                IsAvailable = book.IsAvailable
            };

            return CreatedAtAction(nameof(GetBook), new { id = book.Id }, bookDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating book");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Update an existing book
    /// </summary>
    /// <param name="id">Book ID</param>
    /// <param name="updateBookDto">Updated book data</param>
    /// <returns>No content if successful</returns>
    /// <remarks>
    /// Sample request:
    ///
    ///     PUT /api/books/1
    ///     {
    ///        "title": "Advanced ASP.NET Core",
    ///        "author": "Jane Developer",
    ///        "isbn": "978-0987654321",
    ///        "price": 39.99,
    ///        "publishedDate": "2024-02-20T00:00:00",
    ///        "isAvailable": true,
    ///        "publisherId": 2
    ///     }
    ///
    /// </remarks>
    /// <response code="204">Book updated successfully</response>
    /// <response code="400">If the book data is invalid</response>
    /// <response code="404">If the book is not found</response>
    /// <response code="409">If the ISBN conflicts with another book</response>
    [HttpPut("{id}")]
    [ProducesResponseType(204)]
    [ProducesResponseType(400)]
    [ProducesResponseType(404)]
    [ProducesResponseType(409)]
    public async Task<IActionResult> UpdateBook(int id, [FromBody] UpdateBookDto updateBookDto)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var book = await _context.Books.FindAsync(id);
            if (book == null)
            {
                return NotFound($"Book with ID {id} not found");
            }

            // Check if ISBN is being changed and if it conflicts with another book
            if (book.ISBN != updateBookDto.ISBN)
            {
                var existingBook = await _context.Books
                    .FirstOrDefaultAsync(b => b.ISBN == updateBookDto.ISBN && b.Id != id);

                if (existingBook != null)
                {
                    return Conflict($"Book with ISBN {updateBookDto.ISBN} already exists");
                }
            }

            // Validate publisher exists if provided
            if (updateBookDto.PublisherId.HasValue)
            {
                var publisherExists = await _context.Publishers
                    .AnyAsync(p => p.Id == updateBookDto.PublisherId.Value);

                if (!publisherExists)
                {
                    return BadRequest($"Publisher with ID {updateBookDto.PublisherId} does not exist");
                }
            }

            book.Title = updateBookDto.Title;
            book.Author = updateBookDto.Author;
            book.ISBN = updateBookDto.ISBN;
            book.Price = updateBookDto.Price;
            book.PublishedDate = updateBookDto.PublishedDate;
            book.IsAvailable = updateBookDto.IsAvailable;
            book.PublisherId = updateBookDto.PublisherId;

            await _context.SaveChangesAsync();
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating book {BookId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Delete a book
    /// </summary>
    /// <param name="id">Book ID</param>
    /// <returns>No content if successful</returns>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteBook(int id)
    {
        try
        {
            var book = await _context.Books.FindAsync(id);
            if (book == null)
            {
                return NotFound($"Book with ID {id} not found");
            }

            _context.Books.Remove(book);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Deleted book {BookId}: {BookTitle}", id, book.Title);
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting book {BookId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get all publishers (helper endpoint for testing)
    /// </summary>
    /// <returns>List of all publishers</returns>
    [HttpGet("publishers")]
    public async Task<ActionResult<IEnumerable<object>>> GetPublishers()
    {
        try
        {
            var publishers = await _context.Publishers
                .AsNoTracking()
                .Select(p => new
                {
                    Id = p.Id,
                    Name = p.Name,
                    Address = p.Address,
                    Website = p.Website,
                    FoundedYear = p.FoundedYear
                })
                .OrderBy(p => p.Name)
                .ToListAsync();

            return Ok(publishers);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving publishers");
            return StatusCode(500, "Internal server error");
        }
    }

    private bool BookExists(int id)
    {
        return _context.Books.Any(e => e.Id == id);
    }
}' \
"BooksController with complete CRUD operations using DTOs to avoid circular references"

    # Create exercise guide
    create_file_interactive "EXERCISE_GUIDE.md" \
'# Exercise 1: Basic EF Core Setup and CRUD Operations

## 🎯 Objective
Set up Entity Framework Core in an ASP.NET Core application and implement basic CRUD operations.

## ⏱️ Time Allocation
**Total Time**: 30 minutes
- Setup and Configuration: 10 minutes
- Entity and DbContext Creation: 10 minutes
- CRUD Operations: 10 minutes

## 🚀 Getting Started

### Step 1: Run Initial Migration
```bash
dotnet ef migrations add InitialCreate
dotnet ef database update
```

### Step 2: Complete the GetBooks method
```csharp
var books = await _context.Books
    .Where(b => b.IsAvailable)
    .OrderBy(b => b.Title)
    .ToListAsync();

return Ok(books);
```

### Step 3: Complete the GetBook method
```csharp
var book = await _context.Books.FindAsync(id);

if (book == null)
{
    return NotFound($"Book with ID {id} not found");
}

return Ok(book);
```

### Step 4: Complete the CreateBook method
```csharp
// Check if ISBN already exists
var existingBook = await _context.Books
    .FirstOrDefaultAsync(b => b.ISBN == book.ISBN);

if (existingBook != null)
{
    return Conflict($"Book with ISBN {book.ISBN} already exists");
}

_context.Books.Add(book);
await _context.SaveChangesAsync();

return CreatedAtAction(nameof(GetBook), new { id = book.Id }, book);
```

## 🧪 Testing Your Implementation
1. Run: `dotnet run`
2. Navigate to: http://localhost:5000/swagger
3. Test each endpoint with sample data

## ✅ Success Criteria
- [ ] Entity Framework Core is properly configured
- [ ] Book entity is created with validation
- [ ] DbContext is configured with Fluent API
- [ ] Database is created with seed data
- [ ] All CRUD endpoints are working
- [ ] Proper error handling is implemented

## 🔄 Next Steps
After completing this exercise, move on to Exercise 2 for advanced querying techniques.
' \
"Complete exercise guide with implementation steps"

    echo -e "${GREEN}🎉 Exercise 1 template created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Run: ${CYAN}dotnet ef migrations add InitialCreate${NC}"
    echo "2. Run: ${CYAN}dotnet ef database update${NC}"
    echo "3. Run: ${CYAN}dotnet run${NC}"
    echo "4. Visit: ${CYAN}http://localhost:5000/swagger${NC}"
    echo "5. Follow the EXERCISE_GUIDE.md for implementation steps"

elif [[ $EXERCISE_NAME == "exercise02" ]]; then
    # Exercise 2: Advanced LINQ Queries and Navigation Properties

    explain_concept "Advanced LINQ Queries" \
"Advanced LINQ with Entity Framework Core:
• Navigation Properties: Define relationships between entities
• Include() and ThenInclude(): Eager loading of related data
• Complex Joins: Multi-table queries with proper relationships
• Aggregation: Count, Sum, Average, Min, Max operations
• Grouping: Group data and calculate statistics
• Projection: Select specific fields for performance"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${RED}❌ Exercise 2 requires Exercise 1 to be completed first!${NC}"
        echo -e "${YELLOW}Please run: ./launch-exercises.sh exercise01${NC}"
        exit 1
    fi

    # Note: Author, Publisher, and BookAuthor entities are already created in Exercise 1

    # Create BookQueryService for advanced LINQ queries
    create_file_interactive "Services/BookQueryService.cs" \
'using EFCoreDemo.Data;
using EFCoreDemo.Models;
using Microsoft.EntityFrameworkCore;

namespace EFCoreDemo.Services;

/// <summary>
/// Book query service from Exercise 02 - Advanced LINQ Queries
/// Implements all required query methods from the exercise
/// </summary>
public class BookQueryService
{
    private readonly BookStoreContext _context;
    private readonly ILogger<BookQueryService> _logger;

    public BookQueryService(BookStoreContext context, ILogger<BookQueryService> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Get all books with their publishers (Basic LINQ Query #1)
    /// </summary>
    public async Task<IEnumerable<Book>> GetBooksWithPublishersAsync()
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Where(b => b.IsAvailable)
            .OrderBy(b => b.Title)
            .ToListAsync();
    }

    /// <summary>
    /// Get books by a specific author (Basic LINQ Query #2)
    /// </summary>
    public async Task<IEnumerable<Book>> GetBooksByAuthorAsync(int authorId)
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Include(b => b.BookAuthors)
                .ThenInclude(ba => ba.Author)
            .Where(b => b.BookAuthors.Any(ba => ba.AuthorId == authorId))
            .OrderBy(b => b.Title)
            .ToListAsync();
    }

    /// <summary>
    /// Get authors with their book count (Basic LINQ Query #3)
    /// </summary>
    public async Task<IEnumerable<object>> GetAuthorsWithBookCountAsync()
    {
        return await _context.Authors
            .Select(a => new
            {
                AuthorId = a.Id,
                FullName = a.FirstName + " " + a.LastName,
                Email = a.Email,
                BookCount = a.BookAuthors.Count()
            })
            .OrderByDescending(a => a.BookCount)
            .ToListAsync();
    }

    /// <summary>
    /// Full-text search across book title, author name, and publisher - Search (Advanced Query #5)
    /// </summary>
    public async Task<IEnumerable<object>> SearchBooksAsync(string searchTerm)
    {
        var term = searchTerm.ToLower();

        return await _context.Books
            .Include(b => b.Publisher)
            .Include(b => b.BookAuthors)
                .ThenInclude(ba => ba.Author)
            .Where(b => b.Title.ToLower().Contains(term) ||
                       b.ISBN.Contains(term) ||
                       (b.Publisher != null && b.Publisher.Name.ToLower().Contains(term)) ||
                       b.BookAuthors.Any(ba =>
                           ba.Author.FirstName.ToLower().Contains(term) ||
                           ba.Author.LastName.ToLower().Contains(term)))
            .Select(b => new
            {
                Id = b.Id,
                Title = b.Title,
                ISBN = b.ISBN,
                Price = b.Price,
                PublisherName = b.Publisher != null ? b.Publisher.Name : "Unknown",
                Authors = b.BookAuthors.Select(ba => new
                {
                    Name = ba.Author.FullName,
                    Role = ba.Role
                }).ToList()
            })
            .OrderBy(b => b.Title)
            .ToListAsync();
    }
}' \
"BookQueryService with advanced LINQ query implementations"

    # Create QueryTestController to expose LINQ queries as API endpoints
    create_file_interactive "Controllers/QueryTestController.cs" \
'using EFCoreDemo.Services;
using Microsoft.AspNetCore.Mvc;

namespace EFCoreDemo.Controllers;

/// <summary>
/// Query Test Controller from Exercise 02 - Advanced LINQ Queries
/// Demonstrates all required query methods from the exercise
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class QueryTestController : ControllerBase
{
    private readonly BookQueryService _queryService;
    private readonly ILogger<QueryTestController> _logger;

    public QueryTestController(BookQueryService queryService, ILogger<QueryTestController> logger)
    {
        _queryService = queryService;
        _logger = logger;
    }

    /// <summary>
    /// Get books with publishers - Basic Query #1
    /// </summary>
    [HttpGet("books-with-publishers")]
    public async Task<IActionResult> GetBooksWithPublishers()
    {
        try
        {
            var result = await _queryService.GetBooksWithPublishersAsync();
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting books with publishers");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get books by author - Basic Query #2
    /// </summary>
    [HttpGet("books-by-author/{authorId}")]
    public async Task<IActionResult> GetBooksByAuthor(int authorId)
    {
        try
        {
            var result = await _queryService.GetBooksByAuthorAsync(authorId);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting books by author {AuthorId}", authorId);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get authors with book count - Basic Query #3
    /// </summary>
    [HttpGet("authors-with-book-count")]
    public async Task<IActionResult> GetAuthorsWithBookCount()
    {
        try
        {
            var result = await _queryService.GetAuthorsWithBookCountAsync();
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting authors with book count");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Search books across multiple fields - Advanced Query #5 (Search)
    /// </summary>
    [HttpGet("search")]
    public async Task<IActionResult> SearchBooks([FromQuery] string term)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(term))
            {
                return BadRequest("Search term is required");
            }

            var result = await _queryService.SearchBooksAsync(term);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error searching books with term: {Term}", term);
            return StatusCode(500, "Internal server error");
        }
    }
}' \
"QueryTestController to expose BookQueryService methods as API endpoints"

    # Update Program.cs to register BookQueryService
    echo -e "${CYAN}Updating Program.cs to register BookQueryService...${NC}"
    if [ -f "Program.cs" ]; then
        # Uncomment the BookQueryService registration using a more robust approach
        sed -i.bak 's|^// builder\.Services\.AddScoped<EFCoreDemo\.Services\.BookQueryService>();|builder.Services.AddScoped<EFCoreDemo.Services.BookQueryService>();|g' Program.cs
        # Verify the change was made
        if grep -q "^builder\.Services\.AddScoped<EFCoreDemo\.Services\.BookQueryService>();" Program.cs; then
            echo -e "${GREEN}✅ Updated Program.cs with BookQueryService registration${NC}"
        else
            echo -e "${YELLOW}⚠️  Manual registration may be needed - check Program.cs${NC}"
        fi
    else
        echo -e "${RED}❌ Program.cs not found - please register BookQueryService manually${NC}"
    fi

    # Create Exercise Guide for Exercise 2
    create_file_interactive "EXERCISE_02_GUIDE.md" \
'# Exercise 2: Advanced LINQ Queries and Navigation Properties

## 🎯 Objective
Master advanced LINQ queries with Entity Framework Core, including joins, navigation properties, and complex filtering scenarios.

## ⏱️ Time Allocation
**Total Time**: 25 minutes
- Entity Relationships Setup: 8 minutes
- Basic LINQ Queries: 7 minutes
- Advanced Query Scenarios: 10 minutes

## 🚀 Getting Started

### Step 1: Service Registration (Automatic)
The BookQueryService has been automatically registered in Program.cs.

### Step 2: Create Migration
```bash
dotnet ef migrations add AddAuthorPublisherRelationships
dotnet ef database update
```

## ✅ Success Criteria
- [ ] All entities are properly configured with relationships
- [ ] Database migrations are created and applied successfully
- [ ] All basic LINQ queries return correct results
- [ ] Advanced queries with joins and aggregations work correctly
- [ ] Search functionality works across multiple tables

## 🧪 Testing Your Implementation
1. Run: `dotnet run`
2. Navigate to: http://localhost:5000/swagger
3. Test the new QueryTest endpoints:
   - GET /api/querytest/books-with-publishers
   - GET /api/querytest/books-by-author/{authorId}
   - GET /api/querytest/authors-with-book-count
   - GET /api/querytest/search?term=...
4. Verify complex relationships are loaded correctly

## 🎯 Learning Outcomes
After completing this exercise, you should understand:
- Entity relationships and navigation properties
- Advanced LINQ query techniques
- Include() and ThenInclude() for eager loading
- Complex joins and aggregations
- Search across multiple entities
' \
"Complete exercise guide for Advanced LINQ Queries"

    echo -e "${GREEN}🎉 Exercise 2 template created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. BookQueryService automatically registered ✅"
    echo "2. Run: ${CYAN}dotnet ef migrations add AddAuthorPublisherRelationships${NC}"
    echo "3. Run: ${CYAN}dotnet ef database update${NC}"
    echo "4. Run: ${CYAN}dotnet run${NC}"
    echo "5. Test QueryTest endpoints in Swagger: /api/querytest/books-with-publishers"
    echo "6. Follow the EXERCISE_02_GUIDE.md for implementation steps"

elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    # Exercise 3: Repository Pattern and Unit of Work Implementation

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${RED}❌ Exercise 3 requires Exercise 1 to be completed first!${NC}"
        echo -e "${CYAN}Please run: ./launch-exercises.sh exercise01${NC}"
        exit 1
    fi

    explain_concept "Repository Pattern" \
"Repository Pattern provides an abstraction layer between your business logic and data access:
• Encapsulates data access logic in repository classes
• Makes code more testable by allowing easy mocking
• Provides a consistent interface for data operations
• Enables switching data sources without changing business logic
• Centralizes query logic for reusability"

    # Create Repositories folder
    if [ ! -d "Repositories" ]; then
        mkdir -p Repositories
    fi

    # Create IRepository interface
    create_file_interactive "Repositories/IRepository.cs" \
'using System.Linq.Expressions;

namespace EFCoreDemo.Repositories;

/// <summary>
/// Generic repository interface for common CRUD operations
/// From Exercise 03 - Repository Pattern
/// </summary>
public interface IRepository<T> where T : class
{
    // Basic CRUD operations
    Task<IEnumerable<T>> GetAllAsync();
    Task<T?> GetByIdAsync(int id);
    Task<T> AddAsync(T entity);
    Task<T> UpdateAsync(T entity);
    Task<bool> DeleteAsync(int id);
    
    // Advanced operations
    Task<bool> ExistsAsync(int id);
    Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate);
    Task<T?> FirstOrDefaultAsync(Expression<Func<T, bool>> predicate);
    Task<int> CountAsync();
    Task<int> CountAsync(Expression<Func<T, bool>> predicate);
    
    // Pagination
    Task<IEnumerable<T>> GetPagedAsync(int page, int pageSize);
    Task<IEnumerable<T>> GetPagedAsync(
        Expression<Func<T, bool>>? filter = null,
        Func<IQueryable<T>, IOrderedQueryable<T>>? orderBy = null,
        int page = 1,
        int pageSize = 10);
}' \
"Generic repository interface defining common data access operations"

    # Create Repository base implementation
    create_file_interactive "Repositories/Repository.cs" \
'using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Data;

namespace EFCoreDemo.Repositories;

/// <summary>
/// Generic repository implementation for common CRUD operations
/// From Exercise 03 - Repository Pattern
/// </summary>
public class Repository<T> : IRepository<T> where T : class
{
    protected readonly BookStoreContext _context;
    protected readonly DbSet<T> _dbSet;
    
    public Repository(BookStoreContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }
    
    public virtual async Task<IEnumerable<T>> GetAllAsync()
    {
        return await _dbSet.ToListAsync();
    }
    
    public virtual async Task<T?> GetByIdAsync(int id)
    {
        return await _dbSet.FindAsync(id);
    }
    
    public virtual async Task<T> AddAsync(T entity)
    {
        var result = await _dbSet.AddAsync(entity);
        return result.Entity;
    }
    
    public virtual async Task<T> UpdateAsync(T entity)
    {
        _dbSet.Update(entity);
        return entity;
    }
    
    public virtual async Task<bool> DeleteAsync(int id)
    {
        var entity = await GetByIdAsync(id);
        if (entity == null)
            return false;
            
        _dbSet.Remove(entity);
        return true;
    }
    
    public virtual async Task<bool> ExistsAsync(int id)
    {
        return await _dbSet.FindAsync(id) != null;
    }
    
    public virtual async Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate)
    {
        return await _dbSet.Where(predicate).ToListAsync();
    }
    
    public virtual async Task<T?> FirstOrDefaultAsync(Expression<Func<T, bool>> predicate)
    {
        return await _dbSet.FirstOrDefaultAsync(predicate);
    }
    
    public virtual async Task<int> CountAsync()
    {
        return await _dbSet.CountAsync();
    }
    
    public virtual async Task<int> CountAsync(Expression<Func<T, bool>> predicate)
    {
        return await _dbSet.CountAsync(predicate);
    }
    
    public virtual async Task<IEnumerable<T>> GetPagedAsync(int page, int pageSize)
    {
        return await _dbSet
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }
    
    public virtual async Task<IEnumerable<T>> GetPagedAsync(
        Expression<Func<T, bool>>? filter = null,
        Func<IQueryable<T>, IOrderedQueryable<T>>? orderBy = null,
        int page = 1,
        int pageSize = 10)
    {
        IQueryable<T> query = _dbSet;
        
        if (filter != null)
        {
            query = query.Where(filter);
        }
        
        if (orderBy != null)
        {
            query = orderBy(query);
        }
        
        return await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }
}' \
"Generic repository implementation with pagination and filtering support"

    explain_concept "Specific Repositories" \
"Specific repositories extend the generic repository with domain-specific operations:
• IBookRepository adds book-specific queries like GetBooksWithPublisher
• IAuthorRepository adds author-specific queries like GetAuthorsWithBooks
• Encapsulates complex LINQ queries in meaningful method names
• Provides a clear API for the business layer
• Makes testing easier with focused interfaces"

    # Create IBookRepository interface
    create_file_interactive "Repositories/IBookRepository.cs" \
'using EFCoreDemo.Models;

namespace EFCoreDemo.Repositories;

/// <summary>
/// Book-specific repository interface
/// From Exercise 03 - Repository Pattern
/// </summary>
public interface IBookRepository : IRepository<Book>
{
    Task<IEnumerable<Book>> GetBooksWithPublisherAsync();
    Task<Book?> GetBookWithDetailsAsync(int id);
    Task<IEnumerable<Book>> GetBooksByAuthorAsync(int authorId);
    Task<IEnumerable<Book>> GetBooksByPublisherAsync(int publisherId);
    Task<IEnumerable<Book>> SearchBooksAsync(string searchTerm);
    Task<IEnumerable<Book>> GetBooksByPriceRangeAsync(decimal minPrice, decimal maxPrice);
    Task<bool> IsbnExistsAsync(string isbn, int? excludeBookId = null);
    Task<decimal> GetAveragePriceAsync();
    Task<IEnumerable<Book>> GetBooksPublishedInYearAsync(int year);
}' \
"Book-specific repository interface with domain-specific queries"

    # Create BookRepository implementation
    create_file_interactive "Repositories/BookRepository.cs" \
'using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Data;
using EFCoreDemo.Models;

namespace EFCoreDemo.Repositories;

/// <summary>
/// Book-specific repository implementation
/// From Exercise 03 - Repository Pattern
/// </summary>
public class BookRepository : Repository<Book>, IBookRepository
{
    public BookRepository(BookStoreContext context) : base(context)
    {
    }
    
    public async Task<IEnumerable<Book>> GetBooksWithPublisherAsync()
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Where(b => b.IsAvailable)
            .OrderBy(b => b.Title)
            .ToListAsync();
    }
    
    public async Task<Book?> GetBookWithDetailsAsync(int id)
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Include(b => b.BookAuthors)
                .ThenInclude(ba => ba.Author)
            .FirstOrDefaultAsync(b => b.Id == id);
    }
    
    public async Task<IEnumerable<Book>> GetBooksByAuthorAsync(int authorId)
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Where(b => b.BookAuthors.Any(ba => ba.AuthorId == authorId))
            .OrderBy(b => b.Title)
            .ToListAsync();
    }
    
    public async Task<IEnumerable<Book>> GetBooksByPublisherAsync(int publisherId)
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Where(b => b.PublisherId == publisherId && b.IsAvailable)
            .OrderBy(b => b.Title)
            .ToListAsync();
    }
    
    public async Task<IEnumerable<Book>> SearchBooksAsync(string searchTerm)
    {
        var term = searchTerm.ToLower();
        return await _context.Books
            .Include(b => b.Publisher)
            .Include(b => b.BookAuthors)
                .ThenInclude(ba => ba.Author)
            .Where(b => b.Title.ToLower().Contains(term) ||
                       b.ISBN.Contains(term) ||
                       (b.Publisher != null && b.Publisher.Name.ToLower().Contains(term)) ||
                       b.BookAuthors.Any(ba => 
                           ba.Author.FirstName.ToLower().Contains(term) ||
                           ba.Author.LastName.ToLower().Contains(term)))
            .OrderBy(b => b.Title)
            .ToListAsync();
    }
    
    public async Task<IEnumerable<Book>> GetBooksByPriceRangeAsync(decimal minPrice, decimal maxPrice)
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Where(b => b.Price >= minPrice && b.Price <= maxPrice)
            .OrderBy(b => b.Price)
            .ToListAsync();
    }
    
    public async Task<bool> IsbnExistsAsync(string isbn, int? excludeBookId = null)
    {
        var query = _context.Books.Where(b => b.ISBN == isbn);
        
        if (excludeBookId.HasValue)
        {
            query = query.Where(b => b.Id != excludeBookId.Value);
        }
        
        return await query.AnyAsync();
    }
    
    public async Task<decimal> GetAveragePriceAsync()
    {
        return await _context.Books.AverageAsync(b => b.Price);
    }
    
    public async Task<IEnumerable<Book>> GetBooksPublishedInYearAsync(int year)
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Where(b => b.PublishedDate.Year == year)
            .OrderBy(b => b.PublishedDate)
            .ToListAsync();
    }
}' \
"Book repository implementation with all domain-specific queries"

    # Create Unit of Work Interface
    create_file_interactive "UnitOfWork/IUnitOfWork.cs" \
'using EFCoreDemo.Models;
using EFCoreDemo.Repositories;

namespace EFCoreDemo.UnitOfWork;

/// <summary>
/// Unit of Work interface from Exercise 03 - Repository Pattern
/// Coordinates multiple repositories and manages transactions
/// </summary>
public interface IUnitOfWork : IDisposable
{
    IBookRepository Books { get; }
    IRepository<Author> Authors { get; }
    IRepository<Publisher> Publishers { get; }

    Task<int> SaveChangesAsync();
    Task BeginTransactionAsync();
    Task CommitTransactionAsync();
    Task RollbackTransactionAsync();
}' \
"Unit of Work interface for coordinating repositories and transactions"

    # Create Unit of Work Implementation
    create_file_interactive "UnitOfWork/UnitOfWork.cs" \
'using Microsoft.EntityFrameworkCore.Storage;
using EFCoreDemo.Data;
using EFCoreDemo.Models;
using EFCoreDemo.Repositories;

namespace EFCoreDemo.UnitOfWork;

/// <summary>
/// Unit of Work implementation from Exercise 03
/// Manages multiple repositories and ensures transactional consistency
/// </summary>
public class UnitOfWork : IUnitOfWork
{
    private readonly BookStoreContext _context;
    private IDbContextTransaction? _transaction;

    public IBookRepository Books { get; }
    public IRepository<Author> Authors { get; }
    public IRepository<Publisher> Publishers { get; }

    public UnitOfWork(BookStoreContext context)
    {
        _context = context;
        Books = new BookRepository(_context);
        Authors = new Repository<Author>(_context);
        Publishers = new Repository<Publisher>(_context);
    }

    public async Task<int> SaveChangesAsync()
    {
        return await _context.SaveChangesAsync();
    }

    public async Task BeginTransactionAsync()
    {
        _transaction = await _context.Database.BeginTransactionAsync();
    }

    public async Task CommitTransactionAsync()
    {
        if (_transaction != null)
        {
            await _transaction.CommitAsync();
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }

    public async Task RollbackTransactionAsync()
    {
        if (_transaction != null)
        {
            await _transaction.RollbackAsync();
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }

    public void Dispose()
    {
        _transaction?.Dispose();
        _context.Dispose();
    }
}' \
"Unit of Work implementation with transaction management"

    # Create Exercise Guide for Exercise 3
    create_file_interactive "EXERCISE_03_GUIDE.md" \
'# Exercise 3: Repository Pattern and Unit of Work Implementation

## 🎯 Objective
Refactor direct Entity Framework Core usage to implement the Repository Pattern and Unit of Work Pattern for better separation of concerns, testability, and maintainability.

## ⏱️ Time Allocation
**Total Time**: 35 minutes
- Generic Repository Implementation: 12 minutes
- Specific Repository Implementation: 10 minutes
- Unit of Work Pattern: 8 minutes
- Controller Refactoring: 5 minutes

## 🚀 Getting Started

### Step 1: Register Services in Program.cs
Add the following to your Program.cs service registration:

```csharp
// Register repositories
builder.Services.AddScoped<IBookRepository, BookRepository>();
builder.Services.AddScoped(typeof(IRepository<>), typeof(Repository<>));

// Register Unit of Work
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
```

### Step 2: Refactor BooksController
Update your BooksController to use the Unit of Work pattern:

```csharp
[ApiController]
[Route("api/[controller]")]
public class BooksController : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<BooksController> _logger;

    public BooksController(IUnitOfWork unitOfWork, ILogger<BooksController> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Book>>> GetBooks()
    {
        try
        {
            var books = await _unitOfWork.Books.GetBooksWithPublisherAsync();
            return Ok(books);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving books");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPost]
    public async Task<ActionResult<Book>> CreateBook(Book book)
    {
        try
        {
            // Validate ISBN uniqueness
            if (await _unitOfWork.Books.IsbnExistsAsync(book.ISBN))
            {
                return Conflict($"Book with ISBN {book.ISBN} already exists");
            }

            await _unitOfWork.BeginTransactionAsync();

            var createdBook = await _unitOfWork.Books.AddAsync(book);
            await _unitOfWork.SaveChangesAsync();

            await _unitOfWork.CommitTransactionAsync();

            return CreatedAtAction(nameof(GetBook), new { id = createdBook.Id }, createdBook);
        }
        catch (Exception ex)
        {
            await _unitOfWork.RollbackTransactionAsync();
            _logger.LogError(ex, "Error creating book");
            return StatusCode(500, "Internal server error");
        }
    }
}
```

## ✅ Success Criteria
- [ ] Generic repository interface and implementation are complete
- [ ] Specific repositories are implemented with domain-specific methods
- [ ] Unit of Work pattern is properly implemented
- [ ] Transaction management works correctly
- [ ] Controllers are refactored to use repositories
- [ ] Proper error handling and logging are in place

## 🧪 Testing Your Implementation
1. Run: `dotnet run`
2. Navigate to: http://localhost:5000/swagger
3. Test repository methods through API endpoints
4. Verify transaction rollback by causing intentional errors

## 🎯 Learning Outcomes
After completing this exercise, you should understand:
- Repository pattern implementation and benefits
- Unit of Work pattern for transaction management
- Dependency injection with repositories
- Clean architecture principles
- Testable code design
' \
"Complete exercise guide for Repository Pattern implementation"

    echo -e "${GREEN}🎉 Exercise 3 template created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Update Program.cs with repository registrations"
    echo "2. Refactor controllers to use Unit of Work"
    echo "3. Run: ${CYAN}dotnet run${NC}"
    echo "4. Test repository patterns through API endpoints"
    echo "5. Follow the EXERCISE_03_GUIDE.md for implementation steps"

fi

echo ""
echo -e "${GREEN}✅ Module 5 Exercise Setup Complete!${NC}"
echo -e "${CYAN}Happy coding! 🚀${NC}"
