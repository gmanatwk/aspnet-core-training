using Microsoft.EntityFrameworkCore;
using RestfulAPI.Models;

namespace RestfulAPI.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<Product> Products => Set<Product>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Configure Product entity
            modelBuilder.Entity<Product>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
                entity.Property(e => e.Description).HasMaxLength(2000);
                entity.Property(e => e.Category).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Sku).IsRequired().HasMaxLength(50);
                entity.HasIndex(e => e.Sku).IsUnique();
                entity.Property(e => e.Price).HasPrecision(18, 2);

                // Add query filter to exclude soft-deleted items
                entity.HasQueryFilter(p => !p.IsDeleted);
            });

            // Seed data
            modelBuilder.Entity<Product>().HasData(
                new Product
                {
                    Id = 1,
                    Name = "Laptop Computer",
                    Description = "High-performance laptop with 16GB RAM and 512GB SSD",
                    Price = 999.99m,
                    Category = "Electronics",
                    StockQuantity = 50,
                    Sku = "ELEC-LAP-001",
                    IsActive = true,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Product
                {
                    Id = 2,
                    Name = "Wireless Mouse",
                    Description = "Ergonomic wireless mouse with precision tracking",
                    Price = 29.99m,
                    Category = "Accessories",
                    StockQuantity = 100,
                    Sku = "ACC-MOU-002",
                    IsActive = true,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Product
                {
                    Id = 3,
                    Name = "Programming Book",
                    Description = "Comprehensive guide to modern software development",
                    Price = 49.99m,
                    Category = "Books",
                    StockQuantity = 25,
                    Sku = "BOOK-PROG-003",
                    IsActive = true,
                    IsAvailable = true,
                    CreatedAt = DateTime.UtcNow
                }
            );
        }
    }
}
