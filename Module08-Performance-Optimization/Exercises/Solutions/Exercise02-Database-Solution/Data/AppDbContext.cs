using DatabaseOptimization.Models;
using Microsoft.EntityFrameworkCore;

namespace DatabaseOptimization.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }
    
    public DbSet<Product> Products { get; set; } = null!;
    public DbSet<Category> Categories { get; set; } = null!;
    public DbSet<Tag> Tags { get; set; } = null!;
    public DbSet<ProductTag> ProductTags { get; set; } = null!;
    public DbSet<Order> Orders { get; set; } = null!;
    public DbSet<OrderItem> OrderItems { get; set; } = null!;
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // Configure ProductTag as a many-to-many relationship
        modelBuilder.Entity<ProductTag>()
            .HasKey(pt => new { pt.ProductId, pt.TagId });
            
        modelBuilder.Entity<ProductTag>()
            .HasOne(pt => pt.Product)
            .WithMany(p => p.ProductTags)
            .HasForeignKey(pt => pt.ProductId);
            
        modelBuilder.Entity<ProductTag>()
            .HasOne(pt => pt.Tag)
            .WithMany(t => t.ProductTags)
            .HasForeignKey(pt => pt.TagId);
            
        // Configure Product
        modelBuilder.Entity<Product>()
            .HasOne(p => p.Category)
            .WithMany(c => c.Products)
            .HasForeignKey(p => p.CategoryId);
            
        // Configure OrderItem
        modelBuilder.Entity<OrderItem>()
            .HasOne(oi => oi.Order)
            .WithMany(o => o.OrderItems)
            .HasForeignKey(oi => oi.OrderId);
            
        modelBuilder.Entity<OrderItem>()
            .HasOne(oi => oi.Product)
            .WithMany(p => p.OrderItems)
            .HasForeignKey(oi => oi.ProductId);
            
        // Add indexes for better performance
        modelBuilder.Entity<Product>()
            .HasIndex(p => p.CategoryId)
            .HasDatabaseName("IX_Product_CategoryId");
            
        modelBuilder.Entity<Product>()
            .HasIndex(p => p.IsActive)
            .HasDatabaseName("IX_Product_IsActive");
            
        modelBuilder.Entity<Product>()
            .HasIndex(p => new { p.CategoryId, p.IsActive })
            .HasDatabaseName("IX_Product_Category_Active");
            
        modelBuilder.Entity<Product>()
            .HasIndex(p => p.Price)
            .HasDatabaseName("IX_Product_Price");
            
        modelBuilder.Entity<Order>()
            .HasIndex(o => o.CustomerEmail)
            .HasDatabaseName("IX_Order_CustomerEmail");
            
        modelBuilder.Entity<Order>()
            .HasIndex(o => o.OrderDate)
            .HasDatabaseName("IX_Order_OrderDate");
            
        // Composite index for efficient queries
        modelBuilder.Entity<OrderItem>()
            .HasIndex(oi => new { oi.ProductId, oi.OrderId })
            .HasDatabaseName("IX_OrderItem_Product_Order");
    }
}
