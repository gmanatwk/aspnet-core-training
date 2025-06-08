# Module 13: Building Microservices with Azure

## 🎯 Learning Objectives

By the end of this module, you will be able to:

- ✅ **Understand Microservices Architecture**: Learn what microservices are and when to use them
- ✅ **Build Cloud-Native Services**: Create services designed for Azure Container Apps
- ✅ **Deploy to Azure Container Apps**: Deploy microservices without managing infrastructure
- ✅ **Implement Service Communication**: Use Azure Service Bus for messaging
- ✅ **Leverage Azure Services**: Use Azure SQL, Key Vault, and Application Insights

## 📚 Module Overview

**Duration**: 3 hours  
**Difficulty**: Intermediate  
**Prerequisites**: 
- Completion of Module 3 (Web APIs)
- Azure subscription (free tier is sufficient)
- Azure CLI installed
- Basic understanding of cloud concepts

**Azure-First Approach**: 
1. Understand microservices in the cloud context
2. Build services designed for Azure
3. Deploy directly to Azure Container Apps
4. Use Azure services for communication and data

## 🏗️ What Are Microservices?

Microservices architecture is a design approach where applications are built as a collection of loosely coupled, independently deployable services. Each service:

- **Owns its data** and business logic
- **Communicates** via well-defined APIs
- **Can be developed** by different teams
- **Scales independently** based on demand
- **Uses different technologies** if needed

### Benefits:
- 🚀 **Scalability**: Scale individual services independently
- 🔧 **Technology Diversity**: Use different tech stacks per service
- 👥 **Team Independence**: Teams can work autonomously
- 🛡️ **Fault Isolation**: Failures don't cascade across the system
- 📦 **Deployment Independence**: Deploy services separately

### Challenges:
- 🌐 **Network Complexity**: Distributed communication overhead
- 📊 **Data Consistency**: Managing transactions across services
- 🔍 **Observability**: Monitoring distributed systems
- 🔒 **Security**: Securing service-to-service communication
- 🎭 **Testing**: Integration testing across services

## 📋 Module Content

### **Part 1: Microservices Fundamentals** (45 minutes)
- Microservices vs Monolithic architecture
- Service decomposition strategies
- Domain-Driven Design (DDD) principles
- Bounded contexts and service boundaries

### **Part 2: Building Your First Microservice** (45 minutes)
- Creating independent ASP.NET Core services
- Service discovery and registration
- API Gateway patterns
- Configuration management

### **Part 3: Inter-Service Communication** (45 minutes)
- Synchronous communication (HTTP/REST, gRPC)
- Asynchronous messaging (Message queues, Event-driven)
- Data consistency patterns (Saga, Event Sourcing)
- Handling distributed transactions

### **Part 4: Deployment and Operations** (45 minutes)
- Containerizing microservices
- Service mesh and networking
- Monitoring and observability
- Resilience patterns and fault tolerance

## 🏋️ Hands-on Exercises

### **Exercise 1: Azure Setup and Microservices Overview** (30 min)
- Set up Azure Resource Group
- Create Azure Container Registry
- Understand Azure Container Apps architecture
- Plan your microservices deployment

### **Exercise 2: Building Azure-Ready Services** (45 min)
- Create Product Service with Azure SQL
- Create Order Service with Azure integration
- Configure for Azure deployment
- Use Azure Key Vault for secrets

### **Exercise 3: Deploy to Azure Container Apps** (45 min)
- Push images to Azure Container Registry
- Deploy services to Container Apps
- Configure environment variables and scaling
- Set up Application Insights monitoring

### **Exercise 4: Service Communication with Azure** (30 min)
- Implement Azure Service Bus for messaging
- Configure service discovery in Container Apps
- Handle failures with Azure's built-in features

### **Exercise 5: Production Features** (30 min)
- Configure auto-scaling
- Set up Azure Front Door
- Implement health checks
- Review costs and optimization

## 🛠️ Technologies Used

### **Core Technologies:**
- ASP.NET Core 8.0 (Web APIs)
- Entity Framework Core (Data Access)
- Azure Container Apps (Serverless containers)
- Azure SQL Database (Managed database)

### **Azure Services:**
- Azure Container Registry (Image storage)
- Azure Service Bus (Messaging)
- Azure Key Vault (Secrets management)
- Application Insights (Monitoring)
- Azure Front Door (Global load balancing)

### **Development Tools:**
- Visual Studio / VS Code
- Azure CLI
- Azure Portal

## 📁 Project Structure

```
Module13-Building-Microservices/
├── README.md (this file)
├── Exercises/
│   ├── Exercise01-Azure-Setup.md
│   ├── Exercise02-Building-Azure-Services.md
│   ├── Exercise03-Deploy-Container-Apps.md
│   ├── Exercise04-Azure-Communication.md
│   └── Exercise05-Production-Features.md
├── Resources/
│   ├── azure-container-apps-guide.md
│   ├── azure-services-overview.md
│   ├── cost-optimization.md
│   └── monitoring-guide.md
├── SourceCode/
│   └── AzureECommerce/
│       ├── ProductService/
│       ├── OrderService/
│       ├── deploy-scripts/
│       └── README.md
└── Templates/
    ├── azure-deploy.sh
    ├── container-app-config.yaml
    └── bicep-templates/
```

## 🎯 Real-World Scenario

**Cloud-Native E-Commerce on Azure**

We'll build a cloud-native e-commerce system using Azure services:

1. **Product Service**: 
   - Deployed to Azure Container Apps
   - Uses Azure SQL Database
   - Integrates with Application Insights
   - Auto-scales based on demand

2. **Order Service**: 
   - Deployed to Azure Container Apps
   - Communicates via Azure Service Bus
   - Uses Azure Key Vault for secrets
   - Implements resilience with Container Apps features

3. **Azure Infrastructure**:
   - Azure Front Door for global distribution
   - Azure Monitor for observability
   - Managed identities for security
   - Built-in load balancing and scaling

## 🔧 Development Environment Setup

### Prerequisites:
```bash
# .NET 8.0 SDK
dotnet --version # Should be 8.0+

# Azure CLI
az --version # Should be 2.50+

# Visual Studio 2022 or VS Code with Azure extensions
```

### Azure Setup:
1. **Create a free Azure account** if you don't have one
2. **Install Azure tools**:
   ```bash
   # Windows (PowerShell)
   Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
   Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
   
   # macOS
   brew install azure-cli
   
   # Linux
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```

3. **Configure Visual Studio for Azure**:
   - Install Azure Development workload
   - Sign in with your Azure account

## 📚 Key Learning Concepts

### **Azure Container Apps Features:**
- **Automatic Scaling**: Scale to zero, scale based on HTTP traffic or queue length
- **Revision Management**: Deploy new versions with traffic splitting
- **Ingress Control**: Built-in load balancing and HTTPS
- **Dapr Integration**: Simplified microservices building blocks
- **Managed Identities**: Secure access to Azure services

### **Azure Best Practices:**
- Use managed services to reduce operational overhead
- Implement proper tagging for cost management
- Use Azure Key Vault for all secrets
- Enable Application Insights from day one
- Design with Azure Well-Architected Framework in mind

## 🚀 Quick Start

### Prerequisites Check:
```bash
# Check Azure CLI
az --version

# Login to Azure
az login

# Set your subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### Quick Deploy:
1. **Run the setup script**:
   ```bash
   cd Module13-Building-Microservices
   ./setup-azure-resources.sh
   ```

2. **Deploy your first service**:
   ```bash
   cd SourceCode/AzureECommerce
   ./deploy-to-azure.sh
   ```

3. **Access your services**:
   - Azure Portal: View your Container Apps
   - Get URLs from deployment output
   - Test with provided Postman collection

## 🎓 Assessment Criteria

### **Knowledge Check:**
- Explain the differences between microservices and monolithic architecture
- Identify appropriate service boundaries for a given business domain
- Describe various communication patterns and when to use them
- Explain data consistency challenges and solutions

### **Practical Skills:**
- Build and deploy multiple microservices
- Implement service-to-service communication
- Handle distributed data management
- Add monitoring and observability

### **Advanced Concepts:**
- Design resilient microservices architecture
- Implement security across services
- Optimize performance and scalability
- Plan migration strategies from monolith to microservices

## 💡 Pro Tips

1. **Use Azure's Managed Services**: Don't reinvent the wheel
2. **Start with Container Apps**: Simpler than AKS for most scenarios
3. **Monitor Costs**: Use cost analysis and set up alerts
4. **Leverage Built-in Features**: Auto-scaling, health checks, and managed identities
5. **Design for the Cloud**: Think serverless and event-driven

## 🔗 Additional Resources

- [Microservices.io](https://microservices.io/) - Comprehensive patterns catalog
- [.NET Microservices Guide](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/)
- [Building Microservices by Sam Newman](https://samnewman.io/books/building_microservices/)
- [Microservices Patterns by Chris Richardson](https://microservices.io/book)

## ⚡ Next Steps

After completing this module:
- **Production Deployment**: Complete Exercise 5 to deploy to Azure Kubernetes Service (AKS) using Terraform
- **Advanced Patterns**: Implement CQRS and Event Sourcing
- **Service Mesh**: Explore Istio or Linkerd for advanced traffic management
- **Observability**: Advanced monitoring with Jaeger and Prometheus
- **Multi-Cloud**: Extend deployment to AWS EKS or Google GKE

---

**Ready to build your first microservices architecture? Let's start with Exercise 1! 🚀**

*Remember: Microservices are not a silver bullet. They solve certain problems but introduce complexity. Choose them when the benefits outweigh the costs.*