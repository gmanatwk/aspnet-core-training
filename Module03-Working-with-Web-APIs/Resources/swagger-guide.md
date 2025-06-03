# Swagger/OpenAPI Documentation Guide

## Introduction

Swagger (now part of OpenAPI Initiative) is a powerful framework for API documentation that provides:
- Interactive API documentation
- Client SDK generation
- API testing interface
- Contract-first development support

## Setting Up Swagger in ASP.NET Core

### 1. Install NuGet Packages

```bash
dotnet add package Swashbuckle.AspNetCore
dotnet add package Swashbuckle.AspNetCore.Annotations
```

### 2. Basic Configuration

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Add Swagger generation
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "My API",
        Version = "v1",
        Description = "A comprehensive API for managing resources",
        Contact = new OpenApiContact
        {
            Name = "API Support",
            Email = "support@example.com",
            Url = new Uri("https://example.com/support")
        },
        License = new OpenApiLicense
        {
            Name = "MIT",
            Url = new Uri("https://opensource.org/licenses/MIT")
        }
    });
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "My API V1");
        c.RoutePrefix = string.Empty; // Serve at root
    });
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.Run();
```

## Advanced Swagger Configuration

### 1. XML Documentation

Enable XML comments for better documentation:

```xml
<!-- In .csproj file -->
<PropertyGroup>
  <GenerateDocumentationFile>true</GenerateDocumentationFile>
  <NoWarn>$(NoWarn);1591</NoWarn>
</PropertyGroup>
```

```csharp
// In Program.cs
builder.Services.AddSwaggerGen(c =>
{
    // Include XML comments
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    c.IncludeXmlComments(xmlPath);
    
    // Include XML comments from models project if separate
    var modelsXmlFile = "MyApi.Models.xml";
    var modelsXmlPath = Path.Combine(AppContext.BaseDirectory, modelsXmlFile);
    if (File.Exists(modelsXmlPath))
    {
        c.IncludeXmlComments(modelsXmlPath);
    }
});
```

### 2. API Versioning Support

```csharp
// Install packages
// dotnet add package Microsoft.AspNetCore.Mvc.Versioning
// dotnet add package Microsoft.AspNetCore.Mvc.Versioning.ApiExplorer

builder.Services.AddApiVersioning(opt =>
{
    opt.DefaultApiVersion = new ApiVersion(1, 0);
    opt.AssumeDefaultVersionWhenUnspecified = true;
    opt.ReportApiVersions = true;
});

builder.Services.AddVersionedApiExplorer(setup =>
{
    setup.GroupNameFormat = "'v'VVV";
    setup.SubstituteApiVersionInUrl = true;
});

// Configure Swagger for multiple versions
builder.Services.AddSwaggerGen(c =>
{
    var provider = builder.Services.BuildServiceProvider()
        .GetRequiredService<IApiVersionDescriptionProvider>();

    foreach (var description in provider.ApiVersionDescriptions)
    {
        c.SwaggerDoc(description.GroupName, new OpenApiInfo
        {
            Title = $"My API {description.ApiVersion}",
            Version = description.ApiVersion.ToString()
        });
    }
});

// Configure SwaggerUI for multiple versions
app.UseSwaggerUI(c =>
{
    foreach (var description in provider.ApiVersionDescriptions)
    {
        c.SwaggerEndpoint(
            $"/swagger/{description.GroupName}/swagger.json",
            $"My API {description.GroupName.ToUpperInvariant()}");
    }
});
```

### 3. Security Configuration

#### JWT Bearer Authentication

```csharp
builder.Services.AddSwaggerGen(c =>
{
    // Define security scheme
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = @"JWT Authorization header using the Bearer scheme. 
                      Enter 'Bearer' [space] and then your token in the text input below.
                      Example: 'Bearer 12345abcdef'",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    // Apply security requirement globally
    c.AddSecurityRequirement(new OpenApiSecurityRequirement()
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
});
```

#### API Key Authentication

```csharp
c.AddSecurityDefinition("ApiKey", new OpenApiSecurityScheme
{
    Description = "API Key needed to access the endpoints. X-Api-Key: My_API_Key",
    In = ParameterLocation.Header,
    Name = "X-Api-Key",
    Type = SecuritySchemeType.ApiKey
});

c.AddSecurityRequirement(new OpenApiSecurityRequirement
{
    {
        new OpenApiSecurityScheme
        {
            Reference = new OpenApiReference
            {
                Type = ReferenceType.SecurityScheme,
                Id = "ApiKey"
            }
        },
        new string[] {}
    }
});
```

### 4. Custom Filters and Operations

```csharp
// Add file upload support
public class FileUploadOperationFilter : IOperationFilter
{
    public void Apply(OpenApiOperation operation, OperationFilterContext context)
    {
        var fileParams = context.MethodInfo.GetParameters()
            .Where(p => p.ParameterType == typeof(IFormFile) || 
                       p.ParameterType == typeof(IFormFileCollection))
            .ToArray();

        if (!fileParams.Any()) return;

        operation.RequestBody = new OpenApiRequestBody
        {
            Content = new Dictionary<string, OpenApiMediaType>
            {
                ["multipart/form-data"] = new OpenApiMediaType
                {
                    Schema = new OpenApiSchema
                    {
                        Type = "object",
                        Properties = fileParams.ToDictionary(
                            p => p.Name,
                            p => new OpenApiSchema
                            {
                                Type = "string",
                                Format = "binary"
                            })
                    }
                }
            }
        };
    }
}

// Register the filter
builder.Services.AddSwaggerGen(c =>
{
    c.OperationFilter<FileUploadOperationFilter>();
});
```

## Documenting Your API

### 1. Controller Documentation

```csharp
/// <summary>
/// Manages product operations
/// </summary>
[ApiController]
[Route("api/v{version:apiVersion}/[controller]")]
[ApiVersion("1.0")]
[Produces("application/json")]
[ProducesResponseType(StatusCodes.Status400BadRequest)]
[ProducesResponseType(StatusCodes.Status500InternalServerError)]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;

    /// <summary>
    /// Creates a ProductsController
    /// </summary>
    /// <param name="productService">The product service</param>
    public ProductsController(IProductService productService)
    {
        _productService = productService;
    }

    /// <summary>
    /// Get all products with optional filtering and pagination
    /// </summary>
    /// <param name="filter">Filter options</param>
    /// <returns>A paginated list of products</returns>
    /// <response code="200">Returns the list of products</response>
    /// <response code="400">If the request is invalid</response>
    [HttpGet]
    [ProducesResponseType(typeof(PagedResult<ProductDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<PagedResult<ProductDto>>> GetProducts(
        [FromQuery] ProductFilter filter)
    {
        var result = await _productService.GetProductsAsync(filter);
        return Ok(result);
    }

    /// <summary>
    /// Get a specific product by ID
    /// </summary>
    /// <param name="id">The product ID</param>
    /// <returns>The requested product</returns>
    /// <response code="200">Returns the product</response>
    /// <response code="404">If the product is not found</response>
    /// <remarks>
    /// Sample request:
    ///
    ///     GET /api/v1/products/123
    ///
    /// </remarks>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(ProductDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ProductDto>> GetProduct(int id)
    {
        var product = await _productService.GetByIdAsync(id);
        if (product == null)
            return NotFound();
        
        return Ok(product);
    }

    /// <summary>
    /// Create a new product
    /// </summary>
    /// <param name="product">The product to create</param>
    /// <returns>The created product</returns>
    /// <response code="201">Returns the newly created product</response>
    /// <response code="400">If the product is invalid</response>
    /// <response code="409">If a product with the same SKU already exists</response>
    [HttpPost]
    [ProducesResponseType(typeof(ProductDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<ActionResult<ProductDto>> CreateProduct(
        [FromBody] CreateProductDto product)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var created = await _productService.CreateAsync(product);
        
        return CreatedAtAction(
            nameof(GetProduct), 
            new { id = created.Id }, 
            created);
    }

    /// <summary>
    /// Upload product image
    /// </summary>
    /// <param name="id">Product ID</param>
    /// <param name="file">Image file (JPEG, PNG, max 5MB)</param>
    /// <returns>Upload result</returns>
    [HttpPost("{id:int}/image")]
    [Consumes("multipart/form-data")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UploadImage(int id, IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest("No file uploaded");

        await _productService.UpdateImageAsync(id, file);
        return Ok(new { message = "Image uploaded successfully" });
    }
}
```

### 2. Model Documentation

```csharp
/// <summary>
/// Represents a product in the catalog
/// </summary>
public class ProductDto
{
    /// <summary>
    /// The unique identifier of the product
    /// </summary>
    /// <example>123</example>
    public int Id { get; set; }

    /// <summary>
    /// The product name
    /// </summary>
    /// <example>Wireless Mouse</example>
    [Required]
    [StringLength(200, MinimumLength = 1)]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// The product description
    /// </summary>
    /// <example>High-precision wireless mouse with ergonomic design</example>
    [StringLength(2000)]
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// The price in USD
    /// </summary>
    /// <example>29.99</example>
    [Range(0.01, double.MaxValue)]
    public decimal Price { get; set; }

    /// <summary>
    /// The product SKU (Stock Keeping Unit)
    /// </summary>
    /// <example>MOUSE-WL-001</example>
    [Required]
    [RegularExpression(@"^[A-Z0-9\-]+$")]
    public string Sku { get; set; } = string.Empty;

    /// <summary>
    /// Product creation timestamp
    /// </summary>
    /// <example>2024-01-20T10:30:00Z</example>
    public DateTime CreatedAt { get; set; }

    /// <summary>
    /// Available stock quantity
    /// </summary>
    /// <example>50</example>
    [Range(0, int.MaxValue)]
    public int StockQuantity { get; set; }

    /// <summary>
    /// Product categories
    /// </summary>
    /// <example>["Electronics", "Computer Accessories"]</example>
    public List<string> Categories { get; set; } = new();
}

/// <summary>
/// Filter options for product queries
/// </summary>
public class ProductFilter
{
    /// <summary>
    /// Filter by category
    /// </summary>
    /// <example>Electronics</example>
    public string? Category { get; set; }

    /// <summary>
    /// Minimum price filter
    /// </summary>
    /// <example>10.00</example>
    [Range(0, double.MaxValue)]
    public decimal? MinPrice { get; set; }

    /// <summary>
    /// Maximum price filter
    /// </summary>
    /// <example>100.00</example>
    [Range(0, double.MaxValue)]
    public decimal? MaxPrice { get; set; }

    /// <summary>
    /// Search in name and description
    /// </summary>
    /// <example>wireless</example>
    public string? SearchTerm { get; set; }

    /// <summary>
    /// Page number (1-based)
    /// </summary>
    /// <example>1</example>
    [Range(1, int.MaxValue)]
    public int PageNumber { get; set; } = 1;

    /// <summary>
    /// Items per page
    /// </summary>
    /// <example>20</example>
    [Range(1, 100)]
    public int PageSize { get; set; } = 20;

    /// <summary>
    /// Sort field
    /// </summary>
    /// <example>name</example>
    [RegularExpression("^(name|price|created)$")]
    public string SortBy { get; set; } = "name";

    /// <summary>
    /// Sort direction
    /// </summary>
    /// <example>asc</example>
    [RegularExpression("^(asc|desc)$")]
    public string SortDirection { get; set; } = "asc";
}
```

### 3. Using Swagger Annotations

```csharp
using Swashbuckle.AspNetCore.Annotations;

[SwaggerTag("Create, read, update and delete products")]
public class ProductsController : ControllerBase
{
    [HttpGet]
    [SwaggerOperation(
        Summary = "Get products",
        Description = "Gets a paginated list of products with optional filtering",
        OperationId = "GetProducts",
        Tags = new[] { "Products" }
    )]
    [SwaggerResponse(200, "Success", typeof(PagedResult<ProductDto>))]
    [SwaggerResponse(400, "Bad Request", typeof(ValidationProblemDetails))]
    public async Task<IActionResult> GetProducts([FromQuery] ProductFilter filter)
    {
        // Implementation
    }

    [HttpPost]
    [SwaggerOperation(
        Summary = "Create product",
        Description = "Creates a new product in the catalog",
        OperationId = "CreateProduct",
        Tags = new[] { "Products" }
    )]
    [SwaggerResponse(201, "Created", typeof(ProductDto))]
    [SwaggerResponse(400, "Validation Error", typeof(ValidationProblemDetails))]
    [SwaggerResponse(409, "Conflict - SKU already exists")]
    public async Task<IActionResult> CreateProduct(
        [FromBody, SwaggerRequestBody("Product to create", Required = true)] 
        CreateProductDto product)
    {
        // Implementation
    }
}
```

## Customizing Swagger UI

### 1. Custom CSS and JavaScript

```csharp
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "My API V1");
    
    // Custom CSS
    c.InjectStylesheet("/swagger-ui/custom.css");
    
    // Custom JavaScript
    c.InjectJavascript("/swagger-ui/custom.js");
    
    // UI Configuration
    c.DefaultModelsExpandDepth(-1); // Hide models by default
    c.DefaultModelRendering(ModelRendering.Model);
    c.DisplayRequestDuration();
    c.DocExpansion(DocExpansion.None); // Collapse all by default
    c.EnableDeepLinking();
    c.EnableFilter();
    c.ShowExtensions();
    c.EnableValidator();
});
```

### 2. Custom Index Page

```html
<!-- wwwroot/swagger-ui/index.html -->
<!DOCTYPE html>
<html>
<head>
    <title>API Documentation</title>
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/swagger-ui-dist@4/swagger-ui.css">
    <style>
        .swagger-ui .topbar { display: none }
        .swagger-ui .info { margin: 20px 0 }
        .swagger-ui .info .title { font-size: 36px }
    </style>
</head>
<body>
    <div id="swagger-ui"></div>
    <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@4/swagger-ui-bundle.js"></script>
    <script>
        window.onload = function() {
            const ui = SwaggerUIBundle({
                url: "/swagger/v1/swagger.json",
                dom_id: '#swagger-ui',
                deepLinking: true,
                presets: [
                    SwaggerUIBundle.presets.apis,
                    SwaggerUIBundle.SwaggerUIStandalonePreset
                ],
                layout: "BaseLayout",
                requestInterceptor: (request) => {
                    // Add custom headers
                    request.headers['X-Custom-Header'] = 'value';
                    return request;
                },
                onComplete: () => {
                    console.log("Swagger UI loaded");
                }
            });
            window.ui = ui;
        }
    </script>
</body>
</html>
```

```csharp
// Use custom index
app.UseSwaggerUI(c =>
{
    c.IndexStream = () => GetType().Assembly
        .GetManifestResourceStream("MyApi.wwwroot.swagger-ui.index.html");
});
```

## Generating OpenAPI Specification

### 1. Build-Time Generation

```xml
<!-- In .csproj -->
<Target Name="GenerateSwagger" AfterTargets="Build">
  <Exec Command="dotnet swagger tofile --output swagger.json $(OutputPath)$(AssemblyName).dll v1" />
</Target>
```

### 2. Runtime Generation

```csharp
// Endpoint to download OpenAPI spec
app.MapGet("/openapi.json", (IApiVersionDescriptionProvider provider) =>
{
    var swagger = app.Services.GetRequiredService<ISwaggerProvider>();
    var doc = swagger.GetSwagger("v1");
    return Results.Ok(doc);
});
```

### 3. Using Swagger CLI

```bash
# Install Swagger CLI
dotnet tool install -g Swashbuckle.AspNetCore.Cli

# Generate OpenAPI spec
dotnet swagger tofile --output swagger.json bin/Debug/net8.0/MyApi.dll v1

# Generate with specific host
dotnet swagger tofile --host https://api.example.com --output swagger.json bin/Debug/net8.0/MyApi.dll v1
```

## Client Generation

### 1. Using NSwag

```bash
# Install NSwag
dotnet tool install -g NSwag.ConsoleCore

# Generate C# client
nswag openapi2csclient /input:swagger.json /classname:ApiClient /namespace:MyApi.Client /output:ApiClient.cs

# Generate TypeScript client
nswag openapi2tsclient /input:swagger.json /classname:ApiClient /namespace:MyApi /output:api-client.ts
```

### 2. Using OpenAPI Generator

```bash
# Install OpenAPI Generator
npm install @openapitools/openapi-generator-cli -g

# Generate C# client
openapi-generator-cli generate -i swagger.json -g csharp-netcore -o ./generated/csharp

# Generate TypeScript client
openapi-generator-cli generate -i swagger.json -g typescript-axios -o ./generated/typescript
```

## Best Practices

### 1. ✅ DO's
- Provide comprehensive descriptions
- Include examples for complex types
- Document all response codes
- Use consistent naming conventions
- Version your API properly
- Include contact information
- Document authentication requirements

### 2. ❌ DON'Ts
- Don't expose sensitive information
- Don't use Swagger UI in production (or secure it)
- Don't forget to update documentation
- Don't use generic error messages
- Don't skip validation documentation

### 3. Security Considerations

```csharp
// Disable Swagger in production
if (!app.Environment.IsDevelopment())
{
    // Option 1: Don't add Swagger at all
    return;
    
    // Option 2: Require authentication
    app.UseSwagger(c =>
    {
        c.PreSerializeFilters.Add((swagger, httpReq) =>
        {
            if (!httpReq.Headers.ContainsKey("X-API-KEY") ||
                httpReq.Headers["X-API-KEY"] != "secret-key")
            {
                throw new UnauthorizedAccessException();
            }
        });
    });
}
```

## Common Issues and Solutions

### Issue: Swagger not showing all endpoints
**Solution**: Ensure all controllers have `[ApiController]` attribute and proper routing.

### Issue: Duplicate operation IDs
**Solution**: Use unique operation IDs or let Swagger generate them:
```csharp
c.CustomOperationIds(apiDesc =>
{
    return apiDesc.TryGetMethodInfo(out MethodInfo methodInfo) 
        ? methodInfo.Name 
        : null;
});
```

### Issue: Complex types not documented
**Solution**: Add XML comments to all public properties and use examples.

### Issue: File upload not working
**Solution**: Use proper attributes and operation filters for file uploads.

## Resources

- [OpenAPI Specification](https://swagger.io/specification/)
- [Swashbuckle Documentation](https://github.com/domaindrivendev/Swashbuckle.AspNetCore)
- [Swagger Editor](https://editor.swagger.io/)
- [OpenAPI Generator](https://openapi-generator.tech/)
- [NSwag](https://github.com/RicoSuter/NSwag)

---

Remember: Good API documentation is as important as good code. It's the first thing developers see when using your API!