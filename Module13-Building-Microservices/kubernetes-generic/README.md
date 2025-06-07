# Cloud-Agnostic Kubernetes Deployment

This directory contains Kubernetes manifests that can be deployed on any Kubernetes cluster, regardless of the cloud provider:
- Google Kubernetes Engine (GKE)
- Amazon Elastic Kubernetes Service (EKS)
- Azure Kubernetes Service (AKS)
- On-premises Kubernetes
- Minikube/Kind for local development

## 📋 Prerequisites

1. **Kubernetes Cluster**: Access to a Kubernetes cluster (1.20+)
2. **kubectl**: Kubernetes CLI tool configured to access your cluster
3. **Container Registry**: Access to a container registry (Docker Hub, ECR, GCR, ACR, etc.)

## 🚀 Quick Start

### 1. Update Registry Configuration
Edit `kustomization.yaml` to point to your container registry:

```yaml
images:
  - name: product-catalog
    newName: your-registry/product-catalog
    newTag: latest
```

### 2. Create Namespace
```bash
kubectl create namespace ecommerce
```

### 3. Deploy Infrastructure Components
```bash
# Deploy PostgreSQL
kubectl apply -f infrastructure/postgres.yaml -n ecommerce

# Deploy RabbitMQ
kubectl apply -f infrastructure/rabbitmq.yaml -n ecommerce

# Deploy Redis
kubectl apply -f infrastructure/redis.yaml -n ecommerce
```

### 4. Deploy Microservices
```bash
# Apply all manifests using kustomize
kubectl apply -k . -n ecommerce
```

### 5. Access Services
```bash
# Get the LoadBalancer IP (if supported by your cluster)
kubectl get service api-gateway -n ecommerce

# Or use port-forward for local access
kubectl port-forward service/api-gateway 8080:80 -n ecommerce
```

## 📁 Directory Structure

```
kubernetes-generic/
├── kustomization.yaml          # Kustomize configuration
├── infrastructure/             # Infrastructure services
│   ├── postgres.yaml          # PostgreSQL database
│   ├── rabbitmq.yaml          # RabbitMQ message broker
│   └── redis.yaml             # Redis cache
├── services/                   # Microservices
│   ├── product-catalog.yaml
│   ├── order-management.yaml
│   ├── user-management.yaml
│   ├── notification-service.yaml
│   └── api-gateway.yaml
├── monitoring/                 # Monitoring stack
│   ├── prometheus.yaml
│   └── grafana.yaml
└── ingress/                   # Ingress configuration
    └── ingress.yaml
```

## 🔧 Configuration Options

### Using ConfigMaps for Configuration
```bash
# Create configmap from file
kubectl create configmap app-config \
  --from-file=appsettings.json \
  -n ecommerce
```

### Using Secrets for Sensitive Data
```bash
# Create secrets
kubectl create secret generic db-credentials \
  --from-literal=username=postgres \
  --from-literal=password=your-password \
  -n ecommerce
```

### Scaling Services
```bash
# Scale a deployment
kubectl scale deployment product-catalog --replicas=5 -n ecommerce

# Enable autoscaling
kubectl autoscale deployment product-catalog \
  --min=2 --max=10 --cpu-percent=80 \
  -n ecommerce
```

## 🌐 Cloud-Specific Adaptations

### For AWS EKS
- Use AWS Load Balancer Controller for ingress
- Configure IRSA for pod-level AWS access
- Use EBS CSI driver for persistent volumes

### For Google GKE
- Use GCE persistent disks
- Configure Workload Identity for GCP access
- Use Google Cloud Load Balancer

### For Azure AKS
- Use Azure Disk for persistent volumes
- Configure Pod Identity for Azure access
- Use Azure Load Balancer

### For On-Premises
- Use MetalLB for load balancing
- Configure NFS or local storage for persistence
- Use cert-manager for TLS certificates

## 📊 Monitoring

Deploy the monitoring stack:
```bash
kubectl apply -f monitoring/ -n ecommerce
```

Access Grafana:
```bash
kubectl port-forward service/grafana 3000:3000 -n ecommerce
```

## 🔒 Security Considerations

1. **Network Policies**: Apply network policies to restrict traffic
2. **RBAC**: Configure proper role-based access control
3. **Secrets Management**: Use external secret stores when possible
4. **Pod Security**: Apply security contexts and policies

## 🧹 Cleanup

Remove all resources:
```bash
kubectl delete namespace ecommerce
```

## 💡 Tips

- Use `kubectl diff` to preview changes before applying
- Enable resource quotas to prevent resource exhaustion
- Implement proper health checks and readiness probes
- Use init containers for database migrations
- Consider using Helm for more complex deployments