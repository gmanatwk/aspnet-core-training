# Exercise 5: Production Deployment with Terraform and Kubernetes on Azure

## 🎯 Objective
Deploy the complete microservices architecture to Azure using Infrastructure as Code (Terraform) and Kubernetes, implementing production-grade features including auto-scaling, monitoring, and security.

## ⏱️ Estimated Time
90 minutes

## 📚 Prerequisites
- Completed Exercises 1-4
- Azure subscription with sufficient credits
- Azure CLI installed and configured
- Terraform installed (v1.3+)
- kubectl installed
- Basic understanding of Terraform and Kubernetes

## 🔧 Setup

### Step 1: Prepare Your Environment
```bash
# Navigate to the module directory
cd Module13-Building-Microservices

# Check prerequisites
az --version          # Azure CLI 2.40+
terraform --version   # Terraform 1.3+
kubectl version       # kubectl 1.28+
helm version         # Helm 3.10+

# Login to Azure
az login

# Set your subscription (if you have multiple)
az account list --output table
az account set --subscription "Your-Subscription-Name"
```

## 📋 Tasks

### Task 1: Understanding the Terraform Configuration (15 minutes)

1. **Explore the Terraform structure**:
```bash
cd terraform
tree -L 2
```

Expected structure:
```
terraform/
├── main.tf              # Main infrastructure resources
├── kubernetes.tf        # Kubernetes-specific resources
├── variables.tf         # Input variables
├── terraform.tfvars.example  # Example configuration
├── deploy.sh           # Deployment automation script
├── helm-values/        # Helm chart configurations
└── README.md          # Detailed documentation
```

2. **Review key resources** in `main.tf`:
   - Resource Group
   - Virtual Network and Subnets
   - Azure Kubernetes Service (AKS)
   - Azure Container Registry (ACR)
   - Azure SQL Databases
   - Azure Service Bus
   - Azure Key Vault
   - Application Insights

3. **Understand the variables**:
```bash
# Review available variables
grep "variable" variables.tf | grep -o '"[^"]*"' | sort -u
```

### Task 2: Configure Terraform Variables (10 minutes)

1. **Create your terraform.tfvars**:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. **Edit terraform.tfvars** with your values:
```hcl
# Azure Configuration
subscription_id = "your-azure-subscription-id"
tenant_id       = "your-azure-tenant-id"

# Resource Configuration
resource_group_name = "ecommerce-microservices-rg"
location            = "East US"  # Choose closest region
environment         = "production"
project_name        = "ecommerce"

# Optional: Use smaller sizes for cost savings during learning
# Uncomment to override defaults:
# environments = {
#   production = {
#     aks_node_count  = 2      # Reduce from 3
#     aks_vm_size     = "Standard_D2s_v3"  # Smaller VMs
#     sql_sku         = "Basic"  # Basic tier
#   }
# }
```

3. **Get your Azure subscription details**:
```bash
# Get subscription ID
az account show --query id -o tsv

# Get tenant ID
az account show --query tenantId -o tsv
```

### Task 3: Initialize and Plan Infrastructure (15 minutes)

1. **Initialize Terraform**:
```bash
# This will create backend storage and initialize providers
./deploy.sh init
```

Expected output:
```
Checking prerequisites...
All prerequisites are installed.
Logging into Azure...
Creating Terraform backend storage...
Initializing Terraform...
Terraform initialized successfully.
```

2. **Validate the configuration**:
```bash
terraform validate
```

3. **Create the deployment plan**:
```bash
./deploy.sh plan
```

4. **Review the plan output**:
   - Number of resources to be created
   - Resource types and configurations
   - Estimated costs (if available)

### Task 4: Deploy Azure Infrastructure (20 minutes)

1. **Apply the Terraform configuration**:
```bash
./deploy.sh apply
```

When prompted, type `yes` to confirm.

2. **Monitor the deployment progress**:
   - Watch for any errors
   - Note the resource creation order
   - Deployment typically takes 15-20 minutes

3. **Verify infrastructure creation**:
```bash
# Check resource group
az group show --name ecommerce-microservices-rg

# Check AKS cluster
az aks list --output table

# Check ACR
az acr list --output table
```

### Task 5: Build and Push Docker Images (15 minutes)

1. **Prepare the microservices code**:
```bash
cd ../SourceCode/ECommerceMS
```

2. **Build and push images to ACR**:
```bash
cd ../../terraform
./deploy.sh build-images
```

This will:
- Login to Azure Container Registry
- Build Docker images for each microservice
- Tag images appropriately
- Push images to ACR

3. **Verify images in ACR**:
```bash
# Get ACR name
ACR_NAME=$(terraform output -raw acr_login_server | cut -d'.' -f1)

# List repositories
az acr repository list --name $ACR_NAME --output table

# Show tags for a specific image
az acr repository show-tags --name $ACR_NAME --repository productservice --output table
```

### Task 6: Deploy Kubernetes Resources (15 minutes)

1. **Deploy the microservices to AKS**:
```bash
./deploy.sh deploy-k8s
```

2. **Monitor deployment progress**:
```bash
# Watch deployments
kubectl get deployments -n ecommerce-apps -w

# In another terminal, watch pods
kubectl get pods -n ecommerce-apps -w
```

3. **Verify all components are running**:
```bash
# Check deployments
kubectl get deployments -n ecommerce-apps

# Check services
kubectl get services -n ecommerce-apps

# Check ingress
kubectl get ingress -n ecommerce-apps
```

### Task 7: Configure Monitoring and Observability (10 minutes)

1. **Access Grafana dashboard**:
```bash
# Get Grafana URL
GRAFANA_URL=$(kubectl get service kube-prometheus-stack-grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Grafana URL: http://$GRAFANA_URL"

# Get admin password
kubectl get secret kube-prometheus-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
```

2. **Login to Grafana**:
   - Username: `admin`
   - Password: (from the command above)
   - Explore pre-configured dashboards

3. **View Application Insights**:
```bash
# Get Application Insights name
APP_INSIGHTS=$(terraform output -raw application_insights_key)

# Open Azure Portal
az portal --resource-group ecommerce-microservices-rg
```

Navigate to Application Insights → Live Metrics

### Task 8: Test the Deployment (10 minutes)

1. **Get the API Gateway endpoint**:
```bash
# Get external IP
EXTERNAL_IP=$(kubectl get service nginx-ingress-ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "API Gateway: http://$EXTERNAL_IP"
```

2. **Test the health endpoints**:
```bash
# Test API Gateway health
curl -f http://$EXTERNAL_IP/health || echo "Health check failed"

# Test product catalog
curl -f http://$EXTERNAL_IP/api/products || echo "Products API failed"
```

3. **Create a test order**:
```bash
# Create order
curl -X POST http://$EXTERNAL_IP/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test-user-001",
    "items": [{
      "productId": "prod-001",
      "quantity": 2,
      "price": 29.99
    }],
    "totalAmount": 59.98
  }'
```

## 🧪 Advanced Scenarios

### Scenario 1: Auto-Scaling Test (15 minutes)

1. **Generate load to trigger auto-scaling**:
```bash
# Install Apache Bench if not available
sudo apt-get update && sudo apt-get install -y apache2-utils

# Generate load on product catalog
ab -n 10000 -c 100 http://$EXTERNAL_IP/api/products
```

2. **Watch auto-scaling in action**:
```bash
# Watch HPA
kubectl get hpa -n ecommerce-apps -w

# Watch nodes
kubectl get nodes -w
```

3. **Monitor in Grafana**:
   - Navigate to Kubernetes / Compute Resources / Namespace
   - Select `ecommerce-apps` namespace
   - Observe CPU and memory usage

### Scenario 2: Failure Recovery (10 minutes)

1. **Simulate pod failure**:
```bash
# Delete a product catalog pod
kubectl delete pod -n ecommerce-apps -l app=product-catalog | head -1
```

2. **Observe recovery**:
```bash
# Watch pod recreation
kubectl get pods -n ecommerce-apps -l app=product-catalog -w
```

3. **Test during recovery**:
```bash
# Continuously test the API
while true; do
  curl -s -o /dev/null -w "%{http_code}\n" http://$EXTERNAL_IP/api/products
  sleep 1
done
```

### Scenario 3: Configuration Update (10 minutes)

1. **Update configuration**:
```bash
# Edit the product catalog configmap
kubectl edit configmap product-catalog-config -n ecommerce-apps
```

2. **Trigger rolling update**:
```bash
# Restart deployment to pick up new config
kubectl rollout restart deployment product-catalog -n ecommerce-apps

# Watch the rollout
kubectl rollout status deployment product-catalog -n ecommerce-apps
```

## 📊 Monitoring and Troubleshooting

### Check Resource Usage
```bash
# Node resource usage
kubectl top nodes

# Pod resource usage
kubectl top pods -n ecommerce-apps

# Detailed pod metrics
kubectl describe pod <pod-name> -n ecommerce-apps
```

### View Logs
```bash
# View logs for a specific service
kubectl logs -n ecommerce-apps -l app=product-catalog --tail=100

# Stream logs
kubectl logs -n ecommerce-apps -l app=api-gateway -f

# View logs from previous container (if crashed)
kubectl logs <pod-name> -n ecommerce-apps --previous
```

### Debug Connectivity Issues
```bash
# Test service connectivity from within cluster
kubectl run debug --image=nicolaka/netshoot -it --rm -- /bin/bash

# Inside the debug pod:
curl http://product-catalog.ecommerce-apps.svc.cluster.local/health
nslookup product-catalog.ecommerce-apps.svc.cluster.local
```

## 🎯 Success Criteria

### Basic Deployment (70%)
- [ ] All Terraform resources created successfully
- [ ] All microservices deployed and running
- [ ] Basic API calls working through gateway
- [ ] Monitoring dashboard accessible

### Advanced Features (90%)
- [ ] Auto-scaling working (HPA and cluster autoscaler)
- [ ] Pod recovery after failure verified
- [ ] Metrics visible in Grafana
- [ ] Application logs in Application Insights

### Production Ready (100%)
- [ ] TLS/SSL configured with cert-manager
- [ ] Network policies enforced
- [ ] Resource limits and requests optimized
- [ ] Backup and disaster recovery plan documented

## 🧹 Cleanup

When you're done experimenting:

```bash
# Destroy all resources
cd terraform
./deploy.sh destroy

# Confirm by typing 'yes' when prompted
# This will delete all resources and data!
```

## 📝 Reflection Questions

1. **Infrastructure as Code**: What are the benefits of using Terraform for infrastructure deployment?

2. **Kubernetes Orchestration**: How does Kubernetes help manage microservices at scale?

3. **Cost Optimization**: What strategies could you implement to reduce Azure costs while maintaining reliability?

4. **Security Considerations**: What additional security measures would you implement for a production deployment?

5. **Monitoring Strategy**: How would you set up alerts for critical issues in production?

## 🎓 Bonus Challenges

### Challenge 1: Implement CI/CD Pipeline
Create an Azure DevOps or GitHub Actions pipeline that:
- Builds Docker images on code push
- Runs tests
- Updates Kubernetes deployments
- Performs blue-green deployments

### Challenge 2: Add Service Mesh
Deploy Istio or Linkerd to add:
- Advanced traffic management
- Service-to-service encryption
- Distributed tracing
- Circuit breaking

### Challenge 3: Multi-Region Deployment
Extend the Terraform configuration to:
- Deploy across multiple Azure regions
- Implement geo-replication for databases
- Configure Traffic Manager for global load balancing

### Challenge 4: Cost Optimization
Implement cost-saving measures:
- Use Azure Spot instances for non-critical workloads
- Implement pod autoscaling based on custom metrics
- Configure scheduled scaling for predictable traffic patterns

## 🏆 Congratulations!

You've successfully deployed a production-grade microservices architecture on Azure using Terraform and Kubernetes! This exercise has given you hands-on experience with:

- **Infrastructure as Code** with Terraform
- **Container orchestration** with Kubernetes
- **Cloud-native services** on Azure
- **Production deployment** best practices
- **Monitoring and observability** setup

## ⏭️ Next Steps

1. **Security Hardening**: Implement Azure Policy, Pod Security Standards
2. **Advanced Networking**: Configure service mesh, private endpoints
3. **Disaster Recovery**: Implement backup strategies, test recovery procedures
4. **Performance Tuning**: Optimize resource allocation, implement caching

---

**💡 Pro Tip**: Keep this deployment running for a few days to understand the operational aspects, but remember to destroy resources when not needed to avoid unnecessary costs!