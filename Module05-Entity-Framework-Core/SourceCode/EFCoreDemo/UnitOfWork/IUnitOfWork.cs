using EFCoreDemo.Models;
using EFCoreDemo.Repositories;

namespace EFCoreDemo.UnitOfWork;

/// <summary>
/// Unit of Work interface from Exercise 03
/// </summary>
public interface IUnitOfWork : IDisposable
{
    // Repository properties for Product Catalog
    IProductRepository Products { get; }
    ICategoryRepository Categories { get; }
    IRepository<Supplier> Suppliers { get; }
    
    // Repository properties for BookStore
    IBookRepository Books { get; }
    IAuthorRepository Authors { get; }
    IRepository<Publisher> Publishers { get; }
    
    // Transaction and save methods
    Task<int> SaveChangesAsync();
    Task BeginTransactionAsync();
    Task CommitTransactionAsync();
    Task RollbackTransactionAsync();
    bool HasActiveTransaction { get; }
}