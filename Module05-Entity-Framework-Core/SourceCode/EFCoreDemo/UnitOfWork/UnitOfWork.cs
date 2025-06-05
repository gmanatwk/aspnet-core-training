using EFCoreDemo.Data;
using EFCoreDemo.Models;
using EFCoreDemo.Repositories;
using Microsoft.EntityFrameworkCore.Storage;

namespace EFCoreDemo.UnitOfWork;

/// <summary>
/// Unit of Work implementation from Exercise 03
/// </summary>
public class UnitOfWork : IUnitOfWork
{
    private readonly ProductCatalogContext _productContext;
    private readonly BookStoreContext _bookContext;
    private IDbContextTransaction? _productTransaction;
    private IDbContextTransaction? _bookTransaction;
    private readonly ILogger<UnitOfWork> _logger;

    // Repository instances
    private IProductRepository? _products;
    private ICategoryRepository? _categories;
    private IRepository<Supplier>? _suppliers;
    private IBookRepository? _books;
    private IAuthorRepository? _authors;
    private IRepository<Publisher>? _publishers;

    public UnitOfWork(
        ProductCatalogContext productContext, 
        BookStoreContext bookContext,
        ILogger<UnitOfWork> logger)
    {
        _productContext = productContext;
        _bookContext = bookContext;
        _logger = logger;
    }

    // Product Catalog repositories
    public IProductRepository Products => 
        _products ??= new ProductRepository(_productContext);

    public ICategoryRepository Categories => 
        _categories ??= new CategoryRepository(_productContext);

    public IRepository<Supplier> Suppliers => 
        _suppliers ??= new Repository<Supplier>(_productContext);

    // BookStore repositories
    public IBookRepository Books => 
        _books ??= new BookRepository(_bookContext);

    public IAuthorRepository Authors => 
        _authors ??= new AuthorRepository(_bookContext);

    public IRepository<Publisher> Publishers => 
        _publishers ??= new Repository<Publisher>(_bookContext);

    public bool HasActiveTransaction => _productTransaction != null || _bookTransaction != null;

    public async Task<int> SaveChangesAsync()
    {
        try
        {
            var productChanges = await _productContext.SaveChangesAsync();
            var bookChanges = await _bookContext.SaveChangesAsync();
            
            _logger.LogInformation("Unit of Work saved {ProductChanges} product changes and {BookChanges} book changes", 
                productChanges, bookChanges);
            
            return productChanges + bookChanges;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error saving changes in Unit of Work");
            throw;
        }
    }

    public async Task BeginTransactionAsync()
    {
        if (HasActiveTransaction)
        {
            _logger.LogWarning("Transaction already in progress");
            return;
        }

        try
        {
            _productTransaction = await _productContext.Database.BeginTransactionAsync();
            _bookTransaction = await _bookContext.Database.BeginTransactionAsync();
            
            _logger.LogInformation("Unit of Work transaction started");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error starting transaction");
            throw;
        }
    }

    public async Task CommitTransactionAsync()
    {
        if (!HasActiveTransaction)
        {
            _logger.LogWarning("No active transaction to commit");
            return;
        }

        try
        {
            if (_productTransaction != null)
            {
                await _productTransaction.CommitAsync();
                await _productTransaction.DisposeAsync();
                _productTransaction = null;
            }

            if (_bookTransaction != null)
            {
                await _bookTransaction.CommitAsync();
                await _bookTransaction.DisposeAsync();
                _bookTransaction = null;
            }
            
            _logger.LogInformation("Unit of Work transaction committed");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error committing transaction");
            await RollbackTransactionAsync();
            throw;
        }
    }

    public async Task RollbackTransactionAsync()
    {
        if (!HasActiveTransaction)
        {
            _logger.LogWarning("No active transaction to rollback");
            return;
        }

        try
        {
            if (_productTransaction != null)
            {
                await _productTransaction.RollbackAsync();
                await _productTransaction.DisposeAsync();
                _productTransaction = null;
            }

            if (_bookTransaction != null)
            {
                await _bookTransaction.RollbackAsync();
                await _bookTransaction.DisposeAsync();
                _bookTransaction = null;
            }
            
            _logger.LogInformation("Unit of Work transaction rolled back");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error rolling back transaction");
            throw;
        }
    }

    public void Dispose()
    {
        _productTransaction?.Dispose();
        _bookTransaction?.Dispose();
        _productContext.Dispose();
        _bookContext.Dispose();
        
        _logger.LogInformation("Unit of Work disposed");
    }
}