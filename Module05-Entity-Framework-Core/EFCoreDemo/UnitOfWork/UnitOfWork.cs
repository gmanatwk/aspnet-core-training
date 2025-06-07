using Microsoft.EntityFrameworkCore.Storage;
using EFCoreDemo.Data;
using EFCoreDemo.Models;
using EFCoreDemo.Repositories;

namespace EFCoreDemo.UnitOfWork;

/// <summary>
/// Unit of Work implementation from Exercise 03
/// Manages multiple repositories and ensures transactional consistency
/// </summary>
public class UnitOfWork : IUnitOfWork
{
    private readonly BookStoreContext _context;
    private IDbContextTransaction? _transaction;

    public IBookRepository Books { get; }
    public IRepository<Author> Authors { get; }
    public IRepository<Publisher> Publishers { get; }

    public UnitOfWork(BookStoreContext context)
    {
        _context = context;
        Books = new BookRepository(_context);
        Authors = new Repository<Author>(_context);
        Publishers = new Repository<Publisher>(_context);
    }

    public async Task<int> SaveChangesAsync()
    {
        return await _context.SaveChangesAsync();
    }

    public async Task BeginTransactionAsync()
    {
        _transaction = await _context.Database.BeginTransactionAsync();
    }

    public async Task CommitTransactionAsync()
    {
        if (_transaction != null)
        {
            await _transaction.CommitAsync();
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }

    public async Task RollbackTransactionAsync()
    {
        if (_transaction != null)
        {
            await _transaction.RollbackAsync();
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }

    public void Dispose()
    {
        _transaction?.Dispose();
        _context.Dispose();
    }
}
