using Microsoft.Extensions.ObjectPool;

namespace MemoryOptimization.Services;

/// <summary>
/// Expensive object that requires costly initialization
/// </summary>
public class ExpensiveObject
{
    private readonly byte[] _buffer;

    public ExpensiveObject(int bufferSize = 1024 * 1024) // 1MB buffer
    {
        _buffer = new byte[bufferSize];
        
        // Simulate expensive initialization
        for (int i = 0; i < _buffer.Length; i++)
        {
            _buffer[i] = (byte)(i % 256);
        }
    }

    public byte[] ProcessData(byte[] input)
    {
        if (input == null || input.Length == 0)
            return Array.Empty<byte>();

        // Simulate data processing
        var result = new byte[input.Length];
        for (int i = 0; i < input.Length; i++)
        {
            result[i] = (byte)(_buffer[i % _buffer.Length] ^ input[i]);
        }
        return result;
    }

    public void Reset()
    {
        // Reset state if needed for reuse
        // In this case, our object is stateless after initialization
    }
}

/// <summary>
/// Object pool policy for ExpensiveObject
/// </summary>
public class ExpensiveObjectPolicy : IPooledObjectPolicy<ExpensiveObject>
{
    public ExpensiveObject Create()
    {
        return new ExpensiveObject();
    }

    public bool Return(ExpensiveObject obj)
    {
        // Perform any cleanup here if needed
        obj.Reset();
        return true; // Return true to indicate the object can be reused
    }
}

public interface IDataProcessingService
{
    byte[] ProcessWithoutPooling(byte[] data);
    byte[] ProcessWithPooling(byte[] data);
}

/// <summary>
/// Service demonstrating object pooling vs. regular instantiation
/// </summary>
public class DataProcessingService : IDataProcessingService
{
    private readonly ObjectPool<ExpensiveObject> _objectPool;
    private readonly ILogger<DataProcessingService> _logger;

    public DataProcessingService(
        ObjectPool<ExpensiveObject> objectPool,
        ILogger<DataProcessingService> logger)
    {
        _objectPool = objectPool;
        _logger = logger;
    }

    /// <summary>
    /// Process data without object pooling (creates new instance each time)
    /// </summary>
    public byte[] ProcessWithoutPooling(byte[] data)
    {
        _logger.LogDebug("Processing data without pooling - creating new ExpensiveObject");
        
        // Create a new instance for each request (inefficient)
        var processor = new ExpensiveObject();
        return processor.ProcessData(data);
    }

    /// <summary>
    /// Process data with object pooling (reuses instances)
    /// </summary>
    public byte[] ProcessWithPooling(byte[] data)
    {
        _logger.LogDebug("Processing data with pooling - getting object from pool");
        
        // Get object from pool
        var processor = _objectPool.Get();
        
        try
        {
            return processor.ProcessData(data);
        }
        finally
        {
            // Return object to pool for reuse
            _objectPool.Return(processor);
        }
    }
}
