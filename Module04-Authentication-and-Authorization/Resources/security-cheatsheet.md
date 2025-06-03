# JWT Security Quick Reference Guide

## 🔐 JWT Token Structure

### Three Parts (separated by dots):
1. **Header** - Algorithm and token type
2. **Payload** - Claims and user data  
3. **Signature** - Verification signature

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

## 🛡️ Security Best Practices

### Token Security:
- ✅ **Use Strong Signing Keys** (minimum 256 bits)
- ✅ **Set Appropriate Expiration Times** (1-24 hours)
- ✅ **Never Store Sensitive Data in Payload**
- ✅ **Implement Token Refresh Mechanism**
- ✅ **Use HTTPS Only in Production**

### Key Configuration:
```json
{
  "Jwt": {
    "Key": "your-super-secret-key-that-is-at-least-256-bits-long",
    "Issuer": "your-application-name",
    "Audience": "your-application-users", 
    "ExpiryMinutes": 60
  }
}
```

## 🔧 ASP.NET Core Configuration

### Program.cs Setup:
```csharp
// Add Authentication
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
        };
    });

// Add Authorization
builder.Services.AddAuthorization();

// Middleware Order (IMPORTANT!)
app.UseAuthentication();
app.UseAuthorization();
```

## 🎯 Authorization Attributes

### Basic Authorization:
```csharp
[Authorize] // Requires authentication
[Authorize(Roles = "Admin")] // Requires Admin role
[Authorize(Policy = "MinimumAge")] // Requires custom policy
[AllowAnonymous] // Allows anonymous access
```

### Multiple Requirements:
```csharp
[Authorize(Roles = "Admin,Manager")] // Admin OR Manager
[Authorize(Roles = "Admin")]
[Authorize(Roles = "Manager")] // Admin AND Manager (multiple attributes)
```

## 📋 Common Claims Types

### Standard Claims:
```csharp
ClaimTypes.NameIdentifier // User ID
ClaimTypes.Name // Username
ClaimTypes.Email // Email address
ClaimTypes.Role // User role
ClaimTypes.DateOfBirth // Birth date
```

### Custom Claims:
```csharp
new Claim("department", "IT")
new Claim("position", "Developer")
new Claim("security_level", "3")
```

## 🚨 Common Security Issues

### ❌ Don't Do This:
```csharp
// Storing passwords in JWT
new Claim("password", user.Password) // NEVER!

// Using weak signing keys
"Key": "secret" // Too short!

// No token expiration
Expires = DateTime.MaxValue // Never expires!

// Sensitive data in payload
new Claim("ssn", "123-45-6789") // Exposed!
```

### ✅ Do This Instead:
```csharp
// Only public, non-sensitive data
new Claim(ClaimTypes.NameIdentifier, user.Id.ToString())
new Claim(ClaimTypes.Name, user.Username)
new Claim(ClaimTypes.Role, "User")

// Strong signing key
"Key": "YourSuperSecretKeyThatIsAtLeast256BitsLongForMaximumSecurity2024!"

// Reasonable expiration
Expires = DateTime.UtcNow.AddHours(1)
```

## 🔍 Testing & Debugging

### Postman Authorization:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### JWT Debugging:
- Use [jwt.io](https://jwt.io) to decode tokens
- Check token expiration times
- Verify claims structure
- Validate signature

### Common HTTP Status Codes:
- **200 OK** - Successful authentication
- **401 Unauthorized** - Missing or invalid token
- **403 Forbidden** - Valid token, insufficient permissions
- **422 Unprocessable Entity** - Invalid credentials format

## ⚡ Performance Tips

### Token Size Optimization:
- Keep claims minimal
- Use short claim names
- Avoid complex objects in claims

### Caching Strategies:
```csharp
// Cache user roles to avoid database lookups
[ResponseCache(Duration = 300)]
public IActionResult GetUserRoles() { }
```

## 🔄 Token Refresh Pattern

### Implementation:
```csharp
public class TokenResponse
{
    public string AccessToken { get; set; }
    public string RefreshToken { get; set; }
    public DateTime AccessTokenExpiry { get; set; }
}
```

### Refresh Logic:
1. Check if access token is expired
2. Use refresh token to get new access token
3. Update stored tokens
4. Retry original request

## 🎨 Authorization Patterns

### Role-Based (RBAC):
```csharp
[Authorize(Roles = "Admin,Manager")]
```

### Policy-Based:
```csharp
[Authorize(Policy = "EditDocument")]
```

### Resource-Based:
```csharp
var authResult = await _authorizationService
    .AuthorizeAsync(User, document, "EditPolicy");
```

## 📱 Mobile & SPA Considerations

### Token Storage:
- **Web Apps**: HttpOnly cookies (more secure)
- **SPAs**: Local storage (convenience) or sessionStorage
- **Mobile**: Secure storage mechanisms

### CORS Configuration:
```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins("https://yourdomain.com")
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();
    });
});
```

---

## 🆘 Emergency Checklist

When authentication isn't working:
1. ✅ Check middleware order
2. ✅ Verify JWT configuration
3. ✅ Confirm token format in request
4. ✅ Check token expiration
5. ✅ Validate signing key
6. ✅ Review authorization attributes
7. ✅ Check user roles/claims
8. ✅ Test with jwt.io debugger