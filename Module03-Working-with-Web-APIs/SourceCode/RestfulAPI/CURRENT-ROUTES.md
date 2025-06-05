# Current API Routes Configuration

## 🏠 Main Pages
- **Swagger UI**: `/` (root URL) - Interactive API documentation
- **Static Welcome Page**: `/index.html` - Overview of API features
- **Health Check**: `/health` - Application health status

## 📦 API Endpoints

### Products API v1
All endpoints require the `/api/v1/` prefix:
- `GET /api/v1/products` - List all products
- `GET /api/v1/products/{id}` - Get specific product
- `POST /api/v1/products` - Create new product
- `PUT /api/v1/products/{id}` - Update product
- `PATCH /api/v1/products/{id}` - Partial update
- `DELETE /api/v1/products/{id}` - Delete product
- `GET /api/v1/products/categories` - Get categories
- `GET /api/v1/products/search?query={text}` - Search products
- `GET /api/v1/products/secure` - Secure endpoint (requires auth)

### Products API v2
All endpoints require the `/api/v2/` prefix:
- `GET /api/v2/products` - List with enhanced metadata
- `GET /api/v2/products/{id}?includeStats=true` - Get with statistics
- `POST /api/v2/products/bulk` - Bulk create products
- `GET /api/v2/products/statistics` - Get statistics
- `GET /api/v2/products/export` - Export to CSV

### Authentication API
No versioning on auth endpoints:
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login
- `GET /api/auth/profile` - Get profile (requires auth)
- `POST /api/auth/change-password` - Change password (requires auth)
- `POST /api/auth/validate-token` - Validate JWT token
- `GET /api/auth/test` - Test authentication
- `GET /api/auth/admin-test` - Test admin role

### Minimal API
- `GET /api/minimal/products` - List products
- `GET /api/minimal/products/{id}` - Get product
- `POST /api/minimal/products` - Create product
- `DELETE /api/minimal/products/{id}` - Delete product

## ⚠️ Important Notes

1. **No route at `/api/products`** - Must use versioned routes like `/api/v1/products`
2. **Swagger UI at root** - Access API documentation at `http://localhost:5000/`
3. **Static files available** - Access welcome page at `/index.html`
4. **Environment must be Development** - Swagger only available in Development mode

## 🧪 Quick Test Commands

```bash
# Test v1 API
curl http://localhost:5000/api/v1/products

# Test v2 API
curl http://localhost:5000/api/v2/products

# Test health
curl http://localhost:5000/health

# Access Swagger UI
open http://localhost:5000/

# Access static welcome page
open http://localhost:5000/index.html
```