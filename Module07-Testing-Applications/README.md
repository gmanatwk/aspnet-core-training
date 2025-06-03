# Module 7: Testing Applications in ASP.NET Core

## 🎯 Learning Objectives
By the end of this module, you will be able to:
- Set up comprehensive testing environments for ASP.NET Core applications
- Write effective unit tests using xUnit and NUnit frameworks
- Implement integration tests with TestServer and WebApplicationFactory
- Use mocking frameworks (Moq, NSubstitute) for dependency isolation
- Apply Test-Driven Development (TDD) principles
- Perform performance and load testing
- Implement end-to-end testing strategies
- Understand testing best practices and patterns

## 📚 Module Overview
This module covers comprehensive testing strategies for ASP.NET Core applications, from unit testing individual components to full integration testing of web APIs. You'll learn industry-standard testing frameworks, mocking techniques, and how to build reliable test suites that ensure code quality and maintainability.

## 🕒 Estimated Duration: 3 hours

---

## 📖 Table of Contents

### 1. Testing Fundamentals
- Testing pyramid concepts
- Types of tests (Unit, Integration, End-to-End)
- Test-Driven Development (TDD) vs Behavior-Driven Development (BDD)
- Arrange-Act-Assert pattern

### 2. Unit Testing with xUnit
- Setting up xUnit test projects
- Writing effective unit tests
- Test data and theory attributes
- Test fixtures and collections
- Parameterized tests

### 3. Mocking and Test Doubles
- Understanding test doubles (Mock, Stub, Fake, Spy)
- Using Moq framework
- NSubstitute alternatives
- Mocking dependencies and external services
- Verifying method calls and behaviors

### 4. Integration Testing
- WebApplicationFactory setup
- TestServer configuration
- Database testing with InMemory providers
- Authentication testing
- API endpoint testing

### 5. Testing Controllers and Services
- Testing MVC controllers
- Testing Web API controllers
- Service layer testing
- Repository pattern testing
- Validation testing

### 6. Testing Entity Framework
- Testing with InMemory database
- Using SQLite for testing
- Repository and Unit of Work testing
- Migration testing

### 7. Performance and Load Testing
- Benchmarking with BenchmarkDotNet
- Load testing strategies
- Memory leak detection
- Performance profiling

### 8. Advanced Testing Patterns
- Test containers for external dependencies
- Custom test attributes
- Test data builders
- Snapshot testing

---

## 🛠️ Prerequisites
- Completion of Modules 1-6
- Understanding of ASP.NET Core fundamentals
- Knowledge of Entity Framework Core
- Basic understanding of dependency injection

## 📦 Required NuGet Packages
```xml
<!-- Testing Framework -->
<PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.8.0" />
<PackageReference Include="xunit" Version="2.4.2" />
<PackageReference Include="xunit.runner.visualstudio" Version="2.4.5" />

<!-- ASP.NET Core Testing -->
<PackageReference Include="Microsoft.AspNetCore.Mvc.Testing" Version="8.0.0" />
<PackageReference Include="Microsoft.EntityFrameworkCore.InMemory" Version="8.0.0" />

<!-- Mocking -->
<PackageReference Include="Moq" Version="4.20.69" />
<PackageReference Include="NSubstitute" Version="5.1.0" />

<!-- Test Data -->
<PackageReference Include="Bogus" Version="34.0.2" />
<PackageReference Include="AutoFixture" Version="4.18.0" />

<!-- Performance Testing -->
<PackageReference Include="BenchmarkDotNet" Version="0.13.8" />
```

---

## 🔥 Key Concepts Covered

### Testing Strategy
Understanding how to structure tests for maximum coverage and maintainability while avoiding common testing anti-patterns.

### Unit Testing Best Practices
Learn to write fast, reliable, and maintainable unit tests that provide meaningful feedback when they fail.

### Integration Testing Patterns
Master the art of testing complete application workflows while maintaining test isolation and performance.

### Mocking Strategies
Understand when and how to use mocks effectively without making tests brittle or difficult to maintain.

### Test Data Management
Learn various approaches to managing test data, from simple inline data to sophisticated test data builders.

---

## 🏗️ Project Structure
```
Module07-Testing-Applications/
├── README.md
├── SourceCode/
│   ├── ProductCatalog.API/          # Main API to test
│   ├── ProductCatalog.UnitTests/    # Unit tests
│   ├── ProductCatalog.IntegrationTests/ # Integration tests
│   └── ProductCatalog.PerformanceTests/ # Performance tests
├── Exercises/
│   ├── Exercise01-Unit-Testing-Basics.md
│   ├── Exercise02-Integration-Testing.md
│   ├── Exercise03-Mocking-External-Services.md
│   └── Exercise04-Performance-Testing.md
└── Resources/
    ├── testing-best-practices.md
    ├── tdd-workflow-guide.md
    └── test-naming-conventions.md
```

---

## 🎯 Learning Path

### Phase 1: Foundation (45 minutes)
1. **Testing Fundamentals** - Understanding the testing pyramid
2. **Unit Testing Setup** - Creating and configuring test projects
3. **First Unit Tests** - Writing basic tests with xUnit

### Phase 2: Core Testing Skills (60 minutes)
1. **Mocking Dependencies** - Using Moq for isolation
2. **Testing Controllers** - API controller testing patterns
3. **Service Testing** - Business logic testing

### Phase 3: Integration Testing (60 minutes)
1. **WebApplicationFactory** - Setting up integration tests
2. **Database Testing** - Testing with Entity Framework
3. **Authentication Testing** - Testing secured endpoints

### Phase 4: Advanced Topics (35 minutes)
1. **Performance Testing** - Load and benchmark testing
2. **Test Optimization** - Making tests fast and reliable
3. **CI/CD Integration** - Running tests in pipelines

---

## 📋 Hands-On Exercises

### Exercise 1: Unit Testing Basics
Create comprehensive unit tests for a service class, covering all public methods and edge cases.

### Exercise 2: Integration Testing
Build integration tests for a complete Web API, including database operations and authentication.

### Exercise 3: Mocking External Services
Implement tests that mock external API calls and database operations using Moq.

### Exercise 4: Performance Testing
Create performance benchmarks and load tests for critical application endpoints.

---

## 🎓 Assessment Criteria
- Ability to write comprehensive unit tests
- Understanding of integration testing concepts
- Proper use of mocking frameworks
- Implementation of testing best practices
- Knowledge of performance testing strategies

---

## 📚 Additional Resources
- [ASP.NET Core Testing Documentation](https://docs.microsoft.com/en-us/aspnet/core/test/)
- [xUnit Documentation](https://xunit.net/)
- [Moq Documentation](https://github.com/moq/moq4)
- [Testing Best Practices](https://docs.microsoft.com/en-us/dotnet/core/testing/best-practices)

---

## 🚀 Next Steps
After completing this module, you'll be ready to:
- Module 8: Performance Optimization
- Implement comprehensive test suites in real projects
- Apply TDD/BDD methodologies
- Set up automated testing in CI/CD pipelines

---

**📌 Note**: This module includes working code examples that demonstrate real-world testing scenarios. All examples are designed to be practical and immediately applicable to production applications.
