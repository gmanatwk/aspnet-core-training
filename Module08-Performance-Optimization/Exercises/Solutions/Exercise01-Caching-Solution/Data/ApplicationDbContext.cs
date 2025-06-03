using CachingDemo.Models;
using Microsoft.EntityFrameworkCore;

namespace CachingDemo.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }
    
    public DbSet<Product> Products { get; set; } = null!;
    public DbSet<Category> Categories { get; set; } = null!;
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // Configure Product
        modelBuilder.Entity<Product>()
            .HasIndex(p => p.SKU)
            .IsUnique();
            
        modelBuilder.Entity<Product>()
            .HasOne(p => p.Category)
            .WithMany(c => c.Products)
            .HasForeignKey(p => p.CategoryId);
            
        // Add indexes for better performance
        modelBuilder.Entity<Product>()
            .HasIndex(p => p.CategoryId);
            
        modelBuilder.Entity<Product>()
            .HasIndex(p => p.IsActive);
            
        modelBuilder.Entity<Product>()
            .HasIndex(p => new { p.CategoryId, p.IsActive });
    }
}
