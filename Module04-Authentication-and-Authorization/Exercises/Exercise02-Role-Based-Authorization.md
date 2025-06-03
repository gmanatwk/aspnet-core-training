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
1. **Add authorization policies in Program.cs**:
   ```csharp
   builder.Services.AddAuthorization(options =>
   {
       options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
       options.AddPolicy("EditorOrAdmin", policy => policy.RequireRole("Editor", "Admin"));
       options.AddPolicy("UserOrAbove", policy => policy.RequireRole("User", "Editor", "Admin"));
   });
   ```

2. **Create sample users with different roles**:
   - Admin: Full access
   - Editor: Content management
   - User: Basic access
   - Guest: Limited access

### Task 3: Implement Role-Based Endpoints (15 minutes)
1. **Create different protected endpoints**:
   - `/api/admin/dashboard` - Admin only
   - `/api/editor/content` - Editor or Admin
   - `/api/user/profile` - Any authenticated user
   - `/api/public/info` - No authentication required

2. **Apply appropriate authorization attributes**

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