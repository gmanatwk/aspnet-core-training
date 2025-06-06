using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using RestfulAPI.Data;

namespace RestfulAPI.HealthChecks
{
    public class ApiHealthCheck : IHealthCheck
    {
        private readonly ApplicationDbContext _context;

        public ApiHealthCheck(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<HealthCheckResult> CheckHealthAsync(
            HealthCheckContext context,
            CancellationToken cancellationToken = default)
        {
            try
            {
                // Check database connectivity
                await _context.Database.CanConnectAsync(cancellationToken);
                
                // You can add more checks here
                
                return HealthCheckResult.Healthy("API is healthy");
            }
            catch (Exception ex)
            {
                return HealthCheckResult.Unhealthy(
                    "API is unhealthy", 
                    exception: ex);
            }
        }
    }
}
