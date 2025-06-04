# Module 03 - Working with Web APIs

This module contains a comprehensive RESTful API implementation with ASP.NET Core, including authentication, authorization, and integration tests.

## Projects

### RestfulAPI
The main API project featuring:
- RESTful API endpoints with versioning
- JWT authentication and role-based authorization
- Entity Framework Core with in-memory database
- Swagger/OpenAPI documentation
- Both controller-based and minimal API implementations
- Global exception handling and logging
- CORS configuration
- Response caching and compression

### RestfulAPI.Tests
Comprehensive integration test suite covering:
- All ProductsController endpoints
- All AuthController endpoints
- Minimal API endpoints
- Middleware functionality
- Authentication and authorization scenarios

## Running the Application

```bash
# Navigate to the RestfulAPI directory
cd RestfulAPI

# Restore dependencies
dotnet restore

# Run the application
dotnet run
```

The API will be available at:
- HTTP: http://localhost:5000
- HTTPS: https://localhost:5001
- Swagger UI: http://localhost:5000 (root URL)

## Running Tests

```bash
# Option 1: Use the test script
./run-tests.sh

# Option 2: Manual execution
cd RestfulAPI.Tests
dotnet test

# Run with detailed output
dotnet test --logger "console;verbosity=detailed"

# Run with code coverage
dotnet test --collect:"XPlat Code Coverage"
```

## Test Coverage

The test suite includes 50+ integration tests covering:
- ✅ All ProductsController endpoints (11 endpoints)
- ✅ All AuthController endpoints (7 endpoints)
- ✅ Minimal API endpoints (4 endpoints)
- ✅ Health check and root redirect
- ✅ Middleware (CORS, versioning, caching)
- ✅ Authentication and authorization scenarios
- ✅ Error handling and validation

## API Endpoints

### Products API (v1)
- `GET /api/v1/products` - Get all products with pagination and filtering
- `GET /api/v1/products/{id}` - Get product by ID
- `POST /api/v1/products` - Create new product
- `PUT /api/v1/products/{id}` - Update product
- `PATCH /api/v1/products/{id}` - Partial update
- `DELETE /api/v1/products/{id}` - Delete product
- `GET /api/v1/products/categories` - Get all categories
- `GET /api/v1/products/search` - Search products
- `GET /api/v1/products/secure` - Secure endpoint (requires auth)

### Authentication API
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login
- `GET /api/auth/profile` - Get user profile (requires auth)
- `POST /api/auth/change-password` - Change password (requires auth)
- `POST /api/auth/validate-token` - Validate JWT token
- `GET /api/auth/test` - Test authentication
- `GET /api/auth/admin-test` - Test admin role

### Minimal API
- `GET /api/minimal/products` - Get products
- `GET /api/minimal/products/{id}` - Get product by ID
- `POST /api/minimal/products` - Create product
- `DELETE /api/minimal/products/{id}` - Delete product

## Authentication

The API uses JWT Bearer authentication. To access protected endpoints:

1. Register a new user or login with existing credentials
2. Use the returned token in the Authorization header: `Bearer {token}`

### Test Credentials
- Admin: `admin@test.com` / `Admin123!`
- Manager: `manager@test.com` / `Manager123!`
- User: `user@test.com` / `User123!`

## Development Notes

- The application uses an in-memory database in development mode
- Swagger UI is available at the root URL in development
- All endpoints support JSON and some support XML
- API versioning is supported via URL segment, query string, header, or media type