#!/bin/bash

# Module 13: Building Microservices - Interactive Exercise Launcher
# This script provides guided, hands-on exercises for microservices architecture and implementation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="ECommerceMS"
INTERACTIVE_MODE=true
SKIP_PROJECT_CREATION=false

# Function to display colored output
echo_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
echo_success() { echo -e "${GREEN}✅ $1${NC}"; }
echo_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
echo_error() { echo -e "${RED}❌ $1${NC}"; }

# Function to pause for user interaction
pause_for_user() {
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -n "Press Enter to continue..."
        read -r
        echo ""
    fi
}

# Function to explain concepts interactively
explain_concept() {
    local concept=$1
    local explanation=$2
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}🏗️ MICROSERVICES CONCEPT: $concept${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}$explanation${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    pause_for_user
}

# Function to show learning objectives
show_learning_objectives() {
    local exercise=$1
    
    echo -e "${BLUE}🎯 Microservices Learning Objectives for $exercise:${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${CYAN}Service Decomposition & Domain-Driven Design:${NC}"
            echo "  🏗️  1. Analyze monolithic applications for service boundaries"
            echo "  🏗️  2. Apply Domain-Driven Design (DDD) principles"
            echo "  🏗️  3. Identify bounded contexts and aggregates"
            echo "  🏗️  4. Design data consistency strategies"
            echo ""
            echo -e "${YELLOW}Microservices concepts:${NC}"
            echo "  • Service decomposition strategies"
            echo "  • Bounded context identification"
            echo "  • Data ownership patterns"
            echo "  • Saga pattern design"
            ;;
        "exercise02")
            echo -e "${CYAN}Building Core Microservices:${NC}"
            echo "  🏗️  1. Create independent ASP.NET Core services"
            echo "  🏗️  2. Implement service-specific databases"
            echo "  🏗️  3. Design RESTful APIs for inter-service communication"
            echo "  🏗️  4. Set up shared libraries and common patterns"
            echo ""
            echo -e "${YELLOW}Microservices concepts:${NC}"
            echo "  • Service independence and autonomy"
            echo "  • Database per service pattern"
            echo "  • API contract design"
            echo "  • Shared library management"
            ;;
        "exercise03")
            echo -e "${CYAN}Inter-Service Communication Patterns:${NC}"
            echo "  🏗️  1. Implement synchronous HTTP communication"
            echo "  🏗️  2. Add asynchronous messaging with RabbitMQ"
            echo "  🏗️  3. Handle distributed data consistency"
            echo "  🏗️  4. Implement event-driven architecture"
            echo ""
            echo -e "${YELLOW}Microservices concepts:${NC}"
            echo "  • Synchronous vs asynchronous communication"
            echo "  • Message broker integration"
            echo "  • Event sourcing patterns"
            echo "  • Distributed transaction management"
            ;;
        "exercise04")
            echo -e "${CYAN}Production-Ready Deployment:${NC}"
            echo "  🏗️  1. Containerize microservices with Docker"
            echo "  🏗️  2. Orchestrate services with Docker Compose"
            echo "  🏗️  3. Implement monitoring and observability"
            echo "  🏗️  4. Add resilience patterns (Circuit Breaker, Retry)"
            echo ""
            echo -e "${YELLOW}Microservices concepts:${NC}"
            echo "  • Container orchestration"
            echo "  • Service discovery and load balancing"
            echo "  • Distributed tracing and monitoring"
            echo "  • Fault tolerance and resilience"
            ;;
        "exercise05")
            echo -e "${CYAN}Cloud Deployment Options:${NC}"
            echo "  🏗️  1. Deploy to Azure Kubernetes Service (AKS)"
            echo "  🏗️  2. Use Terraform for Infrastructure as Code"
            echo "  🏗️  3. Configure production monitoring and scaling"
            echo "  🏗️  4. Implement CI/CD pipelines"
            echo ""
            echo -e "${YELLOW}Microservices concepts:${NC}"
            echo "  • Cloud-native deployment strategies"
            echo "  • Infrastructure as Code (IaC)"
            echo "  • Auto-scaling and load management"
            echo "  • Production monitoring and alerting"
            ;;
    esac
    echo ""
}

# Function to show what will be created
show_creation_overview() {
    local exercise=$1
    
    echo -e "${CYAN}📋 Microservices Components for $exercise:${NC}"
    
    case $exercise in
        "exercise01")
            echo "• Domain analysis templates and worksheets"
            echo "• Service boundary design documents"
            echo "• Data consistency strategy guides"
            echo "• Technology stack decision templates"
            echo "• Service architecture diagrams"
            ;;
        "exercise02")
            echo "• Product Catalog microservice"
            echo "• Order Management microservice"
            echo "• User Management microservice"
            echo "• Shared libraries and common models"
            echo "• API Gateway foundation"
            ;;
        "exercise03")
            echo "• HTTP client communication patterns"
            echo "• RabbitMQ message broker integration"
            echo "• Event-driven communication examples"
            echo "• Distributed transaction handling"
            echo "• Saga pattern implementations"
            ;;
        "exercise04")
            echo "• Docker containerization for all services"
            echo "• Docker Compose orchestration"
            echo "• Application Insights monitoring"
            echo "• Health checks and diagnostics"
            echo "• Circuit breaker and retry patterns"
            ;;
        "exercise05")
            echo "• Azure AKS deployment with Terraform"
            echo "• Generic Kubernetes manifests"
            echo "• Docker Swarm deployment option"
            echo "• Production monitoring dashboards"
            echo "• CI/CD pipeline configurations"
            ;;
    esac
    echo ""
}

# Function to create files interactively
create_file_interactive() {
    local file_path=$1
    local content=$2
    local description=$3
    
    if [ "$PREVIEW_ONLY" = true ]; then
        echo -e "${CYAN}📄 Would create: $file_path${NC}"
        echo -e "${YELLOW}   Description: $description${NC}"
        return
    fi
    
    echo -e "${CYAN}📄 Creating: $file_path${NC}"
    echo -e "${YELLOW}   $description${NC}"
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$file_path")"
    
    # Write content to file
    echo "$content" > "$file_path"
    
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -n "   File created. Press Enter to continue..."
        read -r
    fi
    echo ""
}

# Function to show available exercises
show_exercises() {
    echo -e "${CYAN}Module 13 - Building Microservices${NC}"
    echo -e "${CYAN}Available Exercises:${NC}"
    echo ""
    echo "  - exercise01: Service Decomposition & Domain-Driven Design"
    echo "  - exercise02: Building Core Microservices"
    echo "  - exercise03: Inter-Service Communication Patterns"
    echo "  - exercise04: Production-Ready Deployment"
    echo "  - exercise05: Cloud Deployment Options"
    echo ""
    echo "Usage:"
    echo "  ./launch-exercises.sh <exercise-name> [options]"
    echo ""
    echo "Options:"
    echo "  --list          Show all available exercises"
    echo "  --auto          Skip interactive mode"
    echo "  --preview       Show what will be created without creating"
}

# Main script starts here
if [ $# -eq 0 ]; then
    echo_error "Usage: $0 <exercise-name> [options]"
    echo ""
    show_exercises
    exit 1
fi

# Handle --list option
if [ "$1" == "--list" ]; then
    show_exercises
    exit 0
fi

EXERCISE_NAME=$1
PREVIEW_ONLY=false

# Parse options
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            INTERACTIVE_MODE=false
            shift
            ;;
        --preview)
            PREVIEW_ONLY=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Validate exercise name
case $EXERCISE_NAME in
    "exercise01"|"exercise02"|"exercise03"|"exercise04"|"exercise05")
        ;;
    *)
        echo_error "Unknown exercise: $EXERCISE_NAME"
        echo ""
        show_exercises
        exit 1
        ;;
esac

# Welcome message
echo -e "${MAGENTA}🏗️ Module 13: Building Microservices${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show learning objectives
show_learning_objectives $EXERCISE_NAME

# Show what will be created
show_creation_overview $EXERCISE_NAME

if [ "$PREVIEW_ONLY" = true ]; then
    echo_info "Preview mode - no files will be created"
    echo ""
fi

# Check prerequisites
echo_info "Checking microservices prerequisites..."

# Check .NET SDK
if ! command -v dotnet &> /dev/null; then
    echo_error ".NET SDK is not installed. Please install .NET 8.0 SDK."
    exit 1
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo_warning "Docker is not installed. Some exercises may require it."
fi

echo_success "Prerequisites check completed"
echo ""

# Check if project exists in current directory
if [ -d "$PROJECT_NAME" ]; then
    if [[ $EXERCISE_NAME == "exercise02" ]] || [[ $EXERCISE_NAME == "exercise03" ]] || [[ $EXERCISE_NAME == "exercise04" ]] || [[ $EXERCISE_NAME == "exercise05" ]]; then
        echo_success "Found existing $PROJECT_NAME from previous exercise"
        echo_info "This exercise will build on your existing work"
        cd "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=true
    else
        echo_warning "Project '$PROJECT_NAME' already exists!"
        echo -n "Do you want to overwrite it? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            exit 1
        fi
        rm -rf "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=false
    fi
else
    SKIP_PROJECT_CREATION=false
fi

# Exercise implementations
if [[ $EXERCISE_NAME == "exercise01" ]]; then
    # Exercise 1: Service Decomposition & Domain-Driven Design

    explain_concept "Domain-Driven Design for Microservices" \
"Domain-Driven Design (DDD) for Microservices:
• Bounded Contexts: Define clear boundaries around business domains
• Ubiquitous Language: Shared vocabulary within each context
• Aggregates: Consistency boundaries for data operations
• Domain Events: Communication between bounded contexts
• Service Boundaries: Each microservice owns a bounded context"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_info "Creating microservices design workspace..."
        mkdir -p "$PROJECT_NAME"
        cd "$PROJECT_NAME"
        mkdir -p docs analysis design
    fi

    # Create domain analysis template
    create_file_interactive "docs/domain-analysis.md" \
'# E-Commerce Domain Analysis

## Business Capabilities Analysis

### 1. User Management
- **Purpose**: Manage user accounts, authentication, and personal data
- **Key Entities**: User, Profile, Authentication, Preferences, Role
- **Business Rules**:
  - Unique email addresses required
  - Password complexity requirements
  - Data privacy compliance (GDPR)
  - Role-based access control
- **External Dependencies**: Email service, OAuth providers, identity verification

### 2. Product Catalog
- **Purpose**: Manage product information, categories, and inventory
- **Key Entities**: Product, Category, Inventory, SKU, Pricing
- **Business Rules**:
  - Unique SKU per product
  - Category hierarchy management
  - Inventory tracking and alerts
  - Price history and promotions
- **External Dependencies**: Image storage, search indexing, supplier systems

### 3. Shopping Cart
- **Purpose**: Manage customer shopping sessions and cart items
- **Key Entities**: Cart, CartItem, Session, WishList
- **Business Rules**:
  - Cart expiration policies
  - Inventory reservation during checkout
  - Guest vs authenticated cart handling
  - Cart merging on login
- **External Dependencies**: Product catalog, user management

### 4. Order Processing
- **Purpose**: Handle order creation, payment, and fulfillment
- **Key Entities**: Order, OrderItem, Payment, Invoice, Fulfillment
- **Business Rules**:
  - Order state transitions
  - Payment processing workflows
  - Inventory allocation and reservation
  - Order cancellation policies
- **External Dependencies**: Payment gateways, shipping providers, inventory

### 5. Inventory Management
- **Purpose**: Track stock levels, reservations, and replenishment
- **Key Entities**: Stock, Reservation, Replenishment, Warehouse
- **Business Rules**:
  - Real-time stock tracking
  - Reservation timeout handling
  - Low stock alerts
  - Multi-warehouse support
- **External Dependencies**: Supplier systems, warehouse management

### 6. Notifications
- **Purpose**: Send communications to users and administrators
- **Key Entities**: Notification, Template, Channel, Subscription
- **Business Rules**:
  - Multi-channel delivery (email, SMS, push)
  - User preference management
  - Delivery confirmation tracking
  - Template versioning
- **External Dependencies**: Email providers, SMS gateways, push notification services

## Bounded Contexts Identification

### Context 1: Identity & Access Management
- **Ubiquitous Language**: User, Account, Authentication, Authorization, Profile, Role, Permission
- **Entities**: User, Role, Permission, Session, Profile
- **Value Objects**: Email, Password, ProfilePicture, Address
- **Aggregates**: User (with Profile, Preferences, Roles)
- **Services**: AuthenticationService, AuthorizationService, ProfileService
- **Boundaries**: Includes user data and access control, excludes order history and preferences

### Context 2: Product Catalog Management
- **Ubiquitous Language**: Product, Category, SKU, Inventory, Price, Catalog
- **Entities**: Product, Category, InventoryItem, PriceHistory
- **Value Objects**: SKU, Price, ProductImage, ProductAttributes
- **Aggregates**: Product (with Inventory, Pricing), Category (with Products)
- **Services**: CatalogService, InventoryService, PricingService
- **Boundaries**: Includes product data and inventory, excludes order processing

### Context 3: Order Management
- **Ubiquitous Language**: Order, OrderItem, Payment, Fulfillment, Invoice, Shipping
- **Entities**: Order, OrderItem, Payment, Shipment, Invoice
- **Value Objects**: OrderNumber, PaymentMethod, ShippingAddress, OrderStatus
- **Aggregates**: Order (with OrderItems, Payment, Shipment)
- **Services**: OrderService, PaymentService, FulfillmentService
- **Boundaries**: Includes order lifecycle, excludes product catalog and user management

### Context 4: Communication & Notifications
- **Ubiquitous Language**: Notification, Message, Template, Channel, Subscription
- **Entities**: Notification, NotificationTemplate, Subscription
- **Value Objects**: MessageContent, DeliveryChannel, NotificationStatus
- **Aggregates**: Notification (with Template, Delivery)
- **Services**: NotificationService, TemplateService, DeliveryService
- **Boundaries**: Includes all communication, excludes business domain logic

## Service Boundary Recommendations

Based on the bounded context analysis, we recommend the following microservices:

1. **User Management Service** (Identity & Access Management context)
2. **Product Catalog Service** (Product Catalog Management context)
3. **Order Management Service** (Order Management context)
4. **Notification Service** (Communication & Notifications context)
5. **API Gateway** (Cross-cutting concern for routing and security)

Each service will own its data and expose well-defined APIs for inter-service communication.
' \
"Comprehensive domain analysis for e-commerce microservices decomposition"

elif [[ $EXERCISE_NAME == "exercise02" ]]; then
    # Exercise 2: Building Core Microservices

    explain_concept "Microservices Implementation Patterns" \
"Core Microservices Implementation:
• Service Independence: Each service has its own database and deployment
• API-First Design: Well-defined contracts between services
• Shared Libraries: Common models and utilities without tight coupling
• Database per Service: Data ownership and independence
• Service Registration: Discovery and health monitoring"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 2 requires Exercise 1 to be completed first!"
        echo_info "Please run: ./launch-exercises.sh exercise01"
        exit 1
    fi

    echo_info "Setting up microservices solution structure..."

    # Create solution structure
    dotnet new sln -n ECommerceMS

    # Create shared library
    mkdir -p src/SharedLibraries
    cd src/SharedLibraries
    dotnet new classlib -n ECommerceMS.Shared --framework net8.0
    dotnet add ECommerceMS.Shared package Microsoft.Extensions.Logging
    cd ../..

    # Add shared library to solution
    dotnet sln add src/SharedLibraries/ECommerceMS.Shared/ECommerceMS.Shared.csproj

    # Create base entity
    create_file_interactive "src/SharedLibraries/ECommerceMS.Shared/Models/BaseEntity.cs" \
'using System.ComponentModel.DataAnnotations;

namespace ECommerceMS.Shared.Models;

public abstract class BaseEntity
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public string? UpdatedBy { get; set; }
}' \
"Base entity class for all microservices"

elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    # Exercise 3: Inter-Service Communication Patterns

    explain_concept "Inter-Service Communication" \
"Microservices Communication Patterns:
• Synchronous Communication: HTTP/REST for immediate responses
• Asynchronous Messaging: Event-driven communication via message brokers
• Service Discovery: Dynamic service location and health checking
• Circuit Breaker: Fault tolerance for service dependencies
• Event Sourcing: Capturing state changes as events"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 3 requires Exercises 1 and 2 to be completed first!"
        echo_info "Please run exercises in order: exercise01, exercise02, exercise03"
        exit 1
    fi

    # Add RabbitMQ and HTTP client packages
    echo_info "Adding communication packages to services..."

    # Add to each service
    for service in "ProductCatalog.Service" "OrderManagement.Service" "UserManagement.Service"; do
        if [ -d "src/$service" ]; then
            cd "src/$service"
            dotnet add package RabbitMQ.Client
            dotnet add package Microsoft.Extensions.Http
            dotnet add package Polly.Extensions.Http
            cd ../..
        fi
    done

elif [[ $EXERCISE_NAME == "exercise04" ]]; then
    # Exercise 4: Production-Ready Deployment

    explain_concept "Production Deployment Patterns" \
"Production-Ready Microservices:
• Containerization: Docker containers for consistent deployment
• Orchestration: Docker Compose for local development
• Health Checks: Service health monitoring and readiness probes
• Monitoring: Application Insights and distributed tracing
• Resilience: Circuit breakers, retries, and timeout patterns"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 4 requires Exercises 1, 2, and 3 to be completed first!"
        echo_info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04"
        exit 1
    fi

    # Create Docker Compose configuration
    create_file_interactive "docker-compose.yml" \
'version: "3.8"

services:
  # Product Catalog Service
  product-catalog:
    build:
      context: ./src/ProductCatalog.Service
      dockerfile: Dockerfile
    ports:
      - "5001:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Server=sqlserver;Database=ProductCatalogDB;User Id=sa;Password=YourPassword123!;TrustServerCertificate=true
      - RabbitMQ__ConnectionString=amqp://guest:guest@rabbitmq:5672/
    depends_on:
      - sqlserver
      - rabbitmq
    networks:
      - ecommerce-network

  # Order Management Service
  order-management:
    build:
      context: ./src/OrderManagement.Service
      dockerfile: Dockerfile
    ports:
      - "5002:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Server=sqlserver;Database=OrderManagementDB;User Id=sa;Password=YourPassword123!;TrustServerCertificate=true
      - RabbitMQ__ConnectionString=amqp://guest:guest@rabbitmq:5672/
      - Services__ProductCatalog=http://product-catalog:80
    depends_on:
      - sqlserver
      - rabbitmq
      - product-catalog
    networks:
      - ecommerce-network

  # User Management Service
  user-management:
    build:
      context: ./src/UserManagement.Service
      dockerfile: Dockerfile
    ports:
      - "5003:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Server=sqlserver;Database=UserManagementDB;User Id=sa;Password=YourPassword123!;TrustServerCertificate=true
    depends_on:
      - sqlserver
    networks:
      - ecommerce-network

  # API Gateway
  api-gateway:
    build:
      context: ./src/ApiGateway
      dockerfile: Dockerfile
    ports:
      - "5000:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - Services__ProductCatalog=http://product-catalog:80
      - Services__OrderManagement=http://order-management:80
      - Services__UserManagement=http://user-management:80
    depends_on:
      - product-catalog
      - order-management
      - user-management
    networks:
      - ecommerce-network

  # SQL Server Database
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=YourPassword123!
    ports:
      - "1433:1433"
    volumes:
      - sqlserver-data:/var/opt/mssql
    networks:
      - ecommerce-network

  # RabbitMQ Message Broker
  rabbitmq:
    image: rabbitmq:3-management
    environment:
      - RABBITMQ_DEFAULT_USER=guest
      - RABBITMQ_DEFAULT_PASS=guest
    ports:
      - "5672:5672"
      - "15672:15672"
    volumes:
      - rabbitmq-data:/var/lib/rabbitmq
    networks:
      - ecommerce-network

  # Redis Cache
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - ecommerce-network

volumes:
  sqlserver-data:
  rabbitmq-data:
  redis-data:

networks:
  ecommerce-network:
    driver: bridge' \
"Complete Docker Compose configuration for microservices deployment"

elif [[ $EXERCISE_NAME == "exercise05" ]]; then
    # Exercise 5: Cloud Deployment Options

    explain_concept "Cloud-Native Deployment" \
"Cloud Deployment Strategies:
• Azure Kubernetes Service (AKS): Managed Kubernetes for Azure
• Infrastructure as Code: Terraform for reproducible deployments
• Generic Kubernetes: Multi-cloud deployment flexibility
• Docker Swarm: Simpler orchestration for smaller deployments
• CI/CD Integration: Automated deployment pipelines"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 5 requires all previous exercises to be completed first!"
        echo_info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04, exercise05"
        exit 1
    fi

    echo_info "Setting up cloud deployment configurations..."

    # Create Kubernetes deployment manifests
    mkdir -p k8s
    create_file_interactive "k8s/product-catalog-deployment.yaml" \
'apiVersion: apps/v1
kind: Deployment
metadata:
  name: product-catalog
  labels:
    app: product-catalog
spec:
  replicas: 2
  selector:
    matchLabels:
      app: product-catalog
  template:
    metadata:
      labels:
        app: product-catalog
    spec:
      containers:
      - name: product-catalog
        image: ecommercems/product-catalog:latest
        ports:
        - containerPort: 80
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: "Production"
        - name: ConnectionStrings__DefaultConnection
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: connection-string
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: product-catalog-service
spec:
  selector:
    app: product-catalog
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP' \
"Kubernetes deployment manifest for Product Catalog service"

fi

# Final completion message
echo ""
echo_success "🎉 $EXERCISE_NAME template created successfully!"
echo ""
echo_info "📋 Next steps:"

case $EXERCISE_NAME in
    "exercise01")
        echo "1. Complete the domain analysis in: ${CYAN}docs/domain-analysis.md${NC}"
        echo "2. Design service boundaries and data consistency strategies"
        echo "3. Create service architecture diagrams"
        echo "4. Review with team or instructor before proceeding"
        ;;
    "exercise02")
        echo "1. Build and test each microservice independently"
        echo "2. Run: ${CYAN}dotnet build${NC} in each service directory"
        echo "3. Test APIs using Swagger UI for each service"
        echo "4. Verify database independence and data ownership"
        ;;
    "exercise03")
        echo "1. Implement HTTP client communication between services"
        echo "2. Set up RabbitMQ message broker"
        echo "3. Test synchronous and asynchronous communication"
        echo "4. Implement event-driven patterns"
        ;;
    "exercise04")
        echo "1. Build Docker images: ${CYAN}docker-compose build${NC}"
        echo "2. Run the complete system: ${CYAN}docker-compose up -d${NC}"
        echo "3. Access services via API Gateway: ${CYAN}http://localhost:5000${NC}"
        echo "4. Monitor health and performance metrics"
        ;;
    "exercise05")
        echo "1. Choose deployment option: Azure AKS, Generic K8s, or Docker Swarm"
        echo "2. Configure cloud infrastructure with Terraform (if using Azure)"
        echo "3. Deploy to chosen platform: ${CYAN}kubectl apply -f k8s/${NC}"
        echo "4. Set up monitoring and scaling policies"
        ;;
esac

echo ""
echo_info "📚 For detailed instructions, refer to the exercise files in the Exercises/ directory."
echo_info "🔗 Additional microservices resources available in the Resources/ directory."
echo_info "💡 Consider using the complete SourceCode implementation as a reference."
