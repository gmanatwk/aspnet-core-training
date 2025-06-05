using Asp.Versioning;
using Microsoft.AspNetCore.Mvc;
using Swashbuckle.AspNetCore.Annotations;
using LibraryAPI.Models.DTOs;
using LibraryAPI.Data;
using Microsoft.EntityFrameworkCore;

namespace LibraryAPI.Controllers.V1
{
    /// <summary>
    /// Manages library books (Version 1)
    /// </summary>
    [ApiController]
    [ApiVersion("1.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [Produces("application/json")]
    [SwaggerTag("Create, read, update and delete books")]
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
        /// Get all books with pagination
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     GET /api/v1/books?pageNumber=1&amp;pageSize=10&amp;category=Fiction
        ///
        /// </remarks>
        /// <param name="category">Filter by category name (optional)</param>
        /// <param name="author">Filter by author last name (optional)</param>
        /// <param name="year">Filter by publication year (optional)</param>
        /// <param name="pageNumber">Page number (default: 1)</param>
        /// <param name="pageSize">Items per page (default: 10, max: 100)</param>
        /// <returns>A paginated list of books</returns>
        /// <response code="200">Returns the list of books</response>
        /// <response code="400">If the pagination parameters are invalid</response>
        [HttpGet]
        [SwaggerOperation(
            Summary = "Get all books",
            Description = "Retrieves a paginated list of books with optional filtering",
            OperationId = "GetBooksV1",
            Tags = new[] { "Books" }
        )]
        [SwaggerResponse(200, "Success", typeof(PaginatedResponse<BookDto>))]
        [SwaggerResponse(400, "Bad Request", typeof(ValidationProblemDetails))]
        public async Task<ActionResult<PaginatedResponse<BookDto>>> GetBooks(
            [FromQuery] string? category = null,
            [FromQuery] string? author = null,
            [FromQuery] int? year = null,
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 10)
        {
            try
            {
                // Validate pagination parameters
                if (pageNumber < 1) pageNumber = 1;
                if (pageSize < 1) pageSize = 10;
                if (pageSize > 100) pageSize = 100;

                var query = _context.Books
                    .Include(b => b.Author)
                    .Include(b => b.Category)
                    .AsQueryable();

                // Apply basic filters
                if (!string.IsNullOrEmpty(category))
                {
                    query = query.Where(b => b.Category!.Name.Contains(category));
                }

                if (!string.IsNullOrEmpty(author))
                {
                    query = query.Where(b => b.Author!.LastName.Contains(author));
                }

                if (year.HasValue)
                {
                    query = query.Where(b => b.PublicationYear == year.Value);
                }

                // Get total count
                var totalCount = await query.CountAsync();

                // Apply pagination and select
                var books = await query
                    .OrderBy(b => b.Title)
                    .Skip((pageNumber - 1) * pageSize)
                    .Take(pageSize)
                    .Select(b => new BookDto
                    {
                        Id = b.Id,
                        Title = b.Title,
                        Author = $"{b.Author!.FirstName} {b.Author.LastName}",
                        Category = b.Category!.Name,
                        PublicationYear = b.PublicationYear,
                        ISBN = b.ISBN,
                        AvailableCopies = 5, // Mock data for V1

                    })
                    .ToListAsync();

                var result = PaginatedResponse<BookDto>.Create(
                    books,
                    pageNumber,
                    pageSize,
                    totalCount);

                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving books");
                return StatusCode(500, "An error occurred while retrieving books");
            }
        }

        /// <summary>
        /// Get a specific book by ID
        /// </summary>
        /// <param name="id">Book ID</param>
        /// <returns>Book details</returns>
        [HttpGet("{id}")]
        [SwaggerOperation(
            Summary = "Get book by ID",
            Description = "Retrieves a specific book by its ID",
            OperationId = "GetBookByIdV1"
        )]
        [SwaggerResponse(200, "Success", typeof(BookDto))]
        [SwaggerResponse(404, "Book not found")]
        public async Task<ActionResult<BookDto>> GetBook(int id)
        {
            var book = await _context.Books
                .Include(b => b.Author)
                .Include(b => b.Category)
                .FirstOrDefaultAsync(b => b.Id == id);

            if (book == null)
            {
                return NotFound($"Book with ID {id} not found");
            }

            var bookDto = new BookDto{
                Id = book.Id,
                Title =book.Title,
                Author = $"{book.Author!.FirstName} {book.Author.LastName}",
                PublicationYear = book.PublicationYear,
                AvailableCopies = 5, // AvailableCopies (mock data for V1)
                ISBN = book.ISBN,
               Category = book.Category!.Name
            };

            return Ok(bookDto);
        }
    }
}