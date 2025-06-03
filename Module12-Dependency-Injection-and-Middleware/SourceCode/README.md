# Module 12 Source Code Examples

## 📁 **Directory Structure**

```
SourceCode/
├── DILifetimeDemo/              # Service lifetime demonstrations
│   ├── Controllers/
│   ├── Services/
│   ├── Program.cs
│   └── DILifetimeDemo.csproj
├── MiddlewarePipeline/          # Custom middleware implementations
│   ├── Middleware/
│   ├── Controllers/
│   ├── Program.cs
│   └── MiddlewarePipeline.csproj
├── AdvancedDIPatterns/          # Factory and decorator patterns
│   ├── Factories/
│   ├── Decorators/
│   ├── Services/
│   ├── Program.cs
│   └── AdvancedDIPatterns.csproj
└── ProductionIntegration/       # Complete application example
    ├── Domain/
    ├── Infrastructure/
    ├── Business/
    ├── Controllers/
    ├── Middleware/
    ├── Health/
    ├── Configuration/
    ├── Program.cs
    └── ProductionIntegration.csproj
```

## 🎯 **Source Code Overview**

### **1. DILifetimeDemo**
- Service lifetime demonstrations (Singleton, Scoped, Transient)
- Resource management examples
- Concurrent access scenarios
- Performance comparisons
- Disposal pattern implementations

### **2. MiddlewarePipeline**
- Custom middleware implementations
- Pipeline configuration examples
- Error handling patterns
- Security middleware integration
- Performance monitoring middleware

### **3. AdvancedDIPatterns**
- Factory pattern implementations
- Decorator pattern examples
- Generic services implementation
- Multiple implementations handling
- Configuration-driven services

### **4. ProductionIntegration**
- Complete application example combining all concepts
- Layered architecture with DI
- Comprehensive middleware pipeline
- Environment-specific configuration
- Health checks and monitoring
- Error handling and logging

## 🚀 **Running the Examples**

### **Prerequisites**
- .NET 8.0 SDK
- Visual Studio 2022 or VS Code
- Postman (for testing APIs)

### **Quick Start**

1. **Navigate to any project directory:**
   ```bash
   cd SourceCode/DILifetimeDemo
   ```

2. **Restore packages:**
   ```bash
   dotnet restore
   ```

3. **Run the application:**
   ```bash
   dotnet run
   ```

4. **Test the endpoints:**
   ```bash
   # For DILifetimeDemo
   curl -X GET "http://localhost:5000/api/lifetime/test-lifetimes"
   
   # For MiddlewarePipeline
   curl -X GET "http://localhost:5000/api/test/success"
   
   # For AdvancedDIPatterns
   curl -X POST "http://localhost:5000/api/advanceddi/send-notification" \
     -H "Content-Type: application/json" \
     -d '{"recipient": "test@domain.com", "subject": "Test", "message": "Hello World"}'
   
   # For ProductionIntegration
   curl -X GET "http://localhost:5000/health"
   ```

## 📚 **Learning Path**

### **Recommended Order:**
1. **Start with DILifetimeDemo** to understand service lifetimes
2. **Move to MiddlewarePipeline** to learn middleware concepts
3. **Explore AdvancedDIPatterns** for complex scenarios
4. **Study ProductionIntegration** for real-world application

### **Key Learning Points:**
- **Service Lifetime Management**: When to use Singleton, Scoped, and Transient
- **Middleware Pipeline**: Order, configuration, and custom implementations
- **Design Patterns**: Factory, Decorator, and Repository patterns with DI
- **Production Readiness**: Monitoring, health checks, and error handling

## 🎓 **Educational Value**

Each project demonstrates:
- ✅ **Best Practices**: Industry-standard patterns and implementations
- ✅ **Real-World Scenarios**: Practical examples you'll encounter in production
- ✅ **Progressive Complexity**: From basic concepts to advanced enterprise patterns
- ✅ **Comprehensive Coverage**: All aspects of DI and middleware in ASP.NET Core
- ✅ **Production Ready**: Code that can be adapted for real applications

## 🔧 **Customization**

Feel free to:
- Modify configurations to see different behaviors
- Add your own middleware implementations
- Experiment with different service lifetimes
- Extend the patterns for your specific use cases
- Use as a foundation for your own projects

---

**Happy Learning! 🚀** These examples provide a solid foundation for mastering dependency injection and middleware in ASP.NET Core applications.