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

            // TODO: Implement getting all books
            // HINT: Use await _context.Books.ToListAsync()
            return Ok(new { message = "TODO: Implement GetBooks method" });
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

            // TODO: Get a specific book by ID
            // HINT: Use await _context.Books.FindAsync(id)
            return Ok(new { message = $"TODO: Implement GetBook for id: {id}" });
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

            _logger.LogInformation("Creating new book: {BookTitle}", book.Title);

            // TODO: Add book to database
            // STEPS:
            // 1. _context.Books.Add(book)
            // 2. await _context.SaveChangesAsync()
            // 3. Return CreatedAtAction(nameof(GetBook), new { id = book.Id }, book)
            return Ok(new { message = "TODO: Implement CreateBook method" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating book");
            return StatusCode(500, "Internal server error");
        }
    }

    // TODO: Add PUT and DELETE methods
    // PUT: api/books/5
    // DELETE: api/books/5
}
