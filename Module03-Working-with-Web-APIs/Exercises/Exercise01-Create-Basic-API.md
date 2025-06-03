# Exercise 1: Create a Basic RESTful API

## 🎯 Objective
Build a complete RESTful API for managing a library system with books, authors, and categories, implementing proper HTTP methods and status codes.

## ⏱️ Estimated Time
45 minutes

## 📋 Prerequisites
- Completed Module 1
- .NET 8.0 SDK installed
- Understanding of HTTP methods
- Basic knowledge of REST principles

## 📝 Instructions

### Part 1: Create the API Project (10 minutes)

1. **Create a new Web API project**:
   ```bash
  - Updated dotnet new command
  - Updated dotnet new command with existing flags
dotnet new   --framework net8.0
   cd LibraryAPI
   ```

2. **Add required packages**:
   ```bash
   dotnet add package Microsoft.EntityFrameworkCore.InMemory
   dotnet add package Swashbuckle.AspNetCore
   ```

3. **Create the domain models** in `Models/`:

   **Book.cs**:
   ```csharp
   namespace LibraryAPI.Models
   {
       public class Book
       {
           public int Id { get; set; }
           public string Title { get; set; } = string.Empty;
           public string ISBN { get; set; } = string.Empty;
           public int PublicationYear { get; set; }
           public int NumberOfPages { get; set; }
           public string Summary { get; set; } = string.Empty;
           
           // Navigation properties
           public int AuthorId { get; set; }
           public Author? Author { get; set; }
           
           public int CategoryId { get; set; }
           public Category? Category { get; set; }
           
           public DateTime CreatedAt { get; set; }
           public DateTime? UpdatedAt { get; set; }
       }
   }
   ```

   **Author.cs**:
   ```csharp
   namespace LibraryAPI.Models
   {
       public class Author
       {
           public int Id { get; set; }
           public string FirstName { get; set; } = string.Empty;
           public string LastName { get; set; } = string.Empty;
           public string Biography { get; set; } = string.Empty;
           public DateTime DateOfBirth { get; set; }
           
           // Navigation property
           public List<Book> Books { get; set; } = new();
       }
   }
   ```

   **Category.cs**:
   ```csharp
   namespace LibraryAPI.Models
   {
       public class Category
       {
           public int Id { get; set; }
           public string Name { get; set; } = string.Empty;
           public string Description { get; set; } = string.Empty;
           
           // Navigation property
           public List<Book> Books { get; set; } = new();
       }
   }
   ```

### Part 2: Create DTOs (10 minutes)

1. **Create a `DTOs` folder** and add the following:

   **BookDtos.cs**:
   ```csharp
   using System.ComponentModel.DataAnnotations;

   namespace LibraryAPI.DTOs
   {
       public record BookDto(
           int Id,
           string Title,
           string ISBN,
           int PublicationYear,
           int NumberOfPages,
           string Summary,
           string AuthorName,
           string CategoryName,
           DateTime CreatedAt,
           DateTime? UpdatedAt
       );

       public record CreateBookDto(
           [Required] [StringLength(200, MinimumLength = 1)] string Title,
           [Required] [RegularExpression(@"^\d{3}-\d{10}$", ErrorMessage = "ISBN must be in format XXX-XXXXXXXXXX")] string ISBN,
           [Range(1450, 2100, ErrorMessage = "Publication year must be between 1450 and current year + 5")] int PublicationYear,
           [Range(1, 10000, ErrorMessage = "Number of pages must be between 1 and 10000")] int NumberOfPages,
           [StringLength(2000)] string Summary,
           [Required] int AuthorId,
           [Required] int CategoryId
       );

       public record UpdateBookDto(
           [Required] [StringLength(200, MinimumLength = 1)] string Title,
           [Required] [RegularExpression(@"^\d{3}-\d{10}$")] string ISBN,
           [Range(1450, 2100)] int PublicationYear,
           [Range(1, 10000)] int NumberOfPages,
           [StringLength(2000)] string Summary,
           [Required] int AuthorId,
           [Required] int CategoryId
       );
   }
   ```

   **AuthorDtos.cs**:
   ```csharp
   using System.ComponentModel.DataAnnotations;

   namespace LibraryAPI.DTOs
   {
       public record AuthorDto(
           int Id,
           string FirstName,
           string LastName,
           string Biography,
           DateTime DateOfBirth,
           int BookCount
       );

       public record CreateAuthorDto(
           [Required] [StringLength(100, MinimumLength = 1)] string FirstName,
           [Required] [StringLength(100, MinimumLength = 1)] string LastName,
           [StringLength(2000)] string Biography,
           [Required] DateTime DateOfBirth
       )
       {
           public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
           {
               if (DateOfBirth > DateTime.Now)
               {
                   yield return new ValidationResult(
                       "Date of birth cannot be in the future",
                       new[] { nameof(DateOfBirth) }
                   );
               }
           }
       }
   }
   ```

### Part 3: Create the Data Context (5 minutes)

**Data/LibraryContext.cs**:
```csharp
using Microsoft.EntityFrameworkCore;
using LibraryAPI.Models;

namespace LibraryAPI.Data
{
    public class LibraryContext : DbContext
    {
        public LibraryContext(DbContextOptions<LibraryContext> options)
            : base(options)
        {
        }

        public DbSet<Book> Books => Set<Book>();
        public DbSet<Author> Authors => Set<Author>();
        public DbSet<Category> Categories => Set<Category>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Configure Book entity
            modelBuilder.Entity<Book>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Title).IsRequired().HasMaxLength(200);
                entity.Property(e => e.ISBN).IsRequired().HasMaxLength(14);
                entity.HasIndex(e => e.ISBN).IsUnique();
                
                entity.HasOne(e => e.Author)
                    .WithMany(a => a.Books)
                    .HasForeignKey(e => e.AuthorId)
                    .OnDelete(DeleteBehavior.Restrict);
                
                entity.HasOne(e => e.Category)
                    .WithMany(c => c.Books)
                    .HasForeignKey(e => e.CategoryId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // Configure Author entity
            modelBuilder.Entity<Author>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.FirstName).IsRequired().HasMaxLength(100);
                entity.Property(e => e.LastName).IsRequired().HasMaxLength(100);
            });

            // Configure Category entity
            modelBuilder.Entity<Category>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
                entity.HasIndex(e => e.Name).IsUnique();
            });

            // Seed data
            modelBuilder.Entity<Category>().HasData(
                new Category { Id = 1, Name = "Fiction", Description = "Fictional works" },
                new Category { Id = 2, Name = "Non-Fiction", Description = "Non-fictional works" },
                new Category { Id = 3, Name = "Science", Description = "Scientific literature" }
            );

            modelBuilder.Entity<Author>().HasData(
                new Author 
                { 
                    Id = 1, 
                    FirstName = "Jane", 
                    LastName = "Austen", 
                    Biography = "English novelist", 
                    DateOfBirth = new DateTime(1775, 12, 16) 
                },
                new Author 
                { 
                    Id = 2, 
                    FirstName = "Mark", 
                    LastName = "Twain", 
                    Biography = "American writer", 
                    DateOfBirth = new DateTime(1835, 11, 30) 
                }
            );
        }
    }
}
```

### Part 4: Create the Books Controller (15 minutes)

**Controllers/BooksController.cs**:
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using LibraryAPI.Data;
using LibraryAPI.DTOs;
using LibraryAPI.Models;

namespace LibraryAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class BooksController : ControllerBase
    {
        private readonly LibraryContext _context;
        private readonly ILogger<BooksController> _logger;

        public BooksController(LibraryContext context, ILogger<BooksController> logger)
        {
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// Get all books with optional filtering
        /// </summary>
        /// <param name="category">Filter by category name</param>
        /// <param name="author">Filter by author last name</param>
        /// <param name="year">Filter by publication year</param>
        /// <returns>List of books</returns>
        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<BookDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<BookDto>>> GetBooks(
            [FromQuery] string? category = null,
            [FromQuery] string? author = null,
            [FromQuery] int? year = null)
        {
            _logger.LogInformation("Getting books with filters - Category: {Category}, Author: {Author}, Year: {Year}", 
                category, author, year);

            var query = _context.Books
                .Include(b => b.Author)
                .Include(b => b.Category)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(category))
            {
                query = query.Where(b => b.Category.Name.Contains(category));
            }

            if (!string.IsNullOrWhiteSpace(author))
            {
                query = query.Where(b => b.Author.LastName.Contains(author));
            }

            if (year.HasValue)
            {
                query = query.Where(b => b.PublicationYear == year.Value);
            }

            var books = await query
                .Select(b => new BookDto(
                    b.Id,
                    b.Title,
                    b.ISBN,
                    b.PublicationYear,
                    b.NumberOfPages,
                    b.Summary,
                    $"{b.Author.FirstName} {b.Author.LastName}",
                    b.Category.Name,
                    b.CreatedAt,
                    b.UpdatedAt
                ))
                .ToListAsync();

            return Ok(books);
        }

        /// <summary>
        /// Get a specific book by ID
        /// </summary>
        /// <param name="id">Book ID</param>
        /// <returns>Book details</returns>
        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(BookDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<BookDto>> GetBook(int id)
        {
            _logger.LogInformation("Getting book with ID: {BookId}", id);

            var book = await _context.Books
                .Include(b => b.Author)
                .Include(b => b.Category)
                .Where(b => b.Id == id)
                .Select(b => new BookDto(
                    b.Id,
                    b.Title,
                    b.ISBN,
                    b.PublicationYear,
                    b.NumberOfPages,
                    b.Summary,
                    $"{b.Author.FirstName} {b.Author.LastName}",
                    b.Category.Name,
                    b.CreatedAt,
                    b.UpdatedAt
                ))
                .FirstOrDefaultAsync();

            if (book == null)
            {
                _logger.LogWarning("Book with ID {BookId} not found", id);
                return NotFound(new { message = $"Book with ID {id} not found" });
            }

            return Ok(book);
        }

        /// <summary>
        /// Create a new book
        /// </summary>
        /// <param name="createBookDto">Book creation data</param>
        /// <returns>Created book</returns>
        [HttpPost]
        [ProducesResponseType(typeof(BookDto), StatusCodes.Status201Created)]
        [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<BookDto>> CreateBook([FromBody] CreateBookDto createBookDto)
        {
            _logger.LogInformation("Creating new book: {BookTitle}", createBookDto.Title);

            // Validate author exists
            var authorExists = await _context.Authors.AnyAsync(a => a.Id == createBookDto.AuthorId);
            if (!authorExists)
            {
                return BadRequest(new { message = $"Author with ID {createBookDto.AuthorId} not found" });
            }

            // Validate category exists
            var categoryExists = await _context.Categories.AnyAsync(c => c.Id == createBookDto.CategoryId);
            if (!categoryExists)
            {
                return BadRequest(new { message = $"Category with ID {createBookDto.CategoryId} not found" });
            }

            // Check for duplicate ISBN
            var isbnExists = await _context.Books.AnyAsync(b => b.ISBN == createBookDto.ISBN);
            if (isbnExists)
            {
                return BadRequest(new { message = $"Book with ISBN {createBookDto.ISBN} already exists" });
            }

            var book = new Book
            {
                Title = createBookDto.Title,
                ISBN = createBookDto.ISBN,
                PublicationYear = createBookDto.PublicationYear,
                NumberOfPages = createBookDto.NumberOfPages,
                Summary = createBookDto.Summary,
                AuthorId = createBookDto.AuthorId,
                CategoryId = createBookDto.CategoryId,
                CreatedAt = DateTime.UtcNow
            };

            _context.Books.Add(book);
            await _context.SaveChangesAsync();

            // Load related data for response
            await _context.Entry(book)
                .Reference(b => b.Author)
                .LoadAsync();
            await _context.Entry(book)
                .Reference(b => b.Category)
                .LoadAsync();

            var bookDto = new BookDto(
                book.Id,
                book.Title,
                book.ISBN,
                book.PublicationYear,
                book.NumberOfPages,
                book.Summary,
                $"{book.Author.FirstName} {book.Author.LastName}",
                book.Category.Name,
                book.CreatedAt,
                book.UpdatedAt
            );

            return CreatedAtAction(
                nameof(GetBook),
                new { id = book.Id },
                bookDto);
        }

        /// <summary>
        /// Update an existing book
        /// </summary>
        /// <param name="id">Book ID</param>
        /// <param name="updateBookDto">Updated book data</param>
        /// <returns>No content</returns>
        [HttpPut("{id:int}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> UpdateBook(int id, [FromBody] UpdateBookDto updateBookDto)
        {
            _logger.LogInformation("Updating book with ID: {BookId}", id);

            var book = await _context.Books.FindAsync(id);
            if (book == null)
            {
                return NotFound(new { message = $"Book with ID {id} not found" });
            }

            // Validate author exists
            if (book.AuthorId != updateBookDto.AuthorId)
            {
                var authorExists = await _context.Authors.AnyAsync(a => a.Id == updateBookDto.AuthorId);
                if (!authorExists)
                {
                    return BadRequest(new { message = $"Author with ID {updateBookDto.AuthorId} not found" });
                }
            }

            // Validate category exists
            if (book.CategoryId != updateBookDto.CategoryId)
            {
                var categoryExists = await _context.Categories.AnyAsync(c => c.Id == updateBookDto.CategoryId);
                if (!categoryExists)
                {
                    return BadRequest(new { message = $"Category with ID {updateBookDto.CategoryId} not found" });
                }
            }

            // Check for duplicate ISBN (if changed)
            if (book.ISBN != updateBookDto.ISBN)
            {
                var isbnExists = await _context.Books.AnyAsync(b => b.ISBN == updateBookDto.ISBN && b.Id != id);
                if (isbnExists)
                {
                    return BadRequest(new { message = $"Book with ISBN {updateBookDto.ISBN} already exists" });
                }
            }

            book.Title = updateBookDto.Title;
            book.ISBN = updateBookDto.ISBN;
            book.PublicationYear = updateBookDto.PublicationYear;
            book.NumberOfPages = updateBookDto.NumberOfPages;
            book.Summary = updateBookDto.Summary;
            book.AuthorId = updateBookDto.AuthorId;
            book.CategoryId = updateBookDto.CategoryId;
            book.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return NoContent();
        }

        /// <summary>
        /// Delete a book
        /// </summary>
        /// <param name="id">Book ID</param>
        /// <returns>No content</returns>
        [HttpDelete("{id:int}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteBook(int id)
        {
            _logger.LogInformation("Deleting book with ID: {BookId}", id);

            var book = await _context.Books.FindAsync(id);
            if (book == null)
            {
                return NotFound(new { message = $"Book with ID {id} not found" });
            }

            _context.Books.Remove(book);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        /// <summary>
        /// Get books by author
        /// </summary>
        /// <param name="authorId">Author ID</param>
        /// <returns>List of books by the author</returns>
        [HttpGet("by-author/{authorId:int}")]
        [ProducesResponseType(typeof(IEnumerable<BookDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<BookDto>>> GetBooksByAuthor(int authorId)
        {
            var books = await _context.Books
                .Include(b => b.Author)
                .Include(b => b.Category)
                .Where(b => b.AuthorId == authorId)
                .Select(b => new BookDto(
                    b.Id,
                    b.Title,
                    b.ISBN,
                    b.PublicationYear,
                    b.NumberOfPages,
                    b.Summary,
                    $"{b.Author.FirstName} {b.Author.LastName}",
                    b.Category.Name,
                    b.CreatedAt,
                    b.UpdatedAt
                ))
                .ToListAsync();

            return Ok(books);
        }
    }
}
```

### Part 5: Configure the Application (5 minutes)

Update **Program.cs**:
```csharp
using LibraryAPI.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using System.Reflection;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Library API",
        Version = "v1",
        Description = "A simple API for managing a library system",
        Contact = new OpenApiContact
        {
            Name = "Library Support",
            Email = "support@library.com"
        }
    });

    // Include XML comments
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
    {
        c.IncludeXmlComments(xmlPath);
    }
});

// Add Entity Framework
builder.Services.AddDbContext<LibraryContext>(options =>
    options.UseInMemoryDatabase("LibraryDb"));

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// Seed the database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<LibraryContext>();
    context.Database.EnsureCreated();
}

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Library API V1");
    });
}

app.UseHttpsRedirection();
app.UseCors();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

### Part 6: Test Your API (5 minutes)

1. **Enable XML documentation** in your `.csproj`:
   ```xml
   <PropertyGroup>
     <GenerateDocumentationFile>true</GenerateDocumentationFile>
     <NoWarn>$(NoWarn);1591</NoWarn>
   </PropertyGroup>
   ```

2. **Run the application**:
   ```bash
   dotnet run
   ```

3. **Test with Swagger UI**:
   - Navigate to `https://localhost:[port]/swagger`
   - Test each endpoint:
     - GET `/api/books` - Get all books
     - GET `/api/books/1` - Get specific book
     - POST `/api/books` - Create new book
     - PUT `/api/books/1` - Update book
     - DELETE `/api/books/1` - Delete book

4. **Test with curl or Postman**:
   ```bash
   # Get all books
   curl -X GET https://localhost:5001/api/books

   # Create a new book
   curl -X POST https://localhost:5001/api/books \
     -H "Content-Type: application/json" \
     -d '{
       "title": "Pride and Prejudice",
       "isbn": "978-0141439518",
       "publicationYear": 1813,
       "numberOfPages": 432,
       "summary": "A classic novel",
       "authorId": 1,
       "categoryId": 1
     }'
   ```

## ✅ Success Criteria

- [ ] API project created and running
- [ ] All CRUD operations working for books
- [ ] Proper HTTP status codes returned
- [ ] Input validation working
- [ ] Swagger documentation available
- [ ] Relationships between entities working
- [ ] Error responses are meaningful

## 🚀 Bonus Challenges

1. **Add Authors Controller**:
   - Create full CRUD operations for authors
   - Include a count of books per author
   - Prevent deleting authors with books

2. **Add Categories Controller**:
   - Create CRUD operations for categories
   - Add endpoint to get books by category
   - Implement category statistics

3. **Add Pagination**:
   - Implement pagination for book list
   - Add sorting options (by title, year, author)
   - Return pagination metadata in headers

4. **Add Search Functionality**:
   - Create a search endpoint
   - Search across title, author, and ISBN
   - Implement fuzzy search

## 🤔 Reflection Questions

1. Why do we use DTOs instead of exposing entity models directly?
2. What's the purpose of the `[ApiController]` attribute?
3. How does content negotiation work in ASP.NET Core?
4. What are the benefits of using async/await in API controllers?

## 🆘 Troubleshooting

**Issue**: Swagger UI not showing
**Solution**: Ensure you're running in Development mode and accessing the correct URL.

**Issue**: 404 errors on API calls
**Solution**: Check the route attributes and ensure the URL matches the controller and action routes.

**Issue**: Validation not working
**Solution**: Ensure `[ApiController]` attribute is present and model state is valid.

---

