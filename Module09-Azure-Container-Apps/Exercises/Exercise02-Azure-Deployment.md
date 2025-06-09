# Exercise 2: Advanced Azure Container Apps Deployment

## 🎯 Objective
Deploy and configure your ASP.NET Core application for production use in Azure Container Apps. This exercise covers advanced deployment scenarios, configuration management, and production best practices.

## ⏱️ Estimated Time: 45 minutes

## 📋 Prerequisites
- Completed Exercise 1 (Application Preparation)
- Azure subscription with resources from Exercise 1
- Azure CLI installed and authenticated
- Application code from Exercise 1

## 🎓 Learning Goals
- Create Azure Container Apps environment
- Deploy containers using Azure CLI
- Configure environment variables and secrets
- Set up scaling rules and resource limits
- Understand Azure Container Registry integration
- Monitor deployed applications

---

## 📚 Background Information

### Azure Container Apps Overview
Azure Container Apps is a serverless container platform that allows you to:
- Run containers without managing infrastructure
- Scale automatically based on demand
- Pay only for resources you use
- Integrate with Azure services easily

### Key Components
- **Environment**: Secure boundary around groups of container apps
- **Container App**: Your application running in containers
- **Revisions**: Immutable snapshots of your container app
- **Ingress**: Routing and load balancing configuration

---

## 🛠️ Setup Instructions

### Step 1: Azure CLI Authentication
Ensure you're logged into Azure:

```bash
# Login to Azure
az login

# Verify subscription
az account show

# Set subscription if needed
az account set --subscription "Your Subscription Name"
```

### Step 2: Install Container Apps Extension
```bash
# Install the container apps extension
az extension add --name containerapp --upgrade

# Register required providers
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights
```

---

## 📝 Tasks

### Task 1: Create Azure Resources (15 minutes)

#### 1.1 Create Resource Group
```bash
# Set variables for consistency
RESOURCE_GROUP="rg-containerapp-demo"
LOCATION="eastus"
ENVIRONMENT="env-containerapp-demo"
CONTAINER_APP_NAME="productapi"

# Create resource group
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION
```

#### 1.2 Create Container Apps Environment
```bash
# Create the environment
az containerapp env create \
    --name $ENVIRONMENT \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION
```

This creates:
- Log Analytics workspace for monitoring
- Container Apps environment for hosting your apps

#### 1.3 Create Azure Container Registry (Optional but Recommended)
```bash
ACR_NAME="acrdemo$(date +%s)"  # Unique name

# Create container registry
az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME \
    --sku Basic \
    --admin-enabled true

# Get login server
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query loginServer --output tsv)
```

### Task 2: Build and Deploy New Version (10 minutes)

#### 2.1 Build Image in Azure (No Docker Required)
```bash
# Use the existing ACR from Exercise 1
ACR_NAME=$(az acr list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv)
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)

# Build directly in ACR (no Docker needed!)
az acr build --registry $ACR_NAME --image productapi:v2.0 .

# List images to verify
az acr repository show-tags --name $ACR_NAME --repository productapi --output table
```

#### 2.2 Get ACR Credentials
```bash
# Get ACR credentials for Container Apps
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value --output tsv)
```

### Task 3: Deploy to Container Apps (15 minutes)

#### 3.1 Deploy New Version with Advanced Configuration
```bash
# Deploy with production-ready settings
az containerapp create \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --environment $ENVIRONMENT \
    --image $ACR_LOGIN_SERVER/productapi:v2.0 \
    --registry-server $ACR_LOGIN_SERVER \
    --registry-username $ACR_USERNAME \
    --registry-password $ACR_PASSWORD \
    --target-port 80 \
    --ingress external \
    --cpu 0.5 \
    --memory 1.0Gi \
    --min-replicas 2 \
    --max-replicas 10 \
    --scale-rule-name http-rule \
    --scale-rule-type http \
    --scale-rule-metadata concurrentRequests=20
```

#### 3.2 Get Application URL
```bash
# Get the URL of your deployed app
CONTAINER_APP_URL=$(az containerapp show \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --query properties.configuration.ingress.fqdn \
    --output tsv)

echo "Application URL: https://$CONTAINER_APP_URL"
```

#### 3.3 Test the Deployed Application
```bash
# Test the API
curl https://$CONTAINER_APP_URL/WeatherForecast

# Test health check
curl https://$CONTAINER_APP_URL/healthz

# View in browser
echo "Open this URL in your browser: https://$CONTAINER_APP_URL/swagger"
```

### Task 4: Configure Environment Variables and Secrets (5 minutes)

#### 4.1 Add Environment Variables
```bash
# Add some configuration
az containerapp update \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --set-env-vars \
        "ASPNETCORE_ENVIRONMENT=Production" \
        "APP_VERSION=1.0.0" \
        "WELCOME_MESSAGE=Hello from Azure Container Apps!"
```

#### 4.2 Add Secrets (for sensitive data)
```bash
# Add a secret
az containerapp secret set \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --secrets "api-key=your-secret-api-key-here"

# Use secret as environment variable
az containerapp update \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --set-env-vars "API_KEY=secretref:api-key"
```

#### 4.3 Test Configuration
Create a simple endpoint to verify environment variables (if you haven't already):

```bash
# You can test this if you added the /info endpoint in Exercise 1
curl https://$CONTAINER_APP_URL/info
```

### Task 5: Configure Scaling and Resource Management (5 minutes)

#### 5.1 Update Scaling Rules
```bash
# Configure HTTP scaling
az containerapp update \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --min-replicas 0 \
    --max-replicas 5 \
    --scale-rule-name "http-requests" \
    --scale-rule-type "http" \
    --scale-rule-metadata "concurrentRequests=10"
```

#### 5.2 Update Resource Allocation
```bash
# Increase resources if needed
az containerapp update \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --cpu 0.5 \
    --memory 1.0Gi
```

---

## ✅ Verification Checklist

Mark each item as complete:

- [ ] Created Azure resource group
- [ ] Created Container Apps environment
- [ ] Created Azure Container Registry
- [ ] Pushed container image to ACR
- [ ] Deployed container app with external ingress
- [ ] Verified application is accessible via HTTPS
- [ ] Configured environment variables
- [ ] Set up secrets management
- [ ] Configured scaling rules
- [ ] Tested all endpoints (/WeatherForecast, /healthz, /swagger)

---

## 🔍 Monitoring and Troubleshooting

### View Application Logs
```bash
# Stream logs from your container app
az containerapp logs show \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --follow

# View logs without following
az containerapp logs show \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --tail 50
```

### Check Application Status
```bash
# Get detailed app information
az containerapp show \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP

# Check revision status
az containerapp revision list \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --output table
```

### Monitor Resource Usage
```bash
# View scaling metrics (requires Azure CLI with monitoring extension)
az monitor metrics list \
    --resource "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.App/containerApps/$CONTAINER_APP_NAME" \
    --metric "Requests" \
    --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ)
```

---

## 🎯 Expected Outcomes

After completing this exercise, you should have:

1. **Production Deployment**: Application running with production configuration
2. **Advanced Scaling**: Auto-scaling based on multiple metrics
3. **Secure Configuration**: Environment variables and secrets properly managed
4. **Cloud Build Pipeline**: Images built in Azure without local Docker
5. **Monitoring Setup**: Comprehensive logging and metrics

### Performance Expectations
- **Cold start**: ~1-2 seconds with warm instances
- **Scaling**: 2-10 replicas based on demand
- **Availability**: 99.95% uptime with multiple replicas
- **SSL**: Automatic HTTPS with managed certificates
- **Build time**: ~2-3 minutes in ACR

---

## 🔧 Common Issues and Solutions

### Issue 1: Deployment Fails
```bash
# Check deployment status
az containerapp revision list \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP

# Common causes:
# - Image not found: Verify ACR image exists
# - Registry auth: Check username/password
# - Port issues: Ensure target-port matches container port
```

### Issue 2: Application Not Accessible
```bash
# Verify ingress configuration
az containerapp show \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "properties.configuration.ingress"

# Check if external ingress is enabled
# Verify target port matches your application port
```

### Issue 3: Environment Variables Not Working
```bash
# List current environment variables
az containerapp show \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "properties.template.containers[0].env"
```

### Issue 4: Scaling Not Working
```bash
# Check scaling rules
az containerapp show \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "properties.template.scale"
```

---

## 🏆 Bonus Challenges

### Challenge 1: Custom Domain
Configure a custom domain for your application:

```bash
# Add custom domain (requires domain ownership verification)
az containerapp hostname add \
    --hostname "your-domain.com" \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP
```

### Challenge 2: Traffic Splitting
Deploy a new version and split traffic:

```bash
# Update with new image version
az containerapp update \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --image $ACR_LOGIN_SERVER/productapi:v2.0

# Configure traffic splitting
az containerapp ingress traffic set \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --revision-weight latest=80 previous=20
```

### Challenge 3: Application Insights Integration
Add Application Insights for detailed monitoring:

```bash
# Create Application Insights
APP_INSIGHTS_NAME="ai-containerapp-demo"

az monitor app-insights component create \
    --app $APP_INSIGHTS_NAME \
    --location $LOCATION \
    --resource-group $RESOURCE_GROUP

# Get instrumentation key
INSTRUMENTATION_KEY=$(az monitor app-insights component show \
    --app $APP_INSIGHTS_NAME \
    --resource-group $RESOURCE_GROUP \
    --query instrumentationKey \
    --output tsv)

# Add to container app
az containerapp update \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --set-env-vars "APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=$INSTRUMENTATION_KEY"
```

---

## 💰 Cost Management

### Monitor Costs
```bash
# Check current usage
az containerapp show \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "properties.template.scale"

# Optimize for cost:
# - Set min-replicas to 0 for dev environments
# - Use smaller CPU/memory allocations
# - Consider consumption-only pricing
```

### Clean Up Resources
When you're done with the exercise:

```bash
# Delete the entire resource group (removes all resources)
az group delete --name $RESOURCE_GROUP --yes --no-wait

# Or delete specific resources
az containerapp delete --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP
az acr delete --name $ACR_NAME --resource-group $RESOURCE_GROUP
```

---

## 📖 Additional Learning Resources

### Azure Container Apps
- [Azure Container Apps Documentation](https://docs.microsoft.com/en-us/azure/container-apps/)
- [Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
- [Best Practices Guide](https://docs.microsoft.com/en-us/azure/container-apps/overview)

### Container Registry
- [ACR Documentation](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Security Best Practices](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-best-practices)

---

## 🚀 Next Steps

Once you've completed this exercise:

1. **Test your deployment thoroughly** - Ensure all endpoints work correctly
2. **Monitor for a few hours** - Observe scaling behavior
3. **Document your configuration** - Note the settings that work best
4. **Prepare for Exercise 3** - We'll set up CI/CD pipelines

**Key takeaways to remember**:
- Azure Container Apps provides serverless container hosting
- Container Registry integration enables private image storage
- Environment variables and secrets provide secure configuration
- Auto-scaling helps optimize costs and performance
- Built-in HTTPS and monitoring simplify operations

---

**🎉 Congratulations!** You've successfully deployed your containerized application to Azure Container Apps and configured it for production use. Your application is now running in the cloud with automatic scaling and monitoring!
