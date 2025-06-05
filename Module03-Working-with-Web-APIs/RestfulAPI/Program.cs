using System.Text;
using Asp.Versioning;
using Asp.Versioning.ApiExplorer;
using HealthChecks.UI.Client;
using RestfulAPI.Configuration;
using RestfulAPI.Data;
using RestfulAPI.HealthChecks;
using RestfulAPI.Middleware;
using RestfulAPI.Models;
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