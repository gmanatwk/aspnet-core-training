# Exercise 2: Cloud Build and Deployment Strategies

## 🎯 Objective
Learn advanced deployment strategies for Azure Container Apps including multi-environment deployments, configuration management, and zero-downtime updates—all without Docker.

## ⏱️ Estimated Time: 45 minutes

## 📋 Prerequisites
- Completed Exercise 1
- Azure resources created (Resource Group, ACR, Container Apps Environment)
- WeatherAPI project from Exercise 1

## 🎓 Learning Goals
- Implement multi-stage deployments
- Manage secrets with Azure Key Vault
- Configure environment-specific settings
- Implement blue-green deployments
- Set up database connections

---

## 📚 Background Information

### Deployment Strategies in Azure Container Apps

**Revision Management**: Every deployment creates a new revision
- Traffic can be split between revisions
- Enables blue-green and canary deployments
- Automatic rollback capabilities

**Configuration Management**: Separate code from configuration
- Environment variables for settings
- Azure Key Vault for secrets
- Managed identities for secure access

**Zero-Downtime Deployments**: Built-in capabilities
- Health checks ensure readiness
- Gradual traffic shifting
- Automatic rollback on failures

---

## 🛠️ Setup Instructions

### Load Previous Configuration
```bash
# If continuing from Exercise 1, load your variables
$RESOURCE_GROUP="rg-containerapp-demo"
$LOCATION="eastus"
# Get your ACR name
$ACR_NAME=$(az acr list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv)
$ENVIRONMENT="containerapp-env"
```

---

## 📝 Tasks

### Task 1: Add Azure SQL Database Integration (15 minutes)

1. **Create Azure SQL Database**:
```bash
# Create SQL Server
$SQL_SERVER="sql-containerapp-$(Get-Random -Minimum 1000 -Maximum 9999)"
$SQL_ADMIN="sqladmin"
$SQL_PASSWORD="P@ssw0rd$(Get-Random -Minimum 1000 -Maximum 9999)!"

az sql server create `
  --name $SQL_SERVER `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION `
  --admin-user $SQL_ADMIN `
  --admin-password $SQL_PASSWORD

# Allow Azure services
az sql server firewall-rule create `
  --resource-group $RESOURCE_GROUP `
  --server $SQL_SERVER `
  --name AllowAzureServices `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 0.0.0.0

# Create database
az sql db create `
  --resource-group $RESOURCE_GROUP `
  --server $SQL_SERVER `
  --name WeatherDB `
  --edition Basic
```

2. **Update application to use database** - Add to `WeatherAPI.csproj`:
```xml
<ItemGroup>
  <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="8.0.0" />
  <PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="8.0.0" />
</ItemGroup>
```

3. **Create a simple DbContext** - Add `Data/WeatherContext.cs`:
```csharp
using Microsoft.EntityFrameworkCore;

namespace WeatherAPI.Data;

public class WeatherContext : DbContext
{
    public WeatherContext(DbContextOptions<WeatherContext> options)
        : base(options)
    {
    }

    public DbSet<WeatherRecord> WeatherRecords { get; set; }
}

public class WeatherRecord
{
    public int Id { get; set; }
    public DateTime Date { get; set; }
    public int TemperatureC { get; set; }
    public string? Summary { get; set; }
}
```

4. **Update Program.cs** to configure database:
```csharp
// Add after builder creation
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<WeatherContext>(options =>
    options.UseSqlServer(connectionString));

// Add health check for database
builder.Services.AddHealthChecks()
    .AddSqlServer(connectionString, name: "database");
```

### Task 2: Set Up Azure Key Vault (10 minutes)

1. **Create Key Vault**:
```bash
$KEY_VAULT="kv-containerapp-$(Get-Random -Minimum 1000 -Maximum 9999)"

az keyvault create `
  --name $KEY_VAULT `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION

# Add database connection string as secret
$CONNECTION_STRING="Server=tcp:$SQL_SERVER.database.windows.net,1433;Database=WeatherDB;User ID=$SQL_ADMIN;Password=$SQL_PASSWORD;Encrypt=True;TrustServerCertificate=False;"

az keyvault secret set `
  --vault-name $KEY_VAULT `
  --name "ConnectionStrings--DefaultConnection" `
  --value $CONNECTION_STRING
```

2. **Enable managed identity for Container App**:
```bash
# We'll do this when we deploy the updated app
```

### Task 3: Build and Deploy Updated Application (10 minutes)

1. **Update appsettings.json**:
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Will be replaced by Key Vault"
  }
}
```

2. **Build new version in Azure**:
```bash
# Build v2 with database support
az acr build `
  --registry $ACR_NAME `
  --image weatherapi:v2 `
  .
```

3. **Deploy with managed identity and Key Vault**:
```bash
# Create new revision with managed identity
az containerapp update `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --image "$ACR_NAME.azurecr.io/weatherapi:v2" `
  --assign-identity

# Get identity details
$IDENTITY_ID=$(az containerapp identity show --name weatherapi --resource-group $RESOURCE_GROUP --query principalId -o tsv)

# Grant Key Vault access
az keyvault set-policy `
  --name $KEY_VAULT `
  --object-id $IDENTITY_ID `
  --secret-permissions get list

# Update app with Key Vault reference
az containerapp update `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --set-env-vars `
    "AZURE_KEY_VAULT_ENDPOINT=https://$KEY_VAULT.vault.azure.net/" `
    "ConnectionStrings__DefaultConnection=secretref:ConnectionStrings--DefaultConnection"
```

### Task 4: Implement Blue-Green Deployment (10 minutes)

1. **Create a staging revision**:
```bash
# Update with staging label
az containerapp revision copy `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --label staging `
  --cpu 0.25 `
  --memory 0.5Gi
```

2. **Test staging revision**:
```bash
# Get staging URL
$STAGING_URL=$(az containerapp revision show `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --revision staging `
  --query properties.fqdn -o tsv)

Write-Host "Staging URL: https://$STAGING_URL" -ForegroundColor Yellow

# Test staging
curl "https://$STAGING_URL/healthz"
```

3. **Perform traffic splitting**:
```bash
# Split traffic 80/20
az containerapp ingress traffic set `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --revision-weight latest=80 staging=20

# After testing, route all traffic to new version
az containerapp ingress traffic set `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --revision-weight latest=100
```

### Task 5: Configure Monitoring (5 minutes)

1. **Create Application Insights**:
```bash
$APP_INSIGHTS="appi-containerapp"

az monitor app-insights component create `
  --app $APP_INSIGHTS `
  --location $LOCATION `
  --resource-group $RESOURCE_GROUP `
  --application-type web

# Get instrumentation key
$INSTRUMENTATION_KEY=$(az monitor app-insights component show `
  --app $APP_INSIGHTS `
  --resource-group $RESOURCE_GROUP `
  --query instrumentationKey -o tsv)
```

2. **Update application with Application Insights**:
```bash
# Add package to project first
dotnet add package Microsoft.ApplicationInsights.AspNetCore

# Then rebuild and deploy
az acr build --registry $ACR_NAME --image weatherapi:v3 .

az containerapp update `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --image "$ACR_NAME.azurecr.io/weatherapi:v3" `
  --set-env-vars `
    "ApplicationInsights__ConnectionString=InstrumentationKey=$INSTRUMENTATION_KEY"
```

---

## ✅ Verification Steps

1. **Check database connectivity**:
```bash
# View logs for database connection
az containerapp logs show `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --tail 50
```

2. **Verify Key Vault integration**:
```bash
# Check environment variables
az containerapp show `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --query properties.template.containers[0].env `
  --output table
```

3. **Test traffic splitting**:
```bash
# Make multiple requests and observe version distribution
for ($i = 0; $i -lt 10; $i++) {
    curl "https://$APP_URL/weatherforecast"
}
```

---

## 🎉 Success Criteria

You've successfully completed this exercise if:
- ✅ Database is integrated and accessible
- ✅ Secrets are stored in Key Vault
- ✅ Managed identity is configured
- ✅ Blue-green deployment is working
- ✅ Application Insights is collecting telemetry

---

## 🚀 Bonus Challenges

1. **Add Dapr Integration**:
```bash
az containerapp update `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --enable-dapr `
  --dapr-app-id weatherapi `
  --dapr-app-port 80
```

2. **Configure Custom Domain**:
```bash
# First add a custom domain
az containerapp hostname add `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --hostname yourdomain.com

# Then bind certificate
az containerapp hostname bind `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --hostname yourdomain.com `
  --certificate-id /path/to/cert
```

3. **Set Up Autoscaling Rules**:
```bash
# Scale based on HTTP requests
az containerapp update `
  --name weatherapi `
  --resource-group $RESOURCE_GROUP `
  --scale-rule-name http-scaling `
  --scale-rule-type http `
  --scale-rule-metadata concurrentRequests=20 `
  --min-replicas 1 `
  --max-replicas 10
```

---

## 📚 Key Takeaways

- **No Docker Needed**: All builds happen in Azure
- **Secure by Default**: Managed identities and Key Vault
- **Zero-Downtime**: Built-in blue-green deployments
- **Observable**: Application Insights integration
- **Scalable**: Automatic scaling based on load

---

## Next Steps
Proceed to [Exercise 3: CI/CD Pipeline with GitHub Actions](Exercise03-CI-CD-Pipeline.md)