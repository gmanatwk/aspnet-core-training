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
            echo "  📚 1. Setting up Entity Framework Core with SQL Server"
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
            echo "  ✅ SQL Server database with Code-First approach"
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
echo -e "   ${CYAN}# Includes SQL Server and demo application${NC}"
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
        dotnet add package Microsoft.EntityFrameworkCore.SqlServer
        dotnet add package Microsoft.EntityFrameworkCore.Tools
        dotnet add package Microsoft.EntityFrameworkCore.Design

        # Update Program.cs with EF Core configuration
        create_file_interactive "Program.cs" \
'using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();

// Add Entity Framework with SQL Server
builder.Services.AddDbContext<BookStoreContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

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
"Program.cs with Entity Framework Core and SQL Server configuration"
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

    // Computed property for display
    [NotMapped]
    public string DisplayTitle => $"{Title} by {Author}";
}' \
"Book entity model with data annotations and validation"

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
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=BookStoreDB;Trusted_Connection=true;MultipleActiveResultSets=true"
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
"Configuration file with SQL Server connection string and EF Core logging"

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
    echo -e "${CYAN}Exercise 2 implementation would be added here...${NC}"
    echo -e "${YELLOW}This exercise builds on Exercise 1 with advanced LINQ queries${NC}"

elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    echo -e "${CYAN}Exercise 3 implementation would be added here...${NC}"
    echo -e "${YELLOW}This exercise implements the Repository pattern${NC}"

fi

echo ""
echo -e "${GREEN}✅ Module 5 Exercise Setup Complete!${NC}"
echo -e "${CYAN}Happy coding! 🚀${NC}"
