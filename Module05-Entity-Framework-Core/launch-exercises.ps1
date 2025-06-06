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
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "📄 Will create: $FilePath" -ForegroundColor Blue
    Write-Host "📝 Purpose: $Description" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
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
                Write-Host "⏭️  Skipped: $FilePath" -ForegroundColor Red
                return
            }
            "s" {
                $script:InteractiveMode = $false
                Write-Host "📌 Switching to automatic mode..." -ForegroundColor Cyan
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
    Write-Host "✅ Created: $FilePath" -ForegroundColor Green
    Write-Host ""
}

# Function to show learning objectives
function Show-LearningObjectives {
    param([string]$Exercise)
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Write-Host "🎯 Learning Objectives" -ForegroundColor Magenta
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    
    switch ($Exercise) {
        "exercise01" {
            Write-Host "In this exercise, you will learn:" -ForegroundColor Cyan
            Write-Host "  📚 1. Setting up Entity Framework Core with SQL Server" -ForegroundColor White
            Write-Host "  📚 2. Creating entity models with data annotations" -ForegroundColor White
            Write-Host "  📚 3. Configuring DbContext with Fluent API" -ForegroundColor White
            Write-Host "  📚 4. Implementing basic CRUD operations" -ForegroundColor White
            Write-Host ""
            Write-Host "Key concepts:" -ForegroundColor Yellow
            Write-Host "  • Code-First approach with EF Core" -ForegroundColor White
            Write-Host "  • Entity relationships and navigation properties" -ForegroundColor White
            Write-Host "  • Database migrations and seeding" -ForegroundColor White
            Write-Host "  • Async/await patterns with EF Core" -ForegroundColor White
        }
        "exercise02" {
            Write-Host "Building on Exercise 1, you will add:" -ForegroundColor Cyan
            Write-Host "  🔍 1. Complex LINQ queries with navigation properties" -ForegroundColor White
            Write-Host "  🔍 2. Advanced filtering and sorting capabilities" -ForegroundColor White
            Write-Host "  🔍 3. Efficient loading strategies (Include, ThenInclude)" -ForegroundColor White
            Write-Host "  🔍 4. Query performance optimization" -ForegroundColor White
            Write-Host ""
            Write-Host "Advanced concepts:" -ForegroundColor Yellow
            Write-Host "  • LINQ query optimization" -ForegroundColor White
            Write-Host "  • Eager vs Lazy loading" -ForegroundColor White
            Write-Host "  • Query performance monitoring" -ForegroundColor White
            Write-Host "  • Database indexing strategies" -ForegroundColor White
        }
        "exercise03" {
            Write-Host "Implementing professional patterns:" -ForegroundColor Cyan
            Write-Host "  🏗️ 1. Repository pattern implementation" -ForegroundColor White
            Write-Host "  🏗️ 2. Unit of Work pattern" -ForegroundColor White
            Write-Host "  🏗️ 3. Generic repository with specific implementations" -ForegroundColor White
            Write-Host "  🏗️ 4. Dependency injection with repositories" -ForegroundColor White
            Write-Host ""
            Write-Host "Design patterns:" -ForegroundColor Yellow
            Write-Host "  • Separation of concerns" -ForegroundColor White
            Write-Host "  • Testable architecture" -ForegroundColor White
            Write-Host "  • Clean code principles" -ForegroundColor White
            Write-Host "  • SOLID principles application" -ForegroundColor White
        }
    }
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Wait-ForUser
}

# Function to show what will be created overview
function Show-CreationOverview {
    param([string]$Exercise)
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "📋 Overview: What will be created" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    switch ($Exercise) {
        "exercise01" {
            Write-Host "🎯 Exercise 01: Basic EF Core Setup and CRUD Operations" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 What you'll build:" -ForegroundColor Yellow
            Write-Host "  ✅ BookStore API with Entity Framework Core" -ForegroundColor White
            Write-Host "  ✅ SQL Server database with Code-First approach" -ForegroundColor White
            Write-Host "  ✅ Book entity with proper validation and relationships" -ForegroundColor White
            Write-Host "  ✅ Complete CRUD operations with async patterns" -ForegroundColor White
            Write-Host ""
            Write-Host "🚀 RECOMMENDED: Use the Complete Working Example" -ForegroundColor Blue
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
            Write-Host "🎯 Exercise 02: Advanced Querying with LINQ" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 Building on Exercise 1:" -ForegroundColor Yellow
            Write-Host "  ✅ Product and Category entities with relationships" -ForegroundColor White
            Write-Host "  ✅ Complex LINQ queries with navigation properties" -ForegroundColor White
            Write-Host "  ✅ Advanced filtering, sorting, and pagination" -ForegroundColor White
            Write-Host "  ✅ Query performance optimization techniques" -ForegroundColor White
        }
        "exercise03" {
            Write-Host "🎯 Exercise 03: Repository Pattern Implementation" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 Professional architecture patterns:" -ForegroundColor Yellow
            Write-Host "  ✅ Generic repository interface and implementation" -ForegroundColor White
            Write-Host "  ✅ Specific repositories for entities" -ForegroundColor White
            Write-Host "  ✅ Unit of Work pattern for transaction management" -ForegroundColor White
            Write-Host "  ✅ Dependency injection configuration" -ForegroundColor White
        }
    }
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Wait-ForUser
}

# Function to explain a concept
function Show-Concept {
    param(
        [string]$ConceptName,
        [string]$Explanation
    )
    
    Write-Host "💡 Concept: $ConceptName" -ForegroundColor Magenta
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host $Explanation -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
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
    Write-Host "❌ Usage: .\launch-exercises.ps1 <exercise-name> [options]" -ForegroundColor Red
    Write-Host ""
    Show-Exercises
    exit 1
}

$ProjectName = "EFCoreDemo"

# Validate exercise name
$ValidExercises = @("exercise01", "exercise02", "exercise03")
if ($ExerciseName -notin $ValidExercises) {
    Write-Host "❌ Unknown exercise: $ExerciseName" -ForegroundColor Red
    Write-Host ""
    Show-Exercises
    exit 1
}

# Welcome screen
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
Write-Host "🚀 Module 5: Entity Framework Core" -ForegroundColor Magenta
Write-Host "Exercise: $ExerciseName" -ForegroundColor Magenta
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
Write-Host ""

# Show the recommended approach
Write-Host "🎯 RECOMMENDED APPROACH:" -ForegroundColor Green
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
Write-Host "   # Includes SQL Server and demo application" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  The template created by this script is basic and may not match" -ForegroundColor Yellow
Write-Host "   all exercise requirements. The SourceCode version is complete!" -ForegroundColor Yellow
Write-Host ""

if ($InteractiveMode) {
    Write-Host "🎮 Interactive Mode: ON" -ForegroundColor Yellow
    Write-Host "You'll see what each file does before it's created" -ForegroundColor Cyan
} else {
    Write-Host "⚡ Automatic Mode: ON" -ForegroundColor Yellow
}

Write-Host ""
$Response = Read-Host "Continue with template creation? (y/N)"
if ($Response -notmatch "^[Yy]$") {
    Write-Host "💡 Great choice! Use the SourceCode version for the best experience." -ForegroundColor Cyan
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
        Write-Host "⚠️  Project '$ProjectName' already exists!" -ForegroundColor Yellow
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
• Code-First approach: Define models in C#, generate database
• DbContext: Represents a session with the database
• DbSet<T>: Represents a table in the database
• Migrations: Version control for your database schema
• LINQ: Query your database using C# syntax
"@

    if (-not $SkipProjectCreation) {
        Write-Host "Creating new Web API project..." -ForegroundColor Cyan
        dotnet new webapi -n $ProjectName --framework net8.0
        Set-Location -Path $ProjectName
        Remove-Item -Path "WeatherForecast.cs" -ErrorAction SilentlyContinue
        Remove-Item -Path "Controllers\WeatherForecastController.cs" -ErrorAction SilentlyContinue

        # Install EF Core packages
        Write-Host "Installing Entity Framework Core packages..." -ForegroundColor Cyan
        dotnet add package Microsoft.EntityFrameworkCore.SqlServer
        dotnet add package Microsoft.EntityFrameworkCore.Tools
        dotnet add package Microsoft.EntityFrameworkCore.Design

        # Update Program.cs with EF Core configuration
        $ProgramContent = @'
using Microsoft.EntityFrameworkCore;
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

app.Run();
'@

        New-FileInteractive -FilePath "Program.cs" -Content $ProgramContent -Description "Program.cs with Entity Framework Core and SQL Server configuration"
    }

    Show-Concept -ConceptName "Entity Models" -Explanation @"
Entity models represent your database tables:
• Properties become database columns
• Data annotations provide validation and constraints
• Navigation properties define relationships
• Fluent API in DbContext provides advanced configuration
"@

    # Create Book entity model
    $BookModelContent = @'
using System.ComponentModel.DataAnnotations;
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
}
'@

    New-FileInteractive -FilePath "Models\Book.cs" -Content $BookModelContent -Description "Book entity model with data annotations and validation"

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
```powershell
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
'@

    New-FileInteractive -FilePath "EXERCISE_GUIDE.md" -Content $ExerciseGuideContent -Description "Complete exercise guide with implementation steps"

    Write-Host "🎉 Exercise 1 template created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Next steps:" -ForegroundColor Yellow
    Write-Host "1. Run: dotnet ef migrations add InitialCreate" -ForegroundColor Cyan
    Write-Host "2. Run: dotnet ef database update" -ForegroundColor Cyan
    Write-Host "3. Run: dotnet run" -ForegroundColor Cyan
    Write-Host "4. Visit: http://localhost:5000/swagger" -ForegroundColor Cyan
    Write-Host "5. Follow the EXERCISE_GUIDE.md for implementation steps" -ForegroundColor Cyan

} elseif ($ExerciseName -eq "exercise02") {
    Write-Host "Exercise 2 implementation would be added here..." -ForegroundColor Cyan
    Write-Host "This exercise builds on Exercise 1 with advanced LINQ queries" -ForegroundColor Yellow

} elseif ($ExerciseName -eq "exercise03") {
    Write-Host "Exercise 3 implementation would be added here..." -ForegroundColor Cyan
    Write-Host "This exercise implements the Repository pattern" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Module 5 Exercise Setup Complete!" -ForegroundColor Green
Write-Host "Happy coding! 🚀" -ForegroundColor Cyan
