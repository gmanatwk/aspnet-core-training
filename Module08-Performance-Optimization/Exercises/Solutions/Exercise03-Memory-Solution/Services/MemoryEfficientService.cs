using System.Buffers;
using System.Text;
using System.Text.Json;

namespace MemoryOptimization.Services;

public interface IMemoryEfficientService
{
    string ProcessLargeString(string input);
    string ProcessLargeStringOptimized(ReadOnlySpan<char> input);
    byte[] ProcessLargeByteArray(byte[] input);
    byte[] ProcessLargeByteArrayOptimized(ReadOnlySpan<byte> input);
    ReadOnlySpan<char> ExtractSubstring(ReadOnlySpan<char> input, int start, int length);
    bool TryParseJson<T>(ReadOnlySpan<char> json, out T? result);
    ValueTask<string> ProcessDataAsync(string data);
}

/// <summary>
/// Memory-optimized service implementation demonstrating various optimization techniques
/// </summary>
public class MemoryEfficientService : IMemoryEfficientService
{
    private readonly ILogger<MemoryEfficientService> _logger;
    private readonly ArrayPool<byte> _bytePool;
    private readonly ArrayPool<char> _charPool;

    public MemoryEfficientService(ILogger<MemoryEfficientService> logger)
    {
        _logger = logger;
        _bytePool = ArrayPool<byte>.Shared;
        _charPool = ArrayPool<char>.Shared;
    }

    /// <summary>
    /// Inefficient string processing - creates many intermediate strings
    /// </summary>
    public string ProcessLargeString(string input)
    {
        if (string.IsNullOrEmpty(input))
            return string.Empty;

        // Trim whitespace
        var trimmed = input.Trim();

        // Convert to lowercase
        var lowercase = trimmed.ToLower();

        // Replace specific characters
        var replaced = lowercase.Replace("  ", " ");

        // Remove special characters
        var cleaned = string.Empty;
        foreach (var c in replaced)
        {
            if (char.IsLetterOrDigit(c) || char.IsWhiteSpace(c))
                cleaned += c;
        }

        return cleaned;
    }

    /// <summary>
    /// Optimized string processing using StringBuilder and spans
    /// </summary>
    public string ProcessLargeStringOptimized(ReadOnlySpan<char> input)
    {
        if (input.IsEmpty)
            return string.Empty;

        // Trim whitespace
        input = input.Trim();

        // Allocate a buffer for the result
        var estimatedLength = input.Length;
        var builder = new StringBuilder(estimatedLength);

        bool lastWasSpace = false;

        // Process in a single pass
        for (int i = 0; i < input.Length; i++)
        {
            var c = input[i];

            // Convert to lowercase (manually, to avoid allocations)
            if (c >= 'A' && c <= 'Z')
                c = (char)(c + 32);

            // Skip consecutive spaces
            if (c == ' ')
            {
                if (lastWasSpace)
                    continue;

                lastWasSpace = true;
            }
            else
            {
                lastWasSpace = false;
            }

            // Only include valid characters
            if (char.IsLetterOrDigit(c) || char.IsWhiteSpace(c))
                builder.Append(c);
        }

        return builder.ToString();
    }

    /// <summary>
    /// Inefficient byte array processing - creates new arrays
    /// </summary>
    public byte[] ProcessLargeByteArray(byte[] input)
    {
        if (input == null || input.Length == 0)
            return Array.Empty<byte>();

        // Create result array
        var result = new byte[input.Length];

        // Process bytes
        for (int i = 0; i < input.Length; i++)
        {
            // Simple transformation (e.g., increment each byte)
            result[i] = (byte)((input[i] + 1) % 256);
        }

        return result;
    }

    /// <summary>
    /// Optimized byte array processing using array pooling
    /// </summary>
    public byte[] ProcessLargeByteArrayOptimized(ReadOnlySpan<byte> input)
    {
        if (input.IsEmpty)
            return Array.Empty<byte>();

        // Rent buffer from pool
        var buffer = _bytePool.Rent(input.Length);

        try
        {
            // Process bytes
            for (int i = 0; i < input.Length; i++)
            {
                // Simple transformation
                buffer[i] = (byte)((input[i] + 1) % 256);
            }

            // Create final result (unfortunately, we need to allocate here)
            var result = new byte[input.Length];
            buffer.AsSpan(0, input.Length).CopyTo(result);

            return result;
        }
        finally
        {
            // Return buffer to pool
            _bytePool.Return(buffer);
        }
    }

    /// <summary>
    /// Extract substring using spans to avoid allocations
    /// </summary>
    public ReadOnlySpan<char> ExtractSubstring(ReadOnlySpan<char> input, int start, int length)
    {
        if (input.IsEmpty)
            return ReadOnlySpan<char>.Empty;

        // Validate parameters
        if (start < 0 || start >= input.Length)
            throw new ArgumentOutOfRangeException(nameof(start));

        if (length < 0 || start + length > input.Length)
            throw new ArgumentOutOfRangeException(nameof(length));

        // Create slice (no allocation, just a view into the original data)
        return input.Slice(start, length);
    }

    /// <summary>
    /// Efficient JSON parsing with spans
    /// </summary>
    public bool TryParseJson<T>(ReadOnlySpan<char> json, out T? result)
    {
        result = default;

        try
        {
            // Convert span to bytes for Utf8JsonReader
            var maxByteCount = Encoding.UTF8.GetMaxByteCount(json.Length);
            var buffer = _bytePool.Rent(maxByteCount);

            try
            {
                var byteCount = Encoding.UTF8.GetBytes(json, buffer);
                var jsonBytes = buffer.AsSpan(0, byteCount);

                // Use Utf8JsonReader to efficiently parse without creating intermediate strings
                result = JsonSerializer.Deserialize<T>(jsonBytes);
                return true;
            }
            finally
            {
                _bytePool.Return(buffer);
            }
        }
        catch (JsonException ex)
        {
            _logger.LogWarning(ex, "Failed to parse JSON");
            return false;
        }
    }

    /// <summary>
    /// Efficient async operation using ValueTask
    /// </summary>
    public async ValueTask<string> ProcessDataAsync(string data)
    {
        if (string.IsNullOrEmpty(data))
            return string.Empty;

        // Use ValueTask for lightweight async operations that often don't need to allocate a Task
        await Task.Delay(1); // Simulate async work

        // Use string.Create to efficiently create a string
        return string.Create(data.Length, data, (chars, state) =>
        {
            for (int i = 0; i < state.Length; i++)
            {
                chars[i] = char.ToUpper(state[i]);
            }
        });
    }
}

/// <summary>
/// Value types for performance-critical calculations
/// </summary>
public readonly ref struct Point3D
{
    public readonly double X;
    public readonly double Y;
    public readonly double Z;

    public Point3D(double x, double y, double z)
    {
        X = x;
        Y = y;
        Z = z;
    }

    public readonly double DistanceTo(in Point3D other)
    {
        double dx = X - other.X;
        double dy = Y - other.Y;
        double dz = Z - other.Z;
        return Math.Sqrt(dx * dx + dy * dy + dz * dz);
    }

    public readonly Point3D Add(in Point3D other)
    {
        return new Point3D(X + other.X, Y + other.Y, Z + other.Z);
    }

    public readonly Point3D Scale(double factor)
    {
        return new Point3D(X * factor, Y * factor, Z * factor);
    }
}

/// <summary>
/// Class version for comparison
/// </summary>
public class Point3DClass
{
    public double X { get; set; }
    public double Y { get; set; }
    public double Z { get; set; }

    public Point3DClass(double x, double y, double z)
    {
        X = x;
        Y = y;
        Z = z;
    }

    public double DistanceTo(Point3DClass other)
    {
        double dx = X - other.X;
        double dy = Y - other.Y;
        double dz = Z - other.Z;
        return Math.Sqrt(dx * dx + dy * dy + dz * dz);
    }

    public Point3DClass Add(Point3DClass other)
    {
        return new Point3DClass(X + other.X, Y + other.Y, Z + other.Z);
    }

    public Point3DClass Scale(double factor)
    {
        return new Point3DClass(X * factor, Y * factor, Z * factor);
    }
}

/// <summary>
/// Service demonstrating closure allocation issues
/// </summary>
public class ClosureService
{
    private readonly ILogger<ClosureService> _logger;

    public ClosureService(ILogger<ClosureService> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// Creates closures, capturing variables (allocates)
    /// </summary>
    public async Task ProcessItemsWithClosure(List<int> items)
    {
        var tasks = new List<Task>();

        foreach (var item in items)
        {
            // This creates a closure, capturing 'item'
            var task = Task.Run(() =>
            {
                _logger.LogDebug("Processed item: {Item}", item);
                return item * 2;
            });

            tasks.Add(task);
        }

        await Task.WhenAll(tasks);
    }

    /// <summary>
    /// Avoids closures by using static methods or pre-allocated delegates
    /// </summary>
    public async Task ProcessItemsWithoutClosure(List<int> items)
    {
        var tasks = new List<Task>();

        foreach (var item in items)
        {
            // Use Task.FromResult or pass state to avoid closure
            var task = Task.Run(state =>
            {
                var currentItem = (int)state!;
                _logger.LogDebug("Processed item: {Item}", currentItem);
                return currentItem * 2;
            }, item);

            tasks.Add(task);
        }

        await Task.WhenAll(tasks);
    }

    /// <summary>
    /// Alternative using static local function
    /// </summary>
    public async Task ProcessItemsWithStaticLocal(List<int> items)
    {
        var tasks = items.Select(ProcessItem).ToArray();
        await Task.WhenAll(tasks);

        // Static local function doesn't capture variables
        static async Task ProcessItem(int item)
        {
            await Task.Delay(1);
            Console.WriteLine($"Processed item: {item}");
        }
    }
}
