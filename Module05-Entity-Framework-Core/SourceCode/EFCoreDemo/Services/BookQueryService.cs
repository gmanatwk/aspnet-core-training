using EFCoreDemo.Data;
using EFCoreDemo.Models;
using Microsoft.EntityFrameworkCore;

namespace EFCoreDemo.Services;

/// <summary>
/// Book query service from Exercise 02 - Advanced LINQ Queries
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
    /// Get all books with their publishers
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
    /// Get books by a specific author
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
    /// Get authors with their book count
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
    /// Get books published in a specific year
    /// </summary>
    public async Task<IEnumerable<Book>> GetBooksByYearAsync(int year)
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Where(b => b.PublishedDate.Year == year)
            .OrderBy(b => b.PublishedDate)
            .ToListAsync();
    }

    /// <summary>
    /// Get the most expensive books
    /// </summary>
    public async Task<IEnumerable<Book>> GetTopExpensiveBooksAsync(int count = 5)
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .OrderByDescending(b => b.Price)
            .Take(count)
            .ToListAsync();
    }

    /// <summary>
    /// Get books with author details and publisher info (multi-table join)
    /// </summary>
    public async Task<IEnumerable<object>> GetBooksWithAuthorAndPublisherAsync()
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Include(b => b.BookAuthors)
                .ThenInclude(ba => ba.Author)
            .Select(b => new
            {
                BookTitle = b.Title,
                AuthorNames = string.Join(", ", b.BookAuthors.Select(ba => ba.Author.FullName)),
                PublisherName = b.Publisher != null ? b.Publisher.Name : "Unknown",
                Price = b.Price,
                PublishedDate = b.PublishedDate
            })
            .OrderBy(b => b.BookTitle)
            .ToListAsync();
    }

    /// <summary>
    /// Calculate average price by publisher
    /// </summary>
    public async Task<IEnumerable<object>> GetAveragePriceByPublisherAsync()
    {
        return await _context.Publishers
            .Select(p => new
            {
                PublisherName = p.Name,
                BookCount = p.Books.Count(),
                AveragePrice = p.Books.Any() ? Math.Round(p.Books.Average(b => b.Price), 2) : 0,
                MinPrice = p.Books.Any() ? p.Books.Min(b => b.Price) : 0,
                MaxPrice = p.Books.Any() ? p.Books.Max(b => b.Price) : 0
            })
            .Where(p => p.BookCount > 0)
            .OrderByDescending(p => p.AveragePrice)
            .ToListAsync();
    }

    /// <summary>
    /// Find authors who have written books above a certain price
    /// </summary>
    public async Task<IEnumerable<Author>> GetAuthorsWithExpensiveBooksAsync(decimal priceThreshold)
    {
        return await _context.Authors
            .Where(a => a.BookAuthors.Any(ba => ba.Book.Price > priceThreshold))
            .Include(a => a.BookAuthors)
                .ThenInclude(ba => ba.Book)
            .OrderBy(a => a.LastName)
            .ThenBy(a => a.FirstName)
            .ToListAsync();
    }

    /// <summary>
    /// Group books by publication year with statistics
    /// </summary>
    public async Task<IEnumerable<object>> GetBooksByYearStatisticsAsync()
    {
        return await _context.Books
            .GroupBy(b => b.PublishedDate.Year)
            .Select(g => new
            {
                Year = g.Key,
                BookCount = g.Count(),
                AveragePrice = Math.Round(g.Average(b => b.Price), 2),
                TotalRevenue = g.Sum(b => b.Price),
                Titles = g.Select(b => b.Title).ToList()
            })
            .OrderByDescending(g => g.Year)
            .ToListAsync();
    }

    /// <summary>
    /// Full-text search across book title, author name, and publisher
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
                }).ToList(),
                MatchedIn = DetermineMatchLocation(b, term)
            })
            .OrderBy(b => b.Title)
            .ToListAsync();
    }

    /// <summary>
    /// Helper method to determine where the search term was matched
    /// </summary>
    private static string DetermineMatchLocation(Book book, string term)
    {
        var locations = new List<string>();

        if (book.Title.ToLower().Contains(term))
            locations.Add("Title");
        
        if (book.ISBN.Contains(term))
            locations.Add("ISBN");
            
        if (book.Publisher != null && book.Publisher.Name.ToLower().Contains(term))
            locations.Add("Publisher");
            
        if (book.BookAuthors.Any(ba => 
            ba.Author.FirstName.ToLower().Contains(term) || 
            ba.Author.LastName.ToLower().Contains(term)))
            locations.Add("Author");

        return string.Join(", ", locations);
    }
}