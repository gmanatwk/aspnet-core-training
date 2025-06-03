# Module 5: Entity Framework Core

## 🎯 Learning Objectives
By the end of this module, participants will be able to:
- Set up Entity Framework Core in ASP.NET Core applications
- Implement Code-First approach with migrations
- Create and configure DbContext and entity models
- Perform CRUD operations using EF Core
- Write efficient LINQ queries
- Implement repository pattern with EF Core
- Optimize database queries for performance
- Handle database relationships and navigation properties
- Work with database transactions and concurrency

## 📚 Module Overview
**Duration**: 2 hours  
**Difficulty**: Intermediate  
**Prerequisites**: Module 3 (Working with Web APIs), Basic SQL knowledge

### What You'll Learn
Entity Framework Core is a lightweight, extensible, and cross-platform Object-Relational Mapping (ORM) framework for .NET. This module covers everything from basic setup to advanced query optimization techniques.

## 🏗️ Topics Covered

### 1. Entity Framework Core Fundamentals
- What is Entity Framework Core?
- Code-First vs Database-First approach
- Setting up EF Core in ASP.NET Core
- Connection strings and configuration

### 2. DbContext and Entity Models
- Creating and configuring DbContext
- Entity model conventions
- Data annotations vs Fluent API
- Entity relationships (One-to-One, One-to-Many, Many-to-Many)

### 3. Migrations and Database Management
- Creating and applying migrations
- Migration best practices
- Seeding data
- Handling production migrations

### 4. LINQ Queries with EF Core
- Basic LINQ operations
- Filtering, sorting, and grouping
- Joins and navigation properties
- Async query operations

### 5. Repository Pattern Implementation
- Benefits of repository pattern
- Generic repository implementation
- Unit of Work pattern
- Dependency injection with repositories

### 6. Performance Optimization
- Query optimization techniques
- Eager vs Lazy loading
- Explicit loading strategies
- Query performance monitoring

## 🚀 Hands-On Lab: Product Catalog System

### Lab Overview
Build a complete product catalog system with the following features:
- Product and Category management
- CRUD operations with EF Core
- Advanced querying and filtering
- Performance optimization

### Lab Components
- **Models**: Product, Category, ProductCategory (Many-to-Many)
- **DbContext**: ProductCatalogContext with relationships
- **Repository**: Generic repository with specific implementations
- **API Controllers**: Products and Categories with full CRUD
- **Migrations**: Database schema and seed data

## 📁 Project Structure
```
EFCoreDemo/
├── EFCoreDemo.csproj
├── Program.cs
├── appsettings.json
├── Data/
│   ├── ProductCatalogContext.cs
│   └── DbInitializer.cs
├── Models/
│   ├── Product.cs
│   ├── Category.cs
│   └── ProductCategory.cs
├── Repositories/
│   ├── IRepository.cs
│   ├── Repository.cs
│   ├── IProductRepository.cs
│   ├── ProductRepository.cs
│   ├── ICategoryRepository.cs
│   └── CategoryRepository.cs
├── Controllers/
│   ├── ProductsController.cs
│   └── CategoriesController.cs
├── DTOs/
│   ├── ProductDto.cs
│   └── CategoryDto.cs
└── Migrations/
    └── (Generated migration files)
```

## 🛠️ Key Implementation Features

### Code-First Approach
- Entity model configuration using Data Annotations and Fluent API
- Complex relationships with proper foreign keys
- Database constraints and indexes

### LINQ Query Examples
```csharp
// Complex queries with navigation properties
var productsWithCategories = await _context.Products
    .Include(p => p.ProductCategories)
    .ThenInclude(pc => pc.Category)
    .Where(p => p.IsActive)
    .OrderBy(p => p.Name)
    .ToListAsync();

// Efficient pagination
var pagedProducts = await _context.Products
    .Skip((page - 1) * pageSize)
    .Take(pageSize)
    .ToListAsync();
```

### Repository Pattern
```csharp
// Generic repository interface
public interface IRepository<T> where T : class
{
    Task<IEnumerable<T>> GetAllAsync();
    Task<T> GetByIdAsync(int id);
    Task<T> AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(int id);
}

// Specific product repository with advanced queries
public interface IProductRepository : IRepository<Product>
{
    Task<IEnumerable<Product>> GetProductsByCategoryAsync(int categoryId);
    Task<IEnumerable<Product>> SearchProductsAsync(string searchTerm);
    Task<decimal> GetAveragePriceAsync();
}
```

### Performance Optimization
- Query performance monitoring with logging
- Efficient loading strategies
- Database indexing recommendations
- Connection pooling configuration

## 🎯 Learning Activities

### Activity 1: Model Creation and Relationships (20 minutes)
Create entity models with proper relationships and data annotations.

### Activity 2: DbContext Configuration (15 minutes)
Set up DbContext with connection strings and model configuration.

### Activity 3: Migrations and Database Setup (20 minutes)
Create initial migration and seed sample data.

### Activity 4: Repository Implementation (25 minutes)
Implement generic repository and specific repositories for entities.

### Activity 5: API Controllers with EF Core (15 minutes)
Create controllers that use repositories for data access.

### Activity 6: Query Optimization (25 minutes)
Implement complex queries and optimize for performance.

## 📋 Exercises

### Exercise 1: Basic CRUD Operations
**Objective**: Implement basic Create, Read, Update, Delete operations using EF Core
**Time**: 30 minutes
**Skills**: DbContext usage, basic LINQ queries

### Exercise 2: Advanced Querying
**Objective**: Write complex LINQ queries with joins and aggregations
**Time**: 25 minutes
**Skills**: LINQ, navigation properties, performance considerations

### Exercise 3: Repository Pattern Implementation
**Objective**: Refactor direct EF Core usage to repository pattern
**Time**: 35 minutes
**Skills**: Design patterns, dependency injection, abstraction

## 🔧 Technology Stack
- **Framework**: ASP.NET Core 8.0
- **ORM**: Entity Framework Core 8.0
- **Database**: SQL Server (LocalDB for development)
- **Packages**: 
  - Microsoft.EntityFrameworkCore.SqlServer
  - Microsoft.EntityFrameworkCore.Tools
  - Microsoft.EntityFrameworkCore.Design

## 📚 Additional Resources

### Official Documentation
- [Entity Framework Core Documentation](https://docs.microsoft.com/en-us/ef/core/)
- [EF Core Performance Guidelines](https://docs.microsoft.com/en-us/ef/core/performance/)

### Best Practices
- Always use async methods for database operations
- Implement proper error handling and logging
- Use connection pooling in production
- Monitor query performance regularly
- Keep migrations small and focused

### Common Pitfalls to Avoid
- N+1 query problems (use Include() appropriately)
- Loading entire datasets when only specific columns needed
- Not disposing DbContext properly
- Using tracking queries when read-only data is sufficient

## ✅ Module Completion Checklist
- [ ] Understand EF Core fundamentals and setup
- [ ] Can create and configure DbContext
- [ ] Able to work with entity models and relationships
- [ ] Proficient in creating and applying migrations
- [ ] Can write efficient LINQ queries
- [ ] Understand repository pattern implementation
- [ ] Know performance optimization techniques
- [ ] Completed all hands-on exercises
- [ ] Built the complete Product Catalog system

## 🔄 What's Next?
After completing this module, you'll be ready for:
- **Module 6**: Debugging and Troubleshooting
- **Module 7**: Testing Applications (including EF Core testing strategies)
- **Module 8**: Performance Optimization (advanced database performance)

---

**Note**: This module focuses on practical implementation. Ensure you have SQL Server LocalDB installed for the hands-on exercises.
