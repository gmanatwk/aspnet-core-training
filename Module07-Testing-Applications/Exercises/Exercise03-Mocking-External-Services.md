# Exercise 3: Mocking External Services

## Objective
Learn to use mocking frameworks effectively to isolate your tests from external dependencies such as APIs, databases, and file systems.

## Prerequisites
- Visual Studio or Visual Studio Code
- .NET 8 SDK
- xUnit and mocking frameworks knowledge from the module content

## Exercise Description

In this exercise, you'll create a weather forecast service that interacts with an external weather API, a database, and the file system. You'll then write unit tests for this service using mocking to isolate it from its dependencies.

## Tasks

### 1. Create the Weather Forecast Service

Create a simple console application with the following components:

1. A `WeatherData` model:
```csharp
public class WeatherData
{
    public string City { get; set; }
    public double Temperature { get; set; }
    public string Condition { get; set; }
    public int Humidity { get; set; }
    public double WindSpeed { get; set; }
    public DateTime Timestamp { get; set; }
}
```

2. An interface for the external weather API:
```csharp
public interface IWeatherApiClient
{
    Task<WeatherData> GetCurrentWeatherAsync(string city);
    Task<IEnumerable<WeatherData>> GetForecastAsync(string city, int days);
}
```

3. An interface for the database repository:
```csharp
public interface IWeatherRepository
{
    Task SaveWeatherDataAsync(WeatherData data);
    Task<WeatherData> GetLatestWeatherDataAsync(string city);
    Task<IEnumerable<WeatherData>> GetHistoricalDataAsync(string city, DateTime from, DateTime to);
}
```

4. An interface for the file system operations:
```csharp
public interface IFileService
{
    Task WriteReportAsync(string filePath, string content);
    Task<string> ReadReportAsync(string filePath);
    bool FileExists(string filePath);
}
```

5. The weather forecast service:
```csharp
public class WeatherForecastService
{
    private readonly IWeatherApiClient _apiClient;
    private readonly IWeatherRepository _repository;
    private readonly IFileService _fileService;
    private readonly ILogger<WeatherForecastService> _logger;

    public WeatherForecastService(
        IWeatherApiClient apiClient, 
        IWeatherRepository repository, 
        IFileService fileService,
        ILogger<WeatherForecastService> logger)
    {
        _apiClient = apiClient ?? throw new ArgumentNullException(nameof(apiClient));
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _fileService = fileService ?? throw new ArgumentNullException(nameof(fileService));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<WeatherData> GetCurrentWeatherAsync(string city)
    {
        if (string.IsNullOrWhiteSpace(city))
        {
            throw new ArgumentException("City name cannot be empty", nameof(city));
        }

        try
        {
            _logger.LogInformation("Fetching current weather for {City}", city);
            
            // Try to get from the database first
            var cachedData = await _repository.GetLatestWeatherDataAsync(city);
            
            // If data is less than 30 minutes old, return it
            if (cachedData != null && (DateTime.UtcNow - cachedData.Timestamp).TotalMinutes < 30)
            {
                _logger.LogInformation("Returning cached weather data for {City}", city);
                return cachedData;
            }
            
            // Otherwise fetch from the API
            var currentWeather = await _apiClient.GetCurrentWeatherAsync(city);
            
            // Save to database
            await _repository.SaveWeatherDataAsync(currentWeather);
            
            return currentWeather;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting current weather for {City}", city);
            throw;
        }
    }

    public async Task<IEnumerable<WeatherData>> GetForecastAsync(string city, int days)
    {
        if (string.IsNullOrWhiteSpace(city))
        {
            throw new ArgumentException("City name cannot be empty", nameof(city));
        }

        if (days <= 0 || days > 10)
        {
            throw new ArgumentOutOfRangeException(nameof(days), "Days must be between 1 and 10");
        }

        try
        {
            _logger.LogInformation("Fetching {Days} day forecast for {City}", days, city);
            return await _apiClient.GetForecastAsync(city, days);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting forecast for {City}", city);
            throw;
        }
    }

    public async Task<string> GenerateWeatherReportAsync(string city, string reportPath)
    {
        if (string.IsNullOrWhiteSpace(city))
        {
            throw new ArgumentException("City name cannot be empty", nameof(city));
        }

        if (string.IsNullOrWhiteSpace(reportPath))
        {
            throw new ArgumentException("Report path cannot be empty", nameof(reportPath));
        }

        try
        {
            _logger.LogInformation("Generating weather report for {City}", city);
            
            // Get current weather
            var currentWeather = await GetCurrentWeatherAsync(city);
            
            // Get 5-day forecast
            var forecast = await GetForecastAsync(city, 5);
            
            // Generate report content
            var report = new StringBuilder();
            report.AppendLine($"Weather Report for {city}");
            report.AppendLine($"Generated at: {DateTime.Now}");
            report.AppendLine();
            report.AppendLine("Current Weather:");
            report.AppendLine($"Temperature: {currentWeather.Temperature}°C");
            report.AppendLine($"Condition: {currentWeather.Condition}");
            report.AppendLine($"Humidity: {currentWeather.Humidity}%");
            report.AppendLine($"Wind Speed: {currentWeather.WindSpeed} km/h");
            report.AppendLine();
            report.AppendLine("5-Day Forecast:");
            
            foreach (var day in forecast)
            {
                report.AppendLine($"{day.Timestamp.ToShortDateString()}: {day.Condition}, {day.Temperature}°C");
            }
            
            // Write report to file
            await _fileService.WriteReportAsync(reportPath, report.ToString());
            
            _logger.LogInformation("Weather report generated successfully at {ReportPath}", reportPath);
            
            return report.ToString();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error generating weather report for {City}", city);
            throw;
        }
    }

    public async Task<IEnumerable<WeatherData>> GetHistoricalDataAsync(string city, DateTime from, DateTime to)
    {
        if (string.IsNullOrWhiteSpace(city))
        {
            throw new ArgumentException("City name cannot be empty", nameof(city));
        }

        if (from > to)
        {
            throw new ArgumentException("From date must be before to date");
        }

        try
        {
            _logger.LogInformation("Fetching historical data for {City} from {From} to {To}", city, from, to);
            return await _repository.GetHistoricalDataAsync(city, from, to);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting historical data for {City}", city);
            throw;
        }
    }

    public async Task<WeatherAnalysis> AnalyzeWeatherTrendsAsync(string city, int days)
    {
        if (string.IsNullOrWhiteSpace(city))
        {
            throw new ArgumentException("City name cannot be empty", nameof(city));
        }

        if (days <= 0)
        {
            throw new ArgumentOutOfRangeException(nameof(days), "Days must be positive");
        }

        try
        {
            _logger.LogInformation("Analyzing weather trends for {City} over {Days} days", city, days);
            
            var from = DateTime.UtcNow.AddDays(-days);
            var to = DateTime.UtcNow;
            
            var historicalData = await _repository.GetHistoricalDataAsync(city, from, to);
            
            if (!historicalData.Any())
            {
                _logger.LogWarning("No historical data available for {City}", city);
                return new WeatherAnalysis
                {
                    City = city,
                    AverageTemperature = 0,
                    MinTemperature = 0,
                    MaxTemperature = 0,
                    DominantCondition = "Unknown",
                    DataPoints = 0
                };
            }
            
            var analysis = new WeatherAnalysis
            {
                City = city,
                AverageTemperature = historicalData.Average(d => d.Temperature),
                MinTemperature = historicalData.Min(d => d.Temperature),
                MaxTemperature = historicalData.Max(d => d.Temperature),
                DominantCondition = historicalData
                    .GroupBy(d => d.Condition)
                    .OrderByDescending(g => g.Count())
                    .First()
                    .Key,
                DataPoints = historicalData.Count()
            };
            
            _logger.LogInformation("Weather trend analysis completed for {City}", city);
            
            return analysis;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error analyzing weather trends for {City}", city);
            throw;
        }
    }
}

public class WeatherAnalysis
{
    public string City { get; set; }
    public double AverageTemperature { get; set; }
    public double MinTemperature { get; set; }
    public double MaxTemperature { get; set; }
    public string DominantCondition { get; set; }
    public int DataPoints { get; set; }
}
```

### 2. Write Unit Tests with Mocks

Create a test project and write unit tests for each method in the `WeatherForecastService` class:

1. Test the constructor with null parameters:
```csharp
public class WeatherForecastServiceTests
{
    private readonly Mock<IWeatherApiClient> _mockApiClient;
    private readonly Mock<IWeatherRepository> _mockRepository;
    private readonly Mock<IFileService> _mockFileService;
    private readonly Mock<ILogger<WeatherForecastService>> _mockLogger;

    public WeatherForecastServiceTests()
    {
        _mockApiClient = new Mock<IWeatherApiClient>();
        _mockRepository = new Mock<IWeatherRepository>();
        _mockFileService = new Mock<IFileService>();
        _mockLogger = new Mock<ILogger<WeatherForecastService>>();
    }

    [Fact]
    public void Constructor_WithNullApiClient_ThrowsArgumentNullException()
    {
        // Act & Assert
        var exception = Assert.Throws<ArgumentNullException>(() => new WeatherForecastService(
            null,
            _mockRepository.Object,
            _mockFileService.Object,
            _mockLogger.Object
        ));
        
        Assert.Equal("apiClient", exception.ParamName);
    }

    // Add similar tests for other constructor parameters
}
```

2. Test `GetCurrentWeatherAsync` with various scenarios:
```csharp
[Fact]
public async Task GetCurrentWeatherAsync_WithEmptyCity_ThrowsArgumentException()
{
    // Arrange
    var service = new WeatherForecastService(
        _mockApiClient.Object,
        _mockRepository.Object,
        _mockFileService.Object,
        _mockLogger.Object
    );
    
    // Act & Assert
    var exception = await Assert.ThrowsAsync<ArgumentException>(() => 
        service.GetCurrentWeatherAsync(""));
    
    Assert.Equal("city", exception.ParamName);
}

[Fact]
public async Task GetCurrentWeatherAsync_WithCachedRecentData_ReturnsCachedData()
{
    // Arrange
    var city = "London";
    var cachedData = new WeatherData
    {
        City = city,
        Temperature = 20,
        Condition = "Sunny",
        Timestamp = DateTime.UtcNow.AddMinutes(-15) // 15 minutes old (less than 30)
    };
    
    _mockRepository.Setup(r => r.GetLatestWeatherDataAsync(city))
        .ReturnsAsync(cachedData);
    
    var service = new WeatherForecastService(
        _mockApiClient.Object,
        _mockRepository.Object,
        _mockFileService.Object,
        _mockLogger.Object
    );
    
    // Act
    var result = await service.GetCurrentWeatherAsync(city);
    
    // Assert
    Assert.Equal(cachedData, result);
    
    // Verify the API client was NOT called
    _mockApiClient.Verify(a => a.GetCurrentWeatherAsync(It.IsAny<string>()), Times.Never);
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