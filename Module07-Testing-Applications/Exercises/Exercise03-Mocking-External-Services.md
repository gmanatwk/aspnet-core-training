# Exercise 3: Mocking External Services

## Objective
Learn to use mocking frameworks effectively to isolate your tests from external dependencies such as APIs, databases, and file systems.

## Prerequisites
- Visual Studio or Visual Studio Code
- .NET 8 SDK
- xUnit and mocking frameworks knowledge from the module content

## Exercise Description

In this exercise, you'll create a product catalog service that interacts with an external pricing API, a database, and the file system. You'll then write unit tests for this service using mocking to isolate it from its dependencies. This aligns with the ProductCatalog source code in this module.

## Tasks

### 1. Create the Product Catalog Service

Create a simple console application with the following components:

1. A `Product` model:
```csharp
public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
    public string Category { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
```

2. A `PriceHistory` model:
```csharp
public class PriceHistory
{
    public int ProductId { get; set; }
    public decimal Price { get; set; }
    public DateTime Date { get; set; }
    public string Source { get; set; } = string.Empty;
}
```

3. An interface for the external pricing API:
```csharp
public interface IPricingApiClient
{
    Task<decimal> GetCurrentPriceAsync(int productId);
    Task<IEnumerable<PriceHistory>> GetPriceHistoryAsync(int productId, int days);
    Task<bool> IsProductOnSaleAsync(int productId);
}
```

4. An interface for the database repository:
```csharp
public interface IProductRepository
{
    Task SaveProductAsync(Product product);
    Task<Product?> GetProductByIdAsync(int productId);
    Task<IEnumerable<Product>> GetProductsByCategoryAsync(string category);
    Task<IEnumerable<Product>> GetProductsAsync();
}
```

5. An interface for the file system operations:
```csharp
public interface IReportService
{
    Task WriteReportAsync(string filePath, string content);
    Task<string> ReadReportAsync(string filePath);
    bool FileExists(string filePath);
}
```

6. The product catalog service:
```csharp
public class ProductCatalogService
{
    private readonly IPricingApiClient _pricingClient;
    private readonly IProductRepository _repository;
    private readonly IReportService _reportService;
    private readonly ILogger<ProductCatalogService> _logger;

    public ProductCatalogService(
        IPricingApiClient pricingClient,
        IProductRepository repository,
        IReportService reportService,
        ILogger<ProductCatalogService> logger)
    {
        _pricingClient = pricingClient ?? throw new ArgumentNullException(nameof(pricingClient));
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _reportService = reportService ?? throw new ArgumentNullException(nameof(reportService));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<Product> GetProductWithCurrentPriceAsync(int productId)
    {
        if (productId <= 0)
        {
            throw new ArgumentException("Product ID must be positive", nameof(productId));
        }

        try
        {
            _logger.LogInformation("Fetching product {ProductId} with current price", productId);

            // Get product from database
            var product = await _repository.GetProductByIdAsync(productId);
            if (product == null)
            {
                throw new InvalidOperationException($"Product with ID {productId} not found");
            }

            // Get current price from external API
            var currentPrice = await _pricingClient.GetCurrentPriceAsync(productId);

            // Update product with current price
            product.Price = currentPrice;
            product.UpdatedAt = DateTime.UtcNow;

            // Save updated product
            await _repository.SaveProductAsync(product);

            return product;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting product {ProductId} with current price", productId);
            throw;
        }
    }

    public async Task<IEnumerable<Product>> GetProductsOnSaleAsync(string category)
    {
        if (string.IsNullOrWhiteSpace(category))
        {
            throw new ArgumentException("Category cannot be empty", nameof(category));
        }

        try
        {
            _logger.LogInformation("Fetching products on sale for category {Category}", category);

            var products = await _repository.GetProductsByCategoryAsync(category);
            var productsOnSale = new List<Product>();

            foreach (var product in products)
            {
                var isOnSale = await _pricingClient.IsProductOnSaleAsync(product.Id);
                if (isOnSale)
                {
                    productsOnSale.Add(product);
                }
            }

            return productsOnSale;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting products on sale for category {Category}", category);
            throw;
        }
    }

    public async Task<string> GenerateProductReportAsync(string category, string reportPath)
    {
        if (string.IsNullOrWhiteSpace(category))
        {
            throw new ArgumentException("Category cannot be empty", nameof(category));
        }

        if (string.IsNullOrWhiteSpace(reportPath))
        {
            throw new ArgumentException("Report path cannot be empty", nameof(reportPath));
        }

        try
        {
            _logger.LogInformation("Generating product report for category {Category}", category);

            // Get products in category
            var products = await _repository.GetProductsByCategoryAsync(category);

            // Get products on sale
            var productsOnSale = await GetProductsOnSaleAsync(category);

            // Generate report content
            var report = new StringBuilder();
            report.AppendLine($"Product Report for Category: {category}");
            report.AppendLine($"Generated at: {DateTime.Now}");
            report.AppendLine();
            report.AppendLine($"Total Products: {products.Count()}");
            report.AppendLine($"Products on Sale: {productsOnSale.Count()}");
            report.AppendLine();
            report.AppendLine("Product Details:");

            foreach (var product in products)
            {
                var isOnSale = productsOnSale.Any(p => p.Id == product.Id);
                var saleIndicator = isOnSale ? " (ON SALE)" : "";
                report.AppendLine($"- {product.Name}: ${product.Price:F2}{saleIndicator}");
            }

            // Write report to file
            await _reportService.WriteReportAsync(reportPath, report.ToString());

            _logger.LogInformation("Product report generated successfully at {ReportPath}", reportPath);

            return report.ToString();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error generating product report for category {Category}", category);
            throw;
        }
    }

    public async Task<IEnumerable<PriceHistory>> GetPriceHistoryAsync(int productId, int days)
    {
        if (productId <= 0)
        {
            throw new ArgumentException("Product ID must be positive", nameof(productId));
        }

        if (days <= 0)
        {
            throw new ArgumentOutOfRangeException(nameof(days), "Days must be positive");
        }

        try
        {
            _logger.LogInformation("Fetching price history for product {ProductId} for {Days} days", productId, days);
            return await _pricingClient.GetPriceHistoryAsync(productId, days);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting price history for product {ProductId}", productId);
            throw;
        }
    }

    public async Task<ProductAnalysis> AnalyzePriceTrendsAsync(int productId, int days)
    {
        if (productId <= 0)
        {
            throw new ArgumentException("Product ID must be positive", nameof(productId));
        }

        if (days <= 0)
        {
            throw new ArgumentOutOfRangeException(nameof(days), "Days must be positive");
        }

        try
        {
            _logger.LogInformation("Analyzing price trends for product {ProductId} over {Days} days", productId, days);

            var priceHistory = await _pricingClient.GetPriceHistoryAsync(productId, days);

            if (!priceHistory.Any())
            {
                _logger.LogWarning("No price history available for product {ProductId}", productId);
                return new ProductAnalysis
                {
                    ProductId = productId,
                    AveragePrice = 0,
                    MinPrice = 0,
                    MaxPrice = 0,
                    PriceVariance = 0,
                    DataPoints = 0
                };
            }

            var prices = priceHistory.Select(p => p.Price).ToList();
            var analysis = new ProductAnalysis
            {
                ProductId = productId,
                AveragePrice = prices.Average(),
                MinPrice = prices.Min(),
                MaxPrice = prices.Max(),
                PriceVariance = CalculateVariance(prices),
                DataPoints = prices.Count
            };

            _logger.LogInformation("Price trend analysis completed for product {ProductId}", productId);

            return analysis;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error analyzing price trends for product {ProductId}", productId);
            throw;
        }
    }

    private static decimal CalculateVariance(IEnumerable<decimal> values)
    {
        var average = values.Average();
        var sumOfSquares = values.Sum(v => (v - average) * (v - average));
        return sumOfSquares / values.Count();
    }
}

public class ProductAnalysis
{
    public int ProductId { get; set; }
    public decimal AveragePrice { get; set; }
    public decimal MinPrice { get; set; }
    public decimal MaxPrice { get; set; }
    public decimal PriceVariance { get; set; }
    public int DataPoints { get; set; }
}
```

### 2. Write Unit Tests with Mocks

Create a test project and write unit tests for each method in the `ProductCatalogService` class:

1. Test the constructor with null parameters:
```csharp
public class ProductCatalogServiceTests
{
    private readonly Mock<IPricingApiClient> _mockPricingClient;
    private readonly Mock<IProductRepository> _mockRepository;
    private readonly Mock<IReportService> _mockReportService;
    private readonly Mock<ILogger<ProductCatalogService>> _mockLogger;

    public ProductCatalogServiceTests()
    {
        _mockPricingClient = new Mock<IPricingApiClient>();
        _mockRepository = new Mock<IProductRepository>();
        _mockReportService = new Mock<IReportService>();
        _mockLogger = new Mock<ILogger<ProductCatalogService>>();
    }

    [Fact]
    public void Constructor_WithNullPricingClient_ThrowsArgumentNullException()
    {
        // Act & Assert
        var exception = Assert.Throws<ArgumentNullException>(() => new ProductCatalogService(
            null,
            _mockRepository.Object,
            _mockReportService.Object,
            _mockLogger.Object
        ));

        Assert.Equal("pricingClient", exception.ParamName);
    }

    // Add similar tests for other constructor parameters
}
```

2. Test `GetProductWithCurrentPriceAsync` with various scenarios:
```csharp
[Fact]
public async Task GetProductWithCurrentPriceAsync_WithInvalidProductId_ThrowsArgumentException()
{
    // Arrange
    var service = new ProductCatalogService(
        _mockPricingClient.Object,
        _mockRepository.Object,
        _mockReportService.Object,
        _mockLogger.Object
    );

    // Act & Assert
    var exception = await Assert.ThrowsAsync<ArgumentException>(() =>
        service.GetProductWithCurrentPriceAsync(0));

    Assert.Equal("productId", exception.ParamName);
}

[Fact]
public async Task GetProductWithCurrentPriceAsync_WithValidProductId_ReturnsProductWithUpdatedPrice()
{
    // Arrange
    var productId = 1;
    var originalProduct = new Product
    {
        Id = productId,
        Name = "Test Product",
        Price = 10.00m,
        Category = "Electronics"
    };

    var currentPrice = 12.50m;

    _mockRepository.Setup(r => r.GetProductByIdAsync(productId))
        .ReturnsAsync(originalProduct);

    _mockPricingClient.Setup(p => p.GetCurrentPriceAsync(productId))
        .ReturnsAsync(currentPrice);

    var service = new ProductCatalogService(
        _mockPricingClient.Object,
        _mockRepository.Object,
        _mockReportService.Object,
        _mockLogger.Object
    );

    // Act
    var result = await service.GetProductWithCurrentPriceAsync(productId);

    // Assert
    Assert.Equal(currentPrice, result.Price);
    Assert.Equal(originalProduct.Name, result.Name);

    // Verify the pricing client was called
    _mockPricingClient.Verify(p => p.GetCurrentPriceAsync(productId), Times.Once);

    // Verify the repository save was called
    _mockRepository.Verify(r => r.SaveProductAsync(It.IsAny<Product>()), Times.Once);
}

[Fact]
public async Task GetCurrentWeatherAsync_WithOldCachedData_FetchesFromApiAndSavesToDatabase()
{
    // Arrange
    var city = "London";
    var oldCachedData = new WeatherData
    {
        City = city,
        Temperature = 20,
        Condition = "Sunny",
        Timestamp = DateTime.UtcNow.AddMinutes(-45) // 45 minutes old (more than 30)
    };
    
    var newApiData = new WeatherData
    {
        City = city,
        Temperature = 22,
        Condition = "Partly Cloudy",
        Timestamp = DateTime.UtcNow
    };
    
    _mockRepository.Setup(r => r.GetLatestWeatherDataAsync(city))
        .ReturnsAsync(oldCachedData);
    
    _mockApiClient.Setup(a => a.GetCurrentWeatherAsync(city))
        .ReturnsAsync(newApiData);
    
    var service = new WeatherForecastService(
        _mockApiClient.Object,
        _mockRepository.Object,
        _mockFileService.Object,
        _mockLogger.Object
    );
    
    // Act
    var result = await service.GetCurrentWeatherAsync(city);
    
    // Assert
    Assert.Equal(newApiData, result);
    
    // Verify the API client was called
    _mockApiClient.Verify(a => a.GetCurrentWeatherAsync(city), Times.Once);
    
    // Verify the repository's SaveWeatherDataAsync was called with the new data
    _mockRepository.Verify(r => r.SaveWeatherDataAsync(newApiData), Times.Once);
}
```

3. Test `GetForecastAsync`:
```csharp
[Fact]
public async Task GetForecastAsync_WithValidParameters_ReturnsApiResult()
{
    // Arrange
    var city = "London";
    var days = 5;
    var forecastData = new List<WeatherData>
    {
        new WeatherData { City = city, Temperature = 22, Condition = "Sunny", Timestamp = DateTime.UtcNow.AddDays(1) },
        new WeatherData { City = city, Temperature = 20, Condition = "Cloudy", Timestamp = DateTime.UtcNow.AddDays(2) }
    };
    
    _mockApiClient.Setup(a => a.GetForecastAsync(city, days))
        .ReturnsAsync(forecastData);
    
    var service = new WeatherForecastService(
        _mockApiClient.Object,
        _mockRepository.Object,
        _mockFileService.Object,
        _mockLogger.Object
    );
    
    // Act
    var result = await service.GetForecastAsync(city, days);
    
    // Assert
    Assert.Equal(forecastData, result);
    
    // Verify API client was called with correct parameters
    _mockApiClient.Verify(a => a.GetForecastAsync(city, days), Times.Once);
}

[Theory]
[InlineData(0)] // Too few days
[InlineData(11)] // Too many days
public async Task GetForecastAsync_WithInvalidDays_ThrowsArgumentOutOfRangeException(int days)
{
    // Arrange
    var service = new WeatherForecastService(
        _mockApiClient.Object,
        _mockRepository.Object,
        _mockFileService.Object,
        _mockLogger.Object
    );
    
    // Act & Assert
    var exception = await Assert.ThrowsAsync<ArgumentOutOfRangeException>(() => 
        service.GetForecastAsync("London", days));
    
    Assert.Equal("days", exception.ParamName);
}
```

4. Test `GenerateWeatherReportAsync`:
```csharp
[Fact]
public async Task GenerateWeatherReportAsync_WithValidParameters_GeneratesAndSavesReport()
{
    // Arrange
    var city = "London";
    var reportPath = "/path/to/report.txt";
    
    var currentWeather = new WeatherData
    {
        City = city,
        Temperature = 22,
        Condition = "Sunny",
        Humidity = 60,
        WindSpeed = 10,
        Timestamp = DateTime.UtcNow
    };
    
    var forecastData = new List<WeatherData>
    {
        new WeatherData { City = city, Temperature = 22, Condition = "Sunny", Timestamp = DateTime.UtcNow.AddDays(1) },
        new WeatherData { City = city, Temperature = 20, Condition = "Cloudy", Timestamp = DateTime.UtcNow.AddDays(2) }
    };
    
    // Setup repository to return cached weather data
    _mockRepository.Setup(r => r.GetLatestWeatherDataAsync(city))
        .ReturnsAsync(currentWeather);
    
    // Setup API client to return forecast
    _mockApiClient.Setup(a => a.GetForecastAsync(city, 5))
        .ReturnsAsync(forecastData);
    
    // Capture the content written to file
    string capturedContent = null;
    _mockFileService.Setup(f => f.WriteReportAsync(reportPath, It.IsAny<string>()))
        .Callback<string, string>((path, content) => capturedContent = content)
        .Returns(Task.CompletedTask);
    
    var service = new WeatherForecastService(
        _mockApiClient.Object,
        _mockRepository.Object,
        _mockFileService.Object,
        _mockLogger.Object
    );
    
    // Act
    var result = await service.GenerateWeatherReportAsync(city, reportPath);
    
    // Assert
    Assert.NotNull(result);
    Assert.NotNull(capturedContent);
    
    // Basic verification of report content
    Assert.Contains($"Weather Report for {city}", result);
    Assert.Contains($"Temperature: {currentWeather.Temperature}°C", result);
    Assert.Contains($"5-Day Forecast:", result);
    
    // Verify file was written
    _mockFileService.Verify(f => f.WriteReportAsync(reportPath, It.IsAny<string>()), Times.Once);
}
```

5. Test `AnalyzeWeatherTrendsAsync`:
```csharp
[Fact]
public async Task AnalyzeWeatherTrendsAsync_WithHistoricalData_ReturnsCorrectAnalysis()
{
    // Arrange
    var city = "London";
    var days = 7;
    var from = DateTime.UtcNow.AddDays(-days);
    var to = DateTime.UtcNow;
    
    var historicalData = new List<WeatherData>
    {
        new WeatherData { City = city, Temperature = 22, Condition = "Sunny", Timestamp = DateTime.UtcNow.AddDays(-1) },
        new WeatherData { City = city, Temperature = 20, Condition = "Cloudy", Timestamp = DateTime.UtcNow.AddDays(-2) },
        new WeatherData { City = city, Temperature = 18, Condition = "Rainy", Timestamp = DateTime.UtcNow.AddDays(-3) },
        new WeatherData { City = city, Temperature = 19, Condition = "Cloudy", Timestamp = DateTime.UtcNow.AddDays(-4) }
    };
    
    _mockRepository.Setup(r => r.GetHistoricalDataAsync(city, It.IsAny<DateTime>(), It.IsAny<DateTime>()))
        .ReturnsAsync(historicalData);
    
    var service = new WeatherForecastService(
        _mockApiClient.Object,
        _mockRepository.Object,
        _mockFileService.Object,
        _mockLogger.Object
    );
    
    // Act
    var analysis = await service.AnalyzeWeatherTrendsAsync(city, days);
    
    // Assert
    Assert.Equal(city, analysis.City);
    Assert.Equal(19.75, analysis.AverageTemperature); // (22 + 20 + 18 + 19) / 4
    Assert.Equal(18, analysis.MinTemperature);
    Assert.Equal(22, analysis.MaxTemperature);
    Assert.Equal("Cloudy", analysis.DominantCondition); // Appears twice vs once for others
    Assert.Equal(4, analysis.DataPoints);
    
    // Verify repository was called with correct parameters
    _mockRepository.Verify(r => r.GetHistoricalDataAsync(
        city, 
        It.Is<DateTime>(d => d.Date == from.Date), 
        It.Is<DateTime>(d => d.Date == to.Date)), 
        Times.Once);
}

[Fact]
public async Task AnalyzeWeatherTrendsAsync_WithNoHistoricalData_ReturnsDefaultAnalysis()
{
    // Arrange
    var city = "London";
    var days = 7;
    
    _mockRepository.Setup(r => r.GetHistoricalDataAsync(city, It.IsAny<DateTime>(), It.IsAny<DateTime>()))
        .ReturnsAsync(new List<WeatherData>());
    
    var service = new WeatherForecastService(
        _mockApiClient.Object,
        _mockRepository.Object,
        _mockFileService.Object,
        _mockLogger.Object
    );
    
    // Act
    var analysis = await service.AnalyzeWeatherTrendsAsync(city, days);
    
    // Assert
    Assert.Equal(city, analysis.City);
    Assert.Equal(0, analysis.AverageTemperature);
    Assert.Equal(0, analysis.MinTemperature);
    Assert.Equal(0, analysis.MaxTemperature);
    Assert.Equal("Unknown", analysis.DominantCondition);
    Assert.Equal(0, analysis.DataPoints);
}
```

### 3. Use Strict Mocks

Convert some of your mocks to strict mocks and verify that all expected methods are called:

```csharp
[Fact]
public async Task GetCurrentWeatherAsync_WithCachedRecentData_OnlyCallsExpectedMethods()
{
    // Arrange
    var city = "London";
    var cachedData = new WeatherData
    {
        City = city,
        Temperature = 20,
        Condition = "Sunny",
        Timestamp = DateTime.UtcNow.AddMinutes(-15)
    };
    
    // Create strict mocks
    var strictApiClient = new Mock<IWeatherApiClient>(MockBehavior.Strict);
    var strictRepository = new Mock<IWeatherRepository>(MockBehavior.Strict);
    
    // Setup only the methods we expect to be called
    strictRepository.Setup(r => r.GetLatestWeatherDataAsync(city))
        .ReturnsAsync(cachedData);
    
    var service = new WeatherForecastService(
        strictApiClient.Object,
        strictRepository.Object,
        _mockFileService.Object,
        _mockLogger.Object
    );
    
    // Act
    var result = await service.GetCurrentWeatherAsync(city);
    
    // Assert
    Assert.Equal(cachedData, result);
}
```

### 4. Test Exception Handling

Add tests for exception scenarios:

```csharp
[Fact]
public async Task GetCurrentWeatherAsync_WhenApiThrowsException_PropagatesException()
{
    // Arrange
    var city = "London";
    var expectedException = new HttpRequestException("API is down");
    
    _mockRepository.Setup(r => r.GetLatestWeatherDataAsync(city))
        .ReturnsAsync((WeatherData)null); // No cached data
    
    _mockApiClient.Setup(a => a.GetCurrentWeatherAsync(city))
        .ThrowsAsync(expectedException);
    
    var service = new WeatherForecastService(
        _mockApiClient.Object,
        _mockRepository.Object,
        _mockFileService.Object,
        _mockLogger.Object
    );
    
    // Act & Assert
    var exception = await Assert.ThrowsAsync<HttpRequestException>(() => 
        service.GetCurrentWeatherAsync(city));
    
    Assert.Equal(expectedException.Message, exception.Message);
    
    // Verify logging occurred
    _mockLogger.Verify(
        x => x.Log(
            LogLevel.Error,
            It.IsAny<EventId>(),
            It.Is<It.IsAnyType>((v, t) => true),
            expectedException,
            It.IsAny<Func<It.IsAnyType, Exception, string>>()),
        Times.Once);
}
```

### 5. Test Sequence of Calls

Add a test that verifies a specific sequence of calls:

```csharp
[Fact]
public async Task GenerateWeatherReportAsync_MakesCallsInExpectedOrder()
{
    // Arrange
    var city = "London";
    var reportPath = "/path/to/report.txt";
    var sequence = new MockSequence();
    
    var currentWeather = new WeatherData
    {
        City = city,
        Temperature = 22,
        Condition = "Sunny",
        Timestamp = DateTime.UtcNow
    };
    
    var forecastData = new List<WeatherData>
    {
        new WeatherData { City = city, Temperature = 22, Condition = "Sunny", Timestamp = DateTime.UtcNow.AddDays(1) }
    };
    
    // Setup repository call (should be first)
    _mockRepository.InSequence(sequence)
        .Setup(r => r.GetLatestWeatherDataAsync(city))
        .ReturnsAsync(currentWeather);
    
    // Setup API client call (should be second)
    _mockApiClient.InSequence(sequence)
        .Setup(a => a.GetForecastAsync(city, 5))
        .ReturnsAsync(forecastData);
    
    // Setup file service call (should be last)
    _mockFileService.InSequence(sequence)
        .Setup(f => f.WriteReportAsync(reportPath, It.IsAny<string>()))
        .Returns(Task.CompletedTask);
    
    var service = new WeatherForecastService(
        _mockApiClient.Object,
        _mockRepository.Object,
        _mockFileService.Object,
        _mockLogger.Object
    );
    
    // Act
    await service.GenerateWeatherReportAsync(city, reportPath);
    
    // Assert - the sequence verification is implicit in the setup
    _mockRepository.Verify(r => r.GetLatestWeatherDataAsync(city), Times.Once);
    _mockApiClient.Verify(a => a.GetForecastAsync(city, 5), Times.Once);
    _mockFileService.Verify(f => f.WriteReportAsync(reportPath, It.IsAny<string>()), Times.Once);
}
```

## Expected Output

All tests should pass when run with the `dotnet test` command.

## Bonus Tasks

1. Add test cases using both Moq and NSubstitute to compare the syntax.
2. Implement verification for specific logger messages.
3. Create custom argument matchers for complex verification scenarios.
4. Add tests that use the `It.IsAny<T>()` and `It.Is<T>()` methods for argument matching.

## Submission

Submit your test project code, including all implemented mock tests.

## Evaluation Criteria

- Proper use of mocking frameworks
- Test coverage for both success and error paths
- Verification of method calls with correct arguments
- Proper isolation of the system under test
- Clean, readable test organization
- Effective use of mock behavior and verification methods