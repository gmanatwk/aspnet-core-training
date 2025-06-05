using Microsoft.AspNetCore.Mvc.Filters;
using System.Diagnostics;

namespace RestfulAPI.Filters;

/// <summary>
/// Action filter for logging API calls and performance
/// </summary>
public class LoggingActionFilter : IAsyncActionFilter
{
    private readonly ILogger<LoggingActionFilter> _logger;

    public LoggingActionFilter(ILogger<LoggingActionFilter> logger)
    {
        _logger = logger;
    }

    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        var stopwatch = Stopwatch.StartNew();
        var actionName = context.ActionDescriptor.DisplayName;
        var requestId = context.HttpContext.TraceIdentifier;

        _logger.LogInformation("Executing action {ActionName} with request ID {RequestId} at {StartTime}",
            actionName, requestId, DateTime.UtcNow);

        // Log action arguments in development
        if (Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") == "Development")
        {
            foreach (var arg in context.ActionArguments)
            {
                _logger.LogDebug("Action argument {ArgumentName}: {@ArgumentValue}", arg.Key, arg.Value);
            }
        }

        var executedContext = await next();

        stopwatch.Stop();

        if (executedContext.Exception == null)
        {
            _logger.LogInformation("Executed action {ActionName} with request ID {RequestId} in {ElapsedMilliseconds}ms",
                actionName, requestId, stopwatch.ElapsedMilliseconds);
        }
        else
        {
            _logger.LogError(executedContext.Exception,
                "Action {ActionName} with request ID {RequestId} failed after {ElapsedMilliseconds}ms",
                actionName, requestId, stopwatch.ElapsedMilliseconds);
        }
    }
}