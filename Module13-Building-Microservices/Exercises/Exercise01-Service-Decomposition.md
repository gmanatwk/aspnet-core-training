# Exercise 1: Service Decomposition and Design

## 🎯 Objective
Learn how to decompose a monolithic application into microservices using Domain-Driven Design (DDD) principles and identify proper service boundaries.

## 📋 Prerequisites
- Understanding of Domain-Driven Design concepts
- Knowledge of business domain modeling
- Familiarity with ASP.NET Core architecture

## 🏗️ Scenario: E-Commerce Monolith Decomposition

You've been given a legacy e-commerce monolithic application that needs to be decomposed into microservices. The current system handles:

- **User Management**: Registration, authentication, profiles, preferences
- **Product Catalog**: Product information, categories, inventory, pricing
- **Shopping Cart**: Cart management, item additions/removals
- **Order Processing**: Order creation, payment processing, order status
- **Inventory Management**: Stock levels, reservations, updates
- **Notifications**: Email alerts, SMS notifications, push notifications
- **Reviews & Ratings**: Product reviews, user ratings, moderation
- **Promotions**: Discount codes, special offers, loyalty programs
- **Shipping**: Address management, shipping calculations, tracking
- **Analytics**: User behavior, sales reports, inventory reports

## 🔍 Task 1: Domain Analysis (30 minutes)

### Step 1: Identify Business Capabilities
Create a list of high-level business capabilities from the monolith:

**Template:**
```markdown
## Business Capabilities Analysis

### 1. [Capability Name]
- **Purpose**: What business function does this serve?
- **Key Entities**: What are the main data entities?
- **Business Rules**: What are the core business rules?
- **External Dependencies**: What external systems does it interact with?

### Example:
### 1. User Management
- **Purpose**: Manage user accounts, authentication, and personal data
- **Key Entities**: User, Profile, Authentication, Preferences
- **Business Rules**: Unique email addresses, password complexity, data privacy
- **External Dependencies**: Email service, identity providers (OAuth)
```

**Your Task**: Complete this analysis for all 10 capabilities listed above.

### Step 2: Identify Bounded Contexts
Using the business capabilities, identify bounded contexts:

**Template:**
```markdown
## Bounded Contexts

### Context 1: [Context Name]
- **Ubiquitous Language**: Key terms and concepts
- **Entities**: Core entities within this context
- **Value Objects**: Important value objects
- **Aggregates**: Natural groupings of entities
- **Services**: Domain services needed
- **Boundaries**: What's included/excluded

### Example:
### Context 1: Identity & Access Management
- **Ubiquitous Language**: User, Account, Authentication, Authorization, Profile
- **Entities**: User, Role, Permission, Session
- **Value Objects**: Email, Password, ProfilePicture
- **Aggregates**: User (with Profile, Preferences, Roles)
- **Services**: AuthenticationService, AuthorizationService
- **Boundaries**: Includes user data, excludes order history
```

**Your Task**: Define 5-7 bounded contexts from the business capabilities.

## 🎯 Task 2: Service Boundary Design (45 minutes)

### Step 1: Map Bounded Contexts to Services
For each bounded context, design a corresponding microservice:

**Template:**
```markdown
## Microservice: [Service Name]

### Responsibility
- Primary purpose and scope
- What problems does it solve?

### Data Ownership
- **Entities Owned**: List of entities this service owns
- **Database**: Dedicated database/schema
- **Data Access**: How other services access this data

### API Design
- **Public Endpoints**: REST endpoints exposed to other services
- **Events Published**: Domain events published to event bus
- **Events Consumed**: Domain events subscribed to

### Dependencies
- **Upstream Services**: Services this service calls
- **Downstream Services**: Services that call this service
- **External Systems**: Third-party integrations

### Technology Considerations
- **Database**: SQL/NoSQL choice and reasoning
- **Caching**: Caching strategy if needed
- **Performance**: Expected load and performance requirements
```

### Step 2: Design Service Interactions
Create a service interaction diagram:

```markdown
## Service Interaction Map

### Synchronous Calls (HTTP/REST)
- API Gateway → [Service] for [Purpose]
- [Service A] → [Service B] for [Specific Operation]

### Asynchronous Events
- [Service A] publishes [Event] when [Trigger]
- [Service B] subscribes to [Event] to [Action]

### Data Flow
- [Process Name]: Service A → Service B → Service C
- [Process Name]: Event-driven flow A → Event Bus → Service B
```

**Example Solution Structure:**

```markdown
## Microservice: Product Catalog Service

### Responsibility
- Manage product information, categories, and inventory
- Provide product search and filtering capabilities
- Handle product lifecycle management

### Data Ownership
- **Entities Owned**: Product, Category, ProductCategory, InventoryItem
- **Database**: ProductCatalogDB (SQL Server)
- **Data Access**: Public REST API for read operations, events for data changes

### API Design
- **Public Endpoints**:
  - GET /api/products - List products with filtering
  - GET /api/products/{id} - Get product details
  - GET /api/categories - List categories
  - POST /api/products - Create product (admin only)
  - PUT /api/products/{id} - Update product (admin only)
  
- **Events Published**:
  - ProductCreated, ProductUpdated, ProductDeleted
  - InventoryChanged, ProductOutOfStock
  
- **Events Consumed**:
  - OrderPlaced (to update inventory)
  - PaymentConfirmed (to reserve inventory)

### Dependencies
- **Upstream Services**: None (master data)
- **Downstream Services**: Order Service (inventory updates)
- **External Systems**: Product image storage, search index

### Technology Considerations
- **Database**: SQL Server (relational data, ACID transactions)
- **Caching**: Redis for frequently accessed products
- **Performance**: High read volume, moderate write volume
```

## 🏋️ Task 3: Data Consistency Strategy (30 minutes)

### Step 1: Identify Data Consistency Challenges
For each cross-service business process, identify consistency requirements:

**Template:**
```markdown
## Business Process: [Process Name]

### Services Involved
- Service A: [Role in process]
- Service B: [Role in process]
- Service C: [Role in process]

### Consistency Requirements
- **Strong Consistency**: What must be immediately consistent?
- **Eventual Consistency**: What can be eventually consistent?
- **Compensation**: How to handle failures?

### Recommended Pattern
- [ ] Saga Pattern (Orchestration)
- [ ] Saga Pattern (Choreography)
- [ ] Two-Phase Commit
- [ ] Event Sourcing
- [ ] CQRS

### Implementation Strategy
- Detailed steps for implementation
- Failure handling approach
- Monitoring and alerting
```

### Step 2: Design Saga Patterns
Choose 2-3 critical business processes and design saga implementations:

**Example: Order Processing Saga**

```markdown
## Saga: Order Processing

### Participants
1. Order Service - Creates order
2. Inventory Service - Reserves items
3. Payment Service - Processes payment
4. Shipping Service - Arranges delivery
5. Notification Service - Sends confirmations

### Orchestration Steps
1. Order Service creates order (status: PENDING)
2. Order Service → Inventory Service: Reserve items
3. If reservation success → Payment Service: Process payment
4. If payment success → Shipping Service: Arrange delivery
5. If shipping success → Order Service: Complete order
6. Notification Service: Send order confirmation

### Compensation Steps (Rollback)
1. If shipping fails → Payment Service: Refund payment
2. If payment fails → Inventory Service: Release reservation
3. If inventory fails → Order Service: Cancel order
4. Notification Service: Send cancellation notice

### Implementation
- Use MediatR for orchestration
- Store saga state in Order Service
- Use outbox pattern for reliable messaging
- Implement timeout handling
```

## 🔧 Task 4: Technology Stack Selection (15 minutes)

For each service, choose appropriate technologies:

**Template:**
```markdown
## Service Technology Stack

### [Service Name]
- **Framework**: ASP.NET Core 8.0
- **Database**: [SQL Server/PostgreSQL/MongoDB] - [Reasoning]
- **Caching**: [Redis/In-Memory] - [Reasoning]
- **Messaging**: [RabbitMQ/Azure Service Bus] - [Reasoning]
- **Authentication**: [JWT/OAuth2] - [Reasoning]
- **Monitoring**: [Application Insights/Prometheus] - [Reasoning]
- **Container**: Docker
- **Orchestration**: [Docker Compose/Kubernetes] - [Reasoning]
```

## 📝 Deliverables

Create the following documents:

1. **Domain Analysis Report** (domain-analysis.md)
2. **Service Design Document** (service-design.md)
3. **Data Consistency Strategy** (data-consistency.md)
4. **Technology Stack Decisions** (technology-stack.md)
5. **Service Architecture Diagram** (Use draw.io or similar)

## 🎯 Success Criteria

### **Excellent (90-100%)**
- ✅ Correctly identified all bounded contexts
- ✅ Designed services with clear responsibilities
- ✅ Proper data ownership and no shared databases
- ✅ Well-defined API contracts and event schemas
- ✅ Appropriate consistency patterns for business processes
- ✅ Justified technology choices

### **Good (80-89%)**
- ✅ Identified most bounded contexts
- ✅ Services have mostly clear boundaries
- ✅ Some minor data ownership issues
- ✅ Basic API design completed
- ✅ Consistency patterns identified but not detailed

### **Satisfactory (70-79%)**
- ✅ Basic service decomposition completed
- ✅ Some services may have overlapping responsibilities
- ✅ Limited consideration of data consistency
- ✅ Basic technology choices made

## 💡 Tips for Success

1. **Think Business First**: Start with business capabilities, not technical concerns
2. **Single Responsibility**: Each service should have one clear purpose
3. **Data Ownership**: Never share databases between services
4. **Embrace Eventual Consistency**: Not everything needs to be immediately consistent
5. **Start Simple**: Begin with fewer services and split later if needed
6. **Consider Team Structure**: Services should align with team boundaries

## 🔗 Resources

- **Domain-Driven Design**: [DDD Reference](https://domainlanguage.com/ddd/)
- **Microservices Patterns**: [Microservices.io](https://microservices.io/)
- **Service Decomposition**: [Martin Fowler's Blog](https://martinfowler.com/articles/microservices.html)

## ⏭️ Next Steps

After completing this exercise:
- Review your design with peers or instructor
- Proceed to Exercise 2: Building Core Services
- Use your design as the blueprint for implementation

**Remember: Good service design is the foundation of successful microservices architecture! 🏗️**