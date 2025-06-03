# Exercise 2: Database Optimization

## Objective
Optimize database queries and Entity Framework Core usage to improve application performance.

## Prerequisites
- Visual Studio or Visual Studio Code
- .NET 8 SDK
- SQL Server or SQLite (for local database)
- Entity Framework Core knowledge

## Exercise Description

In this exercise, you will analyze and optimize inefficient database queries using Entity Framework Core. You'll learn how to identify and fix common performance issues related to database access.

## Tasks

### 1. Setup the Project

1. Create a new ASP.NET Core Web API project:
   ```
   dotnet new webapi -n DatabaseOptimization
   ```

2. Add the required NuGet packages:
   ```
   dotnet add package Microsoft.EntityFrameworkCore.SqlServer
   dotnet add package Microsoft.EntityFrameworkCore.Design
   dotnet add package BenchmarkDotNet
   ```

3. Create a data model with relationships:
   ```csharp
   public class Product
   {
       public int Id { get; set; }
       public string Name { get; set; }
       public string Description { get; set; }
       public decimal Price { get; set; }
       public int Stock { get; set; }
       public bool IsActive { get; set; }
       public DateTime CreatedAt { get; set; }
       
       public int CategoryId { get; set; }
       public Category Category { get; set; }
       
       public List<OrderItem> OrderItems { get; set; } = new();
       public List<ProductTag> ProductTags { get; set; } = new();
   }
   
   public class Category
   {
       public int Id { get; set; }
       public string Name { get; set; }
       public string Description { get; set; }
       
       public List<Product> Products { get; set; } = new();
   }
   
   public class Order
   {
       public int Id { get; set; }
       public string CustomerName { get; set; }
       public string CustomerEmail { get; set; }
       public DateTime OrderDate { get; set; }
       public decimal TotalAmount { get; set; }
       
       public List<OrderItem> OrderItems { get; set; } = new();
   }
   
   public class OrderItem
   {
       public int Id { get; set; }
       public int OrderId { get; set; }
       public Order Order { get; set; }
       
       public int ProductId { get; set; }
       public Product Product { get; set; }
       
       public int Quantity { get; set; }
       public decimal UnitPrice { get; set; }
   }
   
   public class Tag
   {
       public int Id { get; set; }
       public string Name { get; set; }
       
       public List<ProductTag> ProductTags { get; set; } = new();
   }
   
   public class ProductTag
   {
       public int ProductId { get; set; }
       public Product Product { get; set; }
       
       public int TagId { get; set; }
       public Tag Tag { get; set; }
   }
   ```

4. Create a DbContext with configuration:
   ```csharp
   public class AppDbContext : DbContext
   {
       public AppDbContext(DbContextOptions<AppDbContext> options)
           : base(options)
       {
       }
       
       public DbSet<Product> Products { get; set; }
       public DbSet<Category> Categories { get; set; }
       public DbSet<Order> Orders { get; set; }
       public DbSet<OrderItem> OrderItems { get; set; }
       public DbSet<Tag> Tags { get; set; }
       public DbSet<ProductTag> ProductTags { get; set; }
       
       protected override void OnModelCreating(ModelBuilder modelBuilder)
       {
           // Configure ProductTag as a many-to-many relationship
           modelBuilder.Entity<ProductTag>()
               .HasKey(pt => new { pt.ProductId, pt.TagId });
               
           // TODO: Add necessary configurations and indexes
       }
   }
   ```

5. Seed the database with test data (at least 1000 products, 10 categories, 50 tags, and 500 orders).

### 2. Identify and Fix N+1 Query Problems

1. Create a service with inefficient queries:
   ```csharp
   public class IneffientProductService
   {
       private readonly AppDbContext _context;
       
       public IneffientProductService(AppDbContext context)
       {
           _context = context;
       }
       
       // N+1 query problem example
       public async Task<List<ProductDto>> GetProductsWithCategoryAsync()
       {
           var products = await _context.Products.ToListAsync();
           
           var productDtos = new List<ProductDto>();
           foreach (var product in products)
           {
               // This will cause a separate query for each product
               var category = await _context.Categories.FindAsync(product.CategoryId);
               
               productDtos.Add(new ProductDto
               {
                   Id = product.Id,
                   Name = product.Name,
                   Price = product.Price,
                   CategoryName = category.Name
               });
           }
           
           return productDtos;
       }
       
       // Another inefficient query example
       public async Task<List<OrderSummaryDto>> GetOrdersWithDetailsAsync()
       {
           var orders = await _context.Orders.ToListAsync();
           
           var orderDtos = new List<OrderSummaryDto>();
           foreach (var order in orders)
           {
               var orderItems = await _context.OrderItems
                   .Where(oi => oi.OrderId == order.Id)
                   .ToListAsync();
                   
               var orderDto = new OrderSummaryDto
               {
                   Id = order.Id,
                   CustomerName = order.CustomerName,
                   OrderDate = order.OrderDate,
                   TotalAmount = order.TotalAmount,
                   ItemCount = orderItems.Count
               };
               
               orderDtos.Add(orderDto);
           }
           
           return orderDtos;
       }
   }
   ```

2. Create an optimized version using Include and proper query techniques:
   ```csharp
   public class OptimizedProductService
   {
       private readonly AppDbContext _context;
       
       public OptimizedProductService(AppDbContext context)
       {
           _context = context;
       }
       
       // TODO: Implement optimized versions of the above queries
       public async Task<List<ProductDto>> GetProductsWithCategoryAsync()
       {
           // Use Include to avoid N+1 problem
       }
       
       public async Task<List<OrderSummaryDto>> GetOrdersWithDetailsAsync()
       {
           // Use proper join or Include with efficient projection
       }
   }
   ```

### 3. Implement Query Splitting

1. Identify scenarios where query splitting could be beneficial:
   ```csharp
   // Before: Single complex query with multiple includes
   public async Task<List<ProductDetailDto>> GetProductsWithAllDetailsAsync()
   {
       var products = await _context.Products
           .Include(p => p.Category)
           .Include(p => p.ProductTags)
               .ThenInclude(pt => pt.Tag)
           .Include(p => p.OrderItems)
               .ThenInclude(oi => oi.Order)
           .ToListAsync();
           
       // Map to DTOs
       // ...
   }
   
   // TODO: Implement with query splitting
   public async Task<List<ProductDetailDto>> GetProductsWithAllDetailsSplitAsync()
   {
       // Use AsSplitQuery() to split into multiple database queries
   }
   ```

### 4. Optimize with No-Tracking Queries

1. Identify read-only scenarios and implement no-tracking queries:
   ```csharp
   // Before: Using tracking queries for read-only operations
   public async Task<List<ProductDto>> GetProductsForDisplayAsync()
   {
       return await _context.Products
           .Include(p => p.Category)
           .Select(p => new ProductDto
           {
               Id = p.Id,
               Name = p.Name,
               Price = p.Price,
               CategoryName = p.Category.Name
           })
           .ToListAsync();
   }
   
   // TODO: Implement with no-tracking query
   public async Task<List<ProductDto>> GetProductsForDisplayNoTrackingAsync()
   {
       // Use AsNoTracking() for read-only scenarios
   }
   ```

### 5. Implement Compiled Queries

1. Create compiled queries for frequently executed database operations:
   ```csharp
   // TODO: Implement compiled queries for common operations
   private static readonly Func<AppDbContext, int, Task<Product>> GetProductByIdQuery = 
       EF.CompileAsyncQuery((AppDbContext context, int id) => 
           context.Products.Include(p => p.Category)
               .FirstOrDefault(p => p.Id == id));
   ```

### 6. Implement Efficient Pagination

1. Create an inefficient pagination method:
   ```csharp
   // Inefficient pagination - loads all records and then takes a page
   public async Task<List<ProductDto>> GetProductsPageInefficient(int pageNumber, int pageSize)
   {
       var allProducts = await _context.Products
           .Include(p => p.Category)
           .ToListAsync();
           
       return allProducts
           .Skip((pageNumber - 1) * pageSize)
           .Take(pageSize)
           .Select(p => new ProductDto
           {
               Id = p.Id,
               Name = p.Name,
               Price = p.Price,
               CategoryName = p.Category.Name
           })
           .ToList();
   }
   ```

2. Create an optimized pagination method:
   ```csharp
   // TODO: Implement efficient pagination
   public async Task<PagedResult<ProductDto>> GetProductsPageEfficient(int pageNumber, int pageSize)
   {
       // Apply Skip/Take in the database query
       // Only return the data needed for the current page
   }
   ```

### 7. Use Bulk Operations

1. Implement methods for bulk insert, update, and delete operations:
   ```csharp
   // TODO: Implement bulk operations
   public async Task BulkInsertProductsAsync(List<Product> products)
   {
       // Use bulk insert techniques
   }
   
   public async Task BulkUpdateProductsAsync(List<Product> products)
   {
       // Use bulk update techniques
   }
   ```

### 8. Benchmark Different Approaches

1. Create benchmarks to compare the performance of different approaches:
   ```csharp
   [MemoryDiagnoser]
   [Orderer(SummaryOrderPolicy.FastestToSlowest)]
   [RankColumn]
   public class DatabaseQueryBenchmarks
   {
       private AppDbContext _context;
       private IneffientProductService _inefficientService;
       private OptimizedProductService _optimizedService;
       
       [GlobalSetup]
       public void Setup()
       {
           // Set up database context and services
       }
       
       [Benchmark(Baseline = true)]
       public async Task<List<ProductDto>> GetProductsWithCategory_Inefficient()
       {
           return await _inefficientService.GetProductsWithCategoryAsync();
       }
       
       [Benchmark]
       public async Task<List<ProductDto>> GetProductsWithCategory_Optimized()
       {
           return await _optimizedService.GetProductsWithCategoryAsync();
       }
       
       // Add more benchmarks for other scenarios
   }
   ```

## Expected Output

1. All optimized methods should show significant performance improvements.
2. The benchmark results should demonstrate the impact of each optimization technique.
3. The application should handle the same workload with fewer database queries and less memory usage.

## Bonus Tasks

1. Implement a second-level cache for Entity Framework queries.
2. Use database-specific features (like SQL Server's TVPs) for bulk operations.
3. Implement query hints and index usage analysis.
4. Create a monitoring system to track query performance over time.

## Submission

Submit your project with implementations of all optimization techniques, including benchmark results and an analysis of the improvements.

## Evaluation Criteria

- Proper identification and resolution of N+1 query problems
- Effective use of Include and proper join strategies
- Appropriate use of no-tracking queries
- Implementation of compiled queries
- Efficient pagination implementation
- Proper use of bulk operations
- Benchmark results showing performance improvements
- Code quality and organization