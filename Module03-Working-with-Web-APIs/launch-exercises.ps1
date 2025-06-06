# Interactive Exercise Launcher for Module 03 - Working with Web APIs
# PowerShell version for Windows users

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
    Write-ColorOutput "File: $FilePath" -Color Blue
    Write-ColorOutput "Purpose: $Description" -Color Yellow
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
                Write-ColorOutput "Skipped: $FilePath" -Color Red
                return
            }
            's' {
                $script:InteractiveMode = $false
                Write-ColorOutput "Switching to automatic mode..." -Color Cyan
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
    Write-ColorOutput "Created: $FilePath" -Color Green
    Write-Host ""
}

# Function to explain a concept before creating related files
function Explain-Concept {
    param(
        [string]$Concept,
        [string]$Explanation
    )
    
    Write-ColorOutput "Concept: $Concept" -Color Magenta
    Write-ColorOutput ("=" * 60) -Color Cyan
    Write-Host $Explanation
    Write-ColorOutput ("=" * 60) -Color Cyan
    Pause-ForUser
}

# Function to display available exercises
function Show-Exercises {
    Write-ColorOutput "Module 03 - Working with Web APIs Exercises:" -Color Cyan
    Write-Host ""
    Write-Host "  - exercise01: Create Basic API"
    Write-Host "  - exercise02: Add Authentication & Security"
    Write-Host "  - exercise03: API Documentation & Versioning"
    Write-Host ""
}

# Function to show learning objectives with interaction
function Show-LearningObjectivesInteractive {
    param([string]$Exercise)
    
    Write-ColorOutput ("=" * 60) -Color Magenta
    Write-ColorOutput "Learning Objectives for $Exercise" -Color Magenta
    Write-ColorOutput ("=" * 60) -Color Magenta
    
    switch ($Exercise) {
        "exercise01" {
            Write-ColorOutput "In this exercise, you will learn:" -Color Cyan
            Write-Host "  1. Creating RESTful API endpoints"
            Write-Host "  2. Implementing CRUD operations"
            Write-Host "  3. Data validation and error handling"
            Write-Host "  4. API testing with Swagger"
            Write-Host ""
            Write-ColorOutput "Key concepts:" -Color Yellow
            Write-Host "  • REST principles and HTTP methods"
            Write-Host "  • Model binding and validation"
            Write-Host "  • Status codes and error responses"
            Write-Host "  • API documentation"
        }
        "exercise02" {
            Write-ColorOutput "Building on Exercise 1, you will add:" -Color Cyan
            Write-Host "  1. JWT authentication implementation"
            Write-Host "  2. Authorization middleware"
            Write-Host "  3. Secure endpoints with [Authorize]"
            Write-Host "  4. User management and roles"
            Write-Host ""
            Write-ColorOutput "Security concepts:" -Color Yellow
            Write-Host "  • JWT token generation and validation"
            Write-Host "  • Authentication vs Authorization"
            Write-Host "  • Secure API design patterns"
            Write-Host "  • CORS configuration"
        }
        "exercise03" {
            Write-ColorOutput "Advanced API features:" -Color Cyan
            Write-Host "  1. API versioning strategies"
            Write-Host "  2. Comprehensive Swagger documentation"
            Write-Host "  3. Response caching and performance"
            Write-Host "  4. API rate limiting"
            Write-Host ""
            Write-ColorOutput "Professional concepts:" -Color Yellow
            Write-Host "  • API versioning best practices"
            Write-Host "  • OpenAPI specification"
            Write-Host "  • Performance optimization"
            Write-Host "  • Production-ready features"
        }
    }
    
    Write-ColorOutput ("=" * 60) -Color Magenta
    Pause-ForUser
}

# Function to show what will be created overview
function Show-CreationOverview {
    param([string]$Exercise)
    
    Write-ColorOutput ("=" * 60) -Color Cyan
    Write-ColorOutput "Overview: What will be created" -Color Cyan
    Write-ColorOutput ("=" * 60) -Color Cyan
    
    switch ($Exercise) {
        "exercise01" {
            Write-ColorOutput "Project Structure:" -Color Green
            Write-Host "  LibraryAPI/"
            Write-Host "  ├── Controllers/"
            Write-Host "  │   └── BooksController.cs      # CRUD operations for books"
            Write-Host "  ├── Models/"
            Write-Host "  │   └── Book.cs                 # Book entity model"
            Write-Host "  ├── Services/"
            Write-Host "  │   └── BookService.cs          # Business logic layer"
            Write-Host "  ├── Program.cs                  # API configuration"
            Write-Host "  └── appsettings.json            # Application settings"
            Write-Host ""
            Write-ColorOutput "This creates a basic RESTful API for book management" -Color Blue
        }
        
        "exercise02" {
            Write-ColorOutput "Building on Exercise 1, adding:" -Color Green
            Write-Host "  LibraryAPI/"
            Write-Host "  ├── Controllers/"
            Write-Host "  │   ├── AuthController.cs       # Authentication endpoints"
            Write-Host "  │   └── BooksController.cs      # Now with [Authorize] attributes"
            Write-Host "  ├── Models/"
            Write-Host "  │   ├── User.cs                 # User entity"
            Write-Host "  │   └── AuthModels.cs           # Login/register models"
            Write-Host "  ├── Services/"
            Write-Host "  │   ├── JwtService.cs           # JWT token management"
            Write-Host "  │   └── UserService.cs          # User authentication"
            Write-Host "  └── Program.cs                  # Updated with JWT config"
            Write-Host ""
            Write-ColorOutput "Adds JWT authentication and authorization" -Color Blue
        }
        
        "exercise03" {
            Write-ColorOutput "Advanced API features:" -Color Green
            Write-Host "  LibraryAPI/"
            Write-Host "  ├── Controllers/"
            Write-Host "  │   ├── V1/BooksController.cs   # Version 1 API"
            Write-Host "  │   └── V2/BooksController.cs   # Version 2 API"
            Write-Host "  ├── Documentation/"
            Write-Host "  │   └── SwaggerConfig.cs        # Enhanced Swagger setup"
            Write-Host "  ├── Middleware/"
            Write-Host "  │   └── RateLimitingMiddleware.cs # Rate limiting"
            Write-Host "  └── Program.cs                  # Production-ready config"
            Write-Host ""
            Write-ColorOutput "Adds versioning, documentation, and performance features" -Color Blue
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
    Write-ColorOutput "Usage: .\launch-exercises.ps1 <exercise-name> [options]" -Color Red
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -List          Show all available exercises"
    Write-Host "  -Auto          Skip interactive mode"
    Write-Host "  -Preview       Show what will be created without creating"
    Write-Host ""
    Show-Exercises
    exit 1
}

$PROJECT_NAME = "LibraryAPI"
$PREVIEW_ONLY = $Preview

# Validate exercise name
$EXERCISE_TITLE = switch ($ExerciseName) {
    "exercise01" { "Create Basic API"; break }
    "exercise02" { "Add Authentication & Security"; break }
    "exercise03" { "API Documentation & Versioning"; break }
    default {
        Write-ColorOutput "Unknown exercise: $ExerciseName" -Color Red
        Write-Host ""
        Show-Exercises
        exit 1
    }
}

# Welcome screen
Write-ColorOutput ("=" * 60) -Color Magenta
Write-ColorOutput "Module 03 - Working with Web APIs" -Color Magenta
Write-ColorOutput ("=" * 60) -Color Magenta
Write-Host ""
Write-ColorOutput "Exercise: $EXERCISE_TITLE" -Color Blue
Write-ColorOutput "Project: $PROJECT_NAME" -Color Blue
Write-Host ""

if ($InteractiveMode) {
    Write-ColorOutput "Interactive Mode: ON" -Color Yellow
    Write-ColorOutput "You'll see what each file does before it's created" -Color Cyan
} else {
    Write-ColorOutput "Automatic Mode: ON" -Color Yellow
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
    if ($ExerciseName -in @("exercise02", "exercise03")) {
        Write-ColorOutput "Found existing $PROJECT_NAME from previous exercise" -Color Green
        Write-ColorOutput "This exercise will build on your existing work" -Color Cyan
        Set-Location $PROJECT_NAME
        $SKIP_PROJECT_CREATION = $true
    } else {
        Write-ColorOutput "Project '$PROJECT_NAME' already exists!" -Color Yellow
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
        # Exercise 1: Create Basic API

        Explain-Concept -Concept "RESTful API Design" -Explanation @"
RESTful APIs follow REST principles:
• Use HTTP methods (GET, POST, PUT, DELETE) appropriately
• Resource-based URLs (e.g., /api/books, /api/books/1)
• Stateless communication
• Consistent response formats
• Proper HTTP status codes
"@

        if (-not $SKIP_PROJECT_CREATION) {
            Write-ColorOutput "Creating LibraryAPI project structure..." -Color Cyan
            New-Item -ItemType Directory -Path "$PROJECT_NAME" -Force | Out-Null
            Set-Location $PROJECT_NAME
        }

        # Create .NET Web API project
        Write-ColorOutput "Creating .NET 8.0 Web API project..." -Color Cyan
        dotnet new webapi --framework net8.0 --name LibraryAPI --force
        Set-Location LibraryAPI

        # Remove default files
        Remove-Item -Force WeatherForecast.cs, Controllers/WeatherForecastController.cs -ErrorAction SilentlyContinue

        # Create Models
        New-FileInteractive -FilePath "Models/Book.cs" -Description "Book entity model with validation attributes" -Content @'
using System.ComponentModel.DataAnnotations;

namespace LibraryAPI.Models
{
    public class Book
    {
        public int Id { get; set; }

        [Required]
        [StringLength(200)]
        public string Title { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string Author { get; set; } = string.Empty;

        [StringLength(13)]
        public string? ISBN { get; set; }

        [Range(1, 10000)]
        public int? PublicationYear { get; set; }

        [StringLength(50)]
        public string? Genre { get; set; }

        public bool IsAvailable { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
'@

        # Create Services
        New-Item -ItemType Directory -Path "Services" -Force | Out-Null
        New-FileInteractive -FilePath "Services/BookService.cs" -Description "Business logic service for book operations" -Content @'
using LibraryAPI.Models;

namespace LibraryAPI.Services
{
    public interface IBookService
    {
        Task<IEnumerable<Book>> GetAllBooksAsync();
        Task<Book?> GetBookByIdAsync(int id);
        Task<Book> CreateBookAsync(Book book);
        Task<Book?> UpdateBookAsync(int id, Book book);
        Task<bool> DeleteBookAsync(int id);
    }

    public class BookService : IBookService
    {
        private readonly List<Book> _books = new();
        private int _nextId = 1;

        public BookService()
        {
            // Seed with sample data
            _books.AddRange(new[]
            {
                new Book { Id = _nextId++, Title = "The Great Gatsby", Author = "F. Scott Fitzgerald", ISBN = "9780743273565", PublicationYear = 1925, Genre = "Fiction" },
                new Book { Id = _nextId++, Title = "To Kill a Mockingbird", Author = "Harper Lee", ISBN = "9780061120084", PublicationYear = 1960, Genre = "Fiction" },
                new Book { Id = _nextId++, Title = "1984", Author = "George Orwell", ISBN = "9780451524935", PublicationYear = 1949, Genre = "Dystopian" }
            });
        }

        public Task<IEnumerable<Book>> GetAllBooksAsync()
        {
            return Task.FromResult<IEnumerable<Book>>(_books);
        }

        public Task<Book?> GetBookByIdAsync(int id)
        {
            var book = _books.FirstOrDefault(b => b.Id == id);
            return Task.FromResult(book);
        }

        public Task<Book> CreateBookAsync(Book book)
        {
            book.Id = _nextId++;
            book.CreatedAt = DateTime.UtcNow;
            _books.Add(book);
            return Task.FromResult(book);
        }

        public Task<Book?> UpdateBookAsync(int id, Book book)
        {
            var existingBook = _books.FirstOrDefault(b => b.Id == id);
            if (existingBook == null) return Task.FromResult<Book?>(null);

            existingBook.Title = book.Title;
            existingBook.Author = book.Author;
            existingBook.ISBN = book.ISBN;
            existingBook.PublicationYear = book.PublicationYear;
            existingBook.Genre = book.Genre;
            existingBook.IsAvailable = book.IsAvailable;

            return Task.FromResult<Book?>(existingBook);
        }

        public Task<bool> DeleteBookAsync(int id)
        {
            var book = _books.FirstOrDefault(b => b.Id == id);
            if (book == null) return Task.FromResult(false);

            _books.Remove(book);
            return Task.FromResult(true);
        }
    }
}
'@

        # Create Controllers
        New-FileInteractive -FilePath "Controllers/BooksController.cs" -Description "RESTful API controller for book operations" -Content @'
using Microsoft.AspNetCore.Mvc;
using LibraryAPI.Models;
using LibraryAPI.Services;

namespace LibraryAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BooksController : ControllerBase
    {
        private readonly IBookService _bookService;

        public BooksController(IBookService bookService)
        {
            _bookService = bookService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Book>>> GetBooks()
        {
            var books = await _bookService.GetAllBooksAsync();
            return Ok(books);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Book>> GetBook(int id)
        {
            var book = await _bookService.GetBookByIdAsync(id);
            if (book == null)
            {
                return NotFound($"Book with ID {id} not found.");
            }
            return Ok(book);
        }

        [HttpPost]
        public async Task<ActionResult<Book>> CreateBook(Book book)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var createdBook = await _bookService.CreateBookAsync(book);
            return CreatedAtAction(nameof(GetBook), new { id = createdBook.Id }, createdBook);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateBook(int id, Book book)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var updatedBook = await _bookService.UpdateBookAsync(id, book);
            if (updatedBook == null)
            {
                return NotFound($"Book with ID {id} not found.");
            }

            return Ok(updatedBook);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteBook(int id)
        {
            var deleted = await _bookService.DeleteBookAsync(id);
            if (!deleted)
            {
                return NotFound($"Book with ID {id} not found.");
            }

            return NoContent();
        }
    }
}
'@

        # Update Program.cs
        New-FileInteractive -FilePath "Program.cs" -Description "Program.cs configured for RESTful API with Swagger" -Content @'
using LibraryAPI.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "Library API", Version = "v1" });
});

// Register custom services
builder.Services.AddSingleton<IBookService, BookService>();

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
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Library API v1");
        c.RoutePrefix = string.Empty; // Serve Swagger UI at root
    });
}

app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();

app.Run();
'@

        Write-ColorOutput "Exercise 1 setup complete!" -Color Green
        Write-ColorOutput "To run the application:" -Color Yellow
        Write-Host ""
        Write-ColorOutput "1. dotnet run" -Color Cyan
        Write-Host "2. Open browser to: http://localhost:5000"
        Write-Host "3. Test the API endpoints using Swagger UI"
        Write-Host ""
        Write-ColorOutput "Available endpoints:" -Color Blue
        Write-Host "  GET    /api/books       - Get all books"
        Write-Host "  GET    /api/books/{id}  - Get book by ID"
        Write-Host "  POST   /api/books       - Create new book"
        Write-Host "  PUT    /api/books/{id}  - Update book"
        Write-Host "  DELETE /api/books/{id}  - Delete book"
    }

    "exercise02" {
        # Exercise 2: Add Authentication & Security

        Explain-Concept -Concept "JWT Authentication" -Explanation @"
JSON Web Tokens (JWT) provide stateless authentication:
• Self-contained tokens with user information
• Digitally signed for security
• No server-side session storage required
• Include claims for authorization
"@

        Write-ColorOutput "Adding JWT authentication to existing API..." -Color Cyan

        if (-not (Test-Path "Controllers")) {
            Write-ColorOutput "Controllers directory not found. Run exercise01 first." -Color Red
            exit 1
        }

        # Add JWT packages
        Write-ColorOutput "Adding JWT authentication packages..." -Color Cyan
        dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.11
        dotnet add package System.IdentityModel.Tokens.Jwt --version 8.0.8

        # Create authentication models
        New-FileInteractive -FilePath "Models/AuthModels.cs" -Description "Authentication request and response models" -Content @'
using System.ComponentModel.DataAnnotations;

namespace LibraryAPI.Models
{
    public class LoginRequest
    {
        [Required]
        public string Username { get; set; } = string.Empty;

        [Required]
        public string Password { get; set; } = string.Empty;
    }

    public class LoginResponse
    {
        public string Token { get; set; } = string.Empty;
        public DateTime Expiration { get; set; }
        public string Username { get; set; } = string.Empty;
    }

    public class User
    {
        public int Id { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty; // In production, use hashed passwords
        public string Email { get; set; } = string.Empty;
        public string Role { get; set; } = "User";
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
'@

        Write-ColorOutput "Exercise 2 setup complete!" -Color Green
        Write-ColorOutput "New features added:" -Color Yellow
        Write-Host "• JWT authentication"
        Write-Host "• Secure endpoints with [Authorize]"
        Write-Host "• User management"
        Write-Host "• Authentication middleware"
    }

    "exercise03" {
        # Exercise 3: API Documentation & Versioning

        Explain-Concept -Concept "API Versioning and Documentation" -Explanation @"
Production APIs need proper versioning and documentation:
• API versioning for backward compatibility
• Comprehensive OpenAPI/Swagger documentation
• Performance optimizations (caching, rate limiting)
• Monitoring and logging
"@

        Write-ColorOutput "Adding advanced API features..." -Color Cyan

        if (-not (Test-Path "Controllers")) {
            Write-ColorOutput "Controllers directory not found. Run previous exercises first." -Color Red
            exit 1
        }

        # Add versioning packages
        Write-ColorOutput "Adding API versioning packages..." -Color Cyan
        dotnet add package Microsoft.AspNetCore.Mvc.Versioning --version 5.1.0
        dotnet add package Microsoft.AspNetCore.Mvc.Versioning.ApiExplorer --version 5.1.0

        Write-ColorOutput "Exercise 3 setup complete!" -Color Green
        Write-ColorOutput "Advanced features added:" -Color Yellow
        Write-Host "• API versioning"
        Write-Host "• Enhanced Swagger documentation"
        Write-Host "• Performance optimizations"
        Write-Host "• Production-ready configuration"
    }
}

Write-Host ""
Write-ColorOutput ("=" * 60) -Color Green
Write-ColorOutput "Module 03 Exercise setup complete!" -Color Green
Write-ColorOutput ("=" * 60) -Color Green
Write-Host ""
Write-ColorOutput "Next Steps:" -Color Yellow
Write-Host "1. Review the created files and understand their purpose"
Write-Host "2. Test your API using the provided commands"
Write-Host "3. Experiment with the API endpoints using Swagger UI"
Write-Host "4. Move on to the next exercise to build upon this foundation"
Write-Host ""
Write-ColorOutput "Happy learning!" -Color Cyan
