#!/bin/bash

# Deploy Azure Container Apps Infrastructure
set -e

# Default values
RESOURCE_GROUP="rg-containerapp-demo"
LOCATION="eastus"
CONTAINER_APP_NAME="productapi"
CONTAINER_IMAGE=""
DEPLOYMENT_NAME="containerapp-deployment-$(date +%s)"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -n|--name)
            CONTAINER_APP_NAME="$2"
            shift 2
            ;;
        -i|--image)
            CONTAINER_IMAGE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -g, --resource-group    Resource group name (default: rg-containerapp-demo)"
            echo "  -l, --location          Azure location (default: eastus)"
            echo "  -n, --name              Container app name (default: productapi)"
            echo "  -i, --image             Container image (required)"
            echo "  -h, --help              Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

# Validate required parameters
if [ -z "$CONTAINER_IMAGE" ]; then
    echo "Error: Container image is required. Use -i or --image to specify."
    echo "Example: $0 -i myregistry.azurecr.io/productapi:latest"
    exit 1
fi

echo "🚀 Deploying Azure Container Apps Infrastructure"
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "Container App: $CONTAINER_APP_NAME"
echo "Container Image: $CONTAINER_IMAGE"
echo "Deployment Name: $DEPLOYMENT_NAME"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo "❌ Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Check if Bicep is available
if ! az bicep version &> /dev/null; then
    echo "📦 Installing Bicep..."
    az bicep install
fi

echo "✅ Prerequisites check completed"
echo ""

# Create resource group if it doesn't exist
echo "📂 Creating resource group..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output table

echo "✅ Resource group created/verified"
echo ""

# Create parameters file with current values
TEMP_PARAMS_FILE="main.parameters.temp.json"
cat > "$TEMP_PARAMS_FILE" << EOF
{
    "\$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "containerAppName": {
            "value": "$CONTAINER_APP_NAME"
        },
        "containerImage": {
            "value": "$CONTAINER_IMAGE"
        },
        "location": {
            "value": "$LOCATION"
        }
    }
}
EOF

echo "📋 Created temporary parameters file"
echo ""

# Deploy Bicep template
echo "🚀 Deploying Bicep template..."
az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file main.bicep \
    --parameters @"$TEMP_PARAMS_FILE" \
    --name "$DEPLOYMENT_NAME" \
    --output table

# Get deployment outputs
echo ""
echo "📋 Getting deployment outputs..."
CONTAINER_APP_URL=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.containerAppUrl.value" \
    --output tsv)

APP_INSIGHTS_ID=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.applicationInsightsId.value" \
    --output tsv)

LOG_ANALYTICS_ID=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.logAnalyticsWorkspaceId.value" \
    --output tsv)

# Clean up temporary files
rm -f "$TEMP_PARAMS_FILE"

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Deployment Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Application URL:        $CONTAINER_APP_URL"
echo "📊 Application Insights:   $APP_INSIGHTS_ID"
echo "📝 Log Analytics:          $LOG_ANALYTICS_ID"
echo "🏷️  Resource Group:         $RESOURCE_GROUP"
echo "📍 Location:               $LOCATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔍 Next Steps:"
echo "1. Visit your application: $CONTAINER_APP_URL"
echo "2. Check health endpoint: $CONTAINER_APP_URL/healthz"
echo "3. View API documentation: $CONTAINER_APP_URL/swagger"
echo "4. Monitor logs: az containerapp logs show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --follow"
echo "5. View metrics in Azure Portal"
echo ""
echo "📚 Useful Commands:"
echo "# View application status"
echo "az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP"
echo ""
echo "# Stream logs"
echo "az containerapp logs show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --follow"
echo ""
echo "# Scale the application"
echo "az containerapp update --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --min-replicas 2 --max-replicas 10"
echo ""

# Test the deployment
echo "🧪 Testing deployment..."
sleep 10  # Wait for the app to be ready

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$CONTAINER_APP_URL/health" || echo "000")

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Health check passed!"
else
    echo "⚠️  Health check failed (HTTP $HTTP_STATUS). The application might still be starting up."
    echo "   You can check the logs with: az containerapp logs show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP"
fi

echo ""
echo "🚀 Deployment script completed!"
