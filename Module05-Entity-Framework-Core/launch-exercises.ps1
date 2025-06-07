# Module 5 Interactive Exercise Launcher - PowerShell Version
# Entity Framework Core

param(
    [Parameter(Mandatory=$false)]
    [string]$ExerciseName,
    
    [Parameter(Mandatory=$false)]
    [switch]$List,
    
    [Parameter(Mandatory=$false)]
    [switch]$Auto,
    
    [Parameter(Mandatory=$false)]
    [switch]$Preview
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    Magenta = "Magenta"
    Cyan = "Cyan"
    White = "White"
}

# Interactive mode flag
$InteractiveMode = -not $Auto

# Function to pause and wait for user
function Wait-ForUser {
    if ($InteractiveMode) {
        Write-Host "Press Enter to continue..." -ForegroundColor Yellow
        Read-Host
    }
}

# Function to show what will be created
function Show-FilePreview {
    param(
        [string]$FilePath,
        [string]$Description
    )
    
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "[FILE] Will create: $FilePath" -ForegroundColor Blue
    Write-Host "[PURPOSE] Purpose: $Description" -ForegroundColor Yellow
    Write-Host "============================================================" -ForegroundColor Cyan
}

# Function to create file with preview
function New-FileInteractive {
    param(
        [string]$FilePath,
        [string]$Content,
        [string]$Description
    )
    
    Show-FilePreview -FilePath $FilePath -Description $Description
    
    # Show first 20 lines of content
    Write-Host "Content preview:" -ForegroundColor Green
    $ContentLines = $Content -split "`n"
    $PreviewLines = $ContentLines | Select-Object -First 20
    $PreviewLines | ForEach-Object { Write-Host $_ }
    
    if ($ContentLines.Count -gt 20) {
        Write-Host "... (content truncated for preview)" -ForegroundColor Yellow
    }
    Write-Host ""
    
    if ($InteractiveMode) {
        $Response = Read-Host "Create this file? (Y/n/s to skip all)"
        
        switch ($Response.ToLower()) {
            "n" {
                Write-Host "[SKIP]  Skipped: $FilePath" -ForegroundColor Red
                return
            }
            "s" {
                $script:InteractiveMode = $false
                Write-Host "[PIN] Switching to automatic mode..." -ForegroundColor Cyan
            }
        }
    }
    
    # Create directory if it doesn't exist
    $Directory = Split-Path -Path $FilePath -Parent
    if ($Directory -and -not (Test-Path -Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    
    # Write content to file
    $Content | Out-File -FilePath $FilePath -Encoding UTF8
    Write-Host "[OK] Created: $FilePath" -ForegroundColor Green
    Write-Host ""
}

# Function to show learning objectives
function Show-LearningObjectives {
    param([string]$Exercise)
    
    Write-Host "============================================================" -ForegroundColor Magenta
    Write-Host "[TARGET] Learning Objectives" -ForegroundColor Magenta
    Write-Host "============================================================" -ForegroundColor Magenta
    
    switch ($Exercise) {
        "exercise01" {
            Write-Host "In this exercise, you will learn:" -ForegroundColor Cyan
            Write-Host "  [LEARN] 1. Setting up Entity Framework Core with SQLite" -ForegroundColor White
            Write-Host "  [LEARN] 2. Creating entity models with data annotations" -ForegroundColor White
            Write-Host "  [LEARN] 3. Configuring DbContext with Fluent API" -ForegroundColor White
            Write-Host "  [LEARN] 4. Implementing basic CRUD operations" -ForegroundColor White
            Write-Host ""
            Write-Host "Key concepts:" -ForegroundColor Yellow
            Write-Host "  - Code-First approach with EF Core" -ForegroundColor White
            Write-Host "  - Entity relationships and navigation properties" -ForegroundColor White
            Write-Host "  - Database migrations and seeding" -ForegroundColor White
            Write-Host "  - Async/await patterns with EF Core" -ForegroundColor White
        }
        "exercise02" {
            Write-Host "Building on Exercise 1, you will add:" -ForegroundColor Cyan
            Write-Host "  [SEARCH] 1. Complex LINQ queries with navigation properties" -ForegroundColor White
            Write-Host "  [SEARCH] 2. Advanced filtering and sorting capabilities" -ForegroundColor White
            Write-Host "  [SEARCH] 3. Efficient loading strategies (Include, ThenInclude)" -ForegroundColor White
            Write-Host "  [SEARCH] 4. Query performance optimization" -ForegroundColor White
            Write-Host ""
            Write-Host "Advanced concepts:" -ForegroundColor Yellow
            Write-Host "  - LINQ query optimization" -ForegroundColor White
            Write-Host "  - Eager vs Lazy loading" -ForegroundColor White
            Write-Host "  - Query performance monitoring" -ForegroundColor White
            Write-Host "  - Database indexing strategies" -ForegroundColor White
        }
        "exercise03" {
            Write-Host "Implementing professional patterns:" -ForegroundColor Cyan
            Write-Host "  [BUILD] 1. Repository pattern implementation" -ForegroundColor White
            Write-Host "  [BUILD] 2. Unit of Work pattern" -ForegroundColor White
            Write-Host "  [BUILD] 3. Generic repository with specific implementations" -ForegroundColor White
            Write-Host "  [BUILD] 4. Dependency injection with repositories" -ForegroundColor White
            Write-Host ""
            Write-Host "Design patterns:" -ForegroundColor Yellow
            Write-Host "  - Separation of concerns" -ForegroundColor White
            Write-Host "  - Testable architecture" -ForegroundColor White
            Write-Host "  - Clean code principles" -ForegroundColor White
            Write-Host "  - SOLID principles application" -ForegroundColor White
        }
    }
    
    Write-Host "============================================================" -ForegroundColor Magenta
    Wait-ForUser
}

# Function to show what will be created overview
function Show-CreationOverview {
    param([string]$Exercise)
    
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "[OVERVIEW] Overview: What will be created" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    
    switch ($Exercise) {
        "exercise01" {
            Write-Host "[TARGET] Exercise 01: Basic EF Core Setup and CRUD Operations" -ForegroundColor Green
            Write-Host ""
            Write-Host "[OVERVIEW] What you'll build:" -ForegroundColor Yellow
            Write-Host "  [OK] BookStore API with Entity Framework Core" -ForegroundColor White
            Write-Host "  [OK] SQLite database with Code-First approach" -ForegroundColor White
            Write-Host "  [OK] Book entity with proper validation and relationships" -ForegroundColor White
            Write-Host "  [OK] Complete CRUD operations with async patterns" -ForegroundColor White
            Write-Host ""
            Write-Host "[LAUNCH] RECOMMENDED: Use the Complete Working Example" -ForegroundColor Blue
            Write-Host "  Set-Location SourceCode\EFCoreDemo; dotnet run" -ForegroundColor Cyan
            Write-Host "  Then visit: http://localhost:5000 for the demo interface" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "📁 Template Structure:" -ForegroundColor Green
            Write-Host "  EFCoreDemo/" -ForegroundColor White
            Write-Host "  ├── Controllers/" -ForegroundColor White
            Write-Host "  │   └── BooksController.cs      # CRUD API endpoints" -ForegroundColor Yellow
            Write-Host "  ├── Models/" -ForegroundColor White
            Write-Host "  │   └── Book.cs                 # Book entity model" -ForegroundColor Yellow
            Write-Host "  ├── Data/" -ForegroundColor White
            Write-Host "  │   └── BookStoreContext.cs     # EF Core DbContext" -ForegroundColor Yellow
            Write-Host "  ├── Program.cs                  # App configuration" -ForegroundColor Yellow
            Write-Host "  └── appsettings.json            # Connection strings" -ForegroundColor Yellow
        }
        "exercise02" {
            Write-Host "[TARGET] Exercise 02: Advanced Querying with LINQ" -ForegroundColor Green
            Write-Host ""
            Write-Host "[OVERVIEW] Building on Exercise 1:" -ForegroundColor Yellow
            Write-Host "  [OK] Product and Category entities with relationships" -ForegroundColor White
            Write-Host "  [OK] Complex LINQ queries with navigation properties" -ForegroundColor White
            Write-Host "  [OK] Advanced filtering, sorting, and pagination" -ForegroundColor White
            Write-Host "  [OK] Query performance optimization techniques" -ForegroundColor White
        }
        "exercise03" {
            Write-Host "[TARGET] Exercise 03: Repository Pattern Implementation" -ForegroundColor Green
            Write-Host ""
            Write-Host "[OVERVIEW] Professional architecture patterns:" -ForegroundColor Yellow
            Write-Host "  [OK] Generic repository interface and implementation" -ForegroundColor White
            Write-Host "  [OK] Specific repositories for entities" -ForegroundColor White
            Write-Host "  [OK] Unit of Work pattern for transaction management" -ForegroundColor White
            Write-Host "  [OK] Dependency injection configuration" -ForegroundColor White
        }
    }
    
    Write-Host "============================================================" -ForegroundColor Cyan
    Wait-ForUser
}

# Function to explain a concept
function Show-Concept {
    param(
        [string]$ConceptName,
        [string]$Explanation
    )
    
    Write-Host "[TIP] Concept: $ConceptName" -ForegroundColor Magenta
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host $Explanation -ForegroundColor White
    Write-Host "============================================================" -ForegroundColor Cyan
    Wait-ForUser
}

# Function to show available exercises
function Show-Exercises {
    Write-Host "Module 5 - Entity Framework Core" -ForegroundColor Cyan
    Write-Host "Available Exercises:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  - exercise01: Basic EF Core Setup and CRUD Operations" -ForegroundColor White
    Write-Host "  - exercise02: Advanced Querying with LINQ" -ForegroundColor White
    Write-Host "  - exercise03: Repository Pattern Implementation" -ForegroundColor White
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor White
    Write-Host "  .\launch-exercises.ps1 <exercise-name> [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  -List           Show all available exercises" -ForegroundColor White
    Write-Host "  -Auto           Skip interactive mode" -ForegroundColor White
    Write-Host "  -Preview        Show what will be created without creating" -ForegroundColor White
}

# Main script logic
if ($List) {
    Show-Exercises
    exit 0
}

if (-not $ExerciseName) {
    Write-Host "[ERROR] Usage: .\launch-exercises.ps1 <exercise-name> [options]" -ForegroundColor Red
    Write-Host ""
    Show-Exercises
    exit 1
}

$ProjectName = "EFCoreDemo"

# Validate exercise name
$ValidExercises = @("exercise01", "exercise02", "exercise03")
if ($ExerciseName -notin $ValidExercises) {
    Write-Host "[ERROR] Unknown exercise: $ExerciseName" -ForegroundColor Red
    Write-Host ""
    Show-Exercises
    exit 1
}

# Welcome screen
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "[LAUNCH] Module 5: Entity Framework Core" -ForegroundColor Magenta
Write-Host "Exercise: $ExerciseName" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host ""

# Show the recommended approach
Write-Host "[TARGET] RECOMMENDED APPROACH:" -ForegroundColor Green
Write-Host "For the best learning experience, use the complete working implementation:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Use the working source code:" -ForegroundColor Yellow
Write-Host "   Set-Location SourceCode\EFCoreDemo" -ForegroundColor Cyan
Write-Host "   dotnet run" -ForegroundColor Cyan
Write-Host "   # Visit: http://localhost:5000 for the demo interface" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Or use Docker for database setup:" -ForegroundColor Yellow
Write-Host "   Set-Location SourceCode" -ForegroundColor Cyan
Write-Host "   docker-compose up --build" -ForegroundColor Cyan
Write-Host "   # Includes SQLite database and demo application" -ForegroundColor Cyan
Write-Host ""
Write-Host "[WARNING]  The template created by this script is basic and may not match" -ForegroundColor Yellow
Write-Host "   all exercise requirements. The SourceCode version is complete!" -ForegroundColor Yellow
Write-Host ""

if ($InteractiveMode) {
    Write-Host "[INTERACTIVE] Interactive Mode: ON" -ForegroundColor Yellow
    Write-Host "You'll see what each file does before it's created" -ForegroundColor Cyan
} else {
    Write-Host "[AUTO] Automatic Mode: ON" -ForegroundColor Yellow
}

Write-Host ""
$Response = Read-Host "Continue with template creation? (y/N)"
if ($Response -notmatch "^[Yy]$") {
    Write-Host "[TIP] Great choice! Use the SourceCode version for the best experience." -ForegroundColor Cyan
    exit 0
}

# Show learning objectives
Show-LearningObjectives -Exercise $ExerciseName

# Show creation overview
Show-CreationOverview -Exercise $ExerciseName

if ($Preview) {
    Write-Host "Preview mode - no files will be created" -ForegroundColor Yellow
    exit 0
}

# Check if project exists in current directory
$SkipProjectCreation = $false
if (Test-Path -Path $ProjectName) {
    if ($ExerciseName -in @("exercise02", "exercise03")) {
        Write-Host "✓ Found existing $ProjectName from previous exercise" -ForegroundColor Green
        Write-Host "This exercise will build on your existing work" -ForegroundColor Cyan
        Set-Location -Path $ProjectName
        $SkipProjectCreation = $true
    } else {
        Write-Host "[WARNING]  Project '$ProjectName' already exists!" -ForegroundColor Yellow
        $Response = Read-Host "Do you want to overwrite it? (y/N)"
        if ($Response -notmatch "^[Yy]$") {
            exit 1
        }
        Remove-Item -Path $ProjectName -Recurse -Force
        $SkipProjectCreation = $false
    }
} else {
    $SkipProjectCreation = $false
}

# Exercise-specific implementation
if ($ExerciseName -eq "exercise01") {
    # Exercise 1: Basic EF Core Setup

    Show-Concept -ConceptName "Entity Framework Core" -Explanation @"
Entity Framework Core is a lightweight, extensible ORM for .NET:
- Code-First approach: Define models in C#, generate database
- DbContext: Represents a session with the database
- DbSet<T>: Represents a table in the database
- Migrations: Version control for your database schema
- LINQ: Query your database using C# syntax
"@

    if (-not $SkipProjectCreation) {
        Write-Host "Creating new Web API project..." -ForegroundColor Cyan
        dotnet new webapi -n $ProjectName --framework net8.0
        Set-Location -Path $ProjectName
        Remove-Item -Path "WeatherForecast.cs" -ErrorAction SilentlyContinue
        Remove-Item -Path "Controllers\WeatherForecastController.cs" -ErrorAction SilentlyContinue

        # Install EF Core packages
        Write-Host "Installing Entity Framework Core packages..." -ForegroundColor Cyan
        dotnet add package Microsoft.EntityFrameworkCore.Sqlite
        dotnet add package Microsoft.EntityFrameworkCore.Tools
        dotnet add package Microsoft.EntityFrameworkCore.Design

        # Update Program.cs with EF Core configuration
        $ProgramContent = @'
using Microsoft.EntityFrameworkCore;
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

app.Run();
'@

        New-FileInteractive -FilePath "Program.cs" -Content $ProgramContent -Description "Program.cs with Entity Framework Core and SQLite configuration"
    }

    Show-Concept -ConceptName "Entity Models" -Explanation @"
Entity models represent your database tables:
- Properties become database columns
- Data annotations provide validation and constraints
- Navigation properties define relationships
- Fluent API in DbContext provides advanced configuration
"@

    # Create Book entity model
    $BookModelContent = @'
using System.ComponentModel.DataAnnotations;
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
}
'@

    New-FileInteractive -FilePath "Models\Book.cs" -Content $BookModelContent -Description "Book entity model with data annotations, validation, and navigation properties"

    # Create Author entity
    $AuthorModelContent = @'
using System.ComponentModel.DataAnnotations;
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
}
'@

    New-FileInteractive -FilePath "Models\Author.cs" -Content $AuthorModelContent -Description "Author entity with navigation properties for many-to-many relationship"

    # Create Publisher entity
    $PublisherModelContent = @'
using System.ComponentModel.DataAnnotations;
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
}
'@

    New-FileInteractive -FilePath "Models\Publisher.cs" -Content $PublisherModelContent -Description "Publisher entity with one-to-many relationship to books"

    # Create BookAuthor junction entity
    $BookAuthorModelContent = @'
using System.Text.Json.Serialization;

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
}
'@

    New-FileInteractive -FilePath "Models\BookAuthor.cs" -Content $BookAuthorModelContent -Description "Junction entity for many-to-many relationship between Books and Authors"

    Show-Concept -ConceptName "DbContext Configuration" -Explanation @"
DbContext is the bridge between your entities and database:
- Represents a session with the database
- DbSet<T> properties represent tables
- OnModelCreating() configures entities using Fluent API
- Handles change tracking and saves changes
"@

    # Create BookStoreContext
    $DbContextContent = @'
using Microsoft.EntityFrameworkCore;
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
}
'@

    New-FileInteractive -FilePath "Data\BookStoreContext.cs" -Content $DbContextContent -Description "BookStoreContext with Fluent API configuration and seed data"

    # Create appsettings.json
    $AppSettingsContent = @'
{
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
}
'@

    New-FileInteractive -FilePath "appsettings.json" -Content $AppSettingsContent -Description "Configuration file with SQLite connection string and EF Core logging"

    Show-Concept -ConceptName "CRUD Operations with EF Core" -Explanation @"
CRUD operations using Entity Framework Core:
- Create: Add entities to DbSet, call SaveChangesAsync()
- Read: Use LINQ queries on DbSet properties
- Update: Modify tracked entities, call SaveChangesAsync()
- Delete: Remove entities from DbSet, call SaveChangesAsync()
- Always use async methods for database operations
"@

    # First, add DTOs for the PowerShell script
    $BookDtoContent = @'
using System.ComponentModel.DataAnnotations;

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
public class CreateBookDto
{
    [Required(ErrorMessage = "Title is required")]
    [StringLength(200, ErrorMessage = "Title cannot exceed 200 characters")]
    public string Title { get; set; } = string.Empty;

    [Required(ErrorMessage = "Author is required")]
    [StringLength(100, ErrorMessage = "Author name cannot exceed 100 characters")]
    public string Author { get; set; } = string.Empty;

    [Required(ErrorMessage = "ISBN is required")]
    [StringLength(20, ErrorMessage = "ISBN cannot exceed 20 characters")]
    public string ISBN { get; set; } = string.Empty;

    [Range(0.01, 9999.99, ErrorMessage = "Price must be between 0.01 and 9999.99")]
    public decimal Price { get; set; }

    [Required(ErrorMessage = "Published date is required")]
    public DateTime PublishedDate { get; set; }

    public bool IsAvailable { get; set; } = true;

    public int? PublisherId { get; set; }
}

/// <summary>
/// Update Book DTO for API requests
/// </summary>
public class UpdateBookDto
{
    [Required(ErrorMessage = "Title is required")]
    [StringLength(200, ErrorMessage = "Title cannot exceed 200 characters")]
    public string Title { get; set; } = string.Empty;

    [Required(ErrorMessage = "Author is required")]
    [StringLength(100, ErrorMessage = "Author name cannot exceed 100 characters")]
    public string Author { get; set; } = string.Empty;

    [Required(ErrorMessage = "ISBN is required")]
    [StringLength(20, ErrorMessage = "ISBN cannot exceed 20 characters")]
    public string ISBN { get; set; } = string.Empty;

    [Range(0.01, 9999.99, ErrorMessage = "Price must be between 0.01 and 9999.99")]
    public decimal Price { get; set; }

    [Required(ErrorMessage = "Published date is required")]
    public DateTime PublishedDate { get; set; }

    public bool IsAvailable { get; set; }

    public int? PublisherId { get; set; }
}
'@

    New-FileInteractive -FilePath "Models\DTOs\BookDto.cs" -Content $BookDtoContent -Description "DTOs for API requests and responses to avoid circular references"

    # Create BooksController
    $BooksControllerContent = @'
using Microsoft.AspNetCore.Mvc;
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
    [HttpPost]
    public async Task<ActionResult<BookDto>> CreateBook(CreateBookDto createBookDto)
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
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateBook(int id, UpdateBookDto updateBookDto)
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
}
'@

    New-FileInteractive -FilePath "Controllers\BooksController.cs" -Content $BooksControllerContent -Description "BooksController with complete CRUD operations using DTOs to avoid circular references"

    # Create exercise guide
    $ExerciseGuideContent = @'
# Exercise 1: Basic EF Core Setup and CRUD Operations

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

## ✅ Success Criteria
- [ ] Entity Framework Core is properly configured
- [ ] Book entity is created with validation
- [ ] DbContext is configured with Fluent API
- [ ] Database is created with seed data
- [ ] All CRUD endpoints are working
- [ ] Proper error handling is implemented

## 🔧 Testing Your Implementation
1. Run: `dotnet run`
2. Navigate to: http://localhost:5000/swagger
3. Test each endpoint with sample data

## 🎯 Learning Outcomes
After completing this exercise, you should understand:
- How to set up Entity Framework Core in ASP.NET Core
- Entity configuration using data annotations and Fluent API
- Creating and configuring DbContext
- Implementing basic CRUD operations
- Database seeding strategies
- Handling database connections and migrations
'@

    New-FileInteractive -FilePath "EXERCISE_GUIDE.md" -Content $ExerciseGuideContent -Description "Complete exercise guide with implementation steps"

    Write-Host "🎉 Exercise 1 template created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "[OVERVIEW] Next steps:" -ForegroundColor Yellow
    Write-Host "1. Run: dotnet ef migrations add InitialCreate" -ForegroundColor Cyan
    Write-Host "2. Run: dotnet ef database update" -ForegroundColor Cyan
    Write-Host "3. Run: dotnet run" -ForegroundColor Cyan
    Write-Host "4. Visit: http://localhost:5000/swagger" -ForegroundColor Cyan
    Write-Host "5. Follow the EXERCISE_GUIDE.md for implementation steps" -ForegroundColor White

} elseif ($ExerciseName -eq "exercise02") {
    if (-not $SkipProjectCreation) {
        Write-Host "[ERROR] Exercise 2 requires Exercise 1 to be completed first!" -ForegroundColor Red
        Write-Host "Please run: .\launch-exercises.ps1 exercise01" -ForegroundColor Cyan
        exit 1
    }

    Show-Concept -ConceptName "Advanced LINQ Queries" -Explanation @"
Advanced LINQ with Entity Framework Core:
- Navigation Properties: Define relationships between entities
- Include() and ThenInclude(): Eager loading of related data
- Complex Joins: Multi-table queries with proper relationships
- Aggregation: Count, Sum, Average, Min, Max operations
- Grouping: Group data and calculate statistics
- Projection: Select specific fields for performance
"@

    # Note: Author, Publisher, and BookAuthor entities are already created in Exercise 1

    # Create BookQueryService
    $BookQueryServiceContent = @'
using EFCoreDemo.Data;
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

    // TODO: Implement advanced LINQ query methods
    public async Task<IEnumerable<Book>> GetBooksWithPublisherAsync()
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Where(b => b.IsAvailable)
            .ToListAsync();
    }

    public async Task<IEnumerable<Book>> GetBooksByAuthorAsync(int authorId)
    {
        return await _context.Books
            .Include(b => b.BookAuthors)
            .ThenInclude(ba => ba.Author)
            .Where(b => b.BookAuthors.Any(ba => ba.AuthorId == authorId))
            .ToListAsync();
    }
}
'@

    New-FileInteractive -FilePath "Services\BookQueryService.cs" -Content $BookQueryServiceContent -Description "BookQueryService with advanced LINQ query implementations"

    Write-Host "🎉 Exercise 2 template created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "[OVERVIEW] Next steps:" -ForegroundColor Yellow
    Write-Host "1. Register BookQueryService in Program.cs" -ForegroundColor White
    Write-Host "2. Run: dotnet ef migrations add AddAuthorPublisherRelationships" -ForegroundColor Cyan
    Write-Host "3. Run: dotnet ef database update" -ForegroundColor Cyan
    Write-Host "4. Run: dotnet run" -ForegroundColor Cyan
    Write-Host "5. Test advanced LINQ queries through API endpoints" -ForegroundColor White

} elseif ($ExerciseName -eq "exercise03") {
    Write-Host "[TIP] Great choice! Use the SourceCode version for the best experience." -ForegroundColor Cyan
}

Write-Host ""
Write-Host "[OK] Module 5 Exercise Setup Complete!" -ForegroundColor Green
Write-Host "Happy coding! 🚀" -ForegroundColor Cyan
