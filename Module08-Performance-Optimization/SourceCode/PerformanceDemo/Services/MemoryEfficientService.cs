using System.Buffers;
using System.Text;
using System.Text.Json;

namespace PerformanceDemo.Services;

// Memory-optimized service implementation
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
    
    // Simple string processing implementation
    public string ProcessLargeString(string input)
    {
        if (string.IsNullOrEmpty(input))
            return string.Empty;
            
        // Simple implementation - just trim and return
        return input.Trim();
    }
    
    // Simple byte array processing
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
    
    // Extract substring using spans to avoid allocations
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
    
    // Efficient JSON parsing with spans
    public bool TryParseJson<T>(ReadOnlySpan<char> json, out T? result)
    {
        result = default;
        
        try
        {
            // Use Utf8JsonReader to efficiently parse without creating intermediate strings
            result = JsonSerializer.Deserialize<T>(json);
            return true;
        }
        catch (JsonException ex)
        {
            _logger.LogWarning(ex, "Failed to parse JSON");
            return false;
        }
    }
    
    // Efficient async operation using ValueTask
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