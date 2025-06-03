using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;
using ProductApi.Models;
using ProductApi.Services;
using System.Diagnostics;
using System.Text.Json;

namespace ProductApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;
    private readonly MetricsService _metricsService;
    private readonly TelemetryClient _telemetryClient;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(
        IProductService productService,
        MetricsService metricsService,
        TelemetryClient telemetryClient,
        IHttpClientFactory httpClientFactory,
        ILogger<ProductsController> logger)
    {
        _productService = productService;
        _metricsService = metricsService;
        _telemetryClient = telemetryClient;
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Product>>> GetProducts()
    {
        using var operation = _telemetryClient.StartOperation<Microsoft.ApplicationInsights.DataContracts.DependencyTelemetry>("GetProducts");
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            _logger.LogInformation("Getting all products");
            
            var products = await _productService.GetAllProductsAsync();
            
            stopwatch.Stop();
            
            // Track metrics
            _metricsService.TrackBusinessMetric("Products.RequestCount", 1);
            _metricsService.TrackBusinessMetric("Products.ResultCount", products.Count());
            _metricsService.TrackPerformanceCounter("Products.GetAll.ProcessingTime", stopwatch.ElapsedMilliseconds);
            
            operation.Telemetry.Success = true;
            
            _logger.LogInformation("Retrieved {ProductCount} products in {ElapsedMs}ms", products.Count(), stopwatch.ElapsedMilliseconds);
            
            return Ok(products);
        }
        catch (Exception ex)
        {
            operation.Telemetry.Success = false;
            _telemetryClient.TrackException(ex);
            _logger.LogError(ex, "Error retrieving products");
            
            return StatusCode(500, new { Error = "An error occurred while retrieving products" });
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Product>> GetProduct(int id)
    {
        using var operation = _telemetryClient.StartOperation<Microsoft.ApplicationInsights.DataContracts.DependencyTelemetry>("GetProduct");
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            _logger.LogInformation("Getting product with ID {ProductId}", id);
            
            var product = await _productService.GetProductByIdAsync(id);
            
            stopwatch.Stop();
            
            if (product == null)
            {
                _logger.LogWarning("Product with ID {ProductId} not found", id);
                _metricsService.TrackBusinessMetric("Products.NotFound", 1);
                return NotFound(new { Error = $"Product with ID {id} not found" });
            }
            
            // Track metrics
            _metricsService.TrackBusinessMetric("Products.SingleRequestCount", 1);
            _metricsService.TrackPerformanceCounter("Products.GetById.ProcessingTime", stopwatch.ElapsedMilliseconds);
            
            operation.Telemetry.Success = true;
            
            _logger.LogInformation("Retrieved product {ProductId} in {ElapsedMs}ms", id, stopwatch.ElapsedMilliseconds);
            
            return Ok(product);
        }
        catch (Exception ex)
        {
            operation.Telemetry.Success = false;
            _telemetryClient.TrackException(ex);
            _logger.LogError(ex, "Error retrieving product {ProductId}", id);
            
            return StatusCode(500, new { Error = $"An error occurred while retrieving product {id}" });
        }
    }

    [HttpPost]
    public async Task<ActionResult<Product>> CreateProduct(CreateProductRequest request)
    {
        using var operation = _telemetryClient.StartOperation<Microsoft.ApplicationInsights.DataContracts.DependencyTelemetry>("CreateProduct");
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            _logger.LogInformation("Creating new product: {ProductName}", request.Name);
            
            var product = await _productService.CreateProductAsync(request);
            
            stopwatch.Stop();
            
            // Track metrics
            _metricsService.TrackBusinessMetric("Products.CreatedCount", 1);
            _metricsService.TrackPerformanceCounter("Products.Create.ProcessingTime", stopwatch.ElapsedMilliseconds);
            
            // Track business event
            _metricsService.TrackUserActivity("ProductCreated", "system", new Dictionary<string, string>
            {
                ["ProductId"] = product.Id.ToString(),
                ["ProductName"] = product.Name,
                ["ProductPrice"] = product.Price.ToString(),
                ["ProcessingTimeMs"] = stopwatch.ElapsedMilliseconds.ToString()
            });
            
            operation.Telemetry.Success = true;
            
            _logger.LogInformation("Created product {ProductId} in {ElapsedMs}ms", product.Id, stopwatch.ElapsedMilliseconds);
            
            return CreatedAtAction(nameof(GetProduct), new { id = product.Id }, product);
        }
        catch (Exception ex)
        {
            operation.Telemetry.Success = false;
            _telemetryClient.TrackException(ex);
            _logger.LogError(ex, "Error creating product");
            
            return StatusCode(500, new { Error = "An error occurred while creating the product" });
        }
    }

    [HttpGet("users")]
    public async Task<IActionResult> GetUsersFromUserService()
    {
        using var operation = _telemetryClient.StartOperation<Microsoft.ApplicationInsights.DataContracts.DependencyTelemetry>("GetUsers");
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            _logger.LogInformation("Calling user service to get users");
            
            var client = _httpClientFactory.CreateClient("UserService");
            var correlationId = HttpContext.Items["CorrelationId"]?.ToString();
            
            if (!string.IsNullOrEmpty(correlationId))
            {
                client.DefaultRequestHeaders.Add("X-Correlation-ID", correlationId);
            }
            
            var response = await client.GetAsync("api/users");
            
            stopwatch.Stop();
            
            if (response.IsSuccessStatusCode)
            {
                var users = await response.Content.ReadAsStringAsync();
                
                _metricsService.TrackBusinessMetric("Products.UserServiceCalls", 1);
                _metricsService.TrackPerformanceCounter("Products.UserService.ResponseTime", stopwatch.ElapsedMilliseconds);
                
                operation.Telemetry.Success = true;
                
                _logger.LogInformation("Successfully retrieved users from user service in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
                
                return Ok(new 
                { 
                    Users = JsonSerializer.Deserialize<object[]>(users),
                    Source = "UserService",
                    ResponseTimeMs = stopwatch.ElapsedMilliseconds,
                    CorrelationId = correlationId
                });
            }
            
            operation.Telemetry.Success = false;
            _logger.LogWarning("User service returned {StatusCode}", response.StatusCode);
            _metricsService.TrackBusinessMetric("Products.UserServiceErrors", 1);
            
            return StatusCode((int)response.StatusCode, new { Error = "Failed to fetch users from user service" });
        }
        catch (HttpRequestException ex)
        {
            operation.Telemetry.Success = false;
            _telemetryClient.TrackException(ex);
            _logger.LogError(ex, "HTTP error calling user service");
            _metricsService.TrackBusinessMetric("Products.UserServiceErrors", 1);
            
            return StatusCode(503, new { Error = "User service is currently unavailable" });
        }
        catch (TaskCanceledException ex)
        {
            operation.Telemetry.Success = false;
            _telemetryClient.TrackException(ex);
            _logger.LogError(ex, "Timeout calling user service");
            _metricsService.TrackBusinessMetric("Products.UserServiceTimeouts", 1);
            
            return StatusCode(504, new { Error = "User service request timed out" });
        }
        catch (Exception ex)
        {
            operation.Telemetry.Success = false;
            _telemetryClient.TrackException(ex);
            _logger.LogError(ex, "Error calling user service");
            _metricsService.TrackBusinessMetric("Products.UserServiceErrors", 1);
            
            return StatusCode(500, new { Error = $"Error calling user service: {ex.Message}" });
        }
    }

    [HttpGet("test-error")]
    public IActionResult TestError()
    {
        _logger.LogWarning("Test error endpoint called - this will generate an exception");
        
        // This endpoint is for testing error handling and monitoring
        throw new InvalidOperationException("This is a test exception for monitoring purposes");
    }

    [HttpGet("test-slow")]
    public async Task<IActionResult> TestSlowResponse()
    {
        _logger.LogInformation("Test slow endpoint called - simulating slow response");
        
        // Simulate slow processing for testing monitoring
        var delay = Random.Shared.Next(2000, 5000); // 2-5 seconds
        await Task.Delay(delay);
        
        _metricsService.TrackBusinessMetric("Products.SlowRequestCount", 1);
        _metricsService.TrackPerformanceCounter("Products.SlowRequest.DelayMs", delay);
        
        return Ok(new { Message = "Slow response completed", DelayMs = delay });
    }
}
