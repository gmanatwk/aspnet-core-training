# Monitoring Setup for Azure Container Apps

## 🎯 Overview
This guide provides comprehensive monitoring setup for Azure Container Apps, covering Application Insights, Log Analytics, custom metrics, and alerting strategies.

## 📊 Application Insights Integration

### Setup Application Insights

```bash
# Create Application Insights resource
RESOURCE_GROUP="rg-containerapp-demo"
APP_INSIGHTS_NAME="ai-containerapp-monitoring"
LOCATION="eastus"

az monitor app-insights component create \
    --app $APP_INSIGHTS_NAME \
    --location $LOCATION \
    --resource-group $RESOURCE_GROUP \
    --application-type web

# Get connection string
CONNECTION_STRING=$(az monitor app-insights component show \
    --app $APP_INSIGHTS_NAME \
    --resource-group $RESOURCE_GROUP \
    --query connectionString \
    --output tsv)

echo "Connection String: $CONNECTION_STRING"
```

### Configure ASP.NET Core Application

Add Application Insights to your application:

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);

// Add Application Insights
builder.Services.AddApplicationInsightsTelemetry();

// Configure telemetry
builder.Services.Configure<TelemetryConfiguration>(config =>
{
    config.SetAzureTokenCredential(new DefaultAzureCredential());
});

// Add custom telemetry initializers
builder.Services.AddSingleton<ITelemetryInitializer, CloudRoleNameInitializer>();

var app = builder.Build();

// Configure telemetry middleware
app.UseMiddleware<RequestTelemetryMiddleware>();
```

### Custom Telemetry Initializer

```csharp
public class CloudRoleNameInitializer : ITelemetryInitializer
{
    public void Initialize(ITelemetry telemetry)
    {
        if (string.IsNullOrEmpty(telemetry.Context.Cloud.RoleName))
        {
            telemetry.Context.Cloud.RoleName = Environment.GetEnvironmentVariable("CONTAINER_APP_NAME") ?? "ProductApi";
            telemetry.Context.Cloud.RoleInstance = Environment.MachineName;
        }
    }
}
```

### Request Telemetry Middleware

```csharp
public class RequestTelemetryMiddleware
{
    private readonly RequestDelegate _next;
    private readonly TelemetryClient _telemetryClient;

    public RequestTelemetryMiddleware(RequestDelegate next, TelemetryClient telemetryClient)
    {
        _next = next;
        _telemetryClient = telemetryClient;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();
        var correlationId = context.Request.Headers["X-Correlation-ID"].FirstOrDefault() 
                           ?? Guid.NewGuid().ToString();

        context.Items["CorrelationId"] = correlationId;
        context.Response.Headers.Add("X-Correlation-ID", correlationId);

        try
        {
            await _next(context);
        }
        finally
        {
            stopwatch.Stop();
            
            _telemetryClient.TrackRequest(
                context.Request.Path,
                DateTimeOffset.UtcNow.Subtract(stopwatch.Elapsed),
                stopwatch.Elapsed,
                context.Response.StatusCode.ToString(),
                context.Response.StatusCode < 400);

            _telemetryClient.TrackEvent("RequestProcessed", new Dictionary<string, string>
            {
                ["CorrelationId"] = correlationId,
                ["UserAgent"] = context.Request.Headers["User-Agent"],
                ["RemoteIP"] = context.Connection.RemoteIpAddress?.ToString()
            });
        }
    }
}
```

## 📋 Log Analytics Configuration

### KQL Queries for Container Apps

#### Application Performance Monitoring

```kql
// Request performance over time
requests
| where cloud_RoleName == "ProductApi"
| summarize 
    AvgDuration = avg(duration),
    P95Duration = percentile(duration, 95),
    RequestCount = count()
by bin(timestamp, 5m)
| order by timestamp desc

// Error rate monitoring
requests
| where cloud_RoleName == "ProductApi"
| summarize 
    TotalRequests = count(),
    FailedRequests = countif(success == false),
    ErrorRate = (countif(success == false) * 100.0) / count()
by bin(timestamp, 5m)
| order by timestamp desc
```

#### Container and Infrastructure Monitoring

```kql
// Container App Console Logs
ContainerAppConsoleLogs_CL
| where ContainerAppName_s == "productapi"
| where Log_s contains "ERROR" or Log_s contains "WARN"
| order by TimeGenerated desc
| take 100

// Container App System Logs
ContainerAppSystemLogs_CL
| where ContainerAppName_s == "productapi"
| where Reason_s in ("Started", "Stopped", "Failed", "Scaling")
| project TimeGenerated, Reason_s, Log_s
| order by TimeGenerated desc

// Resource utilization
InsightsMetrics
| where Namespace == "container.azm.ms/cpuUsageNanoCores"
| where Name == "cpuUsageNanoCores"
| summarize AvgCPU = avg(Val) by bin(TimeGenerated, 5m)
| order by TimeGenerated desc
```

#### Dependency Tracking

```kql
// External dependency performance
dependencies
| where cloud_RoleName == "ProductApi"
| summarize 
    AvgDuration = avg(duration),
    FailureRate = (countif(success == false) * 100.0) / count(),
    CallCount = count()
by name, type
| order by AvgDuration desc

// Database query performance
dependencies
| where cloud_RoleName == "ProductApi"
| where type == "SQL"
| summarize 
    AvgDuration = avg(duration),
    SlowQueries = countif(duration > 1000)
by bin(timestamp, 5m)
| order by timestamp desc
```

#### Custom Events and Metrics

```kql
// Business metrics
customEvents
| where cloud_RoleName == "ProductApi"
| where name in ("OrderPlaced", "UserRegistered", "PaymentProcessed")
| summarize EventCount = count() by name, bin(timestamp, 1h)
| order by timestamp desc

// Performance counters
performanceCounters
| where cloud_RoleName == "ProductApi"
| where counter in ("% Processor Time", "Available MBytes")
| summarize AvgValue = avg(value) by counter, bin(timestamp, 5m)
| order by timestamp desc
```

## 🚨 Alerting Configuration

### Create Action Groups

```bash
# Create email action group
az monitor action-group create \
    --name "ContainerApp-Email-Alerts" \
    --resource-group $RESOURCE_GROUP \
    --short-name "EmailAlert" \
    --action email admin admin@company.com

# Create SMS action group
az monitor action-group create \
    --name "ContainerApp-SMS-Alerts" \
    --resource-group $RESOURCE_GROUP \
    --short-name "SMSAlert" \
    --action sms oncall +1234567890

# Create webhook action group
az monitor action-group create \
    --name "ContainerApp-Webhook-Alerts" \
    --resource-group $RESOURCE_GROUP \
    --short-name "WebhookAlert" \
    --action webhook teams https://company.webhook.office.com/webhookb2/...
```

### Performance Alerts

```bash
CONTAINER_APP_RESOURCE_ID="/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.App/containerApps/productapi"

# High error rate alert
az monitor metrics alert create \
    --name "High Error Rate" \
    --resource-group $RESOURCE_GROUP \
    --scopes $CONTAINER_APP_RESOURCE_ID \
    --condition "avg requests/failed > 10" \
    --window-size 5m \
    --evaluation-frequency 1m \
    --severity 2 \
    --description "Error rate is above 10 requests per 5 minutes" \
    --action ContainerApp-Email-Alerts

# High response time alert
az monitor metrics alert create \
    --name "High Response Time" \
    --resource-group $RESOURCE_GROUP \
    --scopes $CONTAINER_APP_RESOURCE_ID \
    --condition "avg requests/duration > 2000" \
    --window-size 5m \
    --evaluation-frequency 1m \
    --severity 3 \
    --description "Average response time is above 2 seconds" \
    --action ContainerApp-Email-Alerts

# High CPU utilization
az monitor metrics alert create \
    --name "High CPU Usage" \
    --resource-group $RESOURCE_GROUP \
    --scopes $CONTAINER_APP_RESOURCE_ID \
    --condition "avg UsageNanoCores > 800000000" \
    --window-size 10m \
    --evaluation-frequency 5m \
    --severity 3 \
    --description "CPU usage is above 80%" \
    --action ContainerApp-SMS-Alerts
```

### Log-based Alerts

```bash
# Create log analytics-based alert for errors
az monitor scheduled-query create \
    --name "Application Errors" \
    --resource-group $RESOURCE_GROUP \
    --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/$LOG_WORKSPACE" \
    --condition-query "exceptions | where cloud_RoleName == 'ProductApi' | summarize count() by bin(timestamp, 5m)" \
    --condition-threshold 5 \
    --condition-operator "GreaterThan" \
    --evaluation-frequency 5m \
    --window-size 5m \
    --severity 2 \
    --description "More than 5 exceptions in 5 minutes" \
    --action ContainerApp-Webhook-Alerts

# Memory usage alert
az monitor scheduled-query create \
    --name "High Memory Usage" \
    --resource-group $RESOURCE_GROUP \
    --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/$LOG_WORKSPACE" \
    --condition-query "InsightsMetrics | where Namespace == 'container.azm.ms/memoryRssBytes' | where Name == 'memoryRssBytes' | summarize AvgMemory = avg(Val) by bin(TimeGenerated, 5m)" \
    --condition-threshold 1073741824 \
    --condition-operator "GreaterThan" \
    --evaluation-frequency 5m \
    --window-size 5m \
    --severity 3 \
    --description "Memory usage above 1GB" \
    --action ContainerApp-Email-Alerts
```

## 📈 Custom Metrics Implementation

### Application-Level Metrics

```csharp
public class MetricsService
{
    private readonly TelemetryClient _telemetryClient;
    private readonly ILogger<MetricsService> _logger;

    public MetricsService(TelemetryClient telemetryClient, ILogger<MetricsService> logger)
    {
        _telemetryClient = telemetryClient;
        _logger = logger;
    }

    public void TrackBusinessMetric(string metricName, double value, IDictionary<string, string> properties = null)
    {
        _telemetryClient.TrackMetric(metricName, value, properties);
        _logger.LogInformation("Tracked metric {MetricName} with value {Value}", metricName, value);
    }

    public void TrackUserActivity(string activity, string userId, IDictionary<string, string> additionalProperties = null)
    {
        var properties = new Dictionary<string, string>
        {
            ["UserId"] = userId,
            ["Activity"] = activity,
            ["Timestamp"] = DateTimeOffset.UtcNow.ToString("O")
        };

        if (additionalProperties != null)
        {
            foreach (var prop in additionalProperties)
            {
                properties[prop.Key] = prop.Value;
            }
        }

        _telemetryClient.TrackEvent("UserActivity", properties);
    }

    public void TrackPerformanceCounter(string counterName, double value)
    {
        _telemetryClient.TrackMetric($"Performance.{counterName}", value);
    }
}
```

### Usage in Controllers

```csharp
[ApiController]
[Route("api/[controller]")]
public class WeatherForecastController : ControllerBase
{
    private readonly MetricsService _metricsService;
    private readonly TelemetryClient _telemetryClient;

    public WeatherForecastController(MetricsService metricsService, TelemetryClient telemetryClient)
    {
        _metricsService = metricsService;
        _telemetryClient = telemetryClient;
    }

    [HttpGet(Name = "GetWeatherForecast")]
    public IEnumerable<WeatherForecast> Get()
    {
        using var operation = _telemetryClient.StartOperation<DependencyTelemetry>("GetWeatherForecast");
        
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            var forecasts = GetForecasts();
            
            // Track business metrics
            _metricsService.TrackBusinessMetric("WeatherForecast.RequestCount", 1);
            _metricsService.TrackBusinessMetric("WeatherForecast.ResultCount", forecasts.Count());
            
            // Track performance metrics
            stopwatch.Stop();
            _metricsService.TrackPerformanceCounter("WeatherForecast.ProcessingTime", stopwatch.ElapsedMilliseconds);
            
            operation.Telemetry.Success = true;
            return forecasts;
        }
        catch (Exception ex)
        {
            operation.Telemetry.Success = false;
            _telemetryClient.TrackException(ex);
            throw;
        }
    }

    private IEnumerable<WeatherForecast> GetForecasts()
    {
        // Simulate processing time
        Thread.Sleep(Random.Shared.Next(10, 100));
        
        return Enumerable.Range(1, 5).Select(index => new WeatherForecast
        {
            Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            TemperatureC = Random.Shared.Next(-20, 55),
            Summary = Summaries[Random.Shared.Next(Summaries.Length)]
        }).ToArray();
    }
}
```

## 🎯 Health Monitoring

### Advanced Health Checks

```csharp
public class DatabaseHealthCheck : IHealthCheck
{
    private readonly IServiceScopeFactory _scopeFactory;

    public DatabaseHealthCheck(IServiceScopeFactory scopeFactory)
    {
        _scopeFactory = scopeFactory;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            
            var canConnect = await dbContext.Database.CanConnectAsync(cancellationToken);
            
            if (canConnect)
            {
                var recordCount = await dbContext.Products.CountAsync(cancellationToken);
                return HealthCheckResult.Healthy($"Database connection successful. {recordCount} products in database.");
            }
            
            return HealthCheckResult.Unhealthy("Cannot connect to database");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy($"Database health check failed: {ex.Message}");
        }
    }
}

public class ExternalServiceHealthCheck : IHealthCheck
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<ExternalServiceHealthCheck> _logger;

    public ExternalServiceHealthCheck(HttpClient httpClient, ILogger<ExternalServiceHealthCheck> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        try
        {
            var response = await _httpClient.GetAsync("/health", cancellationToken);
            
            if (response.IsSuccessStatusCode)
            {
                var responseTime = response.Headers.Date?.Subtract(DateTimeOffset.UtcNow).TotalMilliseconds ?? 0;
                return HealthCheckResult.Healthy($"External service is healthy. Response time: {Math.Abs(responseTime)}ms");
            }
            
            return HealthCheckResult.Degraded($"External service returned {response.StatusCode}");
        }
        catch (TaskCanceledException)
        {
            return HealthCheckResult.Unhealthy("External service health check timed out");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "External service health check failed");
            return HealthCheckResult.Unhealthy($"External service health check failed: {ex.Message}");
        }
    }
}
```

### Health Check Configuration

```csharp
// Program.cs
builder.Services.AddHealthChecks()
    .AddCheck<DatabaseHealthCheck>("database")
    .AddCheck<ExternalServiceHealthCheck>("external-service")
    .AddCheck("memory", () =>
    {
        var allocated = GC.GetTotalMemory(false);
        var memoryLimit = 1024 * 1024 * 1024; // 1GB
        
        return allocated < memoryLimit * 0.8 
            ? HealthCheckResult.Healthy($"Memory usage: {allocated / 1024 / 1024}MB")
            : HealthCheckResult.Degraded($"High memory usage: {allocated / 1024 / 1024}MB");
    })
    .AddCheck("disk-space", () =>
    {
        var drives = DriveInfo.GetDrives().Where(d => d.IsReady);
        var rootDrive = drives.FirstOrDefault(d => d.Name == "/");
        
        if (rootDrive != null)
        {
            var freeSpacePercentage = (double)rootDrive.AvailableFreeSpace / rootDrive.TotalSize * 100;
            
            return freeSpacePercentage > 10
                ? HealthCheckResult.Healthy($"Disk space: {freeSpacePercentage:F1}% free")
                : HealthCheckResult.Unhealthy($"Low disk space: {freeSpacePercentage:F1}% free");
        }
        
        return HealthCheckResult.Healthy("Disk space check not applicable");
    });

// Configure health check endpoints
app.MapHealthChecks("/health", new HealthCheckOptions
{
    Predicate = _ => false // Exclude all checks for basic health
});

app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready"),
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
});

app.MapHealthChecks("/health/live", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("live"),
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
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
```

## 📊 Dashboard Configuration

### Azure Dashboard JSON

```json
{
    "properties": {
        "lenses": {
            "0": {
                "order": 0,
                "parts": {
                    "0": {
                        "position": {"x": 0, "y": 0, "rowSpan": 4, "colSpan": 6},
                        "metadata": {
                            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
                            "settings": {
                                "content": {
                                    "options": {
                                        "chart": {
                                            "metrics": [{
                                                "resourceMetadata": {
                                                    "id": "/subscriptions/{subscription}/resourceGroups/{rg}/providers/Microsoft.App/containerApps/{app}"
                                                },
                                                "name": "Requests",
                                                "aggregationType": 4,
                                                "namespace": "Microsoft.App/containerApps",
                                                "metricVisualization": {
                                                    "displayName": "Request Count"
                                                }
                                            }],
                                            "title": "Request Volume",
                                            "titleKind": 1,
                                            "visualization": {
                                                "chartType": 2
                                            },
                                            "timespan": {
                                                "relative": {
                                                    "duration": 21600000
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    },
                    "1": {
                        "position": {"x": 6, "y": 0, "rowSpan": 4, "colSpan": 6},
                        "metadata": {
                            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
                            "settings": {
                                "content": {
                                    "options": {
                                        "chart": {
                                            "metrics": [{
                                                "resourceMetadata": {
                                                    "id": "/subscriptions/{subscription}/resourceGroups/{rg}/providers/Microsoft.App/containerApps/{app}"
                                                },
                                                "name": "CpuUsage",
                                                "aggregationType": 4,
                                                "namespace": "Microsoft.App/containerApps",
                                                "metricVisualization": {
                                                    "displayName": "CPU Usage"
                                                }
                                            }],
                                            "title": "CPU Utilization",
                                            "titleKind": 1,
                                            "visualization": {
                                                "chartType": 2
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        },
        "metadata": {
            "model": {
                "timeRange": {
                    "value": {
                        "relative": {
                            "duration": 24,
                            "timeUnit": 1
                        }
                    },
                    "type": "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
                }
            }
        }
    }
}
```

### Grafana Dashboard (Optional)

```json
{
    "dashboard": {
        "title": "Container Apps Monitoring",
        "panels": [
            {
                "title": "Request Rate",
                "type": "graph",
                "targets": [
                    {
                        "expr": "rate(requests_total[5m])",
                        "legendFormat": "{{method}} {{status}}"
                    }
                ]
            },
            {
                "title": "Response Time",
                "type": "graph",
                "targets": [
                    {
                        "expr": "histogram_quantile(0.95, rate(request_duration_seconds_bucket[5m]))",
                        "legendFormat": "95th percentile"
                    }
                ]
            }
        ]
    }
}
```

## 🔧 Monitoring Best Practices

### 1. Layered Monitoring Strategy
- **Infrastructure**: Container health, resource usage
- **Application**: Request/response metrics, business KPIs
- **User Experience**: End-to-end transaction monitoring

### 2. Alerting Guidelines
- **Critical**: Service down, high error rates
- **Warning**: Performance degradation, resource pressure
- **Info**: Deployment events, configuration changes

### 3. Retention Policies
```bash
# Set data retention for different data types
# Application Insights: 90 days for detailed telemetry
# Log Analytics: 30 days for logs, 2 years for metrics
# Archive older data to storage accounts for compliance
```

### 4. Cost Optimization
- Use sampling for high-volume applications
- Configure appropriate retention periods
- Filter out noise from logs and metrics
- Use Log Analytics data export for long-term storage

## 📚 Additional Resources

- [Application Insights Best Practices](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
- [Azure Monitor Log Queries](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/queries)
- [Container Apps Monitoring](https://docs.microsoft.com/en-us/azure/container-apps/monitoring)
- [KQL Reference](https://docs.microsoft.com/en-us/azure/data-explorer/kql-quick-reference)
