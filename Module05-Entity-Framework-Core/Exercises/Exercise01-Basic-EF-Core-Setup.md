# Exercise 1: Basic EF Core Setup and CRUD Operations

## 🎯 Objective
Set up Entity Framework Core in an ASP.NET Core application and implement basic CRUD operations for a simple entity.

## ⏱️ Time Allocation
**Total Time**: 30 minutes
- Setup and Configuration: 10 minutes
- Entity and DbContext Creation: 10 minutes
- CRUD Operations: 10 minutes

## 📋 Requirements

### Part A: Project Setup (10 minutes)
1. Create a new ASP.NET Core Web API project named `BookStoreAPI`
2. Install the following NuGet packages:
   - `Microsoft.EntityFrameworkCore.SqlServer`
   - `Microsoft.EntityFrameworkCore.Tools`
   - `Microsoft.EntityFrameworkCore.Design`
3. Configure connection string in `appsettings.json`

### Part B: Entity and DbContext (10 minutes)
1. Create a `Book` entity with the following properties:
   - `Id` (int, primary key)
   - `Title` (string, required, max 200 characters)
   - `Author` (string, required, max 100 characters)
   - `ISBN` (string, required, max 20 characters, unique)
   - `Price` (decimal)
   - `PublishedDate` (DateTime)
   - `IsAvailable` (bool, default true)

2. Create a `BookStoreContext` that inherits from `DbContext`
3. Configure the entity using Fluent API
4. Add seed data for 3 books

### Part C: CRUD Controller (10 minutes)
1. Create a `BooksController` with the following endpoints:
   - `GET /api/books` - Get all books
   - `GET /api/books/{id}` - Get book by ID
   - `POST /api/books` - Create new book
   - `PUT /api/books/{id}` - Update book
   - `DELETE /api/books/{id}` - Delete book

## 🚀 Getting Started

### Step 1: Create the Book Entity

**Models/BookEntities.cs**:
```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EFCoreDemo.Models;

/// <summary>
/// Book entity for Exercise 01 - Basic EF Core Setup
/// </summary>
public class Book
{
    [Key]
    public int Id { get; set; }

    [Required(ErrorMessage = "Title is required")]
    [StringLength(200, ErrorMessage = "Title cannot exceed 200 characters")]
    public string Title { get; set; } = string.Empty;

    [Required(ErrorMessage = "Author is required")]
    [StringLength(100, ErrorMessage = "Author name cannot exceed 100 characters")]
    public string Author { get; set; } = string.Empty;

    [Required(ErrorMessage = "ISBN is required")]
    [StringLength(20, ErrorMessage = "ISBN cannot exceed 20 characters")]
    public string ISBN { get; set; } = string.Empty;

    [Column(TypeName = "decimal(18,2)")]
    [Range(0.01, 9999.99, ErrorMessage = "Price must be between 0.01 and 9999.99")]
    public decimal Price { get; set; }

    [Required(ErrorMessage = "Published date is required")]
    public DateTime PublishedDate { get; set; }

    public bool IsAvailable { get; set; } = true;

    // Computed property for display
    [NotMapped]
    public string DisplayTitle => $"{Title} by {Author}";
}
```

### Step 2: Create the DbContext

**Data/BookStoreContext.cs**:
```csharp
using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Models;

namespace EFCoreDemo.Data;

public class BookStoreContext : DbContext
{
    public BookStoreContext(DbContextOptions<BookStoreContext> options) : base(options)
    {
    }

    public DbSet<Book> Books { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure Book entity using Fluent API
        modelBuilder.Entity<Book>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.Property(e => e.Title)
                .IsRequired()
                .HasMaxLength(200);

            entity.Property(e => e.Author)
                .IsRequired()
                .HasMaxLength(100);

            entity.Property(e => e.ISBN)
                .IsRequired()
                .HasMaxLength(20);

            entity.HasIndex(e => e.ISBN)
                .IsUnique()
                .HasDatabaseName("IX_Books_ISBN");

            entity.Property(e => e.Price)
                .HasColumnType("decimal(18,2)")
                .IsRequired();

            entity.Property(e => e.PublishedDate)
                .IsRequired();

            entity.Property(e => e.IsAvailable)
                .HasDefaultValue(true);
        });

        // Seed data for Exercise 01
        SeedData(modelBuilder);
    }

    private void SeedData(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Book>().HasData(
            new Book
            {
                Id = 1,
                Title = "C# Programming Guide",
                Author = "John Smith",
                ISBN = "978-1234567890",
                Price = 29.99m,
                PublishedDate = new DateTime(2023, 1, 15),
                IsAvailable = true
            },
            new Book
            {
                Id = 2,
                Title = "ASP.NET Core in Action",
                Author = "Jane Doe",
                ISBN = "978-0987654321",
                Price = 39.99m,
                PublishedDate = new DateTime(2023, 3, 20),
                IsAvailable = true
            },
            new Book
            {
                Id = 3,
                Title = "Entity Framework Core Deep Dive",
                Author = "Bob Johnson",
                ISBN = "978-1122334455",
                Price = 45.99m,
                PublishedDate = new DateTime(2023, 6, 10),
                IsAvailable = false
            }
        );
    }
}
```

### Step 3: Configure Services in Program.cs

**Program.cs**:
```csharp
using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add Entity Framework
builder.Services.AddDbContext<BookStoreContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

// Ensure database is created and seeded
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<BookStoreContext>();
    context.Database.EnsureCreated();
}

app.Run();
```

### Step 4: Create the BooksController

**Controllers/BooksController.cs**:
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Data;
using EFCoreDemo.Models;

namespace EFCoreDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BooksController : ControllerBase
{
    private readonly BookStoreContext _context;
    private readonly ILogger<BooksController> _logger;

    public BooksController(BookStoreContext context, ILogger<BooksController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Get all books
    /// </summary>
    /// <returns>List of all books</returns>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Book>>> GetBooks()
    {
        try
        {
            _logger.LogInformation("Retrieving all books");
            var books = await _context.Books
                .Where(b => b.IsAvailable)
                .OrderBy(b => b.Title)
                .ToListAsync();

            return Ok(books);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving books");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get book by ID
    /// </summary>
    /// <param name="id">Book ID</param>
    /// <returns>Book details</returns>
    [HttpGet("{id}")]
    public async Task<ActionResult<Book>> GetBook(int id)
    {
        try
        {
            _logger.LogInformation("Retrieving book with ID: {BookId}", id);
            var book = await _context.Books.FindAsync(id);

            if (book == null)
            {
                _logger.LogWarning("Book with ID {BookId} not found", id);
                return NotFound($"Book with ID {id} not found");
            }

            return Ok(book);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving book {BookId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Create a new book
    /// </summary>
    /// <param name="book">Book to create</param>
    /// <returns>Created book</returns>
    [HttpPost]
    public async Task<ActionResult<Book>> CreateBook(Book book)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Check if ISBN already exists
            var existingBook = await _context.Books
                .FirstOrDefaultAsync(b => b.ISBN == book.ISBN);

            if (existingBook != null)
            {
                return Conflict($"Book with ISBN '{book.ISBN}' already exists");
            }

            _logger.LogInformation("Creating new book: {BookTitle}", book.Title);

            _context.Books.Add(book);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetBook), new { id = book.Id }, book);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating book");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Update an existing book
    /// </summary>
    /// <param name="id">Book ID</param>
    /// <param name="book">Updated book data</param>
    /// <returns>Updated book</returns>
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateBook(int id, Book book)
    {
        try
        {
            if (id != book.Id)
            {
                return BadRequest("ID mismatch");
            }

            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var existingBook = await _context.Books.FindAsync(id);
            if (existingBook == null)
            {
                return NotFound($"Book with ID {id} not found");
            }

            // Check if ISBN is being changed to an existing one
            if (existingBook.ISBN != book.ISBN)
            {
                var duplicateISBN = await _context.Books
                    .AnyAsync(b => b.ISBN == book.ISBN && b.Id != id);

                if (duplicateISBN)
                {
                    return Conflict($"Book with ISBN '{book.ISBN}' already exists");
                }
            }

            _logger.LogInformation("Updating book with ID: {BookId}", id);

            // Update properties
            existingBook.Title = book.Title;
            existingBook.Author = book.Author;
            existingBook.ISBN = book.ISBN;
            existingBook.Price = book.Price;
            existingBook.PublishedDate = book.PublishedDate;
            existingBook.IsAvailable = book.IsAvailable;

            await _context.SaveChangesAsync();

            return Ok(existingBook);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating book {BookId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Delete a book
    /// </summary>
    /// <param name="id">Book ID</param>
    /// <returns>Success message</returns>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteBook(int id)
    {
        try
        {
            var book = await _context.Books.FindAsync(id);
            if (book == null)
            {
                return NotFound($"Book with ID {id} not found");
            }

            _logger.LogInformation("Deleting book with ID: {BookId}", id);

            _context.Books.Remove(book);
            await _context.SaveChangesAsync();

            return Ok($"Book '{book.Title}' deleted successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting book {BookId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Search books by title or author
    /// </summary>
    /// <param name="searchTerm">Search term</param>
    /// <returns>Matching books</returns>
    [HttpGet("search")]
    public async Task<ActionResult<IEnumerable<Book>>> SearchBooks([FromQuery] string searchTerm)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
            {
                return BadRequest("Search term is required");
            }

            _logger.LogInformation("Searching books with term: {SearchTerm}", searchTerm);

            var books = await _context.Books
                .Where(b => b.IsAvailable &&
                           (b.Title.Contains(searchTerm) || b.Author.Contains(searchTerm)))
                .OrderBy(b => b.Title)
                .ToListAsync();

            return Ok(books);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error searching books");
            return StatusCode(500, "Internal server error");
        }
    }
}
```

## ✅ Success Criteria
- [ ] Entity Framework Core is properly configured
- [ ] Book entity is created with all required properties
- [ ] DbContext is configured with Fluent API
- [ ] Database is created with seed data
- [ ] All CRUD endpoints are working
- [ ] Data validation is implemented
- [ ] Proper error handling is in place

## 🔧 Testing Your Implementation

### Test the API endpoints using Swagger or curl:

1. **Get all books**:
   ```bash
   GET /api/books
   ```

2. **Create a new book**:
   ```bash
   POST /api/books
   Content-Type: application/json
   
   {
     "title": "C# Programming Guide",
     "author": "John Doe",
     "isbn": "978-1234567890",
     "price": 29.99,
     "publishedDate": "2024-01-15"
   }
   ```

3. **Update a book**:
   ```bash
   PUT /api/books/1
   Content-Type: application/json
   
   {
     "title": "Advanced C# Programming",
     "author": "John Doe",
     "isbn": "978-1234567890",
     "price": 39.99,
     "publishedDate": "2024-01-15",
     "isAvailable": true
   }
   ```

4. **Delete a book**:
   ```bash
   DELETE /api/books/1
   ```

## 💡 Bonus Challenges
If you complete the basic requirements early:

1. **Add data validation attributes** to the Book entity
2. **Implement search functionality** - search books by title or author
3. **Add filtering** - filter books by availability or price range
4. **Implement pagination** for the get all books endpoint
5. **Add logging** to track database operations

## 🎯 Learning Outcomes
After completing this exercise, you should understand:
- How to set up Entity Framework Core in ASP.NET Core
- Entity configuration using data annotations and Fluent API
- Creating and configuring DbContext
- Implementing basic CRUD operations
- Database seeding strategies
- Handling database connections and migrations

## ❓ Common Issues and Solutions

### Issue 1: Migration Errors
**Problem**: Entity Framework migrations fail
**Solution**: Ensure connection string is correct and SQL Server is running

### Issue 2: Unique Constraint Violations
**Problem**: ISBN uniqueness constraint violations
**Solution**: Check seed data for duplicate ISBN values

### Issue 3: Null Reference Exceptions
**Problem**: DbSet properties are null
**Solution**: Ensure DbContext is properly registered in DI container

---

**Next**: Proceed to Exercise 2 for advanced querying techniques!
