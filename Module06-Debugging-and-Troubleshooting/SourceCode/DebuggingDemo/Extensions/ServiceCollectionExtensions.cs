using DebuggingDemo.Services;
using DebuggingDemo.Services.HealthChecks;

namespace DebuggingDemo.Extensions;

public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Add all debugging and monitoring services
    /// </summary>
    public static IServiceCollection AddDebuggingServices(this IServiceCollection services, IConfiguration configuration)
    {
        // Register diagnostic service
        services.AddScoped<DiagnosticService>();

        // Register external API service
        services.AddScoped<IExternalApiService, ExternalApiService>();

        // Register HTTP client for external API
        services.AddHttpClient<IExternalApiService, ExternalApiService>(client =>
        {
            var baseUrl = configuration.GetValue<string>("ExternalApiSettings:BaseUrl") ?? "https://jsonplaceholder.typicode.com/";
            var timeoutSeconds = configuration.GetValue<int>("ExternalApiSettings:TimeoutSeconds", 30);

            client.BaseAddress = new Uri(baseUrl);
            client.Timeout = TimeSpan.FromSeconds(timeoutSeconds);
        });

        return services;
    }

    /// <summary>
    /// Add comprehensive health checks
    /// </summary>
    public static IServiceCollection AddComprehensiveHealthChecks(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddHealthChecks()
            .AddCheck<DatabaseHealthCheck>("database", tags: new[] { "db", "ready" })
            .AddCheck<ExternalApiHealthCheck>("external-api", tags: new[] { "external", "ready" })
            .AddCheck<CustomHealthCheck>("custom-service", tags: new[] { "custom", "ready" })
            ;
            // .AddUrlGroup(new Uri("https://www.google.com"), "google", tags: new[] { "external" });

        // Add Health Checks UI
        services.AddHealthChecksUI(setup =>
        {
            setup.SetEvaluationTimeInSeconds(30);
            setup.SetMinimumSecondsBetweenFailureNotifications(60);
            setup.AddHealthCheckEndpoint("API Health", "/health");
        })
        .AddInMemoryStorage();

        return services;
    }

    /// <summary>
    /// Add custom performance monitoring
    /// </summary>
    public static IServiceCollection AddPerformanceMonitoring(this IServiceCollection services, IConfiguration configuration)
    {
        // Configure performance settings
        services.Configure<PerformanceSettings>(configuration.GetSection("PerformanceSettings"));

        // Add Application Insights if configured
        var instrumentationKey = configuration.GetValue<string>("ApplicationInsights:InstrumentationKey");
        if (!string.IsNullOrEmpty(instrumentationKey))
        {
            services.AddApplicationInsightsTelemetry(options =>
            {
                options.InstrumentationKey = instrumentationKey;
                options.EnableAdaptiveSampling = false;
                options.EnableQuickPulseMetricStream = true;
            });
        }

        return services;
    }

    /// <summary>
    /// Add custom CORS policies for debugging
    /// </summary>
    public static IServiceCollection AddDebuggingCors(this IServiceCollection services)
    {
        services.AddCors(options =>
        {
            options.AddPolicy("DebugPolicy", builder =>
            {
                builder.AllowAnyOrigin()
                       .AllowAnyMethod()
                       .AllowAnyHeader()
                       .WithExposedHeaders("X-Response-Time", "X-Memory-Used");
            });
        });

        return services;
    }
}

/// <summary>
/// Configuration settings for performance monitoring
/// </summary>
public class PerformanceSettings
{
    public int SlowRequestThresholdMs { get; set; } = 1000;
    public bool EnablePerformanceLogging { get; set; } = true;
    public int MemoryThresholdMB { get; set; } = 500;
    public int ThreadThreshold { get; set; } = 100;
    public int GCGen2Threshold { get; set; } = 100;
    public long DiskThresholdGB { get; set; } = 1;
}
