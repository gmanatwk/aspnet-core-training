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
            Write-Host "  RestfulAPI/"
            Write-Host "  ├── Controllers/"
            Write-Host "  │   └── ProductsController.cs   # CRUD operations for products"
            Write-Host "  ├── Models/"
            Write-Host "  │   └── Product.cs              # Product entity model"
            Write-Host "  ├── Data/"
            Write-Host "  │   └── ApplicationDbContext.cs # Entity Framework context"
            Write-Host "  ├── DTOs/"
            Write-Host "  │   └── ProductDtos.cs          # Data transfer objects"
            Write-Host "  ├── Program.cs                  # API configuration with EF"
            Write-Host "  └── appsettings.json            # Application settings"
            Write-Host ""
            Write-ColorOutput "This creates a RESTful API with Entity Framework for product management" -Color Blue
        }
        
        "exercise02" {
            Write-ColorOutput "Building on Exercise 1, adding:" -Color Green
            Write-Host "  RestfulAPI/"
            Write-Host "  ├── Controllers/"
            Write-Host "  │   ├── AuthController.cs       # Authentication endpoints"
            Write-Host "  │   └── ProductsController.cs   # Now with [Authorize] attributes"
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
            Write-Host "  RestfulAPI/"
            Write-Host "  ├── Controllers/"
            Write-Host "  │   ├── V1/ProductsV1Controller.cs # Version 1 API"
            Write-Host "  │   └── V2/ProductsV2Controller.cs # Version 2 API"
            Write-Host "  ├── Configuration/"
            Write-Host "  │   └── SwaggerConfig.cs        # Enhanced Swagger setup"
            Write-Host "  ├── HealthChecks/"
            Write-Host "  │   └── ApiHealthCheck.cs       # Health monitoring"
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

$PROJECT_NAME = "RestfulAPI"
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
            Write-ColorOutput "Creating RestfulAPI project structure..." -Color Cyan
            # Create .NET Web API project directly
            dotnet new webapi --framework net8.0 --name RestfulAPI --force
            Set-Location RestfulAPI
        }

        # Remove default files
        Remove-Item -Force WeatherForecast.cs, Controllers/WeatherForecastController.cs -ErrorAction SilentlyContinue

        # Add required Entity Framework packages
        Write-ColorOutput "Adding Entity Framework packages..." -Color Cyan
        dotnet add package Microsoft.EntityFrameworkCore.InMemory --version 8.0.11
        dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 8.0.11
        dotnet add package Microsoft.EntityFrameworkCore.Tools --version 8.0.11

        # Enable XML documentation generation by recreating the .csproj file
        Write-ColorOutput "Configuring XML documentation..." -Color Cyan
        $csprojContent = @'
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
'@
        Set-Content "RestfulAPI.csproj" -Value $csprojContent
        Write-ColorOutput "XML documentation enabled" -Color Green

        # Create launchSettings.json to ensure consistent port
        New-Item -ItemType Directory -Path "Properties" -Force | Out-Null
        New-FileInteractive -FilePath "Properties/launchSettings.json" -Description "Launch settings to ensure consistent port 5000" -Content @'
{
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
}
'@

        # Create Models
        New-FileInteractive -FilePath "Models/Product.cs" -Description "Product entity model with validation attributes" -Content @'
using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.Models
{
    public class Product
    {
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;

        [StringLength(500)]
        public string? Description { get; set; }

        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal Price { get; set; }

        [Required]
        [StringLength(100)]
        public string Category { get; set; } = string.Empty;

        [Required]
        [StringLength(50)]
        public string Sku { get; set; } = string.Empty;

        [Range(0, int.MaxValue)]
        public int StockQuantity { get; set; }

        public bool IsActive { get; set; } = true;
        public bool IsAvailable { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
    }
}
'@

        # Create Data Context
        New-Item -ItemType Directory -Path "Data" -Force | Out-Null
        New-FileInteractive -FilePath "Data/ApplicationDbContext.cs" -Description "Entity Framework DbContext for the application" -Content @'
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Models;

namespace RestfulAPI.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public DbSet<Product> Products { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Seed data
            modelBuilder.Entity<Product>().HasData(
                new Product { Id = 1, Name = "Laptop", Description = "High-performance laptop", Price = 999.99m, Category = "Electronics", Sku = "LAP001", StockQuantity = 10 },
                new Product { Id = 2, Name = "Mouse", Description = "Wireless mouse", Price = 29.99m, Category = "Accessories", Sku = "MOU001", StockQuantity = 50 },
                new Product { Id = 3, Name = "Keyboard", Description = "Mechanical keyboard", Price = 79.99m, Category = "Accessories", Sku = "KEY001", StockQuantity = 25 }
            );
        }
    }
}
'@

        # Create DTOs
        New-Item -ItemType Directory -Path "DTOs" -Force | Out-Null
        New-FileInteractive -FilePath "DTOs/ProductDtos.cs" -Description "Data Transfer Objects for Product operations" -Content @'
using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.DTOs
{
    public record CreateProductDto
    {
        [Required]
        [StringLength(100, MinimumLength = 1)]
        public string Name { get; init; } = string.Empty;

        [StringLength(500)]
        public string? Description { get; init; }

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

    public record UpdateProductDto
    {
        [Required]
        [StringLength(100, MinimumLength = 1)]
        public string Name { get; init; } = string.Empty;

        [StringLength(500)]
        public string? Description { get; init; }

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

    public record ProductResponseDto
    {
        public int Id { get; init; }
        public string Name { get; init; } = string.Empty;
        public string? Description { get; init; }
        public decimal Price { get; init; }
        public string Sku { get; init; } = string.Empty;
        public int StockQuantity { get; init; }
        public bool IsActive { get; init; }
        public bool IsAvailable { get; init; }
        public DateTime CreatedAt { get; init; }
        public DateTime? UpdatedAt { get; init; }
    }
}
'@

        # Create Controllers
        New-FileInteractive -FilePath "Controllers/ProductsController.cs" -Description "RESTful API controller for product operations" -Content @'
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Data;
using RestfulAPI.Models;
using RestfulAPI.DTOs;

namespace RestfulAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public ProductsController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ProductResponseDto>>> GetProducts()
        {
            var products = await _context.Products
                .Select(p => new ProductResponseDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Sku = p.Sku,
                    StockQuantity = p.StockQuantity,
                    IsActive = p.IsActive,
                    IsAvailable = p.IsAvailable,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .ToListAsync();

            return Ok(products);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ProductResponseDto>> GetProduct(int id)
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null)
            {
                return NotFound($"Product with ID {id} not found.");
            }

            var productDto = new ProductResponseDto
            {
                Id = product.Id,
                Name = product.Name,
                Description = product.Description,
                Price = product.Price,
                Sku = product.Sku,
                StockQuantity = product.StockQuantity,
                IsActive = product.IsActive,
                IsAvailable = product.IsAvailable,
                CreatedAt = product.CreatedAt,
                UpdatedAt = product.UpdatedAt
            };

            return Ok(productDto);
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<ProductResponseDto>> CreateProduct(CreateProductDto createDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var product = new Product
            {
                Name = createDto.Name,
                Description = createDto.Description,
                Price = createDto.Price,
                Category = createDto.Category,
                Sku = createDto.Sku,
                StockQuantity = createDto.StockQuantity,
                IsActive = createDto.IsActive ?? true,
                IsAvailable = createDto.IsAvailable ?? true,
                CreatedAt = DateTime.UtcNow
            };

            _context.Products.Add(product);
            await _context.SaveChangesAsync();

            var productDto = new ProductResponseDto
            {
                Id = product.Id,
                Name = product.Name,
                Description = product.Description,
                Price = product.Price,
                Sku = product.Sku,
                StockQuantity = product.StockQuantity,
                IsActive = product.IsActive,
                IsAvailable = product.IsAvailable,
                CreatedAt = product.CreatedAt,
                UpdatedAt = product.UpdatedAt
            };

            return CreatedAtAction(nameof(GetProduct), new { id = product.Id }, productDto);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateProduct(int id, UpdateProductDto updateDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var product = await _context.Products.FindAsync(id);
            if (product == null)
            {
                return NotFound($"Product with ID {id} not found.");
            }

            product.Name = updateDto.Name;
            product.Description = updateDto.Description;
            product.Price = updateDto.Price;
            product.Category = updateDto.Category;
            product.Sku = updateDto.Sku;
            product.StockQuantity = updateDto.StockQuantity;
            product.IsActive = updateDto.IsActive ?? product.IsActive;
            product.IsAvailable = updateDto.IsAvailable ?? product.IsAvailable;
            product.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return NoContent();
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteProduct(int id)
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null)
            {
                return NotFound($"Product with ID {id} not found.");
            }

            _context.Products.Remove(product);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
'@

        # Update Program.cs
        New-FileInteractive -FilePath "Program.cs" -Description "Program.cs configured for RESTful API with Entity Framework" -Content @'
using Microsoft.EntityFrameworkCore;
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

app.Run();
'@

        Write-ColorOutput "Exercise 1 setup complete!" -Color Green
        Write-ColorOutput "To run the application:" -Color Yellow
        Write-Host ""
        Write-ColorOutput "1. dotnet run --urls `"http://localhost:5000`"" -Color Cyan
        Write-Host "2. Open browser to: http://localhost:5000/swagger"
        Write-Host "3. Test the API endpoints using Swagger UI"
        Write-Host ""
        Write-ColorOutput "Available endpoints:" -Color Blue
        Write-Host "  GET    /api/products       - Get all products"
        Write-Host "  GET    /api/products/{id}  - Get product by ID"
        Write-Host "  POST   /api/products       - Create new product"
        Write-Host "  PUT    /api/products/{id}  - Update product"
        Write-Host "  DELETE /api/products/{id}  - Delete product"
        Write-Host ""
        Write-ColorOutput "Sample product data is automatically seeded!" -Color Green
    }

    "exercise02" {
        # Exercise 2: Add Authentication & Security

        # Add authentication packages
        Write-ColorOutput "Adding authentication packages..." -Color Cyan
        dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.11
        dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore --version 8.0.11
        dotnet add package System.IdentityModel.Tokens.Jwt --version 8.0.2

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



        # Update ApplicationDbContext to include Identity
        Write-ColorOutput "Updating ApplicationDbContext to include Identity..." -Color Cyan
        New-FileInteractive -FilePath "Data/ApplicationDbContext.cs" -Description "Updated Entity Framework DbContext with Identity support" -Content @'
using Microsoft.AspNetCore.Identity;
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
}
'@

        # Create Identity User model
        New-Item -ItemType Directory -Path "Models/Auth" -Force | Out-Null
        New-FileInteractive -FilePath "Models/Auth/User.cs" -Description "Identity user model for authentication" -Content @'
using Microsoft.AspNetCore.Identity;

namespace RestfulAPI.Models.Auth
{
    public class User : IdentityUser
    {
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string FullName => $"{FirstName} {LastName}".Trim();
        public DateTime CreatedAt { get; set; }
        public DateTime? LastLoginAt { get; set; }
        public bool IsActive { get; set; } = true;
    }
}
'@

        # Create authentication models
        New-FileInteractive -FilePath "Models/Auth/AuthModels.cs" -Description "Authentication request and response models" -Content @'
using System.ComponentModel.DataAnnotations;

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
}
'@

        # Create JWT Service
        New-Item -ItemType Directory -Path "Services" -Force | Out-Null
        New-FileInteractive -FilePath "Services/JwtService.cs" -Description "JWT token generation and validation service" -Content @'
using System.IdentityModel.Tokens.Jwt;
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
                    FullName = user.FullName,
                    Roles = roles.ToList()
                }
            };
        }

        public ClaimsPrincipal? ValidateToken(string token)
        {
            try
            {
                var tokenHandler = new JwtSecurityTokenHandler();
                var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"]!);

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

                var principal = tokenHandler.ValidateToken(token, validationParameters, out SecurityToken validatedToken);
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
}
'@

        # Create Auth Controller
        New-FileInteractive -FilePath "Controllers/AuthController.cs" -Description "Authentication controller for login and user management" -Content @'
using Microsoft.AspNetCore.Authorization;
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

                foreach (var error in result.Errors)
                {
                    ModelState.AddModelError(string.Empty, error.Description);
                }
                return ValidationProblem(ModelState);
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
                FullName = user.FullName,
                Roles = roles.ToList()
            };

            return Ok(userInfo);
        }
    }
}
'@

        # Update Program.cs to include JWT authentication
        Write-ColorOutput "Updating Program.cs with JWT authentication..." -Color Cyan
        New-FileInteractive -FilePath "Program.cs" -Description "Program.cs configured with JWT authentication" -Content @'
using Microsoft.AspNetCore.Authentication.JwtBearer;
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
        Description = "JWT Authorization header using the Bearer scheme. Enter 'Bearer' [space] and then your token in the text input below.",
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

app.Run();
'@

        # Create appsettings.json with JWT configuration
        New-FileInteractive -FilePath "appsettings.json" -Description "Application settings with JWT configuration" -Content @'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Jwt": {
    "Key": "your-super-secret-key-that-is-at-least-32-characters-long-for-security",
    "Issuer": "RestfulAPI",
    "Audience": "RestfulAPIUsers"
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

        # Add versioning packages
        Write-ColorOutput "Adding API versioning packages..." -Color Cyan
        dotnet add package Asp.Versioning.Mvc --version 8.0.0
        dotnet add package Asp.Versioning.Mvc.ApiExplorer --version 8.0.0
        dotnet add package Swashbuckle.AspNetCore.Annotations --version 6.8.1

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

        # Create V1 Controllers directory and controller
        New-Item -ItemType Directory -Path "Controllers/V1" -Force | Out-Null
        New-FileInteractive -FilePath "Controllers/V1/ProductsV1Controller.cs" -Description "Version 1 of the Products API (basic functionality)" -Content @'
using Microsoft.AspNetCore.Mvc;
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
        [ProducesResponseType(typeof(IEnumerable<ProductResponseDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<ProductResponseDto>>> GetProducts(
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
                .Select(p => new ProductResponseDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Sku = p.Sku,
                    StockQuantity = p.StockQuantity,
                    IsActive = p.IsActive,
                    IsAvailable = p.IsAvailable,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .ToListAsync();

            return Ok(products);
        }
    }
}
'@

        # Create V2 Controllers directory and controller
        New-Item -ItemType Directory -Path "Controllers/V2" -Force | Out-Null
        New-FileInteractive -FilePath "Controllers/V2/ProductsV2Controller.cs" -Description "Version 2 of the Products API with pagination and advanced features" -Content @'
using Microsoft.AspNetCore.Mvc;
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
                .Select(p => new ProductResponseDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Sku = p.Sku,
                    StockQuantity = p.StockQuantity,
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
                totalPages = (int)Math.Ceiling((double)totalItems / pageSize),
                hasNextPage = page * pageSize < totalItems,
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
            var stats = new
            {
                totalProducts = await _context.Products.CountAsync(),
                averagePrice = await _context.Products.AverageAsync(p => p.Price),
                totalValue = await _context.Products.SumAsync(p => p.Price * p.StockQuantity),
                categoryCounts = await _context.Products
                    .GroupBy(p => p.Category)
                    .Select(g => new { category = g.Key, count = g.Count() })
                    .ToListAsync()
            };

            return Ok(stats);
        }
    }
}
'@

        # Create Configuration for Swagger versioning
        New-Item -ItemType Directory -Path "Configuration" -Force | Out-Null
        New-FileInteractive -FilePath "Configuration/ConfigureSwaggerOptions.cs" -Description "Configuration for multi-version Swagger documentation" -Content @'
using Microsoft.Extensions.Options;
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
                Description = "JWT Authorization header using the Bearer scheme. Enter 'Bearer' [space] and then your token in the text input below.",
                Name = "Authorization",
                In = ParameterLocation.Header,
                Type = SecuritySchemeType.ApiKey,
                Scheme = "Bearer"
            });

            options.AddSecurityRequirement(new OpenApiSecurityRequirement()
            {
                {
                    new OpenApiSecurityScheme
                    {
                        Reference = new OpenApiReference
                        {
                            Type = ReferenceType.SecurityScheme,
                            Id = "Bearer"
                        },
                        Scheme = "oauth2",
                        Name = "Bearer",
                        In = ParameterLocation.Header,
                    },
                    new List<string>()
                }
            });

            // Include XML comments for better documentation
            var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
            var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
            if (File.Exists(xmlPath))
            {
                options.IncludeXmlComments(xmlPath);
            }
        }

        private static OpenApiInfo CreateInfoForApiVersion(ApiVersionDescription description)
        {
            var info = new OpenApiInfo()
            {
                Title = "Products API",
                Version = description.ApiVersion.ToString(),
                Description = "A comprehensive Products API with authentication and versioning.",
                Contact = new OpenApiContact
                {
                    Name = "API Support",
                    Email = "support@example.com"
                }
            };

            if (description.IsDeprecated)
            {
                info.Description += " This API version has been deprecated.";
            }

            return info;
        }
    }
}
'@

        # Create Health Checks
        New-Item -ItemType Directory -Path "HealthChecks" -Force | Out-Null
        New-FileInteractive -FilePath "HealthChecks/ApiHealthCheck.cs" -Description "Custom health check for monitoring API status" -Content @'
using Microsoft.Extensions.Diagnostics.HealthChecks;
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
}
'@

        # Update Program.cs to support multiple API versions
        Write-ColorOutput "Updating Program.cs for API versioning..." -Color Cyan
        New-FileInteractive -FilePath "Program.cs" -Description "Program.cs configured for multiple API versions with v1 and v2 support" -Content @'
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.Options;
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
    options.GroupNameFormat = "'v'VVV";
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

app.Run();
'@

        # Create appsettings.json with JWT configuration (if not exists)
        if (-not (Test-Path "appsettings.json")) {
            New-FileInteractive -FilePath "appsettings.json" -Description "Application settings with JWT configuration" -Content @'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Jwt": {
    "Key": "your-super-secret-key-that-is-at-least-32-characters-long-for-security",
    "Issuer": "RestfulAPI",
    "Audience": "RestfulAPIUsers"
  }
}
'@
        }

        Write-ColorOutput "Exercise 3 setup complete!" -Color Green
        Write-ColorOutput "Advanced features added:" -Color Yellow
        Write-Host "• API versioning (V1 and V2)"
        Write-Host "• Enhanced Swagger documentation"
        Write-Host "• Pagination in V2"
        Write-Host "• Statistics endpoint in V2"
        Write-Host "• Multiple Swagger endpoints for each version"
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
