using EFCoreDemo.Data;
using EFCoreDemo.Models;
using Microsoft.EntityFrameworkCore;

namespace EFCoreDemo.Services;

/// <summary>
/// Book query service from Exercise 02 - Advanced LINQ Queries
/// Implements all required query methods from the exercise
/// </summary>
public class BookQueryService
{
    private readonly BookStoreContext _context;
    private readonly ILogger<BookQueryService> _logger;

    public BookQueryService(BookStoreContext context, ILogger<BookQueryService> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Get all books with their publishers (Basic LINQ Query #1)
    /// </summary>
    public async Task<IEnumerable<Book>> GetBooksWithPublishersAsync()
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Where(b => b.IsAvailable)
            .OrderBy(b => b.Title)
            .ToListAsync();
    }

    /// <summary>
    /// Get books by a specific author (Basic LINQ Query #2)
    /// </summary>
    public async Task<IEnumerable<Book>> GetBooksByAuthorAsync(int authorId)
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Include(b => b.BookAuthors)
                .ThenInclude(ba => ba.Author)
            .Where(b => b.BookAuthors.Any(ba => ba.AuthorId == authorId))
            .OrderBy(b => b.Title)
            .ToListAsync();
    }

    /// <summary>
    /// Get authors with their book count (Basic LINQ Query #3)
    /// </summary>
    public async Task<IEnumerable<object>> GetAuthorsWithBookCountAsync()
    {
        return await _context.Authors
            .Select(a => new
            {
                AuthorId = a.Id,
                FullName = a.FirstName + " " + a.LastName,
                Email = a.Email,
                BookCount = a.BookAuthors.Count()
            })
            .OrderByDescending(a => a.BookCount)
            .ToListAsync();
    }

    /// <summary>
    /// Full-text search across book title, author name, and publisher - Search (Advanced Query #5)
    /// </summary>
    public async Task<IEnumerable<object>> SearchBooksAsync(string searchTerm)
    {
        var term = searchTerm.ToLower();

        return await _context.Books
            .Include(b => b.Publisher)
            .Include(b => b.BookAuthors)
                .ThenInclude(ba => ba.Author)
            .Where(b => b.Title.ToLower().Contains(term) ||
                       b.ISBN.Contains(term) ||
                       (b.Publisher != null && b.Publisher.Name.ToLower().Contains(term)) ||
                       b.BookAuthors.Any(ba =>
                           ba.Author.FirstName.ToLower().Contains(term) ||
                           ba.Author.LastName.ToLower().Contains(term)))
            .Select(b => new
            {
                Id = b.Id,
                Title = b.Title,
                ISBN = b.ISBN,
                Price = b.Price,
                PublisherName = b.Publisher != null ? b.Publisher.Name : "Unknown",
                Authors = b.BookAuthors.Select(ba => new
                {
                    Name = ba.Author.FullName,
                    Role = ba.Role
                }).ToList()
            })
            .OrderBy(b => b.Title)
            .ToListAsync();
    }
}
