# Deploy Microservices to Azure Container Apps
# This script builds and deploys both services to Azure

param(
    [switch]$SkipBuild = $false,
    [switch]$ProductOnly = $false,
    [switch]$OrderOnly = $false
)

Write-Host "🚀 Deploying Microservices to Azure Container Apps" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Check if configuration exists
if (!(Test-Path "../../azure-config.ps1")) {
    Write-Host "❌ Configuration file not found. Please run setup-azure-resources.ps1 first." -ForegroundColor Red
    exit 1
}

# Load configuration
Write-Host "📝 Loading Azure configuration..." -ForegroundColor Yellow
. ../../azure-config.ps1

# Login to ACR
Write-Host "🔐 Logging into Azure Container Registry..." -ForegroundColor Yellow
az acr login --name $ACR_NAME

# Get ACR credentials
$ACR_USERNAME = az acr credential show --name $ACR_NAME --query username -o tsv
$ACR_PASSWORD = az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv

# Function to deploy a service
function Deploy-Service {
    param(
        [string]$ServiceName,
        [string]$ServicePath,
        [string]$ImageTag,
        [hashtable]$EnvVars
    )

    Write-Host ""
    Write-Host "📦 Deploying $ServiceName..." -ForegroundColor Cyan
    
    if (!$SkipBuild) {
        Write-Host "  🔨 Building Docker image..." -ForegroundColor Yellow
        Push-Location $ServicePath
        
        # Build using ACR (builds in cloud)
        az acr build `
            --registry $ACR_NAME `
            --image "${ServiceName}:${ImageTag}" `
            . `
            --platform linux/amd64
        
        Pop-Location
    }

    Write-Host "  🚀 Deploying to Container Apps..." -ForegroundColor Yellow
    
    # Check if app exists
    $appExists = az containerapp show --name $ServiceName --resource-group $RESOURCE_GROUP 2>$null
    
    # Build environment variables string
    $envVarsArray = @()
    foreach ($key in $EnvVars.Keys) {
        $envVarsArray += "$key=$($EnvVars[$key])"
    }
    
    if ($appExists) {
        # Update existing app
        Write-Host "  📝 Updating existing Container App..." -ForegroundColor Yellow
        az containerapp update `
            --name $ServiceName `
            --resource-group $RESOURCE_GROUP `
            --image "${ACR_LOGIN_SERVER}/${ServiceName}:${ImageTag}" `
            --set-env-vars $envVarsArray
    } else {
        # Create new app
        Write-Host "  ✨ Creating new Container App..." -ForegroundColor Yellow
        az containerapp create `
            --name $ServiceName `
            --resource-group $RESOURCE_GROUP `
            --environment $ENVIRONMENT `
            --image "${ACR_LOGIN_SERVER}/${ServiceName}:${ImageTag}" `
            --registry-server $ACR_LOGIN_SERVER `
            --registry-username $ACR_USERNAME `
            --registry-password $ACR_PASSWORD `
            --target-port 80 `
            --ingress 'external' `
            --min-replicas 1 `
            --max-replicas 3 `
            --cpu 0.5 `
            --memory 1.0Gi `
            --env-vars $envVarsArray
    }
    
    # Get URL
    $url = az containerapp show `
        --name $ServiceName `
        --resource-group $RESOURCE_GROUP `
        --query properties.configuration.ingress.fqdn -o tsv
    
    Write-Host "  ✅ $ServiceName deployed successfully!" -ForegroundColor Green
    Write-Host "  🌐 URL: https://$url" -ForegroundColor Cyan
    
    return $url
}

# Deploy Product Service
if (!$OrderOnly) {
    $productEnvVars = @{
        "ConnectionStrings__DefaultConnection" = $PRODUCT_DB_CONNECTION
        "ApplicationInsights__ConnectionString" = $APP_INSIGHTS_CONNECTION
        "ASPNETCORE_ENVIRONMENT" = "Production"
    }
    
    $PRODUCT_SERVICE_URL = Deploy-Service `
        -ServiceName "product-service" `
        -ServicePath "ProductService" `
        -ImageTag "v1" `
        -EnvVars $productEnvVars
}

# Deploy Order Service
if (!$ProductOnly) {
    # Get Product Service URL if not just deployed
    if ($ProductOnly -or !$PRODUCT_SERVICE_URL) {
        $PRODUCT_SERVICE_URL = az containerapp show `
            --name product-service `
            --resource-group $RESOURCE_GROUP `
            --query properties.configuration.ingress.fqdn -o tsv
    }
    
    $orderEnvVars = @{
        "ConnectionStrings__DefaultConnection" = $ORDER_DB_CONNECTION
        "ApplicationInsights__ConnectionString" = $APP_INSIGHTS_CONNECTION
        "Services__ProductService" = "https://$PRODUCT_SERVICE_URL"
        "ASPNETCORE_ENVIRONMENT" = "Production"
    }
    
    $ORDER_SERVICE_URL = Deploy-Service `
        -ServiceName "order-service" `
        -ServicePath "OrderService" `
        -ImageTag "v1" `
        -EnvVars $orderEnvVars
}

# Summary
Write-Host ""
Write-Host "✅ Deployment Complete!" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green

if (!$OrderOnly) {
    Write-Host "Product Service: https://$PRODUCT_SERVICE_URL" -ForegroundColor Cyan
}
if (!$ProductOnly) {
    $ORDER_SERVICE_URL = az containerapp show `
        --name order-service `
        --resource-group $RESOURCE_GROUP `
        --query properties.configuration.ingress.fqdn -o tsv
    Write-Host "Order Service: https://$ORDER_SERVICE_URL" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "📊 View in Azure Portal:" -ForegroundColor Yellow
Write-Host "https://portal.azure.com/#resource/subscriptions/$($subscription.id)/resourceGroups/$RESOURCE_GROUP/overview" -ForegroundColor White

Write-Host ""
Write-Host "📝 Test your services:" -ForegroundColor Yellow
Write-Host "  1. Open the Swagger UI at the root URLs above" -ForegroundColor White
Write-Host "  2. Use the provided test commands in Exercise 3" -ForegroundColor White
Write-Host "  3. Check Application Insights for monitoring data" -ForegroundColor White

Write-Host ""
Write-Host "🔍 View logs:" -ForegroundColor Yellow
Write-Host "  az containerapp logs show --name product-service --resource-group $RESOURCE_GROUP --follow" -ForegroundColor White
Write-Host "  az containerapp logs show --name order-service --resource-group $RESOURCE_GROUP --follow" -ForegroundColor White