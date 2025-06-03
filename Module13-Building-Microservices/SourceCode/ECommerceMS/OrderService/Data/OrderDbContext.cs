using Microsoft.EntityFrameworkCore;
using OrderService.Models;
using SharedLibrary.Models;

namespace OrderService.Data;

public class OrderDbContext : DbContext
{
    public OrderDbContext(DbContextOptions<OrderDbContext> options)
        : base(options)
    {
    }

    public DbSet<Order> Orders { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure Order entity
        modelBuilder.Entity<Order>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.OrderNumber).IsRequired().HasMaxLength(50);
            entity.Property(e => e.TotalAmount).HasPrecision(18, 2);
            entity.HasIndex(e => e.OrderNumber).IsUnique();
            entity.HasIndex(e => e.CustomerId);
            entity.HasIndex(e => e.OrderDate);
            entity.HasIndex(e => e.Status);
        });

        // Configure OrderItem entity
        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.ProductName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.UnitPrice).HasPrecision(18, 2);
            entity.Property(e => e.TotalPrice).HasPrecision(18, 2);
            
            entity.HasOne(e => e.Order)
                .WithMany(o => o.Items)
                .HasForeignKey(e => e.OrderId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Seed initial data
        modelBuilder.Entity<Order>().HasData(
            new Order
            {
                Id = 1,
                CustomerId = 1,
                OrderNumber = "ORD-2024-001",
                OrderDate = DateTime.UtcNow.AddDays(-5),
                Status = OrderStatus.Delivered,
                TotalAmount = 1339.98m,
                ShippingAddress = "123 Main St, City, Country",
                CreatedAt = DateTime.UtcNow.AddDays(-5)
            },
            new Order
            {
                Id = 2,
                CustomerId = 2,
                OrderNumber = "ORD-2024-002",
                OrderDate = DateTime.UtcNow.AddDays(-2),
                Status = OrderStatus.Processing,
                TotalAmount = 99.98m,
                ShippingAddress = "456 Oak Ave, Town, Country",
                CreatedAt = DateTime.UtcNow.AddDays(-2)
            }
        );

        modelBuilder.Entity<OrderItem>().HasData(
            new OrderItem
            {
                Id = 1,
                OrderId = 1,
                ProductId = 1,
                ProductName = "Laptop",
                Quantity = 1,
                UnitPrice = 1299.99m,
                TotalPrice = 1299.99m
            },
            new OrderItem
            {
                Id = 2,
                OrderId = 1,
                ProductId = 2,
                ProductName = "Wireless Mouse",
                Quantity = 1,
                UnitPrice = 39.99m,
                TotalPrice = 39.99m
            },
            new OrderItem
            {
                Id = 3,
                OrderId = 2,
                ProductId = 3,
                ProductName = "USB-C Hub",
                Quantity = 1,
                UnitPrice = 59.99m,
                TotalPrice = 59.99m
            },
            new OrderItem
            {
                Id = 4,
                OrderId = 2,
                ProductId = 2,
                ProductName = "Wireless Mouse",
                Quantity = 1,
                UnitPrice = 39.99m,
                TotalPrice = 39.99m
            }
        );
    }
}