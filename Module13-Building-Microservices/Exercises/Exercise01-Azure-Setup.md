# Exercise 1: Azure Setup and Microservices Overview

## Duration: 30 minutes

## Learning Objectives
- Set up Azure resources for microservices
- Understand Azure Container Apps
- Create Azure Container Registry
- Plan your microservices architecture

## Prerequisites
- Azure subscription (free tier works)
- Azure CLI installed
- Basic understanding of cloud concepts

## Part 1: Azure Login and Setup (10 minutes)

### Step 1: Install and Configure Azure CLI

**Windows (PowerShell as Administrator):**
```powershell
# Download and install
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'

# Restart PowerShell and verify
az --version
```

**macOS:**
```bash
brew update && brew install azure-cli
```

**Linux (Ubuntu/Debian):**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### Step 2: Login to Azure
```bash
# Login to Azure
az login

# List subscriptions
az account list --output table

# Set default subscription
az account set --subscription "YOUR_SUBSCRIPTION_NAME_OR_ID"

# Verify current subscription
az account show --output table
```

### Step 3: Create Resource Group
```bash
# Set variables (change these as needed)
$RESOURCE_GROUP="rg-microservices-demo"
$LOCATION="eastus"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Verify creation
az group show --name $RESOURCE_GROUP --output table
```

## Part 2: Understanding Azure Container Apps (10 minutes)

### What are Azure Container Apps?
Azure Container Apps is a serverless container platform that allows you to:
- Run microservices without managing infrastructure
- Auto-scale based on HTTP traffic, events, or CPU/memory
- Pay only for what you use (scale to zero)
- Built-in service discovery and load balancing

### Container Apps vs Other Options

| Feature | Container Apps | AKS | App Service |
|---------|---------------|-----|-------------|
| **Complexity** | Low | High | Low |
| **Control** | Medium | Full | Limited |
| **Scaling** | Automatic | Manual/Auto | Automatic |
| **Cost Model** | Per usage | Per node | Per plan |
| **Best For** | Microservices | Complex systems | Web apps |

### Key Components
1. **Environment**: Shared boundary for containers (networking, logging)
2. **Container App**: Your microservice
3. **Revision**: Version of your app
4. **Ingress**: How traffic reaches your app

## Part 3: Create Azure Container Registry (10 minutes)

### Step 1: Create Container Registry
```bash
# Set registry name (must be globally unique)
$ACR_NAME="acrmicroservices$(Get-Random -Minimum 1000 -Maximum 9999)"

# Create Azure Container Registry
az acr create `
  --resource-group $RESOURCE_GROUP `
  --name $ACR_NAME `
  --sku Basic `
  --admin-enabled true

# Get registry credentials
az acr credential show --name $ACR_NAME --output table
```

### Step 2: Create Container Apps Environment
```bash
# Set environment name
$ENVIRONMENT="microservices-env"

# Create Container Apps environment
az containerapp env create `
  --name $ENVIRONMENT `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION

# Verify environment
az containerapp env show `
  --name $ENVIRONMENT `
  --resource-group $RESOURCE_GROUP `
  --output table
```

## Part 4: Plan Your Microservices Architecture

### Our Azure Microservices Architecture
```
┌─────────────────┐
│  Azure Front    │
│     Door        │
└────────┬────────┘
         │
┌────────▼────────┐
│ Container Apps  │
│   Environment   │
├─────────────────┤
│ ┌─────────────┐ │
│ │Product      │ │
│ │Service      │ │
│ └──────┬──────┘ │
│        │        │
│ ┌──────▼──────┐ │
│ │Order        │ │
│ │Service      │ │
│ └─────────────┘ │
└─────────────────┘
         │
┌────────▼────────┐
│  Azure SQL      │
│  Database       │
└─────────────────┘
```

### Services We'll Build
1. **Product Service**
   - Container App with auto-scaling
   - Azure SQL Database for data
   - Application Insights for monitoring

2. **Order Service**
   - Container App with service-to-service communication
   - Azure Service Bus for async messaging
   - Azure Key Vault for secrets

### Cost Estimation
For this demo (assuming minimal usage):
- Container Apps: ~$5-10/month
- Azure SQL (Basic): ~$5/month
- Container Registry: ~$5/month
- **Total**: ~$15-20/month

**Free Tier Benefits:**
- First 180,000 vCPU-seconds free
- First 360,000 GB-seconds free
- First 2 million requests free

## Verification Steps

Run these commands to verify your setup:
```bash
# Check all resources
az resource list --resource-group $RESOURCE_GROUP --output table

# Export variables for next exercises
echo "RESOURCE_GROUP=$RESOURCE_GROUP"
echo "ACR_NAME=$ACR_NAME"
echo "ENVIRONMENT=$ENVIRONMENT"
echo "LOCATION=$LOCATION"

# Save to a file for later use
@"
RESOURCE_GROUP=$RESOURCE_GROUP
ACR_NAME=$ACR_NAME
ENVIRONMENT=$ENVIRONMENT
LOCATION=$LOCATION
"@ | Out-File -FilePath "azure-config.ps1"
```

## Common Issues and Solutions

### Issue: "Subscription not found"
```bash
# List all subscriptions
az account list --output table
# Use the correct subscription ID
az account set --subscription "correct-id"
```

### Issue: "Name already exists"
Container Registry names must be globally unique. Add random numbers:
```bash
$ACR_NAME="acrmicroservices$(Get-Random -Minimum 10000 -Maximum 99999)"
```

### Issue: "Insufficient permissions"
Ensure you have at least "Contributor" role:
```bash
az role assignment list --assignee $(az account show --query user.name -o tsv) --output table
```

## Clean Up (Optional)
To avoid charges, you can delete everything:
```bash
# Delete entire resource group (BE CAREFUL!)
# az group delete --name $RESOURCE_GROUP --yes --no-wait
```

## Next Steps
In Exercise 2, we'll build Azure-ready microservices using these resources!