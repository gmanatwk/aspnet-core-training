# Exercise 1: Application Preparation for Azure Container Apps

## 🎯 Objective
Learn to prepare an ASP.NET Core application for Azure Container Apps deployment without requiring Docker locally. This exercise covers application configuration, health checks, and cloud-ready patterns.

## ⏱️ Estimated Time: 30 minutes

## 📋 Prerequisites
- Azure subscription (free tier is sufficient)
- Azure CLI installed (version 2.50+)
- .NET 8 SDK installed
- Visual Studio or Visual Studio Code

## 🎓 Learning Goals
- Create cloud-ready ASP.NET Core applications
- Implement health checks for Azure Container Apps
- Configure applications for containerization without Docker
- Understand Azure Container Apps build process
- Prepare applications for scalable cloud deployment

---

## 📚 Background Information

### Azure Container Apps for .NET Developers
Azure Container Apps provides a serverless container platform without requiring local Docker installation:

- **Cloud-Native Build**: Azure builds your containers from source code
- **Automatic Scaling**: Scale from zero to thousands based on demand
- **Managed Infrastructure**: No cluster or VM management required
- **Built-in Features**: Load balancing, HTTPS, and traffic splitting included

### Why No Docker Required?
- **Simplified Development**: Focus on code, not container tooling
- **Cloud Build Service**: Azure Container Registry builds images for you
- **Consistent Environments**: Build where you deploy
- **No Licensing Concerns**: Avoid Docker Desktop licensing requirements

---

## 🛠️ Setup Instructions

### Step 1: Set Up Azure Resources
First, we'll create the necessary Azure resources for Container Apps.

1. **Login to Azure**:
```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_NAME" # If you have multiple subscriptions
```

2. **Install Container Apps extension**:
```bash
az extension add --name containerapp --upgrade -y
```

3. **Create resource group and environment**:
```bash
# Set variables
RESOURCE_GROUP="rg-containerapp-training"
LOCATION="eastus"
ENVIRONMENT="containerapp-env"
ACR_NAME="acr$(date +%s)"  # Unique name

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Container Registry
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --admin-enabled true

# Create Container Apps environment
az containerapp env create --name $ENVIRONMENT --resource-group $RESOURCE_GROUP --location $LOCATION

echo "Resources created successfully!"
echo "ACR Name: $ACR_NAME"
```

### Step 2: Create the Application
Now let's create a cloud-ready ASP.NET Core application.

1. **Create a new ASP.NET Core Web API**:
```bash
mkdir ContainerAppsDemo
cd ContainerAppsDemo
dotnet new webapi -n ProductApi
cd ProductApi
```

2. **Update Program.cs** for cloud deployment:
```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add health checks for Azure Container Apps
builder.Services.AddHealthChecks();

// Configure for Azure Container Apps
builder.WebHost.ConfigureKestrel(serverOptions =>
{
    var port = builder.Configuration.GetValue("PORT", 80);
    serverOptions.ListenAnyIP(port);
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Health check endpoints for Azure
app.MapHealthChecks("/healthz");
app.MapHealthChecks("/health/ready");
app.MapHealthChecks("/health/live");

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

---

## 📝 Tasks

### Task 1: Create a Minimal Dockerfile for Azure (5 minutes)

Create a `Dockerfile` in the root of your ProductApi project. This file tells Azure how to build your container:

```dockerfile
# Simple Dockerfile for Azure Container Apps
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app .
EXPOSE 80
ENTRYPOINT ["dotnet", "ProductApi.dll"]
```

**Note**: You don't need Docker installed! Azure Container Registry will use this file to build your image in the cloud.

**Key Points:**
- This Dockerfile is simpler since Azure handles optimization
- Azure Container Registry performs the build
- No local Docker daemon required

### Task 2: Add Health Check Controller (5 minutes)

Create a health check controller for Azure Container Apps monitoring:

1. **Create `Controllers/HealthController.cs`**:
```csharp
using Microsoft.AspNetCore.Mvc;

namespace ProductApi.Controllers;

[ApiController]
[Route("[controller]")]
public class HealthController : ControllerBase
{
    private readonly ILogger<HealthController> _logger;
    private readonly IConfiguration _configuration;

    public HealthController(ILogger<HealthController> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
    }

    [HttpGet("/healthz")]
    public IActionResult HealthCheck()
    {
        _logger.LogInformation("Health check requested");
        return Ok(new 
        { 
            status = "Healthy", 
            timestamp = DateTime.UtcNow,
            environment = _configuration["ASPNETCORE_ENVIRONMENT"]
        });
    }

    [HttpGet("/health/ready")]
    public IActionResult ReadinessCheck()
    {
        // Add checks for external dependencies
        return Ok(new { status = "Ready", timestamp = DateTime.UtcNow });
    }

    [HttpGet("/health/live")]
    public IActionResult LivenessCheck()
    {
        // Basic liveness check
        return Ok(new { status = "Live", timestamp = DateTime.UtcNow });
    }
}
```

2. **Test locally**:
```bash
dotnet run
# In another terminal:
curl http://localhost:5000/healthz
```

### Task 3: Build and Deploy to Azure Container Apps (10 minutes)

1. **Build the container image in Azure** (no Docker required!):
```bash
# Get your ACR name from the setup step
ACR_NAME=$(az acr list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv)

# Build in Azure Container Registry
az acr build --registry $ACR_NAME --image productapi:v1 .

echo "Image built successfully in Azure!"
```

2. **Deploy to Container Apps**:
```bash
# Get ACR credentials
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv)

# Create Container App
az containerapp create \
  --name productapi \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image "$ACR_LOGIN_SERVER/productapi:v1" \
  --registry-server $ACR_LOGIN_SERVER \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD \
  --target-port 80 \
  --ingress external \
  --min-replicas 0 \
  --max-replicas 5

# Get the app URL
APP_URL=$(az containerapp show --name productapi --resource-group $RESOURCE_GROUP --query properties.configuration.ingress.fqdn -o tsv)
echo "Your app is deployed at: https://$APP_URL"
```

3. **Test the deployed application**:
```bash
# Test health endpoint
curl https://$APP_URL/healthz

# Test the API
curl https://$APP_URL/weatherforecast

# View logs
az containerapp logs show --name productapi --resource-group $RESOURCE_GROUP --follow
```

### Task 4: Configure Application Settings (5 minutes)

1. **Update `appsettings.json`** for cloud deployment:
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "AzureContainerApps": {
    "Environment": "Production",
    "Version": "1.0.0"
  }
}
```

2. **Add environment variable support** in `Program.cs`:
```csharp
// Add this after creating the builder
builder.Configuration.AddEnvironmentVariables("APP_");

// Add a simple endpoint to show configuration
app.MapGet("/info", (IConfiguration config) => new
{
    Environment = config["ASPNETCORE_ENVIRONMENT"],
    Version = config["AzureContainerApps:Version"],
    CustomMessage = config["APP_MESSAGE"] ?? "Default message"
});
```

3. **Update Container App with environment variables**:
```bash
az containerapp update \
  --name productapi \
  --resource-group $RESOURCE_GROUP \
  --set-env-vars "APP_MESSAGE=Hello from Azure Container Apps!" "VERSION=1.0.0"
```

### Task 5: Enable Auto-Scaling (5 minutes)

1. **Configure scaling rules**:
```bash
# Add HTTP scaling rule
az containerapp update \
  --name productapi \
  --resource-group $RESOURCE_GROUP \
  --scale-rule-name http-rule \
  --scale-rule-type http \
  --scale-rule-metadata concurrentRequests=10
```

2. **Monitor scaling behavior**:
```bash
# Check current replicas
az containerapp revision list \
  --name productapi \
  --resource-group $RESOURCE_GROUP \
  --query "[0].properties.replicas" -o tsv

# Generate load (optional - requires a load testing tool)
# The app will auto-scale based on traffic
```

---

## ✅ Verification Checklist

Mark each item as complete:

- [ ] Created Azure resources (Resource Group, ACR, Container Apps Environment)
- [ ] Created a cloud-ready ASP.NET Core application
- [ ] Implemented health check endpoints
- [ ] Created a simple Dockerfile for Azure Container Registry
- [ ] Built container image in Azure (without Docker locally)
- [ ] Deployed application to Azure Container Apps
- [ ] Accessed the application via HTTPS URL
- [ ] Configured environment variables
- [ ] Set up auto-scaling rules
- [ ] Verified health endpoints are working

---

## 🎯 Expected Outcomes

After completing this exercise, you should have:

1. **Azure Resources**: Container Registry, Container Apps Environment set up
2. **Cloud-Ready App**: ASP.NET Core application configured for cloud deployment
3. **Container Image**: Built in Azure Container Registry (no local Docker)
4. **Live Application**: Running on Azure Container Apps with HTTPS
5. **Auto-Scaling**: Configured to scale based on traffic
6. **Health Monitoring**: Multiple health check endpoints for Azure

### Key Benefits Achieved
- **No Docker Required**: Built and deployed without local container tools
- **Serverless**: Pay only for what you use, scales to zero
- **Managed**: No infrastructure to maintain
- **Secure**: HTTPS by default, managed certificates

---

## 🔍 Troubleshooting Guide

### Common Issues and Solutions

**1. Azure CLI Not Logged In**
```bash
# Error: Please run 'az login' to setup account
az login
az account set --subscription "YOUR_SUBSCRIPTION_NAME"
```

**2. ACR Build Fails**
```bash
# Check ACR exists
az acr list --resource-group $RESOURCE_GROUP

# Ensure you're in the right directory
ls Dockerfile  # Should show the Dockerfile

# Try building with more verbose output
az acr build --registry $ACR_NAME --image productapi:v1 . --verbose
```

**3. Container App Not Accessible**
```bash
# Check ingress configuration
az containerapp ingress show --name productapi --resource-group $RESOURCE_GROUP

# Check application logs
az containerapp logs show --name productapi --resource-group $RESOURCE_GROUP --tail 50
```

**4. Health Check Issues**
```bash
# Verify locally first
dotnet run
curl http://localhost:5000/healthz

# Check Container App logs for errors
az containerapp logs show --name productapi --resource-group $RESOURCE_GROUP --follow
```

---

## 🏆 Bonus Challenges

If you complete the main tasks early, try these additional challenges:

### Challenge 1: Add Application Insights
1. Create Application Insights resource:
```bash
az monitor app-insights component create \
  --app productapi-insights \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP

# Get connection string
CONNECTION_STRING=$(az monitor app-insights component show \
  --app productapi-insights \
  --resource-group $RESOURCE_GROUP \
  --query connectionString -o tsv)
```

2. Update Container App:
```bash
az containerapp update \
  --name productapi \
  --resource-group $RESOURCE_GROUP \
  --set-env-vars "APPLICATIONINSIGHTS_CONNECTION_STRING=$CONNECTION_STRING"
```

### Challenge 2: Add Custom Domain
```bash
# Add a custom domain (requires DNS configuration)
az containerapp hostname add \
  --hostname yourdomain.com \
  --name productapi \
  --resource-group $RESOURCE_GROUP
```

### Challenge 3: Blue-Green Deployment
1. Deploy a new revision:
```bash
# Build new version
az acr build --registry $ACR_NAME --image productapi:v2 .

# Create new revision with traffic split
az containerapp update \
  --name productapi \
  --resource-group $RESOURCE_GROUP \
  --image "$ACR_LOGIN_SERVER/productapi:v2" \
  --revision-suffix v2 \
  --traffic-weight latest=20,previous=80
```

---

## 📖 Additional Reading

### Azure Container Apps Documentation
- [Azure Container Apps Overview](https://docs.microsoft.com/azure/container-apps/overview)
- [Build from Source Code](https://docs.microsoft.com/azure/container-apps/quickstart-code-to-cloud)
- [Health Probes Configuration](https://docs.microsoft.com/azure/container-apps/health-probes)

### Best Practices
- [Container Apps Best Practices](https://docs.microsoft.com/azure/container-apps/best-practices)
- [Scaling Configuration](https://docs.microsoft.com/azure/container-apps/scale-app)
- [Zero to Hero Guide](https://azure.microsoft.com/blog/azure-container-apps-zero-to-hero/)

---

## 🚀 Next Steps

Once you've completed this exercise:

1. **Review the deployment** - Check logs and metrics in Azure Portal
2. **Test scaling** - Generate load to see auto-scaling in action
3. **Explore features** - Try revision management and traffic splitting
4. **Prepare for Exercise 2** - We'll explore advanced deployment scenarios

**Key takeaways to remember**:
- Azure Container Apps builds containers without local Docker
- Automatic HTTPS and load balancing included
- Scale to zero saves costs
- Health checks enable proper monitoring
- Environment variables provide configuration flexibility

## 🧹 Cleanup

To avoid charges, clean up resources when done:
```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

---

**🎉 Congratulations!** You've successfully deployed your first ASP.NET Core application to Azure Container Apps without requiring Docker locally!
