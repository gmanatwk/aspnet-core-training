#!/bin/bash

# Azure Container Apps Deployment Script
set -e

# Configuration variables
RESOURCE_GROUP="rg-containerapp-demo"
LOCATION="eastus"
ENVIRONMENT="env-containerapp-demo"
CONTAINER_APP_NAME="containerappsdemo"
ACR_NAME="acrcontainerappsdemo$(date +%s)"

echo "🚀 Starting Azure Container Apps deployment..."

# Check if Azure CLI is logged in
if ! az account show &> /dev/null; then
    echo "❌ Please login to Azure CLI first: az login"
    exit 1
fi

# Install Container Apps extension
echo "📦 Installing Azure Container Apps extension..."
az extension add --name containerapp --upgrade

# Register required providers
echo "🔧 Registering Azure providers..."
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights

# Create resource group
echo "🏗️  Creating resource group..."
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION

# Create Container Apps environment
echo "🌍 Creating Container Apps environment..."
az containerapp env create \
    --name $ENVIRONMENT \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION

# Create Azure Container Registry
echo "📦 Creating Azure Container Registry..."
az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME \
    --sku Basic \
    --admin-enabled true

# Build and push image to ACR
echo "🔨 Building and pushing container image..."
az acr build \
    --registry $ACR_NAME \
    --image containerappsdemo:v1.0 \
    .

# Get ACR credentials
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value --output tsv)

# Deploy container app
echo "🚀 Deploying container app..."
az containerapp create \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --environment $ENVIRONMENT \
    --image $ACR_LOGIN_SERVER/containerappsdemo:v1.0 \
    --registry-server $ACR_LOGIN_SERVER \
    --registry-username $ACR_USERNAME \
    --registry-password $ACR_PASSWORD \
    --target-port 8080 \
    --ingress external \
    --cpu 0.25 \
    --memory 0.5Gi \
    --min-replicas 1 \
    --max-replicas 3 \
    --env-vars ASPNETCORE_ENVIRONMENT=Production

# Get the application URL
APP_URL=$(az containerapp show \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --query properties.configuration.ingress.fqdn \
    --output tsv)

echo "✅ Deployment completed successfully!"
echo "🌐 Application URL: https://$APP_URL"
echo "🏥 Health check: https://$APP_URL/health"
echo "📊 Swagger UI: https://$APP_URL/swagger"

# Save deployment info
cat > deployment-info.txt << EOF
Deployment Information
=====================
Resource Group: $RESOURCE_GROUP
Container App: $CONTAINER_APP_NAME
Container Registry: $ACR_NAME
Application URL: https://$APP_URL
Health Check: https://$APP_URL/health

Useful Commands:
- View logs: az containerapp logs show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --follow
- Update app: az containerapp update --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --image $ACR_LOGIN_SERVER/containerappsdemo:v2.0
- Scale app: az containerapp update --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --min-replicas 2 --max-replicas 5
EOF

echo "📄 Deployment information saved to deployment-info.txt"
