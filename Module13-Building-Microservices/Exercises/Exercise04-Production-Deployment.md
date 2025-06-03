# Exercise 4: Production-Ready Deployment (Continued)

## 📦 Task 4: Complete Docker Deployment (30 minutes) - Continued

### Step 1: Create Complete Docker Compose Configuration

**docker-compose.yml:**
```yaml
version: '3.8'

networks:
  ecommerce-network:
    driver: bridge

volumes:
  sqlserver_data:
  rabbitmq_data:
  logs_data:

services:
  # Infrastructure Services
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: ecommerce-sqlserver
    environment:
      SA_PASSWORD: "YourStrong@Passw0rd"
      ACCEPT_EULA: "Y"
    ports:
      - "1433:1433"
    volumes:
      - sqlserver_data:/var/opt/mssql
    networks:
      - ecommerce-network
    healthcheck:
      test: ["CMD-SHELL", "/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -Q 'SELECT 1'"]
      interval: 30s
      timeout: 10s
      retries: 3

  rabbitmq:
    image: rabbitmq:3-management
    container_name: ecommerce-rabbitmq
    environment:
      RABBITMQ_DEFAULT_USER: admin
      RABBITMQ_DEFAULT_PASS: password
    ports:
      - "5672:5672"
      - "15672:15672"
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    networks:
      - ecommerce-network
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Application Services
  productcatalog:
    build: 
      context: ./src/ProductCatalog.Service
      dockerfile: Dockerfile
    container_name: ecommerce-productcatalog
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Server=sqlserver;Database=ProductCatalogDB;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True
      - RabbitMQ__Host=rabbitmq
      - RabbitMQ__Username=admin
      - RabbitMQ__Password=password
    ports:
      - "5001:80"
    volumes:
      - logs_data:/app/logs
    networks:
      - ecommerce-network
    depends_on:
      sqlserver:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  ordermanagement:
    build: 
      context: ./src/OrderManagement.Service
      dockerfile: Dockerfile
    container_name: ecommerce-ordermanagement
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Server=sqlserver;Database=OrderManagementDB;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True
      - RabbitMQ__Host=rabbitmq
      - RabbitMQ__Username=admin
      - RabbitMQ__Password=password
      - ProductCatalogService__BaseUrl=http://productcatalog
    ports:
      - "5002:80"
    volumes:
      - logs_data:/app/logs
    networks:
      - ecommerce-network
    depends_on:
      sqlserver:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
      productcatalog:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  apigateway:
    build: 
      context: ./src/ApiGateway
      dockerfile: Dockerfile
    container_name: ecommerce-apigateway
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ReverseProxy__Clusters__products-cluster__Destinations__products-destination__Address=http://productcatalog/
      - ReverseProxy__Clusters__orders-cluster__Destinations__orders-destination__Address=http://ordermanagement/
    ports:
      - "5000:80"
    volumes:
      - logs_data:/app/logs
    networks:
      - ecommerce-network
    depends_on:
      productcatalog:
        condition: service_healthy
      ordermanagement:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Monitoring Services
  prometheus:
    image: prom/prometheus:latest
    container_name: ecommerce-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - ecommerce-network
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'

  grafana:
    image: grafana/grafana:latest
    container_name: ecommerce-grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - ./monitoring/grafana/dashboards:/var/lib/grafana/dashboards
      - ./monitoring/grafana/provisioning:/etc/grafana/provisioning
    networks:
      - ecommerce-network
    depends_on:
      - prometheus
```

### Step 2: Create Monitoring Configuration

**monitoring/prometheus.yml:**
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'api-gateway'
    static_configs:
      - targets: ['apigateway:80']
    metrics_path: '/metrics'
    scrape_interval: 10s

  - job_name: 'product-catalog'
    static_configs:
      - targets: ['productcatalog:80']
    metrics_path: '/metrics'
    scrape_interval: 10s

  - job_name: 'order-management'
    static_configs:
      - targets: ['ordermanagement:80']
    metrics_path: '/metrics'
    scrape_interval: 10s

  - job_name: 'rabbitmq'
    static_configs:
      - targets: ['rabbitmq:15692']
    metrics_path: '/metrics'
```

### Step 3: Create Grafana Dashboard Configuration

**monitoring/grafana/provisioning/datasources/prometheus.yml:**
```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
```

**monitoring/grafana/provisioning/dashboards/dashboard.yml:**
```yaml
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
```

## 🔧 Task 5: Add Production Configuration (25 minutes)

### Step 1: Create Production-Specific Configuration

**src/ProductCatalog.Service/appsettings.Production.json:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=sqlserver;Database=ProductCatalogDB;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True"
  },
  "RabbitMQ": {
    "Host": "rabbitmq",
    "Username": "admin",
    "Password": "password"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Warning"
    }
  },
  "Serilog": {
    "MinimumLevel": {
      "Default": "Information",
      "Override": {
        "Microsoft": "Warning",
        "System": "Warning"
      }
    }
  }
}
```

**src/OrderManagement.Service/appsettings.Production.json:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=sqlserver;Database=OrderManagementDB;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True"
  },
  "RabbitMQ": {
    "Host": "rabbitmq",
    "Username": "admin",
    "Password": "password"
  },
  "ProductCatalogService": {
    "BaseUrl": "http://productcatalog"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Warning"
    }
  }
}
```

### Step 2: Create Dockerfiles for All Services

**src/ApiGateway/Dockerfile:**
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ApiGateway.csproj", "."]
RUN dotnet restore "./ApiGateway.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "ApiGateway.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ApiGateway.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ApiGateway.dll"]
```

**Update ProductCatalog.Service/Dockerfile:**
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ProductCatalog.Service.csproj", "."]
COPY ["../SharedLibraries/ECommerceMS.Shared/ECommerceMS.Shared.csproj", "../SharedLibraries/ECommerceMS.Shared/"]
RUN dotnet restore "./ProductCatalog.Service.csproj"
COPY . .
COPY ../SharedLibraries/ECommerceMS.Shared ../SharedLibraries/ECommerceMS.Shared
WORKDIR "/src/."
RUN dotnet build "ProductCatalog.Service.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ProductCatalog.Service.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ProductCatalog.Service.dll"]
```

### Step 3: Create Build and Deployment Scripts

**scripts/build.sh:**
```bash
#!/bin/bash

echo "Building ECommerce Microservices..."

# Build shared libraries first
echo "Building shared libraries..."
cd src/SharedLibraries/ECommerceMS.Shared
dotnet build -c Release
cd ../../..

# Build services
echo "Building Product Catalog Service..."
cd src/ProductCatalog.Service
dotnet build -c Release
cd ../..

echo "Building Order Management Service..."
cd src/OrderManagement.Service
dotnet build -c Release
cd ../..

echo "Building API Gateway..."
cd src/ApiGateway
dotnet build -c Release
cd ../..

echo "Building Docker images..."
docker-compose build

echo "Build completed successfully!"
```

**scripts/deploy.sh:**
```bash
#!/bin/bash

echo "Deploying ECommerce Microservices..."

# Stop existing containers
echo "Stopping existing containers..."
docker-compose down

# Start infrastructure services first
echo "Starting infrastructure services..."
docker-compose up -d sqlserver rabbitmq

# Wait for infrastructure to be ready
echo "Waiting for infrastructure services to be ready..."
sleep 30

# Start application services
echo "Starting application services..."
docker-compose up -d productcatalog ordermanagement

# Wait for application services
echo "Waiting for application services to be ready..."
sleep 30

# Start API Gateway
echo "Starting API Gateway..."
docker-compose up -d apigateway

# Start monitoring services
echo "Starting monitoring services..."
docker-compose up -d prometheus grafana

echo "Deployment completed!"
echo "Services available at:"
echo "- API Gateway: http://localhost:5000"
echo "- Product Catalog: http://localhost:5001"
echo "- Order Management: http://localhost:5002"
echo "- RabbitMQ Management: http://localhost:15672"
echo "- Prometheus: http://localhost:9090"
echo "- Grafana: http://localhost:3000"
echo "- Health Checks UI: http://localhost:5000/health-ui"
```

**scripts/test-deployment.sh:**
```bash
#!/bin/bash

echo "Testing microservices deployment..."

BASE_URL="http://localhost:5000"

# Test API Gateway health
echo "Testing API Gateway health..."
curl -f "$BASE_URL/health" || { echo "API Gateway health check failed"; exit 1; }

# Test Product Catalog through Gateway
echo "Testing Product Catalog through Gateway..."
curl -f "$BASE_URL/api/products" || { echo "Product Catalog test failed"; exit 1; }

# Create a test order
echo "Creating test order..."
ORDER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/orders" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "11111111-1111-1111-1111-111111111111",
    "items": [
      {
        "productId": "33333333-3333-3333-3333-333333333333",
        "quantity": 1
      }
    ],
    "shippingAmount": 10.00,
    "taxAmount": 130.00,
    "discountAmount": 0.00,
    "shippingName": "Test User",
    "shippingAddress": "123 Test St",
    "shippingCity": "Test City",
    "shippingState": "TS",
    "shippingZipCode": "12345",
    "shippingCountry": "USA"
  }')

if [ $? -eq 0 ]; then
    echo "✅ Order creation test passed"
    ORDER_ID=$(echo $ORDER_RESPONSE | jq -r '.id')
    echo "Created order: $ORDER_ID"
    
    # Test order retrieval
    echo "Testing order retrieval..."
    curl -f "$BASE_URL/api/orders/$ORDER_ID" || { echo "Order retrieval test failed"; exit 1; }
    echo "✅ Order retrieval test passed"
else
    echo "❌ Order creation test failed"
    exit 1
fi

echo "🎉 All tests passed! Deployment is successful."
```

## 🧪 Task 6: Load Testing and Performance Validation (20 minutes)

### Step 1: Create Load Testing Script

**scripts/load-test.sh:**
```bash
#!/bin/bash

echo "Running load tests..."

# Install wrk if not available
if ! command -v wrk &> /dev/null; then
    echo "Installing wrk load testing tool..."
    sudo apt-get update && sudo apt-get install -y wrk
fi

BASE_URL="http://localhost:5000"

echo "Running load test on Product Catalog..."
wrk -t12 -c400 -d30s --timeout 10s "$BASE_URL/api/products"

echo "Running load test on Order Creation..."
wrk -t4 -c100 -d30s --timeout 30s -s scripts/order-load-test.lua "$BASE_URL"

echo "Load testing completed!"
```

**scripts/order-load-test.lua:**
```lua
-- order-load-test.lua
wrk.method = "POST"
wrk.body = '{"userId":"11111111-1111-1111-1111-111111111111","items":[{"productId":"33333333-3333-3333-3333-333333333333","quantity":1}],"shippingAmount":10.00,"taxAmount":130.00,"discountAmount":0.00,"shippingName":"Load Test","shippingAddress":"123 Load Test St","shippingCity":"Test City","shippingState":"TS","shippingZipCode":"12345","shippingCountry":"USA"}'
wrk.headers["Content-Type"] = "application/json"

request = function()
    path = "/api/orders"
    return wrk.format(nil, path)
end
```

### Step 2: Create Performance Monitoring

**scripts/monitor-performance.sh:**
```bash
#!/bin/bash

echo "Monitoring system performance..."

# Monitor Docker container stats
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" --no-stream

# Check application logs for errors
echo "Checking for errors in logs..."
docker-compose logs --tail=100 productcatalog | grep -i error
docker-compose logs --tail=100 ordermanagement | grep -i error
docker-compose logs --tail=100 apigateway | grep -i error

# Check health status
echo "Checking health status..."
curl -s http://localhost:5000/health | jq '.'
```

## 📋 Task 7: Create Documentation and Runbooks (15 minutes)

### Step 1: Create Operations Manual

**docs/operations-manual.md:**
```markdown
# ECommerce Microservices Operations Manual

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- At least 8GB RAM available
- Ports 5000-5002, 1433, 5672, 15672, 9090, 3000 available

### Deployment
```bash
# Clone repository and navigate to root
cd ECommerceMS

# Make scripts executable
chmod +x scripts/*.sh

# Deploy the system
./scripts/deploy.sh

# Test deployment
./scripts/test-deployment.sh
```

### Service URLs
- **API Gateway**: http://localhost:5000
- **Product Catalog**: http://localhost:5001  
- **Order Management**: http://localhost:5002
- **RabbitMQ Management**: http://localhost:15672 (admin/password)
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)
- **Health Dashboard**: http://localhost:5000/health-ui

## 🔧 Troubleshooting

### Common Issues

#### Services Won't Start
1. Check Docker daemon is running
2. Verify port availability: `netstat -tlnp | grep :5000`
3. Check logs: `docker-compose logs [service-name]`
4. Restart services: `docker-compose restart`

#### Database Connection Issues
1. Check SQL Server container: `docker-compose logs sqlserver`
2. Verify connection string in environment variables
3. Check if database is ready: `docker exec -it ecommerce-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -Q "SELECT 1"`

#### RabbitMQ Issues
1. Check RabbitMQ container: `docker-compose logs rabbitmq`
2. Access management UI: http://localhost:15672
3. Check queue status and message flow

#### High CPU/Memory Usage
1. Monitor with: `docker stats`
2. Check for memory leaks in application logs
3. Scale services if needed: `docker-compose up -d --scale productcatalog=2`

### Monitoring and Alerts

#### Key Metrics to Monitor
- **Response Time**: <500ms for 95th percentile
- **Error Rate**: <1% for 5xx errors
- **CPU Usage**: <80% average
- **Memory Usage**: <85% of allocated
- **Database Connections**: Monitor connection pool usage

#### Log Locations
- Application logs: `./logs/` (mounted volume)
- Container logs: `docker-compose logs [service]`
- System logs: `/var/log/docker/`

### Scaling Guidelines

#### Horizontal Scaling
```bash
# Scale Product Catalog service
docker-compose up -d --scale productcatalog=3

# Scale Order Management service  
docker-compose up -d --scale ordermanagement=2
```

#### Load Balancing
- API Gateway automatically load balances between scaled instances
- Monitor health checks to ensure traffic routing

## 🛠️ Maintenance

### Daily Tasks
- [ ] Check service health status
- [ ] Monitor error logs
- [ ] Verify backup completion
- [ ] Check disk space usage

### Weekly Tasks
- [ ] Review performance metrics
- [ ] Update dependencies if needed
- [ ] Clean up old logs and containers
- [ ] Test disaster recovery procedures

### Monthly Tasks
- [ ] Security updates
- [ ] Performance tuning review
- [ ] Capacity planning assessment
- [ ] Documentation updates
```

## 📝 Deliverables

1. **Complete microservices deployment** with API Gateway, monitoring, and logging
2. **Production-ready configuration** with health checks and resilience patterns
3. **Monitoring dashboard** in Grafana showing key metrics
4. **Load testing results** demonstrating system performance
5. **Operations manual** with troubleshooting guides
6. **CI/CD pipeline** (bonus) for automated deployment

## 🎯 Success Criteria

### **Excellent (90-100%)**
- ✅ All services deploy successfully via Docker Compose
- ✅ API Gateway routes requests correctly with authentication
- ✅ Circuit breakers and retry policies work under failure conditions
- ✅ Comprehensive monitoring and alerting configured
- ✅ Load testing shows acceptable performance (>100 RPS)
- ✅ Health checks and graceful shutdown implemented
- ✅ Complete documentation and runbooks provided

### **Good (80-89%)**
- ✅ Most services deploy successfully
- ✅ Basic API Gateway functionality works
- ✅ Some resilience patterns implemented
- ✅ Basic monitoring configured
- ✅ Services handle moderate load

### **Satisfactory (70-79%)**
- ✅ Services deploy with manual intervention
- ✅ Basic functionality works
- ✅ Limited monitoring and error handling

## 💡 Extension Activities

1. **Kubernetes Deployment**: Convert Docker Compose to Kubernetes manifests
2. **Service Mesh**: Implement Istio or Linkerd for advanced traffic management
3. **CI/CD Pipeline**: Create GitHub Actions or Azure DevOps pipelines
4. **Security Hardening**: Implement mTLS, secret management, and security scanning
5. **Performance Optimization**: Add caching layers, database optimization
6. **Multi-Region Deployment**: Deploy across multiple availability zones

## 🏆 Congratulations!

You've successfully built and deployed a production-ready microservices architecture! This exercise demonstrates enterprise-level patterns including:

- **Service decomposition** and proper boundaries
- **Inter-service communication** patterns
- **Resilience and fault tolerance**
- **Monitoring and observability**
- **Production deployment** strategies

## ⏭️ Next Steps

- **Real-world deployment**: Deploy to Azure, AWS, or GCP
- **Advanced patterns**: Implement CQRS, Event Sourcing, or Saga orchestration
- **Security enhancement**: Add OAuth2, API rate limiting, and security headers
- **Performance tuning**: Optimize database queries and implement advanced caching

**Excellent work completing the microservices training! 🎉**