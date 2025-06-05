using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using RestfulAPI.Data;
using System.Linq;

namespace RestfulAPI.Tests.Fixtures;

public class CustomWebApplicationFactory<TProgram> : WebApplicationFactory<TProgram> where TProgram : class
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // Remove the existing DbContext configuration
            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<ApplicationDbContext>));

            if (descriptor != null)
            {
                services.Remove(descriptor);
            }

            // Add ApplicationDbContext using in-memory database for testing
            services.AddDbContext<ApplicationDbContext>(options =>
            {
                options.UseInMemoryDatabase("InMemoryDbForTesting");
            });

            // Build the service provider
            var sp = services.BuildServiceProvider();

            // Create a scope to obtain a reference to the database context
            using (var scope = sp.CreateScope())
            {
                var scopedServices = scope.ServiceProvider;
                var db = scopedServices.GetRequiredService<ApplicationDbContext>();
                var logger = scopedServices.GetRequiredService<ILogger<CustomWebApplicationFactory<TProgram>>>();

                // Ensure the database is created
                db.Database.EnsureCreated();

                try
                {
                    // Seed the database with test data
                    SeedTestData(db);
                }
                catch (Exception ex)
                {
                    logger.LogError(ex, "An error occurred seeding the database with test data. Error: {Message}", ex.Message);
                }
            }
        });
    }

    private static void SeedTestData(ApplicationDbContext context)
    {
        // Clear existing data
        context.Products.RemoveRange(context.Products);
        context.Users.RemoveRange(context.Users);
        context.SaveChanges();

        // Add test products
        context.Products.AddRange(
            new RestfulAPI.Models.Product
            {
                Id = 1,
                Name = "Test Product 1",
                Description = "Test Description 1",
                Price = 10.99M,
                Category = "Electronics",
                StockQuantity = 100,
                IsAvailable = true,
                Sku = "TEST-001",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            },
            new RestfulAPI.Models.Product
            {
                Id = 2,
                Name = "Test Product 2",
                Description = "Test Description 2",
                Price = 25.50M,
                Category = "Books",
                StockQuantity = 50,
                IsAvailable = true,
                Sku = "TEST-002",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            },
            new RestfulAPI.Models.Product
            {
                Id = 3,
                Name = "Test Product 3",
                Description = "Test Description 3",
                Price = 5.00M,
                Category = "Electronics",
                StockQuantity = 0,
                IsAvailable = false,
                Sku = "TEST-003",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            }
        );

        // Add test roles
        var adminRole = new RestfulAPI.Models.Role { Id = 1, Name = "Admin", Description = "Administrator role" };
        var managerRole = new RestfulAPI.Models.Role { Id = 2, Name = "Manager", Description = "Manager role" };
        var userRole = new RestfulAPI.Models.Role { Id = 3, Name = "User", Description = "Regular user role" };
        
        context.Set<RestfulAPI.Models.Role>().AddRange(adminRole, managerRole, userRole);

        // Add test users
        var adminUser = new RestfulAPI.Models.User
        {
            Id = 1,
            Email = "admin@test.com",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin123!"),
            FullName = "Admin User",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
        
        var managerUser = new RestfulAPI.Models.User
        {
            Id = 2,
            Email = "manager@test.com",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Manager123!"),
            FullName = "Manager User",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
        
        var regularUser = new RestfulAPI.Models.User
        {
            Id = 3,
            Email = "user@test.com",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("User123!"),
            FullName = "Regular User",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
        
        context.Users.AddRange(adminUser, managerUser, regularUser);
        context.SaveChanges();

        // Add user roles relationships
        context.Set<RestfulAPI.Models.UserRole>().AddRange(
            new RestfulAPI.Models.UserRole { UserId = 1, RoleId = 1 }, // Admin user has Admin role
            new RestfulAPI.Models.UserRole { UserId = 2, RoleId = 2 }, // Manager user has Manager role
            new RestfulAPI.Models.UserRole { UserId = 3, RoleId = 3 }  // Regular user has User role
        );

        context.SaveChanges();
    }
}