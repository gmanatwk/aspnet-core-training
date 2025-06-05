using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace RestfulAPI.HealthChecks
{
    public class ApiHealthCheck : IHealthCheck
    {
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _configuration;

        public ApiHealthCheck(IHttpClientFactory httpClientFactory, IConfiguration configuration)
        {
            _httpClientFactory = httpClientFactory;
            _configuration = configuration;
        }

        public async Task<HealthCheckResult> CheckHealthAsync(
            HealthCheckContext context,
            CancellationToken cancellationToken = default)
        {
            try
            {
                // For this demo, we'll simply check if we can create an HTTP client
                // In a real scenario, you might check external dependencies
                using var client = _httpClientFactory.CreateClient();
                
                // Simple check - if we can create a client, consider it healthy
                return HealthCheckResult.Healthy("API is responding");
            }
            catch (Exception ex)
            {
                return HealthCheckResult.Unhealthy("API is not responding", ex);
            }
        }
    }
}