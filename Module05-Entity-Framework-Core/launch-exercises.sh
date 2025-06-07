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

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();

// Add Entity Framework with SQLite
builder.Services.AddDbContext<BookStoreContext>(options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "BookStore API", Version = "v1" });
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
    public virtual Publisher? Publisher { get; set; }
    public virtual ICollection<BookAuthor> BookAuthors { get; set; } = new List<BookAuthor>();

    // Computed property for display
    [NotMapped]
    public string DisplayTitle => $"{Title} by {Author}";
}' \
"Book entity model with data annotations, validation, and navigation properties"

    # Create Author entity
    create_file_interactive "Models/Author.cs" \
'using System.ComponentModel.DataAnnotations;

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
    public virtual ICollection<BookAuthor> BookAuthors { get; set; } = new List<BookAuthor>();

    // Computed property
    public string FullName => $"{FirstName} {LastName}";
}' \
"Author entity with navigation properties for many-to-many relationship"

    # Create Publisher entity
    create_file_interactive "Models/Publisher.cs" \
'using System.ComponentModel.DataAnnotations;

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
    public virtual ICollection<Book> Books { get; set; } = new List<Book>();
}' \
"Publisher entity with one-to-many relationship to books"

    # Create BookAuthor junction entity
    create_file_interactive "Models/BookAuthor.cs" \
'namespace EFCoreDemo.Models;

/// <summary>
/// BookAuthor junction entity for many-to-many relationship between Books and Authors
/// </summary>
public class BookAuthor
{
    public int BookId { get; set; }
    public int AuthorId { get; set; }
    public string Role { get; set; } = "Primary Author"; // Primary Author, Co-Author, Editor

    // Navigation properties
    public virtual Book Book { get; set; } = null!;
    public virtual Author Author { get; set; } = null!;
}' \
"Junction entity for many-to-many relationship between Books and Authors"

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
                .OnDelete(DeleteBehavior.SetNull);
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
        modelBuilder.Entity<Book>().HasData(
            new Book
            {
                Id = 1,
                Title = "C# Programming Guide",
                Author = "John Smith",
                ISBN = "978-1234567890",
                Price = 29.99m,
                PublishedDate = new DateTime(2023, 1, 15),
                IsAvailable = true
            },
            new Book
            {
                Id = 2,
                Title = "ASP.NET Core in Action",
                Author = "Jane Doe",
                ISBN = "978-0987654321",
                Price = 39.99m,
                PublishedDate = new DateTime(2023, 3, 20),
                IsAvailable = true
            },
            new Book
            {
                Id = 3,
                Title = "Entity Framework Core Deep Dive",
                Author = "Bob Johnson",
                ISBN = "978-1122334455",
                Price = 45.99m,
                PublishedDate = new DateTime(2023, 6, 10),
                IsAvailable = false
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
    public async Task<ActionResult<IEnumerable<Book>>> GetBooks()
    {
        try
        {
            _logger.LogInformation("Retrieving all books");

            // TODO: Implement getting all books
            // HINT: Use await _context.Books.ToListAsync()
            return Ok(new { message = "TODO: Implement GetBooks method" });
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
    public async Task<ActionResult<Book>> GetBook(int id)
    {
        try
        {
            _logger.LogInformation("Retrieving book with ID: {BookId}", id);

            // TODO: Get a specific book by ID
            // HINT: Use await _context.Books.FindAsync(id)
            return Ok(new { message = $"TODO: Implement GetBook for id: {id}" });
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
    /// <param name="book">Book to create</param>
    /// <returns>Created book</returns>
    [HttpPost]
    public async Task<ActionResult<Book>> CreateBook(Book book)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            _logger.LogInformation("Creating new book: {BookTitle}", book.Title);

            // TODO: Add book to database
            // STEPS:
            // 1. _context.Books.Add(book)
            // 2. await _context.SaveChangesAsync()
            // 3. Return CreatedAtAction(nameof(GetBook), new { id = book.Id }, book)
            return Ok(new { message = "TODO: Implement CreateBook method" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating book");
            return StatusCode(500, "Internal server error");
        }
    }

    // TODO: Add PUT and DELETE methods
    // PUT: api/books/5
    // DELETE: api/books/5
}' \
"BooksController with TODO implementations for students to complete"

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

### Step 1: Register BookQueryService
Add to Program.cs:

```csharp
builder.Services.AddScoped<BookQueryService>();
```

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
3. Test query methods through API endpoints
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
    echo "1. Register BookQueryService in Program.cs"
    echo "2. Run: ${CYAN}dotnet ef migrations add AddAuthorPublisherRelationships${NC}"
    echo "3. Run: ${CYAN}dotnet ef database update${NC}"
    echo "4. Run: ${CYAN}dotnet run${NC}"
    echo "5. Test advanced LINQ queries through API endpoints"
    echo "6. Follow the EXERCISE_02_GUIDE.md for implementation steps"

elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    # Exercise 3: Repository Pattern and Unit of Work Implementation

    explain_concept "Repository Pattern" \
"Repository Pattern benefits:
• Separation of Concerns: Isolate data access logic
• Testability: Easy to mock repositories for unit testing
• Maintainability: Centralized data access logic
• Flexibility: Easy to switch data sources
• Clean Architecture: Domain logic separated from data access"

    explain_concept "Unit of Work Pattern" \
"Unit of Work Pattern coordinates multiple repositories:
• Transaction Management: Ensure data consistency
• Change Tracking: Manage entity state across operations
• Performance: Batch database operations
• Rollback Capability: Handle errors gracefully"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${RED}❌ Exercise 3 requires Exercises 1 and 2 to be completed first!${NC}"
        echo -e "${YELLOW}Please run exercises in order: exercise01, exercise02, exercise03${NC}"
        exit 1
    fi

    # Create Generic Repository Interface
    create_file_interactive "Repositories/IRepository.cs" \
'using System.Linq.Expressions;

namespace EFCoreDemo.Repositories;

/// <summary>
/// Generic repository interface from Exercise 03 - Repository Pattern
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
"Generic repository interface with common CRUD and query operations"

    # Create Generic Repository Implementation
    create_file_interactive "Repositories/Repository.cs" \
'using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Data;
using System.Linq.Expressions;

namespace EFCoreDemo.Repositories;

/// <summary>
/// Generic repository implementation from Exercise 03
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
"Generic repository implementation with all CRUD and query operations"

    # Create Book Repository Interface
    create_file_interactive "Repositories/IBookRepository.cs" \
'using EFCoreDemo.Models;

namespace EFCoreDemo.Repositories;

/// <summary>
/// Book repository interface from Exercise 03 - Repository Pattern
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
"Book repository interface with book-specific operations"

    # Create Book Repository Implementation
    create_file_interactive "Repositories/BookRepository.cs" \
'using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Data;
using EFCoreDemo.Models;

namespace EFCoreDemo.Repositories;

/// <summary>
/// Book repository implementation from Exercise 03
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
            .Where(b => b.Price >= minPrice && b.Price <= maxPrice && b.IsAvailable)
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
        return await _context.Books
            .Where(b => b.IsAvailable)
            .AverageAsync(b => b.Price);
    }

    public async Task<IEnumerable<Book>> GetBooksPublishedInYearAsync(int year)
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Where(b => b.PublishedDate.Year == year && b.IsAvailable)
            .OrderBy(b => b.PublishedDate)
            .ToListAsync();
    }
}' \
"Book repository implementation with all book-specific operations"

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
