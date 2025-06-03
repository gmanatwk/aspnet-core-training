using Microsoft.EntityFrameworkCore;

namespace RestfulAPI.Data;

/// <summary>
/// Data seeder for development environment
/// </summary>
public static class DataSeeder
{
    /// <summary>
    /// Seeds initial data into the database
    /// </summary>
    public static void SeedData(ApplicationDbContext context)
    {
        // Ensure database is created
        context.Database.EnsureCreated();

        // Check if data already exists
        if (context.Products.Any())
        {
            return; // Database has been seeded
        }

        // Products are seeded via EF migrations
        // Force load the seeded data
        context.SaveChanges();
    }
}