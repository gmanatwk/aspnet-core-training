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

1. **Create Requirements folder** and implement custom authorization requirements:

   **Requirements/MinimumAgeRequirement.cs**:
   ```csharp
   using Microsoft.AspNetCore.Authorization;

   namespace JwtAuthenticationAPI.Requirements;

   public class MinimumAgeRequirement : IAuthorizationRequirement
   {
       public int MinimumAge { get; }

       public MinimumAgeRequirement(int minimumAge)
       {
           MinimumAge = minimumAge;
       }
   }
   ```

   **Requirements/DepartmentRequirement.cs**:
   ```csharp
   using Microsoft.AspNetCore.Authorization;

   namespace JwtAuthenticationAPI.Requirements;

   public class DepartmentRequirement : IAuthorizationRequirement
   {
       public string[] AllowedDepartments { get; }

       public DepartmentRequirement(params string[] departments)
       {
           AllowedDepartments = departments;
       }
   }
   ```

   **Requirements/WorkingHoursRequirement.cs**:
   ```csharp
   using Microsoft.AspNetCore.Authorization;

   namespace JwtAuthenticationAPI.Requirements;

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

1. **Create Handlers folder** and implement authorization handlers:

   **Handlers/MinimumAgeHandler.cs**:
   ```csharp
   using Microsoft.AspNetCore.Authorization;
   using JwtAuthenticationAPI.Requirements;

   namespace JwtAuthenticationAPI.Handlers;

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

   **Handlers/DepartmentHandler.cs**:
   ```csharp
   using Microsoft.AspNetCore.Authorization;
   using JwtAuthenticationAPI.Requirements;

   namespace JwtAuthenticationAPI.Handlers;

   public class DepartmentHandler : AuthorizationHandler<DepartmentRequirement>
   {
       protected override Task HandleRequirementAsync(
           AuthorizationHandlerContext context,
           DepartmentRequirement requirement)
       {
           var departmentClaim = context.User.FindFirst("department");

           if (departmentClaim != null)
           {
               var userDepartment = departmentClaim.Value;

               if (requirement.AllowedDepartments.Contains(userDepartment, StringComparer.OrdinalIgnoreCase))
               {
                   context.Succeed(requirement);
               }
           }

           return Task.CompletedTask;
       }
   }
   ```

   **Handlers/WorkingHoursHandler.cs**:
   ```csharp
   using Microsoft.AspNetCore.Authorization;
   using JwtAuthenticationAPI.Requirements;

   namespace JwtAuthenticationAPI.Handlers;

   public class WorkingHoursHandler : AuthorizationHandler<WorkingHoursRequirement>
   {
       protected override Task HandleRequirementAsync(
           AuthorizationHandlerContext context,
           WorkingHoursRequirement requirement)
       {
           var currentTime = DateTime.Now.TimeOfDay;

           // Check if current time is within working hours
           if (currentTime >= requirement.StartTime && currentTime <= requirement.EndTime)
           {
               context.Succeed(requirement);
           }

           return Task.CompletedTask;
       }
   }
   ```

### Task 3: Configure Complex Policies and Controllers (10 minutes)

1. **Update Program.cs** to add custom authorization policies (add to existing authorization configuration):

   **Program.cs** (update authorization section):
   ```csharp
   using JwtAuthenticationAPI.Requirements;
   using JwtAuthenticationAPI.Handlers;

   // Configure Authorization with custom policies (add to existing policies)
   builder.Services.AddAuthorization(options =>
   {
       // Exercise 02 - Role-Based Policies (keep existing)
       options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
       options.AddPolicy("UserOrAdmin", policy => policy.RequireRole("User", "Admin"));
       options.AddPolicy("EditorOrAdmin", policy => policy.RequireRole("Editor", "Admin"));
       options.AddPolicy("UserOrAbove", policy => policy.RequireRole("User", "Editor", "Admin"));

       // Exercise 03 - Custom Authorization Policies
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

   // Register authorization handlers from Exercise 03
   builder.Services.AddScoped<IAuthorizationHandler, MinimumAgeHandler>();
   builder.Services.AddScoped<IAuthorizationHandler, DepartmentHandler>();
   builder.Services.AddScoped<IAuthorizationHandler, WorkingHoursHandler>();
   ```

2. **Update UserService.cs** to add users with custom claims for Exercise 3:

   **Services/UserService.cs** (update constructor with additional users):
   ```csharp
   public UserService(ILogger<UserService> logger)
   {
       _logger = logger;

       // In a real application, this would be replaced with a database
       _users = new List<User>
       {
           // Exercise 01 & 02 users
           new User
           {
               Id = 1,
               Username = "admin",
               Password = HashPassword("admin123"),
               Email = "admin@example.com",
               Roles = new List<string> { "Admin", "Editor", "User", "Employee" }
           },
           new User
           {
               Id = 2,
               Username = "user",
               Password = HashPassword("user123"),
               Email = "user@example.com",
               Roles = new List<string> { "User" }
           },
           new User
           {
               Id = 3,
               Username = "editor",
               Password = HashPassword("editor123"),
               Email = "editor@example.com",
               Roles = new List<string> { "Editor", "User" }
           },
           // Exercise 03 users - for custom policies
           new User
           {
               Id = 4,
               Username = "senior_dev",
               Password = HashPassword("senior123"),
               Email = "senior.dev@example.com",
               Roles = new List<string> { "Employee", "Developer" }
           },
           new User
           {
               Id = 5,
               Username = "junior_dev",
               Password = HashPassword("junior123"),
               Email = "junior.dev@example.com",
               Roles = new List<string> { "Employee", "Developer" }
           }
       };
   }
   ```

3. **Update JwtTokenService.cs** to add custom claims for Exercise 3 policies:

   **Services/JwtTokenService.cs** (add to GenerateToken method after role claims):
   ```csharp
   // Add custom claims for Exercise 03 demonstrations
   // Add birthdate claim for age-based policies
   if (user.Username == "admin" || user.Username == "senior_dev")
   {
       tokenDescriptor.Subject.AddClaim(new Claim("birthdate", "1985-05-15"));
   }
   else if (user.Username == "junior_dev")
   {
       tokenDescriptor.Subject.AddClaim(new Claim("birthdate", "2002-08-20"));
   }

   // Add department claim for department-based policies
   if (user.Username == "admin" || user.Username.Contains("dev"))
   {
       tokenDescriptor.Subject.AddClaim(new Claim("department", "IT"));
   }
   else if (user.Username == "editor")
   {
       tokenDescriptor.Subject.AddClaim(new Claim("department", "Content"));
   }
   else
   {
       tokenDescriptor.Subject.AddClaim(new Claim("department", "General"));
   }
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

### Task 4: Create PolicyController (10 minutes)

1. **Create PolicyController** to test custom authorization policies:

   **Controllers/PolicyController.cs**:
   ```csharp
   using Microsoft.AspNetCore.Authorization;
   using Microsoft.AspNetCore.Mvc;
   using JwtAuthenticationAPI.Models;
   using System.Security.Claims;

   namespace JwtAuthenticationAPI.Controllers;

   /// <summary>
   /// Custom policy endpoints from Exercise 03
   /// </summary>
   [ApiController]
   [Route("api/[controller]")]
   public class PolicyController : ControllerBase
   {
       /// <summary>
       /// Adult content - requires minimum age of 18
       /// </summary>
       [HttpGet("adult-content")]
       [Authorize(Policy = "Adult")]
       public IActionResult GetAdultContent()
       {
           return Ok(new ApiResponse<object>
           {
               Success = true,
               Message = "Adult content accessed",
               Data = new { Content = "This content is restricted to users 18 and older" }
           });
       }

       /// <summary>
       /// IT Department resources - requires IT or Development department
       /// </summary>
       [HttpGet("it-resources")]
       [Authorize(Policy = "ITDepartment")]
       public IActionResult GetITResources()
       {
           var department = User.FindFirst("department")?.Value;

           return Ok(new ApiResponse<object>
           {
               Success = true,
               Message = "IT Department Resources",
               Data = new
               {
                   Department = department,
                   Resources = new[]
                   {
                       "Source Code Repository",
                       "Development Servers",
                       "CI/CD Pipeline",
                       "Technical Documentation"
                   }
               }
           });
       }

       /// <summary>
       /// Business hours only endpoint - accessible 9 AM to 5 PM
       /// </summary>
       [HttpGet("business-hours")]
       [Authorize(Policy = "BusinessHours")]
       public IActionResult GetBusinessHoursData()
       {
           return Ok(new ApiResponse<object>
           {
               Success = true,
               Message = "Business hours data accessed",
               Data = new
               {
                   CurrentTime = DateTime.Now.ToString("HH:mm"),
                   BusinessData = "This data is only available during business hours (9:00 - 17:00)"
               }
           });
       }

       /// <summary>
       /// Senior IT Staff endpoint - combined requirements
       /// </summary>
       [HttpGet("senior-it-data")]
       [Authorize(Policy = "SeniorITStaff")]
       public IActionResult GetSeniorITData()
       {
           var username = User.FindFirst(ClaimTypes.Name)?.Value;
           var department = User.FindFirst("department")?.Value;

           return Ok(new ApiResponse<object>
           {
               Success = true,
               Message = "Senior IT Staff Data",
               Data = new
               {
                   User = username,
                   Department = department,
                   AccessLevel = "Senior",
                   SensitiveData = new
                   {
                       ServerPasswords = "********",
                       DatabaseConnections = "Encrypted",
                       APIKeys = "Secured"
                   }
               }
           });
       }

       /// <summary>
       /// Public info - no authentication required
       /// </summary>
       [HttpGet("public-info")]
       public IActionResult GetPublicInfo()
       {
           return Ok(new ApiResponse<object>
           {
               Success = true,
               Message = "Public information",
               Data = new
               {
                   CompanyName = "Tech Corp",
                   Address = "123 Tech Street",
                   Phone = "555-0123",
                   OpenHours = "Mon-Fri 9:00-17:00"
               }
           });
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