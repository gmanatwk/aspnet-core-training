# Exercise 2: Add Authentication and Security to Your Products API

## 🎯 Objective
Enhance your Products API from Exercise 1 by adding JWT authentication, user registration/login, and role-based authorization to secure your endpoints.

## ⏱️ Estimated Time
45 minutes

## 📋 Prerequisites
- Completed Exercise 1 (Products RESTful API)
- Basic understanding of JWT tokens
- Knowledge of authentication vs authorization

## 📝 Instructions

### Part 0: Project Setup (2 minutes)

**Run the launch script to add authentication to your Products API:**
```bash
# From the Module03-Working-with-Web-APIs directory
./launch-exercises.sh exercise02
```

**The script enhances your existing Products API with:**
- ✅ ASP.NET Core Identity integration
- ✅ JWT authentication with refresh tokens
- ✅ User registration and login endpoints
- ✅ Role-based authorization (Admin, User roles)
- ✅ Protected endpoints with [Authorize] attributes
- ✅ Enhanced Swagger with JWT support

**Test the enhanced API:**
```bash
cd RestfulAPI
dotnet run
# Navigate to: http://localhost:5000/swagger
```

## 🎓 What You've Built

The launch script has enhanced your Products API with complete authentication and authorization:

### 📁 Enhanced Project Structure

```
RestfulAPI/
├── Controllers/
│   ├── ProductsController.cs    # Enhanced with [Authorize] attributes
│   └── AuthController.cs        # NEW - Authentication endpoints
├── Models/
│   ├── Product.cs              # Existing from Exercise 1
│   └── Auth/
│       ├── User.cs             # NEW - Identity user model
│       └── AuthModels.cs       # NEW - Auth request/response models
├── DTOs/
│   └── ProductDtos.cs          # Existing from Exercise 1
├── Data/
│   └── ApplicationDbContext.cs # Enhanced with Identity
├── Services/
│   └── JwtService.cs           # NEW - JWT token generation
├── Program.cs                  # Enhanced with authentication
└── appsettings.json           # Enhanced with JWT settings
```

### 🔐 Authentication Features Added

**New Authentication Endpoints (`/api/auth`):**
- **POST** `/api/auth/register` - Register new user
- **POST** `/api/auth/login` - Login with email/password
- **GET** `/api/auth/profile` - Get current user profile

**Enhanced Products API Security:**
- **GET** endpoints remain public for browsing
- **POST** `/api/products` - Requires authentication
- **PUT** `/api/products/{id}` - Requires Admin role
- **DELETE** `/api/products/{id}` - Requires Admin role

### 🎯 Key Authentication Models

The script has implemented these key models:

**User Model** - Extends ASP.NET Core Identity:
- FirstName, LastName, CreatedAt, LastLoginAt
- Integrated with Identity framework for authentication

**Authentication Request/Response Models**:
- `RegisterModel` - User registration with validation
- `LoginModel` - Login credentials
- `TokenResponse` - JWT token with user info and refresh token
- `UserInfo` - User profile information with roles

## 🧪 Testing Your Enhanced API

### 1. Using Swagger UI (Recommended)

1. **Run the application**: `dotnet run`
2. **Navigate to**: `http://localhost:5000/swagger`
3. **Notice the new features**:
   - 🔒 Lock icon on protected endpoints
   - 🆕 Authentication section with register/login endpoints
   - 🔑 "Authorize" button in top-right corner

### 2. Test Authentication Flow

**Step 1: Register a new user**
```bash
curl -X POST "http://localhost:5000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "Admin123!",
    "confirmPassword": "Admin123!",
    "firstName": "Admin",
    "lastName": "User"
  }'
```

**Step 2: Login to get JWT token**
```bash
curl -X POST "http://localhost:5000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "Admin123!"
  }'
```

**Step 3: Use token for protected endpoints**
```bash
# Copy the token from login response
TOKEN="your-jwt-token-here"

# Create a product (requires authentication)
curl -X POST "http://localhost:5000/api/products" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Authenticated Product",
    "description": "Created by authenticated user",
    "price": 299.99,
    "category": "Electronics",
    "stockQuantity": 25,
    "sku": "AUTH-PROD-001",
    "isActive": true
  }'
```

### 3. Test Authorization Scenarios

**Test unauthorized access:**
```bash
# Try to create product without token (should fail with 401)
curl -X POST "http://localhost:5000/api/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Unauthorized Product",
    "description": "This should fail",
    "price": 99.99,
    "category": "Test",
    "stockQuantity": 10,
    "sku": "FAIL-001"
  }'
```

**Test role-based access:**
```bash
# Try to update/delete as regular user (should fail with 403)
curl -X PUT "http://localhost:5000/api/products/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER_TOKEN" \
  -d '{
    "name": "Updated Product",
    "description": "Regular user trying to update",
    "price": 199.99,
    "category": "Electronics",
    "stockQuantity": 30,
    "sku": "ELEC-LAP-001"
  }'
```

### 4. Using Swagger UI for Authentication

1. **Click the "Authorize" button** in Swagger UI
2. **Enter your JWT token** in the format: `Bearer your-token-here`
3. **Test protected endpoints** - they should now work
4. **Notice the lock icons** on protected endpoints

## 🔐 Security Features Implemented
### 1. JWT Authentication
- **Secure token generation** with user claims and roles
- **Token validation** with proper expiration handling
- **Refresh token support** for seamless user experience
- **Role-based claims** for authorization

### 2. ASP.NET Core Identity Integration
- **User management** with registration, login, password changes
- **Role-based authorization** (Admin, User roles)
- **Password security** with built-in hashing and validation
- **Account management** features

### 3. Enhanced Data Context
- **Identity integration** with ApplicationDbContext
- **Refresh token storage** for secure token management
- **User relationship** with proper foreign keys
- **Maintains existing Products** functionality

### 4. Complete Authentication Controller
The script has implemented a full AuthController with these endpoints:
- **POST** `/api/auth/register` - Register new user with email/password
- **POST** `/api/auth/login` - Login and receive JWT token
- **GET** `/api/auth/profile` - Get current user profile (requires auth)
- **POST** `/api/auth/refresh` - Refresh expired JWT token
- **POST** `/api/auth/change-password` - Change user password (requires auth)
- **POST** `/api/auth/logout` - Logout and revoke refresh tokens

### 5. Enhanced Products API Security

The Products API now has these security enhancements:
- **Public endpoints**: GET operations remain accessible to everyone
- **Authenticated endpoints**: POST operations require valid JWT token
- **Admin-only endpoints**: PUT/DELETE operations require Admin role
- **Enhanced Swagger**: JWT authorization support with "Authorize" button

## ✅ Success Criteria

Test these scenarios to verify your authentication is working:

### Basic Authentication Flow
- [ ] **Register new user** via `/api/auth/register` returns JWT token
- [ ] **Login existing user** via `/api/auth/login` returns JWT token
- [ ] **Access profile** via `/api/auth/profile` with valid token works
- [ ] **Access profile** without token returns 401 Unauthorized

### Products API Security
- [ ] **GET /api/products** works without authentication (public)
- [ ] **POST /api/products** without token returns 401 Unauthorized
- [ ] **POST /api/products** with valid token creates product successfully
- [ ] **PUT /api/products/1** with User role returns 403 Forbidden
- [ ] **DELETE /api/products/1** with User role returns 403 Forbidden

### Swagger UI Integration
- [ ] **"Authorize" button** appears in Swagger UI
- [ ] **Lock icons** show on protected endpoints
- [ ] **JWT token input** works correctly
- [ ] **Protected endpoints** work after authorization

## 🎓 Key Learning Points

### 1. Authentication vs Authorization
- **Authentication**: "Who are you?" (Login with email/password)
- **Authorization**: "What can you do?" (Role-based permissions)
- **JWT tokens**: Stateless authentication with claims

### 2. ASP.NET Core Identity
- **User management**: Registration, login, password changes
- **Role management**: Admin, User roles with different permissions
- **Security features**: Password hashing, lockout policies, validation

### 3. JWT Security Best Practices
- **Token expiration**: 1-hour access tokens for security
- **Refresh tokens**: 7-day refresh tokens for user experience
- **Secure storage**: Tokens stored securely, not in localStorage
- **Claims-based**: User info and roles embedded in token

### 4. API Security Patterns
- **[Authorize] attribute**: Protect endpoints requiring authentication
- **Role-based authorization**: Different permissions for different users
- **Public endpoints**: Allow anonymous access where appropriate
- **Security headers**: Additional protection against common attacks

## 🚀 Next Steps

Your Products API now has enterprise-grade security! In **Exercise 3**, you will add:
- API versioning for backward compatibility
- Advanced Swagger documentation
- Health checks and monitoring
- Production-ready features

## 🆘 Troubleshooting

**Issue**: 401 Unauthorized even with valid token
**Solution**: Check that the token is properly formatted as `Bearer your-token-here` in the Authorization header

**Issue**: 403 Forbidden for admin operations
**Solution**: Ensure your user has the Admin role. The first registered user gets User role by default.

**Issue**: Swagger "Authorize" button not working
**Solution**: Make sure you include "Bearer " (with space) before your token in the authorization input

**Issue**: Token expired errors
**Solution**: Tokens expire after 1 hour. Use the refresh token endpoint or login again to get a new token

---

**🎉 Congratulations! You've secured your API with enterprise-grade authentication!**





---

**🎉 Congratulations! You've successfully secured your Products API with enterprise-grade authentication!**

**Next Exercise**: [Exercise 3 - API Documentation and Versioning →](Exercise03-API-Documentation-Versioning.md)