using EFCoreDemo.Models;
using EFCoreDemo.UnitOfWork;
using Microsoft.AspNetCore.Mvc;

namespace EFCoreDemo.Controllers;

/// <summary>
/// Books API Controller from Exercise 01 - Basic CRUD Operations
/// Refactored in Exercise 03 to use Repository Pattern and Unit of Work
/// </summary>
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

    /// <summary>
    /// Get all books
    /// </summary>
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

    /// <summary>
    /// Get book by ID
    /// </summary>
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

    /// <summary>
    /// Create a new book
    /// </summary>
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

            // Validate publisher exists
            if (book.PublisherId.HasValue && !await _unitOfWork.Publishers.ExistsAsync(book.PublisherId.Value))
            {
                return BadRequest($"Publisher with ID {book.PublisherId} does not exist");
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

    /// <summary>
    /// Update an existing book
    /// </summary>
    [HttpPut("{id}")]
    public async Task<ActionResult<Book>> UpdateBook(int id, Book book)
    {
        try
        {
            if (id != book.Id)
            {
                return BadRequest("Book ID mismatch");
            }

            var existingBook = await _unitOfWork.Books.GetByIdAsync(id);
            
            if (existingBook == null)
            {
                return NotFound($"Book with ID {id} not found");
            }

            // Validate ISBN uniqueness (excluding current book)
            if (await _unitOfWork.Books.IsbnExistsAsync(book.ISBN, id))
            {
                return Conflict($"Another book with ISBN '{book.ISBN}' already exists");
            }

            // Validate publisher exists
            if (book.PublisherId.HasValue && !await _unitOfWork.Publishers.ExistsAsync(book.PublisherId.Value))
            {
                return BadRequest($"Publisher with ID {book.PublisherId} does not exist");
            }

            // Update book properties
            existingBook.Title = book.Title;
            existingBook.ISBN = book.ISBN;
            existingBook.Price = book.Price;
            existingBook.PublishedDate = book.PublishedDate;
            existingBook.IsAvailable = book.IsAvailable;
            existingBook.PublisherId = book.PublisherId;

            var updatedBook = await _unitOfWork.Books.UpdateAsync(existingBook);
            await _unitOfWork.SaveChangesAsync();

            return Ok(updatedBook);
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
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteBook(int id)
    {
        try
        {
            var deleted = await _unitOfWork.Books.DeleteAsync(id);
            
            if (!deleted)
            {
                return NotFound($"Book with ID {id} not found");
            }

            await _unitOfWork.SaveChangesAsync();
            
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting book {BookId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Search books (from Exercise 02)
    /// </summary>
    [HttpGet("search")]
    public async Task<ActionResult<IEnumerable<Book>>> SearchBooks([FromQuery] string searchTerm)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
            {
                return BadRequest("Search term is required");
            }

            var books = await _unitOfWork.Books.SearchBooksAsync(searchTerm);
            return Ok(books);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error searching books with term: {SearchTerm}", searchTerm);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get books by price range (Bonus from Exercise 01)
    /// </summary>
    [HttpGet("price-range")]
    public async Task<ActionResult<IEnumerable<Book>>> GetBooksByPriceRange(
        [FromQuery] decimal minPrice, 
        [FromQuery] decimal maxPrice)
    {
        try
        {
            if (minPrice < 0 || maxPrice < 0 || minPrice > maxPrice)
            {
                return BadRequest("Invalid price range");
            }

            var books = await _unitOfWork.Books.GetBooksByPriceRangeAsync(minPrice, maxPrice);
            return Ok(books);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving books by price range");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get books with pagination (Bonus from Exercise 01)
    /// </summary>
    [HttpGet("paged")]
    public async Task<ActionResult<object>> GetBooksPaged(
        [FromQuery] int page = 1, 
        [FromQuery] int pageSize = 10)
    {
        try
        {
            if (page < 1 || pageSize < 1 || pageSize > 100)
            {
                return BadRequest("Invalid pagination parameters");
            }

            var books = await _unitOfWork.Books.GetPagedAsync<Book>(
                filter: b => b.IsAvailable,
                orderBy: q => q.OrderBy(b => b.Title),
                page: page,
                pageSize: pageSize);

            var totalCount = await _unitOfWork.Books.CountAsync(b => b.IsAvailable);
            
            return Ok(new
            {
                Data = books,
                Page = page,
                PageSize = pageSize,
                TotalCount = totalCount,
                TotalPages = (int)Math.Ceiling((double)totalCount / pageSize)
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving paged books");
            return StatusCode(500, "Internal server error");
        }
    }
}