#!/bin/bash

# Enhanced Exercise Launcher v2 - With Learning Explanations
# This version explains WHY each component is created and builds progressively

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to create a file with explanation
create_file_with_explanation() {
    local file_path=$1
    local content=$2
    local explanation=$3
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$file_path")"
    
    # Write content to file
    echo "$content" > "$file_path"
    echo -e "  📄 Created: $file_path"
    echo -e "  ${CYAN}   ℹ️  Why: $explanation${NC}"
}

# Function to show learning objectives
show_learning_objectives() {
    local exercise=$1
    
    echo -e "${MAGENTA}🎯 Learning Objectives:${NC}"
    
    case $exercise in
        "module03-exercise01")
            echo "  1. Understand RESTful API principles"
            echo "  2. Create your first controller with CRUD operations"
            echo "  3. Learn dependency injection with DbContext"
            echo "  4. Use Entity Framework Core with in-memory database"
            ;;
        "module03-exercise02")
            echo "  1. Add JWT authentication to existing API"
            echo "  2. Protect endpoints with [Authorize] attribute"
            echo "  3. Implement user registration and login"
            echo "  4. Build on Exercise 1's models and controllers"
            ;;
        "module03-exercise03")
            echo "  1. Add API versioning to support multiple versions"
            echo "  2. Document API with Swagger annotations"
            echo "  3. Implement health checks for monitoring"
            echo "  4. Enhance Exercise 2's authenticated API"
            ;;
    esac
    echo ""
}

# Function to create progressive files
create_progressive_controller() {
    local exercise=$1
    local project_name=$2
    
    case $exercise in
        "module03-exercise01")
            # Basic controller - first exposure
            create_file_with_explanation "Controllers/BooksController.cs" 'using Microsoft.AspNetCore.Mvc;
using LibraryAPI.Models;
using LibraryAPI.Data;

namespace LibraryAPI.Controllers
{
    // LEARNING POINT: [ApiController] attribute enables:
    // - Automatic model validation
    // - Automatic HTTP 400 responses for validation errors
    // - Binding source parameter inference
    [ApiController]
    [Route("api/[controller]")]  // Creates route: /api/books
    public class BooksController : ControllerBase
    {
        // LEARNING POINT: Dependency Injection
        // The DbContext is injected here, not created manually
        // This makes the controller testable and loosely coupled
        private readonly LibraryContext _context;

        public BooksController(LibraryContext context)
        {
            _context = context;
        }

        // TODO: Exercise 1.1 - Implement GET all books
        // HINT: Use _context.Books.ToListAsync()
        // QUESTION: Why use async/await for database operations?
        [HttpGet]
        public IActionResult GetBooks()
        {
            // Replace this with actual implementation
            return Ok(new { message = "Implement GetBooks", hint = "Return all books from _context" });
        }

        // TODO: Exercise 1.2 - Implement GET book by ID
        // LEARNING POINT: Route parameters like {id} are automatically bound
        [HttpGet("{id}")]
        public IActionResult GetBook(int id)
        {
            // HINT: Use _context.Books.FindAsync(id)
            // QUESTION: What should you return if the book is not found?
            return Ok(new { message = $"Implement GetBook for id: {id}" });
        }

        // TODO: Exercise 1.3 - Implement POST to create a book
        // LEARNING POINT: [FromBody] tells ASP.NET to deserialize JSON
        [HttpPost]
        public IActionResult CreateBook([FromBody] Book book)
        {
            // STEPS:
            // 1. Validate the model (done automatically with [ApiController])
            // 2. Add to context: _context.Books.Add(book)
            // 3. Save changes: await _context.SaveChangesAsync()
            // 4. Return CreatedAtAction with location header
            return Ok(new { message = "Implement CreateBook" });
        }
    }
}' \
            "Controllers handle HTTP requests and define your API endpoints. This is where your API logic begins."
            
            # Create explanation file
            create_file_with_explanation "Controllers/README_CONTROLLERS.md" '# Understanding Controllers

## What is a Controller?
A controller is a class that handles HTTP requests in ASP.NET Core. Think of it as the "traffic director" of your API.

## Key Concepts in BooksController:

### 1. Attributes
- `[ApiController]` - Adds API-specific behaviors like automatic model validation
- `[Route("api/[controller]")]` - Defines the URL pattern (/api/books)
- `[HttpGet]`, `[HttpPost]` - Specify which HTTP methods each action handles

### 2. Dependency Injection
```csharp
private readonly LibraryContext _context;
public BooksController(LibraryContext context)
{
    _context = context;
}
```
- The database context is "injected" not "created"
- This makes the code testable and maintainable

### 3. Action Methods
Each public method in a controller is an "action" that handles a specific endpoint:
- `GetBooks()` → GET /api/books
- `GetBook(int id)` → GET /api/books/5
- `CreateBook(Book book)` → POST /api/books

## Your Tasks:
1. Implement the TODO methods
2. Test each endpoint using Swagger UI
3. Understand why we use async/await for database operations

## Next Exercise Preview:
In Exercise 2, you will add authentication to protect these endpoints!' \
            "This guide explains the controller concepts you're implementing"
            ;;
            
        "module03-exercise02")
            # Enhanced controller with authentication
            create_file_with_explanation "Controllers/BooksController.cs" 'using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using LibraryAPI.Models;
using LibraryAPI.Data;

namespace LibraryAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize] // NEW: Requires authentication for all endpoints
    public class BooksController : ControllerBase
    {
        private readonly LibraryContext _context;

        public BooksController(LibraryContext context)
        {
            _context = context;
        }

        // PROGRESS CHECK: This should be implemented from Exercise 1
        // Now it requires authentication!
        [HttpGet]
        public async Task<IActionResult> GetBooks()
        {
            // Your Exercise 1 implementation here
            var books = await _context.Books.ToListAsync();
            return Ok(books);
        }

        // NEW: Anonymous access for browsing
        [HttpGet("{id}")]
        [AllowAnonymous] // TODO: Exercise 2.1 - Understand why we might allow anonymous access here
        public async Task<IActionResult> GetBook(int id)
        {
            var book = await _context.Books.FindAsync(id);
            return book != null ? Ok(book) : NotFound();
        }

        // NEW: Only authenticated users can create books
        [HttpPost]
        public async Task<IActionResult> CreateBook([FromBody] Book book)
        {
            // TODO: Exercise 2.2 - Add the current user as the book creator
            // HINT: Use User.Identity.Name to get the username
            // book.CreatedBy = User.Identity.Name;
            
            _context.Books.Add(book);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetBook), new { id = book.Id }, book);
        }

        // NEW: Role-based authorization
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")] // TODO: Exercise 2.3 - Test with different user roles
        public async Task<IActionResult> DeleteBook(int id)
        {
            // Only admins can delete books
            var book = await _context.Books.FindAsync(id);
            if (book == null) return NotFound();
            
            _context.Books.Remove(book);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}' \
            "Building on Exercise 1, we add authentication to protect our API endpoints"
            
            # Create auth controller
            create_file_with_explanation "Controllers/AuthController.cs" 'using Microsoft.AspNetCore.Mvc;

namespace LibraryAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        // TODO: Exercise 2.4 - Implement user registration
        [HttpPost("register")]
        public IActionResult Register([FromBody] RegisterModel model)
        {
            // LEARNING STEPS:
            // 1. Validate the model
            // 2. Check if user already exists
            // 3. Hash the password (NEVER store plain text!)
            // 4. Create user in database
            // 5. Return success response
            
            return Ok(new { message = "Implement registration" });
        }

        // TODO: Exercise 2.5 - Implement login with JWT
        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginModel model)
        {
            // LEARNING STEPS:
            // 1. Find user by username
            // 2. Verify password hash
            // 3. Generate JWT token with claims
            // 4. Return token to client
            
            return Ok(new { message = "Implement login", token = "JWT will go here" });
        }
    }
}' \
            "Authentication controller handles user registration and login, issuing JWT tokens"
            ;;
            
        "module03-exercise03")
            # API versioning and documentation
            create_file_with_explanation "Controllers/V2/BooksController.cs" 'using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;

namespace LibraryAPI.Controllers.V2
{
    // LEARNING POINT: API Versioning
    // Allows multiple versions of your API to coexist
    [ApiController]
    [ApiVersion("2.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [Authorize]
    public class BooksController : ControllerBase
    {
        // TODO: Exercise 3.1 - Implement V2 with pagination
        // Building on V1, add pagination support
        [HttpGet]
        [SwaggerOperation(
            Summary = "Get paginated books",
            Description = "Returns books with pagination support"
        )]
        [SwaggerResponse(200, "Success", typeof(PaginatedResult<Book>))]
        [SwaggerResponse(401, "Unauthorized")]
        public async Task<IActionResult> GetBooks(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            // NEW CONCEPTS:
            // 1. Pagination prevents loading too much data
            // 2. SwaggerOperation documents your API
            // 3. Version 2 maintains backward compatibility
            
            return Ok(new { message = "Implement paginated GetBooks" });
        }
    }
}' \
            "Version 2 of the API adds new features while maintaining backward compatibility"
            ;;
    esac
}

# Function to show progression path
show_progression_path() {
    echo -e "${YELLOW}📈 Exercise Progression Path:${NC}"
    echo ""
    echo "  Module 3 - Web APIs:"
    echo "  ┌─ Exercise 1: Basic CRUD API"
    echo "  │   └─ Learn: Controllers, Routes, DbContext, Entity Framework"
    echo "  │"
    echo "  ├─ Exercise 2: Add Authentication (builds on Ex1)"
    echo "  │   └─ Learn: JWT, [Authorize], Roles, User Claims"
    echo "  │       Uses: Ex1's models and controllers"
    echo "  │"
    echo "  └─ Exercise 3: API Documentation & Versioning (builds on Ex2)"
    echo "      └─ Learn: Swagger, API Versioning, Health Checks"
    echo "          Uses: Ex2's authenticated API"
    echo ""
    echo "  Each exercise assumes you completed the previous one!"
    echo ""
}

# Function to create learning checkpoint
create_learning_checkpoint() {
    local exercise=$1
    
    create_file_with_explanation "LEARNING_CHECKPOINT.md" "# Learning Checkpoint for $exercise

## Before Starting This Exercise

### Check Your Understanding:
$(case $exercise in
    "module03-exercise01")
        echo "- [ ] Do you understand what REST means?
- [ ] Can you explain what HTTP verbs (GET, POST, PUT, DELETE) do?
- [ ] Do you know what JSON is?
- [ ] Have you used Postman or similar tools before?"
        ;;
    "module03-exercise02")
        echo "- [ ] Did you complete Exercise 1 successfully?
- [ ] Can you explain what authentication vs authorization means?
- [ ] Do you understand what a JWT token is?
- [ ] Have you tested your Exercise 1 endpoints?"
        ;;
    "module03-exercise03")
        echo "- [ ] Did you complete Exercise 2 successfully?
- [ ] Can you explain why API versioning is important?
- [ ] Do you understand what API documentation is for?
- [ ] Have you successfully authenticated with JWT?"
        ;;
esac)

## What You'll Build:
$(case $exercise in
    "module03-exercise01")
        echo "A basic library API with:
- Book management (Create, Read, Update, Delete)
- In-memory database for testing
- Swagger UI for testing endpoints
- Proper HTTP status codes"
        ;;
    "module03-exercise02")
        echo "Enhance your library API with:
- User registration and login
- JWT token authentication
- Protected endpoints
- Role-based access control"
        ;;
    "module03-exercise03")
        echo "Production-ready API with:
- Multiple API versions
- Comprehensive documentation
- Health check endpoints
- Rate limiting and monitoring"
        ;;
esac)

## Success Criteria:
$(case $exercise in
    "module03-exercise01")
        echo "1. All CRUD operations work in Swagger
2. Proper status codes (200, 201, 404, etc.)
3. Data persists during application runtime
4. You understand each line of code you wrote"
        ;;
    "module03-exercise02")
        echo "1. Users can register and login
2. JWT tokens are properly generated
3. Protected endpoints require authentication
4. Role-based endpoints work correctly"
        ;;
    "module03-exercise03")
        echo "1. Both API versions work simultaneously
2. Swagger shows comprehensive documentation
3. Health checks report API status
4. You can explain versioning strategy"
        ;;
esac)

## Need Help?
- Review the README files in each folder
- Check the inline comments marked with LEARNING POINT
- Use the validation script to check your progress
- Ask your instructor about concepts you don't understand" \
    "This checkpoint ensures you're ready for the exercise and understand what you're building"
}

# Function to create progression tracker
create_progression_tracker() {
    local exercise=$1
    
    create_file_with_explanation "PROGRESSION_TRACKER.md" "# Your Learning Progress Tracker

## Module 3 Progress:
- [ ] Exercise 1: Basic CRUD API
  - [ ] Implemented GetBooks
  - [ ] Implemented GetBook by ID  
  - [ ] Implemented CreateBook
  - [ ] Implemented UpdateBook
  - [ ] Implemented DeleteBook
  - [ ] Tested all endpoints
  
- [ ] Exercise 2: Authentication (Requires Exercise 1)
  - [ ] Copied Exercise 1 code
  - [ ] Added JWT configuration
  - [ ] Implemented Register endpoint
  - [ ] Implemented Login endpoint
  - [ ] Protected existing endpoints
  - [ ] Added role-based authorization
  
- [ ] Exercise 3: API v2 & Documentation (Requires Exercise 2)
  - [ ] Copied Exercise 2 code
  - [ ] Added API versioning
  - [ ] Created v2 controllers
  - [ ] Added Swagger annotations
  - [ ] Implemented health checks
  - [ ] Documented all endpoints

## Concepts Mastered:
- [ ] REST principles
- [ ] Dependency Injection
- [ ] Async/Await patterns
- [ ] Entity Framework basics
- [ ] JWT authentication
- [ ] Authorization attributes
- [ ] API versioning
- [ ] API documentation

## Notes:
_Write your learning notes here..._" \
    "Track your progress through the exercises and concepts you've learned"
}

# Main script starts here
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Usage: $0 <exercise-name>${NC}"
    echo ""
    show_progression_path
    exit 1
fi

EXERCISE_NAME=$1

# Determine exercise configuration
case $EXERCISE_NAME in
    "module03-exercise01")
        PROJECT_NAME="LibraryAPI"
        MODULE="Module03-Working-with-Web-APIs"
        EXERCISE_TITLE="Create Basic API"
        ;;
    "module03-exercise02")
        PROJECT_NAME="LibraryAPI"
        MODULE="Module03-Working-with-Web-APIs"
        EXERCISE_TITLE="Add Authentication & Security"
        ;;
    "module03-exercise03")
        PROJECT_NAME="LibraryAPI"
        MODULE="Module03-Working-with-Web-APIs"
        EXERCISE_TITLE="API Documentation & Versioning"
        ;;
    *)
        echo -e "${RED}❌ Unknown exercise: $EXERCISE_NAME${NC}"
        show_progression_path
        exit 1
        ;;
esac

echo -e "${MAGENTA}🚀 ASP.NET Core Training - Progressive Exercise Launcher${NC}"
echo -e "${MAGENTA}======================================================${NC}"
echo ""

# Show what exercise builds on
if [[ $EXERCISE_NAME == "module03-exercise02" ]]; then
    echo -e "${YELLOW}📚 This exercise builds on: module03-exercise01${NC}"
    echo -e "${YELLOW}   Make sure you completed Exercise 1 first!${NC}"
    echo ""
elif [[ $EXERCISE_NAME == "module03-exercise03" ]]; then
    echo -e "${YELLOW}📚 This exercise builds on: module03-exercise02${NC}"
    echo -e "${YELLOW}   Make sure you completed Exercise 2 first!${NC}"
    echo ""
fi

show_learning_objectives $EXERCISE_NAME

# Check if project already exists
if [ -d "$PROJECT_NAME" ]; then
    if [[ $EXERCISE_NAME != "module03-exercise01" ]]; then
        echo -e "${GREEN}✓ Found existing $PROJECT_NAME from previous exercise${NC}"
        echo -e "${CYAN}  This exercise will enhance your existing code${NC}"
        cd "$PROJECT_NAME"
        
        # Create progression files
        create_learning_checkpoint $EXERCISE_NAME
        create_progression_tracker $EXERCISE_NAME
        
        # Add new features based on exercise
        echo -e "${CYAN}Adding new features for $EXERCISE_TITLE...${NC}"
        create_progressive_controller $EXERCISE_NAME $PROJECT_NAME
        
        echo -e "${GREEN}✅ Exercise $EXERCISE_NAME is ready!${NC}"
        echo -e "${YELLOW}Check LEARNING_CHECKPOINT.md for your tasks${NC}"
        exit 0
    else
        echo -e "${YELLOW}⚠️  Project '$PROJECT_NAME' already exists!${NC}"
        echo -n "Do you want to start fresh? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            exit 1
        fi
        rm -rf "$PROJECT_NAME"
    fi
fi

# Create new project for Exercise 1
echo -e "${CYAN}Creating new project...${NC}"
dotnet new webapi -n "$PROJECT_NAME" --framework net8.0 > /dev/null 2>&1
cd "$PROJECT_NAME"

# Create learning files
create_learning_checkpoint $EXERCISE_NAME
create_progression_tracker $EXERCISE_NAME
create_progressive_controller $EXERCISE_NAME $PROJECT_NAME

# Create models with explanations
create_file_with_explanation "Models/Book.cs" 'namespace LibraryAPI.Models
{
    // LEARNING POINT: This is your domain model
    // It represents the data structure for a book in your system
    public class Book
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string ISBN { get; set; } = string.Empty;
        public int PublicationYear { get; set; }
        
        // TODO: Exercise 1.4 - Add Author relationship
        // public int AuthorId { get; set; }
        // public Author? Author { get; set; }
        
        // These will be useful in Exercise 2
        public DateTime CreatedAt { get; set; }
        public string? CreatedBy { get; set; }  // Track who created the book
    }
}' \
"Models define the structure of your data. They become database tables with Entity Framework."

# Create DbContext with explanations
create_file_with_explanation "Data/LibraryContext.cs" 'using Microsoft.EntityFrameworkCore;
using LibraryAPI.Models;

namespace LibraryAPI.Data
{
    // LEARNING POINT: DbContext is your database connection
    // It manages the entity objects during runtime and handles database operations
    public class LibraryContext : DbContext
    {
        public LibraryContext(DbContextOptions<LibraryContext> options)
            : base(options)
        {
        }

        // LEARNING POINT: DbSet represents a table in your database
        // You can query and save instances of Book using this property
        public DbSet<Book> Books => Set<Book>();
        
        // TODO: Exercise 1.5 - Add Authors DbSet
        // public DbSet<Author> Authors => Set<Author>();
        
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // LEARNING POINT: This method lets you configure your entities
            // You can set up relationships, indexes, and constraints here
            
            // Example: Make ISBN unique
            modelBuilder.Entity<Book>()
                .HasIndex(b => b.ISBN)
                .IsUnique();
                
            base.OnModelCreating(modelBuilder);
        }
    }
}' \
"DbContext manages database connections and tracks changes to your entities."

# Create Program.cs with learning comments
create_file_with_explanation "Program.cs" 'var builder = WebApplication.CreateBuilder(args);

// LEARNING CHECKPOINT: Service Registration
// This is where you configure all the services your application needs

// 1. Add MVC Controllers support
builder.Services.AddControllers();

// 2. Add API Explorer (required for Swagger)
builder.Services.AddEndpointsApiExplorer();

// 3. Add Swagger for API documentation
builder.Services.AddSwaggerGen();

// 4. Add Entity Framework with In-Memory Database
// LEARNING POINT: In-Memory database is perfect for learning and testing
// In production, you would use SQL Server, PostgreSQL, etc.
builder.Services.AddDbContext<LibraryAPI.Data.LibraryContext>(options =>
    options.UseInMemoryDatabase("LibraryDB"));

// TODO: Exercise 2 will add authentication here
// TODO: Exercise 3 will add versioning here

var app = builder.Build();

// LEARNING CHECKPOINT: Request Pipeline
// The order here matters! Each middleware processes requests in order

if (app.Environment.IsDevelopment())
{
    // Swagger UI only in development
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// TODO: Exercise 2 will add authentication/authorization here

app.MapControllers();

// Seed some initial data for testing
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<LibraryAPI.Data.LibraryContext>();
    
    // Add sample data if none exists
    if (!context.Books.Any())
    {
        context.Books.AddRange(
            new LibraryAPI.Models.Book 
            { 
                Title = "Clean Code", 
                ISBN = "978-0132350884", 
                PublicationYear = 2008,
                CreatedAt = DateTime.UtcNow
            },
            new LibraryAPI.Models.Book 
            { 
                Title = "The Pragmatic Programmer", 
                ISBN = "978-0201616224", 
                PublicationYear = 1999,
                CreatedAt = DateTime.UtcNow
            }
        );
        context.SaveChanges();
    }
}

app.Run();' \
"Program.cs configures services and the request pipeline. This is your application's entry point."

# Add necessary packages
echo -e "${CYAN}Installing packages...${NC}"
dotnet add package Microsoft.EntityFrameworkCore.InMemory --version 8.0.11 > /dev/null 2>&1
dotnet add package Swashbuckle.AspNetCore --version 6.8.1 > /dev/null 2>&1

# Create exercise guide
create_file_with_explanation "EXERCISE_GUIDE.md" '# Exercise Guide

## How This Exercise Works

### 1. Learning by Doing
Instead of copying code, you will:
- Read the learning comments in each file
- Understand WHY each component exists
- Implement the TODOs step by step
- Test your implementation
- Validate your understanding

### 2. File Structure Explanation
```
LibraryAPI/
├── Controllers/          # HTTP request handlers
│   ├── BooksController.cs    # Your main work area
│   └── README_CONTROLLERS.md # Concept explanation
├── Models/              # Data structures
│   └── Book.cs          # Entity model
├── Data/                # Database related
│   └── LibraryContext.cs # EF Core DbContext
├── Program.cs           # Application configuration
├── LEARNING_CHECKPOINT.md # Your current objectives
└── PROGRESSION_TRACKER.md # Track your progress
```

### 3. Implementation Order
1. Read LEARNING_CHECKPOINT.md first
2. Open Controllers/BooksController.cs
3. Implement each TODO in order
4. Test using Swagger UI
5. Move to the next TODO

### 4. Testing Your Work
```bash
# Run the application
./run-exercise.sh

# Open browser
http://localhost:5000/swagger

# Test each endpoint as you implement it
```

### 5. Getting Help
- Each file has LEARNING POINT comments
- README files explain concepts
- Validation script checks your progress
- Ask questions when stuck!

## Remember
The goal is not just to make it work, but to understand:
- WHY we structure code this way
- WHAT each component does
- HOW they work together
- WHEN to use different patterns' \
"This guide explains how to approach the exercise for maximum learning"

echo ""
echo -e "${GREEN}🎉 Exercise setup complete!${NC}"
echo ""
echo -e "${YELLOW}📋 Start Here:${NC}"
echo "1. Read ${BLUE}LEARNING_CHECKPOINT.md${NC} to understand your objectives"
echo "2. Open ${BLUE}Controllers/BooksController.cs${NC} and read the learning comments"
echo "3. Implement the TODOs one by one"
echo "4. Run ${BLUE}./run-exercise.sh${NC} to test your implementation"
echo ""
echo -e "${CYAN}💡 This is a learning experience, not a copy exercise!${NC}"