using MemoryOptimization.Services;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;

namespace MemoryOptimization.Controllers;

[ApiController]
[Route("api/[controller]")]
public class StringProcessingController : ControllerBase
{
    private readonly IStringProcessor _inefficientProcessor;
    private readonly OptimizedStringProcessor _optimizedProcessor;
    private readonly SpanStringProcessor _spanProcessor;
    private readonly ILogger<StringProcessingController> _logger;

    public StringProcessingController(
        IStringProcessor inefficientProcessor,
        OptimizedStringProcessor optimizedProcessor,
        SpanStringProcessor spanProcessor,
        ILogger<StringProcessingController> logger)
    {
        _inefficientProcessor = inefficientProcessor;
        _optimizedProcessor = optimizedProcessor;
        _spanProcessor = spanProcessor;
        _logger = logger;
    }

    [HttpPost("inefficient")]
    public ActionResult<object> ProcessStringInefficient([FromBody] string input)
    {
        var sw = Stopwatch.StartNew();
        var gcBefore = GC.GetTotalMemory(false);

        try
        {
            var result = _inefficientProcessor.Process(input);
            sw.Stop();
            
            var gcAfter = GC.GetTotalMemory(false);
            var memoryAllocated = gcAfter - gcBefore;

            _logger.LogInformation("Inefficient string processing completed in {ElapsedMs}ms", sw.ElapsedMilliseconds);

            return Ok(new
            {
                Result = result,
                ExecutionTimeMs = sw.ElapsedMilliseconds,
                MemoryAllocatedBytes = memoryAllocated,
                ProcessingType = "Inefficient (Multiple String Allocations)"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in inefficient string processing");
            return StatusCode(500, "Error in string processing");
        }
    }

    [HttpPost("optimized")]
    public ActionResult<object> ProcessStringOptimized([FromBody] string input)
    {
        var sw = Stopwatch.StartNew();
        var gcBefore = GC.GetTotalMemory(false);

        try
        {
            var result = _optimizedProcessor.Process(input);
            sw.Stop();
            
            var gcAfter = GC.GetTotalMemory(false);
            var memoryAllocated = gcAfter - gcBefore;

            _logger.LogInformation("Optimized string processing completed in {ElapsedMs}ms", sw.ElapsedMilliseconds);

            return Ok(new
            {
                Result = result,
                ExecutionTimeMs = sw.ElapsedMilliseconds,
                MemoryAllocatedBytes = memoryAllocated,
                ProcessingType = "Optimized (StringBuilder)"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in optimized string processing");
            return StatusCode(500, "Error in string processing");
        }
    }

    [HttpPost("span")]
    public ActionResult<object> ProcessStringSpan([FromBody] string input)
    {
        var sw = Stopwatch.StartNew();
        var gcBefore = GC.GetTotalMemory(false);

        try
        {
            var result = _spanProcessor.Process(input);
            sw.Stop();
            
            var gcAfter = GC.GetTotalMemory(false);
            var memoryAllocated = gcAfter - gcBefore;

            _logger.LogInformation("Span string processing completed in {ElapsedMs}ms", sw.ElapsedMilliseconds);

            return Ok(new
            {
                Result = result,
                ExecutionTimeMs = sw.ElapsedMilliseconds,
                MemoryAllocatedBytes = memoryAllocated,
                ProcessingType = "Span-based (ArrayPool + Zero Allocations)"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in span string processing");
            return StatusCode(500, "Error in string processing");
        }
    }

    [HttpPost("compare")]
    public ActionResult<object> CompareStringProcessing([FromBody] string input)
    {
        var results = new Dictionary<string, object>();

        // Test inefficient approach
        try
        {
            var sw1 = Stopwatch.StartNew();
            var gcBefore1 = GC.GetTotalMemory(false);
            var result1 = _inefficientProcessor.Process(input);
            sw1.Stop();
            var gcAfter1 = GC.GetTotalMemory(false);

            results["Inefficient"] = new
            {
                ExecutionTimeMs = sw1.ElapsedMilliseconds,
                MemoryAllocatedBytes = gcAfter1 - gcBefore1,
                ResultLength = result1.Length
            };
        }
        catch (Exception ex)
        {
            results["Inefficient"] = new { Error = ex.Message };
        }

        // Test optimized approach
        try
        {
            var sw2 = Stopwatch.StartNew();
            var gcBefore2 = GC.GetTotalMemory(false);
            var result2 = _optimizedProcessor.Process(input);
            sw2.Stop();
            var gcAfter2 = GC.GetTotalMemory(false);

            results["Optimized"] = new
            {
                ExecutionTimeMs = sw2.ElapsedMilliseconds,
                MemoryAllocatedBytes = gcAfter2 - gcBefore2,
                ResultLength = result2.Length
            };
        }
        catch (Exception ex)
        {
            results["Optimized"] = new { Error = ex.Message };
        }

        // Test span approach
        try
        {
            var sw3 = Stopwatch.StartNew();
            var gcBefore3 = GC.GetTotalMemory(false);
            var result3 = _spanProcessor.Process(input);
            sw3.Stop();
            var gcAfter3 = GC.GetTotalMemory(false);

            results["Span"] = new
            {
                ExecutionTimeMs = sw3.ElapsedMilliseconds,
                MemoryAllocatedBytes = gcAfter3 - gcBefore3,
                ResultLength = result3.Length
            };
        }
        catch (Exception ex)
        {
            results["Span"] = new { Error = ex.Message };
        }

        return Ok(results);
    }
}

[ApiController]
[Route("api/[controller]")]
public class DataProcessingController : ControllerBase
{
    private readonly IDataProcessingService _dataProcessingService;
    private readonly ILogger<DataProcessingController> _logger;

    public DataProcessingController(
        IDataProcessingService dataProcessingService,
        ILogger<DataProcessingController> logger)
    {
        _dataProcessingService = dataProcessingService;
        _logger = logger;
    }

    [HttpPost("no-pooling")]
    public ActionResult<object> ProcessWithoutPooling([FromBody] byte[] data)
    {
        var sw = Stopwatch.StartNew();
        var gcBefore = GC.GetTotalMemory(false);

        try
        {
            var result = _dataProcessingService.ProcessWithoutPooling(data);
            sw.Stop();
            
            var gcAfter = GC.GetTotalMemory(false);
            var memoryAllocated = gcAfter - gcBefore;

            _logger.LogInformation("Processing without pooling completed in {ElapsedMs}ms", sw.ElapsedMilliseconds);

            return Ok(new
            {
                ResultLength = result.Length,
                ExecutionTimeMs = sw.ElapsedMilliseconds,
                MemoryAllocatedBytes = memoryAllocated,
                ProcessingType = "Without Object Pooling"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in processing without pooling");
            return StatusCode(500, "Error in data processing");
        }
    }

    [HttpPost("with-pooling")]
    public ActionResult<object> ProcessWithPooling([FromBody] byte[] data)
    {
        var sw = Stopwatch.StartNew();
        var gcBefore = GC.GetTotalMemory(false);

        try
        {
            var result = _dataProcessingService.ProcessWithPooling(data);
            sw.Stop();
            
            var gcAfter = GC.GetTotalMemory(false);
            var memoryAllocated = gcAfter - gcBefore;

            _logger.LogInformation("Processing with pooling completed in {ElapsedMs}ms", sw.ElapsedMilliseconds);

            return Ok(new
            {
                ResultLength = result.Length,
                ExecutionTimeMs = sw.ElapsedMilliseconds,
                MemoryAllocatedBytes = memoryAllocated,
                ProcessingType = "With Object Pooling"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in processing with pooling");
            return StatusCode(500, "Error in data processing");
        }
    }

    [HttpPost("compare")]
    public ActionResult<object> CompareProcessing([FromBody] byte[] data)
    {
        var results = new Dictionary<string, object>();

        // Test without pooling
        try
        {
            var sw1 = Stopwatch.StartNew();
            var gcBefore1 = GC.GetTotalMemory(false);
            var result1 = _dataProcessingService.ProcessWithoutPooling(data);
            sw1.Stop();
            var gcAfter1 = GC.GetTotalMemory(false);

            results["WithoutPooling"] = new
            {
                ExecutionTimeMs = sw1.ElapsedMilliseconds,
                MemoryAllocatedBytes = gcAfter1 - gcBefore1,
                ResultLength = result1.Length
            };
        }
        catch (Exception ex)
        {
            results["WithoutPooling"] = new { Error = ex.Message };
        }

        // Test with pooling
        try
        {
            var sw2 = Stopwatch.StartNew();
            var gcBefore2 = GC.GetTotalMemory(false);
            var result2 = _dataProcessingService.ProcessWithPooling(data);
            sw2.Stop();
            var gcAfter2 = GC.GetTotalMemory(false);

            results["WithPooling"] = new
            {
                ExecutionTimeMs = sw2.ElapsedMilliseconds,
                MemoryAllocatedBytes = gcAfter2 - gcBefore2,
                ResultLength = result2.Length
            };
        }
        catch (Exception ex)
        {
            results["WithPooling"] = new { Error = ex.Message };
        }

        return Ok(results);
    }
}

[ApiController]
[Route("api/[controller]")]
public class BufferProcessingController : ControllerBase
{
    private readonly IBufferProcessor _inefficientProcessor;
    private readonly OptimizedBufferProcessor _optimizedProcessor;
    private readonly ILogger<BufferProcessingController> _logger;

    public BufferProcessingController(
        IBufferProcessor inefficientProcessor,
        OptimizedBufferProcessor optimizedProcessor,
        ILogger<BufferProcessingController> logger)
    {
        _inefficientProcessor = inefficientProcessor;
        _optimizedProcessor = optimizedProcessor;
        _logger = logger;
    }

    [HttpPost("inefficient")]
    public ActionResult<object> ProcessBufferInefficient([FromBody] byte[] input)
    {
        var sw = Stopwatch.StartNew();
        var gcBefore = GC.GetTotalMemory(false);

        try
        {
            var result = _inefficientProcessor.ProcessBuffer(input);
            sw.Stop();
            
            var gcAfter = GC.GetTotalMemory(false);
            var memoryAllocated = gcAfter - gcBefore;

            _logger.LogInformation("Inefficient buffer processing completed in {ElapsedMs}ms", sw.ElapsedMilliseconds);

            return Ok(new
            {
                ResultLength = result.Length,
                ExecutionTimeMs = sw.ElapsedMilliseconds,
                MemoryAllocatedBytes = memoryAllocated,
                ProcessingType = "Inefficient (Multiple Array Allocations)"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in inefficient buffer processing");
            return StatusCode(500, "Error in buffer processing");
        }
    }

    [HttpPost("optimized")]
    public ActionResult<object> ProcessBufferOptimized([FromBody] byte[] input)
    {
        var sw = Stopwatch.StartNew();
        var gcBefore = GC.GetTotalMemory(false);

        try
        {
            var result = _optimizedProcessor.ProcessBuffer(input);
            sw.Stop();
            
            var gcAfter = GC.GetTotalMemory(false);
            var memoryAllocated = gcAfter - gcBefore;

            _logger.LogInformation("Optimized buffer processing completed in {ElapsedMs}ms", sw.ElapsedMilliseconds);

            return Ok(new
            {
                ResultLength = result.Length,
                ExecutionTimeMs = sw.ElapsedMilliseconds,
                MemoryAllocatedBytes = memoryAllocated,
                ProcessingType = "Optimized (ArrayPool)"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in optimized buffer processing");
            return StatusCode(500, "Error in buffer processing");
        }
    }

    [HttpPost("compare")]
    public ActionResult<object> CompareBufferProcessing([FromBody] byte[] input)
    {
        var results = new Dictionary<string, object>();

        // Test inefficient approach
        try
        {
            var sw1 = Stopwatch.StartNew();
            var gcBefore1 = GC.GetTotalMemory(false);
            var result1 = _inefficientProcessor.ProcessBuffer(input);
            sw1.Stop();
            var gcAfter1 = GC.GetTotalMemory(false);

            results["Inefficient"] = new
            {
                ExecutionTimeMs = sw1.ElapsedMilliseconds,
                MemoryAllocatedBytes = gcAfter1 - gcBefore1,
                ResultLength = result1.Length
            };
        }
        catch (Exception ex)
        {
            results["Inefficient"] = new { Error = ex.Message };
        }

        // Test optimized approach
        try
        {
            var sw2 = Stopwatch.StartNew();
            var gcBefore2 = GC.GetTotalMemory(false);
            var result2 = _optimizedProcessor.ProcessBuffer(input);
            sw2.Stop();
            var gcAfter2 = GC.GetTotalMemory(false);

            results["Optimized"] = new
            {
                ExecutionTimeMs = sw2.ElapsedMilliseconds,
                MemoryAllocatedBytes = gcAfter2 - gcBefore2,
                ResultLength = result2.Length
            };
        }
        catch (Exception ex)
        {
            results["Optimized"] = new { Error = ex.Message };
        }

        return Ok(results);
    }
}

[ApiController]
[Route("api/[controller]")]
public class MemoryController : ControllerBase
{
    private readonly IMemoryEfficientService _memoryService;
    private readonly ILogger<MemoryController> _logger;

    public MemoryController(
        IMemoryEfficientService memoryService,
        ILogger<MemoryController> logger)
    {
        _memoryService = memoryService;
        _logger = logger;
    }

    [HttpGet("gc-info")]
    public ActionResult<object> GetGarbageCollectionInfo()
    {
        return Ok(new
        {
            TotalMemoryBytes = GC.GetTotalMemory(false),
            Gen0Collections = GC.CollectionCount(0),
            Gen1Collections = GC.CollectionCount(1),
            Gen2Collections = GC.CollectionCount(2),
            MaxGeneration = GC.MaxGeneration,
            IsServerGC = GCSettings.IsServerGC,
            LatencyMode = GCSettings.LatencyMode.ToString()
        });
    }

    [HttpPost("force-gc")]
    public ActionResult<object> ForceGarbageCollection()
    {
        var beforeMemory = GC.GetTotalMemory(false);
        
        GC.Collect();
        GC.WaitForPendingFinalizers();
        GC.Collect();
        
        var afterMemory = GC.GetTotalMemory(false);
        var freedMemory = beforeMemory - afterMemory;

        return Ok(new
        {
            MemoryBeforeBytes = beforeMemory,
            MemoryAfterBytes = afterMemory,
            MemoryFreedBytes = freedMemory,
            Message = "Garbage collection completed"
        });
    }

    [HttpPost("test-allocations")]
    public ActionResult<object> TestLargeAllocations([FromQuery] int arraySize = 1000000)
    {
        var results = new List<object>();
        var beforeMemory = GC.GetTotalMemory(false);

        // Test large object allocation
        try
        {
            var largeArray = new byte[arraySize];
            for (int i = 0; i < Math.Min(largeArray.Length, 1000); i++)
            {
                largeArray[i] = (byte)(i % 256);
            }

            var afterMemory = GC.GetTotalMemory(false);
            
            results.Add(new
            {
                TestType = "Large Array Allocation",
                ArraySize = arraySize,
                MemoryAllocatedBytes = afterMemory - beforeMemory,
                Success = true
            });
        }
        catch (OutOfMemoryException ex)
        {
            results.Add(new
            {
                TestType = "Large Array Allocation",
                ArraySize = arraySize,
                Error = ex.Message,
                Success = false
            });
        }

        return Ok(new
        {
            Results = results,
            FinalMemoryBytes = GC.GetTotalMemory(false)
        });
    }
}
