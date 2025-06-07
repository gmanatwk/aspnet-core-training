# Exercise 2: Advanced LINQ Queries and Navigation Properties

## 🎯 Objective
Master advanced LINQ queries with Entity Framework Core, including joins, navigation properties, and complex filtering scenarios.

## ⏱️ Time Allocation
**Total Time**: 25 minutes
- Entity Relationships Setup: 8 minutes
- Basic LINQ Queries: 7 minutes
- Advanced Query Scenarios: 10 minutes

## 🚀 Getting Started

### Step 1: Register BookQueryService
Add to Program.cs:

```csharp
builder.Services.AddScoped<BookQueryService>();
```

### Step 2: Create Migration
```bash
dotnet ef migrations add AddAuthorPublisherRelationships
dotnet ef database update
```

## ✅ Success Criteria
- [ ] All entities are properly configured with relationships
- [ ] Database migrations are created and applied successfully
- [ ] All basic LINQ queries return correct results
- [ ] Advanced queries with joins and aggregations work correctly
- [ ] Search functionality works across multiple tables

## 🧪 Testing Your Implementation
1. Run: `dotnet run`
2. Navigate to: http://localhost:5000/swagger
3. Test query methods through API endpoints
4. Verify complex relationships are loaded correctly

## 🎯 Learning Outcomes
After completing this exercise, you should understand:
- Entity relationships and navigation properties
- Advanced LINQ query techniques
- Include() and ThenInclude() for eager loading
- Complex joins and aggregations
- Search across multiple entities

