using EFCoreDemo.Data;
using EFCoreDemo.Models;
using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;

namespace EFCoreDemo.Repositories;

/// <summary>
/// Book-specific repository interface from Exercise 03 - Repository Pattern
/// </summary>
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

/// <summary>
/// Book repository implementation from Exercise 03
/// </summary>
public class BookRepository : BookStoreRepository<Book>, IBookRepository
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
                       (b.Publisher != null && b.Publisher.Name.ToLower().Contains(term)) ||
                       b.BookAuthors.Any(ba => 
                           ba.Author.FirstName.ToLower().Contains(term) ||
                           ba.Author.LastName.ToLower().Contains(term)))
            .OrderBy(b => b.Title)
            .ToListAsync();
    }

    public async Task<IEnumerable<Book>> GetBooksByPriceRangeAsync(decimal minPrice, decimal maxPrice)
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Where(b => b.IsAvailable && b.Price >= minPrice && b.Price <= maxPrice)
            .OrderBy(b => b.Price)
            .ToListAsync();
    }

    public async Task<bool> IsbnExistsAsync(string isbn, int? excludeBookId = null)
    {
        var query = _context.Books.Where(b => b.ISBN == isbn);
        
        if (excludeBookId.HasValue)
        {
            query = query.Where(b => b.Id != excludeBookId.Value);
        }

        return await query.AnyAsync();
    }

    public async Task<decimal> GetAveragePriceAsync()
    {
        var books = await _context.Books.Where(b => b.IsAvailable).ToListAsync();
        return books.Any() ? books.Average(b => b.Price) : 0m;
    }

    public async Task<IEnumerable<Book>> GetBooksPublishedInYearAsync(int year)
    {
        return await _context.Books
            .Include(b => b.Publisher)
            .Where(b => b.PublishedDate.Year == year)
            .OrderBy(b => b.PublishedDate)
            .ToListAsync();
    }

    public override async Task<Book?> GetByIdAsync(int id)
    {
        return await GetBookWithDetailsAsync(id);
    }
}