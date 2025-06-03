# Exercise 3: API Documentation and Versioning

## 🎯 Objective
Enhance your Library API with comprehensive documentation using Swagger/OpenAPI, implement API versioning, and add advanced features like health checks and API analytics.

## ⏱️ Estimated Time
35 minutes

## 📋 Prerequisites
- Completed Exercises 1 and 2
- .NET 8.0 SDK installed
- Understanding of API documentation
- Basic knowledge of versioning strategies

## 📝 Instructions

### Part 1: Enhanced Swagger Documentation (10 minutes)

1. **Install additional packages**:
   ```bash
   dotnet add package Swashbuckle.AspNetCore.Annotations
   dotnet add package Microsoft.AspNetCore.Mvc.Versioning
   dotnet add package Microsoft.AspNetCore.Mvc.Versioning.ApiExplorer
   ```

2. **Create custom Swagger configuration** in `Configuration/`:

   **SwaggerConfiguration.cs**:
   ```csharp
   using Microsoft.AspNetCore.Mvc.ApiExplorer;
   using Microsoft.Extensions.Options;
   using Microsoft.OpenApi.Models;
   using Swashbuckle.AspNetCore.SwaggerGen;

   namespace LibraryAPI.Configuration
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

               // Add example responses
               options.OperationFilter<ExampleResponsesOperationFilter>();

               // Group by tags
               options.TagActionsBy(api =>
               {
                   if (api.GroupName != null)
                   {
                       return new[] { api.GroupName };
                   }

                   var controllerName = api.ActionDescriptor.RouteValues["controller"];
                   return new[] { controllerName ?? "Default" };
               });

               options.DocInclusionPredicate((name, api) => true);
           }

           private static OpenApiInfo CreateInfoForApiVersion(ApiVersionDescription description)
           {
               var info = new OpenApiInfo
               {
                   Title = "Library API",
                   Version = description.ApiVersion.ToString(),
                   Description = "A comprehensive API for managing library resources",
                   Contact = new OpenApiContact
                   {
                       Name = "Library Support Team",
                       Email = "support@library.com",
                       Url = new Uri("https://library.com/support")
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

               operation.Deprecated |= apiDescription.IsDeprecated();

               if (operation.Parameters == null)
               {
                   return;
               }

               foreach (var parameter in operation.Parameters)
               {
                   var description = apiDescription.ParameterDescriptions.First(p => p.Name == parameter.Name);

                   if (parameter.Description == null)
                   {
                       parameter.Description = description.ModelMetadata?.Description;
                   }

                   if (parameter.Schema.Default == null && description.DefaultValue != null)
                   {
                       parameter.Schema.Default = OpenApiAnyFactory.CreateFromJson(
                           System.Text.Json.JsonSerializer.Serialize(description.DefaultValue));
                   }

                   parameter.Required |= description.IsRequired;
               }
           }
       }

       public class ExampleResponsesOperationFilter : IOperationFilter
       {
           public void Apply(OpenApiOperation operation, OperationFilterContext context)
           {
               // Add common error responses
               operation.Responses.TryAdd("400", new OpenApiResponse
               {
                   Description = "Bad Request - Invalid input data",
                   Content = new Dictionary<string, OpenApiMediaType>
                   {
                       ["application/json"] = new OpenApiMediaType
                       {
                           Schema = new OpenApiSchema
                           {
                               Reference = new OpenApiReference
                               {
                                   Type = ReferenceType.Schema,
                                   Id = "ProblemDetails"
                               }
                           }
                       }
                   }
               });

               operation.Responses.TryAdd("401", new OpenApiResponse
               {
                   Description = "Unauthorized - Authentication required"
               });

               operation.Responses.TryAdd("403", new OpenApiResponse
               {
                   Description = "Forbidden - Insufficient permissions"
               });

               operation.Responses.TryAdd("500", new OpenApiResponse
               {
                   Description = "Internal Server Error"
               });
           }
       }
   }
   ```

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
   namespace LibraryAPI.DTOs
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

### Part 2: Implement API Versioning (10 minutes)

1. **Configure API versioning** in Program.cs:

   ```csharp
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
   });

   builder.Services.AddVersionedApiExplorer(options =>
   {
       options.GroupNameFormat = "'v'VVV";
       options.SubstituteApiVersionInUrl = true;
   });

   // Configure Swagger
   builder.Services.AddTransient<IConfigureOptions<SwaggerGenOptions>, ConfigureSwaggerOptions>();
   builder.Services.AddSwaggerGen();
   ```

2. **Create versioned controllers**:

   **Controllers/V1/BooksController.cs**:
   ```csharp
   using Microsoft.AspNetCore.Mvc;
   using Swashbuckle.AspNetCore.Annotations;

   namespace LibraryAPI.Controllers.V1
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
           // ... existing implementation ...

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
               OperationId = "GetBooks",
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
               // Add pagination logic
               if (pageNumber < 1) pageNumber = 1;
               if (pageSize < 1) pageSize = 10;
               if (pageSize > 100) pageSize = 100;

               // ... rest of implementation
           }
       }
   }
   ```

   **Controllers/V2/BooksController.cs**:
   ```csharp
   namespace LibraryAPI.Controllers.V2
   {
       /// <summary>
       /// Manages library books (Version 2 - Enhanced)
       /// </summary>
       [ApiController]
       [ApiVersion("2.0")]
       [Route("api/v{version:apiVersion}/[controller]")]
       [Produces("application/json")]
       public class BooksController : ControllerBase
       {
           /// <summary>
           /// Get all books with advanced filtering and sorting
           /// </summary>
           [HttpGet]
           public async Task<ActionResult<PaginatedResponse<BookDtoV2>>> GetBooks(
               [FromQuery] BookFilterDto filter,
               [FromQuery] PaginationParams pagination,
               [FromQuery] string? sortBy = "title",
               [FromQuery] bool sortDescending = false)
           {
               // V2 implementation with enhanced features
               // Include additional fields, sorting, etc.
           }

           /// <summary>
           /// Bulk create multiple books
           /// </summary>
           [HttpPost("bulk")]
           public async Task<ActionResult<BulkOperationResult>> CreateBooksBulk(
               [FromBody] List<CreateBookDto> books)
           {
               // New endpoint in V2
           }
       }
   }
   ```

### Part 3: Add Health Checks and Monitoring (10 minutes)

1. **Install health check packages**:
   ```bash
   dotnet add package AspNetCore.HealthChecks.UI
   dotnet add package AspNetCore.HealthChecks.UI.Client
   dotnet add package AspNetCore.HealthChecks.UI.InMemory.Storage
   ```

2. **Create custom health checks**:

   **HealthChecks/DatabaseHealthCheck.cs**:
   ```csharp
   using Microsoft.Extensions.Diagnostics.HealthChecks;
   using LibraryAPI.Data;

   namespace LibraryAPI.HealthChecks
   {
       public class DatabaseHealthCheck : IHealthCheck
       {
           private readonly LibraryContext _context;

           public DatabaseHealthCheck(LibraryContext context)
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
                       var bookCount = await _context.Books.CountAsync(cancellationToken);
                       return HealthCheckResult.Healthy(
                           $"Database is accessible. Books count: {bookCount}");
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
               var client = _httpClientFactory.CreateClient();
               var baseUrl = _configuration["BaseUrl"] ?? "https://localhost:5001";
               
               var response = await client.GetAsync($"{baseUrl}/api/v1/books", cancellationToken);
               
               if (response.IsSuccessStatusCode)
               {
                   return HealthCheckResult.Healthy("API is responding");
               }
               
               return HealthCheckResult.Degraded(
                   $"API returned status code: {response.StatusCode}");
           }
           catch (Exception ex)
           {
               return HealthCheckResult.Unhealthy(
                   "API health check failed",
                   exception: ex);
           }
       }
   }
   ```

3. **Configure health checks** in Program.cs:

   ```csharp
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
       options.AddHealthCheckEndpoint("Library API", "/health");
   })
   .AddInMemoryStorage();

   // In the app configuration
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
   ```

### Part 4: Add API Analytics and Metrics (5 minutes)

1. **Create middleware for API analytics**:

   **Middleware/ApiAnalyticsMiddleware.cs**:
   ```csharp
   using System.Diagnostics;

   namespace LibraryAPI.Middleware
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
   ```

### Part 5: Test Your Enhanced API (5 minutes)

1. **Update Program.cs** to use the middleware:
   ```csharp
   // Add the analytics middleware
   app.UseMiddleware<ApiAnalyticsMiddleware>();
   ```

2. **Run and test**:
   ```bash
   dotnet run
   ```

3. **Test endpoints**:
   - Swagger UI: `https://localhost:[port]/swagger`
   - Health checks: `https://localhost:[port]/health`
   - Health UI: `https://localhost:[port]/health-ui`
   - V1 API: `https://localhost:[port]/api/v1/books`
   - V2 API: `https://localhost:[port]/api/v2/books`
   - Analytics: `https://localhost:[port]/api/v1/analytics/summary`

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

