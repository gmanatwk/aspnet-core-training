using Microsoft.Extensions.Diagnostics.HealthChecks;
using RestfulAPI.Data;
using Microsoft.EntityFrameworkCore;

namespace RestfulAPI.HealthChecks
{
    public class DatabaseHealthCheck : IHealthCheck
    {
        private readonly ApplicationDbContext _context;

        public DatabaseHealthCheck(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<HealthCheckResult> CheckHealthAsync(
            HealthCheckContext context,
            CancellationToken cancellationToken = default)
        {
            try
            {
                // Try to access the database
                var canConnect = await _context.Database.CanConnectAsync(cancellationToken);

                if (canConnect)
                {
                    var productCount = await _context.Products.CountAsync(cancellationToken);
                    return HealthCheckResult.Healthy(
                        $"Database is accessible. Products count: {productCount}");
                }

                return HealthCheckResult.Unhealthy("Cannot connect to database");
            }
            catch (Exception ex)
            {
                return HealthCheckResult.Unhealthy(
                    "Database check failed",
                    exception: ex);
            }
        }
    }
}