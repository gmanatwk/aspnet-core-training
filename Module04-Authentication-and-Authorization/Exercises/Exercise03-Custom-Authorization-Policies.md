# Exercise 3: Custom Authorization Policies

## 🎯 Objective
Create custom authorization policies with complex business logic and requirements.

## ⏱️ Time Allocation: 45 minutes

## 📋 Prerequisites
- Completed Exercises 1 & 2
- Understanding of policy-based authorization
- Knowledge of claims and requirements

## 🎯 Learning Goals
By completing this exercise, you will:
- ✅ Understand policy-based authorization concepts
- ✅ Create custom authorization requirements
- ✅ Implement authorization handlers
- ✅ Combine multiple authorization criteria
- ✅ Handle complex business authorization logic

## 📝 Tasks

### Task 1: Create Custom Requirements (15 minutes)

1. **Create Requirements folder** and implement:

**MinimumAgeRequirement.cs**:
```csharp
public class MinimumAgeRequirement : IAuthorizationRequirement
{
    public int MinimumAge { get; }
    
    public MinimumAgeRequirement(int minimumAge)
    {
        MinimumAge = minimumAge;
    }
}
```

**DepartmentRequirement.cs**:
```csharp
public class DepartmentRequirement : IAuthorizationRequirement
{
    public string[] AllowedDepartments { get; }
    
    public DepartmentRequirement(params string[] departments)
    {
        AllowedDepartments = departments;
    }
}
```

**WorkingHoursRequirement.cs**:
```csharp
public class WorkingHoursRequirement : IAuthorizationRequirement
{
    public TimeSpan StartTime { get; }
    public TimeSpan EndTime { get; }
    
    public WorkingHoursRequirement(TimeSpan startTime, TimeSpan endTime)
    {
        StartTime = startTime;
        EndTime = endTime;
    }
}
```

### Task 2: Implement Authorization Handlers (20 minutes)

1. **Create Handlers folder** and implement handlers:

**MinimumAgeHandler.cs**:
```csharp
public class MinimumAgeHandler : AuthorizationHandler<MinimumAgeRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        MinimumAgeRequirement requirement)
    {
        var birthDateClaim = context.User.FindFirst("birthdate");
        
        if (birthDateClaim != null && DateTime.TryParse(birthDateClaim.Value, out var birthDate))
        {
            var age = DateTime.Today.Year - birthDate.Year;
            if (birthDate > DateTime.Today.AddYears(-age)) age--;
            
            if (age >= requirement.MinimumAge)
            {
                context.Succeed(requirement);
            }
        }
        
        return Task.CompletedTask;
    }
}
```

2. **Implement additional handlers** for department and working hours requirements

### Task 3: Configure Complex Policies (10 minutes)

1. **Add policies in Program.cs**:
```csharp
builder.Services.AddAuthorization(options =>
{
    // Age-based policy
    options.AddPolicy("Adult", policy =>
        policy.Requirements.Add(new MinimumAgeRequirement(18)));
    
    // Department-based policy
    options.AddPolicy("ITDepartment", policy =>
        policy.Requirements.Add(new DepartmentRequirement("IT", "Development")));
    
    // Working hours policy
    options.AddPolicy("BusinessHours", policy =>
        policy.Requirements.Add(new WorkingHoursRequirement(
            new TimeSpan(9, 0, 0), 
            new TimeSpan(17, 0, 0))));
    
    // Complex combined policy
    options.AddPolicy("SeniorITStaff", policy =>
    {
        policy.RequireRole("Employee");
        policy.Requirements.Add(new MinimumAgeRequirement(25));
        policy.Requirements.Add(new DepartmentRequirement("IT"));
    });
});
```

2. **Register authorization handlers**:
```csharp
builder.Services.AddScoped<IAuthorizationHandler, MinimumAgeHandler>();
builder.Services.AddScoped<IAuthorizationHandler, DepartmentHandler>();
builder.Services.AddScoped<IAuthorizationHandler, WorkingHoursHandler>();
```

## 🧪 Testing Scenarios

### Test User Profiles:
```json
// Senior IT Developer
{
  "username": "senior_dev",
  "password": "pass123",
  "roles": ["Employee", "Developer"],
  "claims": {
    "birthdate": "1985-05-15",
    "department": "IT",
    "position": "Senior Developer"
  }
}

// Young Marketing User
{
  "username": "young_marketing",
  "password": "pass123", 
  "roles": ["Employee"],
  "claims": {
    "birthdate": "2000-03-10",
    "department": "Marketing",
    "position": "Marketing Assistant"
  }
}
```

### Policy Test Matrix:
| Policy | Senior IT Dev | Young Marketing | Admin |
|--------|---------------|-----------------|-------|
| Adult | ✅ (Age 38) | ✅ (Age 24) | ✅ |
| ITDepartment | ✅ | ❌ | ✅ |
| BusinessHours | ⏰ Time-dependent | ⏰ Time-dependent | ✅ |
| SeniorITStaff | ✅ | ❌ | ❌ |

## 🔧 Implementation Examples

### Resource-Based Authorization:
```csharp
public class DocumentEditRequirement : IAuthorizationRequirement
{
    // Empty - we'll check ownership in handler
}

public class DocumentEditHandler : 
    AuthorizationHandler<DocumentEditRequirement, Document>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        DocumentEditRequirement requirement,
        Document document)
    {
        var userId = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        
        // Allow if user owns document or is admin
        if (document.OwnerId == userId || context.User.IsInRole("Admin"))
        {
            context.Succeed(requirement);
        }
        
        return Task.CompletedTask;
    }
}
```

### Controller Usage:
```csharp
[ApiController]
[Route("api/[controller]")]
public class SecureController : ControllerBase
{
    [HttpGet("adult-content")]
    [Authorize(Policy = "Adult")]
    public IActionResult GetAdultContent()
    {
        return Ok("Age-restricted content");
    }
    
    [HttpGet("it-tools")]
    [Authorize(Policy = "ITDepartment")]
    public IActionResult GetITTools()
    {
        return Ok("IT department tools");
    }
    
    [HttpPost("senior-action")]
    [Authorize(Policy = "SeniorITStaff")]
    public IActionResult PerformSeniorAction()
    {
        return Ok("Senior IT staff action completed");
    }
}
```

## 📊 Advanced Scenarios

### Scenario 1: Time-Based Access
- Create endpoints only accessible during business hours
- Test access during and outside business hours
- Handle timezone considerations

### Scenario 2: Resource Ownership
- Implement document/resource ownership checks
- Allow users to edit only their own resources
- Admin override for all resources

### Scenario 3: Conditional Access
- Combine multiple requirements with OR logic
- Create fallback authorization paths
- Implement temporary access grants

## ❓ Verification Questions

1. **What's the difference between requirements and handlers?**
2. **How do you combine multiple requirements in a single policy?**
3. **When would you use resource-based authorization?**
4. **How do you handle OR logic between requirements?**
5. **What happens if a handler doesn't call Succeed() or Fail()?**

## 💡 Challenge Tasks (Bonus)

### Challenge 1: Geographic Authorization
- Implement location-based access control
- Check user's IP address or GPS coordinates
- Allow access only from specific locations

### Challenge 2: Dynamic Policies
- Create policies that change based on configuration
- Implement feature flags in authorization
- Allow runtime policy modifications

### Challenge 3: Audit Trail
- Log all authorization decisions
- Track failed authorization attempts
- Create security reports

## 🔍 Testing Commands

### Test Custom Policies:
```bash
# 1. Login and get token with claims
POST /api/auth/login
{
  "username": "senior_dev",
  "password": "pass123"
}

# 2. Test age-restricted endpoint
GET /api/secure/adult-content
Authorization: Bearer {{token}}

# 3. Test department-restricted endpoint  
GET /api/secure/it-tools
Authorization: Bearer {{token}}

# 4. Test complex policy
POST /api/secure/senior-action
Authorization: Bearer {{token}}
```

## ✅ Completion Criteria

You have successfully completed this exercise when:
- ✅ Custom requirements are properly implemented
- ✅ Authorization handlers correctly evaluate requirements
- ✅ Complex policies work with multiple requirements
- ✅ Resource-based authorization functions correctly
- ✅ All test scenarios pass as expected

## 🆘 Troubleshooting Guide

**Policy Not Working:**
- Ensure handlers are registered in DI container
- Check if requirements are added to policies correctly
- Verify claims are present in JWT token

**Handler Not Called:**
- Confirm handler implements correct interface
- Check if requirement type matches
- Ensure DI registration is correct

**Claims Missing:**
- Add claims during token generation
- Verify claim names match exactly
- Check token structure with JWT debugger

---

**Pro Tip**: Use policy-based authorization for complex business rules and role-based authorization for simple access control. Combine both approaches for maximum flexibility!