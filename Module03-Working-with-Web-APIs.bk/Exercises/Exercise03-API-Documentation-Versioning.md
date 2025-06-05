# Exercise 3: API Documentation and Versioning

## 🎯 Objective
Enhance your RESTful API with comprehensive documentation using Swagger/OpenAPI, implement API versioning, and add advanced features like health checks and API analytics.

## ⏱️ Estimated Time
40 minutes

## 📋 Prerequisites
- .NET 8.0 SDK installed
- Understanding of API documentation concepts
- Basic knowledge of versioning strategies
- Familiarity with Exercises 1 and 2 concepts (setup script provides complete project)

## ⚠️ Important Notes

This exercise includes several fixes for common compilation issues:
- Updated API versioning configuration to use `.AddApiExplorer()` instead of `.AddVersionedApiExplorer()`
- Fixed `SwaggerDefaultValues` class to handle deprecated API detection properly
- Added missing using directive `Microsoft.AspNetCore.Diagnostics.HealthChecks`
- Updated `ConfigureSwaggerOptions` to use proper extension methods

These fixes ensure the code compiles and runs correctly with .NET 8.0 and the latest package versions.

**Note about code consistency**: 
- This exercise demonstrates versioning using a Books/Library theme as an example
- If you're continuing from Exercise 1 & 2 (Products theme), you can adapt the concepts to your existing ProductsController
- The versioning, documentation, and health check concepts apply regardless of the domain model used

**Important**: Use `Asp.Versioning` namespace, not the old `Microsoft.AspNetCore.Mvc` versioning:
```csharp
using Asp.Versioning;  // Correct
// NOT using Microsoft.AspNetCore.Mvc.ApiVersion;  // Old/Wrong
```

## 📝 Instructions

### Part 0: Project Setup (2 minutes)

**IMPORTANT**: This exercise builds on your existing Products API from Exercises 1 & 2. 
- DO NOT create any BooksController files
- DO NOT copy any code that references Books, Library, Authors, or Categories
- You will version your existing ProductsController
- Focus only on Products - the same domain you've been working with

**If continuing from Exercise 2:**
- Continue using your existing RestfulAPI project
- Skip to Part 1

**If starting fresh or coming from Exercise 1:**
```bash
# Continue with your RestfulAPI project from previous exercises
cd RestfulAPI

# Add required NuGet packages
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore
dotnet add package System.IdentityModel.Tokens.Jwt
dotnet add package Asp.Versioning.Mvc
dotnet add package Asp.Versioning.Mvc.ApiExplorer
dotnet add package AspNetCore.HealthChecks.UI
dotnet add package AspNetCore.HealthChecks.UI.Client
dotnet add package AspNetCore.HealthChecks.UI.InMemory.Storage
dotnet add package Swashbuckle.AspNetCore.Annotations

# Remove old versioning package if present
dotnet remove package Microsoft.AspNetCore.Mvc.Versioning.ApiExplorer

# Verify setup
dotnet build
```

### Part 1: Create Required DTOs and Models (5 minutes)

**For students continuing from Exercise 1 & 2:**

You need to create these NEW files in your DTOs folder:
- [ ] ProductDtoV2.cs (extends your existing ProductDto)
- [ ] PaginationDto.cs (new pagination classes)

Do NOT modify your existing ProductDto.cs - we're adding new files.

1. **Add versioning DTOs to your existing DTOs folder**:

**IMPORTANT**: You MUST create this new file for V2 to work:

**DTOs/ProductDtoV2.cs**:
```csharp
using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.DTOs
{
    /// <summary>
    /// Enhanced product DTO for API version 2 - extends your existing ProductDto
    /// </summary>
    public record ProductDtoV2 : ProductDto
    {
        /// <summary>
        /// Product manufacturer
        /// </summary>
        public string Manufacturer { get; set; } = string.Empty;

        /// <summary>
        /// Product rating (1-5 stars)
        /// </summary>
        public decimal Rating { get; set; }

        /// <summary>
        /// Number of reviews
        /// </summary>
        public int ReviewCount { get; set; }

        /// <summary>
        /// Product dimensions
        /// </summary>
        public string Dimensions { get; set; } = string.Empty;

        /// <summary>
        /// Product weight
        /// </summary>
        public string Weight { get; set; } = string.Empty;

        /// <summary>
        /// Tags associated with the product
        /// </summary>
        public List<string> Tags { get; set; } = new();

        /// <summary>
        /// Related product IDs
        /// </summary>
        public List<int> RelatedProductIds { get; set; } = new();
    }
}
```

2. **Add pagination DTOs** to your existing DTOs folder:

**DTOs/PaginationDto.cs**:
```csharp
using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.DTOs
{
    /// <summary>
    /// Pagination parameters for API requests
    /// </summary>
    public class PaginationParams
    {
        /// <summary>
        /// Page number (1-based)
        /// </summary>
        [Range(1, int.MaxValue)]
        public int PageNumber { get; set; } = 1;

        /// <summary>
        /// Number of items per page
        /// </summary>
        [Range(1, 100)]
        public int PageSize { get; set; } = 10;
    }

    /// <summary>
    /// Paginated response wrapper
    /// </summary>
    /// <typeparam name="T">Type of data being paginated</typeparam>
    public class PaginatedResponse<T>
    {
        /// <summary>
        /// Current page number
        /// </summary>
        public int PageNumber { get; set; }

        /// <summary>
        /// Number of items per page
        /// </summary>
        public int PageSize { get; set; }

        /// <summary>
        /// Total number of items
        /// </summary>
        public int TotalCount { get; set; }

        /// <summary>
        /// Total number of pages
        /// </summary>
        public int TotalPages { get; set; }

        /// <summary>
        /// Whether there is a previous page
        /// </summary>
        public bool HasPreviousPage { get; set; }

        /// <summary>
        /// Whether there is a next page
        /// </summary>
        public bool HasNextPage { get; set; }

        /// <summary>
        /// The actual data items
        /// </summary>
        public List<T> Data { get; set; } = new();

        /// <summary>
        /// Create a paginated response
        /// </summary>
        public static PaginatedResponse<T> Create(List<T> data, int pageNumber, int pageSize, int totalCount)
        {
            var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);

            return new PaginatedResponse<T>
            {
                PageNumber = pageNumber,
                PageSize = pageSize,
                TotalCount = totalCount,
                TotalPages = totalPages,
                HasPreviousPage = pageNumber > 1,
                HasNextPage = pageNumber < totalPages,
                Data = data
            };
        }
    }

    /// <summary>
    /// Filter parameters for book searches
    /// </summary>
    public class BookFilterDto
    {
        /// <summary>
        /// Filter by category
        /// </summary>
        public string? Category { get; set; }

        /// <summary>
        /// Filter by author
        /// </summary>
        public string? Author { get; set; }

        /// <summary>
        /// Filter by publication year
        /// </summary>
        public int? Year { get; set; }

        /// <summary>
        /// Search in title and description
        /// </summary>
        public string? SearchTerm { get; set; }

        /// <summary>
        /// Minimum rating filter
        /// </summary>
        [Range(1, 5)]
        public decimal? MinRating { get; set; }

        /// <summary>
        /// Filter by language
        /// </summary>
        public string? Language { get; set; }

        /// <summary>
        /// Filter by tags
        /// </summary>
        public List<string>? Tags { get; set; }
    }

    /// <summary>
    /// Result of bulk operations
    /// </summary>
    public class BulkOperationResult
    {
        /// <summary>
        /// Number of items successfully processed
        /// </summary>
        public int SuccessCount { get; set; }

        /// <summary>
        /// Number of items that failed processing
        /// </summary>
        public int FailureCount { get; set; }

        /// <summary>
        /// Total number of items processed
        /// </summary>
        public int TotalCount { get; set; }

        /// <summary>
        /// List of errors that occurred
        /// </summary>
        public List<BulkOperationError> Errors { get; set; } = new();

        /// <summary>
        /// IDs of successfully created items
        /// </summary>
        public List<int> CreatedIds { get; set; } = new();
    }

    /// <summary>
    /// Error information for bulk operations
    /// </summary>
    public class BulkOperationError
    {
        /// <summary>
        /// Index of the item that failed
        /// </summary>
        public int Index { get; set; }

        /// <summary>
        /// Error message
        /// </summary>
        public string Message { get; set; } = string.Empty;

        /// <summary>
        /// The item that failed (optional)
        /// </summary>
        public object? Item { get; set; }
    }
}
```

### Part 2: Enhanced Swagger Documentation (10 minutes)

**Note**: All required packages are already installed by the setup script with correct versions.

1. **Create Swagger configuration class**:

   **Configuration/ConfigureSwaggerOptions.cs**:
   ```csharp
   using System;
   using System.Linq;
   using Asp.Versioning.ApiExplorer;
   using Microsoft.Extensions.Options;
   using Microsoft.OpenApi.Models;
   using Swashbuckle.AspNetCore.SwaggerGen;

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
               // Add a swagger document for each discovered API version
               foreach (var description in _provider.ApiVersionDescriptions)
               {
                   options.SwaggerDoc(description.GroupName, CreateInfoForApiVersion(description));
               }

               // Add custom operation filter
               options.OperationFilter<SwaggerDefaultValues>();

               // Include XML comments
               var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
               var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
               if (File.Exists(xmlPath))
               {
                   options.IncludeXmlComments(xmlPath, true);
               }

               // Add security definition for JWT
               options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
               {
                   Description = @"JWT Authorization header using the Bearer scheme.
                                 Enter 'Bearer' [space] and then your token in the text input below.
                                 Example: 'Bearer 12345abcdef'",
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

               options.DocInclusionPredicate((name, api) => true);
           }

           private static OpenApiInfo CreateInfoForApiVersion(ApiVersionDescription description)
           {
               var info = new OpenApiInfo
               {
                   Title = "RESTful API",
                   Version = description.ApiVersion.ToString(),
                   Description = "A comprehensive API for managing products",
                   Contact = new OpenApiContact
                   {
                       Name = "API Support Team",
                       Email = "support@api.com",
                       Url = new Uri("https://api.com/support")
                   },
                   License = new OpenApiLicense
                   {
                       Name = "MIT License",
                       Url = new Uri("https://opensource.org/licenses/MIT")
                   }
               };

               if (description.IsDeprecated)
               {
                   info.Description += " This API version has been deprecated.";
               }

               return info;
           }
       }

       public class SwaggerDefaultValues : IOperationFilter
       {
           public void Apply(OpenApiOperation operation, OperationFilterContext context)
           {
               var apiDescription = context.ApiDescription;

               // Check if the API is deprecated (simplified check)
               operation.Deprecated |= apiDescription.CustomAttributes().OfType<ObsoleteAttribute>().Any();

               foreach (var responseType in context.ApiDescription.SupportedResponseTypes)
               {
                   var responseKey = responseType.IsDefaultResponse ? "default" : responseType.StatusCode.ToString();
                   if (operation.Responses.ContainsKey(responseKey))
                   {
                       var response = operation.Responses[responseKey];

                       foreach (var contentType in response.Content.Keys.ToList())
                       {
                           if (responseType.ApiResponseFormats.All(x => x.MediaType != contentType))
                           {
                               response.Content.Remove(contentType);
                           }
                       }
                   }
               }

               if (operation.Parameters == null)
                   return;

               foreach (var parameter in operation.Parameters)
               {
                   var description = apiDescription.ParameterDescriptions.FirstOrDefault(p => p.Name == parameter.Name);
                   if (description != null)
                   {
                       parameter.Description ??= description.ModelMetadata?.Description;

                       if (parameter.Schema.Default == null && description.DefaultValue != null)
                       {
                           var defaultValueJson = System.Text.Json.JsonSerializer.Serialize(description.DefaultValue);
                           parameter.Schema.Default = OpenApiAnyFactory.CreateFromJson(defaultValueJson);
                       }

                       parameter.Required |= description.IsRequired;
                   }
               }
           }
       }
   }
   ```

2. **Create the ConfigureSwaggerOptions.cs file** as shown above. This file provides:
   - API versioning support with proper document generation
   - JWT Bearer authentication configuration
   - XML comments inclusion with dynamic assembly name detection
   - Custom operation filters for enhanced documentation
   - Proper API metadata (title, description, contact info)

3. **Add XML documentation** to your models and controllers:

   Update your `.csproj` file:
   ```xml
   <PropertyGroup>
     <GenerateDocumentationFile>true</GenerateDocumentationFile>
     <NoWarn>$(NoWarn);1591</NoWarn>
   </PropertyGroup>
   ```

   Add comprehensive documentation to your DTOs:
   ```csharp
   namespace RestfulAPI.DTOs
   {
       /// <summary>
       /// Represents a book in the library system
       /// </summary>
       public record BookDto
       {
           /// <summary>
           /// Unique identifier for the book
           /// </summary>
           /// <example>123</example>
           public int Id { get; init; }

           /// <summary>
           /// Title of the book
           /// </summary>
           /// <example>The Great Gatsby</example>
           public string Title { get; init; } = string.Empty;

           /// <summary>
           /// ISBN-13 number in format XXX-XXXXXXXXXX
           /// </summary>
           /// <example>978-0141439518</example>
           public string ISBN { get; init; } = string.Empty;

           /// <summary>
           /// Year the book was published
           /// </summary>
           /// <example>1925</example>
           public int PublicationYear { get; init; }

           /// <summary>
           /// Total number of pages
           /// </summary>
           /// <example>180</example>
           public int NumberOfPages { get; init; }

           /// <summary>
           /// Brief summary of the book's content
           /// </summary>
           /// <example>A story about the Jazz Age in the United States</example>
           public string Summary { get; init; } = string.Empty;

           /// <summary>
           /// Full name of the book's author
           /// </summary>
           /// <example>F. Scott Fitzgerald</example>
           public string AuthorName { get; init; } = string.Empty;

           /// <summary>
           /// Category/genre of the book
           /// </summary>
           /// <example>Fiction</example>
           public string CategoryName { get; init; } = string.Empty;

           /// <summary>
           /// Timestamp when the book was added to the system
           /// </summary>
           /// <example>2024-01-15T10:30:00Z</example>
           public DateTime CreatedAt { get; init; }

           /// <summary>
           /// Timestamp of the last update (null if never updated)
           /// </summary>
           /// <example>2024-01-20T14:45:00Z</example>
           public DateTime? UpdatedAt { get; init; }
       }
   }
   ```

### Part 3: Implement API Versioning (10 minutes)

1. **Update your ProductsController with missing using directives**:

Add these using statements to your existing `Controllers/ProductsController.cs`:
```csharp
using Microsoft.AspNetCore.Authorization;
using RestfulAPI.DTOs;
```

2. **Create versioned controllers from your existing ProductsController**:

First, create folders for versioned controllers:
```bash
mkdir Controllers/V1
mkdir Controllers/V2
```

3. **Move and update your existing ProductsController to V1**:

   a. Move your existing `Controllers/ProductsController.cs` to `Controllers/V1/ProductsController.cs`
   
   b. Update the file with these changes:
   - Add `using Asp.Versioning;` at the top
   - Change namespace from `RestfulAPI.Controllers` to `RestfulAPI.Controllers.V1`
   - Add `[ApiVersion("1.0")]` attribute
   - Change route from `[Route("api/[controller]")]` to `[Route("api/v{version:apiVersion}/[controller]")]`
   
   Your V1 controller should look like this (keeping all your existing methods):
   ```csharp
   using Asp.Versioning;
   using Microsoft.AspNetCore.Authorization;
   using Microsoft.AspNetCore.Mvc;
   using Microsoft.EntityFrameworkCore;
   using RestfulAPI.Data;
   using RestfulAPI.DTOs;
   using RestfulAPI.Models;

   namespace RestfulAPI.Controllers.V1
   {
       [ApiController]
       [ApiVersion("1.0")]
       [Route("api/v{version:apiVersion}/[controller]")]
       [Produces("application/json")]
       [Authorize]
       public class ProductsController : ControllerBase
       {
           // Keep ALL your existing code here - constructor, GetProducts, GetProduct, 
           // CreateProduct, UpdateProduct, DeleteProduct methods
           // Just copy them as-is from your original controller
       }
   }
   ```

4. **Create V2 ProductsController with enhanced features**:

   Copy your V1 controller to create a V2 version with enhancements:
   
   **Controllers/V2/ProductsController.cs**:
```csharp
using Asp.Versioning;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Data;
using RestfulAPI.DTOs;
using RestfulAPI.Models;

namespace RestfulAPI.Controllers.V2
{
    [ApiController]
    [ApiVersion("2.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [Produces("application/json")]
    [Authorize]
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
        /// Get all products with pagination and enhanced data
        /// </summary>
        [HttpGet]
        [AllowAnonymous]
        public async Task<ActionResult<PaginatedResponse<ProductDtoV2>>> GetProducts(
            [FromQuery] PaginationParams pagination,
            [FromQuery] string? category = null,
            [FromQuery] string? name = null,
            [FromQuery] decimal? minPrice = null,
            [FromQuery] decimal? maxPrice = null)
        {
            var query = _context.Products.AsQueryable();

            // Apply filters (same as V1)
            if (!string.IsNullOrWhiteSpace(category))
                query = query.Where(p => p.Category.Contains(category));
            
            if (!string.IsNullOrWhiteSpace(name))
                query = query.Where(p => p.Name.Contains(name));
            
            if (minPrice.HasValue)
                query = query.Where(p => p.Price >= minPrice.Value);
            
            if (maxPrice.HasValue)
                query = query.Where(p => p.Price <= maxPrice.Value);

            var totalCount = await query.CountAsync();

            var products = await query
                .Skip((pagination.PageNumber - 1) * pagination.PageSize)
                .Take(pagination.PageSize)
                .Select(p => new ProductDtoV2
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
                    UpdatedAt = p.UpdatedAt,
                    // V2 enhanced properties
                    Manufacturer = "Sample Manufacturer",
                    Rating = 4.5m,
                    ReviewCount = 42,
                    Dimensions = "10x10x10 cm",
                    Weight = "1 kg",
                    Tags = new List<string> { p.Category, "Popular" },
                    RelatedProductIds = new List<int> { 1, 2, 3 }
                })
                .ToListAsync();

            return Ok(PaginatedResponse<ProductDtoV2>.Create(
                products, 
                pagination.PageNumber, 
                pagination.PageSize, 
                totalCount));
        }

        // Copy other methods from V1 and adapt as needed
    }
}
```

5. **Create complete Program.cs configuration**:

   **Program.cs**:
   ```csharp
   using System.Text;
   using Asp.Versioning;
   using Asp.Versioning.ApiExplorer;
   using HealthChecks.UI.Client;
   using RestfulAPI.Configuration;
   using RestfulAPI.Data;
   using RestfulAPI.HealthChecks;
   using RestfulAPI.Middleware;
   using RestfulAPI.Models.Auth;
   using RestfulAPI.Services;
   using Microsoft.AspNetCore.Authentication.JwtBearer;
   using Microsoft.AspNetCore.Diagnostics.HealthChecks;
   using Microsoft.AspNetCore.Identity;
   using Microsoft.EntityFrameworkCore;
   using Microsoft.Extensions.Diagnostics.HealthChecks;
   using Microsoft.Extensions.Options;
   using Microsoft.IdentityModel.Tokens;
   using Swashbuckle.AspNetCore.SwaggerGen;

   var builder = WebApplication.CreateBuilder(args);

   // Add services to the container
   builder.Services.AddControllers();
   builder.Services.AddEndpointsApiExplorer();

   // Add Entity Framework
   builder.Services.AddDbContext<ApplicationDbContext>(options =>
       options.UseInMemoryDatabase("RestfulApiDb"));

   // Add Identity
   builder.Services.AddIdentity<User, IdentityRole>(options =>
   {
       options.Password.RequireDigit = true;
       options.Password.RequireLowercase = true;
       options.Password.RequireNonAlphanumeric = false;
       options.Password.RequireUppercase = true;
       options.Password.RequiredLength = 6;
       options.Password.RequiredUniqueChars = 1;
       options.User.RequireUniqueEmail = true;
   })
   .AddEntityFrameworkStores<ApplicationDbContext>()
   .AddDefaultTokenProviders();

   // Add JWT Authentication
   var jwtKey = builder.Configuration["Jwt:Key"] ?? "ThisIsAVerySecretKeyForJWTTokensThatShouldBeAtLeast32CharactersLong!";
   var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "RestfulAPI";
   var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "RestfulAPIUsers";

   builder.Services.AddAuthentication(options =>
   {
       options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
       options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
   })
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
           IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
           ClockSkew = TimeSpan.Zero
       };
   });

   // Add Authorization
   builder.Services.AddAuthorization(options =>
   {
       options.AddPolicy("RequireAdminRole", policy => policy.RequireRole("Admin"));
       options.AddPolicy("RequireLibrarianRole", policy => policy.RequireRole("Admin", "Librarian"));
   });

   // Add API versioning
   builder.Services.AddApiVersioning(options =>
   {
       options.DefaultApiVersion = new ApiVersion(1, 0);
       options.AssumeDefaultVersionWhenUnspecified = true;
       options.ReportApiVersions = true;
       options.ApiVersionReader = ApiVersionReader.Combine(
           new UrlSegmentApiVersionReader(),
           new QueryStringApiVersionReader("api-version"),
           new HeaderApiVersionReader("X-Version"),
           new MediaTypeApiVersionReader("version")
       );
   }).AddApiExplorer(options =>
   {
       options.GroupNameFormat = "'v'VVV";
       options.SubstituteApiVersionInUrl = true;
   });

   // Configure Swagger
   builder.Services.AddTransient<IConfigureOptions<SwaggerGenOptions>, ConfigureSwaggerOptions>();
   builder.Services.AddSwaggerGen();

   // Add health checks
   builder.Services.AddHealthChecks()
       .AddCheck<DatabaseHealthCheck>("database", tags: new[] { "db", "critical" })
       .AddCheck<ApiHealthCheck>("api", tags: new[] { "api" })
       .AddCheck("memory", () =>
       {
           var allocated = GC.GetTotalMemory(forceFullCollection: false);
           var threshold = 1024L * 1024L * 1024L; // 1 GB

           return allocated < threshold
               ? HealthCheckResult.Healthy($"Memory usage: {allocated / 1024 / 1024} MB")
               : HealthCheckResult.Degraded($"Memory usage high: {allocated / 1024 / 1024} MB");
       }, tags: new[] { "memory" });

   // Add health checks UI
   builder.Services.AddHealthChecksUI(options =>
   {
       options.SetEvaluationTimeInSeconds(30);
       options.MaximumHistoryEntriesPerEndpoint(50);
       options.AddHealthCheckEndpoint("RESTful API", "/health");
   })
   .AddInMemoryStorage();

   // Register custom services
   builder.Services.AddScoped<IJwtService, JwtService>();
   builder.Services.AddHttpClient();

   var app = builder.Build();

   // Seed the database
   using (var scope = app.Services.CreateScope())
   {
       var services = scope.ServiceProvider;
       var context = services.GetRequiredService<ApplicationDbContext>();
       var userManager = services.GetRequiredService<UserManager<User>>();
       var roleManager = services.GetRequiredService<RoleManager<IdentityRole>>();

       context.Database.EnsureCreated();

       // Create roles
       string[] roles = { "Admin", "Librarian", "User" };
       foreach (var role in roles)
       {
           if (!await roleManager.RoleExistsAsync(role))
           {
               await roleManager.CreateAsync(new IdentityRole(role));
           }
       }

       // Create admin user
       var adminEmail = "admin@library.com";
       var adminUser = await userManager.FindByEmailAsync(adminEmail);
       if (adminUser == null)
       {
           adminUser = new User
           {
               UserName = adminEmail,
               Email = adminEmail,
               FirstName = "Admin",
               LastName = "User",
               CreatedAt = DateTime.UtcNow,
               IsActive = true
           };

           await userManager.CreateAsync(adminUser, "Admin123!");
           await userManager.AddToRoleAsync(adminUser, "Admin");
       }

       // Seed sample data
       if (!context.Categories.Any())
       {
           var categories = new[]
           {
               new Category { Name = "Fiction", Description = "Fictional literature" },
               new Category { Name = "Non-Fiction", Description = "Non-fictional works" },
               new Category { Name = "Science", Description = "Scientific literature" },
               new Category { Name = "History", Description = "Historical works" }
           };
           context.Categories.AddRange(categories);
           await context.SaveChangesAsync();
       }

       if (!context.Authors.Any())
       {
           var authors = new[]
           {
               new Author { FirstName = "George", LastName = "Orwell", Nationality = "British" },
               new Author { FirstName = "Jane", LastName = "Austen", Nationality = "British" },
               new Author { FirstName = "Mark", LastName = "Twain", Nationality = "American" },
               new Author { FirstName = "Virginia", LastName = "Woolf", Nationality = "British" }
           };
           context.Authors.AddRange(authors);
           await context.SaveChangesAsync();
       }

       if (!context.Books.Any())
       {
           var books = new[]
           {
               new Book
               {
                   Title = "1984",
                   ISBN = "978-0451524935",
                   PublicationYear = 1949,
                   NumberOfPages = 328,
                   Summary = "A dystopian social science fiction novel",
                   AuthorId = 1,
                   CategoryId = 1,
                   CreatedAt = DateTime.UtcNow
               },
               new Book
               {
                   Title = "Pride and Prejudice",
                   ISBN = "978-0141439518",
                   PublicationYear = 1813,
                   NumberOfPages = 432,
                   Summary = "A romantic novel of manners",
                   AuthorId = 2,
                   CategoryId = 1,
                   CreatedAt = DateTime.UtcNow
               }
           };
           context.Books.AddRange(books);
           await context.SaveChangesAsync();
       }
   }

   // Configure the HTTP request pipeline
   if (app.Environment.IsDevelopment())
   {
       app.UseSwagger();
       app.UseSwaggerUI(c =>
       {
           var provider = app.Services.GetRequiredService<IApiVersionDescriptionProvider>();
           foreach (var description in provider.ApiVersionDescriptions)
           {
               c.SwaggerEndpoint(
                   $"/swagger/{description.GroupName}/swagger.json",
                   $"RESTful API {description.GroupName.ToUpperInvariant()}");
           }
       });
   }

   // Security headers
   app.Use(async (context, next) =>
   {
       context.Response.Headers["X-Content-Type-Options"] = "nosniff";
       context.Response.Headers["X-Frame-Options"] = "DENY";
       context.Response.Headers["X-XSS-Protection"] = "1; mode=block";
       context.Response.Headers.Remove("Server");
       await next();
   });

   // Add the analytics middleware
   app.UseMiddleware<ApiAnalyticsMiddleware>();

   app.UseAuthentication();
   app.UseAuthorization();

   // Configure health checks
   app.MapHealthChecks("/health", new HealthCheckOptions
   {
       Predicate = _ => true,
       ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
   });

   app.MapHealthChecks("/health/ready", new HealthCheckOptions
   {
       Predicate = check => check.Tags.Contains("critical"),
       ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
   });

   app.MapHealthChecks("/health/live", new HealthCheckOptions
   {
       Predicate = _ => false,
       ResponseWriter = (context, _) =>
       {
           context.Response.ContentType = "text/plain";
           return context.Response.WriteAsync("Healthy");
       }
   });

   app.UseHealthChecksUI(options =>
   {
       options.UIPath = "/health-ui";
       options.ApiPath = "/health-api";
   });

   app.MapControllers();

   app.Run();
   ```

### Part 4: Add Health Checks and Monitoring (10 minutes)

1. **Create custom health checks** (packages already installed by setup script):

   **HealthChecks/DatabaseHealthCheck.cs**:
   ```csharp
   using Microsoft.Extensions.Diagnostics.HealthChecks;
   using RestfulAPI.Data;
   using Microsoft.EntityFrameworkCore;

   namespace RestfulAPI.HealthChecks
   {
       public class DatabaseHealthCheck : IHealthCheck
       {
           private readonly ApplicationDbContext _context;

           public DatabaseHealthCheck(ApplicationDbContext context)
           {
               _context = context;
           }

           public async Task<HealthCheckResult> CheckHealthAsync(
               HealthCheckContext context,
               CancellationToken cancellationToken = default)
           {
               try
               {
                   // Try to access the database
                   var canConnect = await _context.Database.CanConnectAsync(cancellationToken);

                   if (canConnect)
                   {
                       var productCount = await _context.Products.CountAsync(cancellationToken);
                       return HealthCheckResult.Healthy(
                           $"Database is accessible. Products count: {productCount}");
                   }

                   return HealthCheckResult.Unhealthy("Cannot connect to database");
               }
               catch (Exception ex)
               {
                   return HealthCheckResult.Unhealthy(
                       "Database check failed",
                       exception: ex);
               }
           }
       }
   }
   ```

   **HealthChecks/ApiHealthCheck.cs**:
   ```csharp
   using Microsoft.Extensions.Diagnostics.HealthChecks;

   namespace RestfulAPI.HealthChecks
   {
       public class ApiHealthCheck : IHealthCheck
       {
           private readonly IHttpClientFactory _httpClientFactory;
           private readonly IConfiguration _configuration;

           public ApiHealthCheck(IHttpClientFactory httpClientFactory, IConfiguration configuration)
           {
               _httpClientFactory = httpClientFactory;
               _configuration = configuration;
           }

           public async Task<HealthCheckResult> CheckHealthAsync(
               HealthCheckContext context,
               CancellationToken cancellationToken = default)
           {
               try
               {
                   // For this demo, we'll simply check if we can create an HTTP client
                   // In a real scenario, you might check external dependencies
                   using var client = _httpClientFactory.CreateClient();

                   // Simple check - if we can create a client, consider it healthy
                   return HealthCheckResult.Healthy("API is responding");
               }
               catch (Exception ex)
               {
                   return HealthCheckResult.Unhealthy("API is not responding", ex);
               }
           }
       }
   }
   ```

2. **Test the health checks**:
   - The health check classes are already created and match the source code
   - They use the correct `RestfulAPI` namespace and `ApplicationDbContext`
   - The `DatabaseHealthCheck` monitors `Products` table as per the actual API

3. **Note about additional services**:
   The source code includes additional services like `JwtService` that use the `RestfulAPI` namespace.
   These are already implemented in the source code and follow the same namespace pattern:
   ```csharp
   using System.IdentityModel.Tokens.Jwt;
   using System.Security.Claims;
   using System.Text;
   using RestfulAPI.Models.Auth;
   using Microsoft.AspNetCore.Identity;
   using Microsoft.IdentityModel.Tokens;

   // Additional services like JwtService are already implemented in the source code
   ```

### Part 5: Add API Analytics and Metrics (5 minutes)

1. **Create middleware for API analytics**:

   **Middleware/ApiAnalyticsMiddleware.cs**:
   ```csharp
   using System.Diagnostics;

   namespace RestfulAPI.Middleware
   {
       public class ApiAnalyticsMiddleware
       {
           private readonly RequestDelegate _next;
           private readonly ILogger<ApiAnalyticsMiddleware> _logger;
           private static readonly Dictionary<string, ApiMetrics> _metrics = new();

           public ApiAnalyticsMiddleware(RequestDelegate next, ILogger<ApiAnalyticsMiddleware> logger)
           {
               _next = next;
               _logger = logger;
           }

           public async Task InvokeAsync(HttpContext context)
           {
               var stopwatch = Stopwatch.StartNew();
               var path = context.Request.Path.Value ?? "";
               
               try
               {
                   await _next(context);
               }
               finally
               {
                   stopwatch.Stop();
                   RecordMetrics(path, context.Response.StatusCode, stopwatch.ElapsedMilliseconds);
               }
           }

           private void RecordMetrics(string path, int statusCode, long elapsedMs)
           {
               var key = $"{path}:{statusCode}";
               
               lock (_metrics)
               {
                   if (!_metrics.ContainsKey(key))
                   {
                       _metrics[key] = new ApiMetrics { Path = path, StatusCode = statusCode };
                   }
                   
                   var metric = _metrics[key];
                   metric.Count++;
                   metric.TotalDuration += elapsedMs;
                   metric.LastAccessTime = DateTime.UtcNow;
                   
                   if (elapsedMs > metric.MaxDuration)
                       metric.MaxDuration = elapsedMs;
                   
                   if (metric.MinDuration == 0 || elapsedMs < metric.MinDuration)
                       metric.MinDuration = elapsedMs;
               }
               
               // Log slow requests
               if (elapsedMs > 1000)
               {
                   _logger.LogWarning("Slow API request: {Path} took {ElapsedMs}ms", path, elapsedMs);
               }
           }

           public static Dictionary<string, ApiMetrics> GetMetrics()
           {
               lock (_metrics)
               {
                   return new Dictionary<string, ApiMetrics>(_metrics);
               }
           }
       }

       public class ApiMetrics
       {
           public string Path { get; set; } = string.Empty;
           public int StatusCode { get; set; }
           public int Count { get; set; }
           public long TotalDuration { get; set; }
           public long MinDuration { get; set; }
           public long MaxDuration { get; set; }
           public DateTime LastAccessTime { get; set; }
           
           public double AverageDuration => Count > 0 ? (double)TotalDuration / Count : 0;
       }
   }
   ```

2. **Create analytics endpoint**:

   **Controllers/AnalyticsController.cs**:
   ```csharp
   using Asp.Versioning;
   using Microsoft.AspNetCore.Authorization;
   using Microsoft.AspNetCore.Mvc;
   using RestfulAPI.Middleware;

   namespace RestfulAPI.Controllers
   {
       [ApiController]
   [ApiVersion("1.0")]
   [Route("api/v{version:apiVersion}/[controller]")]
   [Authorize(Roles = "Admin")]
   public class AnalyticsController : ControllerBase
   {
       /// <summary>
       /// Get API usage metrics
       /// </summary>
       [HttpGet("metrics")]
       public ActionResult<IEnumerable<ApiMetrics>> GetMetrics()
       {
           var metrics = ApiAnalyticsMiddleware.GetMetrics()
               .Values
               .OrderByDescending(m => m.Count)
               .Take(50);
           
           return Ok(metrics);
       }

       /// <summary>
       /// Get API statistics summary
       /// </summary>
       [HttpGet("summary")]
       public ActionResult<ApiSummary> GetSummary()
       {
           var metrics = ApiAnalyticsMiddleware.GetMetrics().Values;
           
           var summary = new ApiSummary
           {
               TotalRequests = metrics.Sum(m => m.Count),
               UniqueEndpoints = metrics.Select(m => m.Path).Distinct().Count(),
               AverageResponseTime = metrics.Any() 
                   ? metrics.Average(m => m.AverageDuration) 
                   : 0,
               ErrorRate = metrics.Any() 
                   ? (double)metrics.Where(m => m.StatusCode >= 400).Sum(m => m.Count) / metrics.Sum(m => m.Count) * 100 
                   : 0,
               MostUsedEndpoints = metrics
                   .GroupBy(m => m.Path)
                   .Select(g => new EndpointUsage
                   {
                       Path = g.Key,
                       Count = g.Sum(m => m.Count),
                       AverageResponseTime = g.Average(m => m.AverageDuration)
                   })
                   .OrderByDescending(e => e.Count)
                   .Take(10)
                   .ToList()
           };
           
           return Ok(summary);
       }
   }

   public class ApiSummary
   {
       public int TotalRequests { get; set; }
       public int UniqueEndpoints { get; set; }
       public double AverageResponseTime { get; set; }
       public double ErrorRate { get; set; }
       public List<EndpointUsage> MostUsedEndpoints { get; set; } = new();
   }

   public class EndpointUsage
   {
       public string Path { get; set; } = string.Empty;
       public int Count { get; set; }
       public double AverageResponseTime { get; set; }
   }
   }
   ```

### Part 6: Test Your Enhanced API (5 minutes)

1. **Analytics middleware** (already included in Program.cs above):

2. **Run and test**:
   ```bash
   dotnet run
   ```

3. **Test endpoints**:
   - Swagger UI: `http://localhost:5001/swagger`
   - Health checks: `http://localhost:5001/health`
   - Health UI: `http://localhost:5001/health-ui`
   - V1 API: `http://localhost:5001/api/v1/products`
   - V2 API: `http://localhost:5001/api/v2/products`
   - Analytics: `http://localhost:5001/api/v1/analytics/summary`

## ✅ Success Criteria

- [ ] Swagger documentation shows comprehensive API information
- [ ] API versioning works with multiple version strategies
- [ ] Health checks report system status
- [ ] Health UI dashboard displays monitoring data
- [ ] Analytics endpoints track API usage
- [ ] Documentation includes examples and detailed descriptions

## 🚀 Bonus Challenges

1. **Add API Rate Limiting**:
   - Implement per-user rate limiting
   - Add rate limit headers to responses
   - Create different limits for different API tiers

2. **Implement API Caching**:
   - Add response caching for GET requests
   - Implement cache invalidation
   - Add ETags support

3. **Add GraphQL Support**:
   - Install HotChocolate
   - Create GraphQL schema
   - Support both REST and GraphQL

4. **Implement Webhooks**:
   - Create webhook subscription system
   - Send notifications on book changes
   - Handle webhook delivery failures

## 🤔 Reflection Questions

1. What are the benefits of API versioning?
2. How does health monitoring improve system reliability?
3. What metrics are most important for API monitoring?
4. How can comprehensive documentation improve API adoption?

## 🆘 Troubleshooting

**Issue**: BooksController errors (ApplicationDbContext not found)
**Solution**: You should NOT have any BooksController files. Delete any Controllers/V1/BooksController.cs or Controllers/V2/BooksController.cs files. This exercise uses your existing ProductsController from Exercise 1 & 2.

**Issue**: 'AuthorizeAttribute' could not be found
**Solution**: Add `using Microsoft.AspNetCore.Authorization;` to your controller files.

**Issue**: 'ApiVersion' is ambiguous reference
**Solution**: Use only `using Asp.Versioning;` and remove old versioning packages:
```bash
dotnet remove package Microsoft.AspNetCore.Mvc.Versioning
dotnet remove package Microsoft.AspNetCore.Mvc.Versioning.ApiExplorer
```

**Issue**: ProductsController referencing BookDto
**Solution**: If continuing from Exercise 1 & 2, keep using ProductDto. The BookDto is just an example for Exercise 3's versioning demonstration.

**Issue**: ProductDtoV2 could not be found
**Solution**: You must create the ProductDtoV2.cs file as shown in Part 1. This is a NEW file that extends your existing ProductDto. Make sure it's in your DTOs folder with the correct namespace `RestfulAPI.DTOs`.

**Issue**: "Only records may inherit from records" error
**Solution**: Ensure DTOs are defined as records if using inheritance:
```csharp
public record BookDto { }  // Base record
public record BookDtoV2 : BookDto { }  // Derived record
```

**Issue**: Missing ApplicationDbContext
**Solution**: Add the correct using directive:
```csharp
using RestfulAPI.Data;
```

**Issue**: Swagger UI shows multiple versions but URLs don't work
**Solution**: Ensure URL versioning is configured correctly in both controllers and Swagger.

**Issue**: Health checks always fail
**Solution**: Check that services are registered correctly and database connection is valid.

**Issue**: Analytics data not collecting
**Solution**: Ensure middleware is registered before UseEndpoints/MapControllers.

---

