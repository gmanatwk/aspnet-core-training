using Microsoft.EntityFrameworkCore;

namespace DebuggingDemo.Data;

public class DebuggingContext : DbContext
{
    public DebuggingContext(DbContextOptions<DebuggingContext> options) : base(options)
    {
    }

    public DbSet<TestEntity> TestEntities { get; set; }
    public DbSet<LogEntry> LogEntries { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<TestEntity>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.CreatedAt).IsRequired();
        });

        modelBuilder.Entity<LogEntry>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Timestamp).IsRequired();
            entity.Property(e => e.Level).IsRequired().HasMaxLength(50);
            entity.Property(e => e.Message).IsRequired();
            entity.Property(e => e.RequestId).HasMaxLength(100);
            entity.Property(e => e.UserId).HasMaxLength(100);
        });

        base.OnModelCreating(modelBuilder);
    }
}

public class TestEntity
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime CreatedAt { get; set; }
    public bool IsActive { get; set; }
}

public class LogEntry
{
    public int Id { get; set; }
    public DateTime Timestamp { get; set; }
    public string Level { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string? Exception { get; set; }
    public string RequestId { get; set; } = string.Empty;
    public string? UserId { get; set; }
}

public static class DebuggingContextExtensions
{
    public static void SeedData(this DebuggingContext context)
    {
        if (!context.TestEntities.Any())
        {
            var testEntities = new List<TestEntity>
            {
                new TestEntity { Name = "Test Entity 1", Description = "First test entity", CreatedAt = DateTime.UtcNow, IsActive = true },
                new TestEntity { Name = "Test Entity 2", Description = "Second test entity", CreatedAt = DateTime.UtcNow.AddMinutes(-10), IsActive = true },
                new TestEntity { Name = "Test Entity 3", Description = "Third test entity", CreatedAt = DateTime.UtcNow.AddMinutes(-20), IsActive = false },
                new TestEntity { Name = "Test Entity 4", Description = "Fourth test entity", CreatedAt = DateTime.UtcNow.AddMinutes(-30), IsActive = true },
                new TestEntity { Name = "Test Entity 5", Description = "Fifth test entity", CreatedAt = DateTime.UtcNow.AddMinutes(-40), IsActive = true }
            };

            context.TestEntities.AddRange(testEntities);
            context.SaveChanges();
        }
    }
}
