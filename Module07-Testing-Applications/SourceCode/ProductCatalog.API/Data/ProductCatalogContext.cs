using Microsoft.EntityFrameworkCore;
using ProductCatalog.API.Models;

namespace ProductCatalog.API.Data;

/// <summary>
/// Entity Framework DbContext for Product Catalog
/// </summary>
public class ProductCatalogContext : DbContext
{
    public ProductCatalogContext(DbContextOptions<ProductCatalogContext> options) : base(options)
    {
    }

    public DbSet<Product> Products { get; set; }
    public DbSet<Category> Categories { get; set; }
    public DbSet<Tag> Tags { get; set; }
    public DbSet<ProductTag> ProductTags { get; set; }
    public DbSet<Order> Orders { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Product configuration
        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Description).HasMaxLength(1000);
            entity.Property(e => e.Price).HasColumnType("decimal(18,2)");
            entity.Property(e => e.SKU).HasMaxLength(100);
            entity.Property(e => e.Weight).HasColumnType("decimal(18,2)");
            entity.Property(e => e.ImageUrl).HasMaxLength(500);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

            entity.HasIndex(e => e.SKU).IsUnique().HasFilter("[SKU] IS NOT NULL");
            entity.HasIndex(e => e.Name);
            entity.HasIndex(e => e.CategoryId);
            entity.HasIndex(e => e.IsActive);

            entity.HasOne(e => e.Category)
                  .WithMany(c => c.Products)
                  .HasForeignKey(e => e.CategoryId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // Category configuration
        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

            entity.HasIndex(e => e.Name).IsUnique();
            entity.HasIndex(e => e.IsActive);
        });

        // Tag configuration
        modelBuilder.Entity<Tag>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
            entity.Property(e => e.Description).HasMaxLength(200);

            entity.HasIndex(e => e.Name).IsUnique();
        });

        // ProductTag configuration (Many-to-Many)
        modelBuilder.Entity<ProductTag>(entity =>
        {
            entity.HasKey(e => new { e.ProductId, e.TagId });
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

            entity.HasOne(e => e.Product)
                  .WithMany(p => p.ProductTags)
                  .HasForeignKey(e => e.ProductId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.Tag)
                  .WithMany(t => t.ProductTags)
                  .HasForeignKey(e => e.TagId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // Order configuration
        modelBuilder.Entity<Order>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.CustomerName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.CustomerEmail).IsRequired().HasMaxLength(100);
            entity.Property(e => e.TotalAmount).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Notes).HasMaxLength(500);
            entity.Property(e => e.OrderDate).HasDefaultValueSql("GETUTCDATE()");

            entity.HasIndex(e => e.CustomerEmail);
            entity.HasIndex(e => e.OrderDate);
            entity.HasIndex(e => e.Status);
        });

        // OrderItem configuration
        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.UnitPrice).HasColumnType("decimal(18,2)");

            entity.HasOne(e => e.Order)
                  .WithMany(o => o.OrderItems)
                  .HasForeignKey(e => e.OrderId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.Product)
                  .WithMany()
                  .HasForeignKey(e => e.ProductId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // Seed initial data
        SeedData(modelBuilder);
    }

    private static void SeedData(ModelBuilder modelBuilder)
    {
        // Seed Categories
        modelBuilder.Entity<Category>().HasData(
            new Category { Id = 1, Name = "Electronics", Description = "Electronic devices and accessories", IsActive = true, CreatedAt = DateTime.UtcNow },
            new Category { Id = 2, Name = "Clothing", Description = "Apparel and fashion items", IsActive = true, CreatedAt = DateTime.UtcNow },
            new Category { Id = 3, Name = "Books", Description = "Books and educational materials", IsActive = true, CreatedAt = DateTime.UtcNow },
            new Category { Id = 4, Name = "Home & Garden", Description = "Home improvement and gardening supplies", IsActive = true, CreatedAt = DateTime.UtcNow }
        );

        // Seed Tags
        modelBuilder.Entity<Tag>().HasData(
            new Tag { Id = 1, Name = "Featured", Description = "Featured products" },
            new Tag { Id = 2, Name = "Sale", Description = "Products on sale" },
            new Tag { Id = 3, Name = "New", Description = "New arrivals" },
            new Tag { Id = 4, Name = "Popular", Description = "Popular products" },
            new Tag { Id = 5, Name = "Eco-Friendly", Description = "Environmentally friendly products" }
        );

        // Seed Products
        modelBuilder.Entity<Product>().HasData(
            new Product 
            { 
                Id = 1, 
                Name = "Laptop Pro 15\"", 
                Description = "High-performance laptop for professionals", 
                Price = 1299.99M, 
                Stock = 25, 
                CategoryId = 1, 
                SKU = "LAP-PRO-15", 
                Weight = 2.1M, 
                IsActive = true, 
                CreatedAt = DateTime.UtcNow 
            },
            new Product 
            { 
                Id = 2, 
                Name = "Wireless Headphones", 
                Description = "Premium noise-cancelling wireless headphones", 
                Price = 199.99M, 
                Stock = 50, 
                CategoryId = 1, 
                SKU = "HEAD-WIR-001", 
                Weight = 0.3M, 
                IsActive = true, 
                CreatedAt = DateTime.UtcNow 
            },
            new Product 
            { 
                Id = 3, 
                Name = "Cotton T-Shirt", 
                Description = "Comfortable 100% cotton t-shirt", 
                Price = 29.99M, 
                Stock = 100, 
                CategoryId = 2, 
                SKU = "SHIRT-COT-001", 
                Weight = 0.2M, 
                IsActive = true, 
                CreatedAt = DateTime.UtcNow 
            },
            new Product 
            { 
                Id = 4, 
                Name = "Programming Book", 
                Description = "Complete guide to modern programming", 
                Price = 49.99M, 
                Stock = 30, 
                CategoryId = 3, 
                SKU = "BOOK-PROG-001", 
                Weight = 0.8M, 
                IsActive = true, 
                CreatedAt = DateTime.UtcNow 
            },
            new Product 
            { 
                Id = 5, 
                Name = "Garden Tool Set", 
                Description = "Complete set of garden tools", 
                Price = 89.99M, 
                Stock = 15, 
                CategoryId = 4, 
                SKU = "TOOL-GARD-SET", 
                Weight = 3.5M, 
                IsActive = true, 
                CreatedAt = DateTime.UtcNow 
            }
        );

        // Seed ProductTags
        modelBuilder.Entity<ProductTag>().HasData(
            new ProductTag { ProductId = 1, TagId = 1, CreatedAt = DateTime.UtcNow }, // Laptop - Featured
            new ProductTag { ProductId = 1, TagId = 4, CreatedAt = DateTime.UtcNow }, // Laptop - Popular
            new ProductTag { ProductId = 2, TagId = 3, CreatedAt = DateTime.UtcNow }, // Headphones - New
            new ProductTag { ProductId = 2, TagId = 4, CreatedAt = DateTime.UtcNow }, // Headphones - Popular
            new ProductTag { ProductId = 3, TagId = 2, CreatedAt = DateTime.UtcNow }, // T-Shirt - Sale
            new ProductTag { ProductId = 3, TagId = 5, CreatedAt = DateTime.UtcNow }, // T-Shirt - Eco-Friendly
            new ProductTag { ProductId = 4, TagId = 1, CreatedAt = DateTime.UtcNow }, // Book - Featured
            new ProductTag { ProductId = 5, TagId = 5, CreatedAt = DateTime.UtcNow }  // Garden Tools - Eco-Friendly
        );
    }
}
