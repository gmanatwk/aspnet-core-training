# REST Architecture Principles Guide

## What is REST?

REST (REpresentational State Transfer) is an architectural style for designing distributed systems. It was introduced by Roy Fielding in his 2000 doctoral dissertation.

## Core REST Principles

### 1. 🔄 Statelessness
- Each request must contain all the information needed to understand and process it
- Server doesn't store client context between requests
- Session state is kept entirely on the client

**Example:**
```http
# Bad - Relies on server session
GET /api/next-page

# Good - Self-contained request
GET /api/products?page=2&pageSize=10
```

### 2. 📍 Resource-Based
- Everything is a resource identified by URIs
- Resources are separate from their representations
- Use nouns, not verbs in URIs

**Examples:**
```
✅ Good URIs:
/api/products
/api/products/123
/api/users/456/orders

❌ Bad URIs:
/api/getProducts
/api/deleteUser
/api/updateProductPrice
```

### 3. 🌐 Uniform Interface
- Use standard HTTP methods consistently
- Resources are manipulated through representations
- Self-descriptive messages
- HATEOAS (Hypermedia as the Engine of Application State)

**HTTP Methods Mapping:**
| Operation | HTTP Method | Example |
|-----------|------------|---------|
| Create | POST | POST /api/products |
| Read | GET | GET /api/products/123 |
| Update (full) | PUT | PUT /api/products/123 |
| Update (partial) | PATCH | PATCH /api/products/123 |
| Delete | DELETE | DELETE /api/products/123 |

### 4. 🎭 Multiple Representations
- Resources can have multiple representations (JSON, XML, HTML)
- Use content negotiation via Accept and Content-Type headers

**Example:**
```http
# Request JSON
GET /api/products/123
Accept: application/json

# Request XML
GET /api/products/123
Accept: application/xml
```

### 5. 🏗️ Layered System
- Architecture can be composed of hierarchical layers
- Each layer doesn't know about layers beyond the next one
- Enables scalability through load balancing and caching

### 6. 💾 Cacheability
- Responses must define themselves as cacheable or non-cacheable
- Improves scalability and performance

**Cache Headers:**
```http
# Cacheable response
Cache-Control: public, max-age=3600
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"

# Non-cacheable response
Cache-Control: no-cache, no-store, must-revalidate
```

## RESTful API Design Best Practices

### 1. Resource Naming
```
# Collections - Use plural nouns
/api/products
/api/users
/api/orders

# Single resources - Use identifiers
/api/products/123
/api/users/456
/api/orders/789

# Nested resources - Show relationships
/api/users/456/orders
/api/orders/789/items
```

### 2. HTTP Status Codes

#### Success Codes (2xx)
- **200 OK** - General success
- **201 Created** - Resource created successfully
- **202 Accepted** - Request accepted for processing
- **204 No Content** - Success with no response body

#### Client Error Codes (4xx)
- **400 Bad Request** - Invalid request format
- **401 Unauthorized** - Authentication required
- **403 Forbidden** - Access denied
- **404 Not Found** - Resource doesn't exist
- **409 Conflict** - Request conflicts with current state
- **422 Unprocessable Entity** - Validation errors

#### Server Error Codes (5xx)
- **500 Internal Server Error** - Generic server error
- **502 Bad Gateway** - Invalid response from upstream server
- **503 Service Unavailable** - Server temporarily unavailable

### 3. Filtering, Sorting, and Pagination

**Filtering:**
```http
GET /api/products?category=electronics&minPrice=100&maxPrice=1000
```

**Sorting:**
```http
GET /api/products?sortBy=price&sortOrder=desc
```

**Pagination:**
```http
GET /api/products?page=2&pageSize=20
```

### 4. Versioning Strategies

**URI Versioning:**
```http
GET /api/v1/products
GET /api/v2/products
```

**Header Versioning:**
```http
GET /api/products
X-API-Version: 1.0
```

**Query String Versioning:**
```http
GET /api/products?version=1.0
```

**Media Type Versioning:**
```http
GET /api/products
Accept: application/vnd.company.v1+json
```

### 5. Error Response Format

Consistent error responses improve API usability:

```json
{
  "error": {
    "code": "PRODUCT_NOT_FOUND",
    "message": "Product with ID 123 not found",
    "details": [
      {
        "field": "productId",
        "message": "Invalid product identifier"
      }
    ],
    "timestamp": "2024-01-20T10:30:00Z",
    "path": "/api/products/123"
  }
}
```

### 6. HATEOAS Example

Including links for discoverability:

```json
{
  "id": 123,
  "name": "Laptop",
  "price": 999.99,
  "_links": {
    "self": {
      "href": "/api/products/123"
    },
    "update": {
      "href": "/api/products/123",
      "method": "PUT"
    },
    "delete": {
      "href": "/api/products/123",
      "method": "DELETE"
    },
    "category": {
      "href": "/api/categories/electronics"
    }
  }
}
```

## RESTful vs Non-RESTful Examples

### Non-RESTful (RPC-style)
```
POST /api/getUser
POST /api/createUser
POST /api/updateUserEmail
POST /api/deleteUser
POST /api/findUsersByName
```

### RESTful
```
GET    /api/users/{id}
POST   /api/users
PUT    /api/users/{id}
PATCH  /api/users/{id}
DELETE /api/users/{id}
GET    /api/users?name=john
```

## Common REST Anti-Patterns to Avoid

1. **Using verbs in URIs**
   - ❌ `/api/getProducts`
   - ✅ `/api/products`

2. **Not using proper HTTP methods**
   - ❌ `POST /api/products/delete/123`
   - ✅ `DELETE /api/products/123`

3. **Ignoring status codes**
   - ❌ Always returning 200 with error in body
   - ✅ Using appropriate status codes

4. **Nested resources too deep**
   - ❌ `/api/users/123/orders/456/items/789/details`
   - ✅ `/api/order-items/789` or `/api/orders/456/items`

5. **Not supporting content negotiation**
   - ❌ Separate endpoints for different formats
   - ✅ Using Accept headers

## REST Maturity Model (Richardson)

### Level 0: The Swamp of POX
- Single URI, single HTTP method
- Uses HTTP as transport only

### Level 1: Resources
- Multiple URIs, one per resource
- Still uses single HTTP method (usually POST)

### Level 2: HTTP Verbs
- Multiple URIs
- Proper use of HTTP methods
- Proper use of status codes

### Level 3: Hypermedia Controls
- HATEOAS
- Self-descriptive messages
- Discoverable API

## Tools for Testing REST APIs

1. **Postman** - GUI-based API testing
2. **curl** - Command-line HTTP client
3. **HTTPie** - User-friendly command-line HTTP client
4. **REST Client** - VS Code extension
5. **Swagger/OpenAPI** - API documentation and testing

## ASP.NET Core REST Implementation Tips

1. **Use attribute routing for clarity:**
   ```csharp
   [Route("api/[controller]")]
   [ApiController]
   public class ProductsController : ControllerBase
   ```

2. **Return appropriate action results:**
   ```csharp
   return Ok(product);           // 200
   return Created(uri, product); // 201
   return NoContent();          // 204
   return NotFound();           // 404
   ```

3. **Use DTOs for API contracts:**
   ```csharp
   public record ProductDto(
       int Id,
       string Name,
       decimal Price
   );
   ```

4. **Implement proper validation:**
   ```csharp
   [Required]
   [StringLength(100)]
   public string Name { get; set; }
   ```

## Further Reading

- [Roy Fielding's Dissertation](https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm)
- [Microsoft REST API Guidelines](https://github.com/Microsoft/api-guidelines)
- [RESTful Web Services Cookbook](https://www.oreilly.com/library/view/restful-web-services/9780596809140/)
- [REST API Design Rulebook](https://www.oreilly.com/library/view/rest-api-design/9781449317904/)

---

Remember: REST is an architectural style, not a standard. The goal is to create APIs that are scalable, maintainable, and easy to use.