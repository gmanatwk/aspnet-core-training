# Module 9: Deploying to Azure Container Apps (No Docker Required)

## 🎯 Learning Objectives
By the end of this module, you will be able to:
- Understand Azure Container Apps as a serverless platform
- Deploy ASP.NET Core applications directly to Azure without Docker
- Use Azure Container Registry build tasks to create containers in the cloud
- Configure scaling, networking, and security for your applications
- Implement CI/CD pipelines with GitHub Actions
- Monitor applications using Application Insights
- Manage environment variables and secrets with Azure Key Vault
- Set up custom domains and SSL certificates
- Implement deployment strategies without local containers
- Integrate with Azure services seamlessly

## 📚 Module Overview
This module covers deployment of ASP.NET Core applications to Azure Container Apps without requiring Docker Desktop or local containerization. You'll learn how to use Azure's build services to create containers in the cloud, deploy them to the serverless platform, and manage them in production.

## 🕒 Estimated Duration: 2 hours

---

## 📖 Table of Contents

### 1. Azure Container Apps Fundamentals
- What are Azure Container Apps?
- Comparison with other Azure container services
- Architecture and key components
- Pricing and scaling models
- When to use Azure Container Apps

### 2. Cloud-Native ASP.NET Core Applications
- Preparing applications for Azure deployment
- Understanding container concepts without Docker
- Azure Container Registry build tasks
- Cloud-based image building
- Best practices for cloud-native .NET apps

### 3. Deployment Strategies
- Azure CLI deployment
- Azure Portal deployment
- Bicep and ARM templates
- GitHub Actions integration
- Azure DevOps pipelines

### 4. Configuration and Secrets Management
- Environment variables configuration
- Azure Key Vault integration
- Configuration providers for containers
- Managing connection strings securely
- Application settings and feature flags

### 5. Scaling and Performance
- Horizontal Pod Autoscaling (HPA)
- Vertical scaling options
- Traffic splitting and load balancing
- Performance monitoring and optimization
- Resource limits and requests

### 6. Networking and Security
- Virtual network integration
- Custom domains and SSL certificates
- Authentication and authorization
- Network security groups
- Private endpoints and egress restrictions

### 7. Monitoring and Troubleshooting
- Application Insights integration
- Container logs and metrics
- Health checks and probes
- Debugging containerized applications
- Common deployment issues and solutions

---

## 🛠️ Prerequisites
- Completion of Modules 1-8
- Azure subscription (free tier is sufficient)
- Azure CLI installed (version 2.50+)
- Visual Studio or Visual Studio Code
- .NET 8 SDK
- Git for version control

## 📦 Required Tools and Extensions
```bash
# Azure CLI
az --version

# .NET SDK
dotnet --version

# Git
git --version

# GitHub CLI (optional)
gh --version
```

### VS Code Extensions
- Azure Account
- Azure Container Apps
- Azure Resources
- C# Dev Kit

---

## 🔥 Key Concepts Covered

### 1. Azure Container Apps Architecture
- **Serverless Containers**: Focus on your application, not infrastructure
- **Built-in Autoscaling**: Scale to zero and beyond based on demand
- **Event-Driven Computing**: HTTP, Timers, and custom triggers
- **Microservices Ready**: Service discovery and communication
- **Environment Management**: Isolated environments for different stages

### 2. Cloud Build Fundamentals
- **ACR Build Tasks**: Building images in the cloud without Docker
- **Automated Builds**: Azure detects and builds .NET projects automatically
- **Base Image Management**: Azure selects optimal base images
- **Build Caching**: Azure handles caching for performance
- **Security Scanning**: Built-in vulnerability scanning in ACR

### 3. Deployment and DevOps
- **Infrastructure as Code**: Bicep templates for repeatable deployments
- **CI/CD Pipelines**: Automated building, testing, and deployment
- **GitOps**: Configuration management through Git
- **Blue-Green Deployments**: Zero-downtime deployments
- **Canary Releases**: Gradual rollout strategies

### 4. Configuration Management
- **12-Factor App Principles**: Environment-specific configuration
- **Azure Key Vault**: Secure secret management
- **Configuration Providers**: Flexible configuration loading
- **Feature Flags**: Dynamic application behavior
- **Environment Promotion**: Configuration across environments

### 5. Observability and Monitoring
- **Application Insights**: Deep application monitoring
- **Container Metrics**: Resource usage and performance
- **Distributed Tracing**: Request flow across services
- **Log Aggregation**: Centralized logging strategies
- **Alerting**: Proactive issue detection

---

## 🏗️ Project Structure
```
Module09-Azure-Container-Apps/
├── README.md
├── SourceCode/
│   ├── ContainerAppsDemo/
│   │   ├── ContainerAppsDemo.csproj
│   │   ├── Program.cs
│   │   ├── Controllers/
│   │   └── deploy-to-azure.sh
├── Exercises/
│   ├── Exercise01-Azure-Setup.md
│   ├── Exercise02-Cloud-Build-Deploy.md
│   ├── Exercise03-CI-CD-Pipeline.md
│   └── Exercise04-Advanced-Configuration.md
└── Resources/
    ├── deployment-templates/
    ├── azure-build-guide.md
    ├── troubleshooting-guide.md
    └── monitoring-setup.md
```

---

## 🎯 Learning Path

### Phase 1: Azure Container Apps Fundamentals (30 minutes)
1. **Container Concepts** - Understanding containers without Docker
2. **Azure Setup** - Creating necessary Azure resources
3. **Cloud Builds** - Using Azure to build container images

### Phase 2: Azure Container Apps Setup (30 minutes)
1. **Azure Resources** - Creating container app environments
2. **First Deployment** - Deploy using Azure CLI
3. **Configuration** - Environment variables and secrets

### Phase 3: Production Deployment (45 minutes)
1. **CI/CD Pipeline** - Automated deployment with GitHub Actions
2. **Infrastructure as Code** - Bicep template deployment
3. **Monitoring Setup** - Application Insights integration

### Phase 4: Advanced Scenarios (15 minutes)
1. **Scaling Configuration** - Auto-scaling setup
2. **Custom Domains** - SSL and domain configuration
3. **Multi-Service Architecture** - Service-to-service communication

---

## 📋 Hands-On Exercises

### Exercise 1: Preparing for Azure Deployment (30 minutes)
**Objective**: Prepare an ASP.NET Core application for Azure Container Apps

**Tasks**:
- Create a cloud-ready ASP.NET Core API
- Configure for Azure deployment settings
- Set up Azure Container Registry
- Use ACR build tasks to create images
- Configure health checks for Azure

**Key Learning Points**:
- Dockerfile best practices for .NET applications
- Container image layering and caching
- Running containers with proper port mapping
- Environment variable configuration
- Container debugging techniques

**✅ Complete Solution Available**: `Exercises/Solutions/Exercise01-Containerization-Solution/`

### Exercise 2: Azure Deployment (45 minutes)
**Objective**: Deploy the containerized application to Azure Container Apps

**Tasks**:
- Create Azure Container Apps environment
- Deploy application using Azure CLI
- Configure environment variables and secrets
- Set up custom scaling rules
- Test the deployed application

**Key Learning Points**:
- Azure CLI commands for container apps
- Container registry integration
- Environment and secret management
- Scaling configuration options
- Accessing deployed applications

**✅ Complete Solution Available**: `Exercises/Solutions/Exercise02-Azure-Deployment-Solution/`

### Exercise 3: CI/CD Pipeline (30 minutes)
**Objective**: Implement automated deployment using GitHub Actions

**Tasks**:
- Create GitHub Actions workflow for container building
- Set up automated deployment to Azure Container Apps
- Configure environment-specific deployments
- Implement deployment approvals for production
- Add automated testing in the pipeline

**Key Learning Points**:
- GitHub Actions for container workflows
- Azure service principal authentication
- Environment-specific configuration
- Deployment strategies and approvals
- Pipeline debugging and troubleshooting

**✅ Complete Solution Available**: `Exercises/Solutions/Exercise03-CICD-Pipeline-Solution/`

### Exercise 4: Advanced Configuration (15 minutes)
**Objective**: Configure monitoring, custom domains, and service communication

**Tasks**:
- Set up Application Insights monitoring
- Configure custom domain with SSL certificate
- Implement service-to-service communication
- Set up log aggregation and alerting
- Configure network security

**Key Learning Points**:
- Application Insights integration
- Custom domain and SSL setup
- Service discovery mechanisms
- Log management strategies
- Network security configuration

**✅ Complete Solution Available**: `Exercises/Solutions/Exercise04-Advanced-Config-Solution/`

---

## 📝 Quick Reference Code Examples

### Dockerfile (Created by Azure)
```dockerfile
# Azure Container Registry will generate this for you
# You don't need to create or manage Dockerfiles locally
# ACR Tasks automatically detect .NET projects and create optimal images

# Example of what ACR creates:
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app .
EXPOINT ["dotnet", "YourApp.dll"]
```

### Azure CLI Deployment (No Docker Required)
```bash
# Create resource group
az group create --name myResourceGroup --location eastus

# Create Azure Container Registry
az acr create --name myregistry --resource-group myResourceGroup --sku Basic

# Build image in Azure (no local Docker needed!)
az acr build --registry myregistry --image myapi:v1 .

# Create container app environment
az containerapp env create \
  --name myEnvironment \
  --resource-group myResourceGroup \
  --location eastus

# Deploy container app from ACR
az containerapp create \
  --name myapi \
  --resource-group myResourceGroup \
  --environment myEnvironment \
  --image myregistry.azurecr.io/myapi:v1 \
  --registry-server myregistry.azurecr.io \
  --target-port 80 \
  --ingress external \
  --cpu 0.25 \
  --memory 0.5Gi
```

### GitHub Actions Workflow
```yaml
name: Deploy to Azure Container Apps

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Log in to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    # No Docker needed - Azure builds the image!
    - name: Build image in Azure
      run: |
        az acr build --registry myregistry \
          --image myapi:${{ github.sha }} .
    
    - name: Deploy to Container Apps
      run: |
        az containerapp update \
          --name myapi \
          --resource-group myResourceGroup \
          --image myregistry.azurecr.io/myapi:${{ github.sha }}
```

### Bicep Template
```bicep
param appName string = 'myapi'
param location string = resourceGroup().location
param containerImage string

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: '${appName}-env'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
    }
  }
}

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: appName
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
      }
    }
    template: {
      containers: [
        {
          name: appName
          image: containerImage
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
      }
    }
  }
}
```

---

## 🎓 Assessment Criteria

### Technical Proficiency (40%)
- **Containerization**: Creating optimized Dockerfile and container images
- **Azure Deployment**: Successfully deploying and configuring container apps
- **Configuration Management**: Proper handling of secrets and environment variables
- **Infrastructure as Code**: Using Bicep templates for deployment automation

### DevOps Skills (30%)
- **CI/CD Implementation**: Setting up automated build and deployment pipelines
- **Version Control**: Proper Git workflow and branching strategies
- **Monitoring Setup**: Configuring comprehensive application monitoring
- **Troubleshooting**: Debugging container and deployment issues

### Architecture Understanding (20%)
- **Cloud-Native Principles**: Applying 12-factor app methodology
- **Scaling Design**: Understanding auto-scaling and resource management
- **Security Implementation**: Secure configuration and secret management
- **Service Design**: Designing for containerized environments

### Problem-Solving (10%)
- **Issue Resolution**: Debugging deployment and runtime issues
- **Performance Optimization**: Container and application performance tuning
- **Documentation**: Creating clear deployment and operational documentation

---

## 🔧 Essential Azure CLI Commands

### Environment Management
```bash
# List container app environments
az containerapp env list --output table

# Show environment details
az containerapp env show --name myenv --resource-group myRG

# Delete environment
az containerapp env delete --name myenv --resource-group myRG
```

### Container App Management
```bash
# List container apps
az containerapp list --output table

# Show app details
az containerapp show --name myapp --resource-group myRG

# Update container app
az containerapp update --name myapp --resource-group myRG --image newimage:tag

# View logs
az containerapp logs show --name myapp --resource-group myRG --follow
```

### Scaling Configuration
```bash
# Update scaling rules
az containerapp update --name myapp --resource-group myRG \
  --min-replicas 2 --max-replicas 10

# Set CPU and memory
az containerapp update --name myapp --resource-group myRG \
  --cpu 0.5 --memory 1.0Gi
```

---

## 🚫 Common Pitfalls and Solutions

### ❌ Avoid These Mistakes

**1. Trying to Use Docker Locally**
```bash
# BAD - Trying to build locally
docker build -t myapp .
docker push myregistry.azurecr.io/myapp

# GOOD - Let Azure build for you
az acr build --registry myregistry --image myapp:v1 .
```

**2. Hardcoded Configuration**
```csharp
// BAD - Hardcoded connection strings
var connectionString = "Server=myserver;Database=mydb;";

// GOOD - Environment-based configuration
var connectionString = configuration.GetConnectionString("DefaultConnection");
```

**3. Improper Secret Management**
```bash
# BAD - Secrets in environment variables
az containerapp create --env-vars "API_KEY=secret123"

# GOOD - Using secrets
az containerapp secret set --name myapp --secrets "api-key=secret123"
az containerapp update --name myapp --set-env-vars "API_KEY=secretref:api-key"
```

**4. Missing Health Checks**
```csharp
// GOOD - Implement health checks for Azure
builder.Services.AddHealthChecks();
app.MapHealthChecks("/healthz");
app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready")
});
```

---

## 📚 Additional Resources

### Official Documentation
- [Azure Container Apps Documentation](https://docs.microsoft.com/en-us/azure/container-apps/)
- [Docker for .NET Developers](https://docs.microsoft.com/en-us/dotnet/architecture/containerized-lifecycle/)
- [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)

### Best Practices Guides
- [Container Image Security](https://docs.microsoft.com/en-us/azure/container-apps/security)
- [.NET Container Guidelines](https://github.com/dotnet/dotnet-docker/blob/main/documentation/best-practices.md)
- [12-Factor App Methodology](https://12factor.net/)
- [Azure Well-Architected Framework](https://docs.microsoft.com/en-us/azure/architecture/framework/)

### Tools and Utilities
- [Azure Container Apps CLI Extension](https://github.com/microsoft/azure-container-apps)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Visual Studio Code Azure Extension](https://code.visualstudio.com/docs/azure/extensions)
- [Bicep VS Code Extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep)

### Community Resources
- [Azure Container Apps Samples](https://github.com/Azure-Samples/container-apps-store-api-microservice)
- [Awesome Azure Container Apps](https://github.com/Azure/awesome-azure-container-apps)
- [Microsoft Learn Modules](https://docs.microsoft.com/en-us/learn/paths/deploy-applications-azure-container-apps/)

---

## 🚀 Next Steps
After completing this module, you'll be ready to:
- **Module 10: Security Fundamentals** - Implement advanced security patterns
- Deploy production-ready containerized applications to Azure
- Set up sophisticated CI/CD pipelines for container-based applications
- Implement blue-green and canary deployment strategies
- Design and deploy microservices architectures
- Optimize container performance and costs in production
- Mentor teams on cloud-native development practices

---

**📌 Note**: This module provides hands-on experience with real Azure deployments. Students will deploy actual applications to Azure Container Apps and learn to manage them in production scenarios. All exercises include cost-optimization strategies to minimize Azure charges during learning.
