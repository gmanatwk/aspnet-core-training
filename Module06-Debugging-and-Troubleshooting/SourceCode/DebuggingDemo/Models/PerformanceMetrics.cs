namespace DebuggingDemo.Models;

public class PerformanceMetrics
{
    public string EndpointName { get; set; } = string.Empty;
    public long ElapsedMilliseconds { get; set; }
    public int StatusCode { get; set; }
    public DateTime Timestamp { get; set; }
    public string RequestMethod { get; set; } = string.Empty;
    public string RequestPath { get; set; } = string.Empty;
    public long MemoryBefore { get; set; }
    public long MemoryAfter { get; set; }
    public long MemoryDifference => MemoryAfter - MemoryBefore;
    public string? UserId { get; set; }
    public string? UserAgent { get; set; }
    public int RequestSize { get; set; }
    public int ResponseSize { get; set; }
    public Dictionary<string, object> CustomMetrics { get; set; } = new();
}