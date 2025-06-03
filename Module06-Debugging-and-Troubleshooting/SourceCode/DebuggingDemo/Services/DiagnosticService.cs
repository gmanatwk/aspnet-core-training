using System.Diagnostics;
using System.Reflection;
using DebuggingDemo.Models;

namespace DebuggingDemo.Services;

public class DiagnosticService
{
    private readonly ILogger<DiagnosticService> _logger;
    private readonly IConfiguration _configuration;
    private static readonly DateTime StartTime = DateTime.UtcNow;

    public DiagnosticService(ILogger<DiagnosticService> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
    }

    public DiagnosticInfo GetDiagnosticInfo()
    {
        try
        {
            var process = Process.GetCurrentProcess();
            var assembly = Assembly.GetExecutingAssembly();

            var diagnosticInfo = new DiagnosticInfo
            {
                ApplicationName = assembly.GetName().Name ?? "Unknown",
                Version = assembly.GetName().Version?.ToString() ?? "Unknown",
                Environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Unknown",
                StartTime = StartTime,
                MachineName = Environment.MachineName,
                ProcessId = process.Id,
                WorkingSetMemory = process.WorkingSet64,
                GCTotalMemory = GC.GetTotalMemory(false),
                ThreadCount = process.Threads.Count,
                AdditionalInfo = new Dictionary<string, object>
                {
                    ["OSVersion"] = Environment.OSVersion.ToString(),
                    ["ProcessorCount"] = Environment.ProcessorCount,
                    ["UserInteractive"] = Environment.UserInteractive,
                    ["CLRVersion"] = Environment.Version.ToString(),
                    ["CurrentDirectory"] = Environment.CurrentDirectory,
                    ["Is64BitProcess"] = Environment.Is64BitProcess,
                    ["Is64BitOS"] = Environment.Is64BitOperatingSystem
                }
            };

            _logger.LogDebug("Generated diagnostic info for application: {ApplicationName}", 
                diagnosticInfo.ApplicationName);

            return diagnosticInfo;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error generating diagnostic information");
            throw;
        }
    }

    public async Task<List<LogEntry>> GetRecentLogsAsync(int count = 50)
    {
        try
        {
            _logger.LogDebug("Retrieving recent log entries, count: {Count}", count);

            // In a real application, you would retrieve logs from your logging system
            // For demo purposes, we'll create some sample log entries
            var logs = new List<LogEntry>();

            for (int i = 0; i < Math.Min(count, 10); i++)
            {
                logs.Add(new LogEntry
                {
                    Timestamp = DateTime.UtcNow.AddMinutes(-i * 5),
                    Level = GetRandomLogLevel(),
                    Message = $"Sample log entry {i + 1}",
                    RequestId = Guid.NewGuid().ToString(),
                    Properties = new Dictionary<string, object>
                    {
                        ["Source"] = "DiagnosticService",
                        ["Index"] = i
                    }
                });
            }

            _logger.LogDebug("Retrieved {Count} log entries", logs.Count);

            return await Task.FromResult(logs);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving recent logs");
            throw;
        }
    }

    public PerformanceMetrics GetPerformanceSnapshot()
    {
        try
        {
            var process = Process.GetCurrentProcess();

            var metrics = new PerformanceMetrics
            {
                RequestId = "SYSTEM",
                Method = "DIAGNOSTIC",
                Path = "/diagnostics/performance",
                StatusCode = 200,
                ElapsedMilliseconds = 0, // Not applicable for system snapshot
                MemoryUsedBytes = GC.GetTotalMemory(false),
                Timestamp = DateTime.UtcNow,
                CustomMetrics = new Dictionary<string, object>
                {
                    ["WorkingSetMemory"] = process.WorkingSet64,
                    ["PrivateMemory"] = process.PrivateMemorySize64,
                    ["VirtualMemory"] = process.VirtualMemorySize64,
                    ["ThreadCount"] = process.Threads.Count,
                    ["HandleCount"] = process.HandleCount,
                    ["GC.Gen0Collections"] = GC.CollectionCount(0),
                    ["GC.Gen1Collections"] = GC.CollectionCount(1),
                    ["GC.Gen2Collections"] = GC.CollectionCount(2)
                }
            };

            _logger.LogDebug("Generated performance snapshot with {MetricCount} metrics", 
                metrics.CustomMetrics.Count);

            return metrics;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error generating performance snapshot");
            throw;
        }
    }

    public async Task<string> RunDiagnosticTestAsync(string testName)
    {
        try
        {
            _logger.LogInformation("Running diagnostic test: {TestName}", testName);

            var result = testName.ToLowerInvariant() switch
            {
                "memory" => await RunMemoryTest(),
                "performance" => await RunPerformanceTest(),
                "exception" => await RunExceptionTest(),
                "logging" => await RunLoggingTest(),
                _ => throw new ArgumentException($"Unknown test: {testName}")
            };

            _logger.LogInformation("Diagnostic test {TestName} completed: {Result}", testName, result);

            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Diagnostic test {TestName} failed", testName);
            throw;
        }
    }

    private async Task<string> RunMemoryTest()
    {
        var beforeMemory = GC.GetTotalMemory(false);
        
        // Allocate some memory
        var data = new byte[1024 * 1024]; // 1MB
        Array.Fill(data, (byte)1);
        
        var afterMemory = GC.GetTotalMemory(false);
        
        // Force garbage collection
        GC.Collect();
        GC.WaitForPendingFinalizers();
        
        var afterGCMemory = GC.GetTotalMemory(true);
        
        return await Task.FromResult($"Memory test completed. Before: {beforeMemory}, After: {afterMemory}, After GC: {afterGCMemory}");
    }

    private async Task<string> RunPerformanceTest()
    {
        var stopwatch = Stopwatch.StartNew();
        
        // Simulate some work
        await Task.Delay(100);
        
        // CPU intensive task
        var sum = 0;
        for (int i = 0; i < 1000000; i++)
        {
            sum += i;
        }
        
        stopwatch.Stop();
        
        return $"Performance test completed in {stopwatch.ElapsedMilliseconds}ms. Sum: {sum}";
    }

    private async Task<string> RunExceptionTest()
    {
        try
        {
            // This will throw an exception for testing
            throw new InvalidOperationException("This is a test exception for diagnostic purposes");
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Test exception caught as expected");
            return await Task.FromResult($"Exception test completed. Caught: {ex.GetType().Name}");
        }
    }

    private async Task<string> RunLoggingTest()
    {
        _logger.LogTrace("Trace level log message");
        _logger.LogDebug("Debug level log message");
        _logger.LogInformation("Information level log message");
        _logger.LogWarning("Warning level log message");
        _logger.LogError("Error level log message");
        _logger.LogCritical("Critical level log message");
        
        return await Task.FromResult("Logging test completed. All log levels tested.");
    }

    private static string GetRandomLogLevel()
    {
        var levels = new[] { "Debug", "Information", "Warning", "Error" };
        var random = new Random();
        return levels[random.Next(levels.Length)];
    }
}
