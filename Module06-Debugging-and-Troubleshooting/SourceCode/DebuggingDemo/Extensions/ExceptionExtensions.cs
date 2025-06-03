using System.Net.Sockets;

namespace DebuggingDemo.Extensions;

public static class ExceptionExtensions
{
    /// <summary>
    /// Get all inner exceptions as a flat list
    /// </summary>
    public static IEnumerable<Exception> GetAllInnerExceptions(this Exception exception)
    {
        var current = exception;
        while (current != null)
        {
            yield return current;
            current = current.InnerException;
        }
    }

    /// <summary>
    /// Get a formatted string with all exception details
    /// </summary>
    public static string GetDetailedMessage(this Exception exception)
    {
        var messages = exception.GetAllInnerExceptions()
            .Select(ex => $"{ex.GetType().Name}: {ex.Message}")
            .ToList();

        return string.Join(" -> ", messages);
    }

    /// <summary>
    /// Get the root cause exception
    /// </summary>
    public static Exception GetRootCause(this Exception exception)
    {
        var current = exception;
        while (current.InnerException != null)
        {
            current = current.InnerException;
        }
        return current;
    }

    /// <summary>
    /// Check if exception or any inner exception is of specific type
    /// </summary>
    public static bool ContainsException<T>(this Exception exception) where T : Exception
    {
        return exception.GetAllInnerExceptions().Any(ex => ex is T);
    }

    /// <summary>
    /// Get exception data as a dictionary for logging
    /// </summary>
    public static Dictionary<string, object> GetLoggingData(this Exception exception)
    {
        var data = new Dictionary<string, object>
        {
            ["ExceptionType"] = exception.GetType().Name,
            ["Message"] = exception.Message,
            ["StackTrace"] = exception.StackTrace ?? "No stack trace available",
            ["Source"] = exception.Source ?? "Unknown",
            ["HelpLink"] = exception.HelpLink ?? "No help link"
        };

        if (exception.Data.Count > 0)
        {
            var exceptionData = new Dictionary<string, object>();
            foreach (var key in exception.Data.Keys)
            {
                if (key != null)
                {
                    exceptionData[key.ToString()!] = exception.Data[key]?.ToString() ?? "null";
                }
            }
            data["ExceptionData"] = exceptionData;
        }

        if (exception.InnerException != null)
        {
            data["InnerException"] = exception.InnerException.GetLoggingData();
        }

        return data;
    }

    /// <summary>
    /// Add context data to exception
    /// </summary>
    public static T AddContext<T>(this T exception, string key, object value) where T : Exception
    {
        exception.Data[key] = value;
        return exception;
    }

    /// <summary>
    /// Add multiple context data to exception
    /// </summary>
    public static T AddContext<T>(this T exception, Dictionary<string, object> context) where T : Exception
    {
        foreach (var item in context)
        {
            exception.Data[item.Key] = item.Value;
        }
        return exception;
    }

    /// <summary>
    /// Check if exception is transient (should be retried)
    /// </summary>
    public static bool IsTransient(this Exception exception)
    {
        return exception switch
        {
            TimeoutException => true,
            HttpRequestException httpEx when IsTransientHttpException(httpEx) => true,
            SocketException => true,
            TaskCanceledException => true,
            _ when exception.ContainsException<TimeoutException>() => true,
            _ when exception.ContainsException<SocketException>() => true,
            _ => false
        };
    }

    private static bool IsTransientHttpException(HttpRequestException httpException)
    {
        // Check for specific HTTP status codes that indicate transient errors
        var message = httpException.Message.ToLowerInvariant();
        return message.Contains("timeout") ||
               message.Contains("503") ||  // Service Unavailable
               message.Contains("502") ||  // Bad Gateway
               message.Contains("504");    // Gateway Timeout
    }

    /// <summary>
    /// Get a safe message for user display (hides sensitive information)
    /// </summary>
    public static string GetSafeMessage(this Exception exception, bool isDevelopment = false)
    {
        if (isDevelopment)
        {
            return exception.GetDetailedMessage();
        }

        return exception switch
        {
            ArgumentException => "Invalid input provided",
            KeyNotFoundException => "Requested resource not found",
            UnauthorizedAccessException => "Access denied",
            TimeoutException => "Request timed out",
            HttpRequestException => "External service unavailable",
            InvalidOperationException => "Operation not allowed",
            _ => "An error occurred while processing your request"
        };
    }
}
