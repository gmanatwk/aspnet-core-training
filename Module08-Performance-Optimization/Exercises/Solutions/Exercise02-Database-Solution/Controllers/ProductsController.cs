using DatabaseOptimization.Models;
using DatabaseOptimization.Services;
using Microsoft.AspNetCore.Mvc;

namespace DatabaseOptimization.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IIneffientProductService _inefficientService;
    private readonly IOptimizedProductService _optimizedService;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(
        IIneffientProductService inefficientService,
        IOptimizedProductService optimizedService,
        ILogger<ProductsController> logger)
    {
        _inefficientService = inefficientService;
        _optimizedService = optimizedService;
        _logger = logger;
    }

    /// <summary>
    /// Get products with categories using inefficient N+1 pattern
    /// </summary>
    [HttpGet("inefficient/with-categories")]
    public async Task<ActionResult<List<ProductDto>>> GetProductsWithCategoriesInefficient()
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            var products = await _inefficientService.GetProductsWithCategoryAsync();
            stopwatch.Stop();
            
            _logger.LogInformation("Inefficient query completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
            
            return Ok(new
            {
                Data = products,
                ExecutionTimeMs = stopwatch.ElapsedMilliseconds,
                QueryType = "Inefficient (N+1 Problem)"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in inefficient query");
            return StatusCode(500, "Error executing inefficient query");
        }
    }

    /// <summary>
    /// Get products with categories using optimized projection
    /// </summary>
    [HttpGet("optimized/with-categories")]
    public async Task<ActionResult<List<ProductDto>>> GetProductsWithCategoriesOptimized()
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            var products = await _optimizedService.GetProductsWithCategoryAsync();
            stopwatch.Stop();
            
            _logger.LogInformation("Optimized query completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
            
            return Ok(new
            {
                Data = products,
                ExecutionTimeMs = stopwatch.ElapsedMilliseconds,
                QueryType = "Optimized (Single Query with Projection)"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in optimized query");
            return StatusCode(500, "Error executing optimized query");
        }
    }

    /// <summary>
    /// Get orders with details using inefficient pattern
    /// </summary>
    [HttpGet("inefficient/orders")]
    public async Task<ActionResult<List<OrderSummaryDto>>> GetOrdersInefficient()
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            var orders = await _inefficientService.GetOrdersWithDetailsAsync();
            stopwatch.Stop();
            
            _logger.LogInformation("Inefficient orders query completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
            
            return Ok(new
            {
                Data = orders,
                ExecutionTimeMs = stopwatch.ElapsedMilliseconds,
                QueryType = "Inefficient (N+1 Problem)"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in inefficient orders query");
            return StatusCode(500, "Error executing inefficient orders query");
        }
    }

    /// <summary>
    /// Get orders with details using optimized pattern
    /// </summary>
    [HttpGet("optimized/orders")]
    public async Task<ActionResult<List<OrderSummaryDto>>> GetOrdersOptimized()
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            var orders = await _optimizedService.GetOrdersWithDetailsAsync();
            stopwatch.Stop();
            
            _logger.LogInformation("Optimized orders query completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
            
            return Ok(new
            {
                Data = orders,
                ExecutionTimeMs = stopwatch.ElapsedMilliseconds,
                QueryType = "Optimized (Single Query with Aggregation)"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in optimized orders query");
            return StatusCode(500, "Error executing optimized orders query");
        }
    }

    /// <summary>
    /// Get products with all details using inefficient complex joins
    /// </summary>
    [HttpGet("inefficient/detailed")]
    public async Task<ActionResult<List<ProductDetailDto>>> GetProductsDetailedInefficient()
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            var products = await _inefficientService.GetProductsWithAllDetailsAsync();
            stopwatch.Stop();
            
            _logger.LogInformation("Inefficient detailed query completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
            
            return Ok(new
            {
                Data = products.Take(10), // Limit results for demo
                ExecutionTimeMs = stopwatch.ElapsedMilliseconds,
                QueryType = "Inefficient (Complex Joins with Cartesian Product)"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in inefficient detailed query");
            return StatusCode(500, "Error executing inefficient detailed query");
        }
    }

    /// <summary>
    /// Get products with all details using optimized split query
    /// </summary>
    [HttpGet("optimized/detailed")]
    public async Task<ActionResult<List<ProductDetailDto>>> GetProductsDetailedOptimized()
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            var products = await _optimizedService.GetProductsWithAllDetailsSplitAsync();
            stopwatch.Stop();
            
            _logger.LogInformation("Optimized detailed query completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
            
            return Ok(new
            {
                Data = products.Take(10), // Limit results for demo
                ExecutionTimeMs = stopwatch.ElapsedMilliseconds,
                QueryType = "Optimized (Split Query + Separate Aggregation)"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in optimized detailed query");
            return StatusCode(500, "Error executing optimized detailed query");
        }
    }

    /// <summary>
    /// Get products for display using inefficient tracking
    /// </summary>
    [HttpGet("inefficient/display")]
    public async Task<ActionResult<List<ProductDto>>> GetProductsForDisplayInefficient()
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            var products = await _inefficientService.GetProductsForDisplayAsync();
            stopwatch.Stop();
            
            _logger.LogInformation("Inefficient display query completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
            
            return Ok(new
            {
                Data = products.Take(50), // Limit results for demo
                ExecutionTimeMs = stopwatch.ElapsedMilliseconds,
                QueryType = "Inefficient (Tracking Enabled + Memory Transformation)"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in inefficient display query");
            return StatusCode(500, "Error executing inefficient display query");
        }
    }

    /// <summary>
    /// Get products for display using optimized no-tracking
    /// </summary>
    [HttpGet("optimized/display")]
    public async Task<ActionResult<List<ProductDto>>> GetProductsForDisplayOptimized()
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            var products = await _optimizedService.GetProductsForDisplayNoTrackingAsync();
            stopwatch.Stop();
            
            _logger.LogInformation("Optimized display query completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
            
            return Ok(new
            {
                Data = products.Take(50), // Limit results for demo
                ExecutionTimeMs = stopwatch.ElapsedMilliseconds,
                QueryType = "Optimized (No Tracking + Database Projection)"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in optimized display query");
            return StatusCode(500, "Error executing optimized display query");
        }
    }

    /// <summary>
    /// Get paginated products using inefficient method
    /// </summary>
    [HttpGet("inefficient/page")]
    public async Task<ActionResult<List<ProductDto>>> GetProductsPageInefficient(
        [FromQuery] int page = 1, 
        [FromQuery] int size = 20)
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            var products = await _inefficientService.GetProductsPageInefficient(page, size);
            stopwatch.Stop();
            
            _logger.LogInformation("Inefficient pagination query completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
            
            return Ok(new
            {
                Data = products,
                ExecutionTimeMs = stopwatch.ElapsedMilliseconds,
                QueryType = "Inefficient (Load All + Memory Pagination)"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in inefficient pagination query");
            return StatusCode(500, "Error executing inefficient pagination query");
        }
    }

    /// <summary>
    /// Get paginated products using optimized method
    /// </summary>
    [HttpGet("optimized/page")]
    public async Task<ActionResult<PagedResult<ProductDto>>> GetProductsPageOptimized(
        [FromQuery] int page = 1, 
        [FromQuery] int size = 20)
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            var result = await _optimizedService.GetProductsPageEfficient(page, size);
            stopwatch.Stop();
            
            _logger.LogInformation("Optimized pagination query completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
            
            return Ok(new
            {
                Data = result,
                ExecutionTimeMs = stopwatch.ElapsedMilliseconds,
                QueryType = "Optimized (Database-Level Pagination)"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in optimized pagination query");
            return StatusCode(500, "Error executing optimized pagination query");
        }
    }

    /// <summary>
    /// Demonstrate compiled query performance
    /// </summary>
    [HttpGet("compiled/{id}")]
    public async Task<ActionResult<Product>> GetProductCompiledQuery(int id)
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            var product = await _optimizedService.GetProductByIdCompiledAsync(id);
            stopwatch.Stop();
            
            if (product == null)
                return NotFound();
                
            _logger.LogInformation("Compiled query completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
            
            return Ok(new
            {
                Data = product,
                ExecutionTimeMs = stopwatch.ElapsedMilliseconds,
                QueryType = "Compiled Query"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in compiled query");
            return StatusCode(500, "Error executing compiled query");
        }
    }

    /// <summary>
    /// Compare all query types for products with categories
    /// </summary>
    [HttpGet("compare/with-categories")]
    public async Task<ActionResult> CompareProductsWithCategories()
    {
        var results = new Dictionary<string, object>();

        // Test inefficient approach
        var inefficientStopwatch = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            var inefficientProducts = await _inefficientService.GetProductsWithCategoryAsync();
            inefficientStopwatch.Stop();
            
            results["Inefficient"] = new
            {
                ExecutionTimeMs = inefficientStopwatch.ElapsedMilliseconds,
                RecordCount = inefficientProducts.Count,
                QueryType = "N+1 Problem"
            };
        }
        catch (Exception ex)
        {
            results["Inefficient"] = new { Error = ex.Message };
        }

        // Test optimized approach
        var optimizedStopwatch = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            var optimizedProducts = await _optimizedService.GetProductsWithCategoryAsync();
            optimizedStopwatch.Stop();
            
            results["Optimized"] = new
            {
                ExecutionTimeMs = optimizedStopwatch.ElapsedMilliseconds,
                RecordCount = optimizedProducts.Count,
                QueryType = "Single Query with Projection"
            };
        }
        catch (Exception ex)
        {
            results["Optimized"] = new { Error = ex.Message };
        }

        // Calculate improvement
        if (results.ContainsKey("Inefficient") && results.ContainsKey("Optimized"))
        {
            var inefficientTime = inefficientStopwatch.ElapsedMilliseconds;
            var optimizedTime = optimizedStopwatch.ElapsedMilliseconds;
            
            if (optimizedTime > 0)
            {
                var improvement = ((double)(inefficientTime - optimizedTime) / inefficientTime) * 100;
                results["Performance Improvement"] = $"{improvement:F1}% faster";
                results["Speed Multiplier"] = $"{(double)inefficientTime / optimizedTime:F1}x";
            }
        }

        return Ok(results);
    }
}
