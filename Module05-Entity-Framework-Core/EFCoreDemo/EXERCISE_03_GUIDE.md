# Exercise 3: Repository Pattern and Unit of Work Implementation

## 🎯 Objective
Refactor direct Entity Framework Core usage to implement the Repository Pattern and Unit of Work Pattern for better separation of concerns, testability, and maintainability.

## ⏱️ Time Allocation
**Total Time**: 35 minutes
- Generic Repository Implementation: 12 minutes
- Specific Repository Implementation: 10 minutes
- Unit of Work Pattern: 8 minutes
- Controller Refactoring: 5 minutes

## 🚀 Getting Started

### Step 1: Register Services in Program.cs
Add the following to your Program.cs service registration:

```csharp
// Register repositories
builder.Services.AddScoped<IBookRepository, BookRepository>();
builder.Services.AddScoped(typeof(IRepository<>), typeof(Repository<>));

// Register Unit of Work
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
```

### Step 2: Refactor BooksController
Update your BooksController to use the Unit of Work pattern:

```csharp
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

    [HttpPost]
    public async Task<ActionResult<Book>> CreateBook(Book book)
    {
        try
        {
            // Validate ISBN uniqueness
            if (await _unitOfWork.Books.IsbnExistsAsync(book.ISBN))
            {
                return Conflict($"Book with ISBN {book.ISBN} already exists");
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
}
```

## ✅ Success Criteria
- [ ] Generic repository interface and implementation are complete
- [ ] Specific repositories are implemented with domain-specific methods
- [ ] Unit of Work pattern is properly implemented
- [ ] Transaction management works correctly
- [ ] Controllers are refactored to use repositories
- [ ] Proper error handling and logging are in place

## 🧪 Testing Your Implementation
1. Run: `dotnet run`
2. Navigate to: http://localhost:5000/swagger
3. Test repository methods through API endpoints
4. Verify transaction rollback by causing intentional errors

## 🎯 Learning Outcomes
After completing this exercise, you should understand:
- Repository pattern implementation and benefits
- Unit of Work pattern for transaction management
- Dependency injection with repositories
- Clean architecture principles
- Testable code design

