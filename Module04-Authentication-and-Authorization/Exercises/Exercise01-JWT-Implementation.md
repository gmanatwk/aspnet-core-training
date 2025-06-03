# Exercise 1: JWT Implementation

## 🎯 Objective
Create a secure JWT authentication system from scratch and test all endpoints.

## ⏱️ Time Allocation: 45 minutes

## 📋 Prerequisites
- .NET 8.0 SDK installed
- Visual Studio or VS Code
- Postman or similar API testing tool

## 🎯 Learning Goals
By completing this exercise, you will:
- ✅ Understand JWT token structure and validation
- ✅ Configure JWT authentication in ASP.NET Core
- ✅ Implement secure login endpoints
- ✅ Test protected API endpoints
- ✅ Handle authentication errors properly

## 📝 Tasks

### Task 1: Project Setup (10 minutes)
1. **Create a new Web API project**:
   ```bash
   dotnet new webapi -n JwtAuthExercise
   cd JwtAuthExercise
   ```

2. **Install required NuGet packages**:
   ```bash
   dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
   dotnet add package System.IdentityModel.Tokens.Jwt
   dotnet add package Microsoft.IdentityModel.Tokens
   ```

3. **Configure appsettings.json**:
   Add JWT configuration section with your own secret key.

### Task 2: JWT Service Implementation (15 minutes)
1. **Create Models folder** and add:
   - `LoginRequest.cs` - Login credentials model
   - `LoginResponse.cs` - JWT token response model
   - `User.cs` - User entity model

2. **Create Services folder** and implement:
   - `IJwtTokenService` interface
   - `JwtTokenService` class with token generation and validation

### Task 3: Authentication Configuration (10 minutes)
1. **Configure JWT in Program.cs**:
   - Add authentication services
   - Configure JWT bearer options
   - Set up token validation parameters

2. **Add authentication middleware** in correct order

### Task 4: Controller Implementation (10 minutes)
1. **Create AuthController** with endpoints:
   - `POST /api/auth/login` - User authentication
   - `GET /api/auth/protected` - Protected test endpoint

2. **Add proper authorization attributes**

3. **Implement error handling and validation**

## 🧪 Testing Checklist

### Authentication Tests:
- [ ] **Valid Login**: Test with correct credentials
- [ ] **Invalid Login**: Test with wrong credentials
- [ ] **Missing Credentials**: Test with empty request
- [ ] **Token Format**: Verify JWT token structure

### Authorization Tests:
- [ ] **Protected Endpoint Without Token**: Should return 401
- [ ] **Protected Endpoint With Valid Token**: Should return 200
- [ ] **Protected Endpoint With Expired Token**: Should return 401
- [ ] **Protected Endpoint With Invalid Token**: Should return 401

## 📊 Sample Test Data

### Valid Users:
```json
{
  "username": "admin",
  "password": "admin123"
}
```

```json
{
  "username": "user",
  "password": "user123"
}
```

## 🔧 Postman Test Collection

### 1. Login Request
```
POST {{baseUrl}}/api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}
```

### 2. Protected Endpoint
```
GET {{baseUrl}}/api/auth/protected
Authorization: Bearer {{token}}
```

## ❓ Verification Questions

After completing the exercise, answer these questions:

1. **What are the three parts of a JWT token?**
2. **Why is the signing key important in JWT?**
3. **What happens if you don't include the Authorization middleware?**
4. **How would you extend the token expiration time?**
5. **What's the difference between authentication and authorization?**

## 💡 Challenge Tasks (Bonus)

If you finish early, try these additional challenges:

### Challenge 1: User Registration
- Add a registration endpoint
- Implement proper password hashing
- Validate user input

### Challenge 2: Role-Based Authorization
- Add roles to your user model
- Implement role-based access control
- Create admin-only endpoints

### Challenge 3: Token Refresh
- Implement token refresh mechanism
- Handle token expiration gracefully
- Add refresh token storage

## 🆘 Troubleshooting Guide

### Common Issues:

**Token Not Working:**
- Check if authentication middleware is added
- Verify token is properly formatted in Authorization header
- Ensure JWT configuration matches between generation and validation

**401 Unauthorized:**
- Verify [Authorize] attribute is applied
- Check if token is expired
- Ensure proper Bearer format: `Bearer {your-token}`

**Configuration Errors:**
- Verify JWT key is long enough (minimum 256 bits)
- Check issuer and audience settings
- Ensure middleware order is correct

## ✅ Completion Criteria

You have successfully completed this exercise when:
- ✅ Login endpoint returns valid JWT tokens
- ✅ Protected endpoints require authentication
- ✅ Invalid credentials are properly rejected
- ✅ Token validation works correctly
- ✅ All Postman tests pass

## 📚 Additional Resources

- [JWT.io Token Debugger](https://jwt.io/)
- [ASP.NET Core JWT Documentation](https://docs.microsoft.com/en-us/aspnet/core/security/authentication/jwt-authn)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)

---

**Remember**: Always use strong, unique signing keys in production and never expose them in your code or version control!