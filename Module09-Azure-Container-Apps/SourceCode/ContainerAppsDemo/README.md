# ProductApi - Azure Container Apps Demo

This is a sample ASP.NET Core Web API designed to demonstrate deployment to Azure Container Apps without requiring Docker Desktop.

## 🚀 Quick Start - No Docker Required!

### Prerequisites
- Azure subscription (free tier works)
- Azure CLI installed
- .NET 8 SDK

### Deploy to Azure Container Apps

1. **Login to Azure**:
   ```bash
   az login
   ```

2. **Run the deployment script**:
   ```powershell
   # Windows PowerShell
   .\deploy-to-azure.ps1

   # macOS/Linux
   pwsh deploy-to-azure.ps1
   ```

3. **That's it!** The script will:
   - Create all required Azure resources
   - Build your container image in Azure
   - Deploy to Azure Container Apps
   - Configure auto-scaling and monitoring

## 🏗️ Architecture

This application demonstrates:
- Cloud-native ASP.NET Core configuration
- Health checks for Azure monitoring
- Application Insights integration
- Auto-scaling based on HTTP traffic
- Secure container deployment without local Docker

## 📁 Project Structure

```
ProductApi/
├── Controllers/
│   ├── ProductsController.cs    # Main API endpoints
│   └── ValidationController.cs  # Input validation demo
├── Services/
│   ├── ProductService.cs       # Business logic
│   └── MetricsService.cs       # Custom metrics
├── Middleware/
│   └── InputValidationMiddleware.cs
├── Program.cs                  # App configuration
├── Dockerfile                  # Used by Azure ACR
└── appsettings.json           # Configuration
```

## 🔧 Local Development

To run locally (without containers):

```bash
cd ProductApi
dotnet run
```

Access the API at:
- Swagger UI: http://localhost:5000/swagger
- Health check: http://localhost:5000/health

## 🌩️ Azure Features Demonstrated

1. **Serverless Containers**: Scale to zero when not in use
2. **Managed Certificates**: Automatic HTTPS
3. **Built-in Load Balancing**: No configuration needed
4. **Health Monitoring**: Integrated health checks
5. **Application Insights**: Full telemetry out of the box

## 📊 Monitoring

After deployment, you can:

1. **View logs**:
   ```bash
   az containerapp logs show --name productapi-demo --resource-group rg-containerapp-module09 --follow
   ```

2. **Check metrics** in Azure Portal:
   - Navigate to your Container App
   - Click on "Metrics" to see requests, CPU, memory

3. **Application Insights**:
   - Full application telemetry
   - Custom metrics tracking
   - Performance monitoring

## 🔄 Updating the Application

1. Make your code changes

2. Deploy the update:
   ```bash
   # The script builds in Azure - no Docker needed!
   cd ProductApi
   az acr build --registry <your-acr> --image productapi:v2 .
   az containerapp update --name productapi-demo --resource-group rg-containerapp-module09 --image <your-acr>.azurecr.io/productapi:v2
   ```

## 💡 Key Benefits

- **No Docker Desktop Required**: Build and deploy entirely in the cloud
- **Cost Effective**: Pay only for what you use
- **Automatic Scaling**: Handle traffic spikes automatically
- **Zero Infrastructure Management**: Focus on code, not servers
- **Built-in Security**: Managed identities and Key Vault integration

## 🧹 Cleanup

To remove all resources:
```bash
az group delete --name rg-containerapp-module09 --yes --no-wait
```

## 📚 Learn More

- [Azure Container Apps Documentation](https://docs.microsoft.com/azure/container-apps/)
- [ASP.NET Core Best Practices](https://docs.microsoft.com/aspnet/core/)
- [Container Apps Pricing](https://azure.microsoft.com/pricing/details/container-apps/)