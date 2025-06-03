using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using ProductCatalog.API.Data;
using ProductCatalog.API.Models;
using ProductCatalog.API.Services;
using System.Linq;

namespace ProductCatalog.IntegrationTests;

/// <summary>
/// Custom WebApplicationFactory for integration tests
/// Sets up a test server with in-memory database and seeded test data
/// </summary>
public class CustomWebApplicationFactory<TProgram> : WebApplicationFactory<TProgram> where TProgram : class
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // Find the DbContext registration and replace with in-memory database
            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<ProductCatalogContext>));

            if (descriptor != null)
            {
                services.Remove(descriptor);
            }

            // Add in-memory database for testing
            services.AddDbContext<ProductCatalogContext>(options =>
            {
                options.UseInMemoryDatabase("InMemoryDbForTesting");
            });

            // Replace real notification service with test mock
            services.AddScoped<INotificationService, TestNotificationService>();

            // Build service provider
            var sp = services.BuildServiceProvider();

            // Create scope for database initialization
            using var scope = sp.CreateScope();
            var scopedServices = scope.ServiceProvider;
            var db = scopedServices.GetRequiredService<ProductCatalogContext>();
            var logger = scopedServices.GetRequiredService<ILogger<CustomWebApplicationFactory<TProgram>>>();

            // Ensure database is created and seed test data
            db.Database.EnsureCreated();

            try
            {
                SeedTestData(db);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred seeding the database with test data. Error: {Message}", ex.Message);
            }
        });
    }

    private static void SeedTestData(ProductCatalogContext context)
    {
        // Add categories
        var categories = new List<Category>
        {
            new Category
            {
                Id = 1,
                Name = "Electronics",
                Description = "Electronic devices and gadgets",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = 2,
                Name = "Clothing",
                Description = "Apparel and accessories",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            }
        };

        context.Categories.AddRange(categories);

        // Add products
        var products = new List<Product>
        {
            new Product
            {
                Id = 1,
                Name = "Smartphone",
                Description = "Latest model smartphone",
                Price = 699.99M,
                Stock = 50,
                CategoryId = 1,
                SKU = "ELEC-1001",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            },
            new Product
            {
                Id = 2,
                Name = "Laptop",
                Description = "High-performance laptop",
                Price = 1299.99M,
                Stock = 25,
                CategoryId = 1,
                SKU = "ELEC-1002",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            },
            new Product
            {
                Id = 3,
                Name = "T-Shirt",
                Description = "Cotton t-shirt",
                Price = 19.99M,
                Stock = 100,
                CategoryId = 2,
                SKU = "CLOTH-2001",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            },
            new Product
            {
                Id = 4,
                Name = "Jeans",
                Description = "Denim jeans",
                Price = 49.99M,
                Stock = 75,
                CategoryId = 2,
                SKU = "CLOTH-2002",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            }
        };

        context.Products.AddRange(products);

        // Add tags
        var tags = new List<Tag>
        {
            new Tag { Id = 1, Name = "New Arrival" },
            new Tag { Id = 2, Name = "Best Seller" },
            new Tag { Id = 3, Name = "Sale" }
        };

        context.Tags.AddRange(tags);

        // Add product tags
        var productTags = new List<ProductTag>
        {
            new ProductTag { ProductId = 1, TagId = 1 },
            new ProductTag { ProductId = 1, TagId = 2 },
            new ProductTag { ProductId = 2, TagId = 1 },
            new ProductTag { ProductId = 3, TagId = 3 },
            new ProductTag { ProductId = 4, TagId = 2 }
        };

        context.ProductTags.AddRange(productTags);

        // Add test orders
        var orders = new List<Order>
        {
            new Order
            {
                Id = 1,
                CustomerName = "John Doe",
                CustomerEmail = "john.doe@example.com",
                OrderDate = DateTime.UtcNow.AddDays(-2),
                Status = OrderStatus.Delivered,
                TotalAmount = 699.99M
            },
            new Order
            {
                Id = 2,
                CustomerName = "Jane Smith",
                CustomerEmail = "jane.smith@example.com",
                OrderDate = DateTime.UtcNow.AddDays(-1),
                Status = OrderStatus.Processing,
                TotalAmount = 1319.98M
            }
        };

        context.Orders.AddRange(orders);

        // Add order items
        var orderItems = new List<OrderItem>
        {
            new OrderItem
            {
                OrderId = 1,
                ProductId = 1,
                Quantity = 1,
                UnitPrice = 699.99M
            },
            new OrderItem
            {
                OrderId = 2,
                ProductId = 2,
                Quantity = 1,
                UnitPrice = 1299.99M
            },
            new OrderItem
            {
                OrderId = 2,
                ProductId = 3,
                Quantity = 1,
                UnitPrice = 19.99M
            }
        };

        context.OrderItems.AddRange(orderItems);
        context.SaveChanges();
    }
}

/// <summary>
/// Test notification service that doesn't make external calls
/// </summary>
public class TestNotificationService : INotificationService
{
    public Task<bool> IsEmailValidAsync(string email)
    {
        // Simple validation logic for testing
        return Task.FromResult(!string.IsNullOrWhiteSpace(email) && 
                                email.Contains('@') && 
                                email.Contains('.') && 
                                !email.Contains("invalid"));
    }

    public Task SendEmailAsync(string to, string subject, string body)
    {
        // Do nothing, just simulate successful sending
        return Task.CompletedTask;
    }

    public Task SendSmsAsync(string phoneNumber, string message)
    {
        // Do nothing, just simulate successful sending
        return Task.CompletedTask;
    }
}