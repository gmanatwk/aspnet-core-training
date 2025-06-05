using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Mvc;
using Asp.Versioning;
using Asp.Versioning.ApiExplorer;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using RestfulAPI.Configuration;
using RestfulAPI.Data;
using RestfulAPI.DTOs;
using RestfulAPI.HealthChecks;
using RestfulAPI.Middleware;
using RestfulAPI.Services;
using Serilog;
using Swashbuckle.AspNetCore.SwaggerGen;
using System.Reflection;
using System.Text;
using HealthChecks.UI.Client;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.Diagnostics.HealthChecks;

// Configure Serilog
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .WriteTo.File("logs/api-.log", rollingInterval: RollingInterval.Day)
    .CreateLogger();

try
{
    Log.Information("Starting RestfulAPI application");

    var builder = WebApplication.CreateBuilder(args);

    // Add Serilog
    builder.Host.UseSerilog();

    // Add services to the container
    builder.Services.AddControllers(options =>
    {
        options.ReturnHttpNotAcceptable = true;
        options.RespectBrowserAcceptHeader = true;
    })
    .AddNewtonsoftJson(options =>
    {
        options.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore;
    })
    .AddXmlSerializerFormatters()
    .ConfigureApiBehaviorOptions(options =>
    {
        options.InvalidModelStateResponseFactory = context =>
        {
            var problems = new ValidationProblemDetails(context.ModelState)
            {
                Type = "https://tools.ietf.org/html/rfc7231#section-6.5.1",
                Title = "One or more validation errors occurred.",
                Status = StatusCodes.Status400BadRequest,
                Detail = "See the errors property for details.",
                Instance = context.HttpContext.Request.Path
            };

            problems.Extensions.Add("traceId", context.HttpContext.TraceIdentifier);

            return new BadRequestObjectResult(problems)
            {
                ContentTypes = { "application/problem+json", "application/problem+xml" }
            };
        };
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
            new MediaTypeApiVersionReader("ver")
        );
    });

    builder.Services.AddApiVersioning().AddApiExplorer(options =>
    {
        options.GroupNameFormat = "'v'VVV";
        options.SubstituteApiVersionInUrl = true;
    });

    // Configure Entity Framework
    builder.Services.AddDbContext<ApplicationDbContext>(options =>
    {
        var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
        
        // Try to use SQL Server if connection string is provided
        if (!string.IsNullOrEmpty(connectionString))
        {
            options.UseSqlServer(connectionString, sqlOptions =>
            {
                sqlOptions.EnableRetryOnFailure(
                    maxRetryCount: 5,
                    maxRetryDelay: TimeSpan.FromSeconds(30),
                    errorNumbersToAdd: null);
            });
            
            Log.Information("Using SQL Server database");
        }
        else
        {
            // Fall back to in-memory database
            options.UseInMemoryDatabase("ProductsDb");
            Log.Information("Using in-memory database");
        }
    });

    // Add JWT Authentication
    var jwtSettings = builder.Configuration.GetSection("JwtSettings");
    var key = Encoding.ASCII.GetBytes(jwtSettings["SecretKey"] ?? "ThisIsASecretKeyForDevelopmentOnly");

    builder.Services.AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer(options =>
    {
        options.RequireHttpsMetadata = !builder.Environment.IsDevelopment();
        options.SaveToken = true;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(key),
            ValidateIssuer = true,
            ValidIssuer = jwtSettings["Issuer"],
            ValidateAudience = true,
            ValidAudience = jwtSettings["Audience"],
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero
        };

        options.Events = new JwtBearerEvents
        {
            OnAuthenticationFailed = context =>
            {
                if (context.Exception.GetType() == typeof(SecurityTokenExpiredException))
                {
                    context.Response.Headers["Token-Expired"] = "true";
                }
                return Task.CompletedTask;
            }
        };
    });

    // Add Authorization
    builder.Services.AddAuthorization(options =>
    {
        options.AddPolicy("RequireAdminRole", policy => policy.RequireRole("Admin"));
        options.AddPolicy("RequireManagerRole", policy => policy.RequireRole("Admin", "Manager"));
    });

    // Configure Swagger/OpenAPI
    builder.Services.AddTransient<IConfigureOptions<SwaggerGenOptions>, ConfigureSwaggerOptions>();
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen(options =>
    {
        options.EnableAnnotations();
    });

    // Add CORS
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("AllowSpecificOrigins", policy =>
        {
            policy.WithOrigins(
                "http://localhost:3000",
                "https://localhost:3000",
                "http://localhost:5173",
                "https://localhost:5173")
                .AllowAnyHeader()
                .AllowAnyMethod()
                .AllowCredentials();
        });

        options.AddPolicy("AllowAll", policy =>
        {
            policy.AllowAnyOrigin()
                .AllowAnyHeader()
                .AllowAnyMethod();
        });
    });

    // Add services
    builder.Services.AddScoped<IProductService, ProductService>();
    builder.Services.AddSingleton<ITokenService, TokenService>();
    builder.Services.AddScoped<IUserService, UserService>();

    // Add response caching
    builder.Services.AddResponseCaching();

    // Add compression
    builder.Services.AddResponseCompression(options =>
    {
        options.EnableForHttps = true;
    });

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

    // Add HTTP client
    builder.Services.AddHttpClient();

    // Add memory cache
    builder.Services.AddMemoryCache();

    var app = builder.Build();

    // Configure the HTTP request pipeline
    app.UseSerilogRequestLogging();

    // Add custom exception handling middleware
    app.UseMiddleware<GlobalExceptionMiddleware>();

    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI(options =>
        {
            var provider = app.Services.GetRequiredService<IApiVersionDescriptionProvider>();
            
            foreach (var description in provider.ApiVersionDescriptions)
            {
                options.SwaggerEndpoint(
                    $"/swagger/{description.GroupName}/swagger.json",
                    $"Products API {description.GroupName.ToUpperInvariant()}");
            }

            options.RoutePrefix = ""; // Serve Swagger UI at root
            options.DocumentTitle = "Products RESTful API";
        });

        // Seed database
        using (var scope = app.Services.CreateScope())
        {
            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            try
            {
                DataSeeder.SeedData(context);
            }
            catch (Exception ex)
            {
                Log.Warning("Failed to seed database: {Message}. Using in-memory database if SQL Server is unavailable.", ex.Message);
            }
        }
    }
    else
    {
        // Production security headers
        app.UseHsts();
        app.Use(async (context, next) =>
        {
            context.Response.Headers["X-Content-Type-Options"] = "nosniff";
            context.Response.Headers["X-Frame-Options"] = "DENY";
            context.Response.Headers["X-XSS-Protection"] = "1; mode=block";
            context.Response.Headers["Referrer-Policy"] = "no-referrer";
            context.Response.Headers["Content-Security-Policy"] = "default-src 'self'";
            await next();
        });
    }

    // Only use HTTPS redirection in production
    if (!app.Environment.IsDevelopment())
    {
        app.UseHttpsRedirection();
    }

    // Enable static files
    app.UseStaticFiles();

    // Use CORS
    if (app.Environment.IsDevelopment())
    {
        app.UseCors("AllowAll");
    }
    else
    {
        app.UseCors("AllowSpecificOrigins");
    }

    // Use response caching
    app.UseResponseCaching();

    // Use response compression
    app.UseResponseCompression();

    // Add the analytics middleware
    app.UseMiddleware<ApiAnalyticsMiddleware>();

    // Use authentication & authorization
    app.UseAuthentication();
    app.UseAuthorization();

    // Map controllers
    app.MapControllers();

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

    // Map minimal API endpoints
    // Commented out because Swagger UI is served at root
    // app.MapGet("/", () => Results.Redirect("/index.html"))
    //     .ExcludeFromDescription();

    // Minimal API example - lightweight endpoints
    var productsApi = app.MapGroup("/api/minimal/products")
        .WithTags("Minimal Products API");

    productsApi.MapGet("/", async (IProductService productService) =>
    {
        var products = await productService.GetProductsAsync(null, null, null, 1, 100);
        return Results.Ok(products);
    })
    .WithName("GetAllProductsMinimal")
    .Produces<PagedResponse<ProductDto>>(StatusCodes.Status200OK);

    productsApi.MapGet("/{id:int}", async (int id, IProductService productService) =>
    {
        var product = await productService.GetProductByIdAsync(id);
        return product is not null 
            ? Results.Ok(product) 
            : Results.NotFound(new { message = $"Product with ID {id} not found" });
    })
    .WithName("GetProductByIdMinimal")
    .Produces<ProductDto>(StatusCodes.Status200OK)
    .Produces(StatusCodes.Status404NotFound);

    productsApi.MapPost("/", async (CreateProductDto dto, IProductService productService) =>
    {
        var product = await productService.CreateProductAsync(dto);
        return Results.Created($"/api/minimal/products/{product.Id}", product);
    })
    .WithName("CreateProductMinimal")
    .Produces<ProductDto>(StatusCodes.Status201Created)
    .ProducesValidationProblem();

    productsApi.MapDelete("/{id:int}", async (int id, IProductService productService) =>
    {
        var deleted = await productService.DeleteProductAsync(id);
        return deleted ? Results.NoContent() : Results.NotFound();
    })
    .WithName("DeleteProductMinimal")
    .Produces(StatusCodes.Status204NoContent)
    .Produces(StatusCodes.Status404NotFound);

    // Run the application
    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}

// Make the implicit Program class public so test projects can access it
public partial class Program { }