#!/bin/bash

# Test Module 05 Exercise 1 implementation

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0

echo -e "${BLUE}🧪 Testing Module 05 Exercise 1 Implementation${NC}"
echo "=============================================="

# Clean up any existing project
rm -rf EFCoreDemo

# Test 1: Setup script
echo -e "${BLUE}1. Testing setup script...${NC}"
if ./setup-exercise.sh module05-exercise01-efcore > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Setup script works${NC}"
else
    echo -e "${RED}❌ Setup script failed${NC}"
    ((ERRORS++))
    exit 1
fi

cd EFCoreDemo

# Test 2: Build after setup
echo -e "${BLUE}2. Testing initial build...${NC}"
if dotnet build > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Project builds after setup${NC}"
else
    echo -e "${RED}❌ Project fails to build after setup${NC}"
    ((ERRORS++))
fi

# Test 3: Add code from Exercise 1
echo -e "${BLUE}3. Adding code from Exercise 1...${NC}"

# Create Models directory and add BookEntities.cs
mkdir -p Models
cat > Models/BookEntities.cs << 'EOF'
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EFCoreDemo.Models;

/// <summary>
/// Book entity for Exercise 01 - Basic EF Core Setup
/// </summary>
public class Book
{
    [Key]
    public int Id { get; set; }

    [Required(ErrorMessage = "Title is required")]
    [StringLength(200, ErrorMessage = "Title cannot exceed 200 characters")]
    public string Title { get; set; } = string.Empty;

    [Required(ErrorMessage = "Author is required")]
    [StringLength(100, ErrorMessage = "Author name cannot exceed 100 characters")]
    public string Author { get; set; } = string.Empty;

    [Required(ErrorMessage = "ISBN is required")]
    [StringLength(20, ErrorMessage = "ISBN cannot exceed 20 characters")]
    public string ISBN { get; set; } = string.Empty;

    [Column(TypeName = "decimal(18,2)")]
    [Range(0.01, 9999.99, ErrorMessage = "Price must be between 0.01 and 9999.99")]
    public decimal Price { get; set; }

    [Required(ErrorMessage = "Published date is required")]
    public DateTime PublishedDate { get; set; }

    public bool IsAvailable { get; set; } = true;

    // Computed property for display
    [NotMapped]
    public string DisplayTitle => $"{Title} by {Author}";
}
EOF

# Create Data directory and add BookStoreContext.cs
mkdir -p Data
cat > Data/BookStoreContext.cs << 'EOF'
using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Models;

namespace EFCoreDemo.Data;

public class BookStoreContext : DbContext
{
    public BookStoreContext(DbContextOptions<BookStoreContext> options) : base(options)
    {
    }

    public DbSet<Book> Books { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // Configure Book entity using Fluent API
        modelBuilder.Entity<Book>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.Property(e => e.Title)
                .IsRequired()
                .HasMaxLength(200);
                
            entity.Property(e => e.Author)
                .IsRequired()
                .HasMaxLength(100);
                
            entity.Property(e => e.ISBN)
                .IsRequired()
                .HasMaxLength(20);
                
            entity.HasIndex(e => e.ISBN)
                .IsUnique()
                .HasDatabaseName("IX_Books_ISBN");
                
            entity.Property(e => e.Price)
                .HasColumnType("decimal(18,2)")
                .IsRequired();
                
            entity.Property(e => e.PublishedDate)
                .IsRequired();
                
            entity.Property(e => e.IsAvailable)
                .HasDefaultValue(true);
        });
        
        // Seed data for Exercise 01
        SeedData(modelBuilder);
    }
    
    private void SeedData(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Book>().HasData(
            new Book
            {
                Id = 1,
                Title = "C# Programming Guide",
                Author = "John Smith",
                ISBN = "978-1234567890",
                Price = 29.99m,
                PublishedDate = new DateTime(2023, 1, 15),
                IsAvailable = true
            },
            new Book
            {
                Id = 2,
                Title = "ASP.NET Core in Action",
                Author = "Jane Doe",
                ISBN = "978-0987654321",
                Price = 39.99m,
                PublishedDate = new DateTime(2023, 3, 20),
                IsAvailable = true
            },
            new Book
            {
                Id = 3,
                Title = "Entity Framework Core Deep Dive",
                Author = "Bob Johnson",
                ISBN = "978-1122334455",
                Price = 45.99m,
                PublishedDate = new DateTime(2023, 6, 10),
                IsAvailable = false
            }
        );
    }
}
EOF

# Update Program.cs
cat > Program.cs << 'EOF'
using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add Entity Framework
builder.Services.AddDbContext<BookStoreContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

// Ensure database is created and seeded
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<BookStoreContext>();
    context.Database.EnsureCreated();
}

app.Run();
EOF

# Create Controllers directory and add BooksController
mkdir -p Controllers
cat > Controllers/BooksController.cs << 'EOF'
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EFCoreDemo.Data;
using EFCoreDemo.Models;

namespace EFCoreDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BooksController : ControllerBase
{
    private readonly BookStoreContext _context;
    private readonly ILogger<BooksController> _logger;

    public BooksController(BookStoreContext context, ILogger<BooksController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Book>>> GetBooks()
    {
        try
        {
            var books = await _context.Books
                .Where(b => b.IsAvailable)
                .OrderBy(b => b.Title)
                .ToListAsync();

            return Ok(books);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving books");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Book>> GetBook(int id)
    {
        try
        {
            var book = await _context.Books.FindAsync(id);

            if (book == null)
            {
                return NotFound($"Book with ID {id} not found");
            }

            return Ok(book);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving book {BookId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPost]
    public async Task<ActionResult<Book>> CreateBook(Book book)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var existingBook = await _context.Books
                .FirstOrDefaultAsync(b => b.ISBN == book.ISBN);

            if (existingBook != null)
            {
                return Conflict($"Book with ISBN '{book.ISBN}' already exists");
            }

            _context.Books.Add(book);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetBook), new { id = book.Id }, book);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating book");
            return StatusCode(500, "Internal server error");
        }
    }
}
EOF

echo -e "${GREEN}✅ Code added from exercise${NC}"

# Test 4: Build with exercise code
echo -e "${BLUE}4. Testing build with exercise code...${NC}"
if dotnet build > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Project builds with exercise code${NC}"
else
    echo -e "${RED}❌ Project fails to build with exercise code${NC}"
    ((ERRORS++))
fi

# Test 5: Test application startup
echo -e "${BLUE}5. Testing application startup...${NC}"
timeout 10s dotnet run --urls="http://localhost:5004" > /dev/null 2>&1 &
APP_PID=$!
sleep 5

# Test endpoints
if curl -s http://localhost:5004/swagger/index.html > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Application starts and Swagger accessible${NC}"
else
    echo -e "${RED}❌ Application failed to start${NC}"
    ((ERRORS++))
fi

# Clean up
kill $APP_PID 2>/dev/null || true
cd ..
rm -rf EFCoreDemo

echo ""
echo "=============================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 Module 05 Exercise 1 test PASSED!${NC}"
    echo -e "${GREEN}✅ Students can successfully complete Exercise 1${NC}"
else
    echo -e "${RED}❌ Module 05 Exercise 1 test FAILED with $ERRORS errors${NC}"
    echo -e "${YELLOW}⚠️  Exercise needs more work${NC}"
fi

exit $ERRORS
