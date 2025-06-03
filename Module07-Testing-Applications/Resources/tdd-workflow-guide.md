# Test-Driven Development (TDD) Workflow Guide for ASP.NET Core

## Introduction

Test-Driven Development (TDD) is a development approach where you write tests before implementing the actual code. This guide will help you understand the TDD workflow and how to apply it effectively in ASP.NET Core projects.

## The TDD Cycle

TDD follows a simple but powerful cycle often referred to as "Red-Green-Refactor":

1. **Red**: Write a failing test that defines the functionality you want to implement
2. **Green**: Write the minimal code needed to make the test pass
3. **Refactor**: Improve the code while ensuring the tests continue to pass

![TDD Cycle](https://upload.wikimedia.org/wikipedia/commons/0/0b/TDD_Global_Lifecycle.png)

## Getting Started with TDD in ASP.NET Core

### Prerequisites

1. Install the necessary NuGet packages:
   - `Microsoft.NET.Test.Sdk`
   - `xunit` (or another test framework like NUnit, MSTest)
   - `xunit.runner.visualstudio`
   - `Moq` (for mocking dependencies)
   - `FluentAssertions` (for more readable assertions)

2. Create a test project for your solution:
   ```
   dotnet new xunit -n YourProject.Tests
   ```

3. Add a reference to your main project:
   ```
   dotnet add YourProject.Tests/YourProject.Tests.csproj reference YourProject/YourProject.csproj
   ```

### Step-by-Step TDD Example

Let's walk through implementing a product service using TDD:

#### 1. Write a Failing Test

Start by writing a test for the functionality you want to implement:

```csharp
public class ProductServiceTests
{
    [Fact]
    public async Task GetProductByIdAsync_ExistingProduct_ReturnsProduct()
    {
        // Arrange
        var mockRepository = new Mock<IProductRepository>();
        var expectedProduct = new Product { Id = 1, Name = "Test Product", Price = 19.99m };
        
        mockRepository.Setup(repo => repo.GetByIdAsync(1))
            .ReturnsAsync(expectedProduct);
            
        var service = new ProductService(mockRepository.Object);
        
        // Act
        var result = await service.GetProductByIdAsync(1);
        
        // Assert
        result.Should().NotBeNull();
        result.Id.Should().Be(1);
        result.Name.Should().Be("Test Product");
        result.Price.Should().Be(19.99m);
    }
}
```

Running this test will fail because `ProductService` doesn't exist yet.

#### 2. Write the Minimal Implementation

Create the `ProductService` class with just enough code to make the test pass:

```csharp
public class ProductService
{
    private readonly IProductRepository _repository;
    
    public ProductService(IProductRepository repository)
    {
        _repository = repository;
    }
    
    public async Task<Product> GetProductByIdAsync(int id)
    {
        return await _repository.GetByIdAsync(id);
    }
}
```

Now the test should pass.

#### 3. Refactor (if needed)

In this case, there's not much to refactor. In more complex scenarios, you might:
- Extract methods
- Improve naming
- Optimize code
- Add error handling

#### 4. Write Another Test

Add a test for the scenario where the product doesn't exist:

```csharp
[Fact]
public async Task GetProductByIdAsync_NonExistentProduct_ReturnsNull()
{
    // Arrange
    var mockRepository = new Mock<IProductRepository>();
    
    mockRepository.Setup(repo => repo.GetByIdAsync(999))
        .ReturnsAsync((Product)null);
        
    var service = new ProductService(mockRepository.Object);
    
    // Act
    var result = await service.GetProductByIdAsync(999);
    
    // Assert
    result.Should().BeNull();
}
```

This test should pass without any changes to the implementation.

#### 5. Continue Adding Tests and Implementation

Continue the cycle for new functionality:

```csharp
[Fact]
public async Task GetAllProductsAsync_ReturnsAllProducts()
{
    // Arrange
    var mockRepository = new Mock<IProductRepository>();
    var products = new List<Product>
    {
        new Product { Id = 1, Name = "Product 1", Price = 10.99m },
        new Product { Id = 2, Name = "Product 2", Price = 20.99m }
    };
    
    mockRepository.Setup(repo => repo.GetAllAsync())
        .ReturnsAsync(products);
        
    var service = new ProductService(mockRepository.Object);
    
    // Act
    var result = await service.GetAllProductsAsync();
    
    // Assert
    result.Should().NotBeNull();
    result.Should().HaveCount(2);
    result.Should().ContainEquivalentOf(new { Id = 1, Name = "Product 1" });
    result.Should().ContainEquivalentOf(new { Id = 2, Name = "Product 2" });
}
```

This test will fail because we haven't implemented `GetAllProductsAsync()` yet.

Let's implement it:

```csharp
public async Task<IEnumerable<Product>> GetAllProductsAsync()
{
    return await _repository.GetAllAsync();
}
```

Now the test should pass.

## TDD Best Practices for ASP.NET Core

### 1. Start with the Interface

Define interfaces before implementation:

```csharp
public interface IProductService
{
    Task<Product> GetProductByIdAsync(int id);
    Task<IEnumerable<Product>> GetAllProductsAsync();
    Task<Product> CreateProductAsync(Product product);
    Task<bool> UpdateProductAsync(Product product);
    Task<bool> DeleteProductAsync(int id);
}
```

This helps you think about the API design before implementation.

### 2. Test Edge Cases and Error Scenarios

Don't just test the happy path:

```csharp
[Fact]
public async Task CreateProductAsync_NullProduct_ThrowsArgumentNullException()
{
    // Arrange
    var mockRepository = new Mock<IProductRepository>();
    var service = new ProductService(mockRepository.Object);
    
    // Act & Assert
    await Assert.ThrowsAsync<ArgumentNullException>(() => 
        service.CreateProductAsync(null));
}
```

Implementation:

```csharp
public async Task<Product> CreateProductAsync(Product product)
{
    if (product == null)
        throw new ArgumentNullException(nameof(product));
        
    // Add validation, etc.
    
    return await _repository.AddAsync(product);
}
```

### 3. Use Theory Tests for Multiple Test Cases

```csharp
[Theory]
[InlineData("", "Name is required")]
[InlineData("A", "Name must be at least 3 characters")]
[InlineData("AB", "Name must be at least 3 characters")]
[InlineData("Valid Name", null)] // No error
public void ValidateProduct_ReturnsExpectedError(string name, string expectedError)
{
    // Arrange
    var product = new Product { Name = name };
    var service = new ProductService(Mock.Of<IProductRepository>());
    
    // Act
    var error = service.ValidateProduct(product);
    
    // Assert
    Assert.Equal(expectedError, error);
}
```

### 4. Test Controllers with WebApplicationFactory

For ASP.NET Core controllers:

```csharp
public class ProductsApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    
    public ProductsApiTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                // Configure test services here
                var mockRepository = new Mock<IProductRepository>();
                mockRepository.Setup(r => r.GetAllAsync())
                    .ReturnsAsync(new List<Product>
                    {
                        new Product { Id = 1, Name = "Test Product" }
                    });
                
                services.AddScoped<IProductRepository>(sp => mockRepository.Object);
            });
        });
    }
    
    [Fact]
    public async Task GetProducts_ReturnsSuccessAndProducts()
    {
        // Arrange
        var client = _factory.CreateClient();
        
        // Act
        var response = await client.GetAsync("/api/products");
        
        // Assert
        response.EnsureSuccessStatusCode();
        var products = await response.Content.ReadFromJsonAsync<List<Product>>();
        products.Should().HaveCount(1);
        products[0].Name.Should().Be("Test Product");
    }
}
```

### 5. Use Test Data Builders

Create builders for complex test objects:

```csharp
public class ProductBuilder
{
    private readonly Product _product = new Product
    {
        Id = 1,
        Name = "Default Product",
        Price = 19.99m,
        Description = "Default description",
        InStock = true
    };
    
    public ProductBuilder WithId(int id)
    {
        _product.Id = id;
        return this;
    }
    
    public ProductBuilder WithName(string name)
    {
        _product.Name = name;
        return this;
    }
    
    public ProductBuilder WithPrice(decimal price)
    {
        _product.Price = price;
        return this;
    }
    
    public ProductBuilder OutOfStock()
    {
        _product.InStock = false;
        return this;
    }
    
    public Product Build() => _product;
}

// Usage in tests
var product = new ProductBuilder()
    .WithName("Test Product")
    .WithPrice(29.99m)
    .OutOfStock()
    .Build();
```

## TDD for Different Layers in ASP.NET Core

### Domain and Business Logic

Start with core domain logic:

```csharp
[Fact]
public void Order_CalculateTotal_ReturnsCorrectTotal()
{
    // Arrange
    var order = new Order();
    order.AddItem(new OrderItem { ProductId = 1, Quantity = 2, UnitPrice = 10.00m });
    order.AddItem(new OrderItem { ProductId = 2, Quantity = 1, UnitPrice = 15.00m });
    
    // Act
    var total = order.CalculateTotal();
    
    // Assert
    total.Should().Be(35.00m); // (2 * 10) + (1 * 15)
}
```

### Services

Mock dependencies and focus on business rules:

```csharp
[Fact]
public async Task PlaceOrderAsync_InsufficientStock_ThrowsBusinessException()
{
    // Arrange
    var mockProductRepo = new Mock<IProductRepository>();
    mockProductRepo.Setup(r => r.GetByIdAsync(1))
        .ReturnsAsync(new Product { Id = 1, Stock = 5 });
    
    var service = new OrderService(mockProductRepo.Object, Mock.Of<IOrderRepository>());
    
    var orderDto = new CreateOrderDto
    {
        Items = new[] { new OrderItemDto { ProductId = 1, Quantity = 10 } }
    };
    
    // Act & Assert
    var exception = await Assert.ThrowsAsync<BusinessException>(() => 
        service.PlaceOrderAsync(orderDto));
    
    exception.Message.Should().Contain("insufficient stock");
}
```

### Controllers

Test HTTP responses and model binding:

```csharp
[Fact]
public async Task CreateProduct_InvalidModel_ReturnsBadRequest()
{
    // Arrange
    var mockService = new Mock<IProductService>();
    var controller = new ProductsController(mockService.Object);
    controller.ModelState.AddModelError("Name", "Required");
    
    var product = new CreateProductDto();
    
    // Act
    var result = await controller.Create(product);
    
    // Assert
    var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
    var errors = Assert.IsType<ValidationProblemDetails>(badRequestResult.Value);
    errors.Errors.Should().ContainKey("Name");
}
```

## Advanced TDD Techniques

### Test Doubles Spectrum

Use the right test double for each situation:

1. **Dummy Objects**: Passed but never used
2. **Stubs**: Provide predefined answers to calls
3. **Spies**: Record calls for later verification
4. **Mocks**: Pre-programmed with expectations
5. **Fakes**: Working implementations, but not suitable for production

### State vs. Behavior Verification

- **State verification**: Check the result of the operation
- **Behavior verification**: Check that certain methods were called

```csharp
// State verification
[Fact]
public async Task ArchiveProduct_SetsIsArchivedToTrue()
{
    // Arrange
    var product = new Product { Id = 1, IsArchived = false };
    var mockRepo = new Mock<IProductRepository>();
    mockRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(product);
    
    var service = new ProductService(mockRepo.Object);
    
    // Act
    await service.ArchiveProductAsync(1);
    
    // Assert
    product.IsArchived.Should().BeTrue();
}

// Behavior verification
[Fact]
public async Task ArchiveProduct_CallsUpdateAsyncOnRepository()
{
    // Arrange
    var product = new Product { Id = 1, IsArchived = false };
    var mockRepo = new Mock<IProductRepository>();
    mockRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(product);
    
    var service = new ProductService(mockRepo.Object);
    
    // Act
    await service.ArchiveProductAsync(1);
    
    // Assert
    mockRepo.Verify(r => r.UpdateAsync(product), Times.Once);
}
```

### Outside-In TDD (a.k.a. "London School")

Start from the outside and work inward:

1. Write a failing acceptance test (e.g., controller integration test)
2. Implement the controller, mocking the service
3. Write a failing service test
4. Implement the service, mocking the repository
5. Write a failing repository test
6. Implement the repository

### Inside-Out TDD (a.k.a. "Chicago School")

Start from the domain and work outward:

1. Write domain entity tests
2. Implement domain entities
3. Write service tests
4. Implement services
5. Write controller tests
6. Implement controllers

## Common TDD Challenges and Solutions

### Slow Tests

- Use in-memory databases for integration tests
- Mock external dependencies
- Run tests in parallel
- Separate slow tests from fast tests

### Fragile Tests

- Don't test implementation details
- Test behavior, not methods
- Use meaningful assertions
- Avoid over-specification in mocks

### Overuse of Mocks

- Consider using real objects for simple dependencies
- Use integration tests for complex interactions
- Create test-specific implementations of interfaces

### Maintaining Test Data

- Use AutoFixture for generating test data
- Create test data builders
- Use shared fixtures for common data

## Conclusion

TDD is a powerful approach for building reliable software. By writing tests first, you:

1. Focus on requirements and behavior
2. Create naturally testable code
3. Get immediate feedback on your design
4. Build confidence in your codebase
5. Create living documentation

Start small, practice consistently, and you'll soon see the benefits of TDD in your ASP.NET Core projects.