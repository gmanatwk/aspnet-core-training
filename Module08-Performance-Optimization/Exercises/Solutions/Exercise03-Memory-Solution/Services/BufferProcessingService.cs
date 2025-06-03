using System.Buffers;

namespace MemoryOptimization.Services;

public interface IBufferProcessor
{
    byte[] ProcessBuffer(byte[] input);
}

/// <summary>
/// Inefficient buffer processor that allocates temporary arrays
/// </summary>
public class IneffientBufferProcessor : IBufferProcessor
{
    public byte[] ProcessBuffer(byte[] input)
    {
        if (input == null || input.Length == 0)
            return Array.Empty<byte>();

        // Allocate temporary buffers for processing
        var tempBuffer1 = new byte[input.Length];
        var tempBuffer2 = new byte[input.Length];

        // First transformation
        for (int i = 0; i < input.Length; i++)
        {
            tempBuffer1[i] = (byte)(input[i] + 1);
        }

        // Second transformation
        for (int i = 0; i < input.Length; i++)
        {
            tempBuffer2[i] = (byte)(tempBuffer1[i] * 2);
        }

        // Final transformation
        var result = new byte[input.Length];
        for (int i = 0; i < input.Length; i++)
        {
            result[i] = (byte)(tempBuffer2[i] - 1);
        }

        return result;
    }
}

/// <summary>
/// Optimized buffer processor using ArrayPool<T>
/// </summary>
public class OptimizedBufferProcessor : IBufferProcessor
{
    public byte[] ProcessBuffer(byte[] input)
    {
        if (input == null || input.Length == 0)
            return Array.Empty<byte>();

        var pool = ArrayPool<byte>.Shared;
        byte[]? tempBuffer1 = null;
        byte[]? tempBuffer2 = null;

        try
        {
            // Rent buffers from pool instead of allocating
            tempBuffer1 = pool.Rent(input.Length);
            tempBuffer2 = pool.Rent(input.Length);

            // First transformation
            for (int i = 0; i < input.Length; i++)
            {
                tempBuffer1[i] = (byte)(input[i] + 1);
            }

            // Second transformation
            for (int i = 0; i < input.Length; i++)
            {
                tempBuffer2[i] = (byte)(tempBuffer1[i] * 2);
            }

            // Final transformation directly to result
            var result = new byte[input.Length];
            for (int i = 0; i < input.Length; i++)
            {
                result[i] = (byte)(tempBuffer2[i] - 1);
            }

            return result;
        }
        finally
        {
            // Return buffers to pool
            if (tempBuffer1 != null)
                pool.Return(tempBuffer1);
            if (tempBuffer2 != null)
                pool.Return(tempBuffer2);
        }
    }
}

/// <summary>
/// Alternative implementation using spans for in-place processing
/// </summary>
public class SpanBufferProcessor : IBufferProcessor
{
    public byte[] ProcessBuffer(byte[] input)
    {
        if (input == null || input.Length == 0)
            return Array.Empty<byte>();

        // Create result array
        var result = new byte[input.Length];
        var inputSpan = input.AsSpan();
        var resultSpan = result.AsSpan();

        // Process directly using spans (no temporary allocations)
        for (int i = 0; i < inputSpan.Length; i++)
        {
            // Combined transformation: ((input + 1) * 2) - 1 = input * 2 + 1
            resultSpan[i] = (byte)(inputSpan[i] * 2 + 1);
        }

        return result;
    }
}
