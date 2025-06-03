using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Http;
using SharedLibrary.Models;

namespace SharedLibrary.Middleware;

public class ErrorHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly JsonSerializerOptions _jsonOptions;

    public ErrorHandlingMiddleware(RequestDelegate next)
    {
        _next = next;
        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        };
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/json";
        
        var response = exception switch
        {
            ArgumentNullException => new
            {
                StatusCode = HttpStatusCode.BadRequest,
                Response = ApiResponse<object>.ErrorResponse("Invalid request", exception.Message)
            },
            KeyNotFoundException => new
            {
                StatusCode = HttpStatusCode.NotFound,
                Response = ApiResponse<object>.ErrorResponse("Resource not found", exception.Message)
            },
            UnauthorizedAccessException => new
            {
                StatusCode = HttpStatusCode.Unauthorized,
                Response = ApiResponse<object>.ErrorResponse("Unauthorized", exception.Message)
            },
            _ => new
            {
                StatusCode = HttpStatusCode.InternalServerError,
                Response = ApiResponse<object>.ErrorResponse("An error occurred", exception.Message)
            }
        };

        context.Response.StatusCode = (int)response.StatusCode;
        var jsonResponse = JsonSerializer.Serialize(response.Response, _jsonOptions);
        await context.Response.WriteAsync(jsonResponse);
    }
}