# Exercise 1: Basic EF Core Setup and CRUD Operations

## 🎯 Objective
Set up Entity Framework Core in an ASP.NET Core application and implement basic CRUD operations.

## ⏱️ Time Allocation
**Total Time**: 30 minutes
- Setup and Configuration: 10 minutes
- Entity and DbContext Creation: 10 minutes
- CRUD Operations: 10 minutes

## 🚀 Getting Started

### Step 1: Run Initial Migration
```bash
dotnet ef migrations add InitialCreate
dotnet ef database update
```

### Step 2: Complete the GetBooks method
```csharp
var books = await _context.Books
    .Where(b => b.IsAvailable)
    .OrderBy(b => b.Title)
    .ToListAsync();

return Ok(books);
```

### Step 3: Complete the GetBook method
```csharp
var book = await _context.Books.FindAsync(id);

if (book == null)
{
    return NotFound($"Book with ID {id} not found");
}

return Ok(book);
```

### Step 4: Complete the CreateBook method
```csharp
// Check if ISBN already exists
var existingBook = await _context.Books
    .FirstOrDefaultAsync(b => b.ISBN == book.ISBN);

if (existingBook != null)
{
    return Conflict($"Book with ISBN {book.ISBN} already exists");
}

_context.Books.Add(book);
await _context.SaveChangesAsync();

return CreatedAtAction(nameof(GetBook), new { id = book.Id }, book);
```

## 🧪 Testing Your Implementation
1. Run: `dotnet run`
2. Navigate to: http://localhost:5000/swagger
3. Test each endpoint with sample data

## ✅ Success Criteria
- [ ] Entity Framework Core is properly configured
- [ ] Book entity is created with validation
- [ ] DbContext is configured with Fluent API
- [ ] Database is created with seed data
- [ ] All CRUD endpoints are working
- [ ] Proper error handling is implemented

## 🔄 Next Steps
After completing this exercise, move on to Exercise 2 for advanced querying techniques.

