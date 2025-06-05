using EFCoreDemo.Models;
using EFCoreDemo.Repositories;

namespace EFCoreDemo.UnitOfWork;

/// <summary>
/// Unit of Work interface from Exercise 03 - Repository Pattern
/// Coordinates multiple repositories and manages transactions
/// </summary>
public interface IUnitOfWork : IDisposable
{
    // Product Catalog repositories (existing)
    IProductRepository Products { get; }
    ICategoryRepository Categories { get; }
    IRepository<Supplier> Suppliers { get; }
    
    // BookStore repositories (Exercise 03)
    IBookRepository Books { get; }
    IAuthorRepository Authors { get; }
    IRepository<Publisher> Publishers { get; }
    
    // Transaction and save methods
    Task<int> SaveChangesAsync();
    Task BeginTransactionAsync();
    Task CommitTransactionAsync();
    Task RollbackTransactionAsync();
}