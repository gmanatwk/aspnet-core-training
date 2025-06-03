# Module 3: Working with Web APIs in ASP.NET Core

## 🎯 Learning Objectives

By the end of this module, students will be able to:
- ✅ Understand RESTful API principles and design
- ✅ Handle HTTP methods and status codes properly
- ✅ Structure Web APIs following best practices
- ✅ Implement comprehensive API security
- ✅ Create well-documented APIs with Swagger
- ✅ Handle API versioning and error responses

## 📖 Module Overview

**Duration**: 2.5 hours  
**Skill Level**: Intermediate  
**Prerequisites**: Module 1 completion, basic HTTP knowledge

### Topics Covered:
1. **Introduction to RESTful Web APIs**
2. **Handling HTTP Methods and Status Codes**
3. **Structuring Web APIs in ASP.NET Core**
4. **Securing APIs**
5. **API Documentation with Swagger**
6. **Error Handling and Validation**

## 🏗️ Project Structure

```
Module03-Working-with-Web-APIs/
├── README.md (this file)
├── SourceCode/
│   ├── RestfulAPI/           # Complete RESTful API example
│   ├── APIStructure/         # Well-structured API project
│   ├── SecureAPI/           # API with authentication
│   └── MinimalAPI/          # Minimal API examples
├── Exercises/
│   ├── Exercise01/          # Create basic API
│   ├── Exercise02/          # Add CRUD operations
│   ├── Exercise03/          # Implement security
│   └── Solutions/           # Exercise solutions
└── Resources/
    ├── rest-principles.md   # REST architecture guide
    ├── api-testing.md       # API testing strategies
    └── swagger-guide.md     # Swagger documentation
```

## 🚀 Getting Started

### 1. Prerequisites Check
Ensure you have:
- ✅ .NET 8.0 SDK
- ✅ Visual Studio 2022 or VS Code
- ✅ Postman or similar API testing tool
- ✅ Basic understanding of HTTP methods

### 2. Quick Start
1. Navigate to `SourceCode/RestfulAPI`
2. Run the API:
   ```bash
   dotnet run
   ```
3. Open browser to `https://localhost:5001/swagger`
4. Test the API endpoints

## 📚 Key Concepts

### What is REST?

**REST** (Representational State Transfer) is an architectural style for designing networked applications:

#### **Core Principles:**
1. **🔄 Stateless** - Each request contains all needed information
2. **📍 Resource-Based** - Everything is a resource with unique URIs
3. **🌐 Uniform Interface** - Consistent interaction patterns
4. **🎭 Representation** - Resources can be represented in multiple formats
5. **🏗️ Layered System** - Components are organized in layers

#### **HTTP Methods (CRUD Operations):**
| Method | Purpose | Example | Status Code |
|--------|---------|---------|-------------|
| **GET** | Retrieve data | `GET /api/products` | 200 OK |
| **POST** | Create new resource | `POST /api/products` | 201 Created |
| **PUT** | Update entire resource | `PUT /api/products/1` | 200 OK |
| **PATCH** | Partial update | `PATCH /api/products/1` | 200 OK |
| **DELETE** | Remove resource | `DELETE /api/products/1` | 204 No Content |

#### **HTTP Status Codes:**
```
2xx Success
├── 200 OK - Request successful
├── 201 Created - Resource created
├── 202 Accepted - Request accepted
└── 204 No Content - Successful, no content

4xx Client Errors
├── 400 Bad Request - Invalid request
├── 401 Unauthorized - Authentication required
├── 403 Forbidden - Access denied
├── 404 Not Found - Resource not found
└── 409 Conflict - Resource conflict

5xx Server Errors
├── 500 Internal Server Error - Server error
├── 502 Bad Gateway - Invalid response
└── 503 Service Unavailable - Service down
```

## 🛠️ Implementation Examples

### 1. Complete Products API Controller

```csharp
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(IProductService productService, ILogger<ProductsController> logger)
    {
        _productService = productService;
        _logger = logger;
    }

    /// <summary>
    /// Get all products with optional filtering
    /// </summary>
    /// <param name="category">Filter by category</param>
    /// <param name="minPrice">Minimum price filter</param>
    /// <param name="maxPrice">Maximum price filter</param>
    /// <param name="pageNumber">Page number for pagination</param>
    /// <param name="pageSize">Page size for pagination</param>
    /// <returns>Paginated list of products</returns>
    [HttpGet]
    [ProducesResponseType(typeof(PagedResponse<ProductDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<PagedResponse<ProductDto>>> GetProducts(
        [FromQuery] string? category = null,
        [FromQuery] decimal? minPrice = null,
        [FromQuery] decimal? maxPrice = null,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 10)
    {
        _logger.LogInformation("Getting products with filters - Category: {Category}, Price: {MinPrice}-{MaxPrice}", 
            category, minPrice, maxPrice);

        var result = await _productService.GetProductsAsync(category, minPrice, maxPrice, pageNumber, pageSize);
        return Ok(result);
    }

    /// <summary>
    /// Get product by ID
    /// </summary>
    /// <param name="id">Product ID</param>
    /// <returns>Product details</returns>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(ProductDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ProductDto>> GetProduct(int id)
    {
        _logger.LogInformation("Getting product with ID: {ProductId}", id);
        
        var product = await _productService.GetProductByIdAsync(id);
        if (product == null)
        {
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
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        _logger.LogInformation("Creating new product: {ProductName}", createProductDto.Name);
        
        var product = await _productService.CreateProductAsync(createProductDto);
        
        return CreatedAtAction(
            nameof(GetProduct), 
            new { id = product.Id }, 
            product);
    }

    /// <summary>
    /// Update an existing product
    /// </summary>
    /// <param name="id">Product ID</param>
    /// <param name="updateProductDto">Updated product data</param>
    /// <returns>Updated product</returns>
    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(ProductDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<ProductDto>> UpdateProduct(int id, [FromBody] UpdateProductDto updateProductDto)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        _logger.LogInformation("Updating product with ID: {ProductId}", id);
        
        var product = await _productService.UpdateProductAsync(id, updateProductDto);
        if (product == null)
        {
            return NotFound(new { message = $"Product with ID {id} not found" });
        }

        return Ok(product);
    }

    /// <summary>
    /// Partially update a product
    /// </summary>
    /// <param name="id">Product ID</param>
    /// <param name="patchDocument">JSON Patch document</param>
    /// <returns>Updated product</returns>
    [HttpPatch("{id:int}")]
    [ProducesResponseType(typeof(ProductDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<ProductDto>> PatchProduct(int id, [FromBody] JsonPatchDocument<UpdateProductDto> patchDocument)
    {
        if (patchDocument == null)
        {
            return BadRequest("Patch document is required");
        }

        var product = await _productService.PatchProductAsync(id, patchDocument, ModelState);
        if (product == null)
        {
            return NotFound(new { message = $"Product with ID {id} not found" });
        }

        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        return Ok(product);
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
        
        var deleted = await _productService.DeleteProductAsync(id);
        if (!deleted)
        {
            return NotFound(new { message = $"Product with ID {id} not found" });
        }

        return NoContent();
    }

    /// <summary>
    /// Get product categories
    /// </summary>
    /// <returns>List of categories</returns>
    [HttpGet("categories")]
    [ProducesResponseType(typeof(IEnumerable<string>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<string>>> GetCategories()
    {
        var categories = await _productService.GetCategoriesAsync();
        return Ok(categories);
    }
}
```

### 2. DTOs and Models

```csharp
// Product DTOs
public record ProductDto(
    int Id,
    string Name,
    string Description,
    decimal Price,
    int StockQuantity,
    string Category,
    bool IsActive,
    DateTime CreatedAt,
    DateTime? UpdatedAt
);

public record CreateProductDto(
    [Required] [StringLength(200, MinimumLength = 1)] string Name,
    [StringLength(1000)] string Description,
    [Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than 0")] decimal Price,
    [Range(0, int.MaxValue, ErrorMessage = "Stock quantity cannot be negative")] int StockQuantity,
    [Required] [StringLength(100, MinimumLength = 1)] string Category
);

public record UpdateProductDto(
    [Required] [StringLength(200, MinimumLength = 1)] string Name,
    [StringLength(1000)] string Description,
    [Range(0.01, double.MaxValue)] decimal Price,
    [Range(0, int.MaxValue)] int StockQuantity,
    [Required] [StringLength(100, MinimumLength = 1)] string Category,
    bool IsActive
);

// Pagination models
public class PagedResponse<T>
{
    public IEnumerable<T> Data { get; set; } = new List<T>();
    public int PageNumber { get; set; }
    public int PageSize { get; set; }
    public int TotalPages { get; set; }
    public int TotalRecords { get; set; }
    public bool HasNextPage { get; set; }
    public bool HasPreviousPage { get; set; }
}

// API Response wrapper
public class ApiResponse<T>
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public T? Data { get; set; }
    public List<string> Errors { get; set; } = new();
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    public static ApiResponse<T> SuccessResult(T data, string message = "Operation successful")
    {
        return new ApiResponse<T>
        {
            Success = true,
            Message = message,
            Data = data
        };
    }

    public static ApiResponse<T> ErrorResult(string message, List<string>? errors = null)
    {
        return new ApiResponse<T>
        {
            Success = false,
            Message = message,
            Errors = errors ?? new List<string>()
        };
    }
}
```

### 3. Program.cs Configuration

```csharp
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers(options =>
{
    // Configure API behavior
    options.ReturnHttpNotAcceptable = true;
    options.Filters.Add<ValidationActionFilter>();
})
.AddNewtonsoftJson() // For JSON Patch support
.ConfigureApiBehaviorOptions(options =>
{
    // Customize validation error responses
    options.InvalidModelStateResponseFactory = context =>
    {
        var errors = context.ModelState
            .Where(x => x.Value.Errors.Count > 0)
            .SelectMany(x => x.Value.Errors)
            .Select(x => x.ErrorMessage);

        return new BadRequestObjectResult(new
        {
            message = "Validation failed",
            errors = errors
        });
    };
});

// Add API versioning
builder.Services.AddApiVersioning(opt =>
{
    opt.DefaultApiVersion = new ApiVersion(1, 0);
    opt.AssumeDefaultVersionWhenUnspecified = true;
    opt.ApiVersionReader = ApiVersionReader.Combine(
        new UrlSegmentApiVersionReader(),
        new QueryStringApiVersionReader("version"),
        new HeaderApiVersionReader("X-Version"),
        new MediaTypeApiVersionReader("ver")
    );
});

builder.Services.AddVersionedApiExplorer(setup =>
{
    setup.GroupNameFormat = "'v'VVV";
    setup.SubstituteApiVersionInUrl = true;
});

// Add authentication
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
        };
    });

builder.Services.AddAuthorization();

// Add Swagger/OpenAPI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Products API",
        Version = "v1",
        Description = "A comprehensive API for managing products",
        Contact = new OpenApiContact
        {
            Name = "API Support",
            Email = "your-support-email"
        }
    });

    // Add JWT authentication to Swagger
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Enter 'Bearer' [space] and then your token",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });

    // Include XML comments
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    c.IncludeXmlComments(xmlPath);
});

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowSpecificOrigin", policy =>
    {
        policy.WithOrigins("https://localhost:3000", "https://myapp.com")
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

// Register services
builder.Services.AddScoped<IProductService, ProductService>();

// Add health checks
builder.Services.AddHealthChecks();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Products API V1");
        c.RoutePrefix = string.Empty; // Serve Swagger UI at root
    });
}

app.UseHttpsRedirection();

// Add security headers
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
    context.Response.Headers.Add("X-Frame-Options", "DENY");
    context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
    await next();
});

app.UseCors("AllowSpecificOrigin");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health");

// Global exception handling
app.UseExceptionHandler("/Error");

app.Run();
```

## 🔒 API Security Best Practices

### 1. Authentication & Authorization

```csharp
// Secure endpoint example
[HttpGet("secure")]
[Authorize(Roles = "Admin,Manager")]
[ProducesResponseType(typeof(IEnumerable<ProductDto>), StatusCodes.Status200OK)]
[ProducesResponseType(StatusCodes.Status401Unauthorized)]
[ProducesResponseType(StatusCodes.Status403Forbidden)]
public async Task<ActionResult<IEnumerable<ProductDto>>> GetSecureProducts()
{
    var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    var userRoles = User.FindAll(ClaimTypes.Role).Select(c => c.Value);
    
    _logger.LogInformation("User {UserId} with roles {Roles} accessing secure products", 
        userId, string.Join(", ", userRoles));
    
    var products = await _productService.GetAllProductsAsync();
    return Ok(products);
}
```

### 2. Input Validation

```csharp
public class ValidationActionFilter : ActionFilterAttribute
{
    public override void OnActionExecuting(ActionExecutingContext context)
    {
        if (!context.ModelState.IsValid)
        {
            var errors = context.ModelState
                .Where(x => x.Value.Errors.Count > 0)
                .ToDictionary(
                    kvp => kvp.Key,
                    kvp => kvp.Value.Errors.Select(e => e.ErrorMessage).ToArray()
                );

            context.Result = new BadRequestObjectResult(new
            {
                message = "Validation failed",
                errors = errors
            });
        }
    }
}
```

### 3. Rate Limiting

```csharp
// Install: AspNetCoreRateLimit package
services.Configure<IpRateLimitOptions>(Configuration.GetSection("IpRateLimiting"));
services.AddSingleton<IIpPolicyStore, MemoryCacheIpPolicyStore>();
services.AddSingleton<IRateLimitCounterStore, MemoryCacheRateLimitCounterStore>();
services.AddSingleton<IRateLimitConfiguration, RateLimitConfiguration>();

// In pipeline
app.UseIpRateLimiting();
```

## 📊 API Testing

### 1. Unit Testing Controllers

```csharp
[Test]
public async Task GetProduct_ExistingId_ReturnsOkResult()
{
    // Arrange
    var mockService = new Mock<IProductService>();
    var product = new ProductDto(1, "Test Product", "Description", 99.99m, 10, "Electronics", true, DateTime.Now, null);
    mockService.Setup(s => s.GetProductByIdAsync(1)).ReturnsAsync(product);
    
    var controller = new ProductsController(mockService.Object, Mock.Of<ILogger<ProductsController>>());

    // Act
    var result = await controller.GetProduct(1);

    // Assert
    var okResult = result.Result as OkObjectResult;
    Assert.IsNotNull(okResult);
    Assert.AreEqual(200, okResult.StatusCode);
    Assert.AreEqual(product, okResult.Value);
}
```

### 2. Integration Testing

```csharp
public class ProductsIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public ProductsIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = _factory.CreateClient();
    }

    [Test]
    public async Task GetProducts_ReturnsSuccessAndCorrectContentType()
    {
        // Act
        var response = await _client.GetAsync("/api/products");

        // Assert
        response.EnsureSuccessStatusCode();
        Assert.AreEqual("application/json; charset=utf-8", 
            response.Content.Headers.ContentType?.ToString());
    }
}
```

## 💡 Best Practices

### 1. **API Design**
- ✅ Use nouns for resources, not verbs
- ✅ Use HTTP methods correctly
- ✅ Implement proper status codes
- ✅ Version your APIs
- ✅ Use consistent naming conventions

### 2. **Error Handling**
- ✅ Return meaningful error messages
- ✅ Use proper HTTP status codes
- ✅ Include error details for debugging
- ✅ Don't expose sensitive information

### 3. **Performance**
- ✅ Implement pagination for large datasets
- ✅ Use async/await for I/O operations
- ✅ Cache frequently accessed data
- ✅ Optimize database queries

### 4. **Security**
- ✅ Always validate input
- ✅ Use HTTPS for all communications
- ✅ Implement proper authentication/authorization
- ✅ Apply rate limiting
- ✅ Sanitize output data

## ❓ Quiz Questions

1. What are the five core principles of REST architecture?
2. Which HTTP method should you use to partially update a resource?
3. What status code should be returned when a resource is successfully created?
4. How do you implement API versioning in ASP.NET Core?
5. What are the benefits of using DTOs in API development?

## 🎯 Exercises

### Exercise 1: Create Basic CRUD API
**Objective**: Build a complete CRUD API for managing users
**Time**: 45 minutes
**Instructions**: See `Exercises/Exercise01/README.md`

### Exercise 2: Add Authentication
**Objective**: Secure your API with JWT authentication
**Time**: 40 minutes
**Instructions**: See `Exercises/Exercise02/README.md`

### Exercise 3: API Documentation
**Objective**: Document your API with Swagger and add versioning
**Time**: 35 minutes
**Instructions**: See `Exercises/Exercise03/README.md`

## 📖 Additional Resources

- 📚 [REST API Design Best Practices](https://docs.microsoft.com/rest/api/azure/)
- 🎥 [ASP.NET Core Web API Tutorial](https://www.youtube.com/watch?v=_8nLTsJaWj4)
- 📝 [HTTP Status Code Guide](https://httpstatuses.com/)
- 🛠️ [Postman API Testing](https://learning.postman.com/docs/getting-started/introduction/)
- 📚 [OpenAPI Specification](https://swagger.io/specification/)

## 🔗 Next Module

Ready for security? Continue to:
**[Module 4: Authentication and Authorization in ASP.NET Core](../Module04-Authentication-and-Authorization/README.md)**

## 🆘 Need Help?

- 💬 Ask questions during the live session
- 🔍 Use Swagger UI for API testing
- 📚 Review REST principles in Resources folder

---

**Build APIs that developers love to use! 🚀🔌**