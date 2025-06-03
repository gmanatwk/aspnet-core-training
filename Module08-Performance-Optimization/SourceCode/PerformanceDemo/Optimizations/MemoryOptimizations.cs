using System.Buffers;
using System.Collections.Concurrent;
using System.Text;

namespace PerformanceDemo.Optimizations;

/// <summary>
/// Demonstrates memory optimization techniques to reduce allocations and GC pressure
/// </summary>
public class MemoryOptimizations
{
    private readonly ArrayPool<byte> _bytePool = ArrayPool<byte>.Shared;
    private readonly ArrayPool<char> _charPool = ArrayPool<char>.Shared;

    /// <summary>
    /// Process data using ArrayPool to avoid allocations
    /// </summary>
    public void ProcessDataWithArrayPool(ReadOnlySpan<byte> inputData)
    {
        // Rent a buffer from the pool
        byte[] buffer = _bytePool.Rent(inputData.Length * 2);
        try
        {
            // Use Span<T> for zero-allocation operations
            Span<byte> workingBuffer = buffer.AsSpan(0, inputData.Length * 2);
            
            // Process data without additional allocations
            ProcessDataInPlace(inputData, workingBuffer);
        }
        finally
        {
            // Always return the buffer to the pool
            _bytePool.Return(buffer);
        }
    }

    private static void ProcessDataInPlace(ReadOnlySpan<byte> input, Span<byte> output)
    {
        // Example: Double each byte value
        for (int i = 0; i < input.Length; i++)
        {
            output[i] = (byte)(input[i] * 2);
        }
    }

    /// <summary>
    /// String processing with minimal allocations using StringBuilder pooling
    /// </summary>
    public string ProcessStringsEfficiently(IEnumerable<string> strings)
    {
        // Use a static StringBuilder pool or ObjectPool<StringBuilder>
        var sb = StringBuilderPool.Get();
        try
        {
            foreach (var str in strings)
            {
                if (!string.IsNullOrEmpty(str))
                {
                    sb.Append(str.AsSpan().Trim());
                    sb.Append('|');
                }
            }
            
            // Remove trailing separator
            if (sb.Length > 0)
            {
                sb.Length--;
            }
            
            return sb.ToString();
        }
        finally
        {
            StringBuilderPool.Return(sb);
        }
    }

    /// <summary>
    /// Process large text data using Span<T> and Memory<T>
    /// </summary>
    public async Task<int> CountWordsInLargeTextAsync(Stream textStream)
    {
        const int bufferSize = 4096;
        byte[] buffer = _bytePool.Rent(bufferSize);
        char[] charBuffer = _charPool.Rent(bufferSize);
        
        try
        {
            int wordCount = 0;
            int bytesRead;
            bool inWord = false;
            
            while ((bytesRead = await textStream.ReadAsync(buffer.AsMemory(0, bufferSize))) > 0)
            {
                // Process the buffer in a separate method to avoid async+span issues
                wordCount += CountWordsInBuffer(buffer.AsSpan(0, bytesRead), charBuffer, ref inWord);
            }
            
            return wordCount;
        }
        finally
        {
            _bytePool.Return(buffer);
            _charPool.Return(charBuffer);
        }
    }
    
    private int CountWordsInBuffer(ReadOnlySpan<byte> buffer, char[] charBuffer, ref bool inWord)
    {
        // Convert to chars without additional allocation
        var charCount = Encoding.UTF8.GetChars(buffer, charBuffer);
        var chars = charBuffer.AsSpan(0, charCount);
        
        int wordCount = 0;
        
        // Count words using Span<T>
        foreach (char c in chars)
        {
            if (char.IsWhiteSpace(c))
            {
                inWord = false;
            }
            else if (!inWord)
            {
                wordCount++;
                inWord = true;
            }
        }
        
        return wordCount;
    }

    /// <summary>
    /// Example of using stackalloc for small, short-lived buffers
    /// </summary>
    public unsafe string FormatNumbersEfficiently(int[] numbers)
    {
        if (numbers.Length == 0) return string.Empty;
        
        // Use stackalloc for small buffers (< 1KB recommended)
        const int maxStackSize = 256;
        Span<char> buffer = numbers.Length * 12 <= maxStackSize 
            ? stackalloc char[numbers.Length * 12] 
            : new char[numbers.Length * 12];
        
        int position = 0;
        for (int i = 0; i < numbers.Length; i++)
        {
            if (i > 0)
            {
                buffer[position++] = ',';
                buffer[position++] = ' ';
            }
            
            // Format number directly into the buffer
            if (numbers[i].TryFormat(buffer.Slice(position), out int charsWritten))
            {
                position += charsWritten;
            }
        }
        
        return new string(buffer.Slice(0, position));
    }

    /// <summary>
    /// Memory-efficient data processing with value types
    /// </summary>
    public readonly struct ProcessingResult
    {
        public readonly int Count;
        public readonly double Average;
        public readonly bool IsValid;

        public ProcessingResult(int count, double average, bool isValid)
        {
            Count = count;
            Average = average;
            IsValid = isValid;
        }
    }

    /// <summary>
    /// Process data returning value types to avoid heap allocations
    /// </summary>
    public ProcessingResult ProcessDataEfficiently(ReadOnlySpan<int> data)
    {
        if (data.IsEmpty)
        {
            return new ProcessingResult(0, 0.0, false);
        }

        long sum = 0;
        int count = 0;

        foreach (int value in data)
        {
            if (value >= 0) // Only process non-negative values
            {
                sum += value;
                count++;
            }
        }

        double average = count > 0 ? (double)sum / count : 0.0;
        return new ProcessingResult(count, average, count > 0);
    }
}

/// <summary>
/// Simple StringBuilder pool implementation
/// </summary>
public static class StringBuilderPool
{
    [ThreadStatic]
    private static StringBuilder? _cachedInstance;

    public static StringBuilder Get()
    {
        var sb = _cachedInstance;
        if (sb != null)
        {
            _cachedInstance = null;
            sb.Clear();
            return sb;
        }
        return new StringBuilder();
    }

    public static void Return(StringBuilder sb)
    {
        if (_cachedInstance == null && sb.Capacity < 1024)
        {
            _cachedInstance = sb;
        }
    }
}

/// <summary>
/// Custom object pool for expensive-to-create objects
/// </summary>
public class ObjectPool<T> where T : class, new()
{
    private readonly ConcurrentQueue<T> _items = new();
    private readonly Func<T> _objectGenerator;
    private readonly Action<T>? _resetAction;
    private int _currentCount;
    private readonly int _maxPoolSize;

    public ObjectPool(Func<T>? objectGenerator = null, Action<T>? resetAction = null, int maxPoolSize = 100)
    {
        _objectGenerator = objectGenerator ?? (() => new T());
        _resetAction = resetAction;
        _maxPoolSize = maxPoolSize;
    }

    public T Get()
    {
        if (_items.TryDequeue(out T? item))
        {
            Interlocked.Decrement(ref _currentCount);
            return item;
        }

        return _objectGenerator();
    }

    public void Return(T item)
    {
        if (item == null) return;

        _resetAction?.Invoke(item);

        if (_currentCount < _maxPoolSize)
        {
            _items.Enqueue(item);
            Interlocked.Increment(ref _currentCount);
        }
    }
}
