# RESTful API Example - Module 3

This is a comprehensive RESTful API example demonstrating best practices for building production-ready APIs with ASP.NET Core.

## Features

### Core API Features
- **Full CRUD Operations**: Create, Read, Update, Delete operations for products
- **Pagination**: Built-in pagination support with customizable page size
- **Filtering**: Filter products by category, price range
- **Searching**: Full-text search across product names and descriptions
- **API Versioning**: URL-based versioning (e.g., `/api/v1/products`)
- **PATCH Support**: Partial updates using JSON Patch
- **Minimal API**: Alternative implementation using minimal APIs

### Production Features
- **Authentication & Authorization**: JWT Bearer token authentication
- **Swagger/OpenAPI**: Interactive API documentation
- **Global Exception Handling**: Consistent error responses
- **Rate Limiting**: Protect API from abuse
- **Request/Response Logging**: Structured logging with Serilog
- **Health Checks**: Monitor API and database health
- **CORS Support**: Configure allowed origins
- **Response Compression**: Optimize payload size
- **Security Headers**: XSS protection, content type options, etc.

## Project Structure

```
RestfulAPI/
├── Controllers/
│   └── ProductsController.cs      # Main API controller
├── Data/
│   └── ApplicationDbContext.cs    # EF Core database context
├── DTOs/
│   └── ProductDtos.cs            # Data transfer objects
├── Filters/
│   ├── LoggingActionFilter.cs   # Request/response logging
│   └── ValidationFilter.cs       # Model validation
├── Middleware/
│   ├── GlobalExceptionMiddleware.cs  # Exception handling
│   └── RateLimitingMiddleware.cs    # Rate limiting
├── Models/
│   ├── ApiResponse.cs            # Response wrappers
│   └── Product.cs                # Domain model
├── Services/
│   ├── IProductService.cs        # Service interface
│   └── ProductService.cs         # Business logic
├── MinimalApiExample.cs          # Minimal API implementation
├── Program.cs                    # Application configuration
├── appsettings.json             # Configuration
└── RestfulAPI.csproj            # Project file
```

## API Endpoints

### Controller-based API

#### Products
- `GET /api/v1/products` - Get all products (paginated)
  - Query params: `category`, `minPrice`, `maxPrice`, `pageNumber`, `pageSize`
- `GET /api/v1/products/{id}` - Get product by ID
- `POST /api/v1/products` - Create new product
- `PUT /api/v1/products/{id}` - Update product
- `PATCH /api/v1/products/{id}` - Partially update product
- `DELETE /api/v1/products/{id}` - Delete product (soft delete)
- `GET /api/v1/products/categories` - Get all categories
- `GET /api/v1/products/search?query={query}` - Search products
- `GET /api/v1/products/secure` - Get products (requires authentication)

### Minimal API

- `GET /api/minimal/products` - Get all products
- `GET /api/minimal/products/{id}` - Get product by ID
- `POST /api/minimal/products` - Create product
- `PUT /api/minimal/products/{id}` - Update product
- `DELETE /api/minimal/products/{id}` - Delete product
- `GET /api/minimal/products/search?q={query}` - Search products
- `GET /api/minimal/products/categories` - Get categories

### Health & Info
- `GET /health` - Health check endpoint
- `GET /api/v1/products/count` - Get product count
- `GET /api/v1/products/{id}/exists` - Check if product exists

## Running the Application

1. **Install dependencies**:
   ```bash
   dotnet restore
   ```

2. **Run the application**:
   ```bash
   dotnet run
   ```

3. **Access Swagger UI**:
   Navigate to `https://localhost:5001` or `http://localhost:5000`

## Configuration

### appsettings.json
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=...;Database=ProductsDb;..."
  },
  "Jwt": {
    "Key": "your-secret-key",
    "Issuer": "https://localhost:5001",
    "Audience": "https://localhost:5001"
  },
  "Cors": {
    "AllowedOrigins": ["http://localhost:3000"]
  }
}
```

## Authentication

The API uses JWT Bearer tokens for authentication. To access protected endpoints:

1. Obtain a JWT token (implement authentication endpoint)
2. Include the token in the Authorization header:
   ```
   Authorization: Bearer {your-token}
   ```

## Request Examples

### Create Product
```bash
curl -X POST https://localhost:5001/api/v1/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop",
    "description": "High-performance laptop",
    "price": 999.99,
    "category": "Electronics",
    "stockQuantity": 50
  }'
```

### Get Products with Pagination
```bash
curl "https://localhost:5001/api/v1/products?pageNumber=1&pageSize=10"
```

### Update Product (PATCH)
```bash
curl -X PATCH https://localhost:5001/api/v1/products/1 \
  -H "Content-Type: application/json-patch+json" \
  -d '[
    { "op": "replace", "path": "/price", "value": 899.99 },
    { "op": "replace", "path": "/stockQuantity", "value": 45 }
  ]'
```

## Response Format

### Success Response
```json
{
  "data": [
    {
      "id": 1,
      "name": "Laptop",
      "description": "High-performance laptop",
      "price": 999.99,
      "category": "Electronics",
      "stockQuantity": 50,
      "isAvailable": true,
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": null
    }
  ],
  "pageNumber": 1,
  "pageSize": 10,
  "totalPages": 5,
  "totalRecords": 50,
  "hasPreviousPage": false,
  "hasNextPage": true
}
```

### Error Response (RFC 7807)
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.4",
  "title": "Not Found",
  "status": 404,
  "detail": "Product with ID 999 not found",
  "instance": "/api/v1/products/999",
  "traceId": "0HN4JQPFS5Q7Q:00000001"
}
```

## Key Concepts Demonstrated

1. **RESTful Design**: Proper HTTP verbs, status codes, and resource naming
2. **Clean Architecture**: Separation of concerns with services, DTOs, and models
3. **Dependency Injection**: Service registration and constructor injection
4. **Middleware Pipeline**: Custom middleware for cross-cutting concerns
5. **Async/Await**: Asynchronous programming throughout
6. **Entity Framework Core**: Code-first approach with in-memory database
7. **Model Validation**: Data annotations and custom validation
8. **API Documentation**: OpenAPI/Swagger integration
9. **Error Handling**: Global exception handling with problem details
10. **Security**: Authentication, authorization, rate limiting, security headers

## Testing the API

Use tools like:
- **Swagger UI**: Built-in interactive documentation
- **Postman**: Import OpenAPI specification
- **curl**: Command-line testing
- **REST Client**: VS Code extension

## Performance Considerations

- Response caching enabled for GET requests
- Pagination to limit data transfer
- Async operations throughout
- Response compression
- Efficient LINQ queries with projection
- Rate limiting to prevent abuse

## Security Best Practices

- JWT authentication for protected endpoints
- HTTPS enforcement in production
- Security headers (XSS, Content-Type, etc.)
- Input validation and sanitization
- Rate limiting
- CORS configuration
- Soft deletes to maintain data integrity