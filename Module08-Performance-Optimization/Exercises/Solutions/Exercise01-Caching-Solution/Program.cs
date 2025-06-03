using CachingDemo.Data;
using CachingDemo.Models;
using CachingDemo.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Database configuration
builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    // Use in-memory database for demo purposes
    options.UseInMemoryDatabase("CachingDemo");
});

// Caching configuration
builder.Services.AddMemoryCache();

// Distributed caching (Redis)
if (builder.Configuration.GetConnectionString("RedisConnection") != null)
{
    builder.Services.AddStackExchangeRedisCache(options =>
    {
        options.Configuration = builder.Configuration.GetConnectionString("RedisConnection");
        options.InstanceName = "CachingDemo:";
    });
}

// Response caching
builder.Services.AddResponseCaching();

// Output caching
builder.Services.AddOutputCache(options =>
{
    // Configure default policy
    options.AddBasePolicy(builder => builder.Cache());
    
    // Add custom policy for products
    options.AddPolicy("Products", builder => 
        builder.Tag("products").Expire(TimeSpan.FromMinutes(10)));
        
    // Add policy for categories
    options.AddPolicy("Categories", builder =>
        builder.Tag("categories").Expire(TimeSpan.FromHours(1)));
});

// Register services
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<ICacheService, RedisCacheService>();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Add response caching middleware
app.UseResponseCaching();

// Add output caching middleware
app.UseOutputCache();

app.UseAuthorization();

app.MapControllers();

// Seed database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    await SeedDatabase(context);
}

app.Run();

static async Task SeedDatabase(ApplicationDbContext context)
{
    if (await context.Categories.AnyAsync())
        return;

    var categories = new[]
    {
        new Category { Id = 1, Name = "Electronics", Description = "Electronic devices and accessories" },
        new Category { Id = 2, Name = "Clothing", Description = "Apparel and fashion items" },
        new Category { Id = 3, Name = "Books", Description = "Books and publications" },
        new Category { Id = 4, Name = "Home & Garden", Description = "Home improvement and garden items" },
        new Category { Id = 5, Name = "Sports", Description = "Sports and fitness equipment" }
    };

    context.Categories.AddRange(categories);
    await context.SaveChangesAsync();

    var random = new Random();
    var products = new List<Product>();

    for (int i = 1; i <= 100; i++)
    {
        products.Add(new Product
        {
            Id = i,
            Name = $"Product {i}",
            Description = $"Description for product {i}",
            Price = (decimal)(random.NextDouble() * 1000),
            Stock = random.Next(0, 100),
            CategoryId = random.Next(1, 6),
            SKU = $"SKU-{i:D4}",
            IsActive = true,
            CreatedAt = DateTime.UtcNow.AddDays(-random.Next(1, 365))
        });
    }

    context.Products.AddRange(products);
    await context.SaveChangesAsync();
}

public partial class Program { }
