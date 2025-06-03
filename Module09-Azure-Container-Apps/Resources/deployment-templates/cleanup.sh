#!/bin/bash

# Cleanup Azure Container Apps Resources
set -e

# Default values
RESOURCE_GROUP="rg-containerapp-demo"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -g, --resource-group    Resource group name to delete (default: rg-containerapp-demo)"
            echo "  -h, --help              Show this help message"
            echo ""
            echo "⚠️  WARNING: This will delete ALL resources in the specified resource group!"
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

echo "🗑️  Azure Container Apps Cleanup"
echo "Resource Group: $RESOURCE_GROUP"
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

# Check if resource group exists
if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    echo "ℹ️  Resource group '$RESOURCE_GROUP' does not exist or you don't have access to it."
    exit 0
fi

# List resources in the group
echo "📋 Resources to be deleted:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
az resource list --resource-group "$RESOURCE_GROUP" --output table
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Confirmation prompt
echo "⚠️  WARNING: This will permanently delete ALL resources in resource group '$RESOURCE_GROUP'!"
echo "This action cannot be undone."
echo ""
read -p "Are you sure you want to continue? (type 'yes' to confirm): " CONFIRMATION

if [ "$CONFIRMATION" != "yes" ]; then
    echo "❌ Cleanup cancelled."
    exit 0
fi

echo ""
echo "🗑️  Deleting resource group and all resources..."
echo "This may take several minutes..."
echo ""

# Delete the resource group
az group delete \
    --name "$RESOURCE_GROUP" \
    --yes \
    --no-wait

echo "✅ Deletion initiated successfully!"
echo ""
echo "📋 Cleanup Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗑️  Resource Group:    $RESOURCE_GROUP"
echo "⏱️  Status:            Deletion in progress (async)"
echo "🔍 Monitor:           Use Azure Portal or CLI to monitor deletion progress"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📚 Useful Commands:"
echo "# Check deletion status"
echo "az group show --name $RESOURCE_GROUP"
echo ""
echo "# List all resource groups"
echo "az group list --output table"
echo ""
echo "ℹ️  Note: The deletion runs asynchronously in the background."
echo "   It may take 10-15 minutes to complete depending on the resources."
echo ""
echo "🎉 Cleanup script completed!"
