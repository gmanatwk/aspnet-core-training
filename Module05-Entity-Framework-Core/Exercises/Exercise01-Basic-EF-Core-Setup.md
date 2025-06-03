# Exercise 1: Basic EF Core Setup and CRUD Operations

## 🎯 Objective
Set up Entity Framework Core in an ASP.NET Core application and implement basic CRUD operations for a simple entity.

## ⏱️ Time Allocation
**Total Time**: 30 minutes
- Setup and Configuration: 10 minutes
- Entity and DbContext Creation: 10 minutes
- CRUD Operations: 10 minutes

## 📋 Requirements

### Part A: Project Setup (10 minutes)
1. Create a new ASP.NET Core Web API project named `BookStoreAPI`
2. Install the following NuGet packages:
   - `Microsoft.EntityFrameworkCore.SqlServer`
   - `Microsoft.EntityFrameworkCore.Tools`
   - `Microsoft.EntityFrameworkCore.Design`
3. Configure connection string in `appsettings.json`

### Part B: Entity and DbContext (10 minutes)
1. Create a `Book` entity with the following properties:
   - `Id` (int, primary key)
   - `Title` (string, required, max 200 characters)
   - `Author` (string, required, max 100 characters)
   - `ISBN` (string, required, max 20 characters, unique)
   - `Price` (decimal)
   - `PublishedDate` (DateTime)
   - `IsAvailable` (bool, default true)

2. Create a `BookStoreContext` that inherits from `DbContext`
3. Configure the entity using Fluent API
4. Add seed data for 3 books

### Part C: CRUD Controller (10 minutes)
1. Create a `BooksController` with the following endpoints:
   - `GET /api/books` - Get all books
   - `GET /api/books/{id}` - Get book by ID
   - `POST /api/books` - Create new book
   - `PUT /api/books/{id}` - Update book
   - `DELETE /api/books/{id}` - Delete book

## 🚀 Getting Started

### Step 1: Create the Book Entity
```csharp
// Models/Book.cs
public class Book
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Author { get; set; } = string.Empty;
    public string ISBN { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public DateTime PublishedDate { get; set; }
    public bool IsAvailable { get; set; } = true;
}
```

### Step 2: Create the DbContext
```csharp
// Data/BookStoreContext.cs
public class BookStoreContext : DbContext
{
    public BookStoreContext(DbContextOptions<BookStoreContext> options) : base(options)
    {
    }

    public DbSet<Book> Books { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // Configure Book entity
        modelBuilder.Entity<Book>(entity =>
        {
            // TODO: Add your configuration here
        });
        
        // Seed data
        // TODO: Add seed data
    }
}
```

### Step 3: Configure Services in Program.cs
```csharp
// Add Entity Framework
builder.Services.AddDbContext<BookStoreContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
```

## ✅ Success Criteria
- [ ] Entity Framework Core is properly configured
- [ ] Book entity is created with all required properties
- [ ] DbContext is configured with Fluent API
- [ ] Database is created with seed data
- [ ] All CRUD endpoints are working
- [ ] Data validation is implemented
- [ ] Proper error handling is in place

## 🔧 Testing Your Implementation

### Test the API endpoints using Swagger or curl:

1. **Get all books**:
   ```bash
   GET /api/books
   ```

2. **Create a new book**:
   ```bash
   POST /api/books
   Content-Type: application/json
   
   {
     "title": "C# Programming Guide",
     "author": "John Doe",
     "isbn": "978-1234567890",
     "price": 29.99,
     "publishedDate": "2024-01-15"
   }
   ```

3. **Update a book**:
   ```bash
   PUT /api/books/1
   Content-Type: application/json
   
   {
     "title": "Advanced C# Programming",
     "author": "John Doe",
     "isbn": "978-1234567890",
     "price": 39.99,
     "publishedDate": "2024-01-15",
     "isAvailable": true
   }
   ```

4. **Delete a book**:
   ```bash
   DELETE /api/books/1
   ```

## 💡 Bonus Challenges
If you complete the basic requirements early:

1. **Add data validation attributes** to the Book entity
2. **Implement search functionality** - search books by title or author
3. **Add filtering** - filter books by availability or price range
4. **Implement pagination** for the get all books endpoint
5. **Add logging** to track database operations

## 🎯 Learning Outcomes
After completing this exercise, you should understand:
- How to set up Entity Framework Core in ASP.NET Core
- Entity configuration using data annotations and Fluent API
- Creating and configuring DbContext
- Implementing basic CRUD operations
- Database seeding strategies
- Handling database connections and migrations

## ❓ Common Issues and Solutions

### Issue 1: Migration Errors
**Problem**: Entity Framework migrations fail
**Solution**: Ensure connection string is correct and SQL Server is running

### Issue 2: Unique Constraint Violations
**Problem**: ISBN uniqueness constraint violations
**Solution**: Check seed data for duplicate ISBN values

### Issue 3: Null Reference Exceptions
**Problem**: DbSet properties are null
**Solution**: Ensure DbContext is properly registered in DI container

---

**Next**: Proceed to Exercise 2 for advanced querying techniques!
