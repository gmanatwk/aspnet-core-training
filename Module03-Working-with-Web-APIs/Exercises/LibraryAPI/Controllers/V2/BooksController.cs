
using Asp.Versioning;
using LibraryAPI.Data;
using LibraryAPI.Models;
using LibraryAPI.Models.DTOs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Swashbuckle.AspNetCore.Annotations;

namespace LibraryAPI.Controllers.V2
{
    /// <summary>
    /// Manages library books (Version 2 - Enhanced)
    /// </summary>
    [ApiController]
    [ApiVersion("2.0")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [Produces("application/json")]
    [SwaggerTag("Enhanced book management with advanced features")]
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
        /// Get all books with advanced filtering and sorting
        /// </summary>
        /// <param name="filter">Advanced filter criteria</param>
        /// <param name="pagination">Pagination parameters</param>
        /// <param name="sortBy">Field to sort by (title, author, year, rating)</param>
        /// <param name="sortDescending">Sort in descending order</param>
        /// <returns>Paginated list of enhanced book data</returns>
        [HttpGet]
        [SwaggerOperation(
            Summary = "Get books with advanced filtering",
            Description = "Retrieves books with enhanced filtering, sorting, and pagination capabilities",
            OperationId = "GetBooksV2"
        )]
        [SwaggerResponse(200, "Success", typeof(PaginatedResponse<BookDtoV2>))]
        [SwaggerResponse(400, "Bad Request", typeof(ValidationProblemDetails))]
        public async Task<ActionResult<PaginatedResponse<BookDtoV2>>> GetBooks(
            [FromQuery] BookFilterDto filter,
            [FromQuery] PaginationParams pagination,
            [FromQuery] string? sortBy = "title",
            [FromQuery] bool sortDescending = false)
        {
            try
            {
                var query = _context.Books
                    .Include(b => b.Author)
                    .Include(b => b.Category)
                    .AsQueryable();

                // Apply filters
                if (!string.IsNullOrEmpty(filter.Category))
                {
                    query = query.Where(b => b.Category!.Name.Contains(filter.Category));
                }

                if (!string.IsNullOrEmpty(filter.Author))
                {
                    query = query.Where(b =>
                        b.Author!.FirstName.Contains(filter.Author) ||
                        b.Author!.LastName.Contains(filter.Author));
                }

                if (filter.Year.HasValue)
                {
                    query = query.Where(b => b.PublicationYear == filter.Year.Value);
                }

                if (!string.IsNullOrEmpty(filter.SearchTerm))
                {
                    query = query.Where(b =>
                        b.Title.Contains(filter.SearchTerm) ||
                        b.Summary.Contains(filter.SearchTerm));
                }

                if (!string.IsNullOrEmpty(filter.Language))
                {
                    // For demo purposes, assume all books are in English
                    // In real implementation, you'd have a Language property
                }

                // Apply sorting
                query = sortBy?.ToLower() switch
                {
                    "author" => sortDescending
                        ? query.OrderByDescending(b => b.Author!.LastName)
                        : query.OrderBy(b => b.Author!.LastName),
                    "year" => sortDescending
                        ? query.OrderByDescending(b => b.PublicationYear)
                        : query.OrderBy(b => b.PublicationYear),
                    "category" => sortDescending
                        ? query.OrderByDescending(b => b.Category!.Name)
                        : query.OrderBy(b => b.Category!.Name),
                    _ => sortDescending
                        ? query.OrderByDescending(b => b.Title)
                        : query.OrderBy(b => b.Title)
                };

                // Get total count
                var totalCount = await query.CountAsync();

                // Apply pagination
                var books = await query
                    .Skip((pagination.PageNumber - 1) * pagination.PageSize)
                    .Take(pagination.PageSize)
                    .Select(b => new BookDtoV2
                    // (
                    //     b.Id,
                    //     b.Title,
                    //     $"{b.Author!.FirstName} {b.Author.LastName}",
                    //     b.PublicationYear,
                    //     b.NumberOfPages,
                    //     b.ISBN,
                    //     b.Category!.Name,
                    //     b.Summary,
                    //     b.CreatedAt,
                    //     b.UpdatedAt
                    // )
                    {
                        AvailableCopies = 5, // Mock data
                        Publisher = "Sample Publisher", // Mock data
                        Rating = 4.2m, // Mock data
                        Language = "English",
                        Tags = new List<string> { b.Category!.Name, "Popular" } // Mock data
                    })
                    .ToListAsync();

                var result = PaginatedResponse<BookDtoV2>.Create(
                    books,
                    pagination.PageNumber,
                    pagination.PageSize,
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
        /// Get a specific book by ID with enhanced details
        /// </summary>
        /// <param name="id">Book ID</param>
        /// <returns>Enhanced book details</returns>
        [HttpGet("{id}")]
        [SwaggerOperation(
            Summary = "Get book by ID",
            Description = "Retrieves a specific book with enhanced details",
            OperationId = "GetBookByIdV2"
        )]
        [SwaggerResponse(200, "Success", typeof(BookDtoV2))]
        [SwaggerResponse(404, "Book not found")]
        public async Task<ActionResult<BookDtoV2>> GetBook(int id)
        {
            var book = await _context.Books
                .Include(b => b.Author)
                .Include(b => b.Category)
                .FirstOrDefaultAsync(b => b.Id == id);

            if (book == null)
            {
                return NotFound($"Book with ID {id} not found");
            }

            var bookDto = new BookDtoV2() {
                Title = book.Title,
                Author = $"{book.Author!.FirstName} {book.Author.LastName}",
                PublicationYear = book.PublicationYear,
                PageCount = book.NumberOfPages,
                ISBN = book.ISBN,
                Category = book.Category!.Name,
                Description = book.Summary,
                // CreatedAt = book.CreatedAt,
                // UpatedAd = book.UpdatedAt,
           
                AvailableCopies = 5, // Mock data
                Publisher = "Sample Publisher", // Mock data
                Rating = 4.2m, // Mock data
                Language = "English",
                Tags = new List<string> { book.Category!.Name, "Popular" } // Mock data
            };

            return Ok(bookDto);
        }

        /// <summary>
        /// Bulk create multiple books
        /// </summary>
        /// <param name="books">List of books to create</param>
        /// <returns>Bulk operation result</returns>
        [HttpPost("bulk")]
        [SwaggerOperation(
            Summary = "Bulk create books",
            Description = "Creates multiple books in a single operation",
            OperationId = "CreateBooksBulkV2"
        )]
        [SwaggerResponse(200, "Success", typeof(BulkOperationResult))]
        [SwaggerResponse(400, "Validation errors")]
        public async Task<ActionResult<BulkOperationResult>> CreateBooksBulk(
            [FromBody] List<CreateBookDto> books)
        {
            var result = new BulkOperationResult
            {
                TotalCount = books.Count
            };

            try
            {
                using var transaction = await _context.Database.BeginTransactionAsync();

                for (int i = 0; i < books.Count; i++)
                {
                    var bookDto = books[i];

                    try
                    {
                        // Validate the book
                        if (string.IsNullOrEmpty(bookDto.Title))
                        {
                            result.Errors.Add(new BulkOperationError
                            {
                                Index = i,
                                Message = "Title is required",
                                Item = bookDto
                            });
                            result.FailureCount++;
                            continue;
                        }

                        // Check if ISBN already exists
                        var existingBook = await _context.Books
                            .FirstOrDefaultAsync(b => b.ISBN == bookDto.ISBN);

                        if (existingBook != null)
                        {
                            result.Errors.Add(new BulkOperationError
                            {
                                Index = i,
                                Message = $"Book with ISBN {bookDto.ISBN} already exists",
                                Item = bookDto
                            });
                            result.FailureCount++;
                            continue;
                        }

                        // Create the book
                        var book = new Book
                        {
                            Title = bookDto.Title,
                            ISBN = bookDto.ISBN,
                            PublicationYear = bookDto.PublicationYear,
                            NumberOfPages = bookDto.AvailableCopies,
                            Summary = "Auto-generated summary", // Mock data
                            AuthorId = bookDto.AuthorId,
                            CategoryId = bookDto.CategoryId,
                            CreatedAt = DateTime.UtcNow
                        };

                        _context.Books.Add(book);
                        await _context.SaveChangesAsync();

                        result.CreatedIds.Add(book.Id);
                        result.SuccessCount++;
                    }
                    catch (Exception ex)
                    {
                        result.Errors.Add(new BulkOperationError
                        {
                            Index = i,
                            Message = ex.Message,
                            Item = bookDto
                        });
                        result.FailureCount++;
                    }
                }

                await transaction.CommitAsync();
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during bulk book creation");
                return StatusCode(500, "An error occurred during bulk creation");
            }
        }

        /// <summary>
        /// Get book statistics (V2 only feature)
        /// </summary>
        /// <returns>Book statistics</returns>
        [HttpGet("statistics")]
        [SwaggerOperation(
            Summary = "Get book statistics",
            Description = "Retrieves various statistics about the book collection",
            OperationId = "GetBookStatisticsV2"
        )]
        public async Task<ActionResult<object>> GetStatistics()
        {
            try
            {
                var stats = new
                {
                    TotalBooks = await _context.Books.CountAsync(),
                    TotalAuthors = await _context.Authors.CountAsync(),
                    TotalCategories = await _context.Categories.CountAsync(),
                    AveragePublicationYear = await _context.Books.AverageAsync(b => (double)b.PublicationYear),
                    MostPopularCategory = await _context.Categories
                        .OrderByDescending(c => c.Books.Count)
                        .Select(c => c.Name)
                        .FirstOrDefaultAsync(),
                    BooksByDecade = await _context.Books
                        .GroupBy(b => (b.PublicationYear / 10) * 10)
                        .Select(g => new { Decade = g.Key, Count = g.Count() })
                        .OrderBy(x => x.Decade)
                        .ToListAsync()
                };

                return Ok(stats);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving book statistics");
                return StatusCode(500, "An error occurred while retrieving statistics");
            }
        }
    }
}