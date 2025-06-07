#!/bin/bash

# Docker Swarm Deployment Script - Cloud Agnostic
# Can be deployed on any cloud provider or on-premises infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default values
REGISTRY="localhost:5000"
VERSION="latest"
ENVIRONMENT="production"

# Function to print colored output
print_color() {
    color=$1
    message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    print_color $YELLOW "Checking prerequisites..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        print_color $RED "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null; then
        print_color $RED "Docker Compose is not installed. Please install it first."
        exit 1
    fi
    
    print_color $GREEN "All prerequisites are installed."
}

# Function to initialize Docker Swarm
init_swarm() {
    print_color $YELLOW "Initializing Docker Swarm..."
    
    if docker info | grep -q "Swarm: active"; then
        print_color $GREEN "Docker Swarm is already initialized."
    else
        docker swarm init
        print_color $GREEN "Docker Swarm initialized successfully."
    fi
    
    # Get join token for workers
    WORKER_TOKEN=$(docker swarm join-token -q worker)
    MANAGER_IP=$(docker info --format "{{.Swarm.NodeAddr}}")
    
    print_color $YELLOW "To add worker nodes, run this command on other machines:"
    echo "docker swarm join --token $WORKER_TOKEN $MANAGER_IP:2377"
}

# Function to create Docker registry
create_registry() {
    print_color $YELLOW "Setting up local Docker registry..."
    
    # Check if registry is already running
    if docker service ls | grep -q registry; then
        print_color $GREEN "Registry is already running."
    else
        docker service create \
            --name registry \
            --publish published=5000,target=5000 \
            --mount type=volume,source=registry-data,target=/var/lib/registry \
            registry:2
        
        print_color $GREEN "Local registry created at localhost:5000"
    fi
}

# Function to build images
build_images() {
    print_color $YELLOW "Building microservice images..."
    
    cd SourceCode/ECommerceMS
    
    # Build each service
    services=("ApiGateway" "ProductService" "OrderService" "CustomerService")
    
    for service in "${services[@]}"; do
        if [ -d "$service" ]; then
            print_color $YELLOW "Building $service..."
            docker build -t ${REGISTRY}/${service,,}:${VERSION} -f $service/Dockerfile .
            
            # Push to registry
            print_color $YELLOW "Pushing $service to registry..."
            docker push ${REGISTRY}/${service,,}:${VERSION}
        fi
    done
    
    cd ../..
    print_color $GREEN "All images built and pushed successfully."
}

# Function to create Docker secrets
create_secrets() {
    print_color $YELLOW "Creating Docker secrets..."
    
    # Generate secure passwords if not provided
    DB_PASSWORD=${DB_PASSWORD:-$(openssl rand -base64 32)}
    RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD:-$(openssl rand -base64 32)}
    REDIS_PASSWORD=${REDIS_PASSWORD:-$(openssl rand -base64 32)}
    GRAFANA_PASSWORD=${GRAFANA_PASSWORD:-$(openssl rand -base64 32)}
    
    # Create secrets
    echo "$DB_PASSWORD" | docker secret create db_password -
    echo "$RABBITMQ_PASSWORD" | docker secret create rabbitmq_password -
    echo "$REDIS_PASSWORD" | docker secret create redis_password -
    echo "$GRAFANA_PASSWORD" | docker secret create grafana_password -
    
    # Save passwords for reference
    cat > .env.production <<EOF
DB_PASSWORD=$DB_PASSWORD
RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD
REDIS_PASSWORD=$REDIS_PASSWORD
GRAFANA_PASSWORD=$GRAFANA_PASSWORD
REGISTRY=$REGISTRY
VERSION=$VERSION
EOF
    
    print_color $GREEN "Secrets created and saved to .env.production"
}

# Function to create configs
create_configs() {
    print_color $YELLOW "Creating configuration files..."
    
    # Create nginx config
    mkdir -p nginx
    cat > nginx/nginx.conf <<'EOF'
events {
    worker_connections 1024;
}

http {
    upstream api_gateway {
        server api-gateway:80;
    }
    
    server {
        listen 80;
        
        location / {
            proxy_pass http://api_gateway;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }
}
EOF
    
    # Create Prometheus config
    mkdir -p monitoring
    cat > monitoring/prometheus.yml <<'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'api-gateway'
    dns_sd_configs:
      - names:
          - 'tasks.api-gateway'
        type: 'A'
        port: 80
    metrics_path: '/metrics'
    
  - job_name: 'product-catalog'
    dns_sd_configs:
      - names:
          - 'tasks.product-catalog'
        type: 'A'
        port: 80
    metrics_path: '/metrics'
    
  - job_name: 'order-management'
    dns_sd_configs:
      - names:
          - 'tasks.order-management'
        type: 'A'
        port: 80
    metrics_path: '/metrics'
EOF
    
    # Create database init script
    mkdir -p init-scripts
    cat > init-scripts/init-databases.sql <<'EOF'
CREATE DATABASE IF NOT EXISTS productcatalog;
CREATE DATABASE IF NOT EXISTS ordermanagement;
CREATE DATABASE IF NOT EXISTS usermanagement;
EOF
    
    print_color $GREEN "Configuration files created."
}

# Function to deploy stack
deploy_stack() {
    print_color $YELLOW "Deploying microservices stack..."
    
    # Load environment variables
    export $(cat .env.production | xargs)
    
    # Deploy the stack
    docker stack deploy -c docker-compose-production.yml ecommerce
    
    print_color $GREEN "Stack deployed successfully."
}

# Function to wait for services
wait_for_services() {
    print_color $YELLOW "Waiting for services to be ready..."
    
    # Wait for services to be running
    sleep 30
    
    # Check service status
    while true; do
        RUNNING=$(docker service ls --filter "label=com.docker.stack.namespace=ecommerce" --format "{{.Replicas}}" | grep -E "^[0-9]+/[0-9]+$" | wc -l)
        TOTAL=$(docker service ls --filter "label=com.docker.stack.namespace=ecommerce" | wc -l)
        
        if [ $RUNNING -eq $TOTAL ]; then
            break
        fi
        
        print_color $YELLOW "Waiting for services... ($RUNNING/$TOTAL ready)"
        sleep 10
    done
    
    print_color $GREEN "All services are running."
}

# Function to show status
show_status() {
    print_color $GREEN "=== Deployment Status ==="
    
    # Show services
    docker service ls --filter "label=com.docker.stack.namespace=ecommerce"
    
    # Show access URLs
    print_color $GREEN "\n=== Access URLs ==="
    echo "API Gateway: http://localhost"
    echo "RabbitMQ Management: http://localhost:15672"
    echo "Prometheus: http://localhost:9090"
    echo "Grafana: http://localhost:3000"
    
    # Show credentials
    print_color $GREEN "\n=== Credentials ==="
    source .env.production
    echo "Grafana Username: admin"
    echo "Grafana Password: $GRAFANA_PASSWORD"
    echo "RabbitMQ Username: guest"
    echo "RabbitMQ Password: $RABBITMQ_PASSWORD"
}

# Function to test deployment
test_deployment() {
    print_color $YELLOW "Testing deployment..."
    
    # Test API Gateway health
    curl -f http://localhost/health || { print_color $RED "API Gateway health check failed"; exit 1; }
    
    # Test product catalog
    curl -f http://localhost/api/products || { print_color $RED "Product catalog test failed"; exit 1; }
    
    print_color $GREEN "All tests passed!"
}

# Function to scale services
scale_service() {
    SERVICE=$1
    REPLICAS=$2
    
    print_color $YELLOW "Scaling $SERVICE to $REPLICAS replicas..."
    docker service scale ecommerce_${SERVICE}=${REPLICAS}
}

# Function to update service
update_service() {
    SERVICE=$1
    NEW_VERSION=$2
    
    print_color $YELLOW "Updating $SERVICE to version $NEW_VERSION..."
    docker service update \
        --image ${REGISTRY}/${SERVICE}:${NEW_VERSION} \
        --update-parallelism 1 \
        --update-delay 10s \
        ecommerce_${SERVICE}
}

# Function to cleanup
cleanup() {
    print_color $RED "Removing stack..."
    docker stack rm ecommerce
    
    print_color $YELLOW "Removing secrets..."
    docker secret rm db_password rabbitmq_password redis_password grafana_password 2>/dev/null || true
    
    print_color $YELLOW "Removing volumes..."
    docker volume prune -f
    
    print_color $GREEN "Cleanup completed."
}

# Main execution
main() {
    case "$1" in
        init)
            check_prerequisites
            init_swarm
            create_registry
            ;;
        build)
            build_images
            ;;
        deploy)
            create_secrets
            create_configs
            deploy_stack
            wait_for_services
            show_status
            ;;
        test)
            test_deployment
            ;;
        scale)
            scale_service $2 $3
            ;;
        update)
            update_service $2 $3
            ;;
        status)
            show_status
            ;;
        cleanup)
            cleanup
            ;;
        all)
            check_prerequisites
            init_swarm
            create_registry
            build_images
            create_secrets
            create_configs
            deploy_stack
            wait_for_services
            show_status
            test_deployment
            ;;
        *)
            echo "Usage: $0 {init|build|deploy|test|scale|update|status|cleanup|all}"
            echo ""
            echo "Commands:"
            echo "  init    - Initialize Docker Swarm and registry"
            echo "  build   - Build and push Docker images"
            echo "  deploy  - Deploy the microservices stack"
            echo "  test    - Test the deployment"
            echo "  scale   - Scale a service (e.g., scale product-catalog 5)"
            echo "  update  - Update a service (e.g., update product-catalog v2.0)"
            echo "  status  - Show deployment status"
            echo "  cleanup - Remove the entire stack"
            echo "  all     - Run complete deployment"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"