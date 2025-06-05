# Exercise 1: Create a Basic RESTful API

## 🎯 Objective
Build a complete RESTful API for managing a library system with books, authors, and categories, implementing proper HTTP methods and status codes.

## ⏱️ Estimated Time
45 minutes

## 📋 Prerequisites
- Completed Module 1
- .NET 8.0 SDK installed
- Understanding of HTTP methods
- Basic knowledge of REST principles

## 📝 Instructions

### Part 0: Project Setup (2 minutes)

**Run the setup script:**
```bash
# From the Module03-Working-with-Web-APIs directory
../setup-exercise.sh exercise01-basic-api
cd RestfulAPI
```

**Verify setup:**
```bash
../verify-packages.sh
dotnet build
```

### Part 1: Create the API Models and Controllers (10 minutes)

3. **Create the domain model** in `Models/`:

   **Product.cs**:
   ```csharp
   using System.ComponentModel.DataAnnotations;

   namespace RestfulAPI.Models
   {
       /// <summary>
       /// Product entity model
       /// </summary>
       public class Product
       {
           /// <summary>
           /// Unique identifier
           /// </summary>
           public int Id { get; set; }

           /// <summary>
           /// Product name
           /// </summary>
           [Required]
           [StringLength(200)]
           public string Name { get; set; } = string.Empty;

           /// <summary>
           /// Product description
           /// </summary>
           [StringLength(2000)]
           public string Description { get; set; } = string.Empty;

           /// <summary>
           /// Product price
           /// </summary>
           [Range(0.01, double.MaxValue)]
           public decimal Price { get; set; }

           /// <summary>
           /// Product category
           /// </summary>
           [Required]
           [StringLength(100)]
           public string Category { get; set; } = string.Empty;

           /// <summary>
           /// Stock quantity
           /// </summary>
           [Range(0, int.MaxValue)]
           public int StockQuantity { get; set; }

           /// <summary>
           /// Stock keeping unit
           /// </summary>
           [Required]
           [StringLength(50)]
           public string Sku { get; set; } = string.Empty;

           /// <summary>
           /// Indicates if the product is active
           /// </summary>
           public bool IsActive { get; set; } = true;

           /// <summary>
           /// Indicates if the product is available for sale
           /// </summary>
           public bool IsAvailable { get; set; } = true;

           /// <summary>
           /// Creation timestamp
           /// </summary>
           public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

           /// <summary>
           /// Last update timestamp
           /// </summary>
           public DateTime? UpdatedAt { get; set; }

           /// <summary>
           /// Soft delete flag
           /// </summary>
           public bool IsDeleted { get; set; } = false;
       }
   }
   ```

### Part 2: Create DTOs (10 minutes)

1. **Create a `DTOs` folder** and add the following:

   **ProductDtos.cs**:
   ```csharp
   using System.ComponentModel.DataAnnotations;

   namespace RestfulAPI.DTOs
   {
       /// <summary>
       /// Product data transfer object
       /// </summary>
       public record ProductDto
       {
           /// <summary>
           /// Unique identifier for the product
           /// </summary>
           public int Id { get; init; }

           /// <summary>
           /// Product name
           /// </summary>
           public string Name { get; init; } = string.Empty;

           /// <summary>
           /// Product description
           /// </summary>
           public string Description { get; init; } = string.Empty;

           /// <summary>
           /// Product price in USD
           /// </summary>
           public decimal Price { get; init; }

           /// <summary>
           /// Product category
           /// </summary>
           public string Category { get; init; } = string.Empty;

           /// <summary>
           /// Available stock quantity
           /// </summary>
           public int StockQuantity { get; init; }

           /// <summary>
           /// Product SKU (Stock Keeping Unit)
           /// </summary>
           public string Sku { get; init; } = string.Empty;

           /// <summary>
           /// Indicates if the product is currently active
           /// </summary>
           public bool IsActive { get; init; }

           /// <summary>
           /// Indicates if the product is available for sale
           /// </summary>
           public bool IsAvailable { get; init; }

           /// <summary>
           /// Product creation timestamp
           /// </summary>
           public DateTime CreatedAt { get; init; }

           /// <summary>
           /// Product last update timestamp
           /// </summary>
           public DateTime? UpdatedAt { get; init; }
       }

       /// <summary>
       /// DTO for creating a new product
       /// </summary>
       public record CreateProductDto
       {
           /// <summary>
           /// Product name
           /// </summary>
           [Required(ErrorMessage = "Product name is required")]
           [StringLength(200, MinimumLength = 1, ErrorMessage = "Product name must be between 1 and 200 characters")]
           public string Name { get; init; } = string.Empty;

           /// <summary>
           /// Product description
           /// </summary>
           [StringLength(2000, ErrorMessage = "Description cannot exceed 2000 characters")]
           public string Description { get; init; } = string.Empty;

           /// <summary>
           /// Product price in USD
           /// </summary>
           [Required(ErrorMessage = "Price is required")]
           [Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than 0")]
           public decimal Price { get; init; }

           /// <summary>
           /// Product category
           /// </summary>
           [Required(ErrorMessage = "Category is required")]
           [StringLength(100, MinimumLength = 1, ErrorMessage = "Category must be between 1 and 100 characters")]
           public string Category { get; init; } = string.Empty;

           /// <summary>
           /// Initial stock quantity
           /// </summary>
           [Range(0, int.MaxValue, ErrorMessage = "Stock quantity cannot be negative")]
           public int StockQuantity { get; init; }

           /// <summary>
           /// Product SKU (Stock Keeping Unit)
           /// </summary>
           [Required(ErrorMessage = "SKU is required")]
           [StringLength(50, MinimumLength = 1, ErrorMessage = "SKU must be between 1 and 50 characters")]
           [RegularExpression(@"^[A-Z0-9\-]+$", ErrorMessage = "SKU must contain only uppercase letters, numbers, and hyphens")]
           public string Sku { get; init; } = string.Empty;

           /// <summary>
           /// Indicates if the product is active
           /// </summary>
           public bool? IsActive { get; init; }
       }

       /// <summary>
       /// DTO for updating an existing product
       /// </summary>
       public record UpdateProductDto
       {
           /// <summary>
           /// Product name
           /// </summary>
           [Required(ErrorMessage = "Product name is required")]
           [StringLength(200, MinimumLength = 1, ErrorMessage = "Product name must be between 1 and 200 characters")]
           public string Name { get; init; } = string.Empty;

           /// <summary>
           /// Product description
           /// </summary>
           [StringLength(2000, ErrorMessage = "Description cannot exceed 2000 characters")]
           public string Description { get; init; } = string.Empty;

           /// <summary>
           /// Product price in USD
           /// </summary>
           [Required(ErrorMessage = "Price is required")]
           [Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than 0")]
           public decimal Price { get; init; }

           /// <summary>
           /// Product category
           /// </summary>
           [Required(ErrorMessage = "Category is required")]
           [StringLength(100, MinimumLength = 1, ErrorMessage = "Category must be between 1 and 100 characters")]
           public string Category { get; init; } = string.Empty;

           /// <summary>
           /// Available stock quantity
           /// </summary>
           [Range(0, int.MaxValue, ErrorMessage = "Stock quantity cannot be negative")]
           public int StockQuantity { get; init; }

           /// <summary>
           /// Product SKU (Stock Keeping Unit)
           /// </summary>
           [StringLength(50, MinimumLength = 1, ErrorMessage = "SKU must be between 1 and 50 characters")]
           [RegularExpression(@"^[A-Z0-9\-]+$", ErrorMessage = "SKU must contain only uppercase letters, numbers, and hyphens")]
           public string? Sku { get; init; }

           /// <summary>
           /// Indicates if the product is currently active
           /// </summary>
           public bool? IsActive { get; init; }

           /// <summary>
           /// Indicates if the product is available for sale
           /// </summary>
           public bool? IsAvailable { get; init; }
       }
   }
   ```

### Part 3: Create the Data Context (5 minutes)

**Data/ApplicationDbContext.cs**:
```csharp
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Models;

namespace RestfulAPI.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<Product> Products => Set<Product>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Configure Product entity
            modelBuilder.Entity<Product>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
                entity.Property(e => e.Description).HasMaxLength(2000);
                entity.Property(e => e.Category).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Sku).IsRequired().HasMaxLength(50);
                entity.HasIndex(e => e.Sku).IsUnique();
                entity.Property(e => e.Price).HasColumnType("decimal(18,2)");

                // Add query filter to exclude soft-deleted items
                entity.HasQueryFilter(p => !p.IsDeleted);
            });

            // Seed data
            modelBuilder.Entity<Product>().HasData(
                new Product
                {
                    Id = 1,
                    Name = "Laptop Computer",
                    Description = "High-performance laptop with 16GB RAM and 512GB SSD",
                    Price = 999.99m,
                    Category = "Electronics",
                    StockQuantity = 50,
                    Sku = "ELEC-LAP-001",
                    IsActive = true,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Product
                {
                    Id = 2,
                    Name = "Wireless Mouse",
                    Description = "Ergonomic wireless mouse with precision tracking",
                    Price = 29.99m,
                    Category = "Accessories",
                    StockQuantity = 100,
                    Sku = "ACC-MOU-002",
                    IsActive = true,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Product
                {
                    Id = 3,
                    Name = "Programming Book",
                    Description = "Comprehensive guide to modern software development",
                    Price = 49.99m,
                    Category = "Books",
                    StockQuantity = 25,
                    Sku = "BOOK-PROG-003",
                    IsActive = true,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                }
            );
        }
    }
}
```

### Part 4: Create the Products Controller (15 minutes)

**Controllers/ProductsController.cs**:
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Data;
using RestfulAPI.DTOs;
using RestfulAPI.Models;

namespace RestfulAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class ProductsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<ProductsController> _logger;

        public ProductsController(ApplicationDbContext context, ILogger<ProductsController> logger)
        {
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// Get all products with optional filtering
        /// </summary>
        /// <param name="category">Filter by category name</param>
        /// <param name="name">Filter by product name</param>
        /// <param name="minPrice">Minimum price filter</param>
        /// <param name="maxPrice">Maximum price filter</param>
        /// <returns>List of products</returns>
        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<ProductDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<ProductDto>>> GetProducts(
            [FromQuery] string? category = null,
            [FromQuery] string? name = null,
            [FromQuery] decimal? minPrice = null,
            [FromQuery] decimal? maxPrice = null)
        {
            _logger.LogInformation("Getting products with filters - Category: {Category}, Name: {Name}, MinPrice: {MinPrice}, MaxPrice: {MaxPrice}",
                category, name, minPrice, maxPrice);

            var query = _context.Products.AsQueryable();

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

            var products = await query
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Category = p.Category,
                    StockQuantity = p.StockQuantity,
                    Sku = p.Sku,
                    IsActive = p.IsActive,
                    IsAvailable = p.IsAvailable,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .ToListAsync();

            return Ok(products);
        }

        /// <summary>
        /// Get a specific product by ID
        /// </summary>
        /// <param name="id">Product ID</param>
        /// <returns>Product details</returns>
        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(ProductDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<ProductDto>> GetProduct(int id)
        {
            _logger.LogInformation("Getting product with ID: {ProductId}", id);

            var product = await _context.Products
                .Where(p => p.Id == id)
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Category = p.Category,
                    StockQuantity = p.StockQuantity,
                    Sku = p.Sku,
                    IsActive = p.IsActive,
                    IsAvailable = p.IsAvailable,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .FirstOrDefaultAsync();

            if (product == null)
            {
                _logger.LogWarning("Product with ID {ProductId} not found", id);
                return NotFound(new { message = $"Product with ID {id} not found" });
            }

            return Ok(product);
        }

        /// <summary>
        /// Create a new product
        /// </summary>
        /// <param name="createProductDto">Product creation data</param>
        /// <returns>Created product</returns>
        [HttpPost]
        [ProducesResponseType(typeof(ProductDto), StatusCodes.Status201Created)]
        [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<ProductDto>> CreateProduct([FromBody] CreateProductDto createProductDto)
        {
            _logger.LogInformation("Creating new product: {ProductName}", createProductDto.Name);

            // Check for duplicate SKU
            var skuExists = await _context.Products.AnyAsync(p => p.Sku == createProductDto.Sku);
            if (skuExists)
            {
                return BadRequest(new { message = $"Product with SKU {createProductDto.Sku} already exists" });
            }

            var product = new Product
            {
                Name = createProductDto.Name,
                Description = createProductDto.Description,
                Price = createProductDto.Price,
                Category = createProductDto.Category,
                StockQuantity = createProductDto.StockQuantity,
                Sku = createProductDto.Sku,
                IsActive = createProductDto.IsActive ?? true,
                IsAvailable = true,
                CreatedAt = DateTime.UtcNow
            };

            _context.Products.Add(product);
            await _context.SaveChangesAsync();

            var productDto = new ProductDto
            {
                Id = product.Id,
                Name = product.Name,
                Description = product.Description,
                Price = product.Price,
                Category = product.Category,
                StockQuantity = product.StockQuantity,
                Sku = product.Sku,
                IsActive = product.IsActive,
                IsAvailable = product.IsAvailable,
                CreatedAt = product.CreatedAt,
                UpdatedAt = product.UpdatedAt
            };

            return CreatedAtAction(
                nameof(GetProduct),
                new { id = product.Id },
                productDto);
        }

        /// <summary>
        /// Update an existing product
        /// </summary>
        /// <param name="id">Product ID</param>
        /// <param name="updateProductDto">Updated product data</param>
        /// <returns>No content</returns>
        [HttpPut("{id:int}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> UpdateProduct(int id, [FromBody] UpdateProductDto updateProductDto)
        {
            _logger.LogInformation("Updating product with ID: {ProductId}", id);

            var product = await _context.Products.FindAsync(id);
            if (product == null)
            {
                return NotFound(new { message = $"Product with ID {id} not found" });
            }

            // Check for duplicate SKU (if changed)
            if (!string.IsNullOrEmpty(updateProductDto.Sku) && product.Sku != updateProductDto.Sku)
            {
                var skuExists = await _context.Products.AnyAsync(p => p.Sku == updateProductDto.Sku && p.Id != id);
                if (skuExists)
                {
                    return BadRequest(new { message = $"Product with SKU {updateProductDto.Sku} already exists" });
                }
            }

            product.Name = updateProductDto.Name;
            product.Description = updateProductDto.Description;
            product.Price = updateProductDto.Price;
            product.Category = updateProductDto.Category;
            product.StockQuantity = updateProductDto.StockQuantity;

            if (!string.IsNullOrEmpty(updateProductDto.Sku))
            {
                product.Sku = updateProductDto.Sku;
            }

            if (updateProductDto.IsActive.HasValue)
            {
                product.IsActive = updateProductDto.IsActive.Value;
            }

            if (updateProductDto.IsAvailable.HasValue)
            {
                product.IsAvailable = updateProductDto.IsAvailable.Value;
            }

            product.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return NoContent();
        }

        /// <summary>
        /// Delete a product
        /// </summary>
        /// <param name="id">Product ID</param>
        /// <returns>No content</returns>
        [HttpDelete("{id:int}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteProduct(int id)
        {
            _logger.LogInformation("Deleting product with ID: {ProductId}", id);

            var product = await _context.Products.FindAsync(id);
            if (product == null)
            {
                return NotFound(new { message = $"Product with ID {id} not found" });
            }

            _context.Products.Remove(product);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        /// <summary>
        /// Get products by category
        /// </summary>
        /// <param name="category">Category name</param>
        /// <returns>List of products in the category</returns>
        [HttpGet("by-category/{category}")]
        [ProducesResponseType(typeof(IEnumerable<ProductDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<ProductDto>>> GetProductsByCategory(string category)
        {
            var products = await _context.Products
                .Where(p => p.Category.Contains(category))
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Category = p.Category,
                    StockQuantity = p.StockQuantity,
                    Sku = p.Sku,
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
```

### Part 5: Configure the Application (5 minutes)

Update **Program.cs**:
```csharp
using RestfulAPI.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using System.Reflection;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "RESTful API",
        Version = "v1",
        Description = "A comprehensive API for managing products",
        Contact = new OpenApiContact
        {
            Name = "API Support Team",
            Email = "support@api.com"
        }
    });

    // Include XML comments
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
    {
        c.IncludeXmlComments(xmlPath);
    }
});

// Add Entity Framework
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseInMemoryDatabase("ProductsDb"));

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// Seed the database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    context.Database.EnsureCreated();
}

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "RESTful API V1");
    });
}

app.UseHttpsRedirection();
app.UseCors();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

### Part 6: Test Your API (5 minutes)

1. **Enable XML documentation** in your `.csproj`:
   ```xml
   <PropertyGroup>
     <GenerateDocumentationFile>true</GenerateDocumentationFile>
     <NoWarn>$(NoWarn);1591</NoWarn>
   </PropertyGroup>
   ```

2. **Run the application**:
   ```bash
   dotnet run
   ```

3. **Test with Swagger UI**:
   - Navigate to `https://localhost:[port]/swagger`
   - Test each endpoint:
     - GET `/api/products` - Get all products
     - GET `/api/products/1` - Get specific product
     - POST `/api/products` - Create new product
     - PUT `/api/products/1` - Update product
     - DELETE `/api/products/1` - Delete product

4. **Test with curl or Postman**:
   ```bash
   # Get all products
   curl -X GET https://localhost:5001/api/products

   # Create a new product
   curl -X POST https://localhost:5001/api/products \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Wireless Headphones",
       "description": "High-quality wireless headphones with noise cancellation",
       "price": 199.99,
       "category": "Electronics",
       "stockQuantity": 75,
       "sku": "ELEC-HEAD-004",
       "isActive": true
     }'
   ```

## ✅ Success Criteria

- [ ] API project created and running
- [ ] All CRUD operations working for products
- [ ] Proper HTTP status codes returned
- [ ] Input validation working
- [ ] Swagger documentation available
- [ ] SKU uniqueness validation working
- [ ] Error responses are meaningful

## 🚀 Bonus Challenges

1. **Add Product Search**:
   - Create advanced search endpoint
   - Search by name, description, and category
   - Add price range filtering

2. **Add Product Categories**:
   - Create separate Category entity
   - Implement category management endpoints
   - Add category statistics

3. **Add Pagination**:
   - Implement pagination for product list
   - Add sorting options (by name, price, category)
   - Return pagination metadata in headers

4. **Add Inventory Management**:
   - Create stock adjustment endpoints
   - Add low stock alerts
   - Implement stock history tracking

## 🤔 Reflection Questions

1. Why do we use DTOs instead of exposing entity models directly?
2. What's the purpose of the `[ApiController]` attribute?
3. How does content negotiation work in ASP.NET Core?
4. What are the benefits of using async/await in API controllers?

## 🆘 Troubleshooting

**Issue**: Swagger UI not showing
**Solution**: Ensure you're running in Development mode and accessing the correct URL.

**Issue**: 404 errors on API calls
**Solution**: Check the route attributes and ensure the URL matches the controller and action routes.

**Issue**: Validation not working
**Solution**: Ensure `[ApiController]` attribute is present and model state is valid.

---

