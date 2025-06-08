namespace DebuggingDemo.Models;

/// <summary>
/// Represents diagnostic information about the application
/// </summary>
public class DiagnosticInfo
{
    public string ApplicationName { get; set; } = string.Empty;
    public string Version { get; set; } = string.Empty;
    public string Environment { get; set; } = string.Empty;
    public DateTime StartTime { get; set; }
    public TimeSpan Uptime => DateTime.UtcNow - StartTime;
    public string MachineName { get; set; } = string.Empty;
    public int ProcessId { get; set; }
    public long WorkingSetMemory { get; set; }
    public long GCTotalMemory { get; set; }
    public int ThreadCount { get; set; }
    public Dictionary<string, object> AdditionalInfo { get; set; } = new();
}



/// <summary>
/// Represents a log entry for structured logging
/// </summary>
public class LogEntry
{
    public DateTime Timestamp { get; set; }
    public string Level { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string? Exception { get; set; }
    public string RequestId { get; set; } = string.Empty;
    public string? UserId { get; set; }
    public Dictionary<string, object> Properties { get; set; } = new();
}

/// <summary>
/// Represents health check results summary
/// </summary>
public class HealthCheckSummary
{
    public string Status { get; set; } = string.Empty;
    public TimeSpan TotalDuration { get; set; }
    public Dictionary<string, HealthCheckEntry> Entries { get; set; } = new();
}

public class HealthCheckEntry
{
    public string Status { get; set; } = string.Empty;
    public string? Description { get; set; }
    public TimeSpan Duration { get; set; }
    public string? Exception { get; set; }
    public Dictionary<string, object> Data { get; set; } = new();
}
