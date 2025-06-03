# Dependency Injection Best Practices

## 🎯 **Overview**
This guide covers comprehensive best practices for using dependency injection in ASP.NET Core applications, from basic service registration to advanced enterprise patterns.

## 📚 **Table of Contents**
1. [Service Registration Patterns](#service-registration-patterns)
2. [Service Lifetime Guidelines](#service-lifetime-guidelines)
3. [Interface Design Principles](#interface-design-principles)
4. [Advanced DI Patterns](#advanced-di-patterns)
5. [Performance Considerations](#performance-considerations)
6. [Testing with DI](#testing-with-di)
7. [Common Anti-Patterns](#common-anti-patterns)
8. [Troubleshooting Guide](#troubleshooting-guide)

---

## 🔧 **Service Registration Patterns**

### **1. Basic Registration Patterns**

```csharp
// ✅ Good: Use interfaces for abstraction
services.AddScoped<IUserService, UserService>();

// ✅ Good: Register concrete classes when no interface needed
services.AddScoped<EmailService>();

// ✅ Good: Use factory pattern for complex creation
services.AddScoped<IReportService>(provider =>
{
    var config = provider.GetRequiredService<ReportingConfig>();
    return new ReportService(config.ReportType);
});

// ❌ Bad: Registering concrete class as interface
services.AddScoped<UserService, UserService>(); // Should be IUserService
```

### **2. Conditional Registration**

```csharp
// ✅ Good: Environment-based registration
if (builder.Environment.IsDevelopment())
{
    services.AddScoped<IEmailService, MockEmailService>();
}
else
{
    services.AddScoped<IEmailService, SmtpEmailService>();
}

// ✅ Good: Configuration-driven registration
var emailProvider = builder.Configuration.GetValue<string>("EmailProvider");
switch (emailProvider?.ToLower())
{
    case "smtp":
        services.AddScoped<IEmailService, SmtpEmailService>();
        break;
    case "sendgrid":
        services.AddScoped<IEmailService, SendGridEmailService>();
        break;
    default:
        services.AddScoped<IEmailService, MockEmailService>();
        break;
}
```

### **3. Generic Service Registration**

```csharp
// ✅ Good: Open generic registration
services.AddScoped(typeof(IRepository<>), typeof(Repository<>));

// ✅ Good: Multiple generic registrations
services.AddScoped(typeof(ICommandHandler<>), typeof(CommandHandler<>));
services.AddScoped(typeof(IQueryHandler<,>), typeof(QueryHandler<,>));

// ✅ Good: Closed generic for specific types
services.AddScoped<IRepository<User>, UserRepository>();
```

---

## ⏰ **Service Lifetime Guidelines**

### **1. Singleton Lifetime**

**Use When:**
- Service is stateless
- Service is thread-safe
- Service is expensive to create
- Service maintains global state (caches, configuration)

```csharp
// ✅ Good: Configuration services
services.AddSingleton<IConfiguration>(configuration);

// ✅ Good: Caching services
services.AddSingleton<IMemoryCache, MemoryCache>();

// ✅ Good: Background services
services.AddSingleton<IHostedService, BackgroundTaskService>();

// ❌ Bad: Database contexts (not thread-safe)
services.AddSingleton<DbContext>(); // Use Scoped instead
```

### **2. Scoped Lifetime**

**Use When:**
- Service maintains state per request
- Service works with database contexts
- Service handles user-specific data

```csharp
// ✅ Good: Database contexts
services.AddScoped<ApplicationDbContext>();

// ✅ Good: Request-specific services
services.AddScoped<ICurrentUserService>();

// ✅ Good: Unit of Work pattern
services.AddScoped<IUnitOfWork, UnitOfWork>();

// ✅ Good: Business services
services.AddScoped<IOrderService, OrderService>();
```

### **3. Transient Lifetime**

**Use When:**
- Service is lightweight and stateless
- Service is used infrequently
- Each usage needs a fresh instance

```csharp
// ✅ Good: Lightweight services
services.AddTransient<IEmailValidator, EmailValidator>();

// ✅ Good: Factory services
services.AddTransient<IHttpClientFactory, HttpClientFactory>();

// ✅ Good: Data transfer objects
services.AddTransient<IMapper, AutoMapper>();
```

## 🎯 **Key Takeaways**

### **DO**
- ✅ Use constructor injection for required dependencies
- ✅ Design small, focused interfaces
- ✅ Choose appropriate service lifetimes
- ✅ Implement IDisposable when managing resources
- ✅ Write testable code with clear dependencies
- ✅ Validate service registration in development
- ✅ Use factory patterns for complex object creation
- ✅ Follow SOLID principles

### **DON'T**
- ❌ Use service locator pattern
- ❌ Create dependencies manually with 'new'
- ❌ Inject IServiceProvider unless absolutely necessary
- ❌ Create circular dependencies
- ❌ Use inappropriate service lifetimes
- ❌ Create god objects with too many dependencies
- ❌ Ignore dispose patterns for resource cleanup
- ❌ Forget to test dependency injection configuration

---

**Remember**: Good dependency injection practices lead to more maintainable, testable, and loosely coupled applications. Invest time in proper DI design - it pays dividends in the long run!