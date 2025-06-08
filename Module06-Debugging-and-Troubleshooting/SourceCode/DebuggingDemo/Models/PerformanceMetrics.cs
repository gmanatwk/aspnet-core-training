namespace DebuggingDemo.Models;

/// <summary>
/// Represents performance metrics for a request or system operation
/// </summary>
public class PerformanceMetrics
{
    // Core request identification
    public string RequestId { get; set; } = string.Empty;
    public string Method { get; set; } = string.Empty;
    public string Path { get; set; } = string.Empty;

    // Performance metrics
    public long ElapsedMilliseconds { get; set; }
    public int StatusCode { get; set; }
    public DateTime Timestamp { get; set; }

    // Memory metrics
    public long MemoryUsedBytes { get; set; }
    public long MemoryBefore { get; set; }
    public long MemoryAfter { get; set; }
    public long MemoryDifference => MemoryAfter - MemoryBefore;

    // Additional request details
    public string? UserId { get; set; }
    public string? UserAgent { get; set; }
    public int RequestSize { get; set; }
    public int ResponseSize { get; set; }

    // Extensible metrics
    public Dictionary<string, object> CustomMetrics { get; set; } = new();

    // Legacy property aliases for backward compatibility
    public string EndpointName
    {
        get => Path;
        set => Path = value;
    }

    public string RequestMethod
    {
        get => Method;
        set => Method = value;
    }

    public string RequestPath
    {
        get => Path;
        set => Path = value;
    }
}