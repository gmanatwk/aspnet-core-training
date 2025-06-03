# Entity Framework Core Performance Optimization Guide

## 🚀 Performance Best Practices

### 1. Query Optimization

#### Use Projection for Specific Data
```csharp
// ❌ Bad: Loading entire entities when only names needed
var bookTitles = await context.Books
    .Include(b => b.Authors)
    .ToListAsync();

// ✅ Good: Project only needed data
var bookTitles = await context.Books
    .Select(b => new { b.Title, AuthorNames = b.Authors.Select(a => a.Name) })
    .ToListAsync();
```

#### Optimize Include Operations
```csharp
// ❌ Bad: Loading unnecessary related data
var books = await context.Books
    .Include(b => b.Publisher)
    .Include(b => b.Authors)
    .Include(b => b.Reviews)
    .ToListAsync();

// ✅ Good: Only include what you need
var books = await context.Books
    .Include(b => b.Publisher)
    .Where(b => b.IsActive)
    .ToListAsync();
```

#### Use AsNoTracking for Read-Only Operations
```csharp
// ✅ Read-only queries
var books = await context.Books
    .AsNoTracking()
    .Where(b => b.IsActive)
    .ToListAsync();

// ✅ For updates, keep tracking
var book = await context.Books
    .FirstOrDefaultAsync(b => b.Id == id);
book.Title = "Updated Title";
await context.SaveChangesAsync();
```

### 2. Loading Strategies

#### Eager Loading (Include)
```csharp
// Load related data upfront
var books = await context.Books
    .Include(b => b.Publisher)
    .Include(b => b.BookAuthors)
        .ThenInclude(ba => ba.Author)
    .ToListAsync();
```

#### Explicit Loading
```csharp
var book = await context.Books.FirstAsync();

// Load related data when needed
await context.Entry(book)
    .Collection(b => b.Reviews)
    .LoadAsync();

await context.Entry(book)
    .Reference(b => b.Publisher)
    .LoadAsync();
```

#### Lazy Loading (Configure with caution)
```csharp
// Enable lazy loading (can cause N+1 problems)
protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
{
    optionsBuilder.UseLazyLoadingProxies();
}
```

### 3. Pagination Best Practices

#### Efficient Pagination
```csharp
public async Task<PagedResult<Book>> GetBooksPagedAsync(int page, int pageSize)
{
    var totalCount = await context.Books.CountAsync();
    
    var books = await context.Books
        .OrderBy(b => b.Id) // Always order for consistent pagination
        .Skip((page - 1) * pageSize)
        .Take(pageSize)
        .AsNoTracking()
        .ToListAsync();
    
    return new PagedResult<Book>
    {
        Data = books,
        TotalCount = totalCount,
        Page = page,
        PageSize = pageSize
    };
}
```

#### Cursor-Based Pagination (for large datasets)
```csharp
public async Task<IEnumerable<Book>> GetBooksAfterCursorAsync(int lastBookId, int pageSize)
{
    return await context.Books
        .Where(b => b.Id > lastBookId)
        .OrderBy(b => b.Id)
        .Take(pageSize)
        .AsNoTracking()
        .ToListAsync();
}
```

### 4. Connection and Context Management

#### DbContext Pooling
```csharp
// In Program.cs
services.AddDbContextPool<AppDbContext>(options =>
    options.UseSqlServer(connectionString), 
    poolSize: 1024);
```

#### Proper DbContext Scope
```csharp
// ✅ Good: Scoped lifetime in web applications
services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString), 
    ServiceLifetime.Scoped);

// ❌ Bad: Don't use singleton for DbContext
services.AddSingleton<AppDbContext>(); // Never do this!
```

### 5. Query Performance Monitoring

#### Enable Query Logging
```csharp
protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
{
    optionsBuilder
        .EnableDetailedErrors()
        .EnableSensitiveDataLogging()
        .LogTo(Console.WriteLine, LogLevel.Information);
}
```

#### Custom Performance Logging
```csharp
public class QueryPerformanceInterceptor : DbCommandInterceptor
{
    private readonly ILogger<QueryPerformanceInterceptor> _logger;
    
    public QueryPerformanceInterceptor(ILogger<QueryPerformanceInterceptor> logger)
    {
        _logger = logger;
    }
    
    public override async ValueTask<InterceptionResult<DbDataReader>> ReaderExecutingAsync(
        DbCommand command,
        CommandEventData eventData,
        InterceptionResult<DbDataReader> result,
        CancellationToken cancellationToken = default)
    {
        var stopwatch = Stopwatch.StartNew();
        var reader = await base.ReaderExecutingAsync(command, eventData, result, cancellationToken);
        stopwatch.Stop();
        
        if (stopwatch.ElapsedMilliseconds > 1000) // Log slow queries
        {
            _logger.LogWarning("Slow query detected: {QueryTime}ms - {CommandText}", 
                stopwatch.ElapsedMilliseconds, command.CommandText);
        }
        
        return reader;
    }
}
```

### 6. Database Design Optimization

#### Proper Indexing
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    // Single column index
    modelBuilder.Entity<Book>()
        .HasIndex(b => b.ISBN)
        .IsUnique();
    
    // Composite index
    modelBuilder.Entity<BookAuthor>()
        .HasIndex(ba => new { ba.BookId, ba.AuthorId });
    
    // Filtered index
    modelBuilder.Entity<Book>()
        .HasIndex(b => b.PublishedDate)
        .HasFilter("[IsActive] = 1");
}
```

### 7. Bulk Operations

#### Bulk Insert (EF Core 6+)
```csharp
var books = new List<Book>();
// ... populate books

// Bulk insert
await context.Books.AddRangeAsync(books);
await context.SaveChangesAsync();
```

#### Batch Updates
```csharp
// Update multiple records efficiently
await context.Books
    .Where(b => b.PublisherId == oldPublisherId)
    .ExecuteUpdateAsync(setters => setters
        .SetProperty(b => b.PublisherId, newPublisherId)
        .SetProperty(b => b.UpdatedAt, DateTime.UtcNow));
```

### 8. Memory Management

#### Clear Change Tracker for Long-Running Operations
```csharp
public async Task ProcessLargeDataset()
{
    var batchSize = 1000;
    var processed = 0;
    
    while (true)
    {
        var books = await context.Books
            .Skip(processed)
            .Take(batchSize)
            .AsNoTracking()
            .ToListAsync();
            
        if (!books.Any())
            break;
            
        // Process books...
        
        processed += books.Count;
        
        // Clear change tracker to free memory
        context.ChangeTracker.Clear();
    }
}
```

## 🔍 Performance Testing Tools

### MiniProfiler Integration
```csharp
// In Program.cs
services.AddMiniProfiler(options =>
{
    options.RouteBasePath = "/profiler";
}).AddEntityFramework();

// In middleware pipeline
app.UseMiniProfiler();
```

### SQL Server Performance Insights
```sql
-- Find slow queries
SELECT TOP 10
    qs.execution_count,
    qs.total_elapsed_time / 1000 as total_elapsed_time_ms,
    qs.total_elapsed_time / qs.execution_count / 1000 as avg_elapsed_time_ms,
    qt.text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
ORDER BY qs.total_elapsed_time DESC;
```

## ⚡ Quick Performance Checklist

- [ ] Use `AsNoTracking()` for read-only queries
- [ ] Project only needed columns with `Select()`
- [ ] Implement proper pagination with `Skip()` and `Take()`
- [ ] Use indexes on frequently queried columns
- [ ] Avoid N+1 query problems with `Include()`
- [ ] Use bulk operations for large datasets
- [ ] Monitor query performance regularly
- [ ] Clear change tracker for long-running operations
- [ ] Use connection pooling in production
- [ ] Implement proper error handling and logging
