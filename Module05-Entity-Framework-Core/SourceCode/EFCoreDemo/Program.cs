using EFCoreDemo.Data;
using EFCoreDemo.Mapping;
using EFCoreDemo.Models;
using EFCoreDemo.Repositories;
using EFCoreDemo.Services;
using EFCoreDemo.UnitOfWork;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { 
        Title = "EF Core Demo API - Complete Module 05", 
        Version = "v1",
        Description = "Comprehensive demonstration of Entity Framework Core with Product Catalog system and all exercises"
    });
    
    // Include XML comments for better API documentation
    var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
    {
        c.IncludeXmlComments(xmlPath);
    }
});

// Configure Entity Framework for Product Catalog (existing demo)
builder.Services.AddDbContext<ProductCatalogContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    options.UseSqlServer(connectionString);
    
    // Enable detailed errors in development
    if (builder.Environment.IsDevelopment())
    {
        options.EnableDetailedErrors();
        options.EnableSensitiveDataLogging();
    }
});

// Configure Entity Framework for BookStore (Exercises 01-03)
builder.Services.AddDbContext<BookStoreContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("BookStoreConnection") 
        ?? builder.Configuration.GetConnectionString("DefaultConnection");
    options.UseSqlServer(connectionString);
    
    // Enable detailed errors in development
    if (builder.Environment.IsDevelopment())
    {
        options.EnableDetailedErrors();
        options.EnableSensitiveDataLogging();
    }
});

// Configure AutoMapper
builder.Services.AddAutoMapper(typeof(MappingProfile));

// Register repositories for Product Catalog
builder.Services.AddScoped<IProductRepository, ProductRepository>();
builder.Services.AddScoped<ICategoryRepository, CategoryRepository>();
builder.Services.AddScoped(typeof(IRepository<>), typeof(Repository<>));

// Register repositories for BookStore (Exercise 03)
builder.Services.AddScoped<IBookRepository, BookRepository>();
builder.Services.AddScoped<IAuthorRepository, AuthorRepository>();

// Register Unit of Work (Exercise 03)
builder.Services.AddScoped<IUnitOfWork, EFCoreDemo.UnitOfWork.UnitOfWork>();

// Register services (Exercise 02)
builder.Services.AddScoped<BookQueryService>();

// Configure logging
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();

// Configure CORS for development
builder.Services.AddCors(options =>
{
    options.AddPolicy("DevelopmentPolicy", policy =>
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
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "EF Core Demo API v1");
        c.RoutePrefix = string.Empty; // Set Swagger UI as the root page
    });
    
    app.UseCors("DevelopmentPolicy");
    
    // Ensure databases are created and seeded
    await EnsureDatabasesCreated(app);
}

// Serve static files from wwwroot
app.UseStaticFiles();

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();

/// <summary>
/// Ensures all databases are created and properly seeded with initial data
/// </summary>
static async Task EnsureDatabasesCreated(WebApplication app)
{
    using var scope = app.Services.CreateScope();
    var productContext = scope.ServiceProvider.GetRequiredService<ProductCatalogContext>();
    var bookContext = scope.ServiceProvider.GetRequiredService<BookStoreContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    
    try
    {
        // Ensure Product Catalog database is created
        logger.LogInformation("Initializing Product Catalog database...");
        await productContext.Database.EnsureCreatedAsync();
        
        // Apply any pending migrations for Product Catalog
        if (productContext.Database.GetPendingMigrations().Any())
        {
            logger.LogInformation("Applying pending migrations to Product Catalog...");
            await productContext.Database.MigrateAsync();
        }
        
        // Ensure BookStore database is created (Exercise 01)
        logger.LogInformation("Initializing BookStore database...");
        await bookContext.Database.EnsureCreatedAsync();
        
        // Apply any pending migrations for BookStore
        if (bookContext.Database.GetPendingMigrations().Any())
        {
            logger.LogInformation("Applying pending migrations to BookStore...");
            await bookContext.Database.MigrateAsync();
        }
        
        logger.LogInformation("All databases initialized successfully");
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "An error occurred while creating the databases");
        throw;
    }
}