using EFCoreDemo.Data;
using EFCoreDemo.Models;
using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;

namespace EFCoreDemo.Repositories;

/// <summary>
/// Book-specific repository interface from Exercise 03
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
    Task<IEnumerable<T>> GetPagedAsync<T>(
        Expression<Func<Book, bool>>? filter = null,
        Func<IQueryable<Book>, IOrderedQueryable<Book>>? orderBy = null,
        int page = 1,
        int pageSize = 10,
        Expression<Func<Book, T>>? selector = null) where T : class;
}

/// <summary>
/// Book repository implementation from Exercise 03
/// </summary>
public class BookRepository : Repository<Book>, IBookRepository
{
    public BookRepository(BookStoreContext context) : base(context)
    {
    }

    private BookStoreContext BookContext => (BookStoreContext)_context;

    public async Task<IEnumerable<Book>> GetBooksWithPublisherAsync()
    {
        return await BookContext.Books
            .Include(b => b.Publisher)
            .Where(b => b.IsAvailable)
            .OrderBy(b => b.Title)
            .ToListAsync();
    }

    public async Task<Book?> GetBookWithDetailsAsync(int id)
    {
        return await BookContext.Books
            .Include(b => b.Publisher)
            .Include(b => b.BookAuthors)
                .ThenInclude(ba => ba.Author)
            .FirstOrDefaultAsync(b => b.Id == id);
    }

    public async Task<IEnumerable<Book>> GetBooksByAuthorAsync(int authorId)
    {
        return await BookContext.Books
            .Include(b => b.Publisher)
            .Where(b => b.BookAuthors.Any(ba => ba.AuthorId == authorId))
            .OrderBy(b => b.Title)
            .ToListAsync();
    }

    public async Task<IEnumerable<Book>> GetBooksByPublisherAsync(int publisherId)
    {
        return await BookContext.Books
            .Include(b => b.Publisher)
            .Where(b => b.PublisherId == publisherId && b.IsAvailable)
            .OrderBy(b => b.Title)
            .ToListAsync();
    }

    public async Task<IEnumerable<Book>> SearchBooksAsync(string searchTerm)
    {
        var term = searchTerm.ToLower();
        return await BookContext.Books
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
        return await BookContext.Books
            .Include(b => b.Publisher)
            .Where(b => b.IsAvailable && b.Price >= minPrice && b.Price <= maxPrice)
            .OrderBy(b => b.Price)
            .ToListAsync();
    }

    public async Task<bool> IsbnExistsAsync(string isbn, int? excludeBookId = null)
    {
        var query = BookContext.Books.Where(b => b.ISBN == isbn);
        
        if (excludeBookId.HasValue)
        {
            query = query.Where(b => b.Id != excludeBookId.Value);
        }

        return await query.AnyAsync();
    }

    public async Task<decimal> GetAveragePriceAsync()
    {
        var books = await BookContext.Books.Where(b => b.IsAvailable).ToListAsync();
        return books.Any() ? books.Average(b => b.Price) : 0m;
    }

    public async Task<IEnumerable<Book>> GetBooksPublishedInYearAsync(int year)
    {
        return await BookContext.Books
            .Include(b => b.Publisher)
            .Where(b => b.PublishedDate.Year == year)
            .OrderBy(b => b.PublishedDate)
            .ToListAsync();
    }

    public async Task<IEnumerable<T>> GetPagedAsync<T>(
        Expression<Func<Book, bool>>? filter = null,
        Func<IQueryable<Book>, IOrderedQueryable<Book>>? orderBy = null,
        int page = 1,
        int pageSize = 10,
        Expression<Func<Book, T>>? selector = null) where T : class
    {
        IQueryable<Book> query = BookContext.Books
            .Include(b => b.Publisher)
            .Include(b => b.BookAuthors)
                .ThenInclude(ba => ba.Author);

        if (filter != null)
        {
            query = query.Where(filter);
        }

        if (orderBy != null)
        {
            query = orderBy(query);
        }
        else
        {
            query = query.OrderBy(b => b.Title);
        }

        query = query.Skip((page - 1) * pageSize).Take(pageSize);

        if (selector != null)
        {
            return await query.Select(selector).ToListAsync();
        }

        // If no selector is provided and T is Book, return as is
        if (typeof(T) == typeof(Book))
        {
            return (IEnumerable<T>)await query.ToListAsync();
        }

        throw new InvalidOperationException("Selector must be provided when T is not Book");
    }

    public override async Task<Book?> GetByIdAsync(int id)
    {
        return await BookContext.Books
            .Include(b => b.Publisher)
            .Include(b => b.BookAuthors)
                .ThenInclude(ba => ba.Author)
            .FirstOrDefaultAsync(b => b.Id == id);
    }
}