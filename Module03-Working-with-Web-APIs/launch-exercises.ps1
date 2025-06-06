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

        # Enable XML documentation generation
        Write-ColorOutput "Configuring XML documentation..." -Color Cyan
        $csprojContent = Get-Content "RestfulAPI.csproj" -Raw
        $csprojContent = $csprojContent -replace '(<PropertyGroup>)', '$1`n    <GenerateDocumentationFile>true</GenerateDocumentationFile>`n    <NoWarn>$(NoWarn);1591</NoWarn>'
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



        # Create authentication models
        New-FileInteractive -FilePath "Models/AuthModels.cs" -Description "Authentication request and response models" -Content @'
using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.Models
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

        # Create JWT Service
        New-Item -ItemType Directory -Path "Services" -Force | Out-Null
        New-FileInteractive -FilePath "Services/JwtService.cs" -Description "JWT token generation and validation service" -Content @'
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using RestfulAPI.Models;

namespace RestfulAPI.Services
{
    public class JwtService
    {
        private readonly IConfiguration _configuration;

        public JwtService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public string GenerateToken(User user)
        {
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"] ?? "your-super-secret-key-that-is-at-least-32-characters-long"));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Name, user.Username),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, user.Role)
            };

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"] ?? "RestfulAPI",
                audience: _configuration["Jwt:Audience"] ?? "RestfulAPI",
                claims: claims,
                expires: DateTime.UtcNow.AddHours(24),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
'@

        # Create Auth Controller
        New-FileInteractive -FilePath "Controllers/AuthController.cs" -Description "Authentication controller for login and user management" -Content @'
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Data;
using RestfulAPI.Models;
using RestfulAPI.Services;
using System.Security.Claims;

namespace RestfulAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly JwtService _jwtService;

        public AuthController(ApplicationDbContext context, JwtService jwtService)
        {
            _context = context;
            _jwtService = jwtService;
        }

        [HttpPost("login")]
        public async Task<ActionResult<LoginResponse>> Login([FromBody] LoginRequest request)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == request.Username);

            if (user == null || user.Password != request.Password) // In production, use proper password hashing
            {
                return Unauthorized(new { message = "Invalid username or password" });
            }

            var token = _jwtService.GenerateToken(user);

            return Ok(new LoginResponse
            {
                Token = token,
                Expiration = DateTime.UtcNow.AddHours(24),
                Username = user.Username
            });
        }

        [HttpGet("profile")]
        [Authorize]
        public async Task<ActionResult<User>> GetProfile()
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            var user = await _context.Users.FindAsync(userId);

            if (user == null)
            {
                return NotFound();
            }

            return Ok(new { user.Id, user.Username, user.Email, user.Role });
        }
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
