# Exercise 2: Advanced LINQ Queries and Navigation Properties

## 🎯 Objective
Master advanced LINQ queries with Entity Framework Core, including joins, navigation properties, and complex filtering scenarios.

## ⏱️ Time Allocation
**Total Time**: 25 minutes
- Entity Relationships Setup: 8 minutes
- Basic LINQ Queries: 7 minutes
- Advanced Query Scenarios: 10 minutes

## 📋 Requirements

### Part A: Extend the Data Model (8 minutes)
Extend the BookStore from Exercise 1 with additional entities:

1. **Author Entity**:
   - `Id`, `FirstName`, `LastName`, `Email`, `BirthDate`, `Country`

2. **Publisher Entity**:
   - `Id`, `Name`, `Address`, `Website`, `FoundedYear`

3. **BookAuthor Entity** (Many-to-Many junction):
   - `BookId`, `AuthorId`, `Role` (Primary Author, Co-Author, Editor)

4. **Update Book Entity**:
   - Add `PublisherId` foreign key
   - Remove `Author` string property (replaced by Author relationship)

### Part B: Basic LINQ Queries (7 minutes)
Implement the following query methods in a `BookQueryService`:

1. Get all books with their publishers
2. Get books by a specific author
3. Get authors with their book count
4. Get books published in a specific year
5. Get the most expensive books (top 5)

### Part C: Advanced Query Scenarios (10 minutes)
Implement complex queries:

1. **Multi-table Join**: Get books with author details and publisher info
2. **Aggregation**: Calculate average price by publisher
3. **Filtering with Navigation**: Find authors who have written books above $50
4. **Grouping**: Group books by publication year with count and average price
5. **Search**: Full-text search across book title, author name, and publisher

## 🚀 Implementation Guide

### Step 1: Create Extended Entities

```csharp
// Models/Author.cs
public class Author
{
    public int Id { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public DateTime? BirthDate { get; set; }
    public string Country { get; set; } = string.Empty;
    
    // Navigation properties
    public virtual ICollection<BookAuthor> BookAuthors { get; set; } = new List<BookAuthor>();
    
    // Computed property
    public string FullName => $"{FirstName} {LastName}";
}

// Models/Publisher.cs
public class Publisher
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string Website { get; set; } = string.Empty;
    public int FoundedYear { get; set; }
    
    // Navigation properties
    public virtual ICollection<Book> Books { get; set; } = new List<Book>();
}

// Models/BookAuthor.cs
public class BookAuthor
{
    public int BookId { get; set; }
    public int AuthorId { get; set; }
    public string Role { get; set; } = "Primary Author"; // Primary Author, Co-Author, Editor
    
    // Navigation properties
    public virtual Book Book { get; set; } = null!;
    public virtual Author Author { get; set; } = null!;
}
```

### Step 2: Update Book Entity
```csharp
// Models/Book.cs - Updated
public class Book
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string ISBN { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public DateTime PublishedDate { get; set; }
    public bool IsAvailable { get; set; } = true;
    
    // Foreign Key
    public int PublisherId { get; set; }
    
    // Navigation properties
    public virtual Publisher Publisher { get; set; } = null!;
    public virtual ICollection<BookAuthor> BookAuthors { get; set; } = new List<BookAuthor>();
}
```

### Step 3: Update DbContext Configuration
```csharp
// Data/BookStoreContext.cs - Add to OnModelCreating
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    base.OnModelCreating(modelBuilder);
    
    // Configure Book-Author many-to-many relationship
    modelBuilder.Entity<BookAuthor>(entity =>
    {
        entity.HasKey(ba => new { ba.BookId, ba.AuthorId });
        
        entity.HasOne(ba => ba.Book)
              .WithMany(b => b.BookAuthors)
              .HasForeignKey(ba => ba.BookId);
              
        entity.HasOne(ba => ba.Author)
              .WithMany(a => a.BookAuthors)
              .HasForeignKey(ba => ba.AuthorId);
    });
    
    // Configure Book-Publisher relationship
    modelBuilder.Entity<Book>()
        .HasOne(b => b.Publisher)
        .WithMany(p => p.Books)
        .HasForeignKey(b => b.PublisherId);
    
    // Add indexes for better query performance
    modelBuilder.Entity<Book>()
        .HasIndex(b => b.ISBN)
        .IsUnique();
        
    modelBuilder.Entity<Author>()
        .HasIndex(a => a.Email)
        .IsUnique();
    
    // Seed data (implement your seed data here)
    SeedData(modelBuilder);
}
```

### Step 4: Create BookQueryService
```csharp
// Services/BookQueryService.cs
public class BookQueryService
{
    private readonly BookStoreContext _context;
    
    public BookQueryService(BookStoreContext context)
    {
        _context = context;
    }
    
    // TODO: Implement the following methods
    
    public async Task<IEnumerable<Book>> GetBooksWithPublishersAsync()
    {
        // Your implementation here
    }
    
    public async Task<IEnumerable<Book>> GetBooksByAuthorAsync(int authorId)
    {
        // Your implementation here
    }
    
    public async Task<IEnumerable<object>> GetAuthorsWithBookCountAsync()
    {
        // Your implementation here
        // Return anonymous objects with Author info + BookCount
    }
    
    public async Task<IEnumerable<Book>> GetBooksByYearAsync(int year)
    {
        // Your implementation here
    }
    
    public async Task<IEnumerable<Book>> GetTopExpensiveBooksAsync(int count = 5)
    {
        // Your implementation here
    }
    
    // Advanced queries
    public async Task<IEnumerable<object>> GetBooksWithAuthorAndPublisherAsync()
    {
        // Complex join returning anonymous object with:
        // BookTitle, AuthorName, PublisherName, Price
    }
    
    public async Task<IEnumerable<object>> GetAveragePriceByPublisherAsync()
    {
        // Group by publisher, calculate average price
    }
    
    public async Task<IEnumerable<Author>> GetAuthorsWithExpensiveBooksAsync(decimal priceThreshold)
    {
        // Authors who have written books above the price threshold
    }
    
    public async Task<IEnumerable<object>> GetBooksByYearStatisticsAsync()
    {
        // Group by year: Year, BookCount, AveragePrice, TotalRevenue
    }
    
    public async Task<IEnumerable<object>> SearchBooksAsync(string searchTerm)
    {
        // Search across book title, author name, and publisher name
    }
}
```

## ✅ Success Criteria
- [ ] All entities are properly configured with relationships
- [ ] Database migrations are created and applied successfully
- [ ] All basic LINQ queries return correct results
- [ ] Advanced queries with joins and aggregations work correctly
- [ ] Search functionality works across multiple tables
- [ ] Performance is optimized with appropriate `Include()` statements
- [ ] Queries use `async/await` pattern correctly

## 🔧 Testing Your Queries

Create a test controller to verify your queries:

```csharp
[ApiController]
[Route("api/[controller]")]
public class QueryTestController : ControllerBase
{
    private readonly BookQueryService _queryService;
    
    public QueryTestController(BookQueryService queryService)
    {
        _queryService = queryService;
    }
    
    [HttpGet("books-with-publishers")]
    public async Task<IActionResult> GetBooksWithPublishers()
    {
        var result = await _queryService.GetBooksWithPublishersAsync();
        return Ok(result);
    }
    
    [HttpGet("books-by-author/{authorId}")]
    public async Task<IActionResult> GetBooksByAuthor(int authorId)
    {
        var result = await _queryService.GetBooksByAuthorAsync(authorId);
        return Ok(result);
    }
    
    [HttpGet("search")]
    public async Task<IActionResult> SearchBooks([FromQuery] string term)
    {
        var result = await _queryService.SearchBooksAsync(term);
        return Ok(result);
    }
    
    // Add other endpoints...
}
```

## 💡 Performance Tips

1. **Use `Include()` wisely**: Only include navigation properties you actually need
2. **Consider `Select()` for projections**: When you only need specific fields
3. **Use `AsNoTracking()`**: For read-only queries to improve performance
4. **Implement pagination**: For queries that might return large datasets
5. **Add database indexes**: On frequently queried columns

## 🎯 Sample Expected Results

### Books with Publishers Query Result:
```json
[
  {
    "id": 1,
    "title": "C# Programming Guide",
    "isbn": "978-1234567890",
    "price": 29.99,
    "publisher": {
      "name": "Tech Publications",
      "foundedYear": 1995
    }
  }
]
```

### Author with Book Count:
```json
[
  {
    "authorId": 1,
    "fullName": "John Doe",
    "email": "john.doe@email.com",
    "bookCount": 3
  }
]
```

## 💡 Bonus Challenges

1. **Implement caching** for frequently accessed queries
2. **Add query filters** for soft-deleted records
3. **Create a generic query builder** for dynamic filtering
4. **Implement full-text search** using SQL Server full-text indexes
5. **Add query performance logging** to identify slow queries

## ❓ Common LINQ Query Patterns

### Efficient Loading Strategies:
```csharp
// Eager Loading
var books = await _context.Books
    .Include(b => b.Publisher)
    .Include(b => b.BookAuthors)
        .ThenInclude(ba => ba.Author)
    .ToListAsync();

// Projection (more efficient for specific data)
var bookSummaries = await _context.Books
    .Select(b => new {
        b.Title,
        b.Price,
        PublisherName = b.Publisher.Name,
        AuthorNames = b.BookAuthors.Select(ba => ba.Author.FullName)
    })
    .ToListAsync();

// Filtering with navigation properties
var expensiveBookAuthors = await _context.Authors
    .Where(a => a.BookAuthors.Any(ba => ba.Book.Price > 50))
    .ToListAsync();
```

---

**Next**: Proceed to Exercise 3 for Repository Pattern implementation!
