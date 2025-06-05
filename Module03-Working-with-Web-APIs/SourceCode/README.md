# Module 03 - Working with Web APIs

This module contains a comprehensive RESTful API implementation with ASP.NET Core, including authentication, authorization, integration tests, and a modern React TypeScript frontend with Docker support.

## Projects

### RestfulAPI
The main API project featuring:
- RESTful API endpoints with versioning
- JWT authentication and role-based authorization
- Entity Framework Core with SQL Server support
- Swagger/OpenAPI documentation
- Both controller-based and minimal API implementations
- Global exception handling and logging
- CORS configuration
- Response caching and compression
- Docker support for containerized deployment

### ReactFrontend
A modern React TypeScript SPA featuring:
- React 18 with TypeScript
- Vite for fast development and optimized builds
- React Query for efficient data fetching
- Full CRUD operations for Product management
- Responsive UI design
- Docker support with nginx for production

### RestfulAPI.Tests
Comprehensive integration test suite covering:
- All ProductsController endpoints
- All AuthController endpoints
- Minimal API endpoints
- Middleware functionality
- Authentication and authorization scenarios

## Running the Application

### Option 1: Using Docker (Recommended)

```bash
# Start all services with hot reload
docker-compose up --build

# To run in background
docker-compose up -d --build

# Stop all services
docker-compose down

# Stop and remove volumes (database data)
docker-compose down -v
```

Services will be available at:
- React Frontend: http://localhost:3000
- RestfulAPI: http://localhost:5001
- Swagger UI: http://localhost:5001/swagger
- SQL Server: localhost:1433 (sa/YourStrong@Passw0rd123) - Optional

**Note**: If SQL Server fails to start (common on Apple Silicon Macs), the API automatically falls back to using an in-memory database. This ensures the application works on all platforms.

### Option 2: Manual Setup

```bash
# Terminal 1: Run the API
cd RestfulAPI
dotnet restore
dotnet run

# Terminal 2: Run the React frontend
cd ReactFrontend
npm install
npm run dev
```

The services will be available at:
- React Frontend: http://localhost:3000
- API: http://localhost:5000 (HTTP) or https://localhost:5001 (HTTPS)
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

- The application uses SQL Server (in Docker) or in-memory database as fallback
- Swagger UI is available at the root URL in development
- All endpoints support JSON and some support XML
- API versioning is supported via URL segment, query string, header, or media type
- Docker Compose orchestrates all services (API, Frontend, Database)
- Hot reload is enabled in development mode for both frontend and backend

## Docker Integration

See [DOCKER-INTEGRATION.md](./DOCKER-INTEGRATION.md) for detailed Docker setup and configuration instructions.

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  React Frontend │────▶│   RestfulAPI    │────▶│   SQL Server    │
│   (Port 3000)   │     │   (Port 5001)   │     │   (Port 1433)   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Additional Resources

### Setup and Configuration
- [Setup Guide](./SETUP-GUIDE.md) - **Start here!** Cross-platform setup instructions
- [Docker Commands Reference](./DOCKER-COMMANDS.md) - Cross-platform Docker commands
- [Docker Integration Guide](./DOCKER-INTEGRATION.md) - Detailed Docker setup guide
- [Project Templates](./templates/README.md) - Consistent dependency templates

### Project Documentation
- [RestfulAPI README](./RestfulAPI/README.md) - Detailed API documentation
- [ReactFrontend README](./ReactFrontend/README.md) - Frontend documentation
- [API Endpoints Reference](./RestfulAPI/API-ENDPOINTS-REFERENCE.md) - Complete API reference
- [Test Coverage Report](./RestfulAPI.Tests/TestCoverage.md) - Test coverage details