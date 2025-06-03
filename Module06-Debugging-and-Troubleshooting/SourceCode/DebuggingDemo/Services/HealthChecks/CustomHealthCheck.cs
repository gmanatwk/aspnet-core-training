using Microsoft.Extensions.Diagnostics.HealthChecks;
using System.Diagnostics;

namespace DebuggingDemo.Services.HealthChecks;

public class CustomHealthCheck : IHealthCheck
{
    private readonly ILogger<CustomHealthCheck> _logger;
    private readonly IConfiguration _configuration;

    public CustomHealthCheck(ILogger<CustomHealthCheck> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context, 
        CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogDebug("Running custom health checks");

            var checks = new Dictionary<string, bool>();
            var data = new Dictionary<string, object>();

            // Check 1: Memory usage
            var process = Process.GetCurrentProcess();
            var memoryUsageMB = process.WorkingSet64 / (1024 * 1024);
            var memoryThresholdMB = _configuration.GetValue<long>("HealthChecks:MemoryThresholdMB", 500);
            
            checks["MemoryUsage"] = memoryUsageMB < memoryThresholdMB;
            data["MemoryUsageMB"] = memoryUsageMB;
            data["MemoryThresholdMB"] = memoryThresholdMB;

            // Check 2: Disk space (simplified check)
            var currentDirectory = new DirectoryInfo(Environment.CurrentDirectory);
            var drive = new DriveInfo(currentDirectory.Root.FullName);
            var freeSpaceGB = drive.AvailableFreeSpace / (1024 * 1024 * 1024);
            var diskThresholdGB = _configuration.GetValue<long>("HealthChecks:DiskThresholdGB", 1);

            checks["DiskSpace"] = freeSpaceGB > diskThresholdGB;
            data["FreeSpaceGB"] = freeSpaceGB;
            data["DiskThresholdGB"] = diskThresholdGB;

            // Check 3: Thread count
            var threadCount = process.Threads.Count;
            var threadThreshold = _configuration.GetValue<int>("HealthChecks:ThreadThreshold", 100);

            checks["ThreadCount"] = threadCount < threadThreshold;
            data["ThreadCount"] = threadCount;
            data["ThreadThreshold"] = threadThreshold;

            // Check 4: GC pressure
            var gcGen2Collections = GC.CollectionCount(2);
            var gcThreshold = _configuration.GetValue<int>("HealthChecks:GCGen2Threshold", 100);

            checks["GCPressure"] = gcGen2Collections < gcThreshold;
            data["GCGen2Collections"] = gcGen2Collections;
            data["GCThreshold"] = gcThreshold;

            data["CheckedAt"] = DateTime.UtcNow;

            // Determine overall health
            var failedChecks = checks.Where(c => !c.Value).ToList();

            if (failedChecks.Count == 0)
            {
                _logger.LogDebug("All custom health checks passed");
                return HealthCheckResult.Healthy("All custom checks passed", data);
            }
            else if (failedChecks.Count <= 1)
            {
                _logger.LogWarning("Some custom health checks failed: {FailedChecks}", 
                    string.Join(", ", failedChecks.Select(c => c.Key)));
                
                data["FailedChecks"] = failedChecks.Select(c => c.Key).ToArray();
                return HealthCheckResult.Degraded("Some custom checks failed", null, data);
            }
            else
            {
                _logger.LogError("Multiple custom health checks failed: {FailedChecks}", 
                    string.Join(", ", failedChecks.Select(c => c.Key)));
                
                data["FailedChecks"] = failedChecks.Select(c => c.Key).ToArray();
                return HealthCheckResult.Unhealthy("Multiple custom checks failed", null, data);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Custom health check failed with exception");

            var data = new Dictionary<string, object>
            {
                ["Error"] = ex.Message,
                ["ExceptionType"] = ex.GetType().Name,
                ["CheckedAt"] = DateTime.UtcNow
            };

            return HealthCheckResult.Unhealthy("Custom health check failed", ex, data);
        }
    }
}
