# Exercise 3: CI/CD Pipeline with GitHub Actions (No Docker Required)

## 🎯 Objective
Implement a complete CI/CD pipeline using GitHub Actions that builds and deploys your application to Azure Container Apps without requiring Docker locally.

## ⏱️ Estimated Time: 30 minutes

## 📋 Prerequisites
- Completed Exercises 1 and 2
- GitHub account with a repository
- Azure resources from previous exercises
- WeatherAPI project pushed to GitHub

## 🎓 Learning Goals
- Create GitHub Actions workflows for Azure
- Implement cloud-based container builds
- Set up automated deployments
- Configure environment-specific deployments
- Implement security best practices

---

## 📚 Background Information

### CI/CD Without Local Docker
Traditional CI/CD pipelines often require Docker to build images locally. With Azure Container Registry build tasks, we can:

- **Build in the Cloud**: No Docker needed on build agents
- **Secure by Default**: No Docker socket exposure
- **Consistent Builds**: Same environment as production
- **Cost Effective**: No need for self-hosted runners

### GitHub Actions + Azure
- **Native Integration**: Azure Login action for authentication
- **Managed Secrets**: GitHub secrets for secure configuration
- **Matrix Builds**: Deploy to multiple environments
- **Approval Gates**: Manual approval for production

---

## 🛠️ Setup Instructions

### Step 1: Prepare Your Repository

1. **Create a GitHub repository** (if not already done):
```bash
# Initialize git in your project
cd WeatherAPI
git init
git add .
git commit -m "Initial commit"

# Create repository on GitHub and push
gh repo create weatherapi-azure --public --source=. --remote=origin --push
```

2. **Verify repository structure**:
```
WeatherAPI/
├── Program.cs
├── WeatherAPI.csproj
├── Dockerfile
├── appsettings.json
└── Controllers/
    └── WeatherForecastController.cs
```

### Step 2: Configure Azure Service Principal

1. **Create service principal for GitHub Actions**:
```bash
# Create service principal
$SP_NAME="GitHub-Actions-WeatherAPI"
$SUBSCRIPTION_ID=$(az account show --query id -o tsv)

$SP_CREDENTIALS=$(az ad sp create-for-rbac `
  --name $SP_NAME `
  --role contributor `
  --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP `
  --sdk-auth)

Write-Host "Save these credentials as a GitHub secret:" -ForegroundColor Yellow
Write-Host $SP_CREDENTIALS -ForegroundColor Cyan
```

2. **Add GitHub secrets**:
   - Go to your GitHub repository
   - Navigate to Settings > Secrets and variables > Actions
   - Add new repository secret:
     - Name: `AZURE_CREDENTIALS`
     - Value: The JSON output from the command above

---

## 📝 Tasks

### Task 1: Create Basic CI/CD Workflow (10 minutes)

1. **Create workflow directory**:
```bash
mkdir -p .github/workflows
```

2. **Create `.github/workflows/deploy.yml`**:
```yaml
name: Build and Deploy to Azure Container Apps

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

env:
  RESOURCE_GROUP: rg-containerapp-demo
  ACR_NAME: <your-acr-name>  # Replace with your ACR name
  CONTAINER_APP_NAME: weatherapi
  CONTAINER_APP_ENV: containerapp-env

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Log in to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Build and push image to ACR
      run: |
        # Build image in Azure Container Registry (no Docker needed!)
        az acr build \
          --registry ${{ env.ACR_NAME }} \
          --image weatherapi:${{ github.sha }} \
          --image weatherapi:latest \
          .

    - name: Deploy to Container Apps
      run: |
        az containerapp update \
          --name ${{ env.CONTAINER_APP_NAME }} \
          --resource-group ${{ env.RESOURCE_GROUP }} \
          --image ${{ env.ACR_NAME }}.azurecr.io/weatherapi:${{ github.sha }}

    - name: Get application URL
      run: |
        APP_URL=$(az containerapp show \
          --name ${{ env.CONTAINER_APP_NAME }} \
          --resource-group ${{ env.RESOURCE_GROUP }} \
          --query properties.configuration.ingress.fqdn -o tsv)
        echo "Application deployed to: https://$APP_URL"
        echo "APP_URL=https://$APP_URL" >> $GITHUB_ENV

    - name: Test deployment
      run: |
        sleep 30  # Wait for app to be ready
        curl -f ${{ env.APP_URL }}/healthz || exit 1
        echo "Health check passed!"
```

3. **Update ACR name in workflow**:
   - Replace `<your-acr-name>` with your actual ACR name from Exercise 1

### Task 2: Add Environment-Specific Deployments (10 minutes)

1. **Create multi-environment workflow** - Update `.github/workflows/deploy.yml`:
```yaml
name: Build and Deploy to Azure Container Apps

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

env:
  RESOURCE_GROUP: rg-containerapp-demo
  ACR_NAME: <your-acr-name>
  CONTAINER_APP_ENV: containerapp-env

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.build.outputs.image-tag }}
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Log in to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Build and push image
      id: build
      run: |
        IMAGE_TAG="${{ github.sha }}"
        echo "image-tag=$IMAGE_TAG" >> $GITHUB_OUTPUT
        
        # Build in ACR (no local Docker!)
        az acr build \
          --registry ${{ env.ACR_NAME }} \
          --image weatherapi:$IMAGE_TAG \
          --image weatherapi:latest \
          .

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    if: github.ref == 'refs/heads/develop'
    
    steps:
    - name: Log in to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Deploy to staging
      run: |
        az containerapp update \
          --name weatherapi-staging \
          --resource-group ${{ env.RESOURCE_GROUP }} \
          --image ${{ env.ACR_NAME }}.azurecr.io/weatherapi:${{ needs.build.outputs.image-tag }} \
          --set-env-vars "ASPNETCORE_ENVIRONMENT=Staging"

  deploy-production:
    needs: build
    runs-on: ubuntu-latest
    environment: production
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Log in to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Deploy to production
      run: |
        # Deploy with traffic splitting (canary deployment)
        az containerapp revision copy \
          --name weatherapi \
          --resource-group ${{ env.RESOURCE_GROUP }} \
          --image ${{ env.ACR_NAME }}.azurecr.io/weatherapi:${{ needs.build.outputs.image-tag }} \
          --revision-suffix ${{ github.run_number }}
        
        # Split traffic 90/10
        LATEST_REVISION=$(az containerapp revision list \
          --name weatherapi \
          --resource-group ${{ env.RESOURCE_GROUP }} \
          --query "[0].name" -o tsv)
        
        PREVIOUS_REVISION=$(az containerapp revision list \
          --name weatherapi \
          --resource-group ${{ env.RESOURCE_GROUP }} \
          --query "[1].name" -o tsv)
        
        az containerapp ingress traffic set \
          --name weatherapi \
          --resource-group ${{ env.RESOURCE_GROUP }} \
          --revision-weight $LATEST_REVISION=10 $PREVIOUS_REVISION=90

    - name: Run smoke tests
      run: |
        APP_URL=$(az containerapp show \
          --name weatherapi \
          --resource-group ${{ env.RESOURCE_GROUP }} \
          --query properties.configuration.ingress.fqdn -o tsv)
        
        # Run basic smoke tests
        curl -f https://$APP_URL/healthz || exit 1
        curl -f https://$APP_URL/weatherforecast || exit 1
        
        echo "Smoke tests passed!"

    - name: Complete deployment
      if: success()
      run: |
        # Route 100% traffic to new revision
        az containerapp ingress traffic set \
          --name weatherapi \
          --resource-group ${{ env.RESOURCE_GROUP }} \
          --revision-weight latest=100
```

2. **Configure GitHub environments**:
   - Go to Settings > Environments
   - Create "staging" environment
   - Create "production" environment with:
     - Required reviewers (add yourself)
     - Wait timer (optional, e.g., 5 minutes)

### Task 3: Add Build Validation (5 minutes)

1. **Create PR validation workflow** - `.github/workflows/pr-validation.yml`:

```yaml
name: PR Validation

on:
  pull_request:
    branches: [ main, develop ]

env:
  DOTNET_VERSION: '8.0.x'

jobs:
  validate:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: ${{ env.DOTNET_VERSION }}
    
    - name: Restore dependencies
      run: dotnet restore
    
    - name: Build
      run: dotnet build --no-restore
    
    - name: Test
      run: dotnet test --no-build --verbosity normal
    
    - name: Check code formatting
      run: |
        dotnet format --verify-no-changes --verbosity diagnostic
    
    - name: Run security scan
      run: |
        dotnet tool install --global security-scan
        security-scan ./WeatherAPI.csproj || true
```

### Task 4: Add Monitoring and Notifications (5 minutes)

1. **Update main workflow with notifications**:
```yaml
    # Add this step at the end of each job
    - name: Send notification
      if: always()
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        text: |
          Deployment ${{ job.status }} for ${{ github.sha }}
          Environment: ${{ github.job }}
          Author: ${{ github.actor }}
        webhook_url: ${{ secrets.SLACK_WEBHOOK }}  # Optional
      env:
        SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

2. **Add deployment status badge** to README.md:
```markdown
# WeatherAPI

[![Build and Deploy](https://github.com/YOUR_USERNAME/weatherapi-azure/actions/workflows/deploy.yml/badge.svg)](https://github.com/YOUR_USERNAME/weatherapi-azure/actions/workflows/deploy.yml)

Azure Container Apps deployment example without Docker Desktop.
```

---

## ✅ Verification Steps

1. **Push code to trigger workflow**:
```bash
git add .
git commit -m "Add GitHub Actions workflow"
git push origin main
```

2. **Monitor workflow execution**:
   - Go to Actions tab in GitHub
   - Watch the workflow progress
   - Check each step for success

3. **Verify deployment**:
```bash
# Get the deployed app URL
$APP_URL=$(az containerapp show `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --query properties.configuration.ingress.fqdn -o tsv)

# Test the deployment
curl https://$APP_URL/healthz
curl https://$APP_URL/weatherforecast
```

---

## 🎉 Success Criteria

You've successfully completed this exercise if:
- ✅ GitHub Actions workflow is created and running
- ✅ Code builds in Azure Container Registry (no local Docker)
- ✅ Automated deployment to Container Apps works
- ✅ Environment-specific deployments are configured
- ✅ PR validation is in place
- ✅ Deployment status is visible in GitHub
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

## 📚 Key Takeaways

- **No Docker Required**: ACR builds eliminate local Docker needs
- **Secure Pipelines**: Service principals provide secure access
- **Environment Management**: Separate staging and production deployments
- **Cost Control**: Scale to zero for non-production environments
- **Automated Testing**: Integrate tests into the pipeline

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

## 🧹 Cleanup Actions

To clean up GitHub Actions resources:
```bash
# Remove service principal (optional)
az ad sp delete --id $(az ad sp list --display-name "GitHub-Actions-WeatherAPI" --query [0].id -o tsv)

# Remove GitHub secrets manually through UI
```

---

## Next Steps
Proceed to [Exercise 4: Advanced Configuration and Monitoring](Exercise04-Advanced-Configuration.md)

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
