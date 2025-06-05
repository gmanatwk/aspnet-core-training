# Exercise 2: Role-Based Authorization

## 🎯 Objective
Implement comprehensive role-based authorization with multiple user roles and permissions.

## ⏱️ Time Allocation: 30 minutes

## 📋 Prerequisites
- Completed Exercise 1 (JWT Implementation)
- Understanding of claims and roles
- Working JWT authentication system

## 🎯 Learning Goals
By completing this exercise, you will:
- ✅ Understand role-based access control (RBAC)
- ✅ Implement multiple user roles
- ✅ Secure endpoints with role requirements
- ✅ Handle role-based authorization scenarios
- ✅ Test different access levels

## 📝 Tasks

### Task 1: Extend User Model (5 minutes)
1. **Update User class** to include roles:
   ```csharp
   public class User
   {
       public int Id { get; set; }
       public string Username { get; set; }
       public string Password { get; set; }
       public string Email { get; set; }
       public List<string> Roles { get; set; } = new();
   }
   ```

2. **Add role claims to JWT token generation**

### Task 2: Configure Authorization Policies (10 minutes)

1. **Update Program.cs** to add authorization policies after the JWT configuration:

   **Program.cs** (add after JWT configuration):
   ```csharp
   // Configure Authorization with role-based policies
   builder.Services.AddAuthorization(options =>
   {
       // Exercise 02 - Role-Based Policies
       options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
       options.AddPolicy("UserOrAdmin", policy => policy.RequireRole("User", "Admin"));
       options.AddPolicy("EditorOrAdmin", policy => policy.RequireRole("Editor", "Admin"));
       options.AddPolicy("UserOrAbove", policy => policy.RequireRole("User", "Editor", "Admin"));
   });
   ```

2. **Update UserService.cs** to include users with different roles:

   **Services/UserService.cs** (update the constructor):
   ```csharp
   public UserService(ILogger<UserService> logger)
   {
       _logger = logger;

       // In a real application, this would be replaced with a database
       _users = new List<User>
       {
           new User
           {
               Id = 1,
               Username = "admin",
               Password = HashPassword("admin123"),
               Email = "admin@example.com",
               Roles = new List<string> { "Admin", "Editor", "User" }
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
           }
       };
   }
   ```

3. **Add GetAllUsersAsync method** to UserService interface and implementation:

   **Services/UserService.cs** (add to interface):
   ```csharp
   public interface IUserService
   {
       Task<User?> AuthenticateAsync(string username, string password);
       Task<User?> GetUserByIdAsync(int id);
       Task<List<User>> GetAllUsersAsync(); // Add this line
   }
   ```

   **Services/UserService.cs** (add to implementation):
   ```csharp
   public async Task<List<User>> GetAllUsersAsync()
   {
       try
       {
           await Task.Delay(50); // Simulate async database call

           return _users.ToList();
       }
       catch (Exception ex)
       {
           _logger.LogError(ex, "Error retrieving all users");
           return new List<User>();
       }
   }
   ```

4. **Add UserProfile model** to AuthModels.cs:

   **Models/AuthModels.cs** (add this class):
   ```csharp
   public class UserProfile
   {
       public int Id { get; set; }
       public string Username { get; set; } = string.Empty;
       public string Email { get; set; } = string.Empty;
       public List<string> Roles { get; set; } = new();
       public DateTime CreatedAt { get; set; }
   }
   ```

### Task 3: Implement Role-Based Controllers (15 minutes)

1. **Create AdminController** for admin-only endpoints:

   **Controllers/AdminController.cs**:
   ```csharp
   using Microsoft.AspNetCore.Authorization;
   using Microsoft.AspNetCore.Mvc;
   using JwtAuthenticationAPI.Models;

   namespace JwtAuthenticationAPI.Controllers;

   /// <summary>
   /// Admin-only endpoints from Exercise 02
   /// </summary>
   [ApiController]
   [Route("api/[controller]")]
   public class AdminController : ControllerBase
   {
       /// <summary>
       /// Admin dashboard - requires Admin role
       /// </summary>
       [HttpGet("dashboard")]
       [Authorize(Roles = "Admin")]
       public IActionResult GetDashboard()
       {
           return Ok(new ApiResponse<object>
           {
               Success = true,
               Message = "Admin Dashboard Data",
               Data = new
               {
                   TotalUsers = 150,
                   ActiveSessions = 45,
                   SystemHealth = "Good",
                   LastBackup = DateTime.UtcNow.AddHours(-2)
               }
           });
       }

       /// <summary>
       /// Get all users - Admin only policy
       /// </summary>
       [HttpGet("users")]
       [Authorize(Policy = "AdminOnly")]
       public IActionResult GetAllUsers()
       {
           return Ok(new ApiResponse<object>
           {
               Success = true,
               Message = "List of all users",
               Data = new[]
               {
                   new { Id = 1, Username = "admin", Role = "Admin", LastLogin = DateTime.UtcNow.AddMinutes(-30) },
                   new { Id = 2, Username = "editor", Role = "Editor", LastLogin = DateTime.UtcNow.AddHours(-1) },
                   new { Id = 3, Username = "user", Role = "User", LastLogin = DateTime.UtcNow.AddDays(-1) }
               }
           });
       }
   }
   ```

2. **Create EditorController** for content management:

   **Controllers/EditorController.cs**:
   ```csharp
   using Microsoft.AspNetCore.Authorization;
   using Microsoft.AspNetCore.Mvc;
   using JwtAuthenticationAPI.Models;

   namespace JwtAuthenticationAPI.Controllers;

   /// <summary>
   /// Editor endpoints from Exercise 02
   /// </summary>
   [ApiController]
   [Route("api/[controller]")]
   public class EditorController : ControllerBase
   {
       /// <summary>
       /// Content management - Editor or Admin access
       /// </summary>
       [HttpGet("content")]
       [Authorize(Policy = "EditorOrAdmin")]
       public IActionResult GetContent()
       {
           return Ok(new ApiResponse<object>
           {
               Success = true,
               Message = "Content Management Data",
               Data = new
               {
                   Articles = new[]
                   {
                       new { Id = 1, Title = "Getting Started with JWT", Status = "Published" },
                       new { Id = 2, Title = "Role-Based Authorization", Status = "Draft" },
                       new { Id = 3, Title = "Custom Policies", Status = "Review" }
                   },
                   CanPublish = User.IsInRole("Editor") || User.IsInRole("Admin"),
                   CanDelete = User.IsInRole("Admin")
               }
           });
       }

       /// <summary>
       /// Create content - requires Editor role
       /// </summary>
       [HttpPost("content")]
       [Authorize(Roles = "Editor,Admin")]
       public IActionResult CreateContent([FromBody] object content)
       {
           return Ok(new ApiResponse<object>
           {
               Success = true,
               Message = "Content created successfully",
               Data = new { Id = 4, CreatedAt = DateTime.UtcNow }
           });
       }
   }
   ```

3. **Create UsersController** for user management:

   **Controllers/UsersController.cs**:
   ```csharp
   using Microsoft.AspNetCore.Authorization;
   using Microsoft.AspNetCore.Mvc;
   using JwtAuthenticationAPI.Models;
   using JwtAuthenticationAPI.Services;
   using System.Security.Claims;

   namespace JwtAuthenticationAPI.Controllers;

   [ApiController]
   [Route("api/[controller]")]
   [Authorize] // All endpoints in this controller require authentication
   public class UsersController : ControllerBase
   {
       private readonly IUserService _userService;
       private readonly ILogger<UsersController> _logger;

       public UsersController(IUserService userService, ILogger<UsersController> logger)
       {
           _userService = userService;
           _logger = logger;
       }

       /// <summary>
       /// Get all users (Admin only)
       /// </summary>
       /// <returns>List of all users</returns>
       [HttpGet]
       [Authorize(Roles = "Admin")]
       public async Task<IActionResult> GetAllUsers()
       {
           try
           {
               var users = await _userService.GetAllUsersAsync();

               var userProfiles = users.Select(u => new UserProfile
               {
                   Id = u.Id,
                   Username = u.Username,
                   Email = u.Email,
                   Roles = u.Roles,
                   CreatedAt = u.CreatedAt
               }).ToList();

               return Ok(new ApiResponse<List<UserProfile>>
               {
                   Success = true,
                   Message = "Users retrieved successfully",
                   Data = userProfiles
               });
           }
           catch (Exception ex)
           {
               _logger.LogError(ex, "Error retrieving all users");
               return StatusCode(500, new ApiResponse<object>
               {
                   Success = false,
                   Message = "An error occurred while retrieving users"
               });
           }
       }

       /// <summary>
       /// Get current user's information
       /// </summary>
       /// <returns>Current user profile</returns>
       [HttpGet("me")]
       public async Task<IActionResult> GetCurrentUser()
       {
           try
           {
               var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

               if (string.IsNullOrEmpty(userId) || !int.TryParse(userId, out int id))
               {
                   return Unauthorized(new ApiResponse<object>
                   {
                       Success = false,
                       Message = "Invalid user token"
                   });
               }

               var user = await _userService.GetUserByIdAsync(id);

               if (user == null)
               {
                   return NotFound(new ApiResponse<object>
                   {
                       Success = false,
                       Message = "User not found"
                   });
               }

               var profile = new UserProfile
               {
                   Id = user.Id,
                   Username = user.Username,
                   Email = user.Email,
                   Roles = user.Roles,
                   CreatedAt = user.CreatedAt
               };

               return Ok(new ApiResponse<UserProfile>
               {
                   Success = true,
                   Message = "Current user retrieved successfully",
                   Data = profile
               });
           }
           catch (Exception ex)
           {
               _logger.LogError(ex, "Error retrieving current user");
               return StatusCode(500, new ApiResponse<object>
               {
                   Success = false,
                   Message = "An error occurred while retrieving current user"
               });
           }
       }
   }
   ```

## 🧪 Testing Scenarios

### User Roles for Testing:
```json
// Admin User
{
  "username": "admin",
  "password": "admin123",
  "roles": ["Admin", "Editor", "User"]
}

// Editor User  
{
  "username": "editor",
  "password": "editor123",
  "roles": ["Editor", "User"]
}

// Regular User
{
  "username": "user",
  "password": "user123",
  "roles": ["User"]
}
```

### Access Control Matrix:
| Endpoint | Admin | Editor | User | Guest |
|----------|--------|--------|------|-------|
| `/api/admin/dashboard` | ✅ | ❌ | ❌ | ❌ |
| `/api/editor/content` | ✅ | ✅ | ❌ | ❌ |
| `/api/user/profile` | ✅ | ✅ | ✅ | ❌ |
| `/api/public/info` | ✅ | ✅ | ✅ | ✅ |

## 🔧 Implementation Examples

### Controller with Role Authorization:
```csharp
[ApiController]
[Route("api/[controller]")]
public class AdminController : ControllerBase
{
    [HttpGet("dashboard")]
    [Authorize(Roles = "Admin")]
    public IActionResult GetDashboard()
    {
        return Ok("Admin Dashboard Data");
    }
    
    [HttpGet("users")]
    [Authorize(Policy = "AdminOnly")]
    public IActionResult GetAllUsers()
    {
        return Ok("List of all users");
    }
}
```

### Dynamic Role Checking:
```csharp
[HttpGet("conditional")]
[Authorize]
public IActionResult ConditionalAccess()
{
    var userRoles = User.FindAll(ClaimTypes.Role).Select(c => c.Value);
    
    if (userRoles.Contains("Admin"))
    {
        return Ok("Admin level data");
    }
    else if (userRoles.Contains("Editor"))
    {
        return Ok("Editor level data");
    }
    else
    {
        return Ok("Basic user data");
    }
}
```

## 📊 Test Cases

### Test Case 1: Admin Access
- **Login as Admin**
- **Access all endpoints**
- **Verify admin-only data is returned**

### Test Case 2: Editor Access
- **Login as Editor**
- **Access editor and user endpoints**
- **Verify admin endpoints are forbidden (403)**

### Test Case 3: User Access
- **Login as User**
- **Access user endpoints only**
- **Verify higher-level endpoints are forbidden**

### Test Case 4: No Authentication
- **Access endpoints without token**
- **Verify 401 Unauthorized responses**

## ❓ Verification Questions

1. **What's the difference between Roles and Policies?**
2. **How do you add multiple roles to a single user?**
3. **What HTTP status code is returned for insufficient privileges?**
4. **How can you check user roles within a controller action?**
5. **What's the advantage of policy-based over role-based authorization?**

## 💡 Challenge Tasks (Bonus)

### Challenge 1: Hierarchical Roles
- Implement role hierarchy (Admin > Editor > User)
- Auto-include lower-level permissions

### Challenge 2: Resource-Based Authorization
- Implement authorization based on resource ownership
- Users can only edit their own content

### Challenge 3: Dynamic Permissions
- Create a permission system
- Assign specific permissions to roles
- Check permissions at runtime

## 🔍 Testing Commands

### Postman Collection:

```bash
# 1. Login as Admin
POST /api/auth/login
{
  "username": "admin",
  "password": "admin123"
}

# 2. Test Admin Endpoint
GET /api/admin/dashboard
Authorization: Bearer {{admin_token}}

# 3. Login as User
POST /api/auth/login
{
  "username": "user", 
  "password": "user123"
}

# 4. Test Admin Endpoint as User (should fail)
GET /api/admin/dashboard
Authorization: Bearer {{user_token}}
```

## ✅ Completion Criteria

You have successfully completed this exercise when:
- ✅ Different user roles are properly configured
- ✅ Role-based endpoints return appropriate responses
- ✅ Access control matrix is correctly enforced
- ✅ Unauthorized access returns proper HTTP status codes
- ✅ JWT tokens contain role claims

## 🆘 Common Issues & Solutions

**Roles Not Working:**
- Ensure role claims are added to JWT token
- Verify [Authorize] attributes use correct role names
- Check token contains role claims using JWT debugger

**403 vs 401 Errors:**
- 401: Not authenticated (no/invalid token)
- 403: Authenticated but insufficient permissions

**Case Sensitivity:**
- Role names are case-sensitive by default
- Ensure consistent casing throughout application

---

**Security Note**: In production, implement proper role management with database storage and admin interfaces for role assignment.