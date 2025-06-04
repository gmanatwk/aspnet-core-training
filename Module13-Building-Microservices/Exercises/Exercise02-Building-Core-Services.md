# Exercise 2: Building Core Services

## 🎯 Objective
Build the foundational microservices for an e-commerce platform, implementing proper service architecture, API design, and inter-service communication patterns.

## 📋 Prerequisites
- Completion of Exercise 1 (Service Decomposition)
- .NET 8.0 SDK installed
- Docker Desktop installed
- Basic understanding of REST APIs and Entity Framework Core

## 🏗️ Overview
In this exercise, you'll build three core microservices:
1. **Product Catalog Service** - Manages products and categories
2. **Order Management Service** - Handles order processing
3. **User Management Service** - Manages user accounts and authentication

Each service will be completely independent with its own database and API.

## 🚀 Task 1: Set up the Solution Structure (20 minutes)

### Step 1: Create the Solution Structure
```bash
# Create solution directory
mkdir ECommerceMS
cd ECommerceMS

# Create solution file
dotnet new sln -n ECommerceMS

# Create service directories
mkdir src
mkdir src/ProductCatalog.Service
mkdir src/OrderManagement.Service
mkdir src/UserManagement.Service
mkdir src/SharedLibraries
mkdir src/ApiGateway

# Create infrastructure directories
mkdir infrastructure
mkdir docker
mkdir docs
```

### Step 2: Create Shared Libraries
Create a shared library for common models and utilities:

```bash
cd src/SharedLibraries
dotnet new classlib -n ECommerceMS.Shared --framework net8.0
dotnet add ECommerceMS.Shared package Microsoft.Extensions.Logging
dotnet add ECommerceMS.Shared package System.ComponentModel.DataAnnotations
```

**Create Common Base Classes:**

**src/SharedLibraries/ECommerceMS.Shared/Models/BaseEntity.cs:**
```csharp
using System.ComponentModel.DataAnnotations;

namespace ECommerceMS.Shared.Models;

public abstract class BaseEntity
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? UpdatedAt { get; set; }
    
    public string? CreatedBy { get; set; }
    
    public string? UpdatedBy { get; set; }
}
```

**src/SharedLibraries/ECommerceMS.Shared/Events/BaseEvent.cs:**
```csharp
namespace ECommerceMS.Shared.Events;

public abstract class BaseEvent
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public DateTime OccurredAt { get; set; } = DateTime.UtcNow;
    public string EventType { get; set; } = string.Empty;
    public Dictionary<string, object> Metadata { get; set; } = new();
}
```

## 🛍️ Task 2: Build Product Catalog Service (45 minutes)

### Step 1: Create the Product Catalog Service
```bash
cd src/ProductCatalog.Service
dotnet new webapi -n ProductCatalog.Service --framework net8.0
dotnet add ProductCatalog.Service package Microsoft.EntityFrameworkCore.SqlServer
dotnet add ProductCatalog.Service package Microsoft.EntityFrameworkCore.Design
dotnet add ProductCatalog.Service package Microsoft.EntityFrameworkCore.Tools
dotnet add ProductCatalog.Service package AutoMapper.Extensions.Microsoft.DependencyInjection
dotnet add ProductCatalog.Service package Serilog.AspNetCore
dotnet add ProductCatalog.Service package MediatR

# Add reference to shared library
dotnet add ProductCatalog.Service reference ../SharedLibraries/ECommerceMS.Shared/ECommerceMS.Shared.csproj
```

### Step 2: Create Domain Models

**Models/Product.cs:**
```csharp
using ECommerceMS.Shared.Models;
using System.ComponentModel.DataAnnotations;

namespace ProductCatalog.Service.Models;

public class Product : BaseEntity
{
    [Required]
    [StringLength(200)]
    public string Name { get; set; } = string.Empty;
    
    [StringLength(1000)]
    public string Description { get; set; } = string.Empty;
    
    [Required]
    public decimal Price { get; set; }
    
    [StringLength(50)]
    public string SKU { get; set; } = string.Empty;
    
    public int StockQuantity { get; set; }
    
    public bool IsActive { get; set; } = true;
    
    public Guid CategoryId { get; set; }
    public Category Category { get; set; } = null!;
    
    public List<string> ImageUrls { get; set; } = new();
    
    public Dictionary<string, string> Attributes { get; set; } = new();
}
```

**Models/Category.cs:**
```csharp
using ECommerceMS.Shared.Models;
using System.ComponentModel.DataAnnotations;

namespace ProductCatalog.Service.Models;

public class Category : BaseEntity
{
    [Required]
    [StringLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [StringLength(500)]
    public string Description { get; set; } = string.Empty;
    
    public string? ParentCategoryId { get; set; }
    
    public bool IsActive { get; set; } = true;
    
    public ICollection<Product> Products { get; set; } = new List<Product>();
}
```

### Step 3: Create DTOs

**DTOs/ProductDto.cs:**
```csharp
namespace ProductCatalog.Service.DTOs;

public record ProductDto(
    Guid Id,
    string Name,
    string Description,
    decimal Price,
    string SKU,
    int StockQuantity,
    bool IsActive,
    Guid CategoryId,
    string CategoryName,
    List<string> ImageUrls,
    Dictionary<string, string> Attributes,
    DateTime CreatedAt
);

public record CreateProductDto(
    string Name,
    string Description,
    decimal Price,
    string SKU,
    int StockQuantity,
    Guid CategoryId,
    List<string> ImageUrls,
    Dictionary<string, string> Attributes
);

public record UpdateProductDto(
    string Name,
    string Description,
    decimal Price,
    int StockQuantity,
    bool IsActive,
    List<string> ImageUrls,
    Dictionary<string, string> Attributes
);
```

### Step 4: Create Database Context

**Data/ProductCatalogContext.cs:**
```csharp
using Microsoft.EntityFrameworkCore;
using ProductCatalog.Service.Models;
using System.Text.Json;

namespace ProductCatalog.Service.Data;

public class ProductCatalogContext : DbContext
{
    public ProductCatalogContext(DbContextOptions<ProductCatalogContext> options) : base(options) { }

    public DbSet<Product> Products { get; set; } = null!;
    public DbSet<Category> Categories { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
            entity.Property(e => e.SKU).IsRequired().HasMaxLength(50);
            entity.HasIndex(e => e.SKU).IsUnique();
            entity.Property(e => e.Price).HasColumnType("decimal(18,2)");
            
            // Configure JSON columns for PostgreSQL or use EF Core value converters
            entity.Property(e => e.ImageUrls)
                .HasConversion(
                    v => JsonSerializer.Serialize(v, (JsonSerializerOptions)null!),
                    v => JsonSerializer.Deserialize<List<string>>(v, (JsonSerializerOptions)null!) ?? new List<string>()
                );
                
            entity.Property(e => e.Attributes)
                .HasConversion(
                    v => JsonSerializer.Serialize(v, (JsonSerializerOptions)null!),
                    v => JsonSerializer.Deserialize<Dictionary<string, string>>(v, (JsonSerializerOptions)null!) ?? new Dictionary<string, string>()
                );

            entity.HasOne(e => e.Category)
                .WithMany(c => c.Products)
                .HasForeignKey(e => e.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            entity.HasIndex(e => e.Name).IsUnique();
        });

        // Seed data
        SeedData(modelBuilder);
    }

    private static void SeedData(ModelBuilder modelBuilder)
    {
        var electronicsCategory = new Category
        {
            Id = Guid.Parse("11111111-1111-1111-1111-111111111111"),
            Name = "Electronics",
            Description = "Electronic devices and gadgets",
            CreatedAt = DateTime.UtcNow
        };

        var clothingCategory = new Category
        {
            Id = Guid.Parse("22222222-2222-2222-2222-222222222222"),
            Name = "Clothing",
            Description = "Apparel and fashion items",
            CreatedAt = DateTime.UtcNow
        };

        modelBuilder.Entity<Category>().HasData(electronicsCategory, clothingCategory);

        var laptop = new Product
        {
            Id = Guid.Parse("33333333-3333-3333-3333-333333333333"),
            Name = "Gaming Laptop",
            Description = "High-performance gaming laptop with RTX graphics",
            Price = 1299.99m,
            SKU = "LAPTOP-001",
            StockQuantity = 10,
            CategoryId = electronicsCategory.Id,
            CreatedAt = DateTime.UtcNow
        };

        modelBuilder.Entity<Product>().HasData(laptop);
    }
}
```

### Step 5: Create Product Controller

**Controllers/ProductsController.cs:**
```csharp
using AutoMapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProductCatalog.Service.Data;
using ProductCatalog.Service.DTOs;
using ProductCatalog.Service.Models;

namespace ProductCatalog.Service.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly ProductCatalogContext _context;
    private readonly IMapper _mapper;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(ProductCatalogContext context, IMapper mapper, ILogger<ProductsController> logger)
    {
        _context = context;
        _mapper = mapper;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetProducts(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] string? category = null,
        [FromQuery] decimal? minPrice = null,
        [FromQuery] decimal? maxPrice = null,
        [FromQuery] string? search = null)
    {
        try
        {
            var query = _context.Products
                .Include(p => p.Category)
                .Where(p => p.IsActive);

            if (!string.IsNullOrEmpty(category))
            {
                query = query.Where(p => p.Category.Name.ToLower().Contains(category.ToLower()));
            }

            if (minPrice.HasValue)
            {
                query = query.Where(p => p.Price >= minPrice.Value);
            }

            if (maxPrice.HasValue)
            {
                query = query.Where(p => p.Price <= maxPrice.Value);
            }

            if (!string.IsNullOrEmpty(search))
            {
                query = query.Where(p => p.Name.ToLower().Contains(search.ToLower()) ||
                                        p.Description.ToLower().Contains(search.ToLower()));
            }

            var products = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var productDtos = products.Select(p => new ProductDto(
                p.Id,
                p.Name,
                p.Description,
                p.Price,
                p.SKU,
                p.StockQuantity,
                p.IsActive,
                p.CategoryId,
                p.Category.Name,
                p.ImageUrls,
                p.Attributes,
                p.CreatedAt
            ));

            return Ok(productDtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving products");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ProductDto>> GetProduct(Guid id)
    {
        try
        {
            var product = await _context.Products
                .Include(p => p.Category)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (product == null)
            {
                return NotFound();
            }

            var productDto = new ProductDto(
                product.Id,
                product.Name,
                product.Description,
                product.Price,
                product.SKU,
                product.StockQuantity,
                product.IsActive,
                product.CategoryId,
                product.Category.Name,
                product.ImageUrls,
                product.Attributes,
                product.CreatedAt
            );

            return Ok(productDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving product {ProductId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPost]
    public async Task<ActionResult<ProductDto>> CreateProduct(CreateProductDto createProductDto)
    {
        try
        {
            // Validate category exists
            var categoryExists = await _context.Categories
                .AnyAsync(c => c.Id == createProductDto.CategoryId);

            if (!categoryExists)
            {
                return BadRequest("Invalid category ID");
            }

            var product = new Product
            {
                Name = createProductDto.Name,
                Description = createProductDto.Description,
                Price = createProductDto.Price,
                SKU = createProductDto.SKU,
                StockQuantity = createProductDto.StockQuantity,
                CategoryId = createProductDto.CategoryId,
                ImageUrls = createProductDto.ImageUrls,
                Attributes = createProductDto.Attributes
            };

            _context.Products.Add(product);
            await _context.SaveChangesAsync();

            // Retrieve the created product with category
            var createdProduct = await _context.Products
                .Include(p => p.Category)
                .FirstOrDefaultAsync(p => p.Id == product.Id);

            var productDto = new ProductDto(
                createdProduct!.Id,
                createdProduct.Name,
                createdProduct.Description,
                createdProduct.Price,
                createdProduct.SKU,
                createdProduct.StockQuantity,
                createdProduct.IsActive,
                createdProduct.CategoryId,
                createdProduct.Category.Name,
                createdProduct.ImageUrls,
                createdProduct.Attributes,
                createdProduct.CreatedAt
            );

            return CreatedAtAction(nameof(GetProduct), new { id = product.Id }, productDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating product");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateProduct(Guid id, UpdateProductDto updateProductDto)
    {
        try
        {
            var product = await _context.Products.FindAsync(id);
            
            if (product == null)
            {
                return NotFound();
            }

            product.Name = updateProductDto.Name;
            product.Description = updateProductDto.Description;
            product.Price = updateProductDto.Price;
            product.StockQuantity = updateProductDto.StockQuantity;
            product.IsActive = updateProductDto.IsActive;
            product.ImageUrls = updateProductDto.ImageUrls;
            product.Attributes = updateProductDto.Attributes;
            product.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating product {ProductId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteProduct(Guid id)
    {
        try
        {
            var product = await _context.Products.FindAsync(id);
            
            if (product == null)
            {
                return NotFound();
            }

            // Soft delete by setting IsActive to false
            product.IsActive = false;
            product.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting product {ProductId}", id);
            return StatusCode(500, "Internal server error");
        }
    }
}
```

### Step 6: Configure the Service

**Program.cs:**
```csharp
using Microsoft.EntityFrameworkCore;
using ProductCatalog.Service.Data;
using Serilog;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .CreateLogger();

builder.Host.UseSerilog();

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add Entity Framework
builder.Services.AddDbContext<ProductCatalogContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add AutoMapper
builder.Services.AddAutoMapper(typeof(Program));

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy => policy
            .AllowAnyOrigin()
            .AllowAnyMethod()
            .AllowAnyHeader());
});

var app = builder.Build();

// Configure pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");
app.UseHttpsRedirection();
app.MapControllers();

// Ensure database is created
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ProductCatalogContext>();
    await context.Database.EnsureCreatedAsync();
}

try
{
    Log.Information("Starting Product Catalog Service");
    await app.RunAsync();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Product Catalog Service terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}
```

**appsettings.json:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=ProductCatalogDB;Trusted_Connection=true;MultipleActiveResultSets=true"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "Serilog": {
    "Using": ["Serilog.Sinks.Console", "Serilog.Sinks.File"],
    "MinimumLevel": "Information",
    "WriteTo": [
      {
        "Name": "Console"
      },
      {
        "Name": "File",
        "Args": {
          "path": "logs/product-catalog-.txt",
          "rollingInterval": "Day"
        }
      }
    ]
  },
  "AllowedHosts": "*"
}
```

## 📦 Task 3: Containerize the Service (20 minutes)

Create a Dockerfile for the Product Catalog Service:

**Dockerfile:**
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ProductCatalog.Service.csproj", "."]
COPY ["../SharedLibraries/ECommerceMS.Shared/ECommerceMS.Shared.csproj", "../SharedLibraries/ECommerceMS.Shared/"]
RUN dotnet restore "./ProductCatalog.Service.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "ProductCatalog.Service.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ProductCatalog.Service.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ProductCatalog.Service.dll"]
```

**docker-compose.yml (at solution root):**
```yaml
version: '3.8'

services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      SA_PASSWORD: "YourStrong@Passw0rd"
      ACCEPT_EULA: "Y"
    ports:
      - "1433:1433"
    volumes:
      - sqlserver_data:/var/opt/mssql

  productcatalog:
    build: 
      context: ./src/ProductCatalog.Service
      dockerfile: Dockerfile
    ports:
      - "5001:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Server=sqlserver;Database=ProductCatalogDB;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True
    depends_on:
      - sqlserver

volumes:
  sqlserver_data:
```

## 🧪 Task 4: Test the Service (15 minutes)

### Step 1: Run the Service
```bash
# Build and run with Docker Compose
docker-compose up --build

# Or run locally
cd src/ProductCatalog.Service
dotnet run
```

### Step 2: Test the API
Use the following curl commands or Postman:

```bash
# Get all products
curl -X GET "http://localhost:5001/api/products"

# Get a specific product
curl -X GET "http://localhost:5001/api/products/33333333-3333-3333-3333-333333333333"

# Create a new product
curl -X POST "http://localhost:5001/api/products" \
-H "Content-Type: application/json" \
-d '{
  "name": "Wireless Mouse",
  "description": "Ergonomic wireless mouse",
  "price": 29.99,
  "sku": "MOUSE-001",
  "stockQuantity": 50,
  "categoryId": "11111111-1111-1111-1111-111111111111",
  "imageUrls": ["https://example.com/mouse.jpg"],
  "attributes": {"color": "black", "wireless": "true"}
}'

# Search products
curl -X GET "http://localhost:5001/api/products?search=laptop&minPrice=1000"
```

## 📝 Deliverables

1. **Working Product Catalog Service** with full CRUD operations
2. **Dockerized service** that runs in containers
3. **API documentation** (Swagger/OpenAPI)
4. **Database schema** with proper relationships
5. **Test results** showing all endpoints work correctly

## 🎯 Success Criteria

### **Excellent (90-100%)**
- ✅ Service runs successfully in Docker
- ✅ All CRUD operations work correctly
- ✅ Proper error handling and logging
- ✅ Database relationships are correctly configured
- ✅ API follows REST conventions
- ✅ Comprehensive input validation
- ✅ Swagger documentation is complete

### **Good (80-89%)**
- ✅ Service runs but may have minor issues
- ✅ Most CRUD operations work
- ✅ Basic error handling implemented
- ✅ Database is properly configured

### **Satisfactory (70-79%)**
- ✅ Service runs with significant issues
- ✅ Basic functionality works
- ✅ Database connection is established

## 💡 Extension Activities

If you finish early, try these enhancements:

1. **Add Health Checks**: Implement health check endpoints
2. **Add Validation**: Use FluentValidation for input validation
3. **Add Caching**: Implement Redis caching for frequently accessed products
4. **Add Events**: Publish domain events when products are created/updated
5. **Add Search**: Implement full-text search capabilities
6. **Add Images**: Handle product image upload and storage

## ⏭️ Next Steps

- Create the Order Management Service following similar patterns
- Create the User Management Service
- Implement inter-service communication
- Proceed to Exercise 3: Communication Patterns

**Great job on building your first microservice! 🎉**