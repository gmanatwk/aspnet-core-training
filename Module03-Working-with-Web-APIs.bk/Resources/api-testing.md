# API Testing Strategies Guide

## Overview

API testing is crucial for ensuring your Web APIs function correctly, perform well, and handle errors gracefully. This guide covers various testing strategies, tools, and best practices.

## Types of API Testing

### 1. 🧪 Unit Testing
Tests individual components in isolation.

**What to test:**
- Controller actions
- Service methods
- Data validation
- Business logic

**Example:**
```csharp
[Test]
public async Task GetProduct_ValidId_ReturnsProduct()
{
    // Arrange
    var mockService = new Mock<IProductService>();
    var expectedProduct = new ProductDto { Id = 1, Name = "Test" };
    mockService.Setup(s => s.GetByIdAsync(1))
               .ReturnsAsync(expectedProduct);
    
    var controller = new ProductsController(mockService.Object);
    
    // Act
    var result = await controller.GetProduct(1);
    
    // Assert
    var okResult = result.Result as OkObjectResult;
    Assert.NotNull(okResult);
    Assert.AreEqual(200, okResult.StatusCode);
    Assert.AreEqual(expectedProduct, okResult.Value);
}
```

### 2. 🔗 Integration Testing
Tests how different components work together.

**What to test:**
- Complete request/response cycle
- Database interactions
- Authentication/Authorization
- Middleware behavior

**Example:**
```csharp
public class ProductsIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public ProductsIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = _factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                // Replace real database with in-memory
                var descriptor = services.SingleOrDefault(
                    d => d.ServiceType == typeof(DbContextOptions<AppDbContext>));
                
                services.Remove(descriptor);
                services.AddDbContext<AppDbContext>(options =>
                {
                    options.UseInMemoryDatabase("TestDb");
                });
            });
        }).CreateClient();
    }

    [Test]
    public async Task CreateProduct_ValidData_Returns201()
    {
        // Arrange
        var product = new CreateProductDto 
        { 
            Name = "Test Product",
            Price = 99.99m,
            Category = "Electronics"
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/products", product);

        // Assert
        Assert.AreEqual(HttpStatusCode.Created, response.StatusCode);
        
        var createdProduct = await response.Content.ReadFromJsonAsync<ProductDto>();
        Assert.NotNull(createdProduct);
        Assert.AreEqual(product.Name, createdProduct.Name);
    }
}
```

### 3. 📊 Contract Testing
Ensures API contracts (request/response formats) remain consistent.

**Tools:**
- Pact
- Spring Cloud Contract
- OpenAPI/Swagger validation

**Example using Pact:**
```csharp
[Test]
public void ProductApi_GetProduct_ReturnsExpectedFormat()
{
    var pact = new PactBuilder()
        .UponReceiving("a request for a product")
        .Given("product with ID 1 exists")
        .WithRequest(HttpMethod.Get, "/api/products/1")
        .WillRespond()
        .WithStatus(200)
        .WithHeader("Content-Type", "application/json")
        .WithBody(new
        {
            id = 1,
            name = Match.Type("Sample Product"),
            price = Match.Decimal(99.99),
            category = Match.Type("Electronics")
        });

    // Verify contract
    pact.Verify();
}
```

### 4. 🚀 Performance Testing
Measures API performance under various loads.

**What to test:**
- Response times
- Throughput
- Resource usage
- Scalability

**Example using NBomber:**
```csharp
var scenario = Scenario.Create("load_test_products_api", async context =>
{
    var request = Http.CreateRequest("GET", "https://localhost:5001/api/products")
        .WithHeader("Accept", "application/json");

    var response = await Http.Send(request, context);
    
    return response;
})
.WithLoadSimulations(
    Simulation.InjectPerSec(rate: 100, during: TimeSpan.FromSeconds(30))
);

NBomberRunner
    .RegisterScenarios(scenario)
    .Run();
```

### 5. 🔒 Security Testing
Ensures APIs are secure against common vulnerabilities.

**What to test:**
- Authentication/Authorization
- Input validation
- SQL injection
- XSS attacks
- Rate limiting

**Example security tests:**
```csharp
[Test]
public async Task SecureEndpoint_NoToken_Returns401()
{
    var response = await _client.GetAsync("/api/secure/data");
    Assert.AreEqual(HttpStatusCode.Unauthorized, response.StatusCode);
}

[Test]
public async Task SecureEndpoint_InvalidToken_Returns401()
{
    _client.DefaultRequestHeaders.Authorization = 
        new AuthenticationHeaderValue("Bearer", "invalid-token");
    
    var response = await _client.GetAsync("/api/secure/data");
    Assert.AreEqual(HttpStatusCode.Unauthorized, response.StatusCode);
}

[Test]
public async Task AdminEndpoint_UserToken_Returns403()
{
    var userToken = await GetUserToken();
    _client.DefaultRequestHeaders.Authorization = 
        new AuthenticationHeaderValue("Bearer", userToken);
    
    var response = await _client.DeleteAsync("/api/products/1");
    Assert.AreEqual(HttpStatusCode.Forbidden, response.StatusCode);
}
```

## Testing Tools Comparison

### GUI-Based Tools

| Tool | Pros | Cons | Best For |
|------|------|------|----------|
| **Postman** | - User-friendly<br>- Collection sharing<br>- Environment variables<br>- Test scripts | - Not version control friendly<br>- Limited CI/CD integration | Manual testing, Team collaboration |
| **Insomnia** | - Clean interface<br>- GraphQL support<br>- Plugin system | - Smaller community<br>- Fewer features than Postman | Simple API testing, GraphQL |
| **SoapUI** | - Comprehensive testing<br>- SOAP support<br>- Load testing | - Heavy/slow<br>- Complex interface | Enterprise testing, SOAP APIs |

### Command-Line Tools

| Tool | Pros | Cons | Best For |
|------|------|------|----------|
| **curl** | - Ubiquitous<br>- Scriptable<br>- Lightweight | - Verbose syntax<br>- Limited formatting | Quick tests, Scripts |
| **HTTPie** | - Human-friendly<br>- JSON support<br>- Colored output | - Requires installation<br>- Slower than curl | Interactive testing |
| **REST Client (VS Code)** | - In-editor testing<br>- Version control friendly<br>- Variable support | - VS Code only<br>- Limited features | Development testing |

### Code-Based Testing

| Framework | Language | Best For |
|-----------|----------|----------|
| **xUnit/NUnit/MSTest** | C# | Unit & Integration tests |
| **RestSharp** | C# | API client testing |
| **WireMock.Net** | C# | Mock server testing |
| **Benchmark.NET** | C# | Performance testing |
| **NBomber** | C# | Load testing |

## Testing Best Practices

### 1. Test Organization
```
Tests/
├── Unit/
│   ├── Controllers/
│   ├── Services/
│   └── Validators/
├── Integration/
│   ├── ApiTests/
│   └── DatabaseTests/
├── Performance/
│   └── LoadTests/
└── Fixtures/
    └── TestData/
```

### 2. Test Data Management

**Use builders for test data:**
```csharp
public class ProductBuilder
{
    private string _name = "Default Product";
    private decimal _price = 99.99m;
    private string _category = "General";

    public ProductBuilder WithName(string name)
    {
        _name = name;
        return this;
    }

    public ProductBuilder WithPrice(decimal price)
    {
        _price = price;
        return this;
    }

    public Product Build()
    {
        return new Product
        {
            Name = _name,
            Price = _price,
            Category = _category
        };
    }
}

// Usage
var product = new ProductBuilder()
    .WithName("Gaming Laptop")
    .WithPrice(1299.99m)
    .Build();
```

### 3. Test Isolation

**Reset state between tests:**
```csharp
public class ApiTestBase : IDisposable
{
    protected HttpClient Client { get; }
    protected AppDbContext DbContext { get; }

    public ApiTestBase()
    {
        var factory = new WebApplicationFactory<Program>();
        Client = factory.CreateClient();
        
        var scope = factory.Services.CreateScope();
        DbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        
        // Ensure clean database
        DbContext.Database.EnsureDeleted();
        DbContext.Database.EnsureCreated();
    }

    public void Dispose()
    {
        DbContext?.Dispose();
        Client?.Dispose();
    }
}
```

### 4. Assertion Patterns

**Use fluent assertions:**
```csharp
// Using FluentAssertions
response.StatusCode.Should().Be(HttpStatusCode.OK);
products.Should().HaveCount(5);
product.Name.Should().StartWith("Product");
product.Price.Should().BeInRange(10, 1000);

// Custom assertions
public static class ApiAssertions
{
    public static async Task ShouldReturnOk<T>(
        this HttpResponseMessage response)
    {
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var content = await response.Content.ReadAsStringAsync();
        content.Should().NotBeNullOrEmpty();
    }
}
```

## API Testing Checklist

### ✅ Functional Testing
- [ ] All endpoints return expected status codes
- [ ] Response formats match specifications
- [ ] Required fields are validated
- [ ] Optional parameters work correctly
- [ ] Error responses are meaningful

### ✅ Security Testing
- [ ] Authentication is required where expected
- [ ] Authorization rules are enforced
- [ ] Input validation prevents injection attacks
- [ ] Sensitive data is not exposed
- [ ] Rate limiting is effective

### ✅ Performance Testing
- [ ] Response times meet SLAs
- [ ] API handles expected load
- [ ] No memory leaks under sustained load
- [ ] Database queries are optimized
- [ ] Caching works effectively

### ✅ Integration Testing
- [ ] Database operations work correctly
- [ ] External service calls are handled
- [ ] Message queues integrate properly
- [ ] File uploads/downloads work
- [ ] Webhooks fire correctly

## Automated Testing Pipeline

```yaml
# Example GitHub Actions workflow
name: API Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v1
      with:
        dotnet-version: 8.0.x
    
    - name: Restore dependencies
      run: dotnet restore
    
    - name: Build
      run: dotnet build --no-restore
    
    - name: Unit Tests
      run: dotnet test --no-build --filter Category=Unit
    
    - name: Integration Tests
      run: dotnet test --no-build --filter Category=Integration
    
    - name: Contract Tests
      run: dotnet test --no-build --filter Category=Contract
    
    - name: Performance Tests
      run: dotnet test --no-build --filter Category=Performance
      
    - name: Generate Coverage Report
      run: |
        dotnet test --collect:"XPlat Code Coverage"
        dotnet tool install -g dotnet-reportgenerator-globaltool
        reportgenerator -reports:**/coverage.cobertura.xml -targetdir:coverage
    
    - name: Upload Coverage
      uses: codecov/codecov-action@v1
```

## Common Testing Patterns

### 1. Arrange-Act-Assert (AAA)
```csharp
[Test]
public async Task GetProducts_ReturnsAllProducts()
{
    // Arrange
    await SeedDatabase();
    
    // Act
    var response = await Client.GetAsync("/api/products");
    var products = await response.Content.ReadFromJsonAsync<List<ProductDto>>();
    
    // Assert
    response.StatusCode.Should().Be(HttpStatusCode.OK);
    products.Should().HaveCount(5);
}
```

### 2. Given-When-Then (BDD)
```csharp
[Test]
public async Task Product_creation_scenario()
{
    // Given a valid product
    var product = new CreateProductDto { Name = "New Product", Price = 50 };
    
    // When the product is created
    var response = await Client.PostAsJsonAsync("/api/products", product);
    
    // Then it should be saved successfully
    response.StatusCode.Should().Be(HttpStatusCode.Created);
    var created = await response.Content.ReadFromJsonAsync<ProductDto>();
    created.Name.Should().Be(product.Name);
}
```

### 3. Test Data Builders
```csharp
public class ApiTestDataBuilder
{
    private readonly HttpClient _client;
    
    public async Task<string> CreateTestUser(string role = "User")
    {
        var user = new RegisterDto 
        { 
            Email = $"test-{Guid.NewGuid()}@example.com",
            Password = "Test123!"
        };
        
        var response = await _client.PostAsJsonAsync("/api/auth/register", user);
        var token = await response.Content.ReadFromJsonAsync<TokenResponse>();
        
        return token.AccessToken;
    }
}
```

## Debugging Failed Tests

### 1. Capture Request/Response
```csharp
public class LoggingHandler : DelegatingHandler
{
    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, 
        CancellationToken cancellationToken)
    {
        Console.WriteLine($"Request: {request.Method} {request.RequestUri}");
        if (request.Content != null)
        {
            var content = await request.Content.ReadAsStringAsync();
            Console.WriteLine($"Content: {content}");
        }
        
        var response = await base.SendAsync(request, cancellationToken);
        
        Console.WriteLine($"Response: {response.StatusCode}");
        var responseContent = await response.Content.ReadAsStringAsync();
        Console.WriteLine($"Content: {responseContent}");
        
        return response;
    }
}
```

### 2. Test Output
```csharp
public class ApiTests
{
    private readonly ITestOutputHelper _output;
    
    public ApiTests(ITestOutputHelper output)
    {
        _output = output;
    }
    
    [Fact]
    public async Task DebugTest()
    {
        _output.WriteLine("Starting test...");
        
        var response = await Client.GetAsync("/api/products");
        _output.WriteLine($"Status: {response.StatusCode}");
        
        var content = await response.Content.ReadAsStringAsync();
        _output.WriteLine($"Response: {content}");
    }
}
```

## Resources

- [ASP.NET Core Testing Documentation](https://docs.microsoft.com/aspnet/core/test/)
- [REST API Testing with Postman](https://learning.postman.com/docs/writing-scripts/test-scripts/)
- [Martin Fowler on Testing](https://martinfowler.com/testing/)
- [API Testing Best Practices](https://swagger.io/resources/articles/best-practices-in-api-testing/)

---

Remember: Good API tests are fast, isolated, repeatable, and provide clear feedback when they fail.