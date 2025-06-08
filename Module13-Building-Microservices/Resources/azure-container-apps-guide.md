# Azure Container Apps Guide

## What are Azure Container Apps?

Azure Container Apps is a fully managed serverless container platform that enables you to build and deploy modern apps and microservices using containers. It's built on top of Kubernetes but abstracts away the complexity.

## Key Features

### 1. **Serverless Containers**
- No infrastructure management
- Automatic OS patching and upgrades
- Built-in load balancing

### 2. **Auto-scaling**
- Scale to zero (cost savings)
- Scale based on:
  - HTTP traffic
  - CPU/Memory usage
  - Azure Queue length
  - Custom metrics

### 3. **Microservices Features**
- Service discovery
- Traffic splitting for A/B testing
- Blue-green deployments
- Built-in Dapr support

### 4. **Networking**
- Custom domains and certificates
- Internal and external ingress
- Built-in HTTPS

## Container Apps vs Other Azure Services

| Feature | Container Apps | App Service | AKS | Container Instances |
|---------|---------------|-------------|-----|-------------------|
| **Best for** | Microservices | Web apps | Full control | Simple containers |
| **Scaling** | Auto (0 to ∞) | Manual/Auto | Manual/Auto | Manual |
| **Complexity** | Low | Low | High | Very Low |
| **Control** | Medium | Low | Full | Low |
| **Pricing** | Per usage | Per plan | Per node | Per container |

## Basic Concepts

### 1. **Environment**
- Secure boundary around a group of container apps
- Shared virtual network
- Shared logging and monitoring

### 2. **Container App**
- Your application
- Can have multiple containers (sidecar pattern)
- Has revisions (versions)

### 3. **Revision**
- Immutable snapshot of a container app version
- Can split traffic between revisions
- Automatic revision on deployment

### 4. **Replica**
- Running instance of your revision
- Managed by the platform

## Common Commands

### Create an Environment
```bash
az containerapp env create \
  --name my-environment \
  --resource-group my-rg \
  --location eastus
```

### Deploy a Container App
```bash
az containerapp create \
  --name my-app \
  --resource-group my-rg \
  --environment my-environment \
  --image myregistry.azurecr.io/myapp:latest \
  --target-port 80 \
  --ingress 'external' \
  --min-replicas 0 \
  --max-replicas 10
```

### Update an App
```bash
az containerapp update \
  --name my-app \
  --resource-group my-rg \
  --image myregistry.azurecr.io/myapp:v2
```

### View Logs
```bash
az containerapp logs show \
  --name my-app \
  --resource-group my-rg \
  --follow
```

## Scaling Configuration

### HTTP Scaling
```bash
az containerapp update \
  --name my-app \
  --resource-group my-rg \
  --scale-rule-name http-rule \
  --scale-rule-type http \
  --scale-rule-metadata concurrentRequests=50 \
  --min-replicas 1 \
  --max-replicas 10
```

### CPU Scaling
```bash
az containerapp update \
  --name my-app \
  --resource-group my-rg \
  --scale-rule-name cpu-rule \
  --scale-rule-type cpu \
  --scale-rule-metadata type=utilization value=70 \
  --min-replicas 1 \
  --max-replicas 5
```

## Environment Variables and Secrets

### Set Environment Variables
```bash
az containerapp update \
  --name my-app \
  --resource-group my-rg \
  --set-env-vars "KEY1=value1" "KEY2=value2"
```

### Use Secrets
```bash
# Create secret
az containerapp secret set \
  --name my-app \
  --resource-group my-rg \
  --secrets "db-password=secretvalue"

# Reference in env var
az containerapp update \
  --name my-app \
  --resource-group my-rg \
  --set-env-vars "DB_PASSWORD=secretref:db-password"
```

## Best Practices

1. **Use Managed Identity**
   - Avoid storing credentials
   - Secure access to Azure services

2. **Health Probes**
   - Always implement /health endpoints
   - Configure liveness and readiness probes

3. **Resource Limits**
   - Set appropriate CPU and memory limits
   - Start small and scale based on metrics

4. **Logging**
   - Use structured logging
   - Integrate with Application Insights

5. **Revisions**
   - Use revision labels for staging
   - Implement gradual rollouts

## Cost Optimization

1. **Scale to Zero**
   - Configure min replicas = 0 for dev/test
   - Use for event-driven workloads

2. **Right-size Resources**
   - Monitor actual usage
   - Adjust CPU/memory allocations

3. **Use Spot Instances**
   - For non-critical workloads
   - Significant cost savings

## Troubleshooting

### App Won't Start
```bash
# Check system logs
az containerapp logs show \
  --name my-app \
  --resource-group my-rg \
  --type system

# Check console logs
az containerapp logs show \
  --name my-app \
  --resource-group my-rg \
  --type console
```

### Scaling Issues
```bash
# Check revision details
az containerapp revision list \
  --name my-app \
  --resource-group my-rg \
  --output table

# Check replica count
az containerapp revision show \
  --name my-app \
  --revision revision-name \
  --resource-group my-rg \
  --query properties.replicas
```

### Network Issues
- Verify ingress configuration
- Check environment network settings
- Ensure service discovery names are correct

## Further Reading

- [Official Documentation](https://docs.microsoft.com/en-us/azure/container-apps/)
- [Pricing Calculator](https://azure.microsoft.com/en-us/pricing/details/container-apps/)
- [GitHub Samples](https://github.com/Azure-Samples/container-apps-samples)