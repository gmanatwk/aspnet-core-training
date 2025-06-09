# Azure Container Apps Best Practices for ASP.NET Core

## 🚀 Overview
This guide covers essential best practices for deploying ASP.NET Core applications to Azure Container Apps without requiring Docker Desktop or local container tools.

## 🌩️ Cloud-Native Development

### Build in the Cloud
Use Azure Container Registry (ACR) build tasks instead of local Docker:

```bash
# Build directly in Azure - no Docker required!
az acr build --registry myregistry --image myapp:v1 .

# ACR automatically detects .NET projects and creates optimal images
```

### Why Cloud Builds?
- **No Docker Desktop licensing**: Avoid enterprise licensing requirements
- **Consistent environments**: Build where you deploy
- **Secure by default**: No exposed Docker socket
- **Simplified CI/CD**: Direct integration with Azure services

## 📦 Application Preparation

### 1. Create Cloud-Ready Applications
Configure your ASP.NET Core app for containerization:

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);

// Configure for Azure Container Apps
builder.WebHost.ConfigureKestrel(serverOptions =>
{
    var port = builder.Configuration.GetValue("PORT", 80);
    serverOptions.ListenAnyIP(port);
});

// Add health checks
builder.Services.AddHealthChecks();

var app = builder.Build();

// Health endpoints for Azure monitoring
app.MapHealthChecks("/healthz");
app.MapHealthChecks("/health/ready");
app.MapHealthChecks("/health/live");
```

### 2. Minimal Dockerfile
Create a simple Dockerfile for ACR to use:

```dockerfile
# ACR will optimize this automatically
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app .
EXPOSE 80
ENTRYPOINT ["dotnet", "YourApp.dll"]
```

### 3. Configuration Management
Use environment variables for configuration:

```json
// appsettings.json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "AzureContainerApps": {
    "Environment": "Production"
  }
}
```

## 🚀 Deployment Best Practices

### 1. Resource Allocation
Right-size your container resources:

```bash
# Start small and scale based on metrics
az containerapp create \
  --cpu 0.25 \
  --memory 0.5Gi \
  --min-replicas 0 \
  --max-replicas 10
```

### 2. Scaling Configuration
Configure appropriate scaling rules:

```bash
# HTTP-based scaling
az containerapp update \
  --scale-rule-name http-rule \
  --scale-rule-type http \
  --scale-rule-metadata concurrentRequests=20

# CPU-based scaling
az containerapp update \
  --scale-rule-name cpu-rule \
  --scale-rule-type cpu \
  --scale-rule-metadata utilizationPercentage=70
```

### 3. Health Checks
Implement comprehensive health checks:

```csharp
public class HealthController : ControllerBase
{
    [HttpGet("/healthz")]
    public IActionResult Health() => Ok(new { status = "Healthy" });

    [HttpGet("/health/ready")]
    public async Task<IActionResult> Ready()
    {
        // Check database, external services
        var dbHealthy = await CheckDatabase();
        return dbHealthy ? Ok() : StatusCode(503);
    }

    [HttpGet("/health/live")]
    public IActionResult Live() => Ok();
}
```

## 🔒 Security Best Practices

### 1. Managed Identity
Use managed identity instead of connection strings:

```bash
# Enable system-assigned identity
az containerapp identity assign \
  --name myapp \
  --resource-group mygroup
```

### 2. Key Vault Integration
Store secrets in Azure Key Vault:

```bash
# Create secret in Key Vault
az keyvault secret set \
  --vault-name myvault \
  --name ConnectionString \
  --value "Server=..."

# Reference in Container App
az containerapp secret set \
  --name myapp \
  --secrets connectionstring=keyvault:myvault/ConnectionString
```

### 3. Network Security
Configure network restrictions:

```bash
# Restrict ingress to specific IPs
az containerapp ingress access-restriction set \
  --name myapp \
  --resource-group mygroup \
  --rule-name office \
  --ip-address 203.0.113.0/24 \
  --action Allow
```

## 📊 Monitoring and Observability

### 1. Application Insights
Always configure Application Insights:

```bash
# Add Application Insights
az containerapp update \
  --set-env-vars "APPLICATIONINSIGHTS_CONNECTION_STRING=$CONNECTION_STRING"
```

### 2. Structured Logging
Use structured logging for better insights:

```csharp
builder.Services.AddLogging(config =>
{
    config.AddConsole();
    config.AddApplicationInsights();
});

// Use structured logging
logger.LogInformation("Processing order {OrderId} for user {UserId}", 
    orderId, userId);
```

### 3. Custom Metrics
Track business metrics:

```csharp
public class MetricsService
{
    private readonly TelemetryClient _telemetryClient;

    public void TrackOrderProcessed(decimal amount)
    {
        _telemetryClient.TrackMetric("OrderAmount", amount);
        _telemetryClient.TrackEvent("OrderProcessed");
    }
}
```

## 🔄 CI/CD Best Practices

### 1. GitHub Actions
Build and deploy without Docker:

```yaml
name: Deploy to Azure Container Apps

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    - name: Build in ACR
      run: |
        az acr build \
          --registry ${{ vars.ACR_NAME }} \
          --image myapp:${{ github.sha }} .
    
    - name: Deploy to Container Apps
      run: |
        az containerapp update \
          --name myapp \
          --image ${{ vars.ACR_NAME }}.azurecr.io/myapp:${{ github.sha }}
```

### 2. Environment Promotion
Use separate environments:

```bash
# Development
az containerapp create --name myapp-dev --environment dev-env

# Staging
az containerapp create --name myapp-staging --environment staging-env

# Production
az containerapp create --name myapp-prod --environment prod-env
```

## 💰 Cost Optimization

### 1. Scale to Zero
Configure apps to scale to zero when not in use:

```bash
az containerapp update \
  --min-replicas 0 \
  --max-replicas 5
```

### 2. Resource Limits
Set appropriate resource limits:

```bash
# Development
--cpu 0.25 --memory 0.5Gi

# Production
--cpu 1 --memory 2Gi
```

### 3. Consumption Plan
Use consumption plan for variable workloads:

```bash
az containerapp env create \
  --name myenv \
  --resource-group mygroup \
  --location eastus \
  --logs-destination none  # Reduce logging costs
```

## 🚨 Common Pitfalls to Avoid

1. **Don't hardcode configuration** - Use environment variables
2. **Don't ignore health checks** - They're crucial for reliability
3. **Don't over-provision resources** - Start small and scale
4. **Don't skip monitoring** - Always configure Application Insights
5. **Don't use latest tags** - Use specific version tags
6. **Don't expose unnecessary ports** - Only expose what's needed
7. **Don't store secrets in code** - Use Key Vault or managed identity

## 📚 Additional Resources

- [Azure Container Apps Documentation](https://docs.microsoft.com/azure/container-apps/)
- [ASP.NET Core in Containers](https://docs.microsoft.com/aspnet/core/host-and-deploy/docker/)
- [Azure Container Apps Pricing](https://azure.microsoft.com/pricing/details/container-apps/)
- [Container Apps CLI Reference](https://docs.microsoft.com/cli/azure/containerapp)