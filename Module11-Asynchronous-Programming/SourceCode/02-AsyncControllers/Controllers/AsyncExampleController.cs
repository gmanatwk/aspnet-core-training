using Microsoft.AspNetCore.Mvc;

namespace AsyncControllers.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AsyncExampleController : ControllerBase
    {
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly ILogger<AsyncExampleController> _logger;

        public AsyncExampleController(IHttpClientFactory httpClientFactory, ILogger<AsyncExampleController> logger)
        {
            _httpClientFactory = httpClientFactory;
            _logger = logger;
        }

        // Example 1: Basic async endpoint
        [HttpGet("basic")]
        public async Task<IActionResult> GetBasicData()
        {
            _logger.LogInformation("Starting basic async operation");

            var result = await ProcessDataAsync();

            _logger.LogInformation("Basic async operation completed");
            return Ok(new { Message = result, Timestamp = DateTime.UtcNow });
        }

        // Example 2: Async with cancellation token
        [HttpGet("cancellable")]
        public async Task<IActionResult> GetCancellableData(CancellationToken cancellationToken)
        {
            _logger.LogInformation("Starting cancellable async operation");

            try
            {
                var result = await ProcessLongRunningOperationAsync(cancellationToken);
                return Ok(new { Message = result, Timestamp = DateTime.UtcNow });
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Operation was cancelled");
                return StatusCode(499, "Operation cancelled by client");
            }
        }

        // Example 3: Multiple concurrent async operations
        [HttpGet("concurrent")]
        public async Task<IActionResult> GetConcurrentData()
        {
            _logger.LogInformation("Starting concurrent async operations");

            var tasks = new[]
            {
                FetchDataFromService1Async(),
                FetchDataFromService2Async(),
                FetchDataFromService3Async()
            };

            var results = await Task.WhenAll(tasks);

            return Ok(new 
            { 
                Results = results,
                TotalItems = results.Sum(r => r.Items.Count),
                Timestamp = DateTime.UtcNow 
            });
        }

        // Example 4: Async with timeout
        [HttpGet("timeout")]
        public async Task<IActionResult> GetDataWithTimeout()
        {
            _logger.LogInformation("Starting async operation with timeout");

            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(5));

            try
            {
                var result = await ProcessWithTimeoutAsync(cts.Token);
                return Ok(new { Message = result, Timestamp = DateTime.UtcNow });
            }
            catch (OperationCanceledException)
            {
                _logger.LogWarning("Operation timed out after 5 seconds");
                return StatusCode(408, "Operation timed out");
            }
        }

        // Example 5: Async streaming response
        [HttpGet("stream")]
        public async IAsyncEnumerable<DataItem> StreamData(
            [System.Runtime.CompilerServices.EnumeratorCancellation] CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("Starting async streaming operation");

            for (int i = 1; i <= 10; i++)
            {
                if (cancellationToken.IsCancellationRequested)
                    yield break;

                await Task.Delay(500, cancellationToken);
                
                yield return new DataItem 
                { 
                    Id = i, 
                    Name = $"Item {i}",
                    Timestamp = DateTime.UtcNow
                };
            }

            _logger.LogInformation("Async streaming operation completed");
        }

        // Example 6: External HTTP call
        [HttpGet("external")]
        public async Task<IActionResult> GetExternalData()
        {
            _logger.LogInformation("Making external HTTP call");

            using var httpClient = _httpClientFactory.CreateClient();
            httpClient.Timeout = TimeSpan.FromSeconds(10);

            try
            {
                var response = await httpClient.GetStringAsync("https://jsonplaceholder.typicode.com/posts/1");
                
                return Ok(new 
                { 
                    ExternalData = response,
                    RetrievedAt = DateTime.UtcNow 
                });
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "Failed to fetch external data");
                return StatusCode(502, "Failed to fetch external data");
            }
            catch (TaskCanceledException)
            {
                _logger.LogError("External request timed out");
                return StatusCode(504, "External request timed out");
            }
        }

        // Helper methods
        private async Task<string> ProcessDataAsync()
        {
            await Task.Delay(1000); // Simulate async work
            return "Data processed successfully";
        }

        private async Task<string> ProcessLongRunningOperationAsync(CancellationToken cancellationToken)
        {
            for (int i = 0; i < 10; i++)
            {
                cancellationToken.ThrowIfCancellationRequested();
                await Task.Delay(1000, cancellationToken);
            }
            return "Long running operation completed";
        }

        private async Task<ServiceData> FetchDataFromService1Async()
        {
            await Task.Delay(800);
            return new ServiceData 
            { 
                ServiceName = "Service1",
                Items = new List<string> { "Item1", "Item2", "Item3" }
            };
        }

        private async Task<ServiceData> FetchDataFromService2Async()
        {
            await Task.Delay(1200);
            return new ServiceData 
            { 
                ServiceName = "Service2",
                Items = new List<string> { "ItemA", "ItemB" }
            };
        }

        private async Task<ServiceData> FetchDataFromService3Async()
        {
            await Task.Delay(600);
            return new ServiceData 
            { 
                ServiceName = "Service3",
                Items = new List<string> { "ItemX", "ItemY", "ItemZ", "ItemW" }
            };
        }

        private async Task<string> ProcessWithTimeoutAsync(CancellationToken cancellationToken)
        {
            // Simulate a long operation that might timeout
            await Task.Delay(3000, cancellationToken);
            return "Operation completed within timeout";
        }
    }

    // Data models
    public class DataItem
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public DateTime Timestamp { get; set; }
    }

    public class ServiceData
    {
        public string ServiceName { get; set; } = string.Empty;
        public List<string> Items { get; set; } = new();
    }
}