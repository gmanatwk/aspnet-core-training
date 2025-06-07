using EFCoreDemo.Models;
using EFCoreDemo.Repositories;

namespace EFCoreDemo.UnitOfWork;

/// <summary>
/// Unit of Work interface from Exercise 03 - Repository Pattern
/// Coordinates multiple repositories and manages transactions
/// </summary>
public interface IUnitOfWork : IDisposable
{
    IBookRepository Books { get; }
    IRepository<Author> Authors { get; }
    IRepository<Publisher> Publishers { get; }

    Task<int> SaveChangesAsync();
    Task BeginTransactionAsync();
    Task CommitTransactionAsync();
    Task RollbackTransactionAsync();
}
