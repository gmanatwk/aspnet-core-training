# Exercise 1: Unit Testing Basics

## 🎯 Objective
Master unit testing fundamentals with xUnit, Moq, and FluentAssertions.

## ⏱️ Time Allocation
**Total Time**: 35 minutes
- Project Setup: 5 minutes
- Writing Basic Tests: 15 minutes
- Advanced Testing Patterns: 15 minutes

## 🚀 Getting Started

### Step 1: Build and Test
```bash
dotnet build
dotnet test
```

### Step 2: Run Tests with Detailed Output
```bash
dotnet test --logger "console;verbosity=detailed"
```

### Step 3: Generate Test Coverage Report
```bash
dotnet test --collect:"XPlat Code Coverage"
```

## 🧪 Testing Exercises

### Exercise A: Complete Missing Tests
1. Implement tests for `UpdateProductAsync` method
2. Add tests for `DeleteProductAsync` method
3. Create tests for `GetAllProductsAsync` method

### Exercise B: Test Data Builders
1. Use the `ProductTestDataBuilder` in your tests
2. Create more complex test scenarios
3. Practice the builder pattern for test data

### Exercise C: Mock Verification
1. Verify that repository methods are called correctly
2. Test that logging occurs at appropriate levels
3. Ensure proper exception handling

## 📝 Test Implementation Examples

### Complete UpdateProductAsync Test
```csharp
[Fact]
public async Task UpdateProductAsync_WithValidData_UpdatesProduct()
{
    // Arrange
    var productId = 1;
    var existingProduct = ProductTestDataBuilder.AProduct()
        .WithId(productId)
        .WithName("Old Name")
        .Build();

    var updatedProduct = ProductTestDataBuilder.AProduct()
        .WithName("New Name")
        .WithPrice(25.99m)
        .Build();

    _mockRepository.Setup(r => r.GetByIdAsync(productId))
                  .ReturnsAsync(existingProduct);

    // Act
    await _productService.UpdateProductAsync(productId, updatedProduct);

    // Assert
    _mockRepository.Verify(r => r.UpdateAsync(It.Is<Product>(p =>
        p.Name == "New Name" && p.Price == 25.99m)), Times.Once);
}
```

## ✅ Success Criteria
- [ ] All tests pass successfully
- [ ] Tests follow Arrange-Act-Assert pattern
- [ ] Mocks are properly configured and verified
- [ ] Edge cases and error scenarios are tested
- [ ] Test names clearly describe the scenario
- [ ] FluentAssertions are used for readable assertions

## 🔄 Next Steps
After mastering unit testing, move on to Exercise 2 for integration testing.

