# Exercise 4: Advanced Configuration

## 🎯 Objective
Configure advanced monitoring, custom domains, service communication, and production-ready security features for your Azure Container Apps deployment. This exercise covers enterprise-level configuration and operational excellence.

## ⏱️ Estimated Time: 15 minutes

## 📋 Prerequisites
- Completed Exercises 1-3
- Application deployed via CI/CD pipeline
- Basic understanding of Application Insights and Azure monitoring
- Custom domain (optional, can use Azure-provided domain)

## 🎓 Learning Goals
- Set up comprehensive Application Insights monitoring
- Configure custom domains with SSL certificates
- Implement service-to-service communication
- Set up centralized logging and alerting
- Configure network security and access controls
- Implement advanced scaling and performance optimization

---

## 📚 Background Information

### Production Monitoring Strategy
Production container applications require comprehensive observability:
- **Application Performance Monitoring (APM)**: Request tracing, dependency tracking
- **Infrastructure Monitoring**: Container metrics, resource usage
- **Log Aggregation**: Centralized logging across all services
- **Alerting**: Proactive notification of issues
- **Health Checks**: Deep health monitoring beyond basic HTTP checks

### Service Communication Patterns
In microservices architectures, services need to communicate securely:
- **Service Discovery**: Finding and connecting to other services
- **Load Balancing**: Distributing requests across instances
- **Circuit Breakers**: Handling service failures gracefully
- **Authentication**: Securing service-to-service communication

---

## 📝 Tasks

### Task 1: Application Insights Integration (5 minutes)

#### 1.1 Create Application Insights Resource
```bash
# Set variables
RESOURCE_GROUP="rg-containerapp-demo"
APP_INSIGHTS_NAME="ai-productapi-$(date +%s)"
LOCATION="eastus"

# Create Application Insights
az monitor app-insights component create \
    --app $APP_INSIGHTS_NAME \
    --location $LOCATION \
    --resource-group $RESOURCE_GROUP \
    --application-type web

# Get connection string
APP_INSIGHTS_CONNECTION_STRING=$(az monitor app-insights component show \
    --app $APP_INSIGHTS_NAME \
    --resource-group $RESOURCE_GROUP \
    --query connectionString \
    --output tsv)

echo "Connection String: $APP_INSIGHTS_CONNECTION_STRING"
```

#### 1.2 Update Application Code for Monitoring
Add Application Insights to your ProductApi project:

```bash
# Add Application Insights package
cd ProductApi
dotnet add package Microsoft.ApplicationInsights.AspNetCore
```

Update `Program.cs`:

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add Application Insights
builder.Services.AddApplicationInsightsTelemetry();

// Add health checks with detailed checks
builder.Services.AddHealthChecks()
    .AddCheck("self", () => HealthCheckResult.Healthy("API is healthy"))
    .AddCheck("database", () => 
    {
        // Simulate database health check
        var isHealthy = DateTime.UtcNow.Second % 10 != 0; // Fail 10% of the time for demo
        return isHealthy ? HealthCheckResult.Healthy("Database is healthy") 
                        : HealthCheckResult.Unhealthy("Database connection failed");
    });

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Add detailed health check endpoint
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
                duration = e.Value.Duration.TotalMilliseconds
            }),
            totalDuration = report.TotalDuration.TotalMilliseconds
        };
        await context.Response.WriteAsync(JsonSerializer.Serialize(result));
    }
});

// Add simple health check
app.MapHealthChecks("/health");

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

// Add info endpoint for monitoring
app.MapGet("/info", (IWebHostEnvironment env, IConfiguration config) => new
{
    Environment = env.EnvironmentName,
    Version = config["APP_VERSION"] ?? "1.0.0",
    Timestamp = DateTime.UtcNow,
    MachineName = Environment.MachineName,
    ConnectionString = !string.IsNullOrEmpty(config.GetConnectionString("ApplicationInsights"))
});

app.Run();
```

#### 1.3 Update Container App with Application Insights
```bash
CONTAINER_APP_NAME="productapi"

# Update container app with Application Insights connection string
az containerapp update \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --set-env-vars "APPLICATIONINSIGHTS_CONNECTION_STRING=$APP_INSIGHTS_CONNECTION_STRING"

# Redeploy with updated code (trigger your CI/CD pipeline or manual update)
```

### Task 2: Advanced Logging and Monitoring (3 minutes)

#### 2.1 Create Log Analytics Queries
Access Log Analytics workspace and create useful queries:

```bash
# Get Log Analytics workspace info
LOG_WORKSPACE=$(az monitor log-analytics workspace list \
    --resource-group $RESOURCE_GROUP \
    --query "[0].name" \
    --output tsv)

echo "Log Analytics Workspace: $LOG_WORKSPACE"
```

Useful KQL queries for Container Apps:

```kql
// Container App Logs
ContainerAppConsoleLogs_CL
| where ContainerAppName_s == "productapi"
| order by TimeGenerated desc
| take 100

// HTTP Requests
requests
| where name contains "WeatherForecast"
| summarize count(), avg(duration) by bin(timestamp, 5m)
| order by timestamp desc

// Failed Requests
requests
| where success == false
| project timestamp, name, resultCode, duration
| order by timestamp desc

// Dependencies
dependencies
| where name contains "database"
| summarize count(), avg(duration) by bin(timestamp, 5m)
| order by timestamp desc

// Performance Counters
performanceCounters
| where name == "% Processor Time"
| summarize avg(value) by bin(timestamp, 5m)
| order by timestamp desc
```

#### 2.2 Set Up Alerts
```bash
# Create action group for notifications
ACTION_GROUP_NAME="ag-productapi-alerts"

az monitor action-group create \
    --name $ACTION_GROUP_NAME \
    --resource-group $RESOURCE_GROUP \
    --short-name "ProductAPI"

# Create alert for high error rate
az monitor metrics alert create \
    --name "High Error Rate" \
    --resource-group $RESOURCE_GROUP \
    --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.App/containerApps/$CONTAINER_APP_NAME" \
    --condition "avg requests/failed > 5" \
    --window-size 5m \
    --evaluation-frequency 1m \
    --action $ACTION_GROUP_NAME

# Create alert for high response time
az monitor metrics alert create \
    --name "High Response Time" \
    --resource-group $RESOURCE_GROUP \
    --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.App/containerApps/$CONTAINER_APP_NAME" \
    --condition "avg requests/duration > 1000" \
    --window-size 5m \
    --evaluation-frequency 1m \
    --action $ACTION_GROUP_NAME
```

### Task 3: Service-to-Service Communication (4 minutes)

#### 3.1 Create a Second Service
Create a simple user service to demonstrate service communication:

```bash
# Create UserService project
mkdir UserService
cd UserService
dotnet new webapi -n UserService

# Add Application Insights
dotnet add package Microsoft.ApplicationInsights.AspNetCore
dotnet add package System.Text.Json
```

Create `UserService/Controllers/UsersController.cs`:

```csharp
using Microsoft.AspNetCore.Mvc;

namespace UserService.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private static readonly List<User> Users = new()
    {
        new User { Id = 1, Name = "John Doe", Email = "email@yourdomain.com" },
        new User { Id = 2, Name = "Jane Smith", Email = "email@yourdomain.com" },
        new User { Id = 3, Name = "Bob Johnson", Email = "email@yourdomain.com" }
    };

    [HttpGet]
    public ActionResult<IEnumerable<User>> Get()
    {
        return Ok(Users);
    }

    [HttpGet("{id}")]
    public ActionResult<User> Get(int id)
    {
        var user = Users.FirstOrDefault(u => u.Id == id);
        return user == null ? NotFound() : Ok(user);
    }
}

public record User
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
}
```

Create `UserService/Dockerfile`:

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS base
WORKDIR /app
EXPOSE 8080

RUN addgroup -g 1000 appgroup && adduser -u 1000 -G appgroup -s /bin/sh -D appuser
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src

COPY ["UserService.csproj", "."]
RUN dotnet restore "./UserService.csproj" --runtime linux-musl-x64

COPY . .
RUN dotnet build "UserService.csproj" -c Release -o /app/build --runtime linux-musl-x64 --no-restore

FROM build AS publish
RUN dotnet publish "UserService.csproj" -c Release -o /app/publish \
    --runtime linux-musl-x64 \
    --self-contained false \
    --no-restore

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "UserService.dll"]
```

#### 3.2 Deploy UserService
```bash
# Build and push UserService
ACR_NAME="your-acr-name"  # Use your ACR name from previous exercises

az acr build \
    --registry $ACR_NAME \
    --image userservice:v1.0 \
    .

# Deploy UserService
az containerapp create \
    --name userservice \
    --resource-group $RESOURCE_GROUP \
    --environment env-containerapp-demo \
    --image $ACR_NAME.azurecr.io/userservice:v1.0 \
    --registry-server $ACR_NAME.azurecr.io \
    --target-port 8080 \
    --ingress internal \
    --cpu 0.25 \
    --memory 0.5Gi \
    --min-replicas 1 \
    --max-replicas 3 \
    --set-env-vars "APPLICATIONINSIGHTS_CONNECTION_STRING=$APP_INSIGHTS_CONNECTION_STRING"
```

#### 3.3 Update ProductApi to Call UserService
Add HTTP client to ProductApi:

```csharp
// In Program.cs, add HTTP client
builder.Services.AddHttpClient("UserService", client =>
{
    client.BaseAddress = new Uri("https://userservice.internal.your-environment-url.eastus.azurecontainerapps.io/");
    client.DefaultRequestHeaders.Add("User-Agent", "ProductApi/1.0");
});

// Add new controller method
[HttpGet("users")]
public async Task<IActionResult> GetUsers([FromServices] IHttpClientFactory httpClientFactory)
{
    try
    {
        var client = httpClientFactory.CreateClient("UserService");
        var response = await client.GetAsync("api/users");
        
        if (response.IsSuccessStatusCode)
        {
            var users = await response.Content.ReadAsStringAsync();
            return Ok(new { Users = JsonSerializer.Deserialize<object[]>(users) });
        }
        
        return StatusCode((int)response.StatusCode, "Failed to fetch users");
    }
    catch (Exception ex)
    {
        return StatusCode(500, $"Error calling UserService: {ex.Message}");
    }
}
```

### Task 4: Network Security and Custom Domains (3 minutes)

#### 4.1 Configure Custom Domain (Optional)
If you have a custom domain:

```bash
CUSTOM_DOMAIN="api.yourdomain.com"

# Add custom domain
az containerapp hostname add \
    --hostname $CUSTOM_DOMAIN \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP

# Bind certificate (requires domain verification)
az containerapp hostname bind \
    --hostname $CUSTOM_DOMAIN \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --validation-method CNAME
```

#### 4.2 Configure Network Access Control
```bash
# Configure access restrictions (if using VNET integration)
az containerapp ingress access-restriction set \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --rule-name "Allow-Office" \
    --ip-address "203.0.113.0/24" \
    --action Allow \
    --description "Allow office network"

# Configure CORS for web applications
az containerapp ingress cors enable \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --allowed-origins "https://yourdomain.com" \
    --allowed-methods "GET,POST,PUT,DELETE" \
    --allowed-headers "Content-Type,Authorization"
```

#### 4.3 Advanced Scaling Configuration
```bash
# Configure advanced scaling rules
az containerapp update \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --scale-rule-name "cpu-scaling" \
    --scale-rule-type "cpu" \
    --scale-rule-metadata "type=Utilization" "value=70" \
    --scale-rule-name "memory-scaling" \
    --scale-rule-type "memory" \
    --scale-rule-metadata "type=Utilization" "value=80"

# Set advanced replica configuration
az containerapp update \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --min-replicas 2 \
    --max-replicas 10
```

---

## ✅ Verification Checklist

Mark each item as complete:

- [ ] Integrated Application Insights with detailed telemetry
- [ ] Set up comprehensive health checks with detailed responses
- [ ] Created Log Analytics queries for monitoring
- [ ] Configured alerts for error rates and performance
- [ ] Deployed second service (UserService) for communication
- [ ] Implemented service-to-service HTTP communication
- [ ] Configured internal and external ingress appropriately
- [ ] Set up network security and access controls
- [ ] Implemented advanced scaling rules
- [ ] Verified all monitoring and communication works

---

## 🔍 Testing Your Configuration

### Test Application Insights
```bash
# Get your container app URL
APP_URL=$(az containerapp show \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --query properties.configuration.ingress.fqdn \
    --output tsv)

# Generate some traffic for monitoring
for i in {1..50}; do
    curl https://$APP_URL/WeatherForecast
    curl https://$APP_URL/healthz
    curl https://$APP_URL/info
    sleep 1
done

# Generate some errors (if you added the users endpoint)
for i in {1..10}; do
    curl https://$APP_URL/WeatherForecast/users
    sleep 1
done
```

### Verify Monitoring Data
1. **Go to Azure Portal**
2. **Navigate to Application Insights resource**
3. **Check these sections**:
   - Live Metrics Stream
   - Application Map
   - Performance
   - Failures
   - Logs

### Test Health Checks
```bash
# Test detailed health check
curl https://$APP_URL/healthz | jq '.'

# Test simple health check
curl https://$APP_URL/health
```

---

## 🎯 Expected Outcomes

After completing this exercise, you should have:

1. **Comprehensive Monitoring**: Full observability into application performance
2. **Service Architecture**: Multi-service communication pattern
3. **Production Readiness**: Health checks, alerts, and scaling configuration
4. **Security Configuration**: Network access controls and secure communication
5. **Operational Excellence**: Centralized logging and monitoring

### Monitoring Capabilities
- **Request Tracing**: End-to-end request visibility
- **Dependency Tracking**: External service call monitoring
- **Performance Metrics**: Response times, throughput, error rates
- **Custom Metrics**: Business-specific measurements
- **Alerting**: Proactive issue notification

---

## 🔧 Troubleshooting Guide

### Issue 1: Application Insights Not Showing Data
```bash
# Verify connection string
az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP \
    --query "properties.template.containers[0].env[?name=='APPLICATIONINSIGHTS_CONNECTION_STRING']"

# Check application logs
az containerapp logs show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --tail 50
```

### Issue 2: Service Communication Fails
```bash
# Check internal service URL
az containerapp show --name userservice --resource-group $RESOURCE_GROUP \
    --query "properties.configuration.ingress.fqdn"

# Verify both services are in same environment
az containerapp list --resource-group $RESOURCE_GROUP --query "[].{name:name,environment:properties.managedEnvironmentId}"
```

### Issue 3: Health Checks Failing
```bash
# Test health endpoints directly
curl -v https://$APP_URL/health
curl -v https://$APP_URL/healthz

# Check health check configuration
az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP \
    --query "properties.template.containers[0].probes"
```

---

## 🏆 Bonus Challenges

### Challenge 1: Custom Metrics
Add custom business metrics to your application:

```csharp
// In ProductApi
builder.Services.AddSingleton<TelemetryClient>();

// In controller
public class WeatherForecastController : ControllerBase
{
    private readonly TelemetryClient _telemetryClient;
    
    public WeatherForecastController(TelemetryClient telemetryClient)
    {
        _telemetryClient = telemetryClient;
    }
    
    [HttpGet(Name = "GetWeatherForecast")]
    public IEnumerable<WeatherForecast> Get()
    {
        _telemetryClient.TrackEvent("WeatherForecastRequested");
        _telemetryClient.TrackMetric("ActiveUsers", 1);
        
        // Existing code...
    }
}
```

### Challenge 2: Distributed Tracing
Implement correlation IDs for request tracing:

```csharp
// Add correlation ID middleware
app.Use(async (context, next) =>
{
    var correlationId = context.Request.Headers["X-Correlation-ID"].FirstOrDefault() 
                       ?? Guid.NewGuid().ToString();
    
    context.Response.Headers.Add("X-Correlation-ID", correlationId);
    context.Items["CorrelationId"] = correlationId;
    
    using var scope = _telemetryClient.StartOperation<RequestTelemetry>("HTTP Request");
    scope.Telemetry.Properties["CorrelationId"] = correlationId;
    
    await next();
});
```

### Challenge 3: Circuit Breaker Pattern
Implement circuit breaker for service calls:

```csharp
// Add Polly for resilience
dotnet add package Polly
dotnet add package Polly.Extensions.Http

// Configure circuit breaker
builder.Services.AddHttpClient("UserService")
    .AddPolicyHandler(Policy.CircuitBreakerAsync<HttpResponseMessage>(
        2, TimeSpan.FromMinutes(1),
        onBreak: (exception, duration) => {
            // Log circuit breaker opened
        },
        onReset: () => {
            // Log circuit breaker closed
        }));
```

---

## 📊 Monitoring Dashboard Example

Create a custom dashboard in Azure Portal:

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
                                                "namespace": "Microsoft.App/containerApps"
                                            }]
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
```

---

## 📚 Additional Resources

### Application Insights
- [Application Insights for ASP.NET Core](https://docs.microsoft.com/en-us/azure/azure-monitor/app/asp-net-core)
- [Custom Metrics and Events](https://docs.microsoft.com/en-us/azure/azure-monitor/app/api-custom-events-metrics)
- [Distributed Tracing](https://docs.microsoft.com/en-us/azure/azure-monitor/app/distributed-tracing)

### Container Apps Networking
- [Container Apps Networking](https://docs.microsoft.com/en-us/azure/container-apps/networking)
- [Custom Domains and SSL](https://docs.microsoft.com/en-us/azure/container-apps/custom-domains-certificates)
- [Service Discovery](https://docs.microsoft.com/en-us/azure/container-apps/connect-apps)

### Monitoring and Alerting
- [Azure Monitor Alerts](https://docs.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview)
- [Log Analytics KQL](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/kql-quick-reference)
- [Monitoring Best Practices](https://docs.microsoft.com/en-us/azure/azure-monitor/best-practices)

---

## 🚀 Next Steps

After completing this exercise, you're ready for production deployment! Consider these next steps:

1. **Performance Testing**: Load test your application under realistic conditions
2. **Security Review**: Implement additional security measures for production
3. **Disaster Recovery**: Set up backup and recovery procedures
4. **Cost Optimization**: Monitor and optimize Azure costs
5. **Team Training**: Share knowledge with your development team

**Key takeaways to remember**:
- Comprehensive monitoring is essential for production applications
- Service-to-service communication requires careful design
- Health checks should validate actual application functionality
- Security should be configured from the start, not added later
- Automation reduces operational overhead and improves reliability

---

**🎉 Congratulations!** You've successfully configured a production-ready containerized application with comprehensive monitoring, service communication, and operational excellence. Your application is now ready for enterprise deployment!

## 🎓 Module 9 Completion

You have successfully completed all exercises in Module 9: Azure Container Apps. You should now be comfortable with:

- ✅ Containerizing ASP.NET Core applications
- ✅ Deploying to Azure Container Apps
- ✅ Setting up CI/CD pipelines
- ✅ Configuring production monitoring and security
- ✅ Implementing service communication patterns
- ✅ Managing configuration and secrets
- ✅ Setting up alerts and observability

**Ready for Module 10: Security Fundamentals** where you'll learn advanced security patterns and implementation strategies!
