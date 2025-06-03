# Deploy Azure Container Apps Infrastructure

This directory contains Bicep templates for deploying Azure Container Apps infrastructure.

## Files

- `main.bicep` - Main Bicep template
- `main.parameters.json` - Parameters file
- `deploy.sh` - Deployment script
- `cleanup.sh` - Cleanup script

## Deployment

### Prerequisites

1. Azure CLI installed and authenticated
2. Bicep CLI installed
3. Valid Azure subscription

### Quick Deployment

```bash
# Make deployment script executable
chmod +x deploy.sh

# Deploy with default parameters
./deploy.sh

# Deploy with custom parameters
./deploy.sh -g "my-resource-group" -n "my-container-app" -i "myregistry.azurecr.io/myapp:latest"
```

### Manual Deployment

```bash
# Set variables
RESOURCE_GROUP="rg-containerapp-demo"
LOCATION="eastus"
DEPLOYMENT_NAME="containerapp-deployment-$(date +%s)"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Deploy Bicep template
az deployment group create \
    --resource-group $RESOURCE_GROUP \
    --template-file main.bicep \
    --parameters @main.parameters.json \
    --name $DEPLOYMENT_NAME
```

### Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| containerAppName | Name of the container app | productapi |
| location | Azure region | Resource group location |
| containerImage | Container image to deploy | Required |
| environmentName | Container Apps environment name | env-containerapp |
| acrLoginServer | ACR login server | Required |
| acrUsername | ACR username | Required |
| acrPassword | ACR password | Required |
| enableApplicationInsights | Enable Application Insights | true |
| minReplicas | Minimum number of replicas | 1 |
| maxReplicas | Maximum number of replicas | 5 |
| cpu | CPU allocation | 0.25 |
| memory | Memory allocation | 0.5Gi |

### Outputs

- `containerAppFQDN` - Fully qualified domain name
- `containerAppUrl` - HTTPS URL of the application
- `logAnalyticsWorkspaceId` - Log Analytics workspace ID
- `applicationInsightsId` - Application Insights resource ID
- `containerAppId` - Container App resource ID

## Cleanup

```bash
# Make cleanup script executable
chmod +x cleanup.sh

# Delete all resources
./cleanup.sh
```

Or manually:

```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

## Customization

### Adding Environment Variables

```bicep
env: [
  {
    name: 'CUSTOM_ENV_VAR'
    value: 'custom-value'
  }
  {
    name: 'SECRET_ENV_VAR'
    secretRef: 'my-secret'
  }
]
```

### Adding Secrets

```bicep
secrets: [
  {
    name: 'my-secret'
    value: 'secret-value'
  }
]
```

### Custom Scaling Rules

```bicep
rules: [
  {
    name: 'memory-rule'
    custom: {
      type: 'memory'
      metadata: {
        type: 'Utilization'
        value: '80'
      }
    }
  }
]
```

### Health Probes

```bicep
probes: [
  {
    type: 'Liveness'
    httpGet: {
      path: '/health'
      port: 8080
    }
    initialDelaySeconds: 30
    periodSeconds: 30
  }
]
```

## Monitoring

The template includes:

- Log Analytics workspace for centralized logging
- Application Insights for application monitoring
- Metric alerts for error rates and response times
- Action group for alert notifications

### Viewing Logs

```bash
# Stream container app logs
az containerapp logs show --name productapi --resource-group $RESOURCE_GROUP --follow

# Query Log Analytics
az monitor log-analytics query \
    --workspace $LOG_ANALYTICS_WORKSPACE_ID \
    --analytics-query "ContainerAppConsoleLogs_CL | take 100"
```

## Troubleshooting

### Common Issues

1. **ACR Authentication Failed**
   - Verify ACR credentials in parameters
   - Ensure ACR admin user is enabled

2. **Container Not Starting**
   - Check container logs
   - Verify health check endpoints
   - Check environment variables

3. **Application Not Accessible**
   - Verify ingress configuration
   - Check target port matches container port
   - Ensure external ingress is enabled

### Diagnostic Commands

```bash
# Check container app status
az containerapp show --name productapi --resource-group $RESOURCE_GROUP

# List revisions
az containerapp revision list --name productapi --resource-group $RESOURCE_GROUP

# View metrics
az monitor metrics list \
    --resource "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.App/containerApps/productapi" \
    --metric "Requests"
```
