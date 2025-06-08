# Exercise 3: Deploy to Azure Container Apps

## Duration: 45 minutes

## Learning Objectives
- Build and push container images to Azure Container Registry
- Deploy services to Azure Container Apps
- Configure environment variables and secrets
- Set up service-to-service communication
- Enable monitoring with Application Insights

## Prerequisites
- Completed Exercises 1 and 2
- Azure CLI logged in
- Services built and tested locally

## Part 1: Prepare Azure Resources (10 minutes)

### Step 1: Load Configuration
```powershell
# Load variables from Exercise 1
. ./azure-config.ps1

# Verify variables
echo "Resource Group: $RESOURCE_GROUP"
echo "ACR Name: $ACR_NAME"
echo "Environment: $ENVIRONMENT"
echo "Location: $LOCATION"
```

### Step 2: Create Azure SQL Database
```powershell
# Create SQL Server
$SQL_SERVER="sql-microservices-$(Get-Random -Minimum 1000 -Maximum 9999)"
$SQL_ADMIN="sqladmin"
$SQL_PASSWORD="P@ssw0rd$(Get-Random -Minimum 1000 -Maximum 9999)!"

az sql server create `
  --name $SQL_SERVER `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION `
  --admin-user $SQL_ADMIN `
  --admin-password $SQL_PASSWORD

# Configure firewall to allow Azure services
az sql server firewall-rule create `
  --resource-group $RESOURCE_GROUP `
  --server $SQL_SERVER `
  --name AllowAzureServices `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 0.0.0.0

# Create databases
az sql db create `
  --resource-group $RESOURCE_GROUP `
  --server $SQL_SERVER `
  --name ProductDb `
  --edition Basic

az sql db create `
  --resource-group $RESOURCE_GROUP `
  --server $SQL_SERVER `
  --name OrderDb `
  --edition Basic

# Get connection strings
$PRODUCT_DB_CONNECTION="Server=tcp:${SQL_SERVER}.database.windows.net,1433;Database=ProductDb;User ID=${SQL_ADMIN};Password=${SQL_PASSWORD};Encrypt=True;TrustServerCertificate=False;"
$ORDER_DB_CONNECTION="Server=tcp:${SQL_SERVER}.database.windows.net,1433;Database=OrderDb;User ID=${SQL_ADMIN};Password=${SQL_PASSWORD};Encrypt=True;TrustServerCertificate=False;"
```

### Step 3: Create Application Insights
```powershell
# Create Application Insights
$APP_INSIGHTS="appi-microservices"

az monitor app-insights component create `
  --app $APP_INSIGHTS `
  --location $LOCATION `
  --resource-group $RESOURCE_GROUP `
  --application-type web

# Get instrumentation key
$INSTRUMENTATION_KEY=$(az monitor app-insights component show `
  --app $APP_INSIGHTS `
  --resource-group $RESOURCE_GROUP `
  --query instrumentationKey -o tsv)

$APP_INSIGHTS_CONNECTION="InstrumentationKey=$INSTRUMENTATION_KEY"
```

## Part 2: Build and Push Container Images (15 minutes)

### Step 1: Login to Azure Container Registry
```powershell
# Get ACR credentials
$ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
$ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv)

# Login to ACR
az acr login --name $ACR_NAME
```

### Step 2: Build and Push Product Service
```powershell
cd SourceCode/AzureECommerce/ProductService

# Build the image
docker build -t ${ACR_NAME}.azurecr.io/product-service:v1 .

# Push to ACR
docker push ${ACR_NAME}.azurecr.io/product-service:v1

# Alternative: Use ACR build (builds in cloud)
az acr build `
  --registry $ACR_NAME `
  --image product-service:v1 `
  .
```

### Step 3: Build and Push Order Service
```powershell
cd ../OrderService

# Build and push
docker build -t ${ACR_NAME}.azurecr.io/order-service:v1 .
docker push ${ACR_NAME}.azurecr.io/order-service:v1

# Alternative: Use ACR build
az acr build `
  --registry $ACR_NAME `
  --image order-service:v1 `
  .
```

## Part 3: Deploy Product Service (10 minutes)

### Step 1: Create Product Service Container App
```powershell
az containerapp create `
  --name product-service `
  --resource-group $RESOURCE_GROUP `
  --environment $ENVIRONMENT `
  --image "${ACR_NAME}.azurecr.io/product-service:v1" `
  --registry-server "${ACR_NAME}.azurecr.io" `
  --registry-username $ACR_USERNAME `
  --registry-password $ACR_PASSWORD `
  --target-port 80 `
  --ingress 'external' `
  --min-replicas 1 `
  --max-replicas 3 `
  --cpu 0.5 `
  --memory 1.0Gi `
  --env-vars `
    "ConnectionStrings__DefaultConnection=$PRODUCT_DB_CONNECTION" `
    "ApplicationInsights__ConnectionString=$APP_INSIGHTS_CONNECTION" `
    "ASPNETCORE_ENVIRONMENT=Production"
```

### Step 2: Get Product Service URL
```powershell
$PRODUCT_SERVICE_URL=$(az containerapp show `
  --name product-service `
  --resource-group $RESOURCE_GROUP `
  --query properties.configuration.ingress.fqdn -o tsv)

echo "Product Service URL: https://$PRODUCT_SERVICE_URL"

# Test the service
curl "https://$PRODUCT_SERVICE_URL/health"
```

## Part 4: Deploy Order Service (10 minutes)

### Step 1: Create Order Service Container App
```powershell
az containerapp create `
  --name order-service `
  --resource-group $RESOURCE_GROUP `
  --environment $ENVIRONMENT `
  --image "${ACR_NAME}.azurecr.io/order-service:v1" `
  --registry-server "${ACR_NAME}.azurecr.io" `
  --registry-username $ACR_USERNAME `
  --registry-password $ACR_PASSWORD `
  --target-port 80 `
  --ingress 'external' `
  --min-replicas 1 `
  --max-replicas 3 `
  --cpu 0.5 `
  --memory 1.0Gi `
  --env-vars `
    "ConnectionStrings__DefaultConnection=$ORDER_DB_CONNECTION" `
    "ApplicationInsights__ConnectionString=$APP_INSIGHTS_CONNECTION" `
    "Services__ProductService=https://$PRODUCT_SERVICE_URL" `
    "ASPNETCORE_ENVIRONMENT=Production"
```

### Step 2: Get Order Service URL
```powershell
$ORDER_SERVICE_URL=$(az containerapp show `
  --name order-service `
  --resource-group $RESOURCE_GROUP `
  --query properties.configuration.ingress.fqdn -o tsv)

echo "Order Service URL: https://$ORDER_SERVICE_URL"
```

## Part 5: Configure and Test (10 minutes)

### Step 1: Enable Container App Logging
```powershell
# Enable system logs
az containerapp logs show `
  --name product-service `
  --resource-group $RESOURCE_GROUP `
  --type system

# Enable console logs
az containerapp logs show `
  --name product-service `
  --resource-group $RESOURCE_GROUP `
  --type console `
  --follow
```

### Step 2: Test the Deployment

1. **Test Product Service**:
```powershell
# Get all products
Invoke-RestMethod -Uri "https://$PRODUCT_SERVICE_URL/api/products" | ConvertTo-Json

# Create a product
$newProduct = @{
    name = "Azure T-Shirt"
    description = "Cloud Native T-Shirt"
    price = 25.99
    stockQuantity = 100
    category = "Apparel"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://$PRODUCT_SERVICE_URL/api/products" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $newProduct
```

2. **Test Order Service**:
```powershell
# Create an order
$newOrder = @{
    customerEmail = "test@example.com"
    items = @(
        @{
            productId = 1
            quantity = 2
        }
    )
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://$ORDER_SERVICE_URL/api/orders" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $newOrder
```

### Step 3: View Application Insights
```powershell
# Open Application Insights in browser
Start-Process "https://portal.azure.com/#resource/subscriptions/$((az account show --query id -o tsv))/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/components/$APP_INSIGHTS/overview"
```

## Part 6: Configure Auto-scaling (Optional)

### Configure CPU-based Scaling
```powershell
# Update Product Service scaling rules
az containerapp update `
  --name product-service `
  --resource-group $RESOURCE_GROUP `
  --scale-rule-name cpu-scaling `
  --scale-rule-type cpu `
  --scale-rule-metadata type=utilization value=70 `
  --min-replicas 1 `
  --max-replicas 5
```

### Configure HTTP-based Scaling
```powershell
# Update Order Service with HTTP scaling
az containerapp update `
  --name order-service `
  --resource-group $RESOURCE_GROUP `
  --scale-rule-name http-scaling `
  --scale-rule-type http `
  --scale-rule-metadata concurrentRequests=50 `
  --min-replicas 1 `
  --max-replicas 10
```

## Deployment Summary

You've successfully deployed:
- ✅ Product Service to Azure Container Apps
- ✅ Order Service with service-to-service communication
- ✅ Azure SQL Database for both services
- ✅ Application Insights for monitoring
- ✅ Auto-scaling configuration

### Access Your Services:
- **Product Service**: `https://$PRODUCT_SERVICE_URL`
- **Order Service**: `https://$ORDER_SERVICE_URL`
- **Azure Portal**: View all resources in your resource group

## Troubleshooting

### Common Issues:

1. **Container fails to start**:
```powershell
# Check logs
az containerapp logs show --name product-service --resource-group $RESOURCE_GROUP
```

2. **Database connection issues**:
```powershell
# Verify connection string
az containerapp show --name product-service --resource-group $RESOURCE_GROUP --query properties.template.containers[0].env
```

3. **Service communication fails**:
```powershell
# Check environment variables
az containerapp show --name order-service --resource-group $RESOURCE_GROUP --query properties.template.containers[0].env
```

## Clean Up Resources

To avoid ongoing charges:
```powershell
# Delete all resources (WARNING: This is permanent!)
# az group delete --name $RESOURCE_GROUP --yes --no-wait
```

## Next Steps
In Exercise 4, we'll add Azure Service Bus for asynchronous messaging!