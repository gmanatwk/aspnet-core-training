using EFCoreDemo.Data;
using EFCoreDemo.Models;
using Microsoft.EntityFrameworkCore;

namespace EFCoreDemo.Repositories;

/// <summary>
/// Author-specific repository interface from Exercise 03
/// </summary>
public interface IAuthorRepository : IRepository<Author>
{
    Task<IEnumerable<Author>> GetAuthorsWithBooksAsync();
    Task<Author?> GetAuthorWithBooksAsync(int id);
    Task<IEnumerable<Author>> SearchAuthorsAsync(string searchTerm);
    Task<bool> EmailExistsAsync(string email, int? excludeAuthorId = null);
    Task<IEnumerable<Author>> GetAuthorsByCountryAsync(string country);
    Task<int> GetBookCountForAuthorAsync(int authorId);
}

/// <summary>
/// Author repository implementation from Exercise 03
/// </summary>
public class AuthorRepository : BookStoreRepository<Author>, IAuthorRepository
{
    public AuthorRepository(BookStoreContext context) : base(context)
    {
    }

    public async Task<IEnumerable<Author>> GetAuthorsWithBooksAsync()
    {
        return await _context.Authors
            .Include(a => a.BookAuthors)
                .ThenInclude(ba => ba.Book)
                    .ThenInclude(b => b.Publisher)
            .OrderBy(a => a.LastName)
            .ThenBy(a => a.FirstName)
            .ToListAsync();
    }

    public async Task<Author?> GetAuthorWithBooksAsync(int id)
    {
        return await _context.Authors
            .Include(a => a.BookAuthors)
                .ThenInclude(ba => ba.Book)
                    .ThenInclude(b => b.Publisher)
            .FirstOrDefaultAsync(a => a.Id == id);
    }

    public async Task<IEnumerable<Author>> SearchAuthorsAsync(string searchTerm)
    {
        var term = searchTerm.ToLower();
        return await _context.Authors
            .Include(a => a.BookAuthors)
                .ThenInclude(ba => ba.Book)
            .Where(a => a.FirstName.ToLower().Contains(term) ||
                       a.LastName.ToLower().Contains(term) ||
                       a.Email.ToLower().Contains(term) ||
                       (a.Country != null && a.Country.ToLower().Contains(term)))
            .OrderBy(a => a.LastName)
            .ThenBy(a => a.FirstName)
            .ToListAsync();
    }

    public async Task<bool> EmailExistsAsync(string email, int? excludeAuthorId = null)
    {
        var query = _context.Authors.Where(a => a.Email.ToLower() == email.ToLower());
        
        if (excludeAuthorId.HasValue)
        {
            query = query.Where(a => a.Id != excludeAuthorId.Value);
        }

        return await query.AnyAsync();
    }

    public async Task<IEnumerable<Author>> GetAuthorsByCountryAsync(string country)
    {
        return await _context.Authors
            .Include(a => a.BookAuthors)
                .ThenInclude(ba => ba.Book)
            .Where(a => a.Country != null && a.Country.ToLower() == country.ToLower())
            .OrderBy(a => a.LastName)
            .ThenBy(a => a.FirstName)
            .ToListAsync();
    }

    public async Task<int> GetBookCountForAuthorAsync(int authorId)
    {
        return await _context.BookAuthors
            .Where(ba => ba.AuthorId == authorId)
            .CountAsync();
    }

    public override async Task<Author?> GetByIdAsync(int id)
    {
        return await GetAuthorWithBooksAsync(id);
    }
}