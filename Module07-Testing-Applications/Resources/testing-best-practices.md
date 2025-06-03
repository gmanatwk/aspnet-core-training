# ASP.NET Core Testing Best Practices

## Overview

This guide provides a comprehensive set of best practices for testing ASP.NET Core applications. Following these practices will help you create more reliable, maintainable, and effective tests.

## General Testing Principles

### 1. The Testing Pyramid

- **Unit Tests**: 70% - Fast tests that verify individual components in isolation
- **Integration Tests**: 20% - Tests that verify how components work together
- **End-to-End Tests**: 10% - Tests that verify the entire system works together

### 2. Write Testable Code

- Follow SOLID principles
- Use dependency injection
- Keep methods small and focused
- Avoid static methods and global state
- Separate business logic from infrastructure concerns

### 3. Test Organization

- Group tests by feature or component
- Use descriptive test names that explain the scenario being tested
- Follow a consistent naming convention (e.g., `MethodName_Scenario_ExpectedResult`)
- Separate test classes for different components

### 4. Test Independence

- Tests should not depend on other tests
- Each test should set up its own data
- Tests should clean up after themselves
- Avoid sharing state between tests

## Unit Testing Best Practices

### 1. Arrange-Act-Assert Pattern

Structure each test into three distinct sections:

```csharp
[Fact]
public void CalculateTotal_WithValidItems_ReturnsSumOfPrices()
{
    // Arrange
    var items = new List<Item>
    {
        new Item { Price = 10 },
        new Item { Price = 20 }
    };
    var calculator = new PriceCalculator();

    // Act
    var result = calculator.CalculateTotal(items);

    // Assert
    Assert.Equal(30, result);
}
```

### 2. Focus on Behavior, Not Implementation

- Test what a method does, not how it does it
- Verify the end result, not the internal steps
- Don't test private methods directly

### 3. Test Edge Cases

- Empty collections
- Null values
- Boundary conditions
- Invalid inputs
- Maximum values

### 4. Use Mocks Appropriately

- Mock external dependencies, not the system under test
- Verify interactions with dependencies when relevant
- Don't overuse mocks - sometimes a real object is better

### 5. Keep Tests Fast

- Avoid I/O operations in unit tests
- Minimize setup code
- Use in-memory databases for data access tests

## Integration Testing Best Practices

### 1. Use WebApplicationFactory

```csharp
public class ApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public ApiTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task GetProducts_ReturnsSuccessStatusCode()
    {
        // Arrange
        var client = _factory.CreateClient();

        // Act
        var response = await client.GetAsync("/api/products");

        // Assert
        response.EnsureSuccessStatusCode();
    }
}
```

### 2. Use In-Memory Database

Configure a test-specific database for integration tests:

```csharp
protected override void ConfigureWebHost(IWebHostBuilder builder)
{
    builder.ConfigureServices(services =>
    {
        // Remove the app's ApplicationDbContext registration
        var descriptor = services.SingleOrDefault(
            d => d.ServiceType == typeof(DbContextOptions<ApplicationDbContext>));

        if (descriptor != null)
        {
            services.Remove(descriptor);
        }

        // Add ApplicationDbContext using an in-memory database for testing
        services.AddDbContext<ApplicationDbContext>(options =>
        {
            options.UseInMemoryDatabase("InMemoryDbForTesting");
        });
    });
}
```

### 3. Seed Test Data

Populate the database with test data:

```csharp
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var context = services.GetRequiredService<ApplicationDbContext>();
    context.Database.EnsureCreated();
    
    // Add seed data
    context.Products.Add(new Product { Id = 1, Name = "Test Product" });
    context.SaveChanges();
}
```

### 4. Test Complete Request/Response Cycles

Verify the entire API flow:

```csharp
[Fact]
public async Task CreateProduct_WithValidData_ReturnsCreatedResponse()
{
    // Arrange
    var client = _factory.CreateClient();
    var product = new CreateProductDto { Name = "New Product" };

    // Act
    var response = await client.PostAsJsonAsync("/api/products", product);

    // Assert
    response.EnsureSuccessStatusCode();
    Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    
    var createdProduct = await response.Content.ReadFromJsonAsync<ProductDto>();
    Assert.NotNull(createdProduct);
    Assert.Equal("New Product", createdProduct.Name);
}
```

### 5. Test Error Cases

Verify how your API handles errors:

```csharp
[Fact]
public async Task GetProduct_WithInvalidId_ReturnsNotFound()
{
    // Arrange
    var client = _factory.CreateClient();

    // Act
    var response = await client.GetAsync("/api/products/999");

    // Assert
    Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
}
```

## Mocking Best Practices

### 1. Use Interface-Based Design

Design your code with interfaces that can be easily mocked:

```csharp
public interface IProductRepository
{
    Task<Product> GetByIdAsync(int id);
    Task<IEnumerable<Product>> GetAllAsync();
    Task AddAsync(Product product);
}
```

### 2. Focus on Behavior Verification

Verify that methods are called with the expected parameters:

```csharp
[Fact]
public async Task GetProductById_CallsRepository()
{
    // Arrange
    var mockRepo = new Mock<IProductRepository>();
    mockRepo.Setup(repo => repo.GetByIdAsync(1))
        .ReturnsAsync(new Product { Id = 1, Name = "Test" });
    
    var service = new ProductService(mockRepo.Object);
    
    // Act
    await service.GetProductByIdAsync(1);
    
    // Assert
    mockRepo.Verify(repo => repo.GetByIdAsync(1), Times.Once);
}
```

### 3. Setup Only What You Need

Only mock the methods that will be called:

```csharp
// Good - only set up what you need
mockRepo.Setup(repo => repo.GetByIdAsync(1))
    .ReturnsAsync(new Product { Id = 1, Name = "Test" });

// Avoid - setting up unnecessary methods
mockRepo.Setup(repo => repo.GetAllAsync())
    .ReturnsAsync(new List<Product>());
```

### 4. Use Strict Mocks for Critical Dependencies

```csharp
var strictMock = new Mock<IPaymentProcessor>(MockBehavior.Strict);
strictMock.Setup(p => p.ProcessPayment(It.IsAny<decimal>()))
    .Returns(true);
```

### 5. Use Argument Matchers Appropriately

```csharp
// Match any integer
mockRepo.Setup(repo => repo.GetByIdAsync(It.IsAny<int>()))
    .ReturnsAsync(new Product());

// Match a specific range
mockRepo.Setup(repo => repo.GetByIdAsync(It.Is<int>(id => id > 0 && id < 100)))
    .ReturnsAsync(new Product());
```

## Performance Testing Best Practices

### 1. Use BenchmarkDotNet

```csharp
[Benchmark]
public void SortList_WithLINQ()
{
    var sorted = _items.OrderBy(i => i.Name).ToList();
}

[Benchmark]
public void SortList_WithComparison()
{
    var list = new List<Item>(_items);
    list.Sort((a, b) => string.Compare(a.Name, b.Name));
}
```

### 2. Test Different Input Sizes

```csharp
[Params(100, 1000, 10000)]
public int N;

[GlobalSetup]
public void Setup()
{
    _items = new List<Item>(N);
    for (int i = 0; i < N; i++)
    {
        _items.Add(new Item { Name = $"Item {i}" });
    }
}
```

### 3. Include Memory Metrics

```csharp
[MemoryDiagnoser]
public class StringConcatenationBenchmark
{
    [Benchmark]
    public string ConcatenateWithPlus()
    {
        var result = "";
        for (int i = 0; i < 1000; i++)
        {
            result += i.ToString();
        }
        return result;
    }

    [Benchmark]
    public string ConcatenateWithStringBuilder()
    {
        var sb = new StringBuilder();
        for (int i = 0; i < 1000; i++)
        {
            sb.Append(i);
        }
        return sb.ToString();
    }
}
```

### 4. Focus on Critical Paths

Identify and benchmark performance-critical code paths:
- Database queries
- Complex calculations
- Data serialization/deserialization
- API request handling

### 5. Compare Algorithms

```csharp
[Benchmark]
public int FindItemLinear()
{
    for (int i = 0; i < _items.Count; i++)
    {
        if (_items[i].Id == _targetId)
            return i;
    }
    return -1;
}

[Benchmark]
public int FindItemDictionary()
{
    return _itemsDict.TryGetValue(_targetId, out var item) ? item : -1;
}
```

## Test Maintainability

### 1. Use Test Helpers and Fixtures

Create reusable test helpers:

```csharp
public class TestDataFixture
{
    public List<Product> GetTestProducts() => new List<Product>
    {
        new Product { Id = 1, Name = "Product 1" },
        new Product { Id = 2, Name = "Product 2" }
    };
}
```

### 2. Use Theory Tests for Similar Test Cases

```csharp
[Theory]
[InlineData("", false)]
[InlineData("a", false)]
[InlineData("ab", false)]
[InlineData("abc", true)]
[InlineData("abcd", true)]
public void IsValidPassword_ReturnsExpectedResult(string password, bool expected)
{
    var validator = new PasswordValidator();
    var result = validator.IsValid(password);
    Assert.Equal(expected, result);
}
```

### 3. Use FluentAssertions for Readability

```csharp
// Standard assertions
Assert.NotNull(result);
Assert.Equal(3, result.Count);
Assert.Contains(result, i => i.Name == "Item 1");

// With FluentAssertions
result.Should().NotBeNull();
result.Should().HaveCount(3);
result.Should().Contain(i => i.Name == "Item 1");
```

### 4. Centralize Test Configuration

Create a base test class for common setup:

```csharp
public abstract class TestBase
{
    protected readonly DbContextOptions<ApplicationDbContext> ContextOptions;

    protected TestBase()
    {
        ContextOptions = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
    }

    protected ApplicationDbContext CreateContext()
    {
        var context = new ApplicationDbContext(ContextOptions);
        context.Database.EnsureCreated();
        return context;
    }
}
```

## Continuous Integration

### 1. Run Tests on Every Build

Configure your CI pipeline to run tests on every build:
- Unit tests on every commit
- Integration tests on pull requests
- Performance tests on a schedule

### 2. Monitor Test Performance

- Track test execution time
- Alert on slow tests
- Refactor slow tests

### 3. Measure Code Coverage

Use tools like Coverlet to measure code coverage:

```xml
<PackageReference Include="coverlet.collector" Version="3.1.0">
  <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
  <PrivateAssets>all</PrivateAssets>
</PackageReference>
```

### 4. Set Quality Gates

Establish minimum quality gates:
- Minimum code coverage (e.g., 80%)
- Maximum test execution time
- Zero failing tests

## Conclusion

Effective testing is an essential part of software development. By following these best practices, you can create a robust test suite that gives you confidence in your code, enables refactoring, and improves the overall quality of your ASP.NET Core applications.