using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using ProductApi.Models;
using ProductApi.Services;
using System.Diagnostics;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add Application Insights
builder.Services.AddApplicationInsightsTelemetry();

// Add custom services
builder.Services.AddSingleton<IProductService, ProductService>();
builder.Services.AddSingleton<MetricsService>();

// Add health checks
builder.Services.AddHealthChecks()
    .AddCheck("self", () => HealthCheckResult.Healthy("API is running"))
    .AddCheck("memory", () =>
    {
        var allocated = GC.GetTotalMemory(false);
        var memoryLimit = 1024 * 1024 * 1024; // 1GB
        
        return allocated < memoryLimit * 0.8 
            ? HealthCheckResult.Healthy($"Memory usage: {allocated / 1024 / 1024}MB")
            : HealthCheckResult.Degraded($"High memory usage: {allocated / 1024 / 1024}MB");
    })
    .AddCheck("random-failure", () =>
    {
        // Simulate random failures for demo purposes
        var isHealthy = DateTime.UtcNow.Second % 10 != 0; // Fail 10% of the time
        return isHealthy 
            ? HealthCheckResult.Healthy("Random check passed")
            : HealthCheckResult.Unhealthy("Random check failed (simulated)");
    });

// Add HTTP client for service communication
builder.Services.AddHttpClient("UserService", client =>
{
    client.BaseAddress = new Uri("https://userservice.internal.example.com/");
    client.DefaultRequestHeaders.Add("User-Agent", "ProductApi/1.0");
    client.Timeout = TimeSpan.FromSeconds(30);
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Add correlation ID middleware
app.Use(async (context, next) =>
{
    var correlationId = context.Request.Headers["X-Correlation-ID"].FirstOrDefault() 
                       ?? Guid.NewGuid().ToString();
    
    context.Response.Headers.Add("X-Correlation-ID", correlationId);
    context.Items["CorrelationId"] = correlationId;
    
    await next();
});

// Health check endpoints
app.MapHealthChecks("/health", new HealthCheckOptions
{
    Predicate = _ => false // Simple health check
});

app.MapHealthChecks("/healthz", new HealthCheckOptions
{
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        
        var result = new
        {
            status = report.Status.ToString(),
            checks = report.Entries.Select(e => new
            {
                name = e.Key,
                status = e.Value.Status.ToString(),
                description = e.Value.Description,
                duration = e.Value.Duration.TotalMilliseconds,
                exception = e.Value.Exception?.Message
            }),
            totalDuration = report.TotalDuration.TotalMilliseconds,
            timestamp = DateTimeOffset.UtcNow
        };
        
        await context.Response.WriteAsync(JsonSerializer.Serialize(result, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            WriteIndented = true
        }));
    }
});

// Info endpoint
app.MapGet("/info", (IWebHostEnvironment env, IConfiguration config) => new
{
    Environment = env.EnvironmentName,
    Version = config["APP_VERSION"] ?? "1.0.0",
    Timestamp = DateTime.UtcNow,
    MachineName = Environment.MachineName,
    ProcessId = Environment.ProcessId,
    WorkingSet = Environment.WorkingSet,
    HasApplicationInsights = !string.IsNullOrEmpty(config.GetConnectionString("APPLICATIONINSIGHTS_CONNECTION_STRING")),
    WelcomeMessage = config["WELCOME_MESSAGE"] ?? "Hello from Container Apps!"
});

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();

// Make the Program class public for testing
public partial class Program { }
