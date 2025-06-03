# Exercise 1: Unit Testing Basics

## Objective
Learn to write effective unit tests for ASP.NET Core applications using xUnit, focusing on testing individual components in isolation.

## Prerequisites
- Visual Studio or Visual Studio Code
- .NET 8 SDK
- xUnit knowledge from the module content

## Exercise Description

In this exercise, you will create unit tests for a service class that manages products in an e-commerce application. The focus is on writing clean, maintainable tests that follow best practices.

## Tasks

### 1. Create a Test Project

1. Create a new xUnit test project named `ShopApp.Tests`.
2. Add a reference to the main project (or create a simple project to test).
3. Install the following NuGet packages:
   - `Microsoft.NET.Test.Sdk`
   - `xunit`
   - `xunit.runner.visualstudio`
   - `Moq`
   - `FluentAssertions`

### 2. Implement the Service to Test

Create a basic `ProductService` class with the following structure:

```csharp
public class ProductService
{
    private readonly IProductRepository _repository;
    private readonly ILogger<ProductService> _logger;

    public ProductService(IProductRepository repository, ILogger<ProductService> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    public async Task<Product> GetProductByIdAsync(int id)
    {
        var product = await _repository.GetByIdAsync(id);
        if (product == null)
        {
            _logger.LogWarning("Product with ID {ProductId} not found", id);
            throw new NotFoundException($"Product with ID {id} not found");
        }
        return product;
    }

    public async Task<List<Product>> GetAllProductsAsync()
    {
        return await _repository.GetAllAsync();
    }

    public async Task<Product> CreateProductAsync(Product product)
    {
        if (product == null)
        {
            throw new ArgumentNullException(nameof(product));
        }

        if (string.IsNullOrWhiteSpace(product.Name))
        {
            throw new ValidationException("Product name is required");
        }

        if (product.Price <= 0)
        {
            throw new ValidationException("Product price must be greater than zero");
        }

        return await _repository.AddAsync(product);
    }

    public async Task UpdateProductAsync(int id, Product product)
    {
        if (product == null)
        {
            throw new ArgumentNullException(nameof(product));
        }

        var existingProduct = await _repository.GetByIdAsync(id);
        if (existingProduct == null)
        {
            throw new NotFoundException($"Product with ID {id} not found");
        }

        existingProduct.Name = product.Name;
        existingProduct.Description = product.Description;
        existingProduct.Price = product.Price;
        existingProduct.StockQuantity = product.StockQuantity;

        await _repository.UpdateAsync(existingProduct);
    }

    public async Task DeleteProductAsync(int id)
    {
        var product = await _repository.GetByIdAsync(id);
        if (product == null)
        {
            throw new NotFoundException($"Product with ID {id} not found");
        }

        await _repository.DeleteAsync(id);
    }
}
```

Also implement the required interfaces and models:

```csharp
public interface IProductRepository
{
    Task<Product> GetByIdAsync(int id);
    Task<List<Product>> GetAllAsync();
    Task<Product> AddAsync(Product product);
    Task UpdateAsync(Product product);
    Task DeleteAsync(int id);
}

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
}

public class NotFoundException : Exception
{
    public NotFoundException(string message) : base(message) { }
}

public class ValidationException : Exception
{
    public ValidationException(string message) : base(message) { }
}
```

### 3. Write Unit Tests

Create a `ProductServiceTests.cs` file and implement tests for each method in the service:

1. Test `GetProductByIdAsync` with:
   - A valid product ID (should return the product)
   - An invalid product ID (should throw NotFoundException)

2. Test `GetAllProductsAsync` with:
   - Multiple products in the repository
   - Empty repository

3. Test `CreateProductAsync` with:
   - Valid product data
   - Null product (should throw ArgumentNullException)
   - Missing product name (should throw ValidationException)
   - Invalid price (should throw ValidationException)

4. Test `UpdateProductAsync` with:
   - Valid update scenario
   - Non-existent product ID (should throw NotFoundException)
   - Null product (should throw ArgumentNullException)

5. Test `DeleteProductAsync` with:
   - Valid deletion scenario
   - Non-existent product ID (should throw NotFoundException)

### 4. Implement Test Fixtures

1. Create a test fixture to share setup code between tests.
2. Move common setup logic to the fixture constructor.

### 5. Implement Theory Tests with InlineData

1. Convert appropriate tests to Theory tests with InlineData.
2. Test various scenarios for validation logic.

## Expected Output

All tests should pass when run with the `dotnet test` command.

## Bonus Tasks

1. Add test coverage for edge cases.
2. Implement custom xUnit traits to categorize tests.
3. Use AutoFixture to generate test data.
4. Implement class and collection fixtures for more complex setup.

## Submission

Submit your test project code, including all implemented tests.

## Evaluation Criteria

- Code correctness and test quality
- Test coverage of edge cases
- Proper use of mocking and test isolation
- Clean, readable test names following naming conventions
- Proper assertions using FluentAssertions
- Proper organization of test classes and methods