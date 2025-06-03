# Module 12: Dependency Injection & Middleware

## 📚 Module Overview
**Duration**: 2.5 hours  
**Skill Level**: Intermediate to Advanced  
**Prerequisites**: Modules 1-6 completed, familiarity with services and controllers

## 🎯 Learning Objectives

By the end of this module, you will be able to:

### Dependency Injection (DI)
- ✅ **Understand DI fundamentals** and the Inversion of Control (IoC) principle
- ✅ **Master service lifetimes** (Singleton, Scoped, Transient)
- ✅ **Configure complex services** with dependencies and interfaces
- ✅ **Implement advanced DI patterns** like factory and decorator patterns
- ✅ **Work with multiple implementations** using keyed services
- ✅ **Handle service disposal** and implement IDisposable correctly
- ✅ **Debug DI issues** and resolve circular dependencies

### Middleware
- ✅ **Understand the request pipeline** and middleware execution order
- ✅ **Create custom middleware** components for cross-cutting concerns
- ✅ **Configure middleware conditionally** based on environments
- ✅ **Implement middleware** for logging, authentication, error handling
- ✅ **Work with middleware parameters** and dependency injection
- ✅ **Handle short-circuiting** and branching in the pipeline
- ✅ **Optimize middleware performance** and avoid common pitfalls

## 📖 Module Content

### **Part 1: Dependency Injection Deep Dive** (1 hour)

#### **1.1 DI Fundamentals and IoC Principle**
- Understanding dependency inversion principle
- Benefits of dependency injection
- ASP.NET Core's built-in IoC container
- Service registration patterns

#### **1.2 Service Lifetimes Mastery**
- **Singleton**: Single instance for application lifetime
- **Scoped**: Per-request instance lifecycle
- **Transient**: New instance every time
- **Keyed Services**: Multiple implementations selection
- Lifetime scope scenarios and best practices

#### **1.3 Advanced DI Patterns**
- Interface segregation and multiple implementations
- Factory pattern with DI
- Decorator pattern for service enhancement
- Generic services and open generic registration
- Service location anti-pattern and alternatives

#### **1.4 Complex Service Configuration**
- Configuration binding to services
- Conditional service registration
- Service validation and health checks
- Circular dependency detection and resolution

### **Part 2: Middleware Architecture** (1 hour)

#### **2.1 Request Pipeline Understanding**
- Middleware execution order importance
- Pipeline termination vs continuation
- Understanding HttpContext flow
- Built-in middleware overview

#### **2.2 Creating Custom Middleware**
- Middleware class vs inline middleware
- Convention-based vs interface-based middleware
- Middleware with dependency injection
- Async middleware patterns

#### **2.3 Middleware Configuration Patterns**
- Conditional middleware registration
- Environment-specific middleware
- Middleware branching with Map and MapWhen
- Short-circuiting the pipeline

#### **2.4 Production Middleware Patterns**
- Error handling middleware
- Logging and diagnostics middleware
- Security middleware (CORS, HTTPS, Security Headers)
- Performance monitoring middleware

### **Part 3: Advanced Integration** (30 minutes)

#### **3.1 DI and Middleware Integration**
- Injecting services into middleware
- Middleware service scope considerations
- Middleware factory pattern
- Testing middleware with DI

#### **3.2 Performance and Best Practices**
- Service resolution performance
- Middleware ordering optimization
- Memory management considerations
- Common pitfalls and how to avoid them

## 🛠️ Hands-On Exercises

### **Exercise 1: Service Lifetime Exploration** (30 minutes)
**Objective**: Understand different service lifetimes through practical examples

**Tasks**:
1. Create services with different lifetimes (Singleton, Scoped, Transient)
2. Track service instance creation and disposal
3. Demonstrate lifetime behavior in controllers and middleware
4. Implement IDisposable properly
5. Test with concurrent requests

**Learning Outcomes**:
- Clear understanding of when to use each lifetime
- Proper resource management patterns
- Thread safety considerations

### **Exercise 2: Custom Middleware Development** (45 minutes)
**Objective**: Build production-ready custom middleware components

**Tasks**:
1. Create request/response logging middleware
2. Implement API rate limiting middleware
3. Build request correlation ID middleware
4. Create custom error handling middleware
5. Configure conditional middleware execution

**Learning Outcomes**:
- Middleware development patterns
- Cross-cutting concerns implementation
- Pipeline configuration strategies

### **Exercise 3: Advanced DI Patterns** (30 minutes)
**Objective**: Implement complex dependency injection scenarios

**Tasks**:
1. Multiple service implementations with factory pattern
2. Decorator pattern for service enhancement
3. Generic service registration
4. Configuration-based service selection
5. Circular dependency resolution

**Learning Outcomes**:
- Advanced architectural patterns
- Flexible service configuration
- Design pattern implementation

### **Exercise 4: Production Integration** (35 minutes)
**Objective**: Integrate DI and middleware in a realistic application

**Tasks**:
1. Build a complete API with layered architecture
2. Implement comprehensive middleware pipeline
3. Add health checks and monitoring
4. Configure different environments (Dev, Staging, Prod)
5. Performance testing and optimization

**Learning Outcomes**:
- End-to-end application architecture
- Production-ready configuration
- Performance optimization techniques

## 💻 Source Code Examples

### **Complete Demo Applications**:

1. **`DILifetimeDemo/`**
   - Service lifetime demonstrations
   - Resource management examples
   - Concurrent access scenarios
   - Performance comparisons

2. **`MiddlewarePipeline/`**
   - Custom middleware implementations
   - Pipeline configuration examples
   - Error handling patterns
   - Security middleware integration

3. **`AdvancedDIPatterns/`**
   - Factory and decorator patterns
   - Generic services implementation
   - Multiple implementations handling
   - Configuration-driven services

4. **`ProductionIntegration/`**
   - Complete application example
   - Layered architecture with DI
   - Comprehensive middleware pipeline
   - Environment-specific configuration

## 📚 Resources & References

### **Best Practices Guides**:
- 📖 **`dependency-injection-best-practices.md`** - Comprehensive DI guidelines
- 📖 **`middleware-patterns-guide.md`** - Common middleware patterns
- 📖 **`performance-optimization.md`** - DI and middleware performance
- 📖 **`troubleshooting-guide.md`** - Common issues and solutions

### **Reference Materials**:
- 🔗 [Microsoft DI Documentation](https://docs.microsoft.com/aspnet/core/fundamentals/dependency-injection)
- 🔗 [ASP.NET Core Middleware](https://docs.microsoft.com/aspnet/core/fundamentals/middleware)
- 🔗 [Service Lifetimes in Detail](https://docs.microsoft.com/aspnet/core/fundamentals/dependency-injection#service-lifetimes)

## 🎯 Module Assessment

### **Knowledge Check Questions**:
1. When should you use Singleton vs Scoped vs Transient lifetimes?
2. How do you handle middleware ordering for security requirements?
3. What are the best practices for implementing IDisposable in services?
4. How do you resolve circular dependencies in DI?
5. When should you use middleware vs action filters?

### **Practical Assessment**:
- Build a multi-layered API with proper DI configuration
- Implement a custom middleware pipeline for cross-cutting concerns
- Demonstrate understanding of service lifetimes in practice
- Show proper error handling and resource management

## 🚀 Real-World Applications

### **Industry Use Cases**:
1. **Enterprise Applications**: Complex service hierarchies and middleware pipelines
2. **Microservices**: Service communication and shared concerns
3. **High-Performance APIs**: Optimized DI and middleware configurations
4. **Multi-Tenant Applications**: Tenant-specific service resolution

### **Career Benefits**:
- **Architecture Skills**: Understanding of modern application architecture
- **Performance Optimization**: Ability to optimize application performance
- **Code Quality**: Writing maintainable and testable code
- **Problem Solving**: Debugging complex DI and middleware issues

## 🎓 Next Steps

After completing this module:

1. **Module 13**: Building Microservices (applies DI patterns across services)
2. **Advanced Topics**: Custom DI containers, advanced middleware scenarios
3. **Practice Projects**: Build complete applications using learned patterns
4. **Performance Tuning**: Deep dive into optimization techniques

## 📞 Support & Troubleshooting

### **Common Issues**:
- Service resolution failures
- Circular dependency errors
- Middleware ordering problems
- Performance bottlenecks

### **Getting Help**:
- Review troubleshooting guide in Resources/
- Check exercise solutions for working examples
- Refer to Microsoft documentation for detailed specifications
- Practice with provided demo applications

---

## 🎯 Module Success Criteria

**You'll know you've mastered this module when you can**:
- ✅ Configure complex DI scenarios with confidence
- ✅ Build custom middleware for any cross-cutting concern
- ✅ Debug and resolve DI and middleware issues quickly
- ✅ Optimize application performance through proper service and middleware configuration
- ✅ Implement production-ready architectural patterns

**Time to build robust, well-architected ASP.NET Core applications! 🚀**