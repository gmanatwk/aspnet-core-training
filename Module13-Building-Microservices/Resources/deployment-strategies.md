# Deployment Strategies for Microservices (Continued)

```yaml
    - name: Build
      if: needs.detect-changes.outputs[matrix.service] == 'true'
      run: |
        case ${{ matrix.service }} in
          product-catalog)
            dotnet build src/ProductCatalog.Service/ProductCatalog.Service.csproj --no-restore --configuration Release
            ;;
          order-management)
            dotnet build src/OrderManagement.Service/OrderManagement.Service.csproj --no-restore --configuration Release
            ;;
          api-gateway)
            dotnet build src/ApiGateway/ApiGateway.csproj --no-restore --configuration Release
            ;;
        esac
    
    - name: Test
      if: needs.detect-changes.outputs[matrix.service] == 'true'
      run: |
        case ${{ matrix.service }} in
          product-catalog)
            dotnet test tests/ProductCatalog.Tests/ProductCatalog.Tests.csproj --no-build --configuration Release --verbosity normal --collect:"XPlat Code Coverage"
            ;;
          order-management)
            dotnet test tests/OrderManagement.Tests/OrderManagement.Tests.csproj --no-build --configuration Release --verbosity normal --collect:"XPlat Code Coverage"
            ;;
          api-gateway)
            dotnet test tests/ApiGateway.Tests/ApiGateway.Tests.csproj --no-build --configuration Release --verbosity normal --collect:"XPlat Code Coverage"
            ;;
        esac
    
    - name: Upload coverage reports
      if: needs.detect-changes.outputs[matrix.service] == 'true'
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
        flags: ${{ matrix.service }}

  security-scan:
    needs: [detect-changes, build-and-test]
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: [product-catalog, order-management, api-gateway]
    steps:
    - uses: actions/checkout@v4
    
    - name: Run Trivy vulnerability scanner
      if: needs.detect-changes.outputs[matrix.service] == 'true'
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: './src/${{ matrix.service }}'
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy scan results
      if: needs.detect-changes.outputs[matrix.service] == 'true'
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'

  build-docker-images:
    needs: [detect-changes, build-and-test, security-scan]
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: [product-catalog, order-management, api-gateway]
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Docker Buildx
      if: needs.detect-changes.outputs[matrix.service] == 'true'
      uses: docker/setup-buildx-action@v3
    
    - name: Log in to Container Registry
      if: needs.detect-changes.outputs[matrix.service] == 'true'
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      if: needs.detect-changes.outputs[matrix.service] == 'true'
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME_PREFIX }}/${{ matrix.service }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha,prefix={{branch}}-
          type=raw,value=latest,enable={{is_default_branch}}
    
    - name: Build and push Docker image
      if: needs.detect-changes.outputs[matrix.service] == 'true'
      uses: docker/build-push-action@v5
      with:
        context: .
        file: ./src/${{ matrix.service }}/Dockerfile
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
        platforms: linux/amd64,linux/arm64

  deploy-staging:
    needs: [detect-changes, build-docker-images]
    runs-on: ubuntu-latest
    environment: staging
    if: github.ref == 'refs/heads/main'
    strategy:
      matrix:
        service: [product-catalog, order-management, api-gateway]
    steps:
    - uses: actions/checkout@v4
    
    - name: Configure kubectl
      if: needs.detect-changes.outputs[matrix.service] == 'true'
      uses: azure/setup-kubectl@v3
      with:
        version: 'v1.28.0'
    
    - name: Set up kubeconfig
      if: needs.detect-changes.outputs[matrix.service] == 'true'
      run: |
        mkdir -p $HOME/.kube
        echo "${{ secrets.KUBE_CONFIG_STAGING }}" | base64 -d > $HOME/.kube/config
    
    - name: Deploy to staging
      if: needs.detect-changes.outputs[matrix.service] == 'true'
      run: |
        # Update image tag in Kubernetes manifests
        sed -i "s|image: .*/${{ matrix.service }}:.*|image: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME_PREFIX }}/${{ matrix.service }}:${{ github.sha }}|" \
          k8s/staging/${{ matrix.service }}/deployment.yaml
        
        kubectl apply -f k8s/staging/${{ matrix.service }}/
        kubectl rollout status deployment/${{ matrix.service }} -n ecommerce-staging --timeout=300s

  integration-tests:
    needs: [deploy-staging]
    runs-on: ubuntu-latest
    environment: staging
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v4
    
    - name: Run integration tests
      run: |
        # Wait for services to be ready
        sleep 30
        
        # Run comprehensive integration tests
        ./scripts/integration-tests.sh staging
        
        # Run performance tests
        ./scripts/performance-tests.sh staging
        
        # Run security tests
        ./scripts/security-tests.sh staging

  deploy-production:
    needs: [integration-tests]
    runs-on: ubuntu-latest
    environment: production
    if: github.ref == 'refs/heads/main'
    strategy:
      matrix:
        service: [product-catalog, order-management, api-gateway]
    steps:
    - uses: actions/checkout@v4
    
    - name: Configure kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'v1.28.0'
    
    - name: Set up kubeconfig
      run: |
        mkdir -p $HOME/.kube
        echo "${{ secrets.KUBE_CONFIG_PRODUCTION }}" | base64 -d > $HOME/.kube/config
    
    - name: Blue-Green Deployment
      run: |
        # Determine current active color
        CURRENT_COLOR=$(kubectl get service ${{ matrix.service }}-service -n ecommerce-production -o jsonpath='{.spec.selector.color}' 2>/dev/null || echo "blue")
        NEW_COLOR="green"
        if [ "$CURRENT_COLOR" = "green" ]; then
          NEW_COLOR="blue"
        fi
        
        echo "Deploying ${{ matrix.service }} to $NEW_COLOR environment"
        
        # Update deployment with new image and color
        sed -i "s|image: .*/${{ matrix.service }}:.*|image: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME_PREFIX }}/${{ matrix.service }}:${{ github.sha }}|" \
          k8s/production/${{ matrix.service }}/deployment-${NEW_COLOR}.yaml
        
        # Deploy to new color
        kubectl apply -f k8s/production/${{ matrix.service }}/deployment-${NEW_COLOR}.yaml
        kubectl rollout status deployment/${{ matrix.service }}-${NEW_COLOR} -n ecommerce-production --timeout=600s
        
        # Run smoke tests on new deployment
        ./scripts/smoke-tests.sh production $NEW_COLOR ${{ matrix.service }}
        
        # Switch service to new color
        kubectl patch service ${{ matrix.service }}-service -n ecommerce-production -p '{"spec":{"selector":{"color":"'$NEW_COLOR'"}}}'
        
        # Wait and monitor
        sleep 60
        
        # Run post-deployment verification
        ./scripts/verify-deployment.sh production ${{ matrix.service }}
        
        # Scale down old color
        kubectl scale deployment ${{ matrix.service }}-${CURRENT_COLOR} --replicas=0 -n ecommerce-production

  notify:
    needs: [deploy-production]
    runs-on: ubuntu-latest
    if: always()
    steps:
    - name: Notify Slack
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        channel: '#deployments'
        webhook_url: ${{ secrets.SLACK_WEBHOOK }}
        fields: repo,message,commit,author,action,eventName,ref,workflow
```

### Azure DevOps Pipeline

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
    - main
    - develop
  paths:
    include:
    - src/
    - k8s/
    - scripts/

variables:
  - group: ecommerce-variables
  - name: containerRegistry
    value: 'ecommerceregistry.azurecr.io'
  - name: imageRepository
    value: 'ecommerce'
  - name: dockerfilePath
    value: '$(Build.SourcesDirectory)/src'
  - name: tag
    value: '$(Build.BuildId)'
  - name: vmImageName
    value: 'ubuntu-latest'

stages:
- stage: Build
  displayName: Build and Test
  jobs:
  - job: DetectChanges
    displayName: Detect Changed Services
    pool:
      vmImage: $(vmImageName)
    steps:
    - script: |
        echo "##vso[task.setvariable variable=productCatalogChanged;isOutput=true]$(scripts/detect-changes.sh product-catalog)"
        echo "##vso[task.setvariable variable=orderManagementChanged;isOutput=true]$(scripts/detect-changes.sh order-management)"
        echo "##vso[task.setvariable variable=apiGatewayChanged;isOutput=true]$(scripts/detect-changes.sh api-gateway)"
      name: detectChanges
      displayName: 'Detect Service Changes'

  - job: BuildServices
    displayName: Build Changed Services
    dependsOn: DetectChanges
    pool:
      vmImage: $(vmImageName)
    strategy:
      matrix:
        ProductCatalog:
          serviceName: 'product-catalog'
          serviceChanged: $[ dependencies.DetectChanges.outputs['detectChanges.productCatalogChanged'] ]
        OrderManagement:
          serviceName: 'order-management'
          serviceChanged: $[ dependencies.DetectChanges.outputs['detectChanges.orderManagementChanged'] ]
        ApiGateway:
          serviceName: 'api-gateway'
          serviceChanged: $[ dependencies.DetectChanges.outputs['detectChanges.apiGatewayChanged'] ]
    condition: eq(variables.serviceChanged, 'true')
    steps:
    - task: UseDotNet@2
      displayName: 'Use .NET 8 SDK'
      inputs:
        packageType: 'sdk'
        version: '8.0.x'

    - task: DotNetCoreCLI@2
      displayName: 'Restore packages'
      inputs:
        command: 'restore'
        projects: 'src/**/*.csproj'

    - task: DotNetCoreCLI@2
      displayName: 'Build solution'
      inputs:
        command: 'build'
        projects: 'src/**/*.csproj'
        arguments: '--configuration Release --no-restore'

    - task: DotNetCoreCLI@2
      displayName: 'Run unit tests'
      inputs:
        command: 'test'
        projects: 'tests/**/*.Tests.csproj'
        arguments: '--configuration Release --no-build --collect:"XPlat Code Coverage" --logger trx --results-directory $(Agent.TempDirectory)'

    - task: PublishTestResults@2
      displayName: 'Publish test results'
      inputs:
        testResultsFormat: 'VSTest'
        testResultsFiles: '**/*.trx'
        searchFolder: '$(Agent.TempDirectory)'

    - task: PublishCodeCoverageResults@1
      displayName: 'Publish code coverage'
      inputs:
        codeCoverageTool: 'Cobertura'
        summaryFileLocation: '$(Agent.TempDirectory)/**/coverage.cobertura.xml'

- stage: SecurityScan
  displayName: Security Scanning
  dependsOn: Build
  jobs:
  - job: SecurityScan
    displayName: Run Security Scans
    pool:
      vmImage: $(vmImageName)
    steps:
    - task: WhiteSource@21
      displayName: 'WhiteSource Security Scan'
      inputs:
        cwd: '$(System.DefaultWorkingDirectory)'

    - task: CredScan@3
      displayName: 'Credential Scanner'

    - task: SdtReport@2
      displayName: 'Security Analysis Report'
      inputs:
        GdnExportAllTools: true

- stage: BuildImages
  displayName: Build Docker Images
  dependsOn: [Build, SecurityScan]
  jobs:
  - job: BuildDockerImages
    displayName: Build and Push Images
    pool:
      vmImage: $(vmImageName)
    strategy:
      matrix:
        ProductCatalog:
          serviceName: 'product-catalog'
        OrderManagement:
          serviceName: 'order-management'
        ApiGateway:
          serviceName: 'api-gateway'
    steps:
    - task: Docker@2
      displayName: 'Build and push image'
      inputs:
        containerRegistry: '$(containerRegistryServiceConnection)'
        repository: '$(imageRepository)/$(serviceName)'
        command: 'buildAndPush'
        Dockerfile: '$(dockerfilePath)/$(serviceName)/Dockerfile'
        tags: |
          $(tag)
          latest

- stage: DeployStaging
  displayName: Deploy to Staging
  dependsOn: BuildImages
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: DeployToStaging
    displayName: Deploy to Staging Environment
    pool:
      vmImage: $(vmImageName)
    environment: 'ecommerce-staging'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: KubectlInstaller@0
            displayName: 'Install kubectl'
            inputs:
              kubectlVersion: '1.28.0'

          - task: Kubernetes@1
            displayName: 'Deploy to staging'
            inputs:
              connectionType: 'kubernetesServiceConnection'
              kubernetesServiceConnection: 'staging-k8s-connection'
              namespace: 'ecommerce-staging'
              command: 'apply'
              arguments: '-f k8s/staging/'

          - task: Kubernetes@1
            displayName: 'Update image tags'
            inputs:
              connectionType: 'kubernetesServiceConnection'
              kubernetesServiceConnection: 'staging-k8s-connection'
              namespace: 'ecommerce-staging'
              command: 'set'
              arguments: 'image deployment/product-catalog product-catalog=$(containerRegistry)/$(imageRepository)/product-catalog:$(tag)'

- stage: IntegrationTests
  displayName: Integration Tests
  dependsOn: DeployStaging
  jobs:
  - job: RunIntegrationTests
    displayName: Run Integration Tests
    pool:
      vmImage: $(vmImageName)
    steps:
    - script: |
        chmod +x scripts/integration-tests.sh
        ./scripts/integration-tests.sh staging
      displayName: 'Run Integration Tests'

    - script: |
        chmod +x scripts/performance-tests.sh
        ./scripts/performance-tests.sh staging
      displayName: 'Run Performance Tests'

- stage: DeployProduction
  displayName: Deploy to Production
  dependsOn: IntegrationTests
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: DeployToProduction
    displayName: Deploy to Production Environment
    pool:
      vmImage: $(vmImageName)
    environment: 'ecommerce-production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: KubectlInstaller@0
            displayName: 'Install kubectl'
            inputs:
              kubectlVersion: '1.28.0'

          - script: |
              chmod +x scripts/blue-green-deploy.sh
              ./scripts/blue-green-deploy.sh production $(tag)
            displayName: 'Blue-Green Deployment'

          - script: |
              chmod +x scripts/verify-deployment.sh
              ./scripts/verify-deployment.sh production
            displayName: 'Verify Deployment'
```

## 🚀 Infrastructure as Code

### Terraform for AWS EKS

```hcl
# main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway = true
  enable_vpn_gateway = true
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Terraform = "true"
    Environment = var.environment
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# EKS Cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  
  cluster_name    = var.cluster_name
  cluster_version = "1.28"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
  
  eks_managed_node_groups = {
    main = {
      min_size     = 2
      max_size     = 10
      desired_size = 3
      
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      
      k8s_labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }
      
      update_config = {
        max_unavailable_percentage = 25
      }
    }
    
    spot = {
      min_size     = 0
      max_size     = 5
      desired_size = 2
      
      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "SPOT"
      
      k8s_labels = {
        Environment = var.environment
        NodeGroup   = "spot"
      }
      
      taints = [
        {
          key    = "spot"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }
  
  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# RDS Database
resource "aws_db_subnet_group" "main" {
  name       = "${var.cluster_name}-db-subnet-group"
  subnet_ids = module.vpc.private_subnets
  
  tags = {
    Name = "${var.cluster_name} DB subnet group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier = "${var.cluster_name}-postgres"
  
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"
  
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true
  
  db_name  = "ecommerce"
  username = "postgres"
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.cluster_name}-postgres-final-snapshot"
  
  tags = {
    Name = "${var.cluster_name}-postgres"
    Environment = var.environment
  }
}

# Security Groups
resource "aws_security_group" "rds" {
  name_prefix = "${var.cluster_name}-rds-"
  vpc_id      = module.vpc.vpc_id
  
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.cluster_name}-rds-sg"
  }
}

# ElastiCache Redis
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.cluster_name}-cache-subnet"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id         = "${var.cluster_name}-redis"
  description                  = "Redis cluster for ${var.cluster_name}"
  
  port                         = 6379
  parameter_group_name         = "default.redis7"
  node_type                    = "cache.t3.micro"
  num_cache_clusters           = 2
  
  subnet_group_name            = aws_elasticache_subnet_group.main.name
  security_group_ids           = [aws_security_group.redis.id]
  
  at_rest_encryption_enabled   = true
  transit_encryption_enabled   = true
  auth_token                   = var.redis_auth_token
  
  tags = {
    Name = "${var.cluster_name}-redis"
    Environment = var.environment
  }
}

resource "aws_security_group" "redis" {
  name_prefix = "${var.cluster_name}-redis-"
  vpc_id      = module.vpc.vpc_id
  
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  
  tags = {
    Name = "${var.cluster_name}-redis-sg"
  }
}

# Helm provider configuration
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# Install essential cluster components
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  
  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }
  
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  
  depends_on = [module.eks]
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  
  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.cluster_name
  }
  
  set {
    name  = "awsRegion"
    value = var.aws_region
  }
  
  depends_on = [module.eks]
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  
  depends_on = [module.eks]
}

# Monitoring stack
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true
  
  values = [
    file("${path.module}/values/prometheus-values.yaml")
  ]
  
  depends_on = [module.eks]
}
```

### Terraform Variables

```hcl
# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "ecommerce-cluster"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "db_password" {
  description = "Password for the RDS instance"
  type        = string
  sensitive   = true
}

variable "redis_auth_token" {
  description = "Auth token for Redis"
  type        = string
  sensitive   = true
}
```

### Terraform Outputs

```hcl
# outputs.tf
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "kubectl_config" {
  description = "kubectl config as generated by the module"
  value       = module.eks.kubeconfig
  sensitive   = true
}

output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "redis_endpoint" {
  description = "Redis cluster endpoint"
  value       = aws_elasticache_replication_group.redis.configuration_endpoint_address
}
```

## 📊 Monitoring Deployments

### Deployment Health Checks

```bash
#!/bin/bash
# scripts/verify-deployment.sh

ENVIRONMENT=$1
SERVICE_NAME=$2
NAMESPACE="ecommerce-${ENVIRONMENT}"

echo "Verifying deployment of ${SERVICE_NAME} in ${ENVIRONMENT}"

# Check deployment status
echo "Checking deployment rollout status..."
kubectl rollout status deployment/${SERVICE_NAME} -n ${NAMESPACE} --timeout=300s

if [ $? -ne 0 ]; then
    echo "Deployment rollout failed!"
    exit 1
fi

# Check pod readiness
echo "Checking pod readiness..."
READY_PODS=$(kubectl get pods -n ${NAMESPACE} -l app=${SERVICE_NAME} --field-selector=status.phase=Running -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | grep -o true | wc -l)
TOTAL_PODS=$(kubectl get pods -n ${NAMESPACE} -l app=${SERVICE_NAME} --field-selector=status.phase=Running -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | wc -w)

echo "Ready pods: ${READY_PODS}/${TOTAL_PODS}"

if [ ${READY_PODS} -ne ${TOTAL_PODS} ]; then
    echo "Not all pods are ready!"
    kubectl get pods -n ${NAMESPACE} -l app=${SERVICE_NAME}
    exit 1
fi

# Health check endpoint test
echo "Testing health check endpoint..."
SERVICE_IP=$(kubectl get service ${SERVICE_NAME}-service -n ${NAMESPACE} -o jsonpath='{.spec.clusterIP}')

for i in {1..10}; do
    if kubectl run test-pod --rm -i --tty --restart=Never --image=curlimages/curl -- curl -f http://${SERVICE_IP}/health; then
        echo "Health check passed"
        break
    else
        echo "Health check attempt ${i} failed, retrying..."
        sleep 5
    fi
    
    if [ ${i} -eq 10 ]; then
        echo "Health check failed after 10 attempts"
        exit 1
    fi
done

# Performance test
echo "Running basic performance test..."
kubectl run load-test --rm -i --tty --restart=Never --image=appropriate/curl -- \
    sh -c "for i in \$(seq 1 100); do curl -s http://${SERVICE_IP}/health > /dev/null; done && echo 'Performance test completed'"

echo "Deployment verification completed successfully!"
```

### Rollback Procedures

```bash
#!/bin/bash
# scripts/rollback-deployment.sh

ENVIRONMENT=$1
SERVICE_NAME=$2
NAMESPACE="ecommerce-${ENVIRONMENT}"

echo "Rolling back ${SERVICE_NAME} in ${ENVIRONMENT}"

# Get current revision
CURRENT_REVISION=$(kubectl rollout history deployment/${SERVICE_NAME} -n ${NAMESPACE} --revision=0 | tail -1 | awk '{print $1}')
PREVIOUS_REVISION=$((CURRENT_REVISION - 1))

echo "Current revision: ${CURRENT_REVISION}"
echo "Rolling back to revision: ${PREVIOUS_REVISION}"

# Perform rollback
kubectl rollout undo deployment/${SERVICE_NAME} -n ${NAMESPACE} --to-revision=${PREVIOUS_REVISION}

# Wait for rollback to complete
kubectl rollout status deployment/${SERVICE_NAME} -n ${NAMESPACE} --timeout=300s

if [ $? -eq 0 ]; then
    echo "Rollback completed successfully"
    
    # Verify rollback
    ./verify-deployment.sh ${ENVIRONMENT} ${SERVICE_NAME}
else
    echo "Rollback failed!"
    exit 1
fi
```

## 🎯 Best Practices Summary

### 1. Deployment Strategy Selection

**Use Blue-Green when:**
- Zero downtime is critical
- Quick rollback is required
- You have sufficient infrastructure capacity
- Database changes are backward compatible

**Use Canary when:**
- Gradual risk mitigation is important
- You want to test with real user traffic
- Performance impact needs to be monitored
- A/B testing is valuable

**Use Rolling when:**
- Resource constraints exist
- Gradual updates are acceptable
- Simple deployment process is preferred

### 2. Infrastructure Management

- **Use Infrastructure as Code** for all environments
- **Implement environment parity** to reduce deployment risks
- **Automate security scanning** in CI/CD pipelines
- **Monitor resource utilization** and costs

### 3. CI/CD Pipeline Best Practices

- **Run tests early and often** in the pipeline
- **Use feature flags** for safer deployments
- **Implement proper secret management**
- **Maintain deployment artifacts** for auditability

### 4. Monitoring and Observability

- **Implement comprehensive health checks**
- **Monitor business metrics** alongside technical metrics
- **Set up proper alerting** for deployment issues
- **Use distributed tracing** for debugging

### 5. Security Considerations

- **Scan images for vulnerabilities**
- **Use least privilege access** for service accounts
- **Implement network policies** in Kubernetes
- **Rotate secrets regularly**

---

*Successful microservices deployment requires careful planning, automation, and monitoring. Start with simple strategies and evolve as your system matures.*