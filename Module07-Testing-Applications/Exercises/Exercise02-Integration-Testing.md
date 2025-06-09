# Exercise 2: Integration Testing

## Objective
Learn to write effective integration tests for ASP.NET Core web APIs using TestServer and WebApplicationFactory.

## Prerequisites
- Visual Studio or Visual Studio Code
- .NET 8 SDK
- xUnit knowledge from the module content
- Understanding of ASP.NET Core API development

## Exercise Description

In this exercise, you will create integration tests for a simple blogging API. The tests will verify that the API endpoints function correctly from end to end, including database operations using Entity Framework Core's in-memory provider.

## Tasks

### 1. Create a Basic Blog API

Create a simple ASP.NET Core Web API project with the following components:

1. A `BlogPost` model:
```csharp
public class BlogPost
{
    public int Id { get; set; }
    public string Title { get; set; }
    public string Content { get; set; }
    public string Author { get; set; }
    public DateTime PublishedDate { get; set; }
    public bool IsPublished { get; set; }
}
```

2. A `BlogDbContext`:
```csharp
public class BlogDbContext : DbContext
{
    public BlogDbContext(DbContextOptions<BlogDbContext> options) : base(options) { }
    
    public DbSet<BlogPost> BlogPosts { get; set; }
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Configure entity
        modelBuilder.Entity<BlogPost>()
            .Property(b => b.Title)
            .IsRequired()
            .HasMaxLength(200);
            
        modelBuilder.Entity<BlogPost>()
            .Property(b => b.Author)
            .IsRequired()
            .HasMaxLength(100);
    }
}
```

3. A `BlogPostsController` with standard CRUD operations:
```csharp
[ApiController]
[Route("api/[controller]")]
public class BlogPostsController : ControllerBase
{
    private readonly BlogDbContext _context;
    
    public BlogPostsController(BlogDbContext context)
    {
        _context = context;
    }
    
    // GET: api/BlogPosts
    [HttpGet]
    public async Task<ActionResult<IEnumerable<BlogPost>>> GetBlogPosts()
    {
        return await _context.BlogPosts.ToListAsync();
    }
    
    // GET: api/BlogPosts/5
    [HttpGet("{id}")]
    public async Task<ActionResult<BlogPost>> GetBlogPost(int id)
    {
        var blogPost = await _context.BlogPosts.FindAsync(id);
        
        if (blogPost == null)
        {
            return NotFound();
        }
        
        return blogPost;
    }
    
    // POST: api/BlogPosts
    [HttpPost]
    public async Task<ActionResult<BlogPost>> CreateBlogPost(BlogPost blogPost)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }
        
        blogPost.PublishedDate = DateTime.UtcNow;
        
        _context.BlogPosts.Add(blogPost);
        await _context.SaveChangesAsync();
        
        return CreatedAtAction(nameof(GetBlogPost), new { id = blogPost.Id }, blogPost);
    }
    
    // PUT: api/BlogPosts/5
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateBlogPost(int id, BlogPost blogPost)
    {
        if (id != blogPost.Id)
        {
            return BadRequest();
        }
        
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }
        
        _context.Entry(blogPost).State = EntityState.Modified;
        
        // Don't modify the original published date
        _context.Entry(blogPost).Property(x => x.PublishedDate).IsModified = false;
        
        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!BlogPostExists(id))
            {
                return NotFound();
            }
            else
            {
                throw;
            }
        }
        
        return NoContent();
    }
    
    // DELETE: api/BlogPosts/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteBlogPost(int id)
    {
        var blogPost = await _context.BlogPosts.FindAsync(id);
        if (blogPost == null)
        {
            return NotFound();
        }
        
        _context.BlogPosts.Remove(blogPost);
        await _context.SaveChangesAsync();
        
        return NoContent();
    }
    
    private bool BlogPostExists(int id)
    {
        return _context.BlogPosts.Any(e => e.Id == id);
    }
}
```

4. Configure the application in `Program.cs`:
```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddDbContext<BlogDbContext>(options =>
{
    // Use SQLite for this exercise (easy to set up, no installation required)
    options.UseSqlite("Data Source=blog.db");
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

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

app.Run();

// Make the implicit Program class public so test projects can access it
public partial class Program { }
```

### 2. Create an Integration Test Project

1. Create a new xUnit test project.
2. Add references to:
   - Your Blog API project
   - `Microsoft.AspNetCore.Mvc.Testing`
   - `Microsoft.EntityFrameworkCore.InMemory`
   - `FluentAssertions`

### 3. Create a Custom WebApplicationFactory

Create a custom `WebApplicationFactory` to configure the test environment:

```csharp
public class CustomWebApplicationFactory<TProgram> : WebApplicationFactory<TProgram> where TProgram : class
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // Find the DbContext registration and replace with test version
            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<BlogDbContext>));
                
            if (descriptor != null)
            {
                services.Remove(descriptor);
            }
            
            // Add in-memory database for testing
            services.AddDbContext<BlogDbContext>(options =>
            {
                options.UseInMemoryDatabase("TestingDb");
            });
            
            // Build the service provider
            var sp = services.BuildServiceProvider();
            
            // Create a scope to get scoped services
            using var scope = sp.CreateScope();
            var scopedServices = scope.ServiceProvider;
            var db = scopedServices.GetRequiredService<BlogDbContext>();
            
            // Ensure database is created and seed with test data
            db.Database.EnsureCreated();
            SeedTestData(db);
        });
    }
    
    private void SeedTestData(BlogDbContext context)
    {
        // Add seed data for tests
        context.BlogPosts.AddRange(
            new BlogPost
            {
                Id = 1,
                Title = "First Test Post",
                Content = "This is the first test post content.",
                Author = "Test Author 1",
                PublishedDate = DateTime.UtcNow.AddDays(-5),
                IsPublished = true
            },
            new BlogPost
            {
                Id = 2,
                Title = "Second Test Post",
                Content = "This is the second test post content.",
                Author = "Test Author 2",
                PublishedDate = DateTime.UtcNow.AddDays(-2),
                IsPublished = true
            },
            new BlogPost
            {
                Id = 3,
                Title = "Draft Post",
                Content = "This is a draft post.",
                Author = "Test Author 1",
                PublishedDate = DateTime.UtcNow.AddDays(-1),
                IsPublished = false
            }
        );
        
        context.SaveChanges();
    }
}
```

### 4. Write Integration Tests

Create tests for each endpoint in the BlogPostsController:

1. Test GET all blog posts:
```csharp
[Fact]
public async Task GetBlogPosts_ReturnsSuccessAndAllPublishedPosts()
{
    // Arrange
    var client = _factory.CreateClient();
    
    // Act
    var response = await client.GetAsync("/api/blogposts");
    
    // Assert
    response.EnsureSuccessStatusCode();
    var returnedPosts = await response.Content.ReadFromJsonAsync<List<BlogPost>>();
    
    Assert.NotNull(returnedPosts);
    Assert.Equal(3, returnedPosts.Count);
}
```

2. Test GET a single blog post:
```csharp
[Fact]
public async Task GetBlogPost_WithValidId_ReturnsPost()
{
    // Arrange
    var client = _factory.CreateClient();
    var validId = 1;
    
    // Act
    var response = await client.GetAsync($"/api/blogposts/{validId}");
    
    // Assert
    response.EnsureSuccessStatusCode();
    var returnedPost = await response.Content.ReadFromJsonAsync<BlogPost>();
    
    Assert.NotNull(returnedPost);
    Assert.Equal(validId, returnedPost.Id);
    Assert.Equal("First Test Post", returnedPost.Title);
}
```

3. Test POST to create a new blog post:
```csharp
[Fact]
public async Task CreateBlogPost_WithValidData_ReturnsCreatedResponse()
{
    // Arrange
    var client = _factory.CreateClient();
    var newPost = new BlogPost
    {
        Title = "New Test Post",
        Content = "This is a new test post created during integration testing.",
        Author = "Integration Tester",
        IsPublished = true
    };
    
    // Act
    var response = await client.PostAsJsonAsync("/api/blogposts", newPost);
    
    // Assert
    response.EnsureSuccessStatusCode();
    Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    
    var returnedPost = await response.Content.ReadFromJsonAsync<BlogPost>();
    Assert.NotNull(returnedPost);
    Assert.Equal(newPost.Title, returnedPost.Title);
    Assert.Equal(newPost.Content, returnedPost.Content);
    Assert.Equal(newPost.Author, returnedPost.Author);
    Assert.True(returnedPost.Id > 0);
}
```

4. Test PUT to update a blog post:
```csharp
[Fact]
public async Task UpdateBlogPost_WithValidData_ReturnsNoContent()
{
    // Arrange
    var client = _factory.CreateClient();
    var postId = 2;
    
    // First, get the existing post
    var getResponse = await client.GetAsync($"/api/blogposts/{postId}");
    getResponse.EnsureSuccessStatusCode();
    var existingPost = await getResponse.Content.ReadFromJsonAsync<BlogPost>();
    
    // Modify the post
    existingPost.Title = "Updated Title";
    existingPost.Content = "Updated content for integration test.";
    
    // Act
    var putResponse = await client.PutAsJsonAsync($"/api/blogposts/{postId}", existingPost);
    
    // Assert
    Assert.Equal(HttpStatusCode.NoContent, putResponse.StatusCode);
    
    // Verify the update was successful by getting the post again
    var verifyResponse = await client.GetAsync($"/api/blogposts/{postId}");
    verifyResponse.EnsureSuccessStatusCode();
    var updatedPost = await verifyResponse.Content.ReadFromJsonAsync<BlogPost>();
    
    Assert.NotNull(updatedPost);
    Assert.Equal("Updated Title", updatedPost.Title);
    Assert.Equal("Updated content for integration test.", updatedPost.Content);
}
```

5. Test DELETE a blog post:
```csharp
[Fact]
public async Task DeleteBlogPost_WithValidId_ReturnsNoContent()
{
    // Arrange
    var client = _factory.CreateClient();
    var postId = 3;
    
    // Act
    var response = await client.DeleteAsync($"/api/blogposts/{postId}");
    
    // Assert
    Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);
    
    // Verify the post was deleted by trying to get it
    var verifyResponse = await client.GetAsync($"/api/blogposts/{postId}");
    Assert.Equal(HttpStatusCode.NotFound, verifyResponse.StatusCode);
}
```

### 5. Test Error Scenarios

Add tests for error scenarios:

1. Test getting a non-existent blog post:
```csharp
[Fact]
public async Task GetBlogPost_WithInvalidId_ReturnsNotFound()
{
    // Arrange
    var client = _factory.CreateClient();
    var invalidId = 999;
    
    // Act
    var response = await client.GetAsync($"/api/blogposts/{invalidId}");
    
    // Assert
    Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
}
```

2. Test creating an invalid blog post:
```csharp
[Fact]
public async Task CreateBlogPost_WithInvalidData_ReturnsBadRequest()
{
    // Arrange
    var client = _factory.CreateClient();
    var invalidPost = new BlogPost
    {
        // Missing required Title and Author
        Content = "This is an invalid post with missing required fields.",
        IsPublished = true
    };
    
    // Act
    var response = await client.PostAsJsonAsync("/api/blogposts", invalidPost);
    
    // Assert
    Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
}
```

### 6. Test with Different Request Headers

Add a test that sends a specific Accept header:

```csharp
[Fact]
public async Task GetBlogPosts_WithJsonAcceptHeader_ReturnsJsonContent()
{
    // Arrange
    var client = _factory.CreateClient();
    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
    
    // Act
    var response = await client.GetAsync("/api/blogposts");
    
    // Assert
    response.EnsureSuccessStatusCode();
    Assert.Equal("application/json", response.Content.Headers.ContentType.MediaType);
}
```

## Expected Output

All tests should pass when run with the `dotnet test` command.

## Bonus Tasks

1. Add authentication and test authenticated endpoints.
2. Implement filters or middleware and test their functionality.
3. Test pagination and filtering capabilities of the API.
4. Implement custom response caching and test it works correctly.

## Submission

Submit your integration test project code, including the WebApplicationFactory and all implemented tests.

## Evaluation Criteria

- Code correctness and test quality
- Proper use of WebApplicationFactory for test setup
- Test coverage of success and error scenarios
- Clean, readable test organization
- Proper assertions and verification of API responses