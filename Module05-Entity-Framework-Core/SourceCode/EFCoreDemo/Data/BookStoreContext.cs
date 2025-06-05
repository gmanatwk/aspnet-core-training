using EFCoreDemo.Models;
using Microsoft.EntityFrameworkCore;

namespace EFCoreDemo.Data;

/// <summary>
/// BookStore database context from Exercise 01
/// </summary>
public class BookStoreContext : DbContext
{
    public BookStoreContext(DbContextOptions<BookStoreContext> options) : base(options)
    {
    }

    // DbSets
    public DbSet<Book> Books { get; set; } = null!;
    public DbSet<Author> Authors { get; set; } = null!;
    public DbSet<Publisher> Publishers { get; set; } = null!;
    public DbSet<BookAuthor> BookAuthors { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure Book entity
        modelBuilder.Entity<Book>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Title).IsRequired().HasMaxLength(200);
            entity.Property(e => e.ISBN).IsRequired().HasMaxLength(20);
            entity.Property(e => e.Price).HasColumnType("decimal(18,2)");
            
            // Unique constraint on ISBN
            entity.HasIndex(e => e.ISBN).IsUnique();
            
            // Configure relationship with Publisher
            entity.HasOne(e => e.Publisher)
                  .WithMany(p => p.Books)
                  .HasForeignKey(e => e.PublisherId)
                  .OnDelete(DeleteBehavior.SetNull);
        });

        // Configure Author entity
        modelBuilder.Entity<Author>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.FirstName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.LastName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Email).IsRequired().HasMaxLength(200);
            
            // Unique constraint on Email
            entity.HasIndex(e => e.Email).IsUnique();
        });

        // Configure Publisher entity
        modelBuilder.Entity<Publisher>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Address).HasMaxLength(500);
            entity.Property(e => e.Website).HasMaxLength(200);
        });

        // Configure BookAuthor many-to-many relationship
        modelBuilder.Entity<BookAuthor>(entity =>
        {
            entity.HasKey(ba => new { ba.BookId, ba.AuthorId });
            
            entity.HasOne(ba => ba.Book)
                  .WithMany(b => b.BookAuthors)
                  .HasForeignKey(ba => ba.BookId);
                  
            entity.HasOne(ba => ba.Author)
                  .WithMany(a => a.BookAuthors)
                  .HasForeignKey(ba => ba.AuthorId);
                  
            entity.Property(ba => ba.Role).HasMaxLength(50);
        });

        // Seed data
        SeedData(modelBuilder);
    }

    private static void SeedData(ModelBuilder modelBuilder)
    {
        // Seed Publishers
        modelBuilder.Entity<Publisher>().HasData(
            new Publisher { Id = 1, Name = "Tech Publications", Address = "123 Tech Street", Website = "www.techpub.com", FoundedYear = 1995 },
            new Publisher { Id = 2, Name = "Literary Press", Address = "456 Book Lane", Website = "www.litpress.com", FoundedYear = 1980 },
            new Publisher { Id = 3, Name = "Academic Publishing", Address = "789 University Ave", Website = "www.academic.com", FoundedYear = 1970 }
        );

        // Seed Authors
        modelBuilder.Entity<Author>().HasData(
            new Author { Id = 1, FirstName = "John", LastName = "Doe", Email = "john.doe@email.com", BirthDate = new DateTime(1975, 5, 15), Country = "USA" },
            new Author { Id = 2, FirstName = "Jane", LastName = "Smith", Email = "jane.smith@email.com", BirthDate = new DateTime(1980, 8, 20), Country = "UK" },
            new Author { Id = 3, FirstName = "Robert", LastName = "Johnson", Email = "robert.j@email.com", BirthDate = new DateTime(1970, 3, 10), Country = "Canada" }
        );

        // Seed Books
        modelBuilder.Entity<Book>().HasData(
            new Book 
            { 
                Id = 1, 
                Title = "C# Programming Guide", 
                ISBN = "978-1234567890", 
                Price = 29.99m, 
                PublishedDate = new DateTime(2024, 1, 15), 
                PublisherId = 1,
                IsAvailable = true
            },
            new Book 
            { 
                Id = 2, 
                Title = "ASP.NET Core in Action", 
                ISBN = "978-0987654321", 
                Price = 39.99m, 
                PublishedDate = new DateTime(2024, 2, 20), 
                PublisherId = 1,
                IsAvailable = true
            },
            new Book 
            { 
                Id = 3, 
                Title = "Entity Framework Core Best Practices", 
                ISBN = "978-1111222333", 
                Price = 49.99m, 
                PublishedDate = new DateTime(2024, 3, 10), 
                PublisherId = 1,
                IsAvailable = true
            }
        );

        // Seed BookAuthor relationships
        modelBuilder.Entity<BookAuthor>().HasData(
            new BookAuthor { BookId = 1, AuthorId = 1, Role = "Primary Author" },
            new BookAuthor { BookId = 2, AuthorId = 2, Role = "Primary Author" },
            new BookAuthor { BookId = 2, AuthorId = 1, Role = "Co-Author" },
            new BookAuthor { BookId = 3, AuthorId = 3, Role = "Primary Author" }
        );
    }
}