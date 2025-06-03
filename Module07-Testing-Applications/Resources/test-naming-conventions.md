# Test Naming Conventions for ASP.NET Core Applications

## Introduction

Consistent test naming is crucial for maintaining a readable and maintainable test suite. Good test names:

- Clearly describe the scenario being tested
- Indicate expected behavior
- Make it easy to identify failing tests
- Serve as documentation

This guide outlines several naming conventions for ASP.NET Core application tests.

## General Naming Patterns

### Pattern 1: `[MethodName]_[Scenario]_[ExpectedResult]`

This is one of the most popular patterns:

```csharp
// Examples
public void GetById_ExistingId_ReturnsProduct()
public void GetById_NonExistingId_ReturnsNull()
public void CreateProduct_NullInput_ThrowsArgumentNullException()
public void UpdateStock_NegativeQuantity_ThrowsInvalidOperationException()
```

### Pattern 2: `Should_[ExpectedBehavior]_When_[Scenario]`

A more behavior-focused approach:

```csharp
// Examples
public void Should_ReturnProduct_When_IdExists()
public void Should_ReturnNull_When_IdDoesNotExist()
public void Should_ThrowArgumentNullException_When_InputIsNull()
public void Should_DecrementStock_When_OrderIsPlaced()
```

### Pattern 3: `Given_[Precondition]_When_[Action]_Then_[ExpectedResult]`

Following the BDD (Behavior-Driven Development) style:

```csharp
// Examples
public void Given_ExistingProduct_When_GetById_Then_ReturnsProduct()
public void Given_EmptyDatabase_When_GetById_Then_ReturnsNull()
public void Given_NullInput_When_CreateProduct_Then_ThrowsArgumentNullException()
public void Given_InsufficientStock_When_PlaceOrder_Then_ThrowsBusinessException()
```

### Pattern 4: `[Feature]_[Scenario]_[ExpectedResult]`

Useful for feature or requirement-based testing:

```csharp
// Examples
public void ProductRetrieval_ExistingProduct_SuccessfullyReturnsDetails()
public void OrderCreation_InvalidItems_ValidationErrorReturned()
public void UserAuthentication_CorrectCredentials_LogsUserIn()
public void CartCheckout_EmptyCart_ShowsErrorMessage()
```

## Testing Different Components

### Controller Tests

Controllers should be tested based on their HTTP behavior:

```csharp
// Examples
public async Task GetProduct_ExistingId_ReturnsOkWithProduct()
public async Task GetProduct_NonExistingId_ReturnsNotFound()
public async Task CreateProduct_ValidModel_ReturnsCreatedAtAction()
public async Task CreateProduct_InvalidModel_ReturnsBadRequest()
public async Task UpdateProduct_Unauthorized_ReturnsUnauthorized()
```

### Service Tests

Services should be tested based on their business logic:

```csharp
// Examples
public async Task GetProductByIdAsync_ExistingProduct_ReturnsProduct()
public async Task CalculateOrderTotalAsync_WithDiscountCode_AppliesDiscount()
public async Task ProcessPaymentAsync_InsufficientFunds_ThrowsPaymentException()
public async Task SendOrderConfirmationAsync_InvalidEmail_LogsWarning()
```

### Repository Tests

Repository tests focus on data access operations:

```csharp
// Examples
public async Task GetByIdAsync_ExistingEntity_ReturnsEntity()
public async Task AddAsync_ValidEntity_PersistsToDatabase()
public async Task DeleteAsync_ExistingEntity_RemovesFromDatabase()
public async Task UpdateAsync_ConcurrentModification_ThrowsDbUpdateConcurrencyException()
```

### Domain Model Tests

Domain model tests verify business rules and invariants:

```csharp
// Examples
public void Order_AddItem_IncreasesSummedTotal()
public void Product_SetNegativePrice_ThrowsDomainException()
public void ShoppingCart_ExceedMaxItems_ThrowsLimitExceededException()
public void Reservation_DateRange_CalculatesDurationCorrectly()
```

## Testing Different Scenarios

### Happy Path Tests

Testing successful scenarios:

```csharp
// Examples
public void ValidateOrder_AllFieldsCorrect_ReturnsNoErrors()
public void ProcessPayment_ValidCreditCard_ChargesCard()
public void RegisterUser_NewEmail_CreatesAccount()
```

### Edge Cases

Testing boundary conditions:

```csharp
// Examples
public void GetProducts_ZeroPageSize_ThrowsArgumentException()
public void ValidatePassword_ExactMinimumLength_Succeeds()
public void ProcessOrder_MaxItemsAllowed_Succeeds()
```

### Error Cases

Testing error handling:

```csharp
// Examples
public void GetUser_NullId_ThrowsArgumentNullException()
public void CreateProduct_DuplicateSku_ThrowsUniqueConstraintException()
public void UpdateOrder_ConcurrentEdit_ThrowsConcurrencyException()
```

## Testing Integration Points

### External Service Tests

```csharp
// Examples
public async Task PaymentGateway_ValidCharge_ReturnsTransactionId()
public async Task EmailProvider_ServerError_ThrowsServiceUnavailableException()
public async Task CloudStorage_UploadFile_ReturnsPublicUrl()
```

### Database Tests

```csharp
// Examples
public async Task Products_ComplexQuery_ReturnsCorrectResults()
public async Task Orders_BulkInsert_PersistsAllRecords()
public async Task Transaction_CommitAfterMultipleOperations_AllChangesVisible()
```

## Using Test Attributes

xUnit provides attributes to organize tests:

```csharp
[Fact]
public void SingleTestCase() { /* ... */ }

[Theory]
[InlineData(1, true)]
[InlineData(0, false)]
[InlineData(-1, false)]
public void MultipleTestCases(int input, bool expected) { /* ... */ }

[Trait("Category", "Integration")]
public void TestWithCategory() { /* ... */ }

[Trait("Feature", "Checkout")]
public void TestForSpecificFeature() { /* ... */ }
```

## Organizing Test Classes

Group related tests into well-named classes:

```csharp
// Product-related tests
public class ProductServiceTests { /* ... */ }
public class ProductControllerTests { /* ... */ }
public class ProductValidationTests { /* ... */ }

// Order-related tests
public class OrderServiceTests { /* ... */ }
public class OrderProcessingTests { /* ... */ }
public class OrderValidationTests { /* ... */ }
```

Consider organizing tests by feature or component:

```csharp
// By feature
public class UserRegistrationTests { /* ... */ }
public class CheckoutProcessTests { /* ... */ }
public class ProductCatalogTests { /* ... */ }

// By component
public class AuthenticationTests { /* ... */ }
public class PaymentProcessingTests { /* ... */ }
public class EmailNotificationTests { /* ... */ }
```

## Test Folder Structure

Maintain a structure that mirrors your main project:

```
YourProject.Tests/
├── Controllers/
│   ├── ProductsControllerTests.cs
│   ├── OrdersControllerTests.cs
│   └── UsersControllerTests.cs
├── Services/
│   ├── ProductServiceTests.cs
│   ├── OrderServiceTests.cs
│   └── UserServiceTests.cs
├── Repositories/
│   ├── ProductRepositoryTests.cs
│   └── OrderRepositoryTests.cs
├── Models/
│   ├── ProductTests.cs
│   └── OrderTests.cs
├── Integration/
│   ├── ApiTests.cs
│   └── DatabaseTests.cs
└── Helpers/
    ├── TestDataGenerator.cs
    └── TestHelpers.cs
```

## Special Test Categories

### Integration Tests

Label integration tests clearly:

```csharp
[Trait("Category", "Integration")]
public class ApiIntegrationTests
{
    [Fact]
    public async Task CompleteOrderFlow_ValidOrder_ProcessesSuccessfully()
    {
        // Tests complete order flow from creation to payment
    }
}
```

### Performance Tests

Name performance tests to indicate what's being measured:

```csharp
[Trait("Category", "Performance")]
public class ProductQueryPerformanceTests
{
    [Benchmark]
    public void FilterProducts_Large_Dataset_ComplexQuery_CompletesUnder100ms()
    {
        // Performance benchmark
    }
}
```

### Security Tests

Clearly label security-related tests:

```csharp
[Trait("Category", "Security")]
public class SecurityTests
{
    [Fact]
    public async Task AdminEndpoint_UnauthenticatedUser_ReturnsUnauthorized()
    {
        // Security test
    }
    
    [Fact]
    public async Task UserData_NonOwner_CannotAccess()
    {
        // Authorization test
    }
}
```

## Practical Examples

### Example 1: Product Service Tests

```csharp
public class ProductServiceTests
{
    [Fact]
    public async Task GetProductByIdAsync_ExistingProduct_ReturnsProduct()
    {
        // Test implementation
    }
    
    [Fact]
    public async Task GetProductByIdAsync_NonExistingProduct_ReturnsNull()
    {
        // Test implementation
    }
    
    [Fact]
    public async Task CreateProductAsync_ValidProduct_ReturnsCreatedProduct()
    {
        // Test implementation
    }
    
    [Fact]
    public async Task CreateProductAsync_NullProduct_ThrowsArgumentNullException()
    {
        // Test implementation
    }
    
    [Theory]
    [InlineData("", "Name is required")]
    [InlineData("AB", "Name must be at least 3 characters")]
    [InlineData("Valid Name", null)] // No error expected
    public void ValidateProduct_VariousInputs_ReturnsExpectedError(string name, string expectedError)
    {
        // Test implementation
    }
}
```

### Example 2: Order Controller Tests

```csharp
public class OrdersControllerTests
{
    [Fact]
    public async Task GetOrders_WithPagination_ReturnsPagedResponse()
    {
        // Test implementation
    }
    
    [Fact]
    public async Task GetOrder_ExistingId_ReturnsOkWithOrder()
    {
        // Test implementation
    }
    
    [Fact]
    public async Task GetOrder_NonExistingId_ReturnsNotFound()
    {
        // Test implementation
    }
    
    [Fact]
    public async Task CreateOrder_ValidOrder_ReturnsCreatedAtAction()
    {
        // Test implementation
    }
    
    [Fact]
    public async Task CreateOrder_InvalidModel_ReturnsBadRequest()
    {
        // Test implementation
    }
    
    [Fact]
    public async Task CancelOrder_OrderInProgress_ReturnsOk()
    {
        // Test implementation
    }
    
    [Fact]
    public async Task CancelOrder_AlreadyShipped_ReturnsBadRequest()
    {
        // Test implementation
    }
}
```

## Conclusion

Consistent, descriptive test naming is essential for maintaining a clear and effective test suite. Choose a naming convention that works for your team and stick with it consistently.

Remember that good test names serve as documentation and help everyone understand what's being tested and why.

When in doubt, ask yourself: "If this test fails, will the name help me understand what went wrong?"