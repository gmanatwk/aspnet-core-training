# Exercise 3: Repository Pattern and Unit of Work Implementation

## 🎯 Objective
Refactor direct Entity Framework Core usage to implement the Repository Pattern and Unit of Work Pattern for better separation of concerns, testability, and maintainability.

## ⏱️ Time Allocation
**Total Time**: 35 minutes
- Generic Repository Implementation: 12 minutes
- Specific Repository Implementation: 10 minutes
- Unit of Work Pattern: 8 minutes
- Controller Refactoring: 5 minutes

## 📋 Requirements

### Part A: Generic Repository Pattern (12 minutes)
1. Create a generic `IRepository<T>` interface with common CRUD operations
2. Implement a base `Repository<T>` class
3. Include support for:
   - Async operations
   - Expression-based filtering
   - Ordering and pagination
   - Existence checks

### Part B: Specific Repository Implementation (10 minutes)
1. Create `IBookRepository` and `BookRepository` with book-specific operations
2. Create `IAuthorRepository` and `AuthorRepository` with author-specific operations
3. Include advanced query methods specific to each entity

### Part C: Unit of Work Pattern (8 minutes)
1. Create `IUnitOfWork` interface to coordinate multiple repositories
2. Implement `UnitOfWork` class that manages transaction scope
3. Ensure proper disposal and transaction management

### Part D: Controller Refactoring (5 minutes)
1. Refactor existing controllers to use repositories instead of direct DbContext
2. Implement proper error handling and logging
3. Demonstrate transaction management with Unit of Work

## 🚀 Implementation Guide

### Step 1: Create Generic Repository Interface

```csharp
// Repositories/IRepository.cs
public interface IRepository<T> where T : class
{
    // Basic CRUD operations
    Task<IEnumerable<T>> GetAllAsync();
    Task<T?> GetByIdAsync(int id);
    Task<T> AddAsync(T entity);
    Task<T> UpdateAsync(T entity);
    Task<bool> DeleteAsync(int id);
    
    // Advanced operations
    Task<bool> ExistsAsync(int id);
    Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate);
    Task<T?> FirstOrDefaultAsync(Expression<Func<T, bool>> predicate);
    Task<int> CountAsync();
    Task<int> CountAsync(Expression<Func<T, bool>> predicate);
    
    // Pagination
    Task<IEnumerable<T>> GetPagedAsync(int page, int pageSize);
    Task<IEnumerable<T>> GetPagedAsync(
        Expression<Func<T, bool>>? filter = null,
        Func<IQueryable<T>, IOrderedQueryable<T>>? orderBy = null,
        int page = 1,
        int pageSize = 10);
}
```

### Step 2: Implement Generic Repository

```csharp
// Repositories/Repository.cs
public class Repository<T> : IRepository<T> where T : class
{
    protected readonly BookStoreContext _context;
    protected readonly DbSet<T> _dbSet;
    
    public Repository(BookStoreContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }
    
    public virtual async Task<IEnumerable<T>> GetAllAsync()
    {
        return await _dbSet.ToListAsync();
    }
    
    public virtual async Task<T?> GetByIdAsync(int id)
    {
        return await _dbSet.FindAsync(id);
    }
    
    public virtual async Task<T> AddAsync(T entity)
    {
        var result = await _dbSet.AddAsync(entity);
        return result.Entity;
    }
    
    public virtual async Task<T> UpdateAsync(T entity)
    {
        _dbSet.Update(entity);
        return entity;
    }
    
    public virtual async Task<bool> DeleteAsync(int id)
    {
        var entity = await GetByIdAsync(id);
        if (entity == null)
            return false;
            
        _dbSet.Remove(entity);
        return true;
    }
    
    public virtual async Task<bool> ExistsAsync(int id)
    {
        return await _dbSet.FindAsync(id) != null;
    }
    
    public virtual async Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate)
    {
        return await _dbSet.Where(predicate).ToListAsync();
    }
    
    public virtual async Task<T?> FirstOrDefaultAsync(Expression<Func<T, bool>> predicate)
    {
        return await _dbSet.FirstOrDefaultAsync(predicate);
    }
    
    public virtual async Task<int> CountAsync()
    {
        return await _dbSet.CountAsync();
    }
    
    public virtual async Task<int> CountAsync(Expression<Func<T, bool>> predicate)
    {
        return await _dbSet.CountAsync(predicate);
    }
    
    public virtual async Task<IEnumerable<T>> GetPagedAsync(int page, int pageSize)
    {
        return await _dbSet
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }
    
    public virtual async Task<IEnumerable<T>> GetPagedAsync(
        Expression<Func<T, bool>>? filter = null,
        Func<IQueryable<T>, IOrderedQueryable<T>>? orderBy = null,
        int page = 1,
        int pageSize = 10)
    {
        IQueryable<T> query = _dbSet;
        
        if (filter != null)
        {
            query = query.Where(filter);
        }
        
        if (orderBy != null)
        {
            query = orderBy(query);
        }
        
        return await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }
}
```

### Step 3: Create Specific Repository Interfaces

```csharp
// Repositories/IBookRepository.cs
public interface IBookRepository : IRepository<Book>
{
    Task<IEnumerable<Book>> GetBooksWithPublisherAsync();
    Task<Book?> GetBookWithDetailsAsync(int id);
    Task<IEnumerable<Book>> GetBooksByAuthorAsync(int authorId);
    Task<IEnumerable<Book>> GetBooksByPublisherAsync(int publisherId);
    Task<IEnumerable<Book>> SearchBooksAsync(string searchTerm);
    Task<IEnumerable<Book>> GetBooksByPriceRangeAsync(decimal minPrice, decimal maxPrice);
    Task<bool> IsbnExistsAsync(string isbn, int? excludeBookId = null);
    Task<decimal> GetAveragePriceAsync();
    Task<IEnumerable<Book>> GetBooksPublishedInYearAsync(int year);
}

// Repositories/IAuthorRepository.cs
public interface IAuthorRepository : IRepository<Author>
{
    Task<IEnumerable<Author>> GetAuthorsWithBooksAsync();
    Task<Author?> GetAuthorWithBooksAsync(int id);
    Task<IEnumerable<Author>> SearchAuthorsAsync(string searchTerm);
    Task<bool> EmailExistsAsync(string email, int? excludeAuthorId = null);
    Task<IEnumerable<Author>> GetAuthorsByCountryAsync(string country);
    Task<int> GetBookCountForAuthorAsync(int authorId);
}
```

### Step 4: Implement Specific Repositories

```csharp
// Repositories/BookRepository.cs
public class BookRepository : Repository<Book>, IBookRepository
{
    public BookRepository(BookStoreContext context) : base(context)
    {
    }
    
    public async Task<IEnumerable<Book>> GetBooksWithPublisherAsync()
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Where(b => b.IsAvailable)
            .OrderBy(b => b.Title)
            .ToListAsync();
    }
    
    public async Task<Book?> GetBookWithDetailsAsync(int id)
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Include(b => b.BookAuthors)
                .ThenInclude(ba => ba.Author)
            .FirstOrDefaultAsync(b => b.Id == id);
    }
    
    public async Task<IEnumerable<Book>> GetBooksByAuthorAsync(int authorId)
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Where(b => b.BookAuthors.Any(ba => ba.AuthorId == authorId))
            .OrderBy(b => b.Title)
            .ToListAsync();
    }
    
    public async Task<IEnumerable<Book>> GetBooksByPublisherAsync(int publisherId)
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Where(b => b.PublisherId == publisherId && b.IsAvailable)
            .OrderBy(b => b.Title)
            .ToListAsync();
    }
    
    public async Task<IEnumerable<Book>> SearchBooksAsync(string searchTerm)
    {
        var term = searchTerm.ToLower();
        return await _context.Books
            .Include(b => b.Publisher)
            .Include(b => b.BookAuthors)
                .ThenInclude(ba => ba.Author)
            .Where(b => b.Title.ToLower().Contains(term) ||
                       b.ISBN.Contains(term) ||
                       b.Publisher.Name.ToLower().Contains(term) ||
                       b.BookAuthors.Any(ba => 
                           ba.Author.FirstName.ToLower().Contains(term) ||
                           ba.Author.LastName.ToLower().Contains(term)))
            .OrderBy(b => b.Title)
            .ToListAsync();
    }
    
    // TODO: Implement remaining methods
    public async Task<IEnumerable<Book>> GetBooksByPriceRangeAsync(decimal minPrice, decimal maxPrice)
    {
        // Your implementation here
        throw new NotImplementedException();
    }
    
    public async Task<bool> IsbnExistsAsync(string isbn, int? excludeBookId = null)
    {
        // Your implementation here
        throw new NotImplementedException();
    }
    
    public async Task<decimal> GetAveragePriceAsync()
    {
        // Your implementation here
        throw new NotImplementedException();
    }
    
    public async Task<IEnumerable<Book>> GetBooksPublishedInYearAsync(int year)
    {
        // Your implementation here
        throw new NotImplementedException();
    }
}
```

### Step 5: Create Unit of Work Pattern

```csharp
// UnitOfWork/IUnitOfWork.cs
public interface IUnitOfWork : IDisposable
{
    IBookRepository Books { get; }
    IAuthorRepository Authors { get; }
    IRepository<Publisher> Publishers { get; }
    
    Task<int> SaveChangesAsync();
    Task BeginTransactionAsync();
    Task CommitTransactionAsync();
    Task RollbackTransactionAsync();
}

// UnitOfWork/UnitOfWork.cs
public class UnitOfWork : IUnitOfWork
{
    private readonly BookStoreContext _context;
    private IDbContextTransaction? _transaction;
    
    public IBookRepository Books { get; }
    public IAuthorRepository Authors { get; }
    public IRepository<Publisher> Publishers { get; }
    
    public UnitOfWork(BookStoreContext context)
    {
        _context = context;
        Books = new BookRepository(_context);
        Authors = new AuthorRepository(_context);
        Publishers = new Repository<Publisher>(_context);
    }
    
    public async Task<int> SaveChangesAsync()
    {
        return await _context.SaveChangesAsync();
    }
    
    public async Task BeginTransactionAsync()
    {
        _transaction = await _context.Database.BeginTransactionAsync();
    }
    
    public async Task CommitTransactionAsync()
    {
        if (_transaction != null)
        {
            await _transaction.CommitAsync();
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }
    
    public async Task RollbackTransactionAsync()
    {
        if (_transaction != null)
        {
            await _transaction.RollbackAsync();
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }
    
    public void Dispose()
    {
        _transaction?.Dispose();
        _context.Dispose();
    }
}
```

### Step 6: Update Dependency Injection

```csharp
// Program.cs - Add to service registration
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<IBookRepository, BookRepository>();
builder.Services.AddScoped<IAuthorRepository, AuthorRepository>();
builder.Services.AddScoped(typeof(IRepository<>), typeof(Repository<>));
```

### Step 7: Refactor Controller

```csharp
// Controllers/BooksController.cs
[ApiController]
[Route("api/[controller]")]
public class BooksController : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<BooksController> _logger;
    
    public BooksController(IUnitOfWork unitOfWork, ILogger<BooksController> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }
    
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Book>>> GetBooks()
    {
        try
        {
            var books = await _unitOfWork.Books.GetBooksWithPublisherAsync();
            return Ok(books);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving books");
            return StatusCode(500, "Internal server error");
        }
    }
    
    [HttpGet("{id}")]
    public async Task<ActionResult<Book>> GetBook(int id)
    {
        try
        {
            var book = await _unitOfWork.Books.GetBookWithDetailsAsync(id);
            
            if (book == null)
            {
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
    
    [HttpPost]
    public async Task<ActionResult<Book>> CreateBook(Book book)
    {
        try
        {
            // Validate ISBN uniqueness
            if (await _unitOfWork.Books.IsbnExistsAsync(book.ISBN))
            {
                return Conflict($"Book with ISBN '{book.ISBN}' already exists");
            }
            
            await _unitOfWork.BeginTransactionAsync();
            
            var createdBook = await _unitOfWork.Books.AddAsync(book);
            await _unitOfWork.SaveChangesAsync();
            
            await _unitOfWork.CommitTransactionAsync();
            
            return CreatedAtAction(nameof(GetBook), new { id = createdBook.Id }, createdBook);
        }
        catch (Exception ex)
        {
            await _unitOfWork.RollbackTransactionAsync();
            _logger.LogError(ex, "Error creating book");
            return StatusCode(500, "Internal server error");
        }
    }
    
    // TODO: Implement PUT, DELETE, and other endpoints
}
```

## ✅ Success Criteria
- [ ] Generic repository interface and implementation are complete
- [ ] Specific repositories are implemented with domain-specific methods
- [ ] Unit of Work pattern is properly implemented
- [ ] Transaction management works correctly
- [ ] Controllers are refactored to use repositories
- [ ] Proper error handling and logging are in place
- [ ] All repository methods work correctly
- [ ] Dependency injection is configured properly

## 🔧 Testing Your Implementation

Create integration tests to verify your repository implementation:

```csharp
// Tests/RepositoryTests.cs
public class BookRepositoryTests : IClassFixture<DatabaseFixture>
{
    private readonly BookStoreContext _context;
    private readonly IBookRepository _bookRepository;
    
    public BookRepositoryTests(DatabaseFixture fixture)
    {
        _context = fixture.Context;
        _bookRepository = new BookRepository(_context);
    }
    
    [Fact]
    public async Task GetBooksWithPublisher_ShouldReturnBooksWithPublisherData()
    {
        // Arrange & Act
        var books = await _bookRepository.GetBooksWithPublisherAsync();
        
        // Assert
        Assert.NotEmpty(books);
        Assert.All(books, book => Assert.NotNull(book.Publisher));
    }
    
    [Fact]
    public async Task SearchBooks_ShouldFindBooksByTitle()
    {
        // Arrange
        var searchTerm = "Programming";
        
        // Act
        var books = await _bookRepository.SearchBooksAsync(searchTerm);
        
        // Assert
        Assert.NotEmpty(books);
        Assert.All(books, book => 
            Assert.Contains(searchTerm, book.Title, StringComparison.OrdinalIgnoreCase));
    }
    
    // Add more tests...
}
```

## 💡 Benefits of Repository Pattern

1. **Separation of Concerns**: Business logic separated from data access
2. **Testability**: Easy to mock repositories for unit testing
3. **Consistency**: Standardized data access patterns
4. **Flexibility**: Can switch data access technologies
5. **Maintainability**: Centralized data access logic

## 🎯 Advanced Features to Implement

### Caching Repository Decorator:
```csharp
public class CachedBookRepository : IBookRepository
{
    private readonly IBookRepository _bookRepository;
    private readonly IMemoryCache _cache;
    
    public CachedBookRepository(IBookRepository bookRepository, IMemoryCache cache)
    {
        _bookRepository = bookRepository;
        _cache = cache;
    }
    
    public async Task<Book?> GetByIdAsync(int id)
    {
        var cacheKey = $"book_{id}";
        
        if (_cache.TryGetValue(cacheKey, out Book? cachedBook))
        {
            return cachedBook;
        }
        
        var book = await _bookRepository.GetByIdAsync(id);
        
        if (book != null)
        {
            _cache.Set(cacheKey, book, TimeSpan.FromMinutes(30));
        }
        
        return book;
    }
    
    // Implement other methods...
}
```

## ❓ Discussion Points

1. **When to use Repository Pattern?**
   - Complex business logic
   - Multiple data sources
   - Need for extensive testing
   - Team consistency requirements

2. **Repository vs Direct EF Core?**
   - Repository: Better abstraction, testability
   - Direct EF: Less complexity, more EF features

3. **Generic vs Specific Repositories?**
   - Generic: Reusable, less code
   - Specific: Domain-specific methods, better expressiveness

---

**Congratulations!** You've successfully implemented the Repository and Unit of Work patterns. This provides a solid foundation for maintainable, testable data access code.
