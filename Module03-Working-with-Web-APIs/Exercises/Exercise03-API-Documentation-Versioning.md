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

## 📝 Instructions

### Part 0: Project Setup (2 minutes)

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
dotnet add package Microsoft.AspNetCore.Mvc.Versioning.ApiExplorer
dotnet add package AspNetCore.HealthChecks.UI
dotnet add package AspNetCore.HealthChecks.UI.Client
dotnet add package AspNetCore.HealthChecks.UI.InMemory.Storage
dotnet add package Swashbuckle.AspNetCore.Annotations

# Verify setup
dotnet build
```

### Part 1: Create Required DTOs and Models (5 minutes)

First, create the data transfer objects and models needed for the exercise:

**Models/DTOs/BookDto.cs**:
```csharp
using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.Models.DTOs
{
    /// <summary>
    /// Book data transfer object for API responses
    /// </summary>
    public class BookDto
    {
        /// <summary>
        /// Unique identifier for the book
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Book title
        /// </summary>
        public string Title { get; set; } = string.Empty;

        /// <summary>
        /// Book author
        /// </summary>
        public string Author { get; set; } = string.Empty;

        /// <summary>
        /// Book category/genre
        /// </summary>
        public string Category { get; set; } = string.Empty;

        /// <summary>
        /// Publication year
        /// </summary>
        public int PublicationYear { get; set; }

        /// <summary>
        /// ISBN number
        /// </summary>
        public string ISBN { get; set; } = string.Empty;

        /// <summary>
        /// Number of available copies
        /// </summary>
        public int AvailableCopies { get; set; }
    }

    /// <summary>
    /// Enhanced book DTO for API version 2
    /// </summary>
    public class BookDtoV2 : BookDto
    {
        /// <summary>
        /// Book description
        /// </summary>
        public string Description { get; set; } = string.Empty;

        /// <summary>
        /// Publisher information
        /// </summary>
        public string Publisher { get; set; } = string.Empty;

        /// <summary>
        /// Book rating (1-5 stars)
        /// </summary>
        public decimal Rating { get; set; }

        /// <summary>
        /// Number of pages
        /// </summary>
        public int PageCount { get; set; }

        /// <summary>
        /// Book language
        /// </summary>
        public string Language { get; set; } = "English";

        /// <summary>
        /// Tags associated with the book
        /// </summary>
        public List<string> Tags { get; set; } = new();
    }

    /// <summary>
    /// DTO for creating new books
    /// </summary>
    public class CreateBookDto
    {
        /// <summary>
        /// Book title
        /// </summary>
        [Required]
        [StringLength(200)]
        public string Title { get; set; } = string.Empty;

        /// <summary>
        /// Book author
        /// </summary>
        [Required]
        [StringLength(100)]
        public string Author { get; set; } = string.Empty;

        /// <summary>
        /// Book category
        /// </summary>
        [Required]
        [StringLength(50)]
        public string Category { get; set; } = string.Empty;

        /// <summary>
        /// Publication year
        /// </summary>
        [Range(1000, 2030)]
        public int PublicationYear { get; set; }

        /// <summary>
        /// ISBN number
        /// </summary>
        [Required]
        [RegularExpression(@"^(?:ISBN(?:-1[03])?:? )?(?=[0-9X]{10}$|(?=(?:[0-9]+[- ]){3})[- 0-9X]{13}$|97[89][0-9]{10}$|(?=(?:[0-9]+[- ]){4})[- 0-9]{17}$)(?:97[89][- ]?)?[0-9]{1,5}[- ]?[0-9]+[- ]?[0-9]+[- ]?[0-9X]$")]
        public string ISBN { get; set; } = string.Empty;

        /// <summary>
        /// Number of copies
        /// </summary>
        [Range(0, 1000)]
        public int AvailableCopies { get; set; }

        /// <summary>
        /// Author ID (for database relationship)
        /// </summary>
        [Required]
        public int AuthorId { get; set; }

        /// <summary>
        /// Category ID (for database relationship)
        /// </summary>
        [Required]
        public int CategoryId { get; set; }
    }
}
```

**Models/DTOs/PaginationDto.cs**:
```csharp
using System.ComponentModel.DataAnnotations;

namespace RestfulAPI.Models.DTOs
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

1. **Create complete Program.cs configuration**:

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

2. **Create versioned controllers**:

   **Controllers/V1/BooksController.cs**:
   ```csharp
   using Asp.Versioning;
   using Microsoft.AspNetCore.Mvc;
   using Swashbuckle.AspNetCore.Annotations;
   using RestfulAPI.Models.DTOs;

   namespace RestfulAPI.Controllers.V1
   {
       /// <summary>
       /// Manages library books (Version 1)
       /// </summary>
       [ApiController]
       [ApiVersion("1.0")]
       [Route("api/v{version:apiVersion}/[controller]")]
       [Produces("application/json")]
       [SwaggerTag("Create, read, update and delete books")]
       public class BooksController : ControllerBase
       {
           private readonly ApplicationDbContext _context;
           private readonly ILogger<BooksController> _logger;

           public BooksController(ApplicationDbContext context, ILogger<BooksController> logger)
           {
               _context = context;
               _logger = logger;
           }

           /// <summary>
           /// Get all books with pagination
           /// </summary>
           /// <remarks>
           /// Sample request:
           ///
           ///     GET /api/v1/books?pageNumber=1&amp;pageSize=10&amp;category=Fiction
           ///
           /// </remarks>
           /// <param name="category">Filter by category name (optional)</param>
           /// <param name="author">Filter by author last name (optional)</param>
           /// <param name="year">Filter by publication year (optional)</param>
           /// <param name="pageNumber">Page number (default: 1)</param>
           /// <param name="pageSize">Items per page (default: 10, max: 100)</param>
           /// <returns>A paginated list of books</returns>
           /// <response code="200">Returns the list of books</response>
           /// <response code="400">If the pagination parameters are invalid</response>
           [HttpGet]
           [SwaggerOperation(
               Summary = "Get all books",
               Description = "Retrieves a paginated list of books with optional filtering",
               OperationId = "GetBooksV1",
               Tags = new[] { "Books" }
           )]
           [SwaggerResponse(200, "Success", typeof(PaginatedResponse<BookDto>))]
           [SwaggerResponse(400, "Bad Request", typeof(ValidationProblemDetails))]
           public async Task<ActionResult<PaginatedResponse<BookDto>>> GetBooks(
               [FromQuery] string? category = null,
               [FromQuery] string? author = null,
               [FromQuery] int? year = null,
               [FromQuery] int pageNumber = 1,
               [FromQuery] int pageSize = 10)
           {
               try
               {
                   // Validate pagination parameters
                   if (pageNumber < 1) pageNumber = 1;
                   if (pageSize < 1) pageSize = 10;
                   if (pageSize > 100) pageSize = 100;

                   var query = _context.Books
                       .Include(b => b.Author)
                       .Include(b => b.Category)
                       .AsQueryable();

                   // Apply basic filters
                   if (!string.IsNullOrEmpty(category))
                   {
                       query = query.Where(b => b.Category!.Name.Contains(category));
                   }

                   if (!string.IsNullOrEmpty(author))
                   {
                       query = query.Where(b => b.Author!.LastName.Contains(author));
                   }

                   if (year.HasValue)
                   {
                       query = query.Where(b => b.PublicationYear == year.Value);
                   }

                   // Get total count
                   var totalCount = await query.CountAsync();

                   // Apply pagination and select
                   var books = await query
                       .OrderBy(b => b.Title)
                       .Skip((pageNumber - 1) * pageSize)
                       .Take(pageSize)
                       .Select(b => new BookDto
                       {
                           Id = b.Id,
                           Title = b.Title,
                           Author = $"{b.Author!.FirstName} {b.Author.LastName}",
                           Category = b.Category!.Name,
                           PublicationYear = b.PublicationYear,
                           ISBN = b.ISBN,
                           AvailableCopies = 5 // Mock data for V1
                       })
                       .ToListAsync();

                   var result = PaginatedResponse<BookDto>.Create(
                       books,
                       pageNumber,
                       pageSize,
                       totalCount);

                   return Ok(result);
               }
               catch (Exception ex)
               {
                   _logger.LogError(ex, "Error retrieving books");
                   return StatusCode(500, "An error occurred while retrieving books");
               }
           }

           /// <summary>
           /// Get a specific book by ID
           /// </summary>
           /// <param name="id">Book ID</param>
           /// <returns>Book details</returns>
           [HttpGet("{id}")]
           [SwaggerOperation(
               Summary = "Get book by ID",
               Description = "Retrieves a specific book by its ID",
               OperationId = "GetBookByIdV1"
           )]
           [SwaggerResponse(200, "Success", typeof(BookDto))]
           [SwaggerResponse(404, "Book not found")]
           public async Task<ActionResult<BookDto>> GetBook(int id)
           {
               var book = await _context.Books
                   .Include(b => b.Author)
                   .Include(b => b.Category)
                   .FirstOrDefaultAsync(b => b.Id == id);

               if (book == null)
               {
                   return NotFound($"Book with ID {id} not found");
               }

               var bookDto = new BookDto
               {
                   Id = book.Id,
                   Title = book.Title,
                   Author = $"{book.Author!.FirstName} {book.Author.LastName}",
                   Category = book.Category!.Name,
                   PublicationYear = book.PublicationYear,
                   ISBN = book.ISBN,
                   AvailableCopies = 5 // Mock data for V1
               };

               return Ok(bookDto);
           }
       }
   }
   ```

   **Controllers/V2/BooksController.cs**:
   ```csharp
   using Asp.Versioning;
   using Microsoft.AspNetCore.Mvc;
   using Microsoft.EntityFrameworkCore;
   using RestfulAPI.Data;
   using RestfulAPI.Models;
   using RestfulAPI.Models.DTOs;
   using Swashbuckle.AspNetCore.Annotations;

   namespace RestfulAPI.Controllers.V2
   {
       /// <summary>
       /// Manages library books (Version 2 - Enhanced)
       /// </summary>
       [ApiController]
       [ApiVersion("2.0")]
       [Route("api/v{version:apiVersion}/[controller]")]
       [Produces("application/json")]
       [SwaggerTag("Enhanced book management with advanced features")]
       public class BooksController : ControllerBase
       {
           private readonly ApplicationDbContext _context;
           private readonly ILogger<BooksController> _logger;

           public BooksController(ApplicationDbContext context, ILogger<BooksController> logger)
           {
               _context = context;
               _logger = logger;
           }

           /// <summary>
           /// Get all books with advanced filtering and sorting
           /// </summary>
           /// <param name="filter">Advanced filter criteria</param>
           /// <param name="pagination">Pagination parameters</param>
           /// <param name="sortBy">Field to sort by (title, author, year, rating)</param>
           /// <param name="sortDescending">Sort in descending order</param>
           /// <returns>Paginated list of enhanced book data</returns>
           [HttpGet]
           [SwaggerOperation(
               Summary = "Get books with advanced filtering",
               Description = "Retrieves books with enhanced filtering, sorting, and pagination capabilities",
               OperationId = "GetBooksV2"
           )]
           [SwaggerResponse(200, "Success", typeof(PaginatedResponse<BookDtoV2>))]
           [SwaggerResponse(400, "Bad Request", typeof(ValidationProblemDetails))]
           public async Task<ActionResult<PaginatedResponse<BookDtoV2>>> GetBooks(
               [FromQuery] BookFilterDto filter,
               [FromQuery] PaginationParams pagination,
               [FromQuery] string? sortBy = "title",
               [FromQuery] bool sortDescending = false)
           {
               try
               {
                   var query = _context.Books
                       .Include(b => b.Author)
                       .Include(b => b.Category)
                       .AsQueryable();

                   // Apply filters
                   if (!string.IsNullOrEmpty(filter.Category))
                   {
                       query = query.Where(b => b.Category!.Name.Contains(filter.Category));
                   }

                   if (!string.IsNullOrEmpty(filter.Author))
                   {
                       query = query.Where(b =>
                           b.Author!.FirstName.Contains(filter.Author) ||
                           b.Author!.LastName.Contains(filter.Author));
                   }

                   if (filter.Year.HasValue)
                   {
                       query = query.Where(b => b.PublicationYear == filter.Year.Value);
                   }

                   if (!string.IsNullOrEmpty(filter.SearchTerm))
                   {
                       query = query.Where(b =>
                           b.Title.Contains(filter.SearchTerm) ||
                           b.Summary.Contains(filter.SearchTerm));
                   }

                   if (!string.IsNullOrEmpty(filter.Language))
                   {
                       // For demo purposes, assume all books are in English
                       // In real implementation, you'd have a Language property
                   }

                   // Apply sorting
                   query = sortBy?.ToLower() switch
                   {
                       "author" => sortDescending
                           ? query.OrderByDescending(b => b.Author!.LastName)
                           : query.OrderBy(b => b.Author!.LastName),
                       "year" => sortDescending
                           ? query.OrderByDescending(b => b.PublicationYear)
                           : query.OrderBy(b => b.PublicationYear),
                       "category" => sortDescending
                           ? query.OrderByDescending(b => b.Category!.Name)
                           : query.OrderBy(b => b.Category!.Name),
                       _ => sortDescending
                           ? query.OrderByDescending(b => b.Title)
                           : query.OrderBy(b => b.Title)
                   };

                   // Get total count
                   var totalCount = await query.CountAsync();

                   // Apply pagination
                   var books = await query
                       .Skip((pagination.PageNumber - 1) * pagination.PageSize)
                       .Take(pagination.PageSize)
                       .Select(b => new BookDtoV2
                       {
                           Id = b.Id,
                           Title = b.Title,
                           Author = $"{b.Author!.FirstName} {b.Author.LastName}",
                           Category = b.Category!.Name,
                           PublicationYear = b.PublicationYear,
                           ISBN = b.ISBN,
                           AvailableCopies = 5, // Mock data
                           Description = b.Summary,
                           Publisher = "Sample Publisher", // Mock data
                           Rating = 4.2m, // Mock data
                           PageCount = b.NumberOfPages,
                           Language = "English",
                           Tags = new List<string> { b.Category!.Name, "Popular" } // Mock data
                       })
                       .ToListAsync();

                   var result = PaginatedResponse<BookDtoV2>.Create(
                       books,
                       pagination.PageNumber,
                       pagination.PageSize,
                       totalCount);

                   return Ok(result);
               }
               catch (Exception ex)
               {
                   _logger.LogError(ex, "Error retrieving books");
                   return StatusCode(500, "An error occurred while retrieving books");
               }
           }

           /// <summary>
           /// Get a specific book by ID with enhanced details
           /// </summary>
           /// <param name="id">Book ID</param>
           /// <returns>Enhanced book details</returns>
           [HttpGet("{id}")]
           [SwaggerOperation(
               Summary = "Get book by ID",
               Description = "Retrieves a specific book with enhanced details",
               OperationId = "GetBookByIdV2"
           )]
           [SwaggerResponse(200, "Success", typeof(BookDtoV2))]
           [SwaggerResponse(404, "Book not found")]
           public async Task<ActionResult<BookDtoV2>> GetBook(int id)
           {
               var book = await _context.Books
                   .Include(b => b.Author)
                   .Include(b => b.Category)
                   .FirstOrDefaultAsync(b => b.Id == id);

               if (book == null)
               {
                   return NotFound($"Book with ID {id} not found");
               }

               var bookDto = new BookDtoV2
               {
                   Id = book.Id,
                   Title = book.Title,
                   Author = $"{book.Author!.FirstName} {book.Author.LastName}",
                   Category = book.Category!.Name,
                   PublicationYear = book.PublicationYear,
                   ISBN = book.ISBN,
                   AvailableCopies = 5, // Mock data
                   Description = book.Summary,
                   Publisher = "Sample Publisher", // Mock data
                   Rating = 4.2m, // Mock data
                   PageCount = book.NumberOfPages,
                   Language = "English",
                   Tags = new List<string> { book.Category!.Name, "Popular" } // Mock data
               };

               return Ok(bookDto);
           }

           /// <summary>
           /// Bulk create multiple books
           /// </summary>
           /// <param name="books">List of books to create</param>
           /// <returns>Bulk operation result</returns>
           [HttpPost("bulk")]
           [SwaggerOperation(
               Summary = "Bulk create books",
               Description = "Creates multiple books in a single operation",
               OperationId = "CreateBooksBulkV2"
           )]
           [SwaggerResponse(200, "Success", typeof(BulkOperationResult))]
           [SwaggerResponse(400, "Validation errors")]
           public async Task<ActionResult<BulkOperationResult>> CreateBooksBulk(
               [FromBody] List<CreateBookDto> books)
           {
               var result = new BulkOperationResult
               {
                   TotalCount = books.Count
               };

               try
               {
                   using var transaction = await _context.Database.BeginTransactionAsync();

                   for (int i = 0; i < books.Count; i++)
                   {
                       var bookDto = books[i];

                       try
                       {
                           // Validate the book
                           if (string.IsNullOrEmpty(bookDto.Title))
                           {
                               result.Errors.Add(new BulkOperationError
                               {
                                   Index = i,
                                   Message = "Title is required",
                                   Item = bookDto
                               });
                               result.FailureCount++;
                               continue;
                           }

                           // Check if ISBN already exists
                           var existingBook = await _context.Books
                               .FirstOrDefaultAsync(b => b.ISBN == bookDto.ISBN);

                           if (existingBook != null)
                           {
                               result.Errors.Add(new BulkOperationError
                               {
                                   Index = i,
                                   Message = $"Book with ISBN {bookDto.ISBN} already exists",
                                   Item = bookDto
                               });
                               result.FailureCount++;
                               continue;
                           }

                           // Create the book
                           var book = new Book
                           {
                               Title = bookDto.Title,
                               ISBN = bookDto.ISBN,
                               PublicationYear = bookDto.PublicationYear,
                               NumberOfPages = bookDto.AvailableCopies,
                               Summary = "Auto-generated summary", // Mock data
                               AuthorId = bookDto.AuthorId,
                               CategoryId = bookDto.CategoryId,
                               CreatedAt = DateTime.UtcNow
                           };

                           _context.Books.Add(book);
                           await _context.SaveChangesAsync();

                           result.CreatedIds.Add(book.Id);
                           result.SuccessCount++;
                       }
                       catch (Exception ex)
                       {
                           result.Errors.Add(new BulkOperationError
                           {
                               Index = i,
                               Message = ex.Message,
                               Item = bookDto
                           });
                           result.FailureCount++;
                       }
                   }

                   await transaction.CommitAsync();
                   return Ok(result);
               }
               catch (Exception ex)
               {
                   _logger.LogError(ex, "Error during bulk book creation");
                   return StatusCode(500, "An error occurred during bulk creation");
               }
           }

           /// <summary>
           /// Get book statistics (V2 only feature)
           /// </summary>
           /// <returns>Book statistics</returns>
           [HttpGet("statistics")]
           [SwaggerOperation(
               Summary = "Get book statistics",
               Description = "Retrieves various statistics about the book collection",
               OperationId = "GetBookStatisticsV2"
           )]
           public async Task<ActionResult<object>> GetStatistics()
           {
               try
               {
                   var stats = new
                   {
                       TotalBooks = await _context.Books.CountAsync(),
                       TotalAuthors = await _context.Authors.CountAsync(),
                       TotalCategories = await _context.Categories.CountAsync(),
                       AveragePublicationYear = await _context.Books.AverageAsync(b => (double)b.PublicationYear),
                       MostPopularCategory = await _context.Categories
                           .OrderByDescending(c => c.Books.Count)
                           .Select(c => c.Name)
                           .FirstOrDefaultAsync(),
                       BooksByDecade = await _context.Books
                           .GroupBy(b => (b.PublicationYear / 10) * 10)
                           .Select(g => new { Decade = g.Key, Count = g.Count() })
                           .OrderBy(x => x.Decade)
                           .ToListAsync()
                   };

                   return Ok(stats);
               }
               catch (Exception ex)
               {
                   _logger.LogError(ex, "Error retrieving book statistics");
                   return StatusCode(500, "An error occurred while retrieving statistics");
               }
           }
       }
   }
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

**Issue**: Swagger UI shows multiple versions but URLs don't work
**Solution**: Ensure URL versioning is configured correctly in both controllers and Swagger.

**Issue**: Health checks always fail
**Solution**: Check that services are registered correctly and database connection is valid.

**Issue**: Analytics data not collecting
**Solution**: Ensure middleware is registered before UseEndpoints/MapControllers.

---

