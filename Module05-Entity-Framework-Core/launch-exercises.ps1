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

    public async Task<IEnumerable<object>> GetAuthorsWithBookCountAsync()
    {
        return await _context.Authors
            .Select(a => new
            {
                Id = a.Id,
                Name = $"{a.FirstName} {a.LastName}",
                BookCount = a.BookAuthors.Count()
            })
            .ToListAsync();
    }

    public async Task<IEnumerable<Book>> SearchBooksAsync(string searchTerm)
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Include(b => b.BookAuthors)
            .ThenInclude(ba => ba.Author)
            .Where(b => b.Title.Contains(searchTerm) ||
                       b.Author.Contains(searchTerm) ||
                       b.ISBN.Contains(searchTerm) ||
                       (b.Publisher != null && b.Publisher.Name.Contains(searchTerm)))
            .ToListAsync();
    }
}
'@

    New-FileInteractive -FilePath "Services\BookQueryService.cs" -Content $BookQueryServiceContent -Description "BookQueryService with advanced LINQ query implementations"

    # Create QueryTestController to expose LINQ queries as API endpoints
    $QueryTestControllerContent = @'
using EFCoreDemo.Services;
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
            var result = await _queryService.GetBooksWithPublisherAsync();
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
}
'@

    New-FileInteractive -FilePath "Controllers\QueryTestController.cs" -Content $QueryTestControllerContent -Description "QueryTestController to expose BookQueryService methods as API endpoints"

    # Update Program.cs to register BookQueryService
    Write-Host "Updating Program.cs to register BookQueryService..." -ForegroundColor Cyan
    if (Test-Path -Path "Program.cs") {
        # Uncomment the BookQueryService registration using PowerShell
        $ProgramContent = Get-Content -Path "Program.cs" -Raw
        $UpdatedContent = $ProgramContent -replace '// builder\.Services\.AddScoped<EFCoreDemo\.Services\.BookQueryService>\(\);', 'builder.Services.AddScoped<EFCoreDemo.Services.BookQueryService>();'
        $UpdatedContent | Out-File -FilePath "Program.cs" -Encoding UTF8

        # Verify the change was made
        if (Select-String -Path "Program.cs" -Pattern "^builder\.Services\.AddScoped<EFCoreDemo\.Services\.BookQueryService>\(\);" -Quiet) {
            Write-Host "✅ Updated Program.cs with BookQueryService registration" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Manual registration may be needed - check Program.cs" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Program.cs not found - please register BookQueryService manually" -ForegroundColor Red
    }

    Write-Host "🎉 Exercise 2 template created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "[OVERVIEW] Next steps:" -ForegroundColor Yellow
    Write-Host "1. BookQueryService automatically registered ✅" -ForegroundColor White
    Write-Host "2. Run: dotnet ef migrations add AddAuthorPublisherRelationships" -ForegroundColor Cyan
    Write-Host "3. Run: dotnet ef database update" -ForegroundColor Cyan
    Write-Host "4. Run: dotnet run" -ForegroundColor Cyan
    Write-Host "5. Test QueryTest endpoints in Swagger: /api/querytest/books-with-publishers" -ForegroundColor White
    Write-Host "6. Follow the EXERCISE_02_GUIDE.md for implementation steps" -ForegroundColor White

} elseif ($ExerciseName -eq "exercise03") {
    # Exercise 3: Repository Pattern Implementation
    
    if (-not $SkipProjectCreation) {
        Write-Host "[ERROR] Exercise 3 requires Exercise 1 to be completed first!" -ForegroundColor Red
        Write-Host "Please run: .\launch-exercises.ps1 exercise01" -ForegroundColor Cyan
        exit 1
    }

    Show-Concept -ConceptName "Repository Pattern" -Explanation @"
Repository Pattern provides an abstraction layer between your business logic and data access:
- Encapsulates data access logic in repository classes
- Makes code more testable by allowing easy mocking
- Provides a consistent interface for data operations
- Enables switching data sources without changing business logic
- Centralizes query logic for reusability
"@

    # Create Repositories folder
    if (-not (Test-Path -Path "Repositories")) {
        New-Item -ItemType Directory -Path "Repositories" -Force | Out-Null
    }

    # Create IRepository interface
    $IRepositoryContent = @'
using System.Linq.Expressions;

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
}
'@

    New-FileInteractive -FilePath "Repositories\IRepository.cs" -Content $IRepositoryContent -Description "Generic repository interface defining common data access operations"

    # Create Repository base implementation
    $RepositoryContent = @'
using System.Linq.Expressions;
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
}
'@

    New-FileInteractive -FilePath "Repositories\Repository.cs" -Content $RepositoryContent -Description "Generic repository implementation with pagination and filtering support"

    Show-Concept -ConceptName "Specific Repositories" -Explanation @"
Specific repositories extend the generic repository with domain-specific operations:
- IBookRepository adds book-specific queries like GetBooksWithPublisher
- IAuthorRepository adds author-specific queries like GetAuthorsWithBooks
- Encapsulates complex LINQ queries in meaningful method names
- Provides a clear API for the business layer
- Makes testing easier with focused interfaces
"@

    # Create IBookRepository interface
    $IBookRepositoryContent = @'
using EFCoreDemo.Models;

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
}
'@

    New-FileInteractive -FilePath "Repositories\IBookRepository.cs" -Content $IBookRepositoryContent -Description "Book-specific repository interface with domain-specific queries"

    # Create BookRepository implementation
    $BookRepositoryContent = @'
using Microsoft.EntityFrameworkCore;
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
}
'@

    New-FileInteractive -FilePath "Repositories\BookRepository.cs" -Content $BookRepositoryContent -Description "Book repository implementation with all domain-specific queries"

    # Create IAuthorRepository interface
    $IAuthorRepositoryContent = @'
using EFCoreDemo.Models;

namespace EFCoreDemo.Repositories;

/// <summary>
/// Author-specific repository interface
/// From Exercise 03 - Repository Pattern
/// </summary>
public interface IAuthorRepository : IRepository<Author>
{
    Task<IEnumerable<Author>> GetAuthorsWithBooksAsync();
    Task<Author?> GetAuthorWithBooksAsync(int id);
    Task<IEnumerable<Author>> SearchAuthorsAsync(string searchTerm);
    Task<bool> EmailExistsAsync(string email, int? excludeAuthorId = null);
    Task<IEnumerable<Author>> GetAuthorsByCountryAsync(string country);
    Task<int> GetBookCountForAuthorAsync(int authorId);
}
'@

    New-FileInteractive -FilePath "Repositories\IAuthorRepository.cs" -Content $IAuthorRepositoryContent -Description "Author-specific repository interface"

    # Create AuthorRepository implementation
    $AuthorRepositoryContent = @'
using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Data;
using EFCoreDemo.Models;

namespace EFCoreDemo.Repositories;

/// <summary>
/// Author-specific repository implementation
/// From Exercise 03 - Repository Pattern
/// </summary>
public class AuthorRepository : Repository<Author>, IAuthorRepository
{
    public AuthorRepository(BookStoreContext context) : base(context)
    {
    }
    
    public async Task<IEnumerable<Author>> GetAuthorsWithBooksAsync()
    {
        return await _context.Authors
            .Include(a => a.BookAuthors)
                .ThenInclude(ba => ba.Book)
            .OrderBy(a => a.LastName)
            .ThenBy(a => a.FirstName)
            .ToListAsync();
    }
    
    public async Task<Author?> GetAuthorWithBooksAsync(int id)
    {
        return await _context.Authors
            .Include(a => a.BookAuthors)
                .ThenInclude(ba => ba.Book)
                    .ThenInclude(b => b.Publisher)
            .FirstOrDefaultAsync(a => a.Id == id);
    }
    
    public async Task<IEnumerable<Author>> SearchAuthorsAsync(string searchTerm)
    {
        var term = searchTerm.ToLower();
        return await _context.Authors
            .Include(a => a.BookAuthors)
                .ThenInclude(ba => ba.Book)
            .Where(a => a.FirstName.ToLower().Contains(term) ||
                       a.LastName.ToLower().Contains(term) ||
                       a.Email.ToLower().Contains(term))
            .OrderBy(a => a.LastName)
            .ThenBy(a => a.FirstName)
            .ToListAsync();
    }
    
    public async Task<bool> EmailExistsAsync(string email, int? excludeAuthorId = null)
    {
        var query = _context.Authors.Where(a => a.Email == email);
        
        if (excludeAuthorId.HasValue)
        {
            query = query.Where(a => a.Id != excludeAuthorId.Value);
        }
        
        return await query.AnyAsync();
    }
    
    public async Task<IEnumerable<Author>> GetAuthorsByCountryAsync(string country)
    {
        return await _context.Authors
            .Where(a => a.Country == country)
            .OrderBy(a => a.LastName)
            .ThenBy(a => a.FirstName)
            .ToListAsync();
    }
    
    public async Task<int> GetBookCountForAuthorAsync(int authorId)
    {
        return await _context.BookAuthors
            .Where(ba => ba.AuthorId == authorId)
            .CountAsync();
    }
}
'@

    New-FileInteractive -FilePath "Repositories\AuthorRepository.cs" -Content $AuthorRepositoryContent -Description "Author repository implementation with book relationships"

    Show-Concept -ConceptName "Unit of Work Pattern" -Explanation @"
Unit of Work pattern coordinates multiple repositories in a single transaction:
- Manages database transactions across multiple repositories
- Ensures all changes are saved together or rolled back
- Provides a single point of control for SaveChanges
- Prevents partial updates to the database
- Simplifies complex business operations that span multiple entities
"@

    # Create UnitOfWork folder
    if (-not (Test-Path -Path "UnitOfWork")) {
        New-Item -ItemType Directory -Path "UnitOfWork" -Force | Out-Null
    }

    # Create IUnitOfWork interface
    $IUnitOfWorkContent = @'
using EFCoreDemo.Repositories;
using EFCoreDemo.Models;

namespace EFCoreDemo.UnitOfWork;

/// <summary>
/// Unit of Work interface to coordinate multiple repositories
/// From Exercise 03 - Repository Pattern
/// </summary>
public interface IUnitOfWork : IDisposable
{
    IBookRepository Books { get; }
    IAuthorRepository Authors { get; }
    IRepository<Publisher> Publishers { get; }
    
    Task<int> SaveChangesAsync();
    Task BeginTransactionAsync();
    Task CommitTransactionAsync();
    Task RollbackTransactionAsync();
}
'@

    New-FileInteractive -FilePath "UnitOfWork\IUnitOfWork.cs" -Content $IUnitOfWorkContent -Description "Unit of Work interface for transaction management"

    # Create UnitOfWork implementation
    $UnitOfWorkContent = @'
using Microsoft.EntityFrameworkCore.Storage;
using EFCoreDemo.Data;
using EFCoreDemo.Models;
using EFCoreDemo.Repositories;

namespace EFCoreDemo.UnitOfWork;

/// <summary>
/// Unit of Work implementation to coordinate multiple repositories
/// From Exercise 03 - Repository Pattern
/// </summary>
public class UnitOfWork : IUnitOfWork
{
    private readonly BookStoreContext _context;
    private IDbContextTransaction? _transaction;
    
    public IBookRepository Books { get; }
    public IAuthorRepository Authors { get; }
    public IRepository<Publisher> Publishers { get; }
    
    public UnitOfWork(BookStoreContext context)
    {
        _context = context;
        Books = new BookRepository(_context);
        Authors = new AuthorRepository(_context);
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
}
'@

    New-FileInteractive -FilePath "UnitOfWork\UnitOfWork.cs" -Content $UnitOfWorkContent -Description "Unit of Work implementation with transaction support"

    # Update Program.cs to register repositories and unit of work
    Write-Host "Updating Program.cs to register repositories and unit of work..." -ForegroundColor Cyan
    if (Test-Path -Path "Program.cs") {
        $ProgramContent = Get-Content -Path "Program.cs" -Raw
        
        # Find the line after the BookQueryService registration
        if ($ProgramContent -match "(builder\.Services\.AddScoped<EFCoreDemo\.Services\.BookQueryService>\(\);)") {
            $RegistrationCode = @"
$1

// Register Repository Pattern and Unit of Work (Exercise 3)
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<IBookRepository, BookRepository>();
builder.Services.AddScoped<IAuthorRepository, AuthorRepository>();
builder.Services.AddScoped(typeof(IRepository<>), typeof(Repository<>));
"@
            
            $UpdatedContent = $ProgramContent -replace "(builder\.Services\.AddScoped<EFCoreDemo\.Services\.BookQueryService>\(\);)", $RegistrationCode
            
            # Add using statements at the top
            $UpdatedContent = $UpdatedContent -replace "(using EFCoreDemo\.Data;)", @"
$1
using EFCoreDemo.Repositories;
using EFCoreDemo.UnitOfWork;
"@
            
            $UpdatedContent | Out-File -FilePath "Program.cs" -Encoding UTF8
            Write-Host "✅ Updated Program.cs with repository and unit of work registrations" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Manual registration may be needed - check Program.cs" -ForegroundColor Yellow
        }
    }

    Show-Concept -ConceptName "Refactoring Controllers" -Explanation @"
Controllers should use repositories instead of direct DbContext access:
- Inject IUnitOfWork instead of DbContext
- Use repository methods for data access
- Leverage Unit of Work for transaction management
- Keep controllers focused on HTTP concerns
- Move complex business logic to service layers
"@

    # Create refactored BooksController with repository pattern
    $RefactoredBooksControllerContent = @'
using Microsoft.AspNetCore.Mvc;
using EFCoreDemo.Models;
using EFCoreDemo.Models.DTOs;
using EFCoreDemo.UnitOfWork;

namespace EFCoreDemo.Controllers;

/// <summary>
/// Books Controller refactored to use Repository Pattern
/// From Exercise 03 - Repository Pattern
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class BooksV2Controller : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<BooksV2Controller> _logger;
    
    public BooksV2Controller(IUnitOfWork unitOfWork, ILogger<BooksV2Controller> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }
    
    /// <summary>
    /// Get all books with publisher information
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<BookDto>>> GetBooks()
    {
        try
        {
            _logger.LogInformation("Retrieving all books using repository pattern");
            
            var books = await _unitOfWork.Books.GetBooksWithPublisherAsync();
            
            var bookDtos = books.Select(b => new BookDto
            {
                Id = b.Id,
                Title = b.Title,
                Author = b.Author,
                ISBN = b.ISBN,
                Price = b.Price,
                PublishedDate = b.PublishedDate,
                IsAvailable = b.IsAvailable,
                PublisherName = b.Publisher?.Name,
                Authors = b.BookAuthors.Select(ba => ba.Author.FullName).ToList()
            });
            
            return Ok(bookDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving books");
            return StatusCode(500, "Internal server error");
        }
    }
    
    /// <summary>
    /// Get book by ID with full details
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<BookDto>> GetBook(int id)
    {
        try
        {
            _logger.LogInformation("Retrieving book with ID: {BookId}", id);
            
            var book = await _unitOfWork.Books.GetBookWithDetailsAsync(id);
            
            if (book == null)
            {
                return NotFound($"Book with ID {id} not found");
            }
            
            var bookDto = new BookDto
            {
                Id = book.Id,
                Title = book.Title,
                Author = book.Author,
                ISBN = book.ISBN,
                Price = book.Price,
                PublishedDate = book.PublishedDate,
                IsAvailable = book.IsAvailable,
                PublisherName = book.Publisher?.Name,
                Authors = book.BookAuthors.Select(ba => ba.Author.FullName).ToList()
            };
            
            return Ok(bookDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving book {BookId}", id);
            return StatusCode(500, "Internal server error");
        }
    }
    
    /// <summary>
    /// Search books across multiple fields
    /// </summary>
    [HttpGet("search")]
    public async Task<ActionResult<IEnumerable<BookDto>>> SearchBooks([FromQuery] string term)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(term))
            {
                return BadRequest("Search term is required");
            }
            
            _logger.LogInformation("Searching books with term: {SearchTerm}", term);
            
            var books = await _unitOfWork.Books.SearchBooksAsync(term);
            
            var bookDtos = books.Select(b => new BookDto
            {
                Id = b.Id,
                Title = b.Title,
                Author = b.Author,
                ISBN = b.ISBN,
                Price = b.Price,
                PublishedDate = b.PublishedDate,
                IsAvailable = b.IsAvailable,
                PublisherName = b.Publisher?.Name,
                Authors = b.BookAuthors.Select(ba => ba.Author.FullName).ToList()
            });
            
            return Ok(bookDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error searching books with term: {Term}", term);
            return StatusCode(500, "Internal server error");
        }
    }
    
    /// <summary>
    /// Create a new book with transaction support
    /// </summary>
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
            
            // Start transaction
            await _unitOfWork.BeginTransactionAsync();
            
            try
            {
                // Validate ISBN uniqueness
                if (await _unitOfWork.Books.IsbnExistsAsync(createBookDto.ISBN))
                {
                    await _unitOfWork.RollbackTransactionAsync();
                    return Conflict($"Book with ISBN '{createBookDto.ISBN}' already exists");
                }
                
                // Validate publisher exists if provided
                if (createBookDto.PublisherId.HasValue)
                {
                    var publisherExists = await _unitOfWork.Publishers.ExistsAsync(createBookDto.PublisherId.Value);
                    if (!publisherExists)
                    {
                        await _unitOfWork.RollbackTransactionAsync();
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
                
                var createdBook = await _unitOfWork.Books.AddAsync(book);
                await _unitOfWork.SaveChangesAsync();
                
                // Commit transaction
                await _unitOfWork.CommitTransactionAsync();
                
                var bookDto = new BookDto
                {
                    Id = createdBook.Id,
                    Title = createdBook.Title,
                    Author = createdBook.Author,
                    ISBN = createdBook.ISBN,
                    Price = createdBook.Price,
                    PublishedDate = createdBook.PublishedDate,
                    IsAvailable = createdBook.IsAvailable
                };
                
                return CreatedAtAction(nameof(GetBook), new { id = createdBook.Id }, bookDto);
            }
            catch
            {
                await _unitOfWork.RollbackTransactionAsync();
                throw;
            }
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
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateBook(int id, UpdateBookDto updateBookDto)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }
            
            var book = await _unitOfWork.Books.GetByIdAsync(id);
            if (book == null)
            {
                return NotFound($"Book with ID {id} not found");
            }
            
            // Check if ISBN is being changed and if it conflicts
            if (book.ISBN != updateBookDto.ISBN)
            {
                if (await _unitOfWork.Books.IsbnExistsAsync(updateBookDto.ISBN, id))
                {
                    return Conflict($"Book with ISBN '{updateBookDto.ISBN}' already exists");
                }
            }
            
            // Validate publisher exists if provided
            if (updateBookDto.PublisherId.HasValue)
            {
                var publisherExists = await _unitOfWork.Publishers.ExistsAsync(updateBookDto.PublisherId.Value);
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
            
            await _unitOfWork.Books.UpdateAsync(book);
            await _unitOfWork.SaveChangesAsync();
            
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
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteBook(int id)
    {
        try
        {
            var deleted = await _unitOfWork.Books.DeleteAsync(id);
            if (!deleted)
            {
                return NotFound($"Book with ID {id} not found");
            }
            
            await _unitOfWork.SaveChangesAsync();
            
            _logger.LogInformation("Deleted book with ID: {BookId}", id);
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting book {BookId}", id);
            return StatusCode(500, "Internal server error");
        }
    }
    
    /// <summary>
    /// Get books by price range
    /// </summary>
    [HttpGet("price-range")]
    public async Task<ActionResult<IEnumerable<BookDto>>> GetBooksByPriceRange(
        [FromQuery] decimal minPrice,
        [FromQuery] decimal maxPrice)
    {
        try
        {
            if (minPrice < 0 || maxPrice < minPrice)
            {
                return BadRequest("Invalid price range");
            }
            
            var books = await _unitOfWork.Books.GetBooksByPriceRangeAsync(minPrice, maxPrice);
            
            var bookDtos = books.Select(b => new BookDto
            {
                Id = b.Id,
                Title = b.Title,
                Author = b.Author,
                ISBN = b.ISBN,
                Price = b.Price,
                PublishedDate = b.PublishedDate,
                IsAvailable = b.IsAvailable,
                PublisherName = b.Publisher?.Name
            });
            
            return Ok(bookDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting books by price range");
            return StatusCode(500, "Internal server error");
        }
    }
    
    /// <summary>
    /// Get average book price
    /// </summary>
    [HttpGet("average-price")]
    public async Task<ActionResult<object>> GetAveragePrice()
    {
        try
        {
            var averagePrice = await _unitOfWork.Books.GetAveragePriceAsync();
            return Ok(new { AveragePrice = averagePrice });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error calculating average price");
            return StatusCode(500, "Internal server error");
        }
    }
}
'@

    New-FileInteractive -FilePath "Controllers\BooksV2Controller.cs" -Content $RefactoredBooksControllerContent -Description "Refactored Books controller using Repository Pattern and Unit of Work"

    # Create exercise guide for Exercise 3
    $Exercise3GuideContent = @'
# Exercise 3: Repository Pattern and Unit of Work Implementation

## 🎯 Objective
Refactor direct Entity Framework Core usage to implement the Repository Pattern and Unit of Work Pattern for better separation of concerns, testability, and maintainability.

## ⏱️ Time Allocation
**Total Time**: 35 minutes
- Generic Repository Implementation: 12 minutes
- Specific Repository Implementation: 10 minutes
- Unit of Work Pattern: 8 minutes
- Controller Refactoring: 5 minutes

## 🚀 Getting Started

### Step 1: Review the Generated Files
The following files have been created:
- `Repositories/IRepository.cs` - Generic repository interface
- `Repositories/Repository.cs` - Generic repository implementation
- `Repositories/IBookRepository.cs` - Book-specific interface
- `Repositories/BookRepository.cs` - Book repository implementation
- `Repositories/IAuthorRepository.cs` - Author-specific interface
- `Repositories/AuthorRepository.cs` - Author repository implementation
- `UnitOfWork/IUnitOfWork.cs` - Unit of Work interface
- `UnitOfWork/UnitOfWork.cs` - Unit of Work implementation
- `Controllers/BooksV2Controller.cs` - Refactored controller

### Step 2: Verify Dependency Injection
Check that Program.cs has been updated with:
```csharp
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<IBookRepository, BookRepository>();
builder.Services.AddScoped<IAuthorRepository, AuthorRepository>();
builder.Services.AddScoped(typeof(IRepository<>), typeof(Repository<>));
```

### Step 3: Test the Implementation
1. Run: `dotnet run`
2. Navigate to: http://localhost:5000/swagger
3. Test the new BooksV2 endpoints

## ✅ Success Criteria
- [ ] Generic repository interface and implementation are complete
- [ ] Specific repositories are implemented with domain-specific methods
- [ ] Unit of Work pattern is properly implemented
- [ ] Transaction management works correctly
- [ ] Controllers are refactored to use repositories
- [ ] Proper error handling and logging are in place
- [ ] All repository methods work correctly
- [ ] Dependency injection is configured properly

## 🔧 Testing Your Implementation

### Test Repository Methods
```bash
# Search books
curl -X GET "http://localhost:5000/api/booksv2/search?term=programming"

# Get books by price range
curl -X GET "http://localhost:5000/api/booksv2/price-range?minPrice=20&maxPrice=50"

# Get average price
curl -X GET "http://localhost:5000/api/booksv2/average-price"
```

### Test Transaction Support
```bash
# Create a book (will use transaction)
curl -X POST "http://localhost:5000/api/booksv2" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Repository Pattern Guide",
    "author": "Martin Fowler",
    "isbn": "978-1234567899",
    "price": 55.99,
    "publishedDate": "2023-01-01",
    "isAvailable": true,
    "publisherId": 1
  }'
```

## 💡 Key Concepts Demonstrated

### Repository Pattern Benefits:
1. **Separation of Concerns**: Business logic separated from data access
2. **Testability**: Easy to mock repositories for unit testing
3. **Consistency**: Standardized data access patterns
4. **Flexibility**: Can switch data access technologies
5. **Maintainability**: Centralized data access logic

### Unit of Work Benefits:
1. **Transaction Management**: Coordinate multiple operations
2. **Consistency**: Ensure all-or-nothing updates
3. **Performance**: Batch database operations
4. **Simplicity**: Single point for SaveChanges

## 🎯 Learning Outcomes
After completing this exercise, you should understand:
- How to implement the Repository Pattern with EF Core
- Generic vs specific repository implementations
- Unit of Work pattern for transaction management
- Dependency injection configuration for repositories
- Benefits of abstraction layers in data access
- How to refactor existing code to use repositories

## 📚 Additional Challenges
1. Add caching to the repository layer
2. Implement soft delete functionality
3. Add audit logging to track changes
4. Create integration tests for repositories
5. Implement specification pattern for complex queries
'@

    New-FileInteractive -FilePath "EXERCISE_03_GUIDE.md" -Content $Exercise3GuideContent -Description "Complete exercise guide for Repository Pattern implementation"

    # Create a simple test file to verify repository implementation
    $RepositoryTestContent = @'
using EFCoreDemo.Data;
using EFCoreDemo.Repositories;
using EFCoreDemo.UnitOfWork;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace EFCoreDemo.Tests;

/// <summary>
/// Simple test class to verify repository implementation
/// From Exercise 03 - Repository Pattern
/// </summary>
public class RepositoryTests
{
    private readonly IServiceProvider _serviceProvider;
    
    public RepositoryTests()
    {
        var services = new ServiceCollection();
        
        // Configure in-memory database for testing
        services.AddDbContext<BookStoreContext>(options =>
            options.UseInMemoryDatabase("TestDatabase"));
        
        // Register repositories and unit of work
        services.AddScoped<IUnitOfWork, UnitOfWork>();
        services.AddScoped<IBookRepository, BookRepository>();
        services.AddScoped<IAuthorRepository, AuthorRepository>();
        services.AddScoped(typeof(IRepository<>), typeof(Repository<>));
        
        // Add logging
        services.AddLogging();
        
        _serviceProvider = services.BuildServiceProvider();
    }
    
    public async Task RunTests()
    {
        Console.WriteLine("Running Repository Pattern Tests...\n");
        
        using (var scope = _serviceProvider.CreateScope())
        {
            var unitOfWork = scope.ServiceProvider.GetRequiredService<IUnitOfWork>();
            
            // Test 1: Add a new book
            Console.WriteLine("Test 1: Adding a new book");
            var newBook = new Models.Book
            {
                Title = "Test Book",
                Author = "Test Author",
                ISBN = "978-0000000001",
                Price = 29.99m,
                PublishedDate = DateTime.Now,
                IsAvailable = true
            };
            
            await unitOfWork.Books.AddAsync(newBook);
            await unitOfWork.SaveChangesAsync();
            Console.WriteLine("✅ Book added successfully\n");
            
            // Test 2: Search for books
            Console.WriteLine("Test 2: Searching for books");
            var searchResults = await unitOfWork.Books.SearchBooksAsync("Test");
            Console.WriteLine($"✅ Found {searchResults.Count()} books\n");
            
            // Test 3: Get books by price range
            Console.WriteLine("Test 3: Getting books by price range");
            var priceRangeBooks = await unitOfWork.Books.GetBooksByPriceRangeAsync(20, 40);
            Console.WriteLine($"✅ Found {priceRangeBooks.Count()} books in price range\n");
            
            // Test 4: Check ISBN exists
            Console.WriteLine("Test 4: Checking if ISBN exists");
            var isbnExists = await unitOfWork.Books.IsbnExistsAsync("978-0000000001");
            Console.WriteLine($"✅ ISBN exists: {isbnExists}\n");
            
            // Test 5: Transaction test
            Console.WriteLine("Test 5: Testing transaction rollback");
            await unitOfWork.BeginTransactionAsync();
            
            var transactionBook = new Models.Book
            {
                Title = "Transaction Test Book",
                Author = "Transaction Author",
                ISBN = "978-0000000002",
                Price = 39.99m,
                PublishedDate = DateTime.Now,
                IsAvailable = true
            };
            
            await unitOfWork.Books.AddAsync(transactionBook);
            await unitOfWork.SaveChangesAsync();
            
            // Rollback instead of commit
            await unitOfWork.RollbackTransactionAsync();
            
            var rollbackCheck = await unitOfWork.Books.IsbnExistsAsync("978-0000000002");
            Console.WriteLine($"✅ Transaction rolled back successfully. Book exists: {rollbackCheck}\n");
        }
        
        Console.WriteLine("All tests completed successfully! 🎉");
    }
}

// To run tests, add this to Program.cs:
// var tests = new RepositoryTests();
// await tests.RunTests();
'@

    New-FileInteractive -FilePath "Tests\RepositoryTests.cs" -Content $RepositoryTestContent -Description "Simple test class to verify repository implementation"

    Write-Host "🎉 Exercise 3 template created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "[OVERVIEW] Next steps:" -ForegroundColor Yellow
    Write-Host "1. Repository pattern and Unit of Work have been registered ✅" -ForegroundColor White
    Write-Host "2. Run: dotnet run" -ForegroundColor Cyan
    Write-Host "3. Test the new BooksV2 endpoints in Swagger" -ForegroundColor Cyan
    Write-Host "4. Compare BooksController vs BooksV2Controller implementations" -ForegroundColor White
    Write-Host "5. Follow the EXERCISE_03_GUIDE.md for detailed instructions" -ForegroundColor White
    Write-Host ""
    Write-Host "[TIP] Benefits of Repository Pattern:" -ForegroundColor Magenta
    Write-Host "  - Better testability with mocked repositories" -ForegroundColor White
    Write-Host "  - Cleaner separation of concerns" -ForegroundColor White
    Write-Host "  - Centralized query logic" -ForegroundColor White
    Write-Host "  - Transaction support via Unit of Work" -ForegroundColor White
    Write-Host "  - Easier to switch data providers" -ForegroundColor White
}

Write-Host ""
Write-Host "[OK] Module 5 Exercise Setup Complete!" -ForegroundColor Green
Write-Host "Happy coding! 🚀" -ForegroundColor Cyan
