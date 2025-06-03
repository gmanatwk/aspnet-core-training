using Microsoft.EntityFrameworkCore;
using ProductService.Models;

namespace ProductService.Data;

public class ProductDbContext : DbContext
{
    public ProductDbContext(DbContextOptions<ProductDbContext> options)
        : base(options)
    {
    }

    public DbSet<Product> Products { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure Product entity
        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.Price).HasPrecision(18, 2);
            entity.HasIndex(e => e.Name);
            entity.HasIndex(e => e.Category);
        });

        // Seed initial data
        modelBuilder.Entity<Product>().HasData(
            new Product
            {
                Id = 1,
                Name = "Laptop",
                Description = "High-performance laptop for professionals",
                Price = 1299.99m,
                StockQuantity = 50,
                Category = "Electronics",
                CreatedAt = DateTime.UtcNow
            },
            new Product
            {
                Id = 2,
                Name = "Wireless Mouse",
                Description = "Ergonomic wireless mouse with precision tracking",
                Price = 39.99m,
                StockQuantity = 200,
                Category = "Electronics",
                CreatedAt = DateTime.UtcNow
            },
            new Product
            {
                Id = 3,
                Name = "USB-C Hub",
                Description = "Multi-port USB-C hub with HDMI and ethernet",
                Price = 59.99m,
                StockQuantity = 150,
                Category = "Electronics",
                CreatedAt = DateTime.UtcNow
            },
            new Product
            {
                Id = 4,
                Name = "Standing Desk",
                Description = "Adjustable height standing desk",
                Price = 499.99m,
                StockQuantity = 30,
                Category = "Furniture",
                CreatedAt = DateTime.UtcNow
            },
            new Product
            {
                Id = 5,
                Name = "Office Chair",
                Description = "Ergonomic office chair with lumbar support",
                Price = 299.99m,
                StockQuantity = 75,
                Category = "Furniture",
                CreatedAt = DateTime.UtcNow
            }
        );
    }
}