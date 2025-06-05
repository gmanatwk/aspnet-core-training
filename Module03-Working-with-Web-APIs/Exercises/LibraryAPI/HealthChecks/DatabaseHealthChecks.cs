using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using LibraryAPI.Data;

namespace LibraryAPI.HealthChecks
{
    public class DatabaseHealthCheck : IHealthCheck
    {
        private readonly LibraryContext _context;

        public DatabaseHealthCheck(LibraryContext context)
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
