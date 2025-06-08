# Exercise 1: Understanding Microservices

## Duration: 30 minutes

## Learning Objectives
- Understand what microservices are
- Learn when to use microservices vs monolithic architecture
- Identify service boundaries
- Plan a simple microservices system

## Part 1: What Are Microservices? (10 minutes)

### Definition
Microservices are an architectural style where an application is built as a collection of small, independent services that:
- Run in their own process
- Communicate through APIs
- Can be deployed independently
- Own their data

### Comparison with Monolithic Architecture

| Aspect | Monolithic | Microservices |
|--------|------------|---------------|
| **Deployment** | Single deployable unit | Multiple independent services |
| **Technology** | One tech stack | Can use different stacks |
| **Scaling** | Scale entire app | Scale individual services |
| **Data** | Shared database | Each service owns its data |
| **Team Structure** | One large team | Small teams per service |
| **Complexity** | Simple to start | More complex infrastructure |

### When to Use Microservices
✅ **Good fit when:**
- You have multiple teams
- Different parts need different scaling
- You need technology flexibility
- Services have clear boundaries
- You have DevOps maturity

❌ **Not ideal when:**
- Small team or project
- Simple CRUD application
- Tight deadlines
- Limited DevOps experience
- Unclear domain boundaries

## Part 2: Identifying Service Boundaries (10 minutes)

### The Shopping Cart Example
Let's analyze a simple e-commerce system and identify potential services:

**Traditional Monolith Structure:**
```
ECommerceApp/
├── Controllers/
│   ├── ProductController.cs
│   ├── OrderController.cs
│   ├── UserController.cs
│   └── PaymentController.cs
├── Services/
│   ├── ProductService.cs
│   ├── OrderService.cs
│   ├── UserService.cs
│   └── PaymentService.cs
└── Database/
    └── ECommerceDB (all tables)
```

**Microservices Structure:**
```
ECommerceMicroservices/
├── ProductService/
│   ├── API/
│   ├── Business Logic/
│   └── ProductDB/
├── OrderService/
│   ├── API/
│   ├── Business Logic/
│   └── OrderDB/
├── UserService/
│   ├── API/
│   ├── Business Logic/
│   └── UserDB/
└── PaymentService/
    ├── API/
    ├── Business Logic/
    └── PaymentDB/
```

### Key Principles for Service Boundaries
1. **Single Responsibility**: Each service does one thing well
2. **Business Capability**: Aligned with business functions
3. **Data Ownership**: Each service owns its data
4. **Loose Coupling**: Minimal dependencies between services

## Part 3: Planning Your First Microservices (10 minutes)

### Task: Design a Simple System
For this module, we'll build a simplified e-commerce system with just 2 services:

1. **Product Service**
   - Manages product catalog
   - Tracks inventory
   - Provides product information

2. **Order Service**
   - Creates orders
   - Validates inventory (calls Product Service)
   - Manages order status

### Service Interactions
```
Customer -> Order Service: "Create order for Product X"
Order Service -> Product Service: "Is Product X available?"
Product Service -> Order Service: "Yes, 5 in stock"
Order Service -> Product Service: "Reserve 1 of Product X"
Order Service -> Customer: "Order created successfully"
```

### Your Task
1. Draw a simple diagram showing how these services interact
2. List the API endpoints each service would need
3. Identify what data each service would store

### Expected Outputs

**Product Service APIs:**
- GET /api/products - List all products
- GET /api/products/{id} - Get product details
- POST /api/products - Create product (admin)
- PUT /api/products/{id}/inventory - Update inventory

**Order Service APIs:**
- POST /api/orders - Create new order
- GET /api/orders/{id} - Get order details
- GET /api/orders - List orders for a customer
- PUT /api/orders/{id}/status - Update order status

## Self-Assessment Questions

1. What's the main difference between microservices and a monolith?
2. Why does each service need its own database?
3. What happens if the Product Service is down when someone tries to create an order?
4. How would you add a Payment Service to this system?

## Next Steps
In Exercise 2, we'll implement these two services using ASP.NET Core and Docker!