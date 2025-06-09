#!/usr/bin/env pwsh

# Azure Container Apps Deployment Script - No Docker Required!
# This script deploys the ProductApi to Azure Container Apps using cloud builds

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "rg-containerapp-module09",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$false)]
    [string]$AppName = "productapi-demo"
)

Write-Host "🚀 Deploying ProductApi to Azure Container Apps" -ForegroundColor Cyan
Write-Host "No Docker installation required!" -ForegroundColor Green
Write-Host ""

# Check Azure CLI
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI not found. Please install: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
}

# Check login status
Write-Host "Checking Azure login status..." -ForegroundColor Yellow
$loginStatus = az account show --query "user.name" -o tsv 2>$null
if (-not $loginStatus) {
    Write-Host "Please login to Azure..." -ForegroundColor Red
    az login
}

Write-Host "Logged in as: $loginStatus" -ForegroundColor Green
Write-Host ""

# Install Container Apps extension
Write-Host "Installing Azure Container Apps extension..." -ForegroundColor Yellow
az extension add --name containerapp --upgrade -y

# Create variables
$ACR_NAME = "acr$(Get-Random -Minimum 10000 -Maximum 99999)"
$ENVIRONMENT = "$AppName-env"

# Create resource group
Write-Host "Creating resource group..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location

# Create Azure Container Registry
Write-Host "Creating Azure Container Registry..." -ForegroundColor Yellow
az acr create `
    --resource-group $ResourceGroupName `
    --name $ACR_NAME `
    --sku Basic `
    --admin-enabled true

# Get ACR details
$ACR_LOGIN_SERVER = $(az acr show --name $ACR_NAME --query loginServer -o tsv)
Write-Host "ACR Login Server: $ACR_LOGIN_SERVER" -ForegroundColor Green

# Build image in Azure (no Docker needed!)
Write-Host "Building container image in Azure Container Registry..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Yellow

# Navigate to ProductApi directory
Push-Location ProductApi
try {
    az acr build `
        --registry $ACR_NAME `
        --image productapi:latest `
        --image productapi:v1.0 `
        .
    
    Write-Host "✅ Image built successfully in Azure!" -ForegroundColor Green
} finally {
    Pop-Location
}

# Create Container Apps environment
Write-Host "Creating Container Apps environment..." -ForegroundColor Yellow
az containerapp env create `
    --name $ENVIRONMENT `
    --resource-group $ResourceGroupName `
    --location $Location

# Get ACR credentials
Write-Host "Getting ACR credentials..." -ForegroundColor Yellow
$ACR_USERNAME = $(az acr credential show --name $ACR_NAME --query username -o tsv)
$ACR_PASSWORD = $(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv)

# Create Application Insights
Write-Host "Creating Application Insights..." -ForegroundColor Yellow
$APP_INSIGHTS = "$AppName-insights"
az monitor app-insights component create `
    --app $APP_INSIGHTS `
    --location $Location `
    --resource-group $ResourceGroupName

# Get Application Insights connection string
$AI_CONNECTION_STRING = $(az monitor app-insights component show `
    --app $APP_INSIGHTS `
    --resource-group $ResourceGroupName `
    --query connectionString -o tsv)

# Deploy Container App
Write-Host "Deploying Container App..." -ForegroundColor Yellow
az containerapp create `
    --name $AppName `
    --resource-group $ResourceGroupName `
    --environment $ENVIRONMENT `
    --image "$ACR_LOGIN_SERVER/productapi:latest" `
    --registry-server $ACR_LOGIN_SERVER `
    --registry-username $ACR_USERNAME `
    --registry-password $ACR_PASSWORD `
    --target-port 80 `
    --ingress external `
    --cpu 0.5 `
    --memory 1.0Gi `
    --min-replicas 1 `
    --max-replicas 5 `
    --scale-rule-name http-rule `
    --scale-rule-type http `
    --scale-rule-metadata concurrentRequests=20 `
    --set-env-vars `
        "ASPNETCORE_ENVIRONMENT=Production" `
        "ApplicationInsights__ConnectionString=$AI_CONNECTION_STRING"

# Get app URL
$APP_URL = $(az containerapp show `
    --name $AppName `
    --resource-group $ResourceGroupName `
    --query properties.configuration.ingress.fqdn -o tsv)

Write-Host ""
Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Deployment Information:" -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "Container Registry: $ACR_LOGIN_SERVER" -ForegroundColor White
Write-Host "Container App: $AppName" -ForegroundColor White
Write-Host "Application URL: https://$APP_URL" -ForegroundColor White
Write-Host "Swagger UI: https://$APP_URL/swagger" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Useful commands:" -ForegroundColor Yellow
Write-Host "View logs:" -ForegroundColor White
Write-Host "  az containerapp logs show --name $AppName --resource-group $ResourceGroupName --follow" -ForegroundColor Gray
Write-Host ""
Write-Host "Scale app:" -ForegroundColor White
Write-Host "  az containerapp update --name $AppName --resource-group $ResourceGroupName --min-replicas 2 --max-replicas 10" -ForegroundColor Gray
Write-Host ""
Write-Host "Update app:" -ForegroundColor White
Write-Host "  az acr build --registry $ACR_NAME --image productapi:v2 ProductApi" -ForegroundColor Gray
Write-Host "  az containerapp update --name $AppName --resource-group $ResourceGroupName --image $ACR_LOGIN_SERVER/productapi:v2" -ForegroundColor Gray
Write-Host ""
Write-Host "Delete resources:" -ForegroundColor White
Write-Host "  az group delete --name $ResourceGroupName --yes --no-wait" -ForegroundColor Gray

# Save deployment info
$deploymentInfo = @"
# Azure Container Apps Deployment Information
Generated: $(Get-Date)

## Resources Created
- Resource Group: $ResourceGroupName
- Container Registry: $ACR_LOGIN_SERVER
- Container App: $AppName
- Environment: $ENVIRONMENT
- Application Insights: $APP_INSIGHTS

## URLs
- Application: https://$APP_URL
- Swagger UI: https://$APP_URL/swagger
- Health Check: https://$APP_URL/health

## Quick Commands
# View logs
az containerapp logs show --name $AppName --resource-group $ResourceGroupName --follow

# Update the application
Push-Location ProductApi
az acr build --registry $ACR_NAME --image productapi:v2 .
Pop-Location
az containerapp update --name $AppName --resource-group $ResourceGroupName --image $ACR_LOGIN_SERVER/productapi:v2

# Clean up resources
az group delete --name $ResourceGroupName --yes --no-wait
"@

$deploymentInfo | Out-File -FilePath "deployment-info.txt" -Encoding UTF8
Write-Host ""
Write-Host "📄 Deployment information saved to deployment-info.txt" -ForegroundColor Green

# Open browser
Write-Host ""
$openBrowser = Read-Host "Do you want to open the application in your browser? (Y/n)"
if ($openBrowser -ne 'n') {
    Start-Process "https://$APP_URL/swagger"
}