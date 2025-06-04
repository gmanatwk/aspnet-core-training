using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using LibraryAPI.Data;
using LibraryAPI.DTOs;
using LibraryAPI.Models;
using Microsoft.AspNetCore.Authorization;

namespace LibraryAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    [Authorize] // Require authentication for all endpoints
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
        [Authorize(Policy = "RequireLibrarianRole")]
        [ProducesResponseType(typeof(BookDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
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