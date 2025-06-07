using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Data;
using EFCoreDemo.Models;
using EFCoreDemo.Models.DTOs;

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
    public async Task<ActionResult<IEnumerable<BookDto>>> GetBooks()
    {
        try
        {
            _logger.LogInformation("Retrieving all books");

            var books = await _context.Books
                .AsNoTracking()
                .Select(b => new BookDto
                {
                    Id = b.Id,
                    Title = b.Title,
                    Author = b.Author,
                    ISBN = b.ISBN,
                    Price = b.Price,
                    PublishedDate = b.PublishedDate,
                    IsAvailable = b.IsAvailable,
                    PublisherName = b.Publisher != null ? b.Publisher.Name : null
                })
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
    public async Task<ActionResult<BookDto>> GetBook(int id)
    {
        try
        {
            _logger.LogInformation("Retrieving book with ID: {BookId}", id);

            var book = await _context.Books
                .AsNoTracking()
                .Where(b => b.Id == id)
                .Select(b => new BookDto
                {
                    Id = b.Id,
                    Title = b.Title,
                    Author = b.Author,
                    ISBN = b.ISBN,
                    Price = b.Price,
                    PublishedDate = b.PublishedDate,
                    IsAvailable = b.IsAvailable,
                    PublisherName = b.Publisher != null ? b.Publisher.Name : null
                })
                .FirstOrDefaultAsync();

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
    /// <param name="createBookDto">Book data to create</param>
    /// <returns>Created book</returns>
    /// <remarks>
    /// Sample request:
    ///
    ///     POST /api/books
    ///     {
    ///        "title": "Learning ASP.NET Core",
    ///        "author": "John Developer",
    ///        "isbn": "978-1234567890",
    ///        "price": 29.99,
    ///        "publishedDate": "2024-01-15T00:00:00",
    ///        "isAvailable": true,
    ///        "publisherId": 1
    ///     }
    ///
    /// </remarks>
    /// <response code="201">Returns the newly created book</response>
    /// <response code="400">If the book data is invalid</response>
    /// <response code="409">If a book with the same ISBN already exists</response>
    [HttpPost]
    [ProducesResponseType(typeof(BookDto), 201)]
    [ProducesResponseType(400)]
    [ProducesResponseType(409)]
    public async Task<ActionResult<BookDto>> CreateBook([FromBody] CreateBookDto createBookDto)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            _logger.LogInformation("Creating new book: {BookTitle}", createBookDto.Title);

            // Check if ISBN already exists
            var existingBook = await _context.Books
                .FirstOrDefaultAsync(b => b.ISBN == createBookDto.ISBN);

            if (existingBook != null)
            {
                return Conflict($"Book with ISBN {createBookDto.ISBN} already exists");
            }

            // Validate publisher exists if provided
            if (createBookDto.PublisherId.HasValue)
            {
                var publisherExists = await _context.Publishers
                    .AnyAsync(p => p.Id == createBookDto.PublisherId.Value);

                if (!publisherExists)
                {
                    return BadRequest($"Publisher with ID {createBookDto.PublisherId} does not exist");
                }
            }

            var book = new Book
            {
                Title = createBookDto.Title,
                Author = createBookDto.Author,
                ISBN = createBookDto.ISBN,
                Price = createBookDto.Price,
                PublishedDate = createBookDto.PublishedDate,
                IsAvailable = createBookDto.IsAvailable,
                PublisherId = createBookDto.PublisherId
            };

            _context.Books.Add(book);
            await _context.SaveChangesAsync();

            var bookDto = new BookDto
            {
                Id = book.Id,
                Title = book.Title,
                Author = book.Author,
                ISBN = book.ISBN,
                Price = book.Price,
                PublishedDate = book.PublishedDate,
                IsAvailable = book.IsAvailable
            };

            return CreatedAtAction(nameof(GetBook), new { id = book.Id }, bookDto);
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
    /// <param name="updateBookDto">Updated book data</param>
    /// <returns>No content if successful</returns>
    /// <remarks>
    /// Sample request:
    ///
    ///     PUT /api/books/1
    ///     {
    ///        "title": "Advanced ASP.NET Core",
    ///        "author": "Jane Developer",
    ///        "isbn": "978-0987654321",
    ///        "price": 39.99,
    ///        "publishedDate": "2024-02-20T00:00:00",
    ///        "isAvailable": true,
    ///        "publisherId": 2
    ///     }
    ///
    /// </remarks>
    /// <response code="204">Book updated successfully</response>
    /// <response code="400">If the book data is invalid</response>
    /// <response code="404">If the book is not found</response>
    /// <response code="409">If the ISBN conflicts with another book</response>
    [HttpPut("{id}")]
    [ProducesResponseType(204)]
    [ProducesResponseType(400)]
    [ProducesResponseType(404)]
    [ProducesResponseType(409)]
    public async Task<IActionResult> UpdateBook(int id, [FromBody] UpdateBookDto updateBookDto)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var book = await _context.Books.FindAsync(id);
            if (book == null)
            {
                return NotFound($"Book with ID {id} not found");
            }

            // Check if ISBN is being changed and if it conflicts with another book
            if (book.ISBN != updateBookDto.ISBN)
            {
                var existingBook = await _context.Books
                    .FirstOrDefaultAsync(b => b.ISBN == updateBookDto.ISBN && b.Id != id);

                if (existingBook != null)
                {
                    return Conflict($"Book with ISBN {updateBookDto.ISBN} already exists");
                }
            }

            // Validate publisher exists if provided
            if (updateBookDto.PublisherId.HasValue)
            {
                var publisherExists = await _context.Publishers
                    .AnyAsync(p => p.Id == updateBookDto.PublisherId.Value);

                if (!publisherExists)
                {
                    return BadRequest($"Publisher with ID {updateBookDto.PublisherId} does not exist");
                }
            }

            book.Title = updateBookDto.Title;
            book.Author = updateBookDto.Author;
            book.ISBN = updateBookDto.ISBN;
            book.Price = updateBookDto.Price;
            book.PublishedDate = updateBookDto.PublishedDate;
            book.IsAvailable = updateBookDto.IsAvailable;
            book.PublisherId = updateBookDto.PublisherId;

            await _context.SaveChangesAsync();
            return NoContent();
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
    /// <returns>No content if successful</returns>
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

            _context.Books.Remove(book);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Deleted book {BookId}: {BookTitle}", id, book.Title);
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting book {BookId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get all publishers (helper endpoint for testing)
    /// </summary>
    /// <returns>List of all publishers</returns>
    [HttpGet("publishers")]
    public async Task<ActionResult<IEnumerable<object>>> GetPublishers()
    {
        try
        {
            var publishers = await _context.Publishers
                .AsNoTracking()
                .Select(p => new
                {
                    Id = p.Id,
                    Name = p.Name,
                    Address = p.Address,
                    Website = p.Website,
                    FoundedYear = p.FoundedYear
                })
                .OrderBy(p => p.Name)
                .ToListAsync();

            return Ok(publishers);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving publishers");
            return StatusCode(500, "Internal server error");
        }
    }

    private bool BookExists(int id)
    {
        return _context.Books.Any(e => e.Id == id);
    }
}
