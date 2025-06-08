# Exercise 1: Azure Setup and Application Preparation

## 🎯 Objective
Set up Azure resources and prepare an ASP.NET Core application for deployment to Azure Container Apps without using Docker locally.

## ⏱️ Estimated Time: 30 minutes

## 📋 Prerequisites
- Azure subscription (free tier is sufficient)
- Azure CLI installed (version 2.50+)
- .NET 8 SDK installed
- Visual Studio or Visual Studio Code

## 🎓 Learning Goals
- Understand Azure Container Apps without Docker
- Set up Azure Container Registry
- Prepare applications for cloud deployment
- Configure health checks for Azure
- Use Azure CLI effectively

---

## 📚 Background Information

### Azure Container Apps Without Docker
Azure Container Apps allows you to deploy containerized applications without managing infrastructure or even having Docker installed locally. Here's how:

- **Azure Container Registry (ACR) Build**: Builds container images in the cloud
- **Serverless Platform**: No infrastructure management required
- **Automatic Scaling**: Scales from zero to thousands
- **Built-in Features**: Load balancing, HTTPS, and more

### Why No Docker?
- **Simplified Development**: Focus on code, not containers
- **No Licensing Issues**: Avoid Docker Desktop licensing
- **Cloud-First Approach**: Build where you deploy
- **Consistent Builds**: Azure handles the containerization

---

## 🛠️ Setup Instructions

### Step 1: Verify Prerequisites

```bash
# Check Azure CLI
az --version

# Check .NET SDK
dotnet --version

# Login to Azure
az login

# Set default subscription (if you have multiple)
az account set --subscription "YOUR_SUBSCRIPTION_NAME"
```

### Step 2: Create Azure Resources

```bash
# Set variables
$RESOURCE_GROUP="rg-containerapp-demo"
$LOCATION="eastus"
$ACR_NAME="acr$(Get-Random -Minimum 10000 -Maximum 99999)"
$ENVIRONMENT="containerapp-env"

# Create Resource Group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Azure Container Registry
az acr create `
  --resource-group $RESOURCE_GROUP `
  --name $ACR_NAME `
  --sku Basic `
  --admin-enabled true

# Create Container Apps Environment
az containerapp env create `
  --name $ENVIRONMENT `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION

Write-Host "Resources created successfully!" -ForegroundColor Green
Write-Host "ACR Name: $ACR_NAME" -ForegroundColor Cyan
```

---

## 📝 Tasks

### Task 1: Create a Cloud-Ready ASP.NET Core Application (10 minutes)

1. **Create a new Web API project**:
```bash
mkdir ContainerAppsDemo
cd ContainerAppsDemo
dotnet new webapi -n WeatherAPI
cd WeatherAPI
```

2. **Add health checks** - Update `Program.cs`:
```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add health checks
builder.Services.AddHealthChecks();

// Configure for Azure
builder.WebHost.ConfigureKestrel(serverOptions =>
{
    serverOptions.ListenAnyIP(builder.Configuration.GetValue("PORT", 80));
});

var app = builder.Build();

// Configure pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Health check endpoints for Azure
app.MapHealthChecks("/healthz");
app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = _ => true
});

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

3. **Update appsettings.json** for cloud configuration:
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ApplicationInsights": {
    "ConnectionString": ""
  }
}
```

### Task 2: Add a Simple Dockerfile (5 minutes)

Create a `Dockerfile` in the project root (Azure will use this as a guide):

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app .
EXPOSE 80
ENTRYPOINT ["dotnet", "WeatherAPI.dll"]
```

**Note**: You don't need Docker installed! Azure Container Registry will use this file to build your image in the cloud.

### Task 3: Build Container Image in Azure (10 minutes)

1. **Build the image using ACR** (no Docker required!):
```bash
# Make sure you're in the WeatherAPI directory
cd WeatherAPI

# Build in Azure Container Registry
az acr build `
  --registry $ACR_NAME `
  --image weatherapi:v1 `
  .

Write-Host "Image built successfully in Azure!" -ForegroundColor Green
```

2. **Verify the image was created**:
```bash
# List images in your registry
az acr repository list --name $ACR_NAME --output table

# Show image details
az acr repository show-tags --name $ACR_NAME --repository weatherapi --output table
```

### Task 4: Deploy to Azure Container Apps (5 minutes)

1. **Get ACR credentials**:
```bash
$ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
$ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
$ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv)
```

2. **Deploy the application**:
```bash
az containerapp create `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --environment $ENVIRONMENT `
  --image "$ACR_LOGIN_SERVER/weatherapi:v1" `
  --registry-server $ACR_LOGIN_SERVER `
  --registry-username $ACR_USERNAME `
  --registry-password $ACR_PASSWORD `
  --target-port 80 `
  --ingress external `
  --min-replicas 0 `
  --max-replicas 5 `
  --cpu 0.25 `
  --memory 0.5Gi

# Get the app URL
$APP_URL=$(az containerapp show --name weatherapi --resource-group $RESOURCE_GROUP --query properties.configuration.ingress.fqdn -o tsv)
Write-Host "Your app is deployed at: https://$APP_URL" -ForegroundColor Green
```

---

## ✅ Verification Steps

1. **Test the deployed application**:
```bash
# Test health endpoint
curl https://$APP_URL/healthz

# Test the API
curl https://$APP_URL/weatherforecast

# Open in browser
Start-Process "https://$APP_URL/swagger"
```

2. **Check application logs**:
```bash
az containerapp logs show `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --follow
```

3. **Monitor scaling**:
```bash
az containerapp revision list `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --output table
```

---

## 🎉 Success Criteria

You've successfully completed this exercise if:
- ✅ Azure resources are created (Resource Group, ACR, Container Apps Environment)
- ✅ Application image is built in Azure Container Registry (without Docker)
- ✅ Application is deployed and accessible via HTTPS
- ✅ Health checks are responding correctly
- ✅ You can view logs and monitor the application

---

## 🚀 Bonus Challenges

1. **Add Application Insights**:
   - Create an Application Insights resource
   - Add the NuGet package to your project
   - Configure the connection string

2. **Configure Auto-scaling**:
   ```bash
   az containerapp update `
     --name weatherapi `
     --resource-group $RESOURCE_GROUP `
     --scale-rule-name http-rule `
     --scale-rule-type http `
     --scale-rule-metadata concurrentRequests=10
   ```

3. **Add Environment Variables**:
   ```bash
   az containerapp update `
     --name weatherapi `
     --resource-group $RESOURCE_GROUP `
     --set-env-vars "ENVIRONMENT=Production" "VERSION=1.0"
   ```

---

## 📚 Key Takeaways

- **No Docker Required**: Azure Container Registry builds images in the cloud
- **Serverless Benefits**: Focus on code, not infrastructure
- **Built-in Features**: Automatic HTTPS, scaling, and load balancing
- **Cost-Effective**: Scale to zero when not in use
- **Cloud-First Development**: Build and deploy in the same environment

---

## 🧹 Cleanup

To avoid charges, clean up resources when done:
```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

---

## Next Steps
Proceed to [Exercise 2: Cloud Build and Deployment Strategies](Exercise02-Cloud-Build-Deploy.md)