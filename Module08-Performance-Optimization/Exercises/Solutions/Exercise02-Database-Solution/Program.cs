using DatabaseOptimization.Data;
using DatabaseOptimization.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Database configuration
builder.Services.AddDbContext<AppDbContext>(options =>
{
    if (builder.Environment.IsDevelopment())
    {
        options.UseInMemoryDatabase("DatabaseOptimizationDemo");
        options.EnableSensitiveDataLogging();
        options.LogTo(Console.WriteLine, LogLevel.Information);
    }
    else
    {
        options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
    }
});

// Register services
builder.Services.AddScoped<IIneffientProductService, IneffientProductService>();
builder.Services.AddScoped<IOptimizedProductService, OptimizedProductService>();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

// Seed database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await SeedDatabase(context);
}

app.Run();

static async Task SeedDatabase(AppDbContext context)
{
    if (await context.Categories.AnyAsync())
        return;

    // Seed categories
    var categories = new[]
    {
        new DatabaseOptimization.Models.Category { Id = 1, Name = "Electronics", Description = "Electronic devices" },
        new DatabaseOptimization.Models.Category { Id = 2, Name = "Clothing", Description = "Apparel items" },
        new DatabaseOptimization.Models.Category { Id = 3, Name = "Books", Description = "Books and publications" },
        new DatabaseOptimization.Models.Category { Id = 4, Name = "Home & Garden", Description = "Home items" },
        new DatabaseOptimization.Models.Category { Id = 5, Name = "Sports", Description = "Sports equipment" }
    };

    context.Categories.AddRange(categories);
    await context.SaveChangesAsync();

    // Seed tags
    var tags = new[]
    {
        new DatabaseOptimization.Models.Tag { Id = 1, Name = "New" },
        new DatabaseOptimization.Models.Tag { Id = 2, Name = "Sale" },
        new DatabaseOptimization.Models.Tag { Id = 3, Name = "Featured" },
        new DatabaseOptimization.Models.Tag { Id = 4, Name = "Popular" },
        new DatabaseOptimization.Models.Tag { Id = 5, Name = "Limited" }
    };

    context.Tags.AddRange(tags);
    await context.SaveChangesAsync();

    // Seed products (large dataset for performance testing)
    var random = new Random(42); // Fixed seed for reproducibility
    var products = new List<DatabaseOptimization.Models.Product>();

    for (int i = 1; i <= 1000; i++)
    {
        products.Add(new DatabaseOptimization.Models.Product
        {
            Id = i,
            Name = $"Product {i}",
            Description = $"Description for product {i}",
            Price = (decimal)(random.NextDouble() * 1000),
            Stock = random.Next(0, 100),
            CategoryId = random.Next(1, 6),
            IsActive = random.NextDouble() > 0.1, // 90% active
            CreatedAt = DateTime.UtcNow.AddDays(-random.Next(1, 365))
        });
    }

    context.Products.AddRange(products);
    await context.SaveChangesAsync();

    // Seed product tags
    var productTags = new List<DatabaseOptimization.Models.ProductTag>();
    foreach (var product in products)
    {
        var tagCount = random.Next(1, 4); // 1-3 tags per product
        var selectedTags = tags.OrderBy(x => random.Next()).Take(tagCount);
        
        foreach (var tag in selectedTags)
        {
            productTags.Add(new DatabaseOptimization.Models.ProductTag
            {
                ProductId = product.Id,
                TagId = tag.Id
            });
        }
    }

    context.ProductTags.AddRange(productTags);
    await context.SaveChangesAsync();

    // Seed orders
    var orders = new List<DatabaseOptimization.Models.Order>();
    var orderItems = new List<DatabaseOptimization.Models.OrderItem>();

    for (int i = 1; i <= 500; i++)
    {
        var order = new DatabaseOptimization.Models.Order
        {
            Id = i,
            CustomerName = $"Customer {i}",
            CustomerEmail = $"customer{i}@example.com",
            OrderDate = DateTime.UtcNow.AddDays(-random.Next(1, 365)),
            TotalAmount = 0 // Will be calculated
        };

        orders.Add(order);

        // Add 1-5 items per order
        var itemCount = random.Next(1, 6);
        decimal totalAmount = 0;

        for (int j = 0; j < itemCount; j++)
        {
            var product = products[random.Next(products.Count)];
            var quantity = random.Next(1, 5);
            var unitPrice = product.Price;

            orderItems.Add(new DatabaseOptimization.Models.OrderItem
            {
                OrderId = order.Id,
                ProductId = product.Id,
                Quantity = quantity,
                UnitPrice = unitPrice
            });

            totalAmount += quantity * unitPrice;
        }

        order.TotalAmount = totalAmount;
    }

    context.Orders.AddRange(orders);
    await context.SaveChangesAsync();

    context.OrderItems.AddRange(orderItems);
    await context.SaveChangesAsync();
}

public partial class Program { }
