using EFCoreDemo.Models;
using Microsoft.EntityFrameworkCore;

namespace EFCoreDemo.Data;

/// <summary>
/// Database context for the Product Catalog system
/// </summary>
public class ProductCatalogContext : DbContext
{
    public ProductCatalogContext(DbContextOptions<ProductCatalogContext> options) : base(options)
    {
    }

    // DbSets
    public DbSet<Product> Products { get; set; } = null!;
    public DbSet<Category> Categories { get; set; } = null!;
    public DbSet<ProductCategory> ProductCategories { get; set; } = null!;
    public DbSet<Supplier> Suppliers { get; set; } = null!;
    public DbSet<ProductSupplier> ProductSuppliers { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure Product entity
        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
            entity.Property(e => e.SKU).IsRequired().HasMaxLength(50);
            entity.Property(e => e.Price).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Description).HasMaxLength(1000);
            entity.Property(e => e.ImageUrl).HasMaxLength(500);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            
            // Index for better query performance
            entity.HasIndex(e => e.SKU).IsUnique();
            entity.HasIndex(e => e.Name);
            entity.HasIndex(e => e.IsActive);
        });

        // Configure Category entity
        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.Slug).HasMaxLength(100);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            
            // Index for better query performance
            entity.HasIndex(e => e.Name);
            entity.HasIndex(e => e.Slug).IsUnique();
            entity.HasIndex(e => e.IsActive);
        });

        // Configure ProductCategory many-to-many relationship
        modelBuilder.Entity<ProductCategory>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.HasOne(e => e.Product)
                .WithMany(e => e.ProductCategories)
                .HasForeignKey(e => e.ProductId)
                .OnDelete(DeleteBehavior.Cascade);
                
            entity.HasOne(e => e.Category)
                .WithMany(e => e.ProductCategories)
                .HasForeignKey(e => e.CategoryId)
                .OnDelete(DeleteBehavior.Cascade);
                
            entity.Property(e => e.AssignedAt).HasDefaultValueSql("GETUTCDATE()");
            
            // Prevent duplicate product-category assignments
            entity.HasIndex(e => new { e.ProductId, e.CategoryId }).IsUnique();
        });

        // Configure Supplier entity
        modelBuilder.Entity<Supplier>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
            entity.Property(e => e.ContactEmail).HasMaxLength(200);
            entity.Property(e => e.Phone).HasMaxLength(20);
            entity.Property(e => e.Address).HasMaxLength(500);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            
            entity.HasIndex(e => e.Name);
            entity.HasIndex(e => e.ContactEmail);
        });

        // Configure ProductSupplier relationship
        modelBuilder.Entity<ProductSupplier>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.HasOne(e => e.Product)
                .WithMany(e => e.ProductSuppliers)
                .HasForeignKey(e => e.ProductId)
                .OnDelete(DeleteBehavior.Cascade);
                
            entity.HasOne(e => e.Supplier)
                .WithMany(e => e.ProductSuppliers)
                .HasForeignKey(e => e.SupplierId)
                .OnDelete(DeleteBehavior.Cascade);
                
            entity.Property(e => e.SupplierPrice).HasColumnType("decimal(18,2)");
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            
            // Ensure unique product-supplier combinations
            entity.HasIndex(e => new { e.ProductId, e.SupplierId }).IsUnique();
        });

        // Seed initial data
        SeedData(modelBuilder);
    }

    private static void SeedData(ModelBuilder modelBuilder)
    {
        // Seed Categories
        modelBuilder.Entity<Category>().HasData(
            new Category { Id = 1, Name = "Electronics", Description = "Electronic devices and gadgets", Slug = "electronics", CreatedAt = DateTime.UtcNow },
            new Category { Id = 2, Name = "Clothing", Description = "Apparel and fashion items", Slug = "clothing", CreatedAt = DateTime.UtcNow },
            new Category { Id = 3, Name = "Books", Description = "Books and publications", Slug = "books", CreatedAt = DateTime.UtcNow },
            new Category { Id = 4, Name = "Home & Garden", Description = "Home improvement and garden supplies", Slug = "home-garden", CreatedAt = DateTime.UtcNow },
            new Category { Id = 5, Name = "Sports", Description = "Sports equipment and accessories", Slug = "sports", CreatedAt = DateTime.UtcNow }
        );

        // Seed Products
        modelBuilder.Entity<Product>().HasData(
            new Product { Id = 1, Name = "Smartphone Pro", Description = "Latest smartphone with advanced features", Price = 999.99m, SKU = "SP-001", StockQuantity = 50, CreatedAt = DateTime.UtcNow },
            new Product { Id = 2, Name = "Laptop Ultra", Description = "High-performance laptop for professionals", Price = 1299.99m, SKU = "LU-002", StockQuantity = 25, CreatedAt = DateTime.UtcNow },
            new Product { Id = 3, Name = "Cotton T-Shirt", Description = "Comfortable cotton t-shirt", Price = 29.99m, SKU = "CT-003", StockQuantity = 100, CreatedAt = DateTime.UtcNow },
            new Product { Id = 4, Name = "Programming Guide", Description = "Comprehensive programming guide", Price = 49.99m, SKU = "PG-004", StockQuantity = 75, CreatedAt = DateTime.UtcNow },
            new Product { Id = 5, Name = "Garden Tools Set", Description = "Complete set of garden tools", Price = 89.99m, SKU = "GT-005", StockQuantity = 30, CreatedAt = DateTime.UtcNow },
            new Product { Id = 6, Name = "Running Shoes", Description = "Professional running shoes", Price = 129.99m, SKU = "RS-006", StockQuantity = 60, CreatedAt = DateTime.UtcNow }
        );

        // Seed ProductCategories
        modelBuilder.Entity<ProductCategory>().HasData(
            new ProductCategory { Id = 1, ProductId = 1, CategoryId = 1, AssignedAt = DateTime.UtcNow }, // Smartphone -> Electronics
            new ProductCategory { Id = 2, ProductId = 2, CategoryId = 1, AssignedAt = DateTime.UtcNow }, // Laptop -> Electronics
            new ProductCategory { Id = 3, ProductId = 3, CategoryId = 2, AssignedAt = DateTime.UtcNow }, // T-Shirt -> Clothing
            new ProductCategory { Id = 4, ProductId = 4, CategoryId = 3, AssignedAt = DateTime.UtcNow }, // Book -> Books
            new ProductCategory { Id = 5, ProductId = 5, CategoryId = 4, AssignedAt = DateTime.UtcNow }, // Garden Tools -> Home & Garden
            new ProductCategory { Id = 6, ProductId = 6, CategoryId = 5, AssignedAt = DateTime.UtcNow }  // Running Shoes -> Sports
        );

        // Seed Suppliers
        modelBuilder.Entity<Supplier>().HasData(
            new Supplier { Id = 1, Name = "Tech Solutions Inc.", ContactEmail = "contact@techsolutions.com", Phone = "+1-555-0101", Address = "123 Tech Street, Silicon Valley, CA", CreatedAt = DateTime.UtcNow },
            new Supplier { Id = 2, Name = "Fashion World Ltd.", ContactEmail = "orders@fashionworld.com", Phone = "+1-555-0102", Address = "456 Fashion Ave, New York, NY", CreatedAt = DateTime.UtcNow },
            new Supplier { Id = 3, Name = "Book Publishers Co.", ContactEmail = "sales@bookpublishers.com", Phone = "+1-555-0103", Address = "789 Book Lane, Boston, MA", CreatedAt = DateTime.UtcNow }
        );
    }
}
