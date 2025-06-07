# E-Commerce Microservices - Azure Terraform Deployment

## 🚀 Overview

This directory contains Infrastructure as Code (IaC) using Terraform to deploy a complete microservices architecture on Azure Kubernetes Service (AKS). The deployment includes:

- **Azure Kubernetes Service (AKS)** - Managed Kubernetes cluster
- **Azure Container Registry (ACR)** - Private Docker registry
- **Azure SQL Database** - Managed SQL databases for each microservice
- **Azure Service Bus** - Message broker for async communication
- **Azure Key Vault** - Secrets management
- **Application Insights** - Monitoring and observability
- **Azure Virtual Network** - Network isolation and security

## 📋 Prerequisites

### Required Tools
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (v2.40+)
- [Terraform](https://www.terraform.io/downloads) (v1.3+)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (v1.28+)
- [Helm](https://helm.sh/docs/intro/install/) (v3.10+)
- [Docker](https://docs.docker.com/get-docker/) (v20+)

### Azure Requirements
- Active Azure subscription
- Sufficient quota for:
  - AKS nodes (minimum 5 vCPUs)
  - Public IPs (minimum 2)
  - Storage accounts
  - SQL databases

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet                              │
└──────────────────────────┬──────────────────────────────────┘
                           │
                    ┌──────▼────────┐
                    │ Load Balancer │
                    └──────┬────────┘
                           │
                    ┌──────▼────────┐
                    │ NGINX Ingress │
                    └──────┬────────┘
                           │
                    ┌──────▼────────┐
                    │  API Gateway  │
                    └──────┬────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
┌───────▼────────┐ ┌──────▼────────┐ ┌──────▼────────┐
│Product Catalog │ │Order Service  │ │User Service   │
└───────┬────────┘ └──────┬────────┘ └──────┬────────┘
        │                  │                  │
        └──────────────────┼──────────────────┘
                           │
                    ┌──────▼────────┐
                    │  Service Bus  │
                    └───────────────┘
```

## 🚀 Quick Start

### 1. Clone and Navigate
```bash
git clone <repository>
cd Module13-Building-Microservices/terraform
```

### 2. Configure Variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Run Complete Deployment
```bash
chmod +x deploy.sh
./deploy.sh all
```

## 📝 Deployment Steps

### Step 1: Initialize Terraform
```bash
./deploy.sh init
```
This will:
- Check prerequisites
- Login to Azure
- Create Terraform state storage
- Initialize Terraform providers

### Step 2: Plan Infrastructure
```bash
./deploy.sh plan
```
This will:
- Validate Terraform configuration
- Create execution plan
- Show resources to be created

### Step 3: Apply Infrastructure
```bash
./deploy.sh apply
```
This will:
- Create all Azure resources
- Configure AKS cluster
- Setup networking and security

### Step 4: Build and Push Images
```bash
./deploy.sh build-images
```
This will:
- Build Docker images for all microservices
- Push images to Azure Container Registry

### Step 5: Deploy Kubernetes Resources
```bash
./deploy.sh deploy-k8s
```
This will:
- Deploy all Kubernetes manifests
- Configure ingress and services
- Setup monitoring with Prometheus/Grafana

### Step 6: Check Status
```bash
./deploy.sh status
```
This will show:
- Resource group details
- AKS cluster information
- Service endpoints
- Monitoring URLs

## 🔧 Configuration

### Terraform Variables

Key variables in `terraform.tfvars`:

```hcl
# Azure Configuration
subscription_id = "your-subscription-id"
tenant_id       = "your-tenant-id"

# Resource Configuration
resource_group_name = "ecommerce-microservices-rg"
location            = "East US"
environment         = "production"

# AKS Configuration
kubernetes_version  = "1.28.3"
enable_auto_scaling = true

# Microservices Configuration
microservices = {
  product-catalog = {
    replicas = 3
    cpu_limit = "500m"
    memory_limit = "512Mi"
  }
  # ... other services
}
```

### Environment-Specific Configurations

The deployment supports multiple environments:
- **Development**: Minimal resources, reduced costs
- **Staging**: Production-like with fewer replicas
- **Production**: Full scale with high availability

## 📊 Monitoring and Observability

### Grafana Dashboard
After deployment, access Grafana:
```bash
# Get Grafana URL
kubectl get service kube-prometheus-stack-grafana -n monitoring

# Get admin password
kubectl get secret kube-prometheus-stack-grafana -n monitoring \
  -o jsonpath="{.data.admin-password}" | base64 --decode
```

### Application Insights
View application metrics and logs in Azure Portal:
1. Navigate to your resource group
2. Open Application Insights resource
3. View Live Metrics, Failures, Performance

### Health Checks
Each service exposes health endpoints:
- `/health/live` - Liveness check
- `/health/ready` - Readiness check
- `/health/startup` - Startup check

## 🔒 Security Features

### Network Security
- Private AKS cluster option available
- Network policies for pod-to-pod communication
- Azure Firewall integration ready

### Identity and Access
- Managed Identity for AKS
- Azure AD integration for RBAC
- Workload Identity for pod-level access

### Secrets Management
- Azure Key Vault for sensitive data
- Kubernetes Secret Store CSI Driver
- Automatic secret rotation support

## 🧹 Cleanup

To destroy all resources:
```bash
./deploy.sh destroy
```

**WARNING**: This will delete all resources including data!

## 🐛 Troubleshooting

### Common Issues

#### 1. Insufficient Quota
```bash
# Check current quota
az vm list-usage --location "East US" -o table

# Request quota increase through Azure Portal
```

#### 2. AKS Node Issues
```bash
# Check node status
kubectl get nodes

# Describe problematic node
kubectl describe node <node-name>

# Check AKS cluster health
az aks show --name <aks-name> --resource-group <rg-name> --query powerState
```

#### 3. Pod Failures
```bash
# Check pod status
kubectl get pods -n ecommerce-apps

# View pod logs
kubectl logs <pod-name> -n ecommerce-apps

# Describe pod for events
kubectl describe pod <pod-name> -n ecommerce-apps
```

### Debug Mode
Enable debug output:
```bash
export TF_LOG=DEBUG
./deploy.sh plan
```

## 📚 Additional Resources

### Terraform Documentation
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

### Azure Documentation
- [AKS Best Practices](https://docs.microsoft.com/en-us/azure/aks/best-practices)
- [Azure Architecture Center](https://docs.microsoft.com/en-us/azure/architecture/)

### Kubernetes Documentation
- [Kubernetes Patterns](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/)
- [Microservices on K8s](https://kubernetes.io/docs/concepts/services-networking/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 💡 Tips and Best Practices

### Cost Optimization
- Use spot instances for non-critical workloads
- Enable cluster autoscaler
- Right-size your nodes
- Use Azure Reservations for long-term savings

### Performance
- Enable Azure CNI for better networking performance
- Use Premium SSD for database storage
- Implement caching with Redis
- Use horizontal pod autoscaling

### Reliability
- Deploy across availability zones
- Implement pod disruption budgets
- Use liveness and readiness probes
- Configure resource limits and requests

### Security
- Enable Azure Policy for AKS
- Implement network policies
- Use private endpoints for PaaS services
- Regular security scanning of images

---

**Need Help?** Open an issue in the repository or contact the DevOps team.