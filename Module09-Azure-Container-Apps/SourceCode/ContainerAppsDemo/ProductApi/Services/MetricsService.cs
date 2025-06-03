using Microsoft.ApplicationInsights;

namespace ProductApi.Services;

public class MetricsService
{
    private readonly TelemetryClient _telemetryClient;
    private readonly ILogger<MetricsService> _logger;

    public MetricsService(TelemetryClient telemetryClient, ILogger<MetricsService> logger)
    {
        _telemetryClient = telemetryClient;
        _logger = logger;
    }

    public void TrackBusinessMetric(string metricName, double value, IDictionary<string, string>? properties = null)
    {
        try
        {
            _telemetryClient.TrackMetric(metricName, value, properties);
            _logger.LogDebug("Tracked metric {MetricName} with value {Value}", metricName, value);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to track metric {MetricName}", metricName);
        }
    }

    public void TrackUserActivity(string activity, string userId, IDictionary<string, string>? additionalProperties = null)
    {
        try
        {
            var properties = new Dictionary<string, string>
            {
                ["UserId"] = userId,
                ["Activity"] = activity,
                ["Timestamp"] = DateTimeOffset.UtcNow.ToString("O"),
                ["Environment"] = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Unknown",
                ["MachineName"] = Environment.MachineName
            };

            if (additionalProperties != null)
            {
                foreach (var prop in additionalProperties)
                {
                    properties[prop.Key] = prop.Value;
                }
            }

            _telemetryClient.TrackEvent("UserActivity", properties);
            _logger.LogDebug("Tracked user activity {Activity} for user {UserId}", activity, userId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to track user activity {Activity}", activity);
        }
    }

    public void TrackPerformanceCounter(string counterName, double value)
    {
        try
        {
            var metricName = $"Performance.{counterName}";
            var properties = new Dictionary<string, string>
            {
                ["Counter"] = counterName,
                ["Environment"] = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Unknown"
            };

            _telemetryClient.TrackMetric(metricName, value, properties);
            _logger.LogDebug("Tracked performance counter {CounterName} with value {Value}", counterName, value);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to track performance counter {CounterName}", counterName);
        }
    }

    public void TrackCustomEvent(string eventName, IDictionary<string, string>? properties = null, IDictionary<string, double>? metrics = null)
    {
        try
        {
            var eventProperties = properties ?? new Dictionary<string, string>();
            
            // Add standard properties
            eventProperties["Environment"] = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Unknown";
            eventProperties["MachineName"] = Environment.MachineName;
            eventProperties["Timestamp"] = DateTimeOffset.UtcNow.ToString("O");

            _telemetryClient.TrackEvent(eventName, eventProperties, metrics);
            _logger.LogDebug("Tracked custom event {EventName}", eventName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to track custom event {EventName}", eventName);
        }
    }

    public void TrackDependency(string dependencyType, string target, string dependencyName, string data, DateTimeOffset startTime, TimeSpan duration, bool success)
    {
        try
        {
            _telemetryClient.TrackDependency(dependencyType, target, dependencyName, data, startTime, duration, string.Empty, success);
            _logger.LogDebug("Tracked dependency {DependencyName} to {Target} - Success: {Success}, Duration: {Duration}ms", 
                dependencyName, target, success, duration.TotalMilliseconds);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to track dependency {DependencyName}", dependencyName);
        }
    }

    public void TrackException(Exception exception, IDictionary<string, string>? properties = null)
    {
        try
        {
            var exceptionProperties = properties ?? new Dictionary<string, string>();
            
            // Add standard properties
            exceptionProperties["Environment"] = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Unknown";
            exceptionProperties["MachineName"] = Environment.MachineName;
            exceptionProperties["Timestamp"] = DateTimeOffset.UtcNow.ToString("O");

            _telemetryClient.TrackException(exception, exceptionProperties);
            _logger.LogDebug("Tracked exception {ExceptionType}: {ExceptionMessage}", exception.GetType().Name, exception.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to track exception");
        }
    }

    public void TrackTrace(string message, Microsoft.ApplicationInsights.DataContracts.SeverityLevel severityLevel, IDictionary<string, string>? properties = null)
    {
        try
        {
            var traceProperties = properties ?? new Dictionary<string, string>();
            
            // Add standard properties
            traceProperties["Environment"] = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Unknown";
            traceProperties["MachineName"] = Environment.MachineName;
            traceProperties["Timestamp"] = DateTimeOffset.UtcNow.ToString("O");

            _telemetryClient.TrackTrace(message, severityLevel, traceProperties);
            _logger.LogDebug("Tracked trace message with severity {Severity}", severityLevel);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to track trace message");
        }
    }

    // Business-specific metrics methods
    public void TrackApiRequest(string endpoint, TimeSpan duration, bool success, int statusCode)
    {
        var properties = new Dictionary<string, string>
        {
            ["Endpoint"] = endpoint,
            ["Success"] = success.ToString(),
            ["StatusCode"] = statusCode.ToString()
        };

        var metrics = new Dictionary<string, double>
        {
            ["Duration"] = duration.TotalMilliseconds,
            ["StatusCode"] = statusCode
        };

        TrackCustomEvent("ApiRequest", properties, metrics);
        TrackBusinessMetric("Api.Requests.Total", 1, properties);
        TrackBusinessMetric("Api.Requests.Duration", duration.TotalMilliseconds, properties);

        if (!success)
        {
            TrackBusinessMetric("Api.Requests.Errors", 1, properties);
        }
    }

    public void TrackServiceCall(string serviceName, string operation, TimeSpan duration, bool success)
    {
        var properties = new Dictionary<string, string>
        {
            ["ServiceName"] = serviceName,
            ["Operation"] = operation,
            ["Success"] = success.ToString()
        };

        var metrics = new Dictionary<string, double>
        {
            ["Duration"] = duration.TotalMilliseconds
        };

        TrackCustomEvent("ServiceCall", properties, metrics);
        TrackBusinessMetric($"Service.{serviceName}.Calls.Total", 1, properties);
        TrackBusinessMetric($"Service.{serviceName}.Calls.Duration", duration.TotalMilliseconds, properties);

        if (!success)
        {
            TrackBusinessMetric($"Service.{serviceName}.Calls.Errors", 1, properties);
        }
    }

    public void TrackResourceUsage()
    {
        try
        {
            var process = System.Diagnostics.Process.GetCurrentProcess();
            
            // Memory metrics
            var workingSet = process.WorkingSet64;
            var privateMemory = process.PrivateMemorySize64;
            
            TrackBusinessMetric("System.Memory.WorkingSet", workingSet / 1024.0 / 1024.0); // MB
            TrackBusinessMetric("System.Memory.PrivateMemory", privateMemory / 1024.0 / 1024.0); // MB
            
            // GC metrics
            var gen0Collections = GC.CollectionCount(0);
            var gen1Collections = GC.CollectionCount(1);
            var gen2Collections = GC.CollectionCount(2);
            var totalMemory = GC.GetTotalMemory(false);
            
            TrackBusinessMetric("System.GC.Gen0Collections", gen0Collections);
            TrackBusinessMetric("System.GC.Gen1Collections", gen1Collections);
            TrackBusinessMetric("System.GC.Gen2Collections", gen2Collections);
            TrackBusinessMetric("System.GC.TotalMemory", totalMemory / 1024.0 / 1024.0); // MB
            
            // Thread metrics
            var threadCount = process.Threads.Count;
            TrackBusinessMetric("System.Threads.Count", threadCount);
            
            _logger.LogDebug("Tracked resource usage metrics");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to track resource usage");
        }
    }
}
