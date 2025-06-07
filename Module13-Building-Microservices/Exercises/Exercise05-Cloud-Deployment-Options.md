# Exercise 5: Cloud Deployment Options

## 🎯 Objective
Deploy the microservices architecture using various cloud and infrastructure options, understanding the trade-offs and benefits of each approach.

## ⏱️ Estimated Time
60-90 minutes (depending on chosen option)

## 📚 Prerequisites
- Completed Exercises 1-4
- Docker installed and configured
- Basic understanding of containers and orchestration

## 🔧 Deployment Options

You can choose from three deployment approaches based on your infrastructure and requirements:

### Option A: Azure Kubernetes Service (AKS) with Terraform
**Best for**: Azure users wanting fully managed Kubernetes with enterprise features

### Option B: Docker Swarm (Cloud-Agnostic)
**Best for**: Simple orchestration, works on any cloud or on-premises

### Option C: Generic Kubernetes (Multi-Cloud)
**Best for**: Flexibility to deploy on any Kubernetes cluster (EKS, GKE, AKS, on-premises)

---

## 🔵 Option A: Azure AKS with Terraform (Azure-Specific)

### Overview
Deploy to Azure Kubernetes Service using Infrastructure as Code with Terraform. This provides:
- Fully managed Kubernetes
- Azure-native integrations (Key Vault, Application Insights, etc.)
- Enterprise-grade security and compliance

### Prerequisites
- Azure subscription
- Azure CLI installed
- Terraform installed

### Quick Start
```bash
cd terraform
./deploy.sh all
```

### Key Features
- Automated infrastructure provisioning
- Integrated monitoring with Application Insights
- Managed database with Azure SQL
- Secrets management with Azure Key Vault

[Full instructions in Exercise05-Azure-Terraform-Deployment.md]

---

## 🟢 Option B: Docker Swarm Deployment (Cloud-Agnostic)

### Overview
Deploy using Docker Swarm mode, which provides simple orchestration that works anywhere Docker runs.

### Prerequisites
- Docker installed (with Swarm mode)
- Access to a Docker host or cloud VM

### Setup Docker Swarm

#### 1. Initialize Swarm Mode
```bash
# On your manager node
docker swarm init

# Save the join token for worker nodes
docker swarm join-token worker
```

#### 2. Deploy the Stack
```bash
# Make the deployment script executable
chmod +x deploy-docker-swarm.sh

# Run complete deployment
./deploy-docker-swarm.sh all
```

#### 3. Verify Deployment
```bash
# Check services
docker service ls

# Check service logs
docker service logs ecommerce_api-gateway

# Access the application
curl http://localhost/health
```

### Scaling Services
```bash
# Scale a specific service
./deploy-docker-swarm.sh scale product-catalog 5

# Update a service
./deploy-docker-swarm.sh update product-catalog v2.0
```

### Monitoring
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000
- RabbitMQ: http://localhost:15672

### Advantages
- Simple to set up and manage
- Works on any infrastructure
- Built-in load balancing
- Rolling updates
- No external dependencies

### Limitations
- Less sophisticated than Kubernetes
- Limited ecosystem
- Basic networking capabilities

---

## 🟡 Option C: Generic Kubernetes Deployment (Multi-Cloud)

### Overview
Deploy to any Kubernetes cluster using standard Kubernetes manifests. Works with:
- Google Kubernetes Engine (GKE)
- Amazon Elastic Kubernetes Service (EKS)
- Azure Kubernetes Service (AKS)
- On-premises Kubernetes
- Minikube/Kind (local development)

### Prerequisites
- Access to a Kubernetes cluster
- kubectl configured
- Container registry access

### Deployment Steps

#### 1. Prepare Your Cluster
```bash
# Create namespace
kubectl create namespace ecommerce

# Verify cluster access
kubectl cluster-info
kubectl get nodes
```

#### 2. Update Container Registry
Edit `kubernetes-generic/kustomization.yaml`:
```yaml
images:
  - name: product-catalog
    newName: your-registry/product-catalog  # Update this
    newTag: latest
```

#### 3. Deploy Infrastructure
```bash
cd kubernetes-generic

# Deploy databases and messaging
kubectl apply -f infrastructure/ -n ecommerce

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=postgres -n ecommerce --timeout=300s
```

#### 4. Deploy Microservices
```bash
# Apply all manifests using kustomize
kubectl apply -k . -n ecommerce

# Watch deployment progress
kubectl get pods -n ecommerce -w
```

#### 5. Access Services
```bash
# Get API Gateway endpoint
kubectl get service api-gateway -n ecommerce

# For local access (if LoadBalancer not available)
kubectl port-forward service/api-gateway 8080:80 -n ecommerce
```

### Cloud-Specific Adaptations

#### For AWS EKS
```bash
# Install AWS Load Balancer Controller
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

# Use EBS CSI Driver for storage
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
```

#### For Google GKE
```bash
# Enable Workload Identity
gcloud container clusters update CLUSTER_NAME \
    --workload-pool=PROJECT_ID.svc.id.goog

# Use GCE persistent disks
# (Automatically available in GKE)
```

#### For On-Premises/Bare Metal
```bash
# Install MetalLB for load balancing
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

# Configure IP address pool for MetalLB
```

### Monitoring Setup
```bash
# Deploy Prometheus and Grafana
kubectl apply -f monitoring/ -n ecommerce

# Access Grafana
kubectl port-forward service/grafana 3000:3000 -n ecommerce
```

---

## 📊 Comparing Deployment Options

| Feature | Azure AKS (Terraform) | Docker Swarm | Generic Kubernetes |
|---------|----------------------|--------------|-------------------|
| **Complexity** | Medium-High | Low | Medium |
| **Setup Time** | 30-45 min | 15-20 min | 20-30 min |
| **Cloud Lock-in** | High (Azure) | None | None |
| **Scalability** | Excellent | Good | Excellent |
| **Monitoring** | Native (App Insights) | Basic | Flexible |
| **Cost** | $$$ | $ | $-$$$ |
| **Learning Curve** | Steep | Gentle | Moderate |
| **Production Ready** | Yes | Yes (small-medium) | Yes |
| **GitOps Support** | Excellent | Limited | Excellent |

---

## 🧪 Testing Your Deployment

Regardless of which option you choose, test with these commands:

### 1. Health Checks
```bash
# API Gateway health
curl http://<ENDPOINT>/health

# Individual service health
curl http://<ENDPOINT>/api/products/health
```

### 2. Create Test Data
```bash
# Add a product
curl -X POST http://<ENDPOINT>/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Product",
    "price": 29.99,
    "category": "Electronics"
  }'

# Create an order
curl -X POST http://<ENDPOINT>/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user123",
    "items": [{
      "productId": "prod123",
      "quantity": 2
    }]
  }'
```

### 3. Load Testing
```bash
# Simple load test with curl
for i in {1..100}; do
  curl -s http://<ENDPOINT>/api/products &
done
wait

# Or use Apache Bench
ab -n 1000 -c 10 http://<ENDPOINT>/api/products
```

---

## 🎯 Success Criteria

### All Deployment Options
- [ ] All services deployed and healthy
- [ ] Inter-service communication working
- [ ] Data persistence verified
- [ ] Monitoring accessible
- [ ] Can handle basic load

### Option-Specific
#### Azure AKS
- [ ] Terraform state managed
- [ ] Azure resources tagged properly
- [ ] Key Vault integration working

#### Docker Swarm
- [ ] Swarm cluster initialized
- [ ] Services distributed across nodes
- [ ] Volumes persisted correctly

#### Generic Kubernetes
- [ ] Works on chosen platform
- [ ] Ingress configured correctly
- [ ] Persistent volumes bound

---

## 🧹 Cleanup

### Option A: Azure AKS
```bash
cd terraform
./deploy.sh destroy
```

### Option B: Docker Swarm
```bash
./deploy-docker-swarm.sh cleanup
```

### Option C: Generic Kubernetes
```bash
kubectl delete namespace ecommerce
```

---

## 📝 Reflection Questions

1. **Infrastructure as Code**: What are the benefits and challenges of using Terraform vs. imperative scripts?

2. **Orchestration Comparison**: How does Docker Swarm compare to Kubernetes for your use case?

3. **Cloud Portability**: What changes would be needed to move between cloud providers?

4. **Production Considerations**: What additional features would you add for production deployment?

5. **Cost Optimization**: How would you optimize costs for each deployment option?

---

## 🎓 Bonus Challenges

### Challenge 1: Multi-Region Deployment
Extend your chosen deployment to span multiple regions with:
- Cross-region replication
- Geo-distributed load balancing
- Data consistency strategies

### Challenge 2: GitOps Implementation
Implement GitOps workflow using:
- ArgoCD or Flux for Kubernetes
- GitHub Actions for automation
- Environment promotion strategies

### Challenge 3: Service Mesh
Add a service mesh layer:
- Istio or Linkerd for Kubernetes
- mTLS between services
- Advanced traffic management

### Challenge 4: Hybrid Deployment
Combine deployment strategies:
- Some services in Kubernetes
- Others in serverless functions
- Legacy services in VMs

---

## 🏆 Congratulations!

You've successfully deployed microservices using multiple approaches! You now understand:
- Different deployment strategies and their trade-offs
- Cloud-specific vs. cloud-agnostic approaches
- Container orchestration options
- Production deployment considerations

## ⏭️ Next Steps

Based on your deployment choice:
- **Azure users**: Explore Azure Service Fabric or Azure Container Apps
- **AWS users**: Try Amazon ECS or AWS App Runner
- **Multi-cloud**: Implement Anthos or Azure Arc for hybrid management
- **On-premises**: Explore Rancher or OpenShift for enterprise features

---

**💡 Pro Tip**: The best deployment option depends on your specific requirements, team skills, and infrastructure constraints. Start simple and evolve as needed!