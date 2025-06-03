using Microsoft.EntityFrameworkCore;
using CustomerService.Models;

namespace CustomerService.Data;

public class CustomerDbContext : DbContext
{
    public CustomerDbContext(DbContextOptions<CustomerDbContext> options)
        : base(options)
    {
    }

    public DbSet<Customer> Customers { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure Customer entity
        modelBuilder.Entity<Customer>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.FirstName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.LastName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Email).IsRequired().HasMaxLength(255);
            entity.HasIndex(e => e.Email).IsUnique();
            entity.HasIndex(e => new { e.FirstName, e.LastName });
        });

        // Seed initial data
        modelBuilder.Entity<Customer>().HasData(
            new Customer
            {
                Id = 1,
                FirstName = "John",
                LastName = "Doe",
                Email = "john.doe@example.com",
                Phone = "+1-555-1234",
                Address = "123 Main St",
                City = "New York",
                Country = "USA",
                PostalCode = "10001",
                CreatedAt = DateTime.UtcNow
            },
            new Customer
            {
                Id = 2,
                FirstName = "Jane",
                LastName = "Smith",
                Email = "jane.smith@example.com",
                Phone = "+1-555-5678",
                Address = "456 Oak Ave",
                City = "Los Angeles",
                Country = "USA",
                PostalCode = "90001",
                CreatedAt = DateTime.UtcNow
            },
            new Customer
            {
                Id = 3,
                FirstName = "Robert",
                LastName = "Johnson",
                Email = "robert.johnson@example.com",
                Phone = "+44-20-1234-5678",
                Address = "789 Park Lane",
                City = "London",
                Country = "UK",
                PostalCode = "SW1A 1AA",
                CreatedAt = DateTime.UtcNow
            },
            new Customer
            {
                Id = 4,
                FirstName = "Maria",
                LastName = "Garcia",
                Email = "maria.garcia@example.com",
                Phone = "+34-91-123-4567",
                Address = "321 Plaza Mayor",
                City = "Madrid",
                Country = "Spain",
                PostalCode = "28001",
                CreatedAt = DateTime.UtcNow
            },
            new Customer
            {
                Id = 5,
                FirstName = "Chen",
                LastName = "Wei",
                Email = "chen.wei@example.com",
                Phone = "+86-10-1234-5678",
                Address = "555 Beijing Road",
                City = "Beijing",
                Country = "China",
                PostalCode = "100000",
                CreatedAt = DateTime.UtcNow
            }
        );
    }
}