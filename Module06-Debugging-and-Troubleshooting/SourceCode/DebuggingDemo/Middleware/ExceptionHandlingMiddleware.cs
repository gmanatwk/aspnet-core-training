using System.Net;
using System.Text.Json;
using DebuggingDemo.Models;

namespace DebuggingDemo.Middleware;

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An unhandled exception occurred. RequestId: {RequestId}, Path: {Path}", 
                context.TraceIdentifier, context.Request.Path);
            
            await HandleExceptionAsync(context, ex);
        }
    }

    private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/json";

        var response = new ErrorResponse
        {
            RequestId = context.TraceIdentifier,
            Type = exception.GetType().Name,
            Title = GetErrorTitle(exception),
            Status = GetStatusCode(exception),
            Detail = GetErrorDetail(exception),
            Instance = context.Request.Path,
            Timestamp = DateTime.UtcNow
        };

        context.Response.StatusCode = response.Status;

        var jsonResponse = JsonSerializer.Serialize(response, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        });

        await context.Response.WriteAsync(jsonResponse);
    }

    private static string GetErrorTitle(Exception exception)
    {
        return exception switch
        {
            ArgumentException => "Invalid Argument",
            KeyNotFoundException => "Resource Not Found",
            UnauthorizedAccessException => "Unauthorized Access",
            InvalidOperationException => "Invalid Operation",
            TimeoutException => "Request Timeout",
            HttpRequestException => "External Service Error",
            _ => "Internal Server Error"
        };
    }

    private static int GetStatusCode(Exception exception)
    {
        return exception switch
        {
            ArgumentException => (int)HttpStatusCode.BadRequest,
            KeyNotFoundException => (int)HttpStatusCode.NotFound,
            UnauthorizedAccessException => (int)HttpStatusCode.Unauthorized,
            InvalidOperationException => (int)HttpStatusCode.BadRequest,
            TimeoutException => (int)HttpStatusCode.RequestTimeout,
            HttpRequestException => (int)HttpStatusCode.BadGateway,
            _ => (int)HttpStatusCode.InternalServerError
        };
    }

    private static string GetErrorDetail(Exception exception)
    {
        // In production, you might want to hide detailed error messages
        return Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") == "Development"
            ? exception.Message
            : "An error occurred while processing your request.";
    }
}
