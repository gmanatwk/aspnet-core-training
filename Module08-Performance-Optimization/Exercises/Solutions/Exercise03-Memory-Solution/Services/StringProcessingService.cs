using System.Buffers;
using System.Text;

namespace MemoryOptimization.Services;

public interface IStringProcessor
{
    string Process(string input);
}

/// <summary>
/// Inefficient string processor with excessive allocations
/// </summary>
public class IneffientStringProcessor : IStringProcessor
{
    public string Process(string input)
    {
        if (string.IsNullOrEmpty(input))
            return string.Empty;

        // Inefficient string operations with multiple allocations
        var result = input.ToUpper();
        result = result.Replace("  ", " ");

        var words = result.Split(' ');
        result = string.Empty;

        foreach (var word in words)
        {
            if (!string.IsNullOrWhiteSpace(word))
            {
                if (!string.IsNullOrEmpty(result))
                    result += " ";

                result += word.Trim();
            }
        }

        return result;
    }
}

/// <summary>
/// Optimized string processor using StringBuilder
/// </summary>
public class OptimizedStringProcessor : IStringProcessor
{
    public string Process(string input)
    {
        if (string.IsNullOrEmpty(input))
            return string.Empty;

        // Use StringBuilder to minimize allocations
        var builder = new StringBuilder(input.Length);
        bool lastWasSpace = false;

        for (int i = 0; i < input.Length; i++)
        {
            var c = input[i];

            // Convert to uppercase
            if (c >= 'a' && c <= 'z')
                c = (char)(c - 32);

            // Handle spaces
            if (char.IsWhiteSpace(c))
            {
                if (!lastWasSpace && builder.Length > 0)
                {
                    builder.Append(' ');
                    lastWasSpace = true;
                }
            }
            else
            {
                builder.Append(c);
                lastWasSpace = false;
            }
        }

        return builder.ToString();
    }
}

/// <summary>
/// String processor using Span<T> for zero-allocation processing
/// </summary>
public class SpanStringProcessor : IStringProcessor
{
    public string Process(string input)
    {
        if (string.IsNullOrEmpty(input))
            return string.Empty;

        return ProcessWithSpan(input.AsSpan());
    }

    private string ProcessWithSpan(ReadOnlySpan<char> input)
    {
        // Trim whitespace using spans
        input = input.Trim();

        if (input.IsEmpty)
            return string.Empty;

        // Rent a buffer for processing
        var charPool = ArrayPool<char>.Shared;
        var buffer = charPool.Rent(input.Length);

        try
        {
            var span = buffer.AsSpan(0, input.Length);
            bool lastWasSpace = false;
            int writeIndex = 0;

            // Process characters in a single pass
            for (int i = 0; i < input.Length; i++)
            {
                var c = input[i];

                // Convert to uppercase
                if (c >= 'a' && c <= 'z')
                    c = (char)(c - 32);

                // Handle spaces
                if (char.IsWhiteSpace(c))
                {
                    if (!lastWasSpace && writeIndex > 0)
                    {
                        span[writeIndex++] = ' ';
                        lastWasSpace = true;
                    }
                }
                else
                {
                    span[writeIndex++] = c;
                    lastWasSpace = false;
                }
            }

            // Create final string from processed span
            return new string(span.Slice(0, writeIndex));
        }
        finally
        {
            charPool.Return(buffer);
        }
    }
}
