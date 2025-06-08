# Exercise 4: Advanced Configuration and Monitoring

## 🎯 Objective
Configure advanced features for your Azure Container Apps deployment including monitoring, custom domains, networking, and production-ready configurations—all without Docker Desktop.

## ⏱️ Estimated Time: 15 minutes

## 📋 Prerequisites
- Completed Exercises 1-3
- Azure Container Apps deployment running
- Application Insights created (from Exercise 2)
- Basic understanding of Azure networking

## 🎓 Learning Goals
- Configure comprehensive monitoring with Application Insights
- Set up custom domains and SSL certificates
- Implement advanced networking configurations
- Configure autoscaling rules
- Set up alerts and dashboards

---

## 📚 Background Information

### Production-Ready Container Apps
Moving to production requires additional configurations:

- **Monitoring**: Application Insights for deep telemetry
- **Security**: Custom domains with managed certificates
- **Networking**: VNet integration for secure communication
- **Performance**: Autoscaling based on various metrics
- **Reliability**: Health probes and circuit breakers

### Azure Monitor Integration
Container Apps provides built-in integration with Azure Monitor:
- **Metrics**: CPU, memory, requests, latency
- **Logs**: Application and system logs
- **Traces**: Distributed tracing across services
- **Alerts**: Proactive notification of issues

---

## 🛠️ Setup Instructions

### Load Previous Configuration
```bash
# Load your variables from previous exercises
$RESOURCE_GROUP="rg-containerapp-demo"
$LOCATION="eastus"
$ACR_NAME=$(az acr list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv)
$ENVIRONMENT="containerapp-env"
$KEY_VAULT=$(az keyvault list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv)
```

---

## 📝 Tasks

### Task 1: Enhanced Monitoring Setup (5 minutes)

1. **Ensure Application Insights is configured**:
```bash
# Get or create Application Insights
$APP_INSIGHTS=$(az monitor app-insights component list `
  --resource-group $RESOURCE_GROUP `
  --query "[0].name" -o tsv)

if (-not $APP_INSIGHTS) {
    $APP_INSIGHTS="appi-containerapp"
    az monitor app-insights component create `
      --app $APP_INSIGHTS `
      --location $LOCATION `
      --resource-group $RESOURCE_GROUP
}

# Get connection string
$APPINSIGHTS_CONNECTION=$(az monitor app-insights component show `
  --app $APP_INSIGHTS `
  --resource-group $RESOURCE_GROUP `
  --query connectionString -o tsv)
```

2. **Update Container App with enhanced monitoring**:
```bash
az containerapp update `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --set-env-vars `
    "ApplicationInsights__ConnectionString=$APPINSIGHTS_CONNECTION" `
    "ASPNETCORE_ENVIRONMENT=Production"
```

3. **Create custom dashboard**:
```bash
# Create dashboard JSON
@"
{
  "properties": {
    "lenses": [
      {
        "parts": [
          {
            "position": {"x": 0, "y": 0, "colSpan": 6, "rowSpan": 4},
            "metadata": {
              "type": "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart",
              "settings": {
                "title": "Container App Performance",
                "subtitle": "CPU and Memory Usage"
              }
            }
          }
        ]
      }
    ]
  }
}
"@ | Out-File -FilePath dashboard.json

az portal dashboard create `
  --name "ContainerAppDashboard" `
  --resource-group $RESOURCE_GROUP `
  --input-path dashboard.json
```

### Task 2: Configure Custom Domain (5 minutes)

1. **Add custom domain** (requires domain ownership):
```bash
# Example with Azure DNS
$CUSTOM_DOMAIN="api.yourdomain.com"

# Add custom domain to Container App
az containerapp hostname add `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --hostname $CUSTOM_DOMAIN

# Bind managed certificate (automatic SSL)
az containerapp hostname bind `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --hostname $CUSTOM_DOMAIN `
  --environment $ENVIRONMENT `
  --validation-method CNAME
```

2. **Configure DNS** (in your DNS provider):
```text
Type: CNAME
Name: api
Value: weatherapi.azurecontainerapps.io
TTL: 3600
```

### Task 3: Advanced Scaling Configuration (3 minutes)

1. **Configure HTTP scaling rules**:
```bash
az containerapp update `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --min-replicas 1 `
  --max-replicas 10 `
  --scale-rule-name http-rule `
  --scale-rule-type http `
  --scale-rule-metadata concurrentRequests=50
```

2. **Add CPU-based scaling**:
```bash
az containerapp update `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --scale-rule-name cpu-rule `
  --scale-rule-type azure-monitor `
  --scale-rule-metadata "metricName=cpu" "metricResourceUri=/subscriptions/.../resourceGroups/$RESOURCE_GROUP/providers/Microsoft.App/containerApps/weatherapi" "targetValue=70"
```

3. **Configure scheduled scaling** (business hours):
```bash
# Scale up during business hours (8 AM - 6 PM weekdays)
az containerapp update `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --scale-rule-name schedule-rule `
  --scale-rule-type cron `
  --scale-rule-metadata `
    timezone="America/New_York" `
    start="0 8 * * MON-FRI" `
    end="0 18 * * MON-FRI" `
    desiredReplicas=5
```

### Task 4: Create Monitoring Alerts (2 minutes)

1. **Create response time alert**:
```bash
az monitor metrics alert create `
  --name "SlowResponseTime" `
  --resource-group $RESOURCE_GROUP `
  --scopes "/subscriptions/.../resourceGroups/$RESOURCE_GROUP/providers/Microsoft.App/containerApps/weatherapi" `
  --condition "avg requests/latency > 500" `
  --window-size 5m `
  --evaluation-frequency 1m `
  --severity 2 `
  --description "Alert when average response time exceeds 500ms"
```

2. **Create error rate alert**:
```bash
az monitor metrics alert create `
  --name "HighErrorRate" `
  --resource-group $RESOURCE_GROUP `
  --scopes "/subscriptions/.../resourceGroups/$RESOURCE_GROUP/providers/Microsoft.App/containerApps/weatherapi" `
  --condition "avg requests/failed > 10" `
  --window-size 5m `
  --evaluation-frequency 1m `
  --severity 1 `
  --description "Alert when error rate exceeds 10 requests per minute"
```

---

## ✅ Verification Steps

1. **Check Application Insights**:
```bash
# Open Application Insights in browser
$APP_INSIGHTS_ID=$(az monitor app-insights component show `
  --app $APP_INSIGHTS `
  --resource-group $RESOURCE_GROUP `
  --query id -o tsv)

Start-Process "https://portal.azure.com/#resource$APP_INSIGHTS_ID/overview"
```

2. **Generate load for monitoring**:
```bash
# Simple load test
$APP_URL=$(az containerapp show `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --query properties.configuration.ingress.fqdn -o tsv)

# Generate 100 requests
1..100 | ForEach-Object {
    Invoke-RestMethod -Uri "https://$APP_URL/weatherforecast" -Method Get
    Start-Sleep -Milliseconds 100
}
```

3. **View metrics**:
```bash
# Get recent metrics
az monitor metrics list `
  --resource "/subscriptions/.../resourceGroups/$RESOURCE_GROUP/providers/Microsoft.App/containerApps/weatherapi" `
  --metric "Requests" `
  --interval PT1M `
  --start-time (Get-Date).AddMinutes(-10).ToString("yyyy-MM-ddTHH:mm:ssZ") `
  --end-time (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
```

---

## 🎉 Success Criteria

You've successfully completed this exercise if:
- ✅ Application Insights is collecting telemetry
- ✅ Custom dashboard is created
- ✅ Autoscaling rules are configured
- ✅ Monitoring alerts are active
- ✅ Metrics are visible in Azure Portal

---

## 🚀 Bonus Challenges

1. **Add Distributed Tracing**:
```csharp
// In Program.cs
builder.Services.AddApplicationInsightsTelemetry();
builder.Services.ConfigureTelemetryModule<DependencyTrackingTelemetryModule>((module, o) => 
{
    module.EnableSqlCommandTextInstrumentation = true;
});
```

2. **Configure VNet Integration**:
```bash
# Create VNet
az network vnet create `
  --name vnet-containerapp `
  --resource-group $RESOURCE_GROUP `
  --address-prefix 10.0.0.0/16 `
  --subnet-name subnet-containerapp `
  --subnet-prefix 10.0.0.0/24

# Update Container Apps Environment
az containerapp env update `
  --name $ENVIRONMENT `
  --resource-group $RESOURCE_GROUP `
  --infrastructure-subnet-resource-id "/subscriptions/.../subnets/subnet-containerapp"
```

3. **Implement Health Check Dashboard**:
```bash
# Create Log Analytics query for health checks
$QUERY = @"
ContainerAppConsoleLogs_CL
| where ContainerAppName_s == 'weatherapi'
| where Log_s contains 'health'
| summarize HealthChecks = count() by bin(TimeGenerated, 1m)
| render timechart
"@

# Save as dashboard widget
```

4. **Set Up Multi-Region Deployment**:
```bash
# Deploy to second region
$LOCATION2="westus"
az containerapp create `
  --name weatherapi-west `
  --resource-group $RESOURCE_GROUP `
  --environment $ENVIRONMENT `
  --image "$ACR_NAME.azurecr.io/weatherapi:latest" `
  --target-port 80 `
  --ingress external `
  --location $LOCATION2
```

---

## 📚 Key Takeaways

- **Comprehensive Monitoring**: Application Insights provides deep insights
- **Auto-scaling**: Multiple scaling strategies for different scenarios
- **Security**: Custom domains with automatic SSL certificates
- **Alerting**: Proactive monitoring prevents issues
- **No Docker Required**: All configurations done through Azure

---

## 🧹 Cleanup

To avoid ongoing charges:
```bash
# Remove all resources
az group delete --name $RESOURCE_GROUP --yes --no-wait

# Or just scale down
az containerapp update `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --min-replicas 0 `
  --max-replicas 1
```

---

---

## 🎓 Module Summary

Congratulations! You've completed Module 9 and learned how to:
- ✅ Deploy ASP.NET Core apps to Azure without Docker Desktop
- ✅ Use Azure Container Registry for cloud builds
- ✅ Implement CI/CD with GitHub Actions
- ✅ Configure monitoring and alerts
- ✅ Set up production-ready configurations

### What You've Achieved
1. **Cloud-Native Development**: Built and deployed without local containers
2. **Enterprise Features**: Monitoring, scaling, custom domains
3. **Security**: Managed identities, Key Vault, SSL
4. **Automation**: Complete CI/CD pipeline
5. **Cost Optimization**: Scale to zero capabilities

### Next Steps
- Explore Module 10: Security Fundamentals
- Try deploying a multi-service application
- Implement more advanced networking scenarios
- Explore Dapr integration for microservices

---

**🎉 Well done!** You're now ready to deploy production applications to Azure Container Apps without needing Docker Desktop!

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
