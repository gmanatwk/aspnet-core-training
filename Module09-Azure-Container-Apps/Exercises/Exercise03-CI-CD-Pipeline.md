# Exercise 3: CI/CD Pipeline

## 🎯 Objective
Implement automated deployment using GitHub Actions to build, test, and deploy your containerized ASP.NET Core application to Azure Container Apps. This exercise covers GitOps principles, infrastructure as code, and production deployment strategies.

## ⏱️ Estimated Time: 30 minutes

## 📋 Prerequisites
- Completed Exercise 2 (Azure Deployment)
- GitHub account
- Azure Container Apps environment from Exercise 2
- Basic understanding of YAML and Git workflows

## 🎓 Learning Goals
- Create GitHub Actions workflows for container applications
- Implement automated testing in CI/CD pipelines
- Configure secure authentication with Azure using service principals
- Set up environment-specific deployments
- Implement deployment approvals and rollback strategies
- Use Infrastructure as Code with Bicep templates

---

## 📚 Background Information

### CI/CD for Container Applications
Continuous Integration and Continuous Deployment for containers involves:
- **Build**: Creating container images automatically
- **Test**: Running automated tests in containerized environments
- **Security**: Scanning images for vulnerabilities
- **Deploy**: Automatic deployment to target environments
- **Monitor**: Tracking deployment success and application health

### GitHub Actions for Azure
GitHub Actions provides native integration with Azure services:
- **Azure Login**: Secure authentication using service principals
- **Container Registry**: Direct integration with ACR
- **Container Apps**: Native deployment support
- **Infrastructure**: Bicep and ARM template deployment

---

## 🛠️ Setup Instructions

### Step 1: Create GitHub Repository
1. Create a new repository on GitHub or use an existing one
2. Initialize with your ProductApi code from Exercise 1
3. Ensure your Dockerfile and source code are in the repository

### Step 2: Azure Service Principal Setup
Create a service principal for GitHub Actions authentication:

```bash
# Set variables
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
RESOURCE_GROUP="rg-containerapp-demo"  # From Exercise 2
SP_NAME="sp-github-containerapp"

# Create service principal
az ad sp create-for-rbac \
    --name $SP_NAME \
    --role Contributor \
    --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP \
    --sdk-auth

# Save the output - you'll need it for GitHub secrets
```

### Step 3: Configure GitHub Secrets
Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

- `AZURE_CREDENTIALS`: The entire JSON output from the service principal creation
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID
- `AZURE_RG`: Your resource group name
- `ACR_NAME`: Your Azure Container Registry name

---

## 📝 Tasks

### Task 1: Create Basic CI/CD Workflow (15 minutes)

Create `.github/workflows/deploy.yml`:

```yaml
name: Build and Deploy to Azure Container Apps

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  AZURE_CONTAINER_APP: productapi
  AZURE_CONTAINER_ENV: env-containerapp-demo
  CONTAINER_IMAGE_NAME: productapi

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: '8.0.x'

    - name: Restore dependencies
      run: dotnet restore

    - name: Build application
      run: dotnet build --no-restore --configuration Release

    - name: Run tests
      run: dotnet test --no-build --configuration Release --verbosity normal

    - name: Login to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Build and push container image
      run: |
        az acr build \
          --registry ${{ secrets.ACR_NAME }} \
          --image ${{ env.CONTAINER_IMAGE_NAME }}:${{ github.sha }} \
          --image ${{ env.CONTAINER_IMAGE_NAME }}:latest \
          .

  deploy-to-azure:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Login to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Deploy to Container Apps
      run: |
        az containerapp update \
          --name ${{ env.AZURE_CONTAINER_APP }} \
          --resource-group ${{ secrets.AZURE_RG }} \
          --image ${{ secrets.ACR_NAME }}.azurecr.io/${{ env.CONTAINER_IMAGE_NAME }}:${{ github.sha }}

    - name: Get application URL
      run: |
        APP_URL=$(az containerapp show \
          --name ${{ env.AZURE_CONTAINER_APP }} \
          --resource-group ${{ secrets.AZURE_RG }} \
          --query properties.configuration.ingress.fqdn \
          --output tsv)
        echo "Application deployed to: https://$APP_URL"
```

### Task 2: Add Unit Tests (5 minutes)

Create a simple unit test project to demonstrate testing in the pipeline:

```bash
# In your repository root
dotnet new xunit -n ProductApi.Tests
cd ProductApi.Tests
dotnet add reference ../ProductApi/ProductApi.csproj
dotnet add package Microsoft.AspNetCore.Mvc.Testing
```

Create `ProductApi.Tests/WeatherForecastTests.cs`:

```csharp
using Microsoft.AspNetCore.Mvc.Testing;
using System.Net;
using Xunit;

namespace ProductApi.Tests;

public class WeatherForecastTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public WeatherForecastTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task Get_WeatherForecast_ReturnsSuccessAndCorrectContentType()
    {
        // Arrange
        var client = _factory.CreateClient();

        // Act
        var response = await client.GetAsync("/WeatherForecast");

        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("application/json; charset=utf-8", 
            response.Content.Headers.ContentType?.ToString());
    }

    [Fact]
    public async Task Get_HealthCheck_ReturnsHealthy()
    {
        // Arrange
        var client = _factory.CreateClient();

        // Act
        var response = await client.GetAsync("/healthz");

        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
}
```

Update your solution file to include the test project:

```bash
# Add test project to solution
dotnet sln add ProductApi.Tests/ProductApi.Tests.csproj
```

### Task 3: Enhanced Workflow with Environment Strategy (5 minutes)

Create `.github/workflows/deploy-with-environments.yml`:

```yaml
name: Deploy with Environments

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  CONTAINER_IMAGE_NAME: productapi

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
      image-digest: ${{ steps.build.outputs.digest }}
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: '8.0.x'

    - name: Run tests
      run: |
        dotnet restore
        dotnet build --configuration Release
        dotnet test --configuration Release --no-build

    - name: Login to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Extract metadata
      id: meta
      run: |
        echo "tags=${{ secrets.ACR_NAME }}.azurecr.io/${{ env.CONTAINER_IMAGE_NAME }}:${{ github.sha }}" >> $GITHUB_OUTPUT

    - name: Build and push
      id: build
      run: |
        az acr build \
          --registry ${{ secrets.ACR_NAME }} \
          --image ${{ env.CONTAINER_IMAGE_NAME }}:${{ github.sha }} \
          --image ${{ env.CONTAINER_IMAGE_NAME }}:latest \
          .

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment: staging
    
    steps:
    - name: Login to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Deploy to staging
      run: |
        az containerapp update \
          --name ${{ env.CONTAINER_IMAGE_NAME }}-staging \
          --resource-group ${{ secrets.AZURE_RG }} \
          --image ${{ needs.build.outputs.image-tag }} \
          --revision-suffix staging-${{ github.run_number }}

  deploy-production:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
    - name: Login to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Deploy to production
      run: |
        az containerapp update \
          --name ${{ env.CONTAINER_IMAGE_NAME }} \
          --resource-group ${{ secrets.AZURE_RG }} \
          --image ${{ needs.build.outputs.image-tag }} \
          --revision-suffix prod-${{ github.run_number }}

    - name: Run smoke tests
      run: |
        APP_URL=$(az containerapp show \
          --name ${{ env.CONTAINER_IMAGE_NAME }} \
          --resource-group ${{ secrets.AZURE_RG }} \
          --query properties.configuration.ingress.fqdn \
          --output tsv)
        
        # Wait for deployment
        sleep 30
        
        # Test endpoints
        curl -f https://$APP_URL/healthz || exit 1
        curl -f https://$APP_URL/WeatherForecast || exit 1
        
        echo "✅ Smoke tests passed!"
        echo "🚀 Application deployed to: https://$APP_URL"
```

### Task 4: Infrastructure as Code with Bicep (5 minutes)

Create `infrastructure/main.bicep`:

```bicep
@description('The name of the container app')
param containerAppName string = 'productapi'

@description('The location for all resources')
param location string = resourceGroup().location

@description('The container image to deploy')
param containerImage string

@description('The environment name')
param environmentName string = 'env-containerapp'

@description('The ACR login server')
param acrLoginServer string

@description('The ACR username')
@secure()
param acrUsername string

@description('The ACR password')
@secure()
param acrPassword string

// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${containerAppName}-logs'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// Container Apps Environment
resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: environmentName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

// Container App
resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
        allowInsecure: false
      }
      registries: [
        {
          server: acrLoginServer
          username: acrUsername
          passwordSecretRef: 'acr-password'
        }
      ]
      secrets: [
        {
          name: 'acr-password'
          value: acrPassword
        }
      ]
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: containerImage
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Production'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 5
        rules: [
          {
            name: 'http-rule'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
}

// Outputs
output containerAppFQDN string = containerApp.properties.configuration.ingress.fqdn
output containerAppUrl string = 'https://${containerApp.properties.configuration.ingress.fqdn}'
```

Add Bicep deployment to your workflow by replacing the deploy step:

```yaml
    - name: Deploy infrastructure
      run: |
        az deployment group create \
          --resource-group ${{ secrets.AZURE_RG }} \
          --template-file infrastructure/main.bicep \
          --parameters \
            containerAppName=${{ env.AZURE_CONTAINER_APP }} \
            containerImage=${{ needs.build.outputs.image-tag }} \
            acrLoginServer=${{ secrets.ACR_NAME }}.azurecr.io \
            acrUsername=${{ secrets.ACR_USERNAME }} \
            acrPassword=${{ secrets.ACR_PASSWORD }}
```

---

## ✅ Verification Checklist

Mark each item as complete:

- [ ] Created GitHub repository with source code
- [ ] Configured Azure service principal and GitHub secrets
- [ ] Created basic CI/CD workflow that builds and tests
- [ ] Added unit tests that run in the pipeline
- [ ] Implemented automated container image building
- [ ] Set up automated deployment to Azure Container Apps
- [ ] Created environment-specific deployment workflows
- [ ] Implemented Bicep Infrastructure as Code
- [ ] Added smoke tests for deployment verification
- [ ] Tested the complete pipeline end-to-end

---

## 🔍 Testing Your Pipeline

### Test the Workflow
1. **Push to repository**:
```bash
git add .
git commit -m "Add CI/CD pipeline"
git push origin main
```

2. **Monitor GitHub Actions**:
   - Go to your repository on GitHub
   - Click on "Actions" tab
   - Watch the workflow execution

3. **Verify deployment**:
   - Check that all jobs complete successfully
   - Visit the application URL from the workflow output
   - Test the endpoints

### Test Pull Request Workflow
1. **Create feature branch**:
```bash
git checkout -b feature/update-message
```

2. **Make a change**:
```csharp
// In WeatherForecastController.cs, update the Get method
[HttpGet(Name = "GetWeatherForecast")]
public IEnumerable<WeatherForecast> Get()
{
    return Enumerable.Range(1, 5).Select(index => new WeatherForecast
    {
        Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
        TemperatureC = Random.Shared.Next(-20, 55),
        Summary = Summaries[Random.Shared.Next(Summaries.Length)] + " (Updated via CI/CD)"
    })
    .ToArray();
}
```

3. **Create pull request**:
```bash
git add .
git commit -m "Update weather forecast message"
git push origin feature/update-message
```

4. **Create PR on GitHub and verify**:
   - Only build and test jobs should run (no deployment)
   - All tests should pass

---

## 🎯 Expected Outcomes

After completing this exercise, you should have:

1. **Automated CI/CD**: Complete pipeline from code commit to production deployment
2. **Quality Gates**: Automated testing prevents broken code from deploying
3. **Security**: Service principal authentication for secure Azure access
4. **Infrastructure as Code**: Bicep templates for reproducible deployments
5. **Environment Strategy**: Separate staging and production deployments
6. **Monitoring**: Smoke tests and deployment verification

### Pipeline Performance
- **Build time**: ~3-5 minutes
- **Test execution**: ~30 seconds
- **Container build**: ~2-3 minutes
- **Deployment time**: ~1-2 minutes
- **Total pipeline**: ~6-10 minutes

---

## 🔧 Common Issues and Solutions

### Issue 1: Service Principal Authentication Fails
```bash
# Verify service principal has correct permissions
az role assignment list --assignee <service-principal-id>

# Ensure GitHub secrets are correct
# Check AZURE_CREDENTIALS format matches az ad sp create-for-rbac --sdk-auth output
```

### Issue 2: Container Registry Access Denied
```bash
# Verify ACR admin is enabled
az acr update --name $ACR_NAME --admin-enabled true

# Check ACR credentials in GitHub secrets
az acr credential show --name $ACR_NAME
```

### Issue 3: Tests Fail in Pipeline
```bash
# Run tests locally first
dotnet test --verbosity normal

# Check test project references
dotnet list reference
```

### Issue 4: Deployment Fails
```bash
# Check container app exists
az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP

# Verify image exists in ACR
az acr repository show-tags --name $ACR_NAME --repository productapi
```

---

## 🏆 Bonus Challenges

### Challenge 1: Security Scanning
Add container security scanning to your pipeline:

```yaml
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: '${{ secrets.ACR_NAME }}.azurecr.io/${{ env.CONTAINER_IMAGE_NAME }}:${{ github.sha }}'
        format: 'table'
        exit-code: '1'
        ignore-unfixed: true
        severity: 'CRITICAL,HIGH'
```

### Challenge 2: Blue-Green Deployment
Implement blue-green deployment strategy:

```yaml
    - name: Blue-Green Deployment
      run: |
        # Create new revision without traffic
        az containerapp update \
          --name ${{ env.AZURE_CONTAINER_APP }} \
          --resource-group ${{ secrets.AZURE_RG }} \
          --image ${{ needs.build.outputs.image-tag }} \
          --revision-suffix green-${{ github.run_number }}
        
        # Wait and test new revision
        sleep 30
        
        # Switch traffic to new revision
        az containerapp ingress traffic set \
          --name ${{ env.AZURE_CONTAINER_APP }} \
          --resource-group ${{ secrets.AZURE_RG }} \
          --revision-weight latest=100
```

### Challenge 3: Database Migrations
Add database migration step:

```yaml
    - name: Run Database Migrations
      run: |
        # Example using Entity Framework migrations
        dotnet tool install --global dotnet-ef
        dotnet ef database update --connection "${{ secrets.CONNECTION_STRING }}"
```

### Challenge 4: Performance Testing
Add performance testing with Artillery:

```yaml
    - name: Performance Testing
      run: |
        npm install -g artillery
        echo "config:
          target: 'https://$APP_URL'
        scenarios:
          - duration: 60
            arrivalRate: 10
            name: 'Load test'
        " > loadtest.yml
        artillery run loadtest.yml
```

---

## 📖 Advanced Topics

### GitHub Environments and Protection Rules
Set up environment protection rules in GitHub:

1. **Go to Settings → Environments**
2. **Create "production" environment**
3. **Add protection rules**:
   - Required reviewers
   - Wait timer
   - Deployment branches

### Workflow Templates
Create reusable workflow templates:

```yaml
# .github/workflows/reusable-deploy.yml
name: Reusable Deploy Workflow

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      image-tag:
        required: true
        type: string
    secrets:
      AZURE_CREDENTIALS:
        required: true
```

### GitOps with ArgoCD
For advanced GitOps scenarios, consider ArgoCD integration:

```yaml
# Deploy using ArgoCD
- name: Update ArgoCD Application
  run: |
    yq eval '.spec.source.helm.parameters[0].value = "${{ needs.build.outputs.image-tag }}"' \
      argocd/application.yaml > argocd/application-updated.yaml
```

---

## 📚 Additional Resources

### GitHub Actions Documentation
- [GitHub Actions for Azure](https://docs.microsoft.com/en-us/azure/developer/github/github-actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Security Best Practices](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)

### Azure DevOps Alternative
If using Azure DevOps instead of GitHub Actions:

```yaml
# azure-pipelines.yml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

stages:
- stage: Build
  jobs:
  - job: BuildAndPush
    steps:
    - task: Docker@2
      inputs:
        containerRegistry: 'myACR'
        repository: 'productapi'
        command: 'buildAndPush'
        Dockerfile: '**/Dockerfile'
```

---

## 🚀 Next Steps

Once you've completed this exercise:

1. **Review pipeline performance** - Identify optimization opportunities
2. **Add more comprehensive tests** - Integration tests, security scans
3. **Implement advanced deployment strategies** - Canary releases, feature flags
4. **Set up monitoring and alerting** - Application Insights, Azure Monitor
5. **Prepare for Exercise 4** - Advanced configuration and monitoring

**Key takeaways to remember**:
- CI/CD pipelines provide consistency and reliability
- Automated testing prevents regression issues
- Infrastructure as Code enables reproducible deployments
- Security scanning should be part of every pipeline
- Environment strategies provide safe deployment practices

---

**🎉 Congratulations!** You've successfully implemented a complete CI/CD pipeline for your containerized application. Your code changes now automatically flow from development to production with full testing and verification!
