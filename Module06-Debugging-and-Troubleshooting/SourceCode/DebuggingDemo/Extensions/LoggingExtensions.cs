namespace DebuggingDemo.Extensions;

public static class LoggingExtensions
{
    /// <summary>
    /// Log the start of a method execution with parameters
    /// </summary>
    public static void LogMethodEntry(this ILogger logger, string methodName, params object[] parameters)
    {
        if (logger.IsEnabled(LogLevel.Debug))
        {
            var parameterString = parameters.Any() 
                ? string.Join(", ", parameters.Select((p, i) => $"param{i}: {p}"))
                : "no parameters";
            
            logger.LogDebug("Entering method: {MethodName} with {Parameters}", methodName, parameterString);
        }
    }

    /// <summary>
    /// Log the exit of a method execution with result
    /// </summary>
    public static void LogMethodExit(this ILogger logger, string methodName, object? result = null)
    {
        if (logger.IsEnabled(LogLevel.Debug))
        {
            var resultString = result?.ToString() ?? "void";
            logger.LogDebug("Exiting method: {MethodName} with result: {Result}", methodName, resultString);
        }
    }

    /// <summary>
    /// Log performance information for a method
    /// </summary>
    public static void LogPerformance(this ILogger logger, string methodName, TimeSpan duration, string? additionalInfo = null)
    {
        var message = additionalInfo != null 
            ? "Method {MethodName} completed in {Duration}ms - {AdditionalInfo}"
            : "Method {MethodName} completed in {Duration}ms";

        if (duration.TotalMilliseconds > 1000)
        {
            logger.LogWarning(message, methodName, duration.TotalMilliseconds, additionalInfo);
        }
        else if (duration.TotalMilliseconds > 500)
        {
            logger.LogInformation(message, methodName, duration.TotalMilliseconds, additionalInfo);
        }
        else
        {
            logger.LogDebug(message, methodName, duration.TotalMilliseconds, additionalInfo);
        }
    }

    /// <summary>
    /// Log user action with context
    /// </summary>
    public static void LogUserAction(this ILogger logger, string userId, string action, string? context = null)
    {
        if (context != null)
        {
            logger.LogInformation("User {UserId} performed action: {Action} - Context: {Context}", userId, action, context);
        }
        else
        {
            logger.LogInformation("User {UserId} performed action: {Action}", userId, action);
        }
    }

    /// <summary>
    /// Log security-related events
    /// </summary>
    public static void LogSecurityEvent(this ILogger logger, string eventType, string details, string? userId = null)
    {
        if (userId != null)
        {
            logger.LogWarning("Security event: {EventType} - User: {UserId} - Details: {Details}", eventType, userId, details);
        }
        else
        {
            logger.LogWarning("Security event: {EventType} - Details: {Details}", eventType, details);
        }
    }

    /// <summary>
    /// Log business rule violations
    /// </summary>
    public static void LogBusinessRuleViolation(this ILogger logger, string ruleName, string violation, object? context = null)
    {
        if (context != null)
        {
            logger.LogWarning("Business rule violation: {RuleName} - {Violation} - Context: {@Context}", ruleName, violation, context);
        }
        else
        {
            logger.LogWarning("Business rule violation: {RuleName} - {Violation}", ruleName, violation);
        }
    }

    /// <summary>
    /// Log external service calls
    /// </summary>
    public static void LogExternalServiceCall(this ILogger logger, string serviceName, string operation, TimeSpan? duration = null, bool success = true)
    {
        if (duration.HasValue)
        {
            if (success)
            {
                logger.LogInformation("External service call succeeded: {ServiceName}.{Operation} completed in {Duration}ms", 
                    serviceName, operation, duration.Value.TotalMilliseconds);
            }
            else
            {
                logger.LogError("External service call failed: {ServiceName}.{Operation} failed after {Duration}ms", 
                    serviceName, operation, duration.Value.TotalMilliseconds);
            }
        }
        else
        {
            if (success)
            {
                logger.LogInformation("External service call succeeded: {ServiceName}.{Operation}", serviceName, operation);
            }
            else
            {
                logger.LogError("External service call failed: {ServiceName}.{Operation}", serviceName, operation);
            }
        }
    }

    /// <summary>
    /// Log database operations
    /// </summary>
    public static void LogDatabaseOperation(this ILogger logger, string operation, string entity, int? recordCount = null, TimeSpan? duration = null)
    {
        var message = recordCount.HasValue
            ? "Database operation: {Operation} on {Entity} - {RecordCount} records"
            : "Database operation: {Operation} on {Entity}";

        var parameters = recordCount.HasValue
            ? new object[] { operation, entity, recordCount.Value }
            : new object[] { operation, entity };

        if (duration.HasValue)
        {
            message += " completed in {Duration}ms";
            parameters = parameters.Append(duration.Value.TotalMilliseconds).ToArray();
        }

        logger.LogInformation(message, parameters);
    }
}
