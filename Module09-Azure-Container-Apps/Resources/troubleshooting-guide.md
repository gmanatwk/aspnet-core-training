# Azure Container Apps Troubleshooting Guide

## 🔧 Common Issues and Solutions

This guide covers the most common issues encountered when working with Azure Container Apps and their solutions.

## 🚫 Deployment Issues

### Issue: Container App Fails to Start

**Symptoms:**
- Container app shows "Failed" or "Unhealthy" status
- Application not accessible
- Logs show startup errors

**Diagnostic Steps:**
```bash
# Check container app status
az containerapp show --name myapp --resource-group myRG --query "properties.runningStatus"

# View container logs
az containerapp logs show --name myapp --resource-group myRG --tail 100

# Check revision status
az containerapp revision list --name myapp --resource-group myRG --output table
```

**Common Causes & Solutions:**

1. **Incorrect Port Configuration**
```bash
# Problem: Target port doesn't match container port
# Solution: Update target port
az containerapp update --name myapp --resource-group myRG --target-port 8080
```

2. **Image Not Found**
```bash
# Problem: Container registry authentication failed
# Solution: Update registry credentials
az containerapp update --name myapp --resource-group myRG \
    --registry-server myregistry.azurecr.io \
    --registry-username myusername \
    --registry-password mypassword
```

3. **Environment Variables Missing**
```bash
# Problem: Required environment variables not set
# Solution: Add missing environment variables
az containerapp update --name myapp --resource-group myRG \
    --set-env-vars "ASPNETCORE_ENVIRONMENT=Production" "API_KEY=secretref:api-key"
```

### Issue: Image Pull Errors

**Symptoms:**
- "ImagePullBackOff" or "ErrImagePull" status
- Cannot pull container image

**Solutions:**

1. **Check Registry Authentication**
```bash
# Verify ACR credentials
az acr credential show --name myregistry

# Update container app with correct credentials
az containerapp registry set --name myapp --resource-group myRG \
    --server myregistry.azurecr.io \
    --username myusername \
    --password mypassword
```

2. **Verify Image Exists**
```bash
# List images in registry
az acr repository list --name myregistry

# Check specific image tags
az acr repository show-tags --name myregistry --repository myapp
```

3. **Check Registry Permissions**
```bash
# Assign AcrPull role to managed identity
az role assignment create \
    --assignee <managed-identity-id> \
    --role AcrPull \
    --scope /subscriptions/<subscription>/resourceGroups/<rg>/providers/Microsoft.ContainerRegistry/registries/<registry>
```

## 🌐 Networking Issues

### Issue: Application Not Accessible

**Symptoms:**
- Cannot reach application URL
- DNS resolution fails
- Connection timeouts

**Diagnostic Steps:**
```bash
# Check ingress configuration
az containerapp show --name myapp --resource-group myRG \
    --query "properties.configuration.ingress"

# Verify FQDN
az containerapp show --name myapp --resource-group myRG \
    --query "properties.configuration.ingress.fqdn"
```

**Solutions:**

1. **Enable External Ingress**
```bash
# Enable external ingress if needed
az containerapp ingress enable --name myapp --resource-group myRG \
    --type external --target-port 8080
```

2. **Check Custom Domain Configuration**
```bash
# List custom domains
az containerapp hostname list --name myapp --resource-group myRG

# Verify DNS configuration
nslookup mydomain.com
```

3. **Verify SSL Certificate**
```bash
# Check certificate status
az containerapp hostname list --name myapp --resource-group myRG \
    --query "[].{hostname:name, certificateStatus:certificateStatus}"
```

### Issue: Internal Service Communication Fails

**Symptoms:**
- Service-to-service calls timeout
- 503 Service Unavailable errors
- DNS resolution failures between services

**Solutions:**

1. **Check Service Discovery**
```bash
# Verify both services are in same environment
az containerapp list --resource-group myRG \
    --query "[].{name:name, environment:properties.managedEnvironmentId}"

# Test internal connectivity
az containerapp exec --name myapp --resource-group myRG \
    --command "nslookup service2.internal.my-env.eastus.azurecontainerapps.io"
```

2. **Internal Ingress Configuration**
```bash
# Ensure target service has internal ingress enabled
az containerapp ingress enable --name targetservice --resource-group myRG \
    --type internal --target-port 8080
```

## 🔍 Performance Issues

### Issue: Slow Application Response

**Symptoms:**
- High response times
- Timeouts
- Poor user experience

**Diagnostic Steps:**
```bash
# Check resource usage
az containerapp show --name myapp --resource-group myRG \
    --query "properties.template.containers[0].resources"

# Monitor scaling
az containerapp revision list --name myapp --resource-group myRG \
    --query "[].{name:name, replicas:properties.replicas, active:properties.active}"
```

**Solutions:**

1. **Increase Resource Limits**
```bash
# Increase CPU and memory
az containerapp update --name myapp --resource-group myRG \
    --cpu 1.0 --memory 2.0Gi
```

2. **Optimize Scaling Rules**
```bash
# Add CPU-based scaling
az containerapp update --name myapp --resource-group myRG \
    --scale-rule-name "cpu-scaling" \
    --scale-rule-type "cpu" \
    --scale-rule-metadata "type=Utilization" "value=70"

# Increase max replicas
az containerapp update --name myapp --resource-group myRG \
    --max-replicas 10
```

3. **Check Application Performance**
```bash
# View Application Insights metrics
# - Response times
# - Dependency calls
# - Exception rates
```

### Issue: Cold Start Problems

**Symptoms:**
- First request takes very long
- Application scales to zero frequently
- Inconsistent performance

**Solutions:**

1. **Increase Minimum Replicas**
```bash
# Prevent scaling to zero
az containerapp update --name myapp --resource-group myRG \
    --min-replicas 1
```

2. **Optimize Container Startup**
```csharp
// In Program.cs - optimize startup
var builder = WebApplication.CreateBuilder(args);

// Pre-compile expressions
builder.Services.AddControllers(options =>
{
    options.ModelValidatorProviders.Clear();
    options.ModelMetadataDetailsProviders.Clear();
});

// Reduce startup overhead
builder.WebHost.UseShutdownTimeout(TimeSpan.FromSeconds(10));
```

## 🔐 Security Issues

### Issue: Authentication Failures

**Symptoms:**
- 401 Unauthorized responses
- Token validation errors
- Identity provider integration fails

**Solutions:**

1. **Check Authentication Configuration**
```bash
# View authentication settings
az containerapp auth show --name myapp --resource-group myRG
```

2. **Update Identity Provider Settings**
```bash
# Configure Azure AD authentication
az containerapp auth microsoft update --name myapp --resource-group myRG \
    --client-id <client-id> \
    --client-secret <client-secret> \
    --tenant-id <tenant-id>
```

### Issue: SSL/TLS Certificate Problems

**Symptoms:**
- SSL certificate warnings
- HTTPS not working
- Certificate validation errors

**Solutions:**

1. **Check Certificate Status**
```bash
# View certificate information
az containerapp hostname list --name myapp --resource-group myRG

# Check certificate expiration
openssl s_client -connect mydomain.com:443 -servername mydomain.com | \
    openssl x509 -noout -dates
```

2. **Update Certificate**
```bash
# Upload new certificate
az containerapp ssl upload --name myapp --resource-group myRG \
    --certificate-file certificate.pfx \
    --certificate-password <password>
```

## 📊 Monitoring and Logging Issues

### Issue: Missing or Incomplete Logs

**Symptoms:**
- No logs appearing in Log Analytics
- Application Insights not receiving data
- Missing telemetry data

**Solutions:**

1. **Check Log Analytics Configuration**
```bash
# Verify Log Analytics workspace
az containerapp env show --name myenv --resource-group myRG \
    --query "properties.appLogsConfiguration"
```

2. **Verify Application Insights Setup**
```bash
# Check connection string
az containerapp show --name myapp --resource-group myRG \
    --query "properties.template.containers[0].env[?name=='APPLICATIONINSIGHTS_CONNECTION_STRING']"
```

3. **Update Logging Configuration**
```csharp
// Ensure proper logging configuration
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddApplicationInsights();

// Add structured logging
builder.Services.Configure<JsonConsoleFormatterOptions>(options =>
{
    options.IncludeScopes = true;
    options.TimestampFormat = "yyyy-MM-dd HH:mm:ss ";
});
```

### Issue: Health Check Failures

**Symptoms:**
- Application marked as unhealthy
- Frequent restarts
- Load balancer removing instances

**Solutions:**

1. **Check Health Check Endpoint**
```bash
# Test health endpoint directly
curl -v https://myapp.domain.com/health

# Check health check configuration
az containerapp show --name myapp --resource-group myRG \
    --query "properties.template.containers[0].probes"
```

2. **Implement Proper Health Checks**
```csharp
// Add comprehensive health checks
builder.Services.AddHealthChecks()
    .AddCheck("self", () => HealthCheckResult.Healthy())
    .AddCheck("database", async () =>
    {
        try
        {
            // Test database connection
            await dbContext.Database.CanConnectAsync();
            return HealthCheckResult.Healthy("Database connection successful");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy($"Database connection failed: {ex.Message}");
        }
    });
```

## 🔄 Scaling Issues

### Issue: Application Not Scaling

**Symptoms:**
- High CPU/memory usage but no scaling
- Performance degradation under load
- Scale rules not triggering

**Solutions:**

1. **Check Scaling Configuration**
```bash
# View current scaling rules
az containerapp show --name myapp --resource-group myRG \
    --query "properties.template.scale"
```

2. **Update Scaling Rules**
```bash
# Add HTTP-based scaling
az containerapp update --name myapp --resource-group myRG \
    --scale-rule-name "http-requests" \
    --scale-rule-type "http" \
    --scale-rule-metadata "concurrentRequests=10"

# Add CPU-based scaling
az containerapp update --name myapp --resource-group myRG \
    --scale-rule-name "cpu-usage" \
    --scale-rule-type "cpu" \
    --scale-rule-metadata "type=Utilization" "value=70"
```

3. **Monitor Scaling Metrics**
```kql
// KQL query for scaling events
ContainerAppSystemLogs_CL
| where ContainerAppName_s == "myapp"
| where Log_s contains "scaling"
| order by TimeGenerated desc
```

## 🛠️ Configuration Issues

### Issue: Environment Variables Not Working

**Symptoms:**
- Application using default values
- Configuration not loading
- Features not working as expected

**Solutions:**

1. **Verify Environment Variables**
```bash
# List current environment variables
az containerapp show --name myapp --resource-group myRG \
    --query "properties.template.containers[0].env"
```

2. **Update Configuration**
```bash
# Add or update environment variables
az containerapp update --name myapp --resource-group myRG \
    --set-env-vars "FEATURE_FLAG=true" "LOG_LEVEL=Debug"

# Reference secrets
az containerapp update --name myapp --resource-group myRG \
    --set-env-vars "CONNECTION_STRING=secretref:connection-string"
```

### Issue: Secrets Management Problems

**Symptoms:**
- Cannot access secret values
- Authentication failures
- Key Vault integration issues

**Solutions:**

1. **Check Secret Configuration**
```bash
# List secrets
az containerapp secret list --name myapp --resource-group myRG

# Update secret value
az containerapp secret set --name myapp --resource-group myRG \
    --secrets "api-key=new-secret-value"
```

2. **Azure Key Vault Integration**
```bash
# Enable managed identity
az containerapp identity assign --name myapp --resource-group myRG --system-assigned

# Grant Key Vault access
az keyvault set-policy --name myvault \
    --object-id <managed-identity-object-id> \
    --secret-permissions get list
```

## 📱 Development and Debugging

### Issue: Cannot Debug Container Locally

**Symptoms:**
- Container works in Azure but not locally
- Different behavior between environments
- Unable to reproduce issues

**Solutions:**

1. **Use Development Dockerfile**
```dockerfile
# Dockerfile.dev
FROM mcr.microsoft.com/dotnet/sdk:8.0
WORKDIR /app
EXPOSE 8080

COPY . .
RUN dotnet restore

CMD ["dotnet", "watch", "run", "--urls", "http://0.0.0.0:8080"]
```

2. **Environment Parity**
```bash
# Run with same environment variables
docker run -p 8080:8080 \
    -e ASPNETCORE_ENVIRONMENT=Development \
    -e APPLICATIONINSIGHTS_CONNECTION_STRING="..." \
    myapp:dev

# Use docker-compose for complex scenarios
docker-compose -f docker-compose.dev.yml up
```

3. **Remote Debugging**
```bash
# Enable remote debugging
az containerapp exec --name myapp --resource-group myRG --command "/bin/sh"

# View real-time logs
az containerapp logs show --name myapp --resource-group myRG --follow
```

## 🚨 Emergency Procedures

### Rollback Deployment

```bash
# Get previous revision
PREVIOUS_REVISION=$(az containerapp revision list --name myapp --resource-group myRG \
    --query "[1].name" --output tsv)

# Rollback to previous revision
az containerapp ingress traffic set --name myapp --resource-group myRG \
    --revision-weight $PREVIOUS_REVISION=100
```

### Scale Up Quickly

```bash
# Emergency scale up
az containerapp update --name myapp --resource-group myRG \
    --min-replicas 5 --max-replicas 20

# Increase resources
az containerapp update --name myapp --resource-group myRG \
    --cpu 2.0 --memory 4.0Gi
```

### Enable Debug Mode

```bash
# Add debug environment variables
az containerapp update --name myapp --resource-group myRG \
    --set-env-vars "ASPNETCORE_ENVIRONMENT=Development" "LOG_LEVEL=Debug"
```

## 📋 Diagnostic Checklist

When troubleshooting issues, follow this systematic approach:

### 1. Basic Health Check
- [ ] Container app status is "Running"
- [ ] Latest revision is active
- [ ] Health endpoints respond correctly
- [ ] Application URL is accessible

### 2. Configuration Review
- [ ] Environment variables are correct
- [ ] Secrets are properly configured
- [ ] Port mappings are accurate
- [ ] Registry authentication works

### 3. Resource Analysis
- [ ] CPU and memory limits are appropriate
- [ ] Scaling rules are configured
- [ ] Performance metrics are within range
- [ ] No resource constraints

### 4. Network Connectivity
- [ ] Ingress configuration is correct
- [ ] DNS resolution works
- [ ] SSL certificates are valid
- [ ] Internal service communication works

### 5. Monitoring Setup
- [ ] Logs are being generated
- [ ] Application Insights is receiving data
- [ ] Alerts are configured
- [ ] Metrics are being collected

## 🆘 Getting Help

### Azure Support Resources
- [Azure Container Apps Documentation](https://docs.microsoft.com/en-us/azure/container-apps/)
- [Azure Support Portal](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade)
- [Microsoft Q&A](https://docs.microsoft.com/en-us/answers/topics/azure-container-apps.html)

### Community Resources
- [Azure Container Apps GitHub](https://github.com/microsoft/azure-container-apps)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/azure-container-apps)
- [Reddit r/AZURE](https://www.reddit.com/r/AZURE/)

### Useful CLI Commands for Support

```bash
# Generate diagnostic information
az containerapp show --name myapp --resource-group myRG > app-config.json

# Export logs
az containerapp logs show --name myapp --resource-group myRG \
    --tail 1000 > app-logs.txt

# Get environment information
az containerapp env show --name myenv --resource-group myRG > env-config.json

# List all resources
az resource list --resource-group myRG --output table > resources.txt
```

Remember: When contacting support, always include relevant logs, configuration details, and steps to reproduce the issue.
