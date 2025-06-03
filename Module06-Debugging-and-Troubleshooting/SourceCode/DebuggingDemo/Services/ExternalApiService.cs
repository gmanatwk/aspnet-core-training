namespace DebuggingDemo.Services;

public interface IExternalApiService
{
    Task<string> GetDataAsync(int id);
    Task<List<object>> GetPostsAsync();
    Task<bool> CheckServiceHealthAsync();
}

public class ExternalApiService : IExternalApiService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<ExternalApiService> _logger;
    private readonly IConfiguration _configuration;

    public ExternalApiService(HttpClient httpClient, ILogger<ExternalApiService> logger, IConfiguration configuration)
    {
        _httpClient = httpClient;
        _logger = logger;
        _configuration = configuration;
    }

    public async Task<string> GetDataAsync(int id)
    {
        try
        {
            _logger.LogInformation("Fetching data for ID: {Id}", id);

            if (id <= 0)
            {
                throw new ArgumentException("ID must be greater than 0", nameof(id));
            }

            var response = await _httpClient.GetAsync($"posts/{id}");
            
            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning("External API returned non-success status: {StatusCode} for ID: {Id}", 
                    response.StatusCode, id);
                throw new HttpRequestException($"External service returned {response.StatusCode}");
            }

            var content = await response.Content.ReadAsStringAsync();
            
            _logger.LogInformation("Successfully fetched data for ID: {Id}, Content length: {Length}", 
                id, content.Length);

            return content;
        }
        catch (TaskCanceledException ex) when (ex.InnerException is TimeoutException)
        {
            _logger.LogError(ex, "Timeout occurred while fetching data for ID: {Id}", id);
            throw new TimeoutException($"Request timed out for ID: {id}");
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "HTTP error occurred while fetching data for ID: {Id}", id);
            throw;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error occurred while fetching data for ID: {Id}", id);
            throw;
        }
    }

    public async Task<List<object>> GetPostsAsync()
    {
        try
        {
            _logger.LogInformation("Fetching all posts from external API");

            var response = await _httpClient.GetAsync("posts");
            response.EnsureSuccessStatusCode();

            var content = await response.Content.ReadAsStringAsync();
            var posts = System.Text.Json.JsonSerializer.Deserialize<List<object>>(content);

            _logger.LogInformation("Successfully fetched {Count} posts", posts?.Count ?? 0);

            return posts ?? new List<object>();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while fetching posts");
            throw;
        }
    }

    public async Task<bool> CheckServiceHealthAsync()
    {
        try
        {
            _logger.LogDebug("Checking external service health");

            var response = await _httpClient.GetAsync("posts/1");
            var isHealthy = response.IsSuccessStatusCode;

            _logger.LogDebug("External service health check result: {IsHealthy}", isHealthy);

            return isHealthy;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "External service health check failed");
            return false;
        }
    }
}
